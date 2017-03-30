#import "TGPaymentCheckoutHeaderItem.h"

#import "TGPaymentCheckoutHeaderItemView.h"

@interface TGPaymentCheckoutHeaderItem () {
    TGImageMediaAttachment *_photo;
    NSString *_title;
    NSString *_text;
    NSString *_label;
}

@end

@implementation TGPaymentCheckoutHeaderItem

- (instancetype)initWithPhoto:(TGImageMediaAttachment *)photo title:(NSString *)title text:(NSString *)text label:(NSString *)label {
    self = [super init];
    if (self != nil) {
        _photo = photo;
        _title = title;
        _text = text;
        _label = label;
        
        self.selectable = false;
        self.highlightable = false;
        self.transparent = true;
    }
    return self;
}

- (Class)itemViewClass
{
    return [TGPaymentCheckoutHeaderItemView class];
}

- (CGSize)itemSizeForContainerSize:(CGSize)containerSize
{
    return CGSizeMake(containerSize.width, 163.0);
}

- (void)bindView:(TGPaymentCheckoutHeaderItemView *)view
{
    [super bindView:view];
    
    [view setPhoto:_photo title:_title text:_text label:_label];
}

@end
