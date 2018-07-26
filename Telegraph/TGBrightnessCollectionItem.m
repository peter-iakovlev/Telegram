#import "TGBrightnessCollectionItem.h"
#import "TGBrightnessCollectionItemView.h"

@interface TGBrightnessCollectionItem ()
{
    void (^_internalValueChanged)(CGFloat);
}
@end

@implementation TGBrightnessCollectionItem

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        self.highlightable = false;
        self.selectable = false;
        
        __weak TGBrightnessCollectionItem *weakSelf = self;
        _internalValueChanged = ^(CGFloat value)
        {
            __strong TGBrightnessCollectionItem *strongSelf = weakSelf;
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

- (void)bindView:(TGBrightnessCollectionItemView *)view
{
    view.value = _value;
    view.valueChanged = [_internalValueChanged copy];
    view.interactionEnded = [_interactionEnded copy];
    [view setMarkerValue:_markerValue];
    
    [super bindView:view];
}

- (void)unbindView
{
    ((TGBrightnessCollectionItemView *)self.boundView).valueChanged = nil;
    ((TGBrightnessCollectionItemView *)self.boundView).interactionEnded = nil;
    [super unbindView];
}

- (void)setValue:(CGFloat)value
{
    _value = value;
}

- (void)setMarkerValue:(CGFloat)markerValue
{
    _markerValue = markerValue;
    [(TGBrightnessCollectionItemView *)self.boundView setMarkerValue:markerValue];
}

- (Class)itemViewClass
{
    return [TGBrightnessCollectionItemView class];
}

- (CGSize)itemSizeForContainerSize:(CGSize)containerSize
{
    return CGSizeMake(containerSize.width, 60.0f);
}

@end
