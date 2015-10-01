#import "TGWebSearchResult.h"

@class TGImageInfo;

@interface TGWebSearchInternalImageResult : NSObject <TGWebSearchResult>

@property (nonatomic, readonly) int64_t imageId;
@property (nonatomic, readonly) int64_t accessHash;
@property (nonatomic, strong, readonly) TGImageInfo *imageInfo;

- (instancetype)initWithImageId:(int64_t)imageId accessHash:(int64_t)accessHash imageInfo:(TGImageInfo *)imageInfo;

@end
