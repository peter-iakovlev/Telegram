#import "TLMetaRpc.h"

@interface TLRPCauth_sendCode : TLMetaRpc

@property (nonatomic) int32_t flags;
@property (nonatomic, strong) NSString *phone_number;
@property (nonatomic) bool current_number;
@property (nonatomic) int32_t api_id;
@property (nonatomic, strong) NSString *api_hash;
@property (nonatomic, strong) NSString *lang_code;

@end
