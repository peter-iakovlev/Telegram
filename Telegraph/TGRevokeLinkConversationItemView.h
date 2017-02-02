#import "TGEditableCollectionItemView.h"

@class TGConversation;

@interface TGRevokeLinkConversationItemView : TGEditableCollectionItemView

@property (nonatomic, copy) void (^revoke)();

- (void)setConversation:(TGConversation *)conversation;

@end
