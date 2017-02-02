#import "TLMetaRpc.h"

@interface TLRPCaccount_sendChangePhoneCode : TLMetaRpc

@property (nonatomic) int32_t flags;
@property (nonatomic, strong) NSString *phone_number;
@property (nonatomic) bool current_number;

@end
