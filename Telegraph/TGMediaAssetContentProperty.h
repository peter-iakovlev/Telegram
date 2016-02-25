#import "PSCoding.h"

@interface TGMediaAssetContentProperty : NSObject <PSCoding>

@property (nonatomic, readonly) NSString *assetIdentifier;
@property (nonatomic, readonly) bool isVideo;
@property (nonatomic, readonly) NSDictionary *editAdjustments;
@property (nonatomic, readonly) bool isCloud;
@property (nonatomic, readonly) bool useMediaCache;
@property (nonatomic, readonly) bool liveUpload;
@property (nonatomic, readonly) bool passthrough;

- (instancetype)initWithAssetIdentifier:(NSString *)assetIdentifier isVideo:(bool)isVideo isCloud:(bool)isCloud useMediaCache:(bool)useMediaCache;
- (instancetype)initWithAssetIdentifier:(NSString *)assetIdentifier isVideo:(bool)isVideo editAdjustments:(NSDictionary *)editAdjustments isCloud:(bool)isCloud useMediaCache:(bool)useMediaCache liveUpload:(bool)liveUpload passthrough:(bool)passthough;

@end

