#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLaccount_PasswordSettings;
@class TLInputCheckPasswordSRP;

@interface TLRPCaccount_getPasswordSettings : TLMetaRpc

@property (nonatomic, retain) TLInputCheckPasswordSRP *password;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCaccount_getPasswordSettings$account_getPasswordSettings : TLRPCaccount_getPasswordSettings


@end

