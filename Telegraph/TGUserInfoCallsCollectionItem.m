#import "TGUserInfoCallsCollectionItem.h"
#import "TGUserInfoCallsCollectionItemView.h"

@interface TGUserInfoCallsCollectionItem ()
{
    NSArray *_callMessages;
}
@end

@implementation TGUserInfoCallsCollectionItem

- (bool)highlightable
{
    return false;
}

- (bool)selectable
{
    return false;
}

- (void)setCallMessages:(NSArray *)callMessages
{
    _callMessages = callMessages;
}

- (Class)itemViewClass
{
    return [TGUserInfoCallsCollectionItemView class];
}

- (CGSize)itemSizeForContainerSize:(CGSize)containerSize
{
    return CGSizeMake(containerSize.width, (_callMessages.count + 1) * 26.0f);
}

- (void)bindView:(TGUserInfoCallsCollectionItemView *)view
{
    [super bindView:view];
    
    [view setCallMessages:_callMessages];
}

- (void)unbindView
{
    [super unbindView];
    
    [((TGUserInfoCallsCollectionItemView *)self.view) setCallMessages:nil];
}

@end
