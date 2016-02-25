#import "TGBridgeMediaAttachment.h"

@interface TGBridgeForwardedMessageMediaAttachment : TGBridgeMediaAttachment

@property (nonatomic, assign) int64_t peerId;
@property (nonatomic, assign) uint32_t mid;
@property (nonatomic, assign) uint32_t date;

@end
