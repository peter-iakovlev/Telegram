#import "TGBridgeMessage.h"

@class TGMessage;

@interface TGBridgeMessage (TGMessage)

+ (TGBridgeMessage *)messageWithTGMessage:(TGMessage *)message;
+ (TGBridgeMessage *)channelMessageWithTGMessage:(TGMessage *)message;

@end
