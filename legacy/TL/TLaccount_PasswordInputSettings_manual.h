#import "TLaccount_PasswordInputSettings.h"

@interface TLaccount_PasswordInputSettings_manual : TLaccount_PasswordInputSettings

@property (nonatomic) int32_t flags;
@property (nonatomic, strong) NSData *n_newSalt;
@property (nonatomic, strong) NSData *n_newPasswordHash;
@property (nonatomic, strong) NSString *hint;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSData *n_new_secure_salt;
@property (nonatomic, strong) NSData *n_new_secure_secret;
@property (nonatomic) int64_t n_new_secure_secret_id;

@end
