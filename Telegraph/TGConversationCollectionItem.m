#import "TGConversationCollectionItem.h"

#import "TGConversationCollectionItemView.h"

@implementation TGConversationCollectionItem

- (instancetype)initWithConversation:(TGConversation *)conversation {
    self = [super init];
    if (self != nil) {
        _conversation = conversation;
    }
    return self;
}

- (Class)itemViewClass
{
    return [TGConversationCollectionItemView class];
}

- (CGSize)itemSizeForContainerSize:(CGSize)containerSize
{
    return CGSizeMake(containerSize.width, 48.0f);
}

- (void)bindView:(TGCollectionItemView *)view
{
    [super bindView:view];
    
    [(TGConversationCollectionItemView *)view setConversation:_conversation];
}

- (void)unbindView
{
    [super unbindView];
}

- (void)itemSelected:(id)__unused actionTarget {
    if (_selected) {
        _selected(_conversation);
    }
}

@end
