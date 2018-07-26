#import "TGFontSizeCollectionItem.h"
#import "TGFontSizeCollectionItemView.h"

@interface TGFontSizeCollectionItem ()
{
    void (^_internalValueChanged)(int32_t);
}
@end

@implementation TGFontSizeCollectionItem

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        self.highlightable = false;
        self.selectable = false;
        
        __weak TGFontSizeCollectionItem *weakSelf = self;
        _internalValueChanged = ^(int32_t value)
        {
            __strong TGFontSizeCollectionItem *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                strongSelf->_value = value;
                
                if (strongSelf.valueChanged != nil)
                    strongSelf.valueChanged(value);
            }
        };
    }
    return self;
}

- (void)bindView:(TGFontSizeCollectionItemView *)view
{
    view.value = _value;
    view.valueChanged = [_internalValueChanged copy];
    
    [super bindView:view];
}

- (void)unbindView
{
    ((TGFontSizeCollectionItemView *)self.boundView).valueChanged = nil;
    [super unbindView];
}

- (void)setValue:(int32_t)value
{
    _value = value;
}

- (Class)itemViewClass
{
    return [TGFontSizeCollectionItemView class];
}

- (CGSize)itemSizeForContainerSize:(CGSize)containerSize
{
    return CGSizeMake(containerSize.width, 60.0f);
}

@end
