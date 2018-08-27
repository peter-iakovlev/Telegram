#import "TLaccount_PasswordInputSettings.h"

@class TLPasswordKdfAlgo;
@class TLSecureSecretSettings;

@interface TLaccount_PasswordInputSettings_manual : TLaccount_PasswordInputSettings

@property (nonatomic) int32_t flags;
@property (nonatomic, strong) TLPasswordKdfAlgo *n_new_algo;
@property (nonatomic, strong) NSData *n_new_password_hash;
@property (nonatomic, strong) NSString *hint;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) TLSecureSecretSettings *n_new_secure_settings;

@end
