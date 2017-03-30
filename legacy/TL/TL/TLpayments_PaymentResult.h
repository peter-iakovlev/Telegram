#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLUpdates;

@interface TLpayments_PaymentResult : NSObject <TLObject>


@end

@interface TLpayments_PaymentResult$payments_paymentResult : TLpayments_PaymentResult

@property (nonatomic, retain) TLUpdates *updates;

@end

@interface TLpayments_PaymentResult$payments_paymentVerficationNeeded : TLpayments_PaymentResult

@property (nonatomic, retain) NSString *url;

@end

