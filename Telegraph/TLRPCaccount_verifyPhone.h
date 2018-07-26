#import "TLMetaRpc.h"

@interface TLRPCaccount_verifyPhone : TLMetaRpc

@property (nonatomic, retain) NSString *phone_number;
@property (nonatomic, retain) NSString *phone_code_hash;
@property (nonatomic, retain) NSString *phone_code;

@end
