#import "TGMediaPickerAssetsLibrary.h"

#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>

#import "ATQueue.h"
#import "TGTimer.h"

#import "TGMediaPickerAsset.h"
#import "TGMediaPickerAssetsGroup.h"

@interface TGMediaPickerAssetsLibrary () <PHPhotoLibraryChangeObserver>
{
    ALAssetsLibrary *_assetsLibrary;
    PHPhotoLibrary *_photoLibrary;
    
    ATQueue *_queue;
    
    TGTimer *_libraryChangeDelayTimer;
}
@end

@implementation TGMediaPickerAssetsLibrary

- (instancetype)initForAssetType:(TGMediaPickerAssetType)assetType
{
    self = [super init];
    if (self != nil)
    {
        _assetType = assetType;
        
        _queue = [[ATQueue alloc] init];
        
        if (iosMajorVersion() >= 8)
        {
            _photoLibrary = [PHPhotoLibrary sharedPhotoLibrary];
            [_photoLibrary registerChangeObserver:self];
        }
        else
        {
            _assetsLibrary = [[ALAssetsLibrary alloc] init];
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(assetsLibraryDidChange:)
                                                         name:ALAssetsLibraryChangedNotification
                                                       object:nil];
        }
        
        [self authorizationStatus];
    }
    return self;
}

- (void)dealloc
{
    if (_photoLibrary != nil)
        [_photoLibrary unregisterChangeObserver:self];
    else if (_assetsLibrary != nil)
        [[NSNotificationCenter defaultCenter] removeObserver:self name:ALAssetsLibraryChangedNotification object:nil];
    
    if (_libraryChangeDelayTimer != nil)
    {
        [_libraryChangeDelayTimer invalidate];
        _libraryChangeDelayTimer = nil;
    }
}

- (void)fetchAssetsGroupsWithCompletionBlock:(void (^)(NSArray *, TGMediaPickerAuthorizationStatus, NSError *))completionBlock
{
    if (completionBlock == nil)
        return;
    
    [_queue dispatch:^
    {
        NSMutableArray *assetGroups = [NSMutableArray array];
        
        if (_photoLibrary != nil)
        {
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status)
            {
                if (status != PHAuthorizationStatusAuthorized)
                {
                    if (completionBlock)
                        completionBlock(nil, [self authorizationStatus], nil);
                    return;
                }

                PHFetchResult *collections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAny options:nil];
                for (PHAssetCollection *collection in collections)
                {
                    PHFetchResult *fetchResult;
                    NSArray *latestAssets = [self _fetchLatestAssetsInCollection:collection fetchResult:&fetchResult];
                    
                    [assetGroups addObject:[[TGMediaPickerAssetsGroup alloc] initWithPHAssetCollection:collection
                                                                                           fetchResult:fetchResult
                                                                                          latestAssets:latestAssets]];
                }
                
                [self _findCameraRollAssetsGroupAndFetchLatestAssets:true reversed:false completion:^(TGMediaPickerAssetsGroup *cameraRollAssetsGroup, __unused NSError *error)
                {
                    [assetGroups insertObject:cameraRollAssetsGroup atIndex:0];
                }];
                
                PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAny options:nil];
                for (PHAssetCollection *collection in smartAlbums)
                {
                    if ([TGMediaPickerAssetsLibrary _isSmartAlbumCollectionSubtype:collection.assetCollectionSubtype requiredForAssetType:_assetType])
                    {
                        PHFetchResult *fetchResult;
                        NSArray *latestAssets = [self _fetchLatestAssetsInCollection:collection fetchResult:&fetchResult];
                        
                        if (latestAssets.count > 0)
                        {
                            [assetGroups addObject:[[TGMediaPickerAssetsGroup alloc] initWithPHAssetCollection:collection
                                                                                                   fetchResult:fetchResult
                                                                                                  latestAssets:latestAssets]];
                        }
                    }
                }
                
                [assetGroups sortUsingFunction:TGMediaPickerAssetsGroupComparator context:nil];
                
                if (completionBlock)
                    completionBlock(assetGroups, [self authorizationStatus], nil);
            }];
        }
        else if (_assetsLibrary != nil)
        {
            [_assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, __unused BOOL *stop)
            {
                if (group != nil)
                {
                    if (_assetType != TGMediaPickerAssetAnyType)
                        [group setAssetsFilter:[TGMediaPickerAssetsLibrary _assetsFilterForAssetType:_assetType]];
                    
                    NSArray *latestAssets = [self _fetchLatestAssetsInGroup:group];
                    
                    [assetGroups addObject:[[TGMediaPickerAssetsGroup alloc] initWithALAssetsGroup:group
                                                                                      latestAssets:latestAssets]];
                }
                else
                {
                    [assetGroups sortUsingFunction:TGMediaPickerAssetsGroupComparator context:nil];
                    
                    if (completionBlock)
                        completionBlock(assetGroups, [self authorizationStatus], nil);
                }
            } failureBlock:^(NSError *error)
            {
                if (completionBlock)
                    completionBlock(nil, [self authorizationStatus], error);
            }];
        }
    }];
}

- (void)fetchAssetsOfAssetsGroup:(TGMediaPickerAssetsGroup *)assetsGroup withCompletionBlock:(void (^)(NSArray *, TGMediaPickerAuthorizationStatus, NSError *))completionBlock
{
    if (completionBlock == nil)
        return;
    
    [_queue dispatch:^
    {
        NSMutableArray *assets = [NSMutableArray array];
        
        if (_photoLibrary != nil)
        {
            [TGMediaPickerAssetsLibrary _requestAuthorizationWithCompletion:^(TGMediaPickerAuthorizationStatus status)
            {
                if (status != TGMediaPickerAuthorizationStatusAuthorized)
                {
                    if (completionBlock != nil)
                        completionBlock(nil, status, nil);
                    return;
                }
            
                void (^enumerateAssetsInFetchResult)(PHFetchResult *, bool) = ^(PHFetchResult *fetchResult, bool isCameraRoll)
                {
                    for (PHAsset *asset in fetchResult)
                    {
                        if (iosMajorVersion() == 8 && iosMinorVersion() < 1)
                        {
                            //that's the only way to filter out stream photos on iOS < 8.1
                            if (!isCameraRoll || [[asset valueForKey:@"assetSource"] isEqualToNumber:@3] || _assetType == TGMediaPickerAssetVideoType)
                            {
                                TGMediaPickerAsset *pickerAsset = [[TGMediaPickerAsset alloc] initWithPHAsset:asset];
                                if (pickerAsset != nil)
                                    [assets addObject:pickerAsset];
                            }
                        }
                        else
                        {
                            TGMediaPickerAsset *pickerAsset = [[TGMediaPickerAsset alloc] initWithPHAsset:asset];
                            if (pickerAsset != nil)
                                [assets addObject:pickerAsset];
                        }
                    }

                    if (completionBlock)
                        completionBlock(assets, [self authorizationStatus], nil);
                };
                
                if (assetsGroup != nil)
                {
                    enumerateAssetsInFetchResult(assetsGroup.backingFetchResult, assetsGroup.isCameraRoll);
                }
                else
                {
                    [self _findCameraRollAssetsGroupAndFetchLatestAssets:false reversed:false completion:^(TGMediaPickerAssetsGroup *cameraRollAssetsGroup, NSError *error)
                    {
                        if (cameraRollAssetsGroup && error == nil)
                            enumerateAssetsInFetchResult(cameraRollAssetsGroup.backingFetchResult, true);
                    }];
                }
            }];
        }
        else if (_assetsLibrary != nil)
        {
            void (^enumerateAssetsInGroup)(ALAssetsGroup *) = ^(ALAssetsGroup *assetsGroup)
            {
                [assetsGroup enumerateAssetsUsingBlock:^(ALAsset *asset, __unused NSUInteger index, __unused BOOL *stop)
                {
                    if (asset != nil)
                        [assets addObject:[[TGMediaPickerAsset alloc] initWithALAsset:asset]];
                }];
                
                if (completionBlock)
                    completionBlock(assets, [self authorizationStatus], nil);
            };
            
            if (assetsGroup != nil)
            {
                enumerateAssetsInGroup(assetsGroup.backingAssetsGroup);
            }
            else
            {
                [self _findCameraRollAssetsGroupAndFetchLatestAssets:false reversed:false completion:^(TGMediaPickerAssetsGroup *cameraRollAssetsGroup, NSError *error)
                {
                    if (cameraRollAssetsGroup && error == nil)
                    {
                        enumerateAssetsInGroup(cameraRollAssetsGroup.backingAssetsGroup);
                    }
                    else
                    {
                        if (completionBlock != nil)
                            completionBlock(nil, [self authorizationStatus], error);
                    }
                }];
            }
        }
    }];
}

- (void)fetchAssetsOfAssetsGroup:(TGMediaPickerAssetsGroup *)assetsGroup reversed:(bool)reversed withEnumerationBlock:(void (^)(TGMediaPickerAsset *, TGMediaPickerAuthorizationStatus, NSError *))enumerationBlock
{
    if (enumerationBlock == nil)
        return;
    
    [_queue dispatch:^
    {
        if (_photoLibrary != nil)
        {
            [TGMediaPickerAssetsLibrary _requestAuthorizationWithCompletion:^(TGMediaPickerAuthorizationStatus status)
            {
                if (status != TGMediaPickerAuthorizationStatusAuthorized)
                {
                    if (enumerationBlock != nil)
                        enumerationBlock(nil, status, nil);
                    return;
                }
                
                void (^enumerateAssetsInFetchResult)(PHFetchResult *, bool) = ^(PHFetchResult *fetchResult, bool isCameraRoll)
                {
                    for (PHAsset *asset in fetchResult)
                    {
                        if (!(iosMajorVersion() == 8 && iosMinorVersion() < 1) || (!isCameraRoll || [[asset valueForKey:@"assetSource"] isEqualToNumber:@3] || _assetType == TGMediaPickerAssetVideoType))
                        {
                            if (!(_assetType == TGMediaPickerAssetAnyType && (asset.mediaSubtypes & PHAssetMediaSubtypeVideoHighFrameRate)))
                            {
                                TGMediaPickerAsset *mediaPickerAsset = [[TGMediaPickerAsset alloc] initWithPHAsset:asset];
                                enumerationBlock(mediaPickerAsset, TGMediaPickerAuthorizationStatusAuthorized, nil);
                            }
                        }
                    }

                    enumerationBlock(nil, TGMediaPickerAuthorizationStatusAuthorized, nil);
                };
                
                if (assetsGroup != nil)
                {
                    enumerateAssetsInFetchResult(assetsGroup.backingFetchResult, assetsGroup.isCameraRoll);
                }
                else
                {
                    [self _findCameraRollAssetsGroupAndFetchLatestAssets:false reversed:reversed completion:^(TGMediaPickerAssetsGroup *cameraRollAssetsGroup, NSError *error)
                    {
                        if (cameraRollAssetsGroup && error == nil)
                            enumerateAssetsInFetchResult(cameraRollAssetsGroup.backingFetchResult, true);
                    }];
                }
            }];
        }
        else if (_assetsLibrary != nil)
        {
            void (^enumerateAssetsInGroup)(ALAssetsGroup *) = ^(ALAssetsGroup *assetsGroup)
            {
                NSEnumerationOptions options = 0;
                if (reversed)
                    options = NSEnumerationReverse;
                
                [assetsGroup enumerateAssetsWithOptions:options usingBlock:^(ALAsset *asset, __unused NSUInteger index, __unused BOOL *stop)
                {
                    if (asset != nil)
                    {
                        TGMediaPickerAsset *mediaPickerAsset = [[TGMediaPickerAsset alloc] initWithALAsset:asset];
                        enumerationBlock(mediaPickerAsset, TGMediaPickerAuthorizationStatusAuthorized, nil);
                    }
                    else
                    {
                        enumerationBlock(nil, TGMediaPickerAuthorizationStatusAuthorized, nil);
                    }
                }];
            };
            
            if (assetsGroup != nil)
            {
                enumerateAssetsInGroup(assetsGroup.backingAssetsGroup);
            }
            else
            {
                [self _findCameraRollAssetsGroupAndFetchLatestAssets:false reversed:false completion:^(TGMediaPickerAssetsGroup *cameraRollAssetsGroup, NSError *error)
                 {
                     if (cameraRollAssetsGroup && error == nil)
                     {
                         enumerateAssetsInGroup(cameraRollAssetsGroup.backingAssetsGroup);
                     }
                     else
                     {
                         if (enumerationBlock != nil)
                             enumerationBlock(nil, [self authorizationStatus], error);
                     }
                 }];
            }
        }
    }];
}

+ (UIImage *)normalizedImageFromImage:(UIImage *)image
{
    if (image.imageOrientation == UIImageOrientationUp) return image;
    
    UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale);
    [image drawInRect:(CGRect){{ 0, 0 }, image.size}];
    UIImage *normalizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return normalizedImage;
}

- (void)saveAssetWithImage:(UIImage *)image completionBlock:(void (^)(bool, NSString *, NSError *))completionBlock
{
    if (image == nil)
        return;
    
    [_queue dispatch:^
    {
        if (_photoLibrary != nil)
        {
            [TGMediaPickerAssetsLibrary _requestAuthorizationWithCompletion:^(TGMediaPickerAuthorizationStatus status)
            {
                if (status != TGMediaPickerAuthorizationStatusAuthorized)
                {
                    if (completionBlock != nil)
                        completionBlock(false, nil, nil);
                    return;
                }
                
                __block NSString *localIdentifier = nil;
                [_photoLibrary performChanges:^
                {
                    PHAssetChangeRequest *request = [PHAssetChangeRequest creationRequestForAssetFromImage:image];
                    localIdentifier = request.placeholderForCreatedAsset.localIdentifier;
                } completionHandler:^(BOOL success, NSError *error)
                {
                    if (completionBlock != nil)
                        completionBlock(success, localIdentifier, error);
                }];
            }];
        }
        else if (_assetsLibrary != nil)
        {
            [_assetsLibrary writeImageToSavedPhotosAlbum:image.CGImage
                                             orientation:(ALAssetOrientation)image.imageOrientation
                                         completionBlock:^(NSURL *assetURL, NSError *error)
            {
                if (completionBlock)
                    completionBlock(assetURL != nil, assetURL.absoluteString, error);
            }];
        }
    }];
}

- (void)saveAssetWithImageData:(NSData *)data completionBlock:(void (^)(bool, NSString *, NSError *))completionBlock
{
    if (data == nil || data.length == 0)
        return;
    
    [_queue dispatch:^
    {
        if (_photoLibrary != nil)
        {
            [TGMediaPickerAssetsLibrary _requestAuthorizationWithCompletion:^(TGMediaPickerAuthorizationStatus status)
            {
                if (status != TGMediaPickerAuthorizationStatusAuthorized)
                {
                    if (completionBlock != nil)
                        completionBlock(false, nil, nil);
                    return;
                }

                __block NSString *localIdentifier = nil;
                [_photoLibrary performChanges:^
                {
                    PHAssetChangeRequest *request = [PHAssetChangeRequest creationRequestForAssetFromImage:[UIImage imageWithData:data]];
                    localIdentifier = request.placeholderForCreatedAsset.localIdentifier;
                } completionHandler:^(BOOL success, NSError *error)
                {
                    if (completionBlock != nil)
                        completionBlock(success, localIdentifier, error);
                }];
            }];
        }
        else if (_assetsLibrary != nil)
        {
            [_assetsLibrary writeImageDataToSavedPhotosAlbum:data metadata:nil completionBlock:^(NSURL *assetURL, NSError *error)
            {
                if (completionBlock)
                    completionBlock(assetURL != nil, assetURL.absoluteString, error);
            }];
        }
    }];
}

- (void)saveAssetWithImageAtURL:(NSURL *)url completionBlock:(void (^)(bool, NSString *, NSError *))completionBlock
{
    [self _saveAssetWithURL:url isVideo:false completionBlock:completionBlock];
}

- (void)saveAssetWithVideoAtURL:(NSURL *)url completionBlock:(void (^)(bool, NSString *, NSError *))completionBlock
{
    [self _saveAssetWithURL:url isVideo:true completionBlock:completionBlock];
}

- (void)_saveAssetWithURL:(NSURL *)url isVideo:(bool)isVideo completionBlock:(void (^)(bool, NSString *, NSError *))completionBlock
{
    if (url == nil)
        return;
    
    [_queue dispatch:^
    {
        if (_photoLibrary != nil)
        {
            [TGMediaPickerAssetsLibrary _requestAuthorizationWithCompletion:^(TGMediaPickerAuthorizationStatus status)
            {
                if (status != TGMediaPickerAuthorizationStatusAuthorized)
                {
                    if (completionBlock != nil)
                        completionBlock(false, nil, nil);
                    return;
                }
                
                __block NSString *localIdentifier = nil;
                [_photoLibrary performChanges:^
                {
                    PHAssetChangeRequest *request = nil;
                    if (!isVideo)
                        request = [PHAssetChangeRequest creationRequestForAssetFromImageAtFileURL:url];
                    else
                        request = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:url];
                     
                    localIdentifier = request.placeholderForCreatedAsset.localIdentifier;
                } completionHandler:^(BOOL success, NSError *error)
                {
                    if (completionBlock != nil)
                        completionBlock(success, localIdentifier, error);
                }];
            }];
        }
        else if (_assetsLibrary != nil)
        {
            void (^writeCompletionBlock)(NSURL *, NSError *) = ^(NSURL *assetURL, NSError *error)
            {
                if (completionBlock != nil)
                {
                    NSString *uniqueId = nil;
                    if (assetURL != nil)
                        uniqueId = [assetURL absoluteString];
                    
                    completionBlock((assetURL != nil), uniqueId, error);
                }
            };
            
            if (!isVideo)
            {
                NSData *data = [[NSData alloc] initWithContentsOfURL:url];
                [_assetsLibrary writeImageDataToSavedPhotosAlbum:data metadata:nil completionBlock:writeCompletionBlock];
            }
            else
            {
                [_assetsLibrary writeVideoAtPathToSavedPhotosAlbum:url completionBlock:writeCompletionBlock];
            }
        }
    }];
}

- (void)assetsLibraryDidChange:(NSNotification *)__unused notification
{
    [self _libraryDidChange];
}

- (void)photoLibraryDidChange:(PHChange *)__unused changeInstance
{
    [self _libraryDidChange];
}

- (void)_libraryDidChange
{
    if (self.libraryChanged == nil)
        return;
    
    [_queue dispatch:^
    {
        if (_libraryChangeDelayTimer != nil)
        {
            [_libraryChangeDelayTimer invalidate];
            _libraryChangeDelayTimer = nil;
        }
 
        __weak TGMediaPickerAssetsLibrary *weakSelf = self;
        _libraryChangeDelayTimer = [[TGTimer alloc] initWithTimeout:1.0f repeat:false completion:^
        {
            __strong TGMediaPickerAssetsLibrary *strongSelf = weakSelf;
            if (strongSelf == nil)
                return;
            
            if (strongSelf.libraryChanged != nil)
                strongSelf.libraryChanged();
        } queue:_queue.nativeQueue];
        [_libraryChangeDelayTimer start];
    }];
}

NSInteger TGMediaPickerAssetsGroupComparator(TGMediaPickerAssetsGroup *group1, TGMediaPickerAssetsGroup *group2, __unused void *context)
{
    if (group1.subtype < group2.subtype)
        return NSOrderedAscending;
    else if (group1.subtype > group2.subtype)
        return NSOrderedDescending;
        
    return [group1.title localizedStandardCompare:group2.title];
}

- (NSArray *)_fetchLatestAssetsInGroup:(ALAssetsGroup *)assetsGroup
{
    NSMutableArray *latestAssets = [[NSMutableArray alloc] init];
    [assetsGroup enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *asset, __unused NSUInteger index, BOOL *stop)
    {
        if (asset != nil)
            [latestAssets addObject:[[TGMediaPickerAsset alloc] initWithALAsset:asset]];
        if (latestAssets.count == 3 && stop != NULL)
            *stop = true;
    }];
    
    return latestAssets;
}

- (NSArray *)_fetchLatestAssetsInCollection:(PHAssetCollection *)assetCollection fetchResult:(out PHFetchResult **)fetchResult
{
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    if (_assetType != TGMediaPickerAssetAnyType)
        options.predicate = [NSPredicate predicateWithFormat:@"mediaType = %i", [TGMediaPickerAssetsLibrary _assetMediaTypeForAssetType:_assetType]];

    PHFetchResult *assetFetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:options];
    
    bool isCameraRoll = false;
    if (assetCollection.assetCollectionType == PHAssetCollectionTypeSmartAlbum &&
        assetCollection.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumUserLibrary)
    {
        isCameraRoll = true;
    }
    
    NSArray *latestAssets = [self _fetchLatestAssetsInFetchResult:assetFetchResult reverse:isCameraRoll];

    if (fetchResult != NULL)
        *fetchResult = assetFetchResult;
    
    return latestAssets;
}

- (NSArray *)_fetchLatestAssetsInFetchResult:(PHFetchResult *)fetchResult reverse:(bool)reverse
{
    NSMutableArray *latestAssets = [[NSMutableArray alloc] init];

    NSInteger totalCount = fetchResult.count;
    
    if (totalCount == 0)
        return latestAssets;
    
    NSInteger requiredCount = MIN(3, totalCount);

    for (NSInteger i = 0; i < requiredCount; i++)
    {
        NSInteger index = reverse ? totalCount - i - 1 : i;
        PHAsset *asset = [fetchResult objectAtIndex:index];
        
        TGMediaPickerAsset *pickerAsset = [[TGMediaPickerAsset alloc] initWithPHAsset:asset];
        
        if (pickerAsset != nil)
            [latestAssets addObject:pickerAsset];
    }

    return latestAssets;
}

- (void)_findCameraRollAssetsGroupAndFetchLatestAssets:(bool)fetchLatestAssets reversed:(bool)reversed completion:(void (^)(TGMediaPickerAssetsGroup *cameraRollAssetsGroup, NSError *error))completion
{
    if (completion == nil)
        return;
    
    if (_photoLibrary != nil)
    {
        if (iosMajorVersion() == 8 && iosMinorVersion() < 1)
        {
            PHFetchOptions *options = [PHFetchOptions new];
            
            if (reversed)
                options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:false]];
            
            PHFetchResult *fetchResult = nil;
            
            if (_assetType == TGMediaPickerAssetAnyType)
            {
                fetchResult = [PHAsset fetchAssetsWithOptions:options];
            }
            else
            {
                fetchResult = [PHAsset fetchAssetsWithMediaType:[TGMediaPickerAssetsLibrary _assetMediaTypeForAssetType:_assetType]
                                                        options:options];
            }
            
            NSArray *latestAssets = nil;
            if (fetchLatestAssets)
                latestAssets = [self _fetchLatestAssetsInFetchResult:fetchResult reverse:true];

            if (completion != nil)
            {
                completion([[TGMediaPickerAssetsGroup alloc] initWithPHFetchResult:fetchResult
                                                                      latestAssets:latestAssets], nil);
            }
        }
        else
        {
            PHFetchResult *collectionsFetchResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum
                                                                                             subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary
                                                                                             options:nil];
            PHAssetCollection *cameraRollCollection;
            PHFetchResult *fetchResult;
            NSArray *latestAssets;
            if (collectionsFetchResult.count > 0)
            {
                cameraRollCollection = collectionsFetchResult.firstObject;
                
                PHFetchOptions *options = [[PHFetchOptions alloc] init];
                if (_assetType != TGMediaPickerAssetAnyType)
                    options.predicate = [NSPredicate predicateWithFormat:@"mediaType = %i", [TGMediaPickerAssetsLibrary _assetMediaTypeForAssetType:_assetType]];
                
                if (reversed)
                    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:false]];
                
                fetchResult = [PHAsset fetchAssetsInAssetCollection:cameraRollCollection options:options];
                
                if (fetchLatestAssets)
                    latestAssets = [self _fetchLatestAssetsInFetchResult:fetchResult reverse:true];
            }

            if (completion != nil)
            {
                completion([[TGMediaPickerAssetsGroup alloc] initWithPHAssetCollection:cameraRollCollection
                                                                           fetchResult:fetchResult
                                                                          latestAssets:latestAssets], nil);
            }
        }
    }
    else if (_assetsLibrary != nil)
    {
        [_assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, __unused BOOL *stop)
        {
            if (group != nil)
            {
                if (stop != NULL)
                    *stop = true;
                
                if (_assetType != TGMediaPickerAssetAnyType)
                    [group setAssetsFilter:[TGMediaPickerAssetsLibrary _assetsFilterForAssetType:_assetType]];
                
                if (completion != nil)
                    completion([[TGMediaPickerAssetsGroup alloc] initWithALAssetsGroup:group latestAssets:nil], nil);
            }
        } failureBlock:^(NSError *error)
        {
            if (completion != nil)
                completion(nil, error);
        }];
    }
}

+ (bool)_isSmartAlbumCollectionSubtype:(PHAssetCollectionSubtype)subtype requiredForAssetType:(TGMediaPickerAssetType)assetType
{
    switch (subtype)
    {
        case PHAssetCollectionSubtypeSmartAlbumPanoramas:
        {
            switch (assetType)
            {
                case TGMediaPickerAssetVideoType:
                    return false;
                    
                default:
                    return true;
            }
        }
            break;
            
        case PHAssetCollectionSubtypeSmartAlbumFavorites:
        {
            return true;
        }
            break;
            
        case PHAssetCollectionSubtypeSmartAlbumTimelapses:
        {
            switch (assetType)
            {
                case TGMediaPickerAssetPhotoType:
                    return false;
                    
                default:
                    return true;
            }
        }
            break;

        case PHAssetCollectionSubtypeSmartAlbumVideos:
        {
            switch (assetType)
            {
                case TGMediaPickerAssetAnyType:
                    return true;
                    
                default:
                    return false;
            }
        }
            
        case PHAssetCollectionSubtypeSmartAlbumSlomoVideos:
        {
            switch (assetType)
            {
                case TGMediaPickerAssetVideoType:
                    return true;
                    
                default:
                    return false;
            }
        }
            break;
            
        case PHAssetCollectionSubtypeSmartAlbumBursts:
        {
            switch (assetType)
            {
                case TGMediaPickerAssetVideoType:
                    return false;
                    
                default:
                    return true;
            }
        }
            break;
            
        default:
        {
            return false;
        }
    }
}

+ (PHAssetMediaType)_assetMediaTypeForAssetType:(TGMediaPickerAssetType)assetType
{
    switch (assetType)
    {
        case TGMediaPickerAssetPhotoType:
            return PHAssetMediaTypeImage;
            
        case TGMediaPickerAssetVideoType:
            return PHAssetMediaTypeVideo;
            
        default:
            return PHAssetMediaTypeUnknown;
    }
}

+ (ALAssetsFilter *)_assetsFilterForAssetType:(TGMediaPickerAssetType)assetType
{
    switch (assetType)
    {
        case TGMediaPickerAssetPhotoType:
            return [ALAssetsFilter allPhotos];
        
        case TGMediaPickerAssetVideoType:
            return [ALAssetsFilter allVideos];
        
        default:
            return [ALAssetsFilter allAssets];
    }
}

+ (void)_requestAuthorizationWithCompletion:(void(^)(TGMediaPickerAuthorizationStatus status))completion
{
    if (completion == nil)
        return;
    
    if (cachedAuthorizationStatus != TGMediaPickerAuthorizationStatusNotDetermined)
    {
        completion(cachedAuthorizationStatus);
        return;
    }
    
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status)
    {
        completion([TGMediaPickerAssetsLibrary _authorizationStatusForPHAuthorizationStatus:status]);
    }];
}

static TGMediaPickerAuthorizationStatus cachedAuthorizationStatus = TGMediaPickerAuthorizationStatusNotDetermined;

- (TGMediaPickerAuthorizationStatus)authorizationStatus
{
    if (cachedAuthorizationStatus != TGMediaPickerAuthorizationStatusNotDetermined)
        return cachedAuthorizationStatus;
    
    if (_photoLibrary != nil)
        cachedAuthorizationStatus = [TGMediaPickerAssetsLibrary _authorizationStatusForPHAuthorizationStatus:[PHPhotoLibrary authorizationStatus]];
    else if (_assetsLibrary != nil)
        cachedAuthorizationStatus = [TGMediaPickerAssetsLibrary _authorizationStatusForALAuthorizationStatus:[ALAssetsLibrary authorizationStatus]];
    
    return cachedAuthorizationStatus;
}

+ (TGMediaPickerAuthorizationStatus)_authorizationStatusForPHAuthorizationStatus:(PHAuthorizationStatus)status
{
    switch (status)
    {
        case PHAuthorizationStatusRestricted:
            return TGMediaPickerAuthorizationStatusRestricted;
            
        case PHAuthorizationStatusDenied:
            return TGMediaPickerAuthorizationStatusDenied;
            
        case PHAuthorizationStatusAuthorized:
            return TGMediaPickerAuthorizationStatusAuthorized;
            
        default:
            return TGMediaPickerAuthorizationStatusNotDetermined;
    }
}

+ (TGMediaPickerAuthorizationStatus)_authorizationStatusForALAuthorizationStatus:(ALAuthorizationStatus)status
{
    switch (status)
    {
        case ALAuthorizationStatusRestricted:
            return TGMediaPickerAuthorizationStatusRestricted;
            
        case ALAuthorizationStatusDenied:
            return TGMediaPickerAuthorizationStatusDenied;
            
        case ALAuthorizationStatusAuthorized:
            return TGMediaPickerAuthorizationStatusAuthorized;
            
        default:
            return TGMediaPickerAuthorizationStatusNotDetermined;
    }
}

+ (instancetype)sharedLibrary
{
    static dispatch_once_t once;
    static TGMediaPickerAssetsLibrary *instance;
    dispatch_once(&once, ^
    {
        instance = [[self alloc] initForAssetType:TGMediaPickerAssetAnyType];
    });
    
    return instance;
}

@end
