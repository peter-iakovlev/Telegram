#import "TGCollectionItem.h"

@class TGImageMediaAttachment;

@interface TGPaymentCheckoutHeaderItem : TGCollectionItem

- (instancetype)initWithPhoto:(TGImageMediaAttachment *)photo title:(NSString *)title text:(NSString *)text label:(NSString *)label;

@end
