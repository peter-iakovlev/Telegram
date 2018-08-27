#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLaccount_PasswordInputSettings;
@class TLInputCheckPasswordSRP;

@interface TLRPCaccount_updatePasswordSettings : TLMetaRpc

@property (nonatomic, retain) TLInputCheckPasswordSRP *password;
@property (nonatomic, retain) TLaccount_PasswordInputSettings *n_new_settings;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCaccount_updatePasswordSettings$account_updatePasswordSettings : TLRPCaccount_updatePasswordSettings


@end

