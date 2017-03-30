#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLInvoice;
@class TLDataJSON;
@class TLPaymentRequestedInfo;
@class TLPaymentSavedCredentials;

@interface TLpayments_PaymentForm : NSObject <TLObject>

@property (nonatomic) int32_t flags;
@property (nonatomic) int32_t bot_id;
@property (nonatomic, retain) TLInvoice *invoice;
@property (nonatomic) int32_t provider_id;
@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) NSString *native_provider;
@property (nonatomic, retain) TLDataJSON *native_params;
@property (nonatomic, retain) TLPaymentRequestedInfo *saved_info;
@property (nonatomic, retain) TLPaymentSavedCredentials *saved_credentials;
@property (nonatomic, retain) NSArray *users;

@end

@interface TLpayments_PaymentForm$payments_paymentFormMeta : TLpayments_PaymentForm


@end

