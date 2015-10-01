#import "TGMediaPickerAssetsGroup.h"

#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface TGMediaPickerAssetsGroup ()
{
    NSArray *_latestAssets;
    
    NSString *_persistentId;
    NSString *_title;
}
@end

@implementation TGMediaPickerAssetsGroup

- (instancetype)initWithPHAssetCollection:(PHAssetCollection *)assetCollection fetchResult:(PHFetchResult *)fetchResult latestAssets:(NSArray *)latestAssets
{
    self = [super init];
    if (self != nil)
    {
        _backingAssetCollection = assetCollection;
        _backingFetchResult = fetchResult;
        _latestAssets = latestAssets;
        if (assetCollection.assetCollectionType == PHAssetCollectionTypeSmartAlbum &&
            assetCollection.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumUserLibrary)
        {
            _isCameraRoll = true;
        }
    }
    return self;
}

- (instancetype)initWithPHFetchResult:(PHFetchResult *)fetchResult latestAssets:(NSArray *)latestAssets
{
    self = [super init];
    if (self != nil)
    {
        _backingFetchResult = fetchResult;
        _title = @"Camera Roll";
        _isCameraRoll = true;
        _latestAssets = latestAssets;
        _persistentId = @"camera_roll";
    }
    return self;
}

- (instancetype)initWithALAssetsGroup:(ALAssetsGroup *)assetsGroup latestAssets:(NSArray *)latestAssets
{
    self = [super init];
    if (self != nil)
    {
        _backingAssetsGroup = assetsGroup;
        _isCameraRoll = ([[assetsGroup valueForProperty:ALAssetsGroupPropertyType] integerValue] == ALAssetsGroupSavedPhotos);
        _latestAssets = latestAssets;
    }
    return self;
}

- (NSArray *)latestAssets
{
    return _latestAssets;
}

- (NSString *)persistentId
{
    if (self.backingAssetCollection != nil)
        return self.backingAssetCollection.localIdentifier;
    else if (_backingAssetsGroup != nil)
        return [self.backingAssetsGroup valueForProperty:ALAssetsGroupPropertyPersistentID];
    
    return _persistentId;
}

- (NSString *)title
{
    if (self.backingAssetCollection != nil)
        return self.backingAssetCollection.localizedTitle;
    else if (self.backingAssetsGroup != nil)
        return [self.backingAssetsGroup valueForProperty:ALAssetsGroupPropertyName];
        
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

- (TGMediaPickerAssetGroupSubtype)subtype
{
    if (self.backingAssetCollection != nil)
    {
        return [TGMediaPickerAssetsGroup _assetGroupSubtypeForCollectionSubtype:self.backingAssetCollection.assetCollectionSubtype];
    }
    else if (self.backingFetchResult != nil)
    {
        if (_isCameraRoll)
            return TGMediaPickerAssetsGroupSubtypeCameraRoll;
    }
    else if (self.backingAssetsGroup != nil)
    {
        if (_isCameraRoll)
            return TGMediaPickerAssetsGroupSubtypeCameraRoll;
    }
    
    return TGMediaPickerAssetsGroupSubtypeRegular;
}

+ (TGMediaPickerAssetGroupSubtype)_assetGroupSubtypeForCollectionSubtype:(PHAssetCollectionSubtype)subtype
{
    switch (subtype)
    {
        case PHAssetCollectionSubtypeSmartAlbumPanoramas:
            return TGMediaPickerAssetsGroupSubtypePanoramas;
            
        case PHAssetCollectionSubtypeSmartAlbumVideos:
            return TGMediaPickerAssetsGroupSubtypeVideos;
            
        case PHAssetCollectionSubtypeSmartAlbumFavorites:
            return TGMediaPickerAssetsGroupSubtypeFavorites;
            
        case PHAssetCollectionSubtypeSmartAlbumTimelapses:
            return TGMediaPickerAssetsGroupSubtypeTimelapses;
            
        case PHAssetCollectionSubtypeSmartAlbumBursts:
            return TGMediaPickerAssetsGroupSubtypeBursts;
            
        case PHAssetCollectionSubtypeSmartAlbumSlomoVideos:
            return TGMediaPickerAssetsGroupSubtypeSlomo;
            
        case PHAssetCollectionSubtypeSmartAlbumUserLibrary:
            return TGMediaPickerAssetsGroupSubtypeCameraRoll;
            
        default:
            return TGMediaPickerAssetsGroupSubtypeRegular;
    }
}

@end
