#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLPaymentRequestedInfo;
@class TLpayments_ValidatedRequestedInfo;

@interface TLRPCpayments_validateRequestedInfo : TLMetaRpc

@property (nonatomic) int32_t flags;
@property (nonatomic) int32_t msg_id;
@property (nonatomic, retain) TLPaymentRequestedInfo *info;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCpayments_validateRequestedInfo$payments_validateRequestedInfo : TLRPCpayments_validateRequestedInfo


@end

