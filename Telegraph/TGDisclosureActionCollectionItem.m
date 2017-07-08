#import "TGDisclosureActionCollectionItem.h"

#import "TGDisclosureActionCollectionItemView.h"

@implementation TGDisclosureActionCollectionItem

- (instancetype)initWithTitle:(NSString *)title action:(SEL)action
{
    self = [super init];
    if (self != nil)
    {
        _title = title;
        _action = action;
    }
    return self;
}

- (Class)itemViewClass
{
    return [TGDisclosureActionCollectionItemView class];
}

- (CGSize)itemSizeForContainerSize:(CGSize)containerSize
{
    return CGSizeMake(containerSize.width, 44);
}

- (void)itemSelected:(id)actionTarget
{
    if (_action != NULL && [actionTarget respondsToSelector:_action])
    {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [actionTarget performSelector:_action];
#pragma clang diagnostic pop
    }
}

- (void)bindView:(TGDisclosureActionCollectionItemView *)view
{
    [super bindView:view];
    
    [view setTitle:_title];
    [view setIcon:_icon];
    [view setBadge:_badge];
    [view setHideArrow:_hideArrow];
}

- (void)unbindView {
    [super unbindView];
}

- (void)setTitle:(NSString *)title
{
    _title = title;
    
    if (self.boundView != nil)
        [(TGDisclosureActionCollectionItemView *)self.view setTitle:title];
}

- (void)setIcon:(UIImage *)icon
{
    _icon = icon;
    
    if (self.boundView != nil)
        [(TGDisclosureActionCollectionItemView *)self.view setIcon:icon];
}

- (void)setBadge:(NSString *)badge {
    _badge = badge;
    
    if (self.boundView != nil)
        [(TGDisclosureActionCollectionItemView *)self.view setBadge:badge];
}

@end
