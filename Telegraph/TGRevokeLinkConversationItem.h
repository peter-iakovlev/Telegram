#import "TGCollectionItem.h"

@class TGConversation;

@interface TGRevokeLinkConversationItem : TGCollectionItem

@property (nonatomic, copy) void (^revoke)();

- (instancetype)initWithConversation:(TGConversation *)conversation;

@end
