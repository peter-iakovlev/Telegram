#import "TLaccount_PasswordInputSettings.h"

@interface TLaccount_PasswordInputSettings_manual : TLaccount_PasswordInputSettings

@property (nonatomic) int32_t flags;
@property (nonatomic, strong) NSData *n_newSalt;
@property (nonatomic, strong) NSData *n_newPasswordHash;
@property (nonatomic, strong) NSString *hint;
@property (nonatomic, strong) NSString *email;

@end
