#import "TGBridgeMessage.h"

@class TGMessage;
@class TGConversation;

@interface TGBridgeMessage (TGMessage)

+ (TGBridgeMessage *)messageWithTGMessage:(TGMessage *)message conversation:(TGConversation *)conversation;
+ (TGBridgeMessage *)channelMessageWithTGMessage:(TGMessage *)message conversation:(TGConversation *)conversation;;

@end
