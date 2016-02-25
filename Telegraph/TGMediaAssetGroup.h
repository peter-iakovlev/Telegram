#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>

#import "TGMediaAsset.h"

typedef enum
{
    TGMediaAssetGroupSubtypeCameraRoll,
    TGMediaAssetGroupSubtypeMyPhotoStream,
    TGMediaAssetGroupSubtypeFavorites,
    TGMediaAssetGroupSubtypePanoramas,
    TGMediaAssetGroupSubtypeSelfPortraits,
    TGMediaAssetGroupSubtypeVideos,
    TGMediaAssetGroupSubtypeSlomo,
    TGMediaAssetGroupSubtypeTimelapses,
    TGMediaAssetGroupSubtypeBursts,
    TGMediaAssetGroupSubtypeScreenshots,
    TGMediaAssetGroupSubtypeRegular
} TGMediaAssetGroupSubtype;

@interface TGMediaAssetGroup : NSObject

@property (nonatomic, readonly) NSString *identifier;
@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) NSUInteger assetCount;
@property (nonatomic, readonly) TGMediaAssetGroupSubtype subtype;
@property (nonatomic, readonly) bool isCameraRoll;
@property (nonatomic, readonly) bool isPhotoStream;
@property (nonatomic, readonly) bool isReversed;

@property (nonatomic, readonly) PHFetchResult *backingFetchResult;
@property (nonatomic, readonly) PHAssetCollection *backingAssetCollection;
@property (nonatomic, readonly) ALAssetsGroup *backingAssetsGroup;

- (instancetype)initWithPHFetchResult:(PHFetchResult *)fetchResult;
- (instancetype)initWithPHAssetCollection:(PHAssetCollection *)collection fetchResult:(PHFetchResult *)fetchResult;
- (instancetype)initWithALAssetsGroup:(ALAssetsGroup *)assetsGroup;

- (NSArray *)latestAssets;

+ (bool)_isSmartAlbumCollectionSubtype:(PHAssetCollectionSubtype)subtype requiredForAssetType:(TGMediaAssetType)assetType;

@end
