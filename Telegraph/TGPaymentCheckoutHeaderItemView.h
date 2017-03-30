#import "TGCollectionItemView.h"

@class TGImageMediaAttachment;

@interface TGPaymentCheckoutHeaderItemView : TGCollectionItemView

- (void)setPhoto:(TGImageMediaAttachment *)photo title:(NSString *)title text:(NSString *)text label:(NSString *)label;

@end
