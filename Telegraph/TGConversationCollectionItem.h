#import "TGCollectionItem.h"

@class TGConversation;

@interface TGConversationCollectionItem : TGCollectionItem

@property (nonatomic, strong, readonly) TGConversation *conversation;
@property (nonatomic, copy) void (^selected)(TGConversation *);

- (instancetype)initWithConversation:(TGConversation *)conversation;

@end
