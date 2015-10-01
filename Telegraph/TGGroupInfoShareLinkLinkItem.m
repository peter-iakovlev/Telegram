#import "TGGroupInfoShareLinkLinkItem.h"

#import "TGGroupInfoShareLinkLinkItemView.h"

@implementation TGGroupInfoShareLinkLinkItem

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        self.selectable = false;
    }
    return self;
}

- (Class)itemViewClass
{
    return [TGGroupInfoShareLinkLinkItemView class];
}

- (CGSize)itemSizeForContainerSize:(CGSize)containerSize
{
    return [TGGroupInfoShareLinkLinkItemView itemSizeForText:_text maxWidth:containerSize.width];
}

- (void)bindView:(TGGroupInfoShareLinkLinkItemView *)view
{
    [super bindView:view];
    
    [view setText:_text];
}

- (void)setText:(NSString *)text
{
    _text = text;
    
    [(TGGroupInfoShareLinkLinkItemView *)self.boundView setText:_text];
}

@end
