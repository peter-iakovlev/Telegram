#import "TLMetaRpc.h"

@interface TLRPCaccount_verifyEmail : TLMetaRpc

@property (nonatomic, retain) NSString *email;
@property (nonatomic, retain) NSString *code;

@end
