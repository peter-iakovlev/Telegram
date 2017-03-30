#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLpayments_PaymentReceipt;

@interface TLRPCpayments_getPaymentReceipt : TLMetaRpc

@property (nonatomic) int32_t msg_id;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCpayments_getPaymentReceipt$payments_getPaymentReceipt : TLRPCpayments_getPaymentReceipt


@end

