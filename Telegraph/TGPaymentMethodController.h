#import "TGCollectionMenuController.h"

@class TGPaymentSavedCredentialsCard;
@class TGPaymentCredentialsStripeToken;

@protocol TGPaymentMethod <NSObject>

- (NSString *)title;

@end

@interface TGPaymentMethodSavedCredentialsCard : NSObject<TGPaymentMethod>

@property (nonatomic, strong, readonly) TGPaymentSavedCredentialsCard *card;

- (instancetype)initWithCard:(TGPaymentSavedCredentialsCard *)card;

@end

@interface TGPaymentMethodStripeToken : NSObject<TGPaymentMethod>

@property (nonatomic, strong, readonly) TGPaymentCredentialsStripeToken *token;

- (instancetype)initWithToken:(TGPaymentCredentialsStripeToken *)token;

@end

@interface TGPaymentMethodApplePay : NSObject<TGPaymentMethod>

@end

@interface TGPaymentMethodWebToken : NSObject<TGPaymentMethod>

@property (nonatomic, strong, readonly) NSString *jsonData;
@property (nonatomic, strong, readonly) NSString *title;
@property (nonatomic, readonly) bool saveCredentials;

- (instancetype)initWithJsonData:(NSString *)jsonData title:(NSString *)title saveCredentials:(bool)saveCredentials;

@end

@interface TGPaymentMethods : NSObject

@property (nonatomic, strong, readonly) NSArray<id<TGPaymentMethod> > *methods;
@property (nonatomic, readonly) NSUInteger selectedIndex;

- (instancetype)initWithMethods:(NSArray<id<TGPaymentMethod> > *)methods selectedIndex:(NSUInteger)selectedIndex;

@end

@interface TGPaymentMethodController : TGCollectionMenuController

@property (nonatomic, copy) void (^completed)(TGPaymentMethods *);

- (instancetype)initWithPaymentMethods:(TGPaymentMethods *)paymentMethods useWebviewUrl:(NSString *)useWebviewUrl botName:(NSString *)botName canSave:(bool)canSave allowSaving:(bool)allowSaving nativeParams:(NSString *)nativeParams;

+ (bool)supportsApplePay;
@end
