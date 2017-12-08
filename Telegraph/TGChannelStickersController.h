#import "TGCollectionMenuController.h"

@class TGConversation;

@interface TGChannelStickersController : TGCollectionMenuController

- (instancetype)initWithConversation:(TGConversation *)conversation;

@end
