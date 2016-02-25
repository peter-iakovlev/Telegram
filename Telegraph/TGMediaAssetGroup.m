#import "TGMediaAssetGroup.h"

@interface TGMediaAssetGroup ()
{
    NSString *_identifier;
    NSString *_title;
    NSArray *_latestAssets;
}
@end

@implementation TGMediaAssetGroup

- (instancetype)initWithPHFetchResult:(PHFetchResult *)fetchResult
{
    self = [super init];
    if (self != nil)
    {
        _backingFetchResult = fetchResult;
        _isCameraRoll = true;
    }
    return self;
}

- (instancetype)initWithPHAssetCollection:(PHAssetCollection *)collection fetchResult:(PHFetchResult *)fetchResult
{
    self = [super init];
    if (self != nil)
    {
        _backingAssetCollection = collection;
        _backingFetchResult = fetchResult;
        _isCameraRoll = (collection.assetCollectionType == PHAssetCollectionTypeSmartAlbum && collection.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumUserLibrary);
        
        if (_backingFetchResult == nil)
        {
            PHFetchOptions *options = [[PHFetchOptions alloc] init];
            //if (_assetType != TGMediaPickerAssetAnyType)
            //    options.predicate = [NSPredicate predicateWithFormat:@"mediaType = %i", [TGMediaAssetsLibrary _assetMediaTypeForAssetType:_assetType]];
            
            _backingFetchResult = [PHAsset fetchAssetsInAssetCollection:_backingAssetCollection options:options];
        }
    }
    return self;
}

- (instancetype)initWithALAssetsGroup:(ALAssetsGroup *)assetsGroup
{
    self = [super init];
    if (self != nil)
    {
        _backingAssetsGroup = assetsGroup;
        _isCameraRoll = ([[assetsGroup valueForProperty:ALAssetsGroupPropertyType] integerValue] == ALAssetsGroupSavedPhotos);
        
        NSMutableArray *latestAssets = [[NSMutableArray alloc] init];
        [assetsGroup enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *asset, __unused NSUInteger index, BOOL *stop)
        {
            if (asset != nil)
                [latestAssets addObject:[[TGMediaAsset alloc] initWithALAsset:asset]];
            if (latestAssets.count == 3 && stop != NULL)
                *stop = true;
        }];
        
        _latestAssets = latestAssets;
    }
    return self;
}

- (NSString *)identifier
{
    if (self.backingAssetCollection != nil)
        return self.backingAssetCollection.localIdentifier;
    else if (_backingAssetsGroup != nil)
        return [self.backingAssetsGroup valueForProperty:ALAssetsGroupPropertyPersistentID];
    
    return _identifier;
}

- (NSString *)title
{
    if (_backingAssetCollection != nil)
        return _backingAssetCollection.localizedTitle;
    if (_backingAssetsGroup != nil)
        return [_backingAssetsGroup valueForProperty:ALAssetsGroupPropertyName];
    
    return _title;
}

- (NSUInteger)assetCount
{
    if (self.backingFetchResult != nil)
        return self.backingFetchResult.count;
    else if (self.backingAssetsGroup != nil)
        return self.backingAssetsGroup.numberOfAssets;
    
    return 0;
}

- (TGMediaAssetGroupSubtype)subtype
{
    if (self.backingAssetCollection != nil)
    {
        return [TGMediaAssetGroup _assetGroupSubtypeForCollectionSubtype:self.backingAssetCollection.assetCollectionSubtype];
    }
    else if (self.backingFetchResult != nil)
    {
        if (_isCameraRoll)
            return TGMediaAssetGroupSubtypeCameraRoll;
    }
    else if (self.backingAssetsGroup != nil)
    {
        if (_isCameraRoll)
            return TGMediaAssetGroupSubtypeCameraRoll;
    }
    
    return TGMediaAssetGroupSubtypeRegular;
}

- (NSArray *)latestAssets
{
    if (_backingFetchResult != nil)
    {
        if (_latestAssets != nil)
            return _latestAssets;
        
        NSMutableArray *latestAssets = [[NSMutableArray alloc] init];
        
        NSInteger totalCount = _backingFetchResult.count;
        
        if (totalCount == 0)
            return nil;
        
        NSInteger requiredCount = MIN(3, totalCount);
        
        for (NSInteger i = 0; i < requiredCount; i++)
        {
            NSInteger index = self.isCameraRoll ? totalCount - i - 1 : i;
            PHAsset *asset = [_backingFetchResult objectAtIndex:index];
            
            TGMediaAsset *pickerAsset = [[TGMediaAsset alloc] initWithPHAsset:asset];
            
            if (pickerAsset != nil)
                [latestAssets addObject:pickerAsset];
        }
        
        _latestAssets = latestAssets;
    }
    
    return _latestAssets;
}

- (BOOL)isEqual:(id)object
{
    if (object == self)
        return YES;
    
    if (!object || ![object isKindOfClass:[self class]])
        return NO;
    
    return [self.identifier isEqual:((TGMediaAssetGroup *)object).identifier];
}

+ (TGMediaAssetGroupSubtype)_assetGroupSubtypeForCollectionSubtype:(PHAssetCollectionSubtype)subtype
{
    switch (subtype)
    {
        case PHAssetCollectionSubtypeSmartAlbumPanoramas:
            return TGMediaAssetGroupSubtypePanoramas;
            
        case PHAssetCollectionSubtypeSmartAlbumVideos:
            return TGMediaAssetGroupSubtypeVideos;
            
        case PHAssetCollectionSubtypeSmartAlbumFavorites:
            return TGMediaAssetGroupSubtypeFavorites;
            
        case PHAssetCollectionSubtypeSmartAlbumTimelapses:
            return TGMediaAssetGroupSubtypeTimelapses;
            
        case PHAssetCollectionSubtypeSmartAlbumBursts:
            return TGMediaAssetGroupSubtypeBursts;
            
        case PHAssetCollectionSubtypeSmartAlbumSlomoVideos:
            return TGMediaAssetGroupSubtypeSlomo;
            
        case PHAssetCollectionSubtypeSmartAlbumUserLibrary:
            return TGMediaAssetGroupSubtypeCameraRoll;
            
        case PHAssetCollectionSubtypeSmartAlbumScreenshots:
            return TGMediaAssetGroupSubtypeScreenshots;
            
        case PHAssetCollectionSubtypeSmartAlbumSelfPortraits:
            return TGMediaAssetGroupSubtypeSelfPortraits;
            
        case PHAssetCollectionSubtypeAlbumMyPhotoStream:
            return TGMediaAssetGroupSubtypeMyPhotoStream;
            
        default:
            return TGMediaAssetGroupSubtypeRegular;
    }
}

+ (bool)_isSmartAlbumCollectionSubtype:(PHAssetCollectionSubtype)subtype requiredForAssetType:(TGMediaAssetType)assetType
{
    switch (subtype)
    {
        case PHAssetCollectionSubtypeSmartAlbumPanoramas:
        {
            switch (assetType)
            {
                case TGMediaAssetVideoType:
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
                case TGMediaAssetPhotoType:
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
                case TGMediaAssetAnyType:
                    return true;
                    
                default:
                    return false;
            }
        }
            
        case PHAssetCollectionSubtypeSmartAlbumSlomoVideos:
        {
            switch (assetType)
            {
                case TGMediaAssetPhotoType:
                    return false;
                    
                default:
                    return true;
            }
        }
            break;
            
        case PHAssetCollectionSubtypeSmartAlbumBursts:
        {
            switch (assetType)
            {
                case TGMediaAssetVideoType:
                    return false;
                    
                default:
                    return true;
            }
        }
            break;
            
        case PHAssetCollectionSubtypeSmartAlbumScreenshots:
        {
            switch (assetType)
            {
                case TGMediaAssetVideoType:
                    return false;
                    
                default:
                    return true;
            }
        }
            
        case PHAssetCollectionSubtypeSmartAlbumSelfPortraits:
        {
            switch (assetType)
            {
                case TGMediaAssetVideoType:
                    return false;
                    
                default:
                    return true;
            }
        }
            
        default:
        {
            return false;
        }
    }
}

@end
