#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLInvoice;
@class TLPaymentRequestedInfo;
@class TLShippingOption;

@interface TLpayments_PaymentReceipt : NSObject <TLObject>

@property (nonatomic) int32_t flags;
@property (nonatomic) int32_t date;
@property (nonatomic) int32_t bot_id;
@property (nonatomic, retain) TLInvoice *invoice;
@property (nonatomic) int32_t provider_id;
@property (nonatomic, retain) TLPaymentRequestedInfo *info;
@property (nonatomic, retain) TLShippingOption *shipping;
@property (nonatomic, retain) NSString *currency;
@property (nonatomic) int64_t total_amount;
@property (nonatomic, retain) NSString *credentials_title;
@property (nonatomic, retain) NSArray *users;

@end

@interface TLpayments_PaymentReceipt$payments_paymentReceiptMeta : TLpayments_PaymentReceipt


@end

