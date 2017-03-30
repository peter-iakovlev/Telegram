#import "TGCollectionItemView.h"

@class STPCardParams;

@interface TGCreditCardNumberCollectionItemView : TGCollectionItemView

@property (nonatomic, copy) void (^cardChanged)(STPCardParams *);
@property (nonatomic, copy) void (^nextField)();

- (void)focusInput;

@end
