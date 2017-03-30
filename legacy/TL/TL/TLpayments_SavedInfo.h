#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLPaymentRequestedInfo;

@interface TLpayments_SavedInfo : NSObject <TLObject>

@property (nonatomic) int32_t flags;
@property (nonatomic, retain) TLPaymentRequestedInfo *saved_info;

@end

@interface TLpayments_SavedInfo$payments_savedInfoMeta : TLpayments_SavedInfo


@end

