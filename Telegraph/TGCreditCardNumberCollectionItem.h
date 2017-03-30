#import "TGCollectionItem.h"

@class STPCardParams;

@interface TGCreditCardNumberCollectionItem : TGCollectionItem

@property (nonatomic, copy) void (^cardChanged)(STPCardParams *);
@property (nonatomic, copy) void (^nextField)();

- (void)becomeFirstResponder;

@end
