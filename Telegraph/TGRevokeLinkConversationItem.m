#import "TGRevokeLinkConversationItem.h"

#import "TGRevokeLinkConversationItemView.h"

@interface TGRevokeLinkConversationItem () {
    TGConversation *_conversation;
}

@end

@implementation TGRevokeLinkConversationItem

- (instancetype)initWithConversation:(TGConversation *)conversation {
    self = [super init];
    if (self != nil) {
        _conversation = conversation;
    }
    return self;
}

- (Class)itemViewClass {
    return [TGRevokeLinkConversationItemView class];
}

- (void)bindView:(TGRevokeLinkConversationItemView *)view {
    [super bindView:view];
    
    [view setConversation:_conversation];
    __weak TGRevokeLinkConversationItem *weakSelf = self;
    view.revoke = ^{
        __strong TGRevokeLinkConversationItem *strongSelf = weakSelf;
        if (strongSelf != nil) {
            if (strongSelf->_revoke) {
                strongSelf->_revoke();
            }
        }
    };
}

- (void)unbindView {
    ((TGRevokeLinkConversationItemView *)[self boundView]).revoke = nil;
    [super unbindView];
}

- (CGSize)itemSizeForContainerSize:(CGSize)containerSize {
    return CGSizeMake(containerSize.width, 50.0f);
}

@end
