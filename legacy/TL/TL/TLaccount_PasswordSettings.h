#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLSecureSecretSettings;

@interface TLaccount_PasswordSettings : NSObject <TLObject>

@property (nonatomic) int32_t flags;
@property (nonatomic, retain) NSString *email;
@property (nonatomic, retain) TLSecureSecretSettings *secure_settings;

@end

@interface TLaccount_PasswordSettings$account_passwordSettingsMeta : TLaccount_PasswordSettings


@end

