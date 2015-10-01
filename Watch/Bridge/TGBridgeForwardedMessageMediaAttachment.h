#import "TGBridgeMediaAttachment.h"

@interface TGBridgeForwardedMessageMediaAttachment : TGBridgeMediaAttachment

@property (nonatomic, assign) uint32_t uid;
@property (nonatomic, assign) uint32_t mid;
@property (nonatomic, assign) uint32_t date;

@end
