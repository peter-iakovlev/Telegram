#import "TGBridgeChat.h"

@class TGConversation;

@interface TGBridgeChat (TGConversation)

+ (TGBridgeChat *)chatWithTGConversation:(TGConversation *)conversation;

@end
