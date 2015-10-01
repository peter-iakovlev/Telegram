#import "TGBridgeMediaAttachment.h"
#import "TGBridgeImageInfo.h"

@interface TGBridgeVideoMediaAttachment : TGBridgeMediaAttachment

@property (nonatomic, assign) int64_t videoId;

@property (nonatomic, strong) TGBridgeImageInfo *thumbnailImageInfo;

@property (nonatomic, assign) int32_t duration;
@property (nonatomic, assign) CGSize dimensions;

@property (nonatomic, strong) NSString *caption;

@end
