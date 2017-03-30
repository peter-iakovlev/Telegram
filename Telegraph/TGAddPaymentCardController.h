#import "TGCollectionMenuController.h"

@class TGPaymentMethodStripeToken;

@interface TGAddPaymentCardController : TGCollectionMenuController

@property (nonatomic, copy) void (^completion)(TGPaymentMethodStripeToken *token);

- (instancetype)initWithCanSave:(bool)canSave allowSaving:(bool)allowSaving requestCountry:(bool)requestCountry requestPostcode:(bool)requestPostcode requestName:(bool)requestName publishableKey:(NSString *)publishableKey;

@end
