#import "TGPaymentCheckoutPriceItem.h"

#import "TGPaymentCheckoutPriceItemView.h"

@interface TGPaymentCheckoutPriceItem () {
    NSString *_title;
    NSString *_value;
    bool _bold;
}

@end

@implementation TGPaymentCheckoutPriceItem

- (instancetype)initWithTitle:(NSString *)title value:(NSString *)value bold:(bool)bold {
    self = [super init];
    if (self != nil) {
        _title = title;
        _value = value;
        _bold = bold;
        
        self.selectable = false;
        self.highlightable = false;
        self.transparent = true;
    }
    return self;
}

- (Class)itemViewClass
{
    return [TGPaymentCheckoutPriceItemView class];
}

- (CGSize)itemSizeForContainerSize:(CGSize)containerSize
{
    return CGSizeMake(containerSize.width, 34.0);
}

- (void)bindView:(TGPaymentCheckoutPriceItemView *)view
{
    [super bindView:view];
    
    [view setTitle:_title value:_value bold:_bold];
}


@end
