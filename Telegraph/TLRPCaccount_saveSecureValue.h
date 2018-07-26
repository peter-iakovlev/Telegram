#import "TLMetaRpc.h"

@class TLInputSecureValue;

@interface TLRPCaccount_saveSecureValue : TLMetaRpc

@property (nonatomic, retain) TLInputSecureValue *value;
@property (nonatomic) int64_t secure_secret_id;

@end
