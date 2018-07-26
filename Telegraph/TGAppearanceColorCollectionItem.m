#import "TGAppearanceColorCollectionItem.h"
#import "TGAppearanceColorCollectionItemView.h"

@implementation TGAppearanceColorCollectionItem

- (void)bindView:(TGAppearanceColorCollectionItemView *)view
{
    [super bindView:view];
    
    view.color = _color;
}

- (void)setColor:(UIColor *)color
{
    _color = color;
    
    ((TGAppearanceColorCollectionItemView *)self.boundView).color = _color;
}

- (Class)itemViewClass
{
    return [TGAppearanceColorCollectionItemView class];
}

@end
