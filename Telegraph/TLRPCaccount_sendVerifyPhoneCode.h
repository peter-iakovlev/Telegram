#import "TLMetaRpc.h"

@interface TLRPCaccount_sendVerifyPhoneCode : TLMetaRpc

@property (nonatomic) int32_t flags;
@property (nonatomic, retain) NSString *phone_number;
@property (nonatomic) bool current_number;

@end
