#import <Foundation/Foundation.h>

@interface TGInvoicePrice : NSObject

@property (nonatomic, strong, readonly) NSString *label;
@property (nonatomic, readonly) int64_t amount;

- (instancetype)initWithLabel:(NSString *)label amount:(int64_t)amount;

@end

@interface TGInvoice : NSObject

@property (nonatomic, readonly) bool isTest;
@property (nonatomic, readonly) bool nameRequested;
@property (nonatomic, readonly) bool phoneRequested;
@property (nonatomic, readonly) bool emailRequested;
@property (nonatomic, readonly) bool shippingAddressRequested;
@property (nonatomic, readonly) bool flexible;
@property (nonatomic, strong, readonly) NSString *currency;
@property (nonatomic, strong, readonly) NSArray<TGInvoicePrice *> *prices;

- (instancetype)initWithIsTest:(bool)isTest nameRequested:(bool)nameRequested phoneRequested:(bool)phoneRequested emailRequested:(bool)emailRequested shippingAddressRequested:(bool)shippingAddressRequested flexible:(bool)flexible currency:(NSString *)currency prices:(NSArray<TGInvoicePrice *> *)prices;

- (bool)requiresShippingInfo;

@end

@interface TGPostAddress : NSObject

@property (nonatomic, strong, readonly) NSString *streetLine1;
@property (nonatomic, strong, readonly) NSString *streetLine2;
@property (nonatomic, strong, readonly) NSString *city;
@property (nonatomic, strong, readonly) NSString *state;
@property (nonatomic, strong, readonly) NSString *countryIso2;
@property (nonatomic, strong, readonly) NSString *postCode;

- (instancetype)initWithStreetLine1:(NSString *)streetLine1 streetLine2:(NSString *)streetLine2 city:(NSString *)city state:(NSString *)state countryIso2:(NSString *)countryIso2 postCode:(NSString *)postCode;
- (NSString *)descriptionWithSeparator:(NSString *)seaparator;

@end

@interface TGPaymentRequestedInfo : NSObject

@property (nonatomic, strong, readonly) NSString *name;
@property (nonatomic, strong, readonly) NSString *phone;
@property (nonatomic, strong, readonly) NSString *email;
@property (nonatomic, strong, readonly) TGPostAddress *shippingAddress;

- (instancetype)initWithName:(NSString *)name phone:(NSString *)phone email:(NSString *)email shippingAddress:(TGPostAddress *)shippingAddress;

- (bool)satisfiesInvoice:(TGInvoice *)invoice;

@end

@interface TGPaymentSavedCredentialsCard : NSObject

@property (nonatomic, strong, readonly) NSString *cardId;
@property (nonatomic, strong, readonly) NSString *title;

- (instancetype)initWithCardId:(NSString *)cardId title:(NSString *)title;

@end

@interface TGPaymentCredentialsStripeToken : NSObject

@property (nonatomic, strong, readonly) NSString *tokenId;
@property (nonatomic, strong, readonly) NSString *title;
@property (nonatomic, readonly) bool saveCredentials;

- (instancetype)initWithTokenId:(NSString *)tokenId title:(NSString *)title saveCredentials:(bool)saveCredentials;

@end

@interface TGPaymentCredentialsWebToken : NSObject

@property (nonatomic, strong, readonly) NSString *data;
@property (nonatomic, readonly) bool saveCredentials;

- (instancetype)initWithData:(NSString *)data saveCredentials:(bool)saveCredentials;

@end

@interface TGPaymentCredentialsSaved : NSObject

@property (nonatomic, strong, readonly) NSString *cardId;
@property (nonatomic, readonly) NSData *tmpPassword;

- (instancetype)initWithCardId:(NSString *)cardId tmpPassword:(NSData *)tmpPassword;

@end

@interface TGPaymentForm : NSObject

@property (nonatomic, readonly) bool canSaveCredentials;
@property (nonatomic, readonly) bool passwordMissing;
@property (nonatomic, readonly) int32_t botId;
@property (nonatomic, strong, readonly) NSString *url;
@property (nonatomic, strong, readonly) TGInvoice *invoice;
@property (nonatomic, readonly) int32_t providerId;
@property (nonatomic, strong, readonly) NSString *nativeProvider;
@property (nonatomic, strong, readonly) NSString *nativeParams;
@property (nonatomic, strong, readonly) TGPaymentRequestedInfo *savedInfo;
@property (nonatomic, strong, readonly) TGPaymentSavedCredentialsCard *savedCredentials;

- (instancetype)initWithCanSaveCredentials:(bool)canSaveCredentials passwordMissing:(bool)passwordMissing botId:(int32_t)botId url:(NSString *)url invoice:(TGInvoice *)invoice providerId:(int32_t)providerId nativeProvider:(NSString *)nativeProvider nativeParams:(NSString *)nativeParams savedInfo:(TGPaymentRequestedInfo *)savedInfo savedCredentials:(TGPaymentSavedCredentialsCard *)savedCredentials;

@end

////payments.validatedRequestedInfo flags:# id:flags.0?string url:string webview_only:flags.2?true shipping_options:flags.1?Vector<ShippingOption> = payments.ValidatedRequestedInfo;

//shippingOption id:string title:string prices:Vector<LabeledPrice> = ShippingOption;

@interface TGShippingOption : NSObject

@property (nonatomic, strong, readonly) NSString *optionId;
@property (nonatomic, strong, readonly) NSString *title;
@property (nonatomic, strong, readonly) NSArray<TGInvoicePrice *> *prices;

- (instancetype)initWithOptionId:(NSString *)optionId title:(NSString *)title prices:(NSArray<TGInvoicePrice *> *)prices;

@end

@interface TGValidatedRequestedInfo : NSObject

@property (nonatomic, strong, readonly) NSString *infoId;
@property (nonatomic, strong, readonly) NSArray<TGShippingOption *> *shippingOptions;

- (instancetype)initWithInfoId:(NSString *)infoId shippingOptions:(NSArray<TGShippingOption *> *)shippingOptions;

@end

@interface TGPaymentReceipt : NSObject

@property (nonatomic, readonly) int32_t date;
@property (nonatomic, readonly) int32_t botId;
@property (nonatomic, strong, readonly) TGInvoice *invoice;
@property (nonatomic, readonly) int32_t providerId;
@property (nonatomic, strong, readonly) TGPaymentRequestedInfo *info;
@property (nonatomic, strong, readonly) TGShippingOption *shippingOption;
@property (nonatomic, strong, readonly) NSString *currency;
@property (nonatomic, readonly) int64_t totalAmount;
@property (nonatomic, strong, readonly) NSString *credentialsTitle;

- (instancetype)initWithDate:(int32_t)date botId:(int32_t)botId invoice:(TGInvoice *)invoice providerId:(int32_t)providerId info:(TGPaymentRequestedInfo *)info shippingOption:(TGShippingOption *)shippingOption currency:(NSString *)currency totalAmount:(int64_t)totalAmount credentialsTitle:(NSString *)credentialsTitle;

@end
