#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLPostAddress;

@interface TLPaymentRequestedInfo : NSObject <TLObject>

@property (nonatomic) int32_t flags;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *phone;
@property (nonatomic, retain) NSString *email;
@property (nonatomic, retain) TLPostAddress *shipping_address;

@end

@interface TLPaymentRequestedInfo$paymentRequestedInfoMeta : TLPaymentRequestedInfo


@end

