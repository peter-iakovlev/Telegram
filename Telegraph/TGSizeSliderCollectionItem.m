#import "TGSizeSliderCollectionItem.h"
#import "TGSizeSliderCollectionItemView.h"

@interface TGSizeSliderCollectionItem ()
{
    void (^_valueChanged)(int32_t);
}
@end

@implementation TGSizeSliderCollectionItem

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        self.highlightable = false;
        self.selectable = false;
        
        __weak TGSizeSliderCollectionItem *weakSelf = self;
        _valueChanged = ^(int32_t value)
        {
            __strong TGSizeSliderCollectionItem *strongSelf = weakSelf;
            if (strongSelf != nil)
                strongSelf->_value = value;
        };
    }
    return self;
}

- (void)bindView:(TGSizeSliderCollectionItemView *)view
{
    view.value = _value;
    view.valueChanged = [_valueChanged copy];
    
    [super bindView:view];
}

- (void)unbindView
{
    ((TGSizeSliderCollectionItemView *)self.boundView).valueChanged = nil;
    [super unbindView];
}

- (void)setValue:(int32_t)value
{
    _value = value;
}

- (Class)itemViewClass
{
    return [TGSizeSliderCollectionItemView class];
}

- (CGSize)itemSizeForContainerSize:(CGSize)containerSize
{
    return CGSizeMake(containerSize.width, 87.0f);
}

@end
