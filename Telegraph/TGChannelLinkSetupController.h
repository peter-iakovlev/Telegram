#import "TGCollectionMenuController.h"

@class TGConversation;

@interface TGChannelLinkSetupController : TGCollectionMenuController

- (instancetype)initWithConversation:(TGConversation *)conversation;
- (instancetype)initWithBlock:(void (^)(NSString *username))block;

@end
