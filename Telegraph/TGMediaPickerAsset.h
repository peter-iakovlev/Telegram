#import <Foundation/Foundation.h>

@class PHAsset;
@class ALAsset;

typedef enum {
    TGMediaPickerAssetAnyType,
    TGMediaPickerAssetPhotoType,
    TGMediaPickerAssetVideoType
} TGMediaPickerAssetType;

typedef enum {
    TGMediaPickerAssetSubtypeNone = 0,
    TGMediaPickerAssetSubtypePhotoPanorama = (1UL << 0),
    TGMediaPickerAssetSubtypePhotoHDR = (1UL << 1),
    TGMediaPickerAssetSubtypeVideoStreamed = (1UL << 16),
    TGMediaPickerAssetSubtypeVideoHighFrameRate = (1UL << 17),
    TGMediaPickerAssetSubtypeVideoTimelapse = (1UL << 18)
} TGMediaPickerAssetSubtype;

@interface TGMediaPickerAsset : NSObject

@property (nonatomic, readonly) NSString *persistentId;
@property (nonatomic, readonly) NSURL *url;
@property (nonatomic, readonly) CGSize dimensions;
@property (nonatomic, readonly) NSDate *date;
@property (nonatomic, readonly) bool isVideo;
@property (nonatomic, readonly) NSTimeInterval videoDuration;
@property (nonatomic, readonly) NSTimeInterval actualVideoDuration;
@property (nonatomic, readonly) bool representsBurst;

@property (nonatomic, readonly) TGMediaPickerAssetType type;
@property (nonatomic, readonly) TGMediaPickerAssetSubtype subtypes;

@property (nonatomic, readonly) PHAsset *backingAsset;
@property (nonatomic, readonly) ALAsset *backingLegacyAsset;

- (instancetype)initWithPHAsset:(PHAsset *)asset;
- (instancetype)initWithALAsset:(ALAsset *)asset;

- (NSString *)uniqueId;

@end
