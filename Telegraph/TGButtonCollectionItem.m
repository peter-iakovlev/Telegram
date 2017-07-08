#import "TGButtonCollectionItem.h"

#import "TGButtonCollectionItemView.h"

@implementation TGButtonCollectionItem

- (instancetype)initWithTitle:(NSString *)title action:(SEL)action
{
    self = [super init];
    if (self != nil)
    {
        _title = title;
        _titleColor = TGAccentColor();
        _alignment = NSTextAlignmentLeft;
        _enabled = true;
        
        _leftInset = 15;
        
        _action = action;
    }
    return self;
}

- (Class)itemViewClass
{
    return [TGButtonCollectionItemView class];
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

- (void)bindView:(TGButtonCollectionItemView *)view
{
    [super bindView:view];
    
    [view setTitle:_title];
    [view setTitleColor:_titleColor];
    [view setTitleAlignment:_alignment];
    [view setEnabled:_enabled];
    [view setIcon:_icon];
    [view setIconOffset:_iconOffset];
    
    view.leftInset = _leftInset;
    [view setAdditionalSeparatorInset:_additionalSeparatorInset];
}

- (void)setIconOffset:(CGPoint)iconOffset
{
    _iconOffset = iconOffset;
    
    if (self.view != nil)
        [(TGButtonCollectionItemView *)self.view setIconOffset:iconOffset];
}

- (void)setTitle:(NSString *)title
{
    _title = title;
    
    if (self.view != nil)
        [(TGButtonCollectionItemView *)self.view setTitle:title];
}

- (void)setEnabled:(bool)enabled
{
    if (_enabled != enabled)
    {
        _enabled = enabled;
        self.selectable = enabled;
        
        [(TGButtonCollectionItemView *)[self boundView] setEnabled:_enabled];
    }
}

- (void)setLeftInset:(CGFloat)leftInset
{
    _leftInset = leftInset;
    
    [(TGButtonCollectionItemView *)[self boundView] setLeftInset:_leftInset];
}

- (void)setAdditionalSeparatorInset:(CGFloat)additionalSeparatorInset {
    _additionalSeparatorInset = additionalSeparatorInset;
    
    [(TGButtonCollectionItemView *)[self boundView] setAdditionalSeparatorInset:_additionalSeparatorInset];
}

@end
