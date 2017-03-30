#import "TLMetaRpc.h"

@class TLInputPaymentCredentials;

@interface TLPayments_sendPaymentForm : TLMetaRpc

@property (nonatomic) int32_t flags;
@property (nonatomic) int32_t msg_id;
@property (nonatomic, strong) NSString *requested_info_id;
@property (nonatomic, strong) NSString *shipping_option_id;
@property (nonatomic, strong) TLInputPaymentCredentials *credentials;

@end
