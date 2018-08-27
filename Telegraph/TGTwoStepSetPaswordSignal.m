#import "TGTwoStepSetPaswordSignal.h"

#import "TGTwoStepConfig.h"
#import "TGTelegramNetworking.h"

#import "TL/TLMetaScheme.h"

#import <MTProtoKit/MTEncryption.h>

#import "TGTwoStepConfigSignal.h"
#import "TGTwoStepUtils.h"

#import "TGPassportSignals.h"

#import "TLaccount_PasswordInputSettings_manual.h"

@implementation TGTwoStepSetPaswordSignal

+ (SSignal *)setPassword:(NSString *)password hint:(NSString *)hint email:(NSString *)email {
    return [[TGTwoStepConfigSignal twoStepConfig] mapToSignal:^SSignal *(TGTwoStepConfig *config) {
        return [self setPasswordWithCurrentAlgo:nil currentPassword:nil currentSecret:nil nextAlgo:config.nextAlgo nextPassword:password nextHint:hint email:email nextSecureAlgo:config.nextSecureAlgo secureRandom:config.secureRandom srpId:0 srpB:nil];
    }];
}

+ (SSignal *)setPasswordWithCurrentAlgo:(TGPasswordKdfAlgo *)currentAlgo currentPassword:(NSString *)currentPassword currentSecret:(NSData *)currentSecret nextAlgo:(TGPasswordKdfAlgo *)nextAlgo nextPassword:(NSString *)nextPassword nextHint:(NSString *)nextHint email:(NSString *)email nextSecureAlgo:(TGSecurePasswordKdfAlgo *)nextSecureAlgo secureRandom:(NSData *)secureRandom srpId:(int64_t)srpId srpB:(NSData *)srpB
{
    [TGPassportSignals clearStoredPasswordHashes];
    
    TLRPCaccount_updatePasswordSettings$account_updatePasswordSettings *updatePasswordSettings = [[TLRPCaccount_updatePasswordSettings$account_updatePasswordSettings alloc] init];
    updatePasswordSettings.password = [TGTwoStepUtils srpPasswordWithPassword:currentPassword algo:currentAlgo srpId:srpId srpB:srpB];
    
    if (nextPassword.length == 0)
    {
        NSData *newPasswordHash = [NSData data];
    
        TLaccount_PasswordInputSettings_manual *inputSettings = [[TLaccount_PasswordInputSettings_manual alloc] init];
        if (currentPassword.length == 0)
            inputSettings.flags = (1 << 1);
        else
            inputSettings.flags = (1 << 0) | (1 << 1);
        
        inputSettings.n_new_algo = [[TLPasswordKdfAlgo$passwordKdfAlgoUnknown alloc] init];
        inputSettings.n_new_password_hash = newPasswordHash;
        inputSettings.hint = @"";
        inputSettings.email = @"";
        
        inputSettings.n_new_secure_settings = nil;
        updatePasswordSettings.n_new_settings = inputSettings;
    }
    else
    {
        NSData *newPasswordHash = [NSData data];
        
        if (![nextAlgo isKindOfClass:[TGPasswordKdfAlgoSHA256SHA256PBKDF2HMACSHA512iter100000SHA256ModPow class]])
            return [SSignal fail:nil];
        
        TGPasswordKdfAlgoSHA256SHA256PBKDF2HMACSHA512iter100000SHA256ModPow *algo = (TGPasswordKdfAlgoSHA256SHA256PBKDF2HMACSHA512iter100000SHA256ModPow *)nextAlgo;
        
        NSData *salt1 = algo.salt1;
        if (salt1 != nil)
        {
            NSMutableData *salt = [[NSMutableData alloc] initWithData:salt1];
            uint8_t bytes[32];
            arc4random_buf(bytes, 32);
            [salt appendBytes:bytes length:32];
            salt1 = salt;
        }
        
        algo = [[TGPasswordKdfAlgoSHA256SHA256PBKDF2HMACSHA512iter100000SHA256ModPow alloc] initWithSalt1:salt1 salt2:algo.salt2 g:algo.g p:algo.p];
        newPasswordHash = [TGTwoStepUtils passwordHashWithPassword:nextPassword algo:algo];
        
        TLaccount_PasswordInputSettings_manual *inputSettings = [[TLaccount_PasswordInputSettings_manual alloc] init];
        inputSettings.flags = 1 | (email == nil ? 0 : 2);

        inputSettings.n_new_algo = [algo tl];
        inputSettings.n_new_password_hash = newPasswordHash;
        inputSettings.hint = nextHint;
        inputSettings.email = email;

        if (currentSecret == nil)
            currentSecret = [TGPassportSignals secretWithSecretRandom:secureRandom];

        if ([nextSecureAlgo isKindOfClass:[TGSecurePasswordKdfAlgoPBKDF2HMACSHA512iter100000 class]])
        {
            inputSettings.flags |= (1 << 2);

            TLSecureSecretSettings$secureSecretSettings *secureSettings = [[TLSecureSecretSettings$secureSecretSettings alloc] init];

            TGSecurePasswordKdfAlgo *secureAlgo = nil;
            NSData *encryptedSecret = [TGPassportSignals encryptedSecureSecretWithData:currentSecret password:nextPassword nextSecureAlgo:nextSecureAlgo secureAlgoOut:&secureAlgo];

            secureSettings.secure_algo = [secureAlgo tl];
            secureSettings.secure_secret = encryptedSecret;
            secureSettings.secure_secret_id = [TGPassportSignals secureSecretId:currentSecret];

            inputSettings.n_new_secure_settings = secureSettings;
        }
        
        updatePasswordSettings.n_new_settings = inputSettings;
    }
    
    return [[[[TGTelegramNetworking instance] requestSignal:updatePasswordSettings requestClass:TGRequestClassFailOnFloodErrors] mapToSignal:^SSignal *(__unused id result)
    {
        return [TGTwoStepConfigSignal twoStepConfig];
    }] catch:^SSignal *(id error)
    {
        NSString *errorText = [[TGTelegramNetworking instance] extractNetworkErrorType:error];
        if ([errorText isEqualToString:@"EMAIL_UNCONFIRMED"])
            return [TGTwoStepConfigSignal twoStepConfig];
        else if ([errorText hasPrefix:@"FLOOD_WAIT"])
            return [SSignal fail:errorText];
        return [SSignal fail:error];
    }];
}

+ (SSignal *)setRecoveryEmail:(NSString *)recoveryEmail currentPassword:(NSString *)currentPassword algo:(TGPasswordKdfAlgo *)algo srpId:(int64_t)srpId srpB:(NSData *)srpB
{
    [TGPassportSignals clearStoredPasswordHashes];
    
    TLRPCaccount_updatePasswordSettings$account_updatePasswordSettings *updatePasswordSettings = [[TLRPCaccount_updatePasswordSettings$account_updatePasswordSettings alloc] init];
    updatePasswordSettings.password = [TGTwoStepUtils srpPasswordWithPassword:currentPassword algo:algo srpId:srpId srpB:srpB];
    
    TLaccount_PasswordInputSettings_manual *inputSettings = [[TLaccount_PasswordInputSettings_manual alloc] init];
    inputSettings.flags = 2;
    
    inputSettings.email = recoveryEmail;
    updatePasswordSettings.n_new_settings = inputSettings;
    
    return [[[[TGTelegramNetworking instance] requestSignal:updatePasswordSettings requestClass:TGRequestClassFailOnFloodErrors] mapToSignal:^SSignal *(__unused id result)
    {
        return [TGTwoStepConfigSignal twoStepConfig];
    }] catch:^SSignal *(id error)
    {
        NSString *errorText = [[TGTelegramNetworking instance] extractNetworkErrorType:error];
        if ([errorText isEqualToString:@"EMAIL_UNCONFIRMED"])
            return [TGTwoStepConfigSignal twoStepConfig];
        else if ([errorText hasPrefix:@"FLOOD_WAIT"])
            return [SSignal fail:errorText];
        return [SSignal fail:error];
    }];
}

+ (SSignal *)setSecureSecret:(NSData *)secret nextSecureAlgo:(TGSecurePasswordKdfAlgo *)nextSecureAlgo currentPassword:(NSString *)currentPassword currentAlgo:(TGPasswordKdfAlgo *)currentAlgo recoveryEmail:(NSString *)recoveryEmail srpId:(int64_t)srpId srpB:(NSData *)srpB
{
    [TGPassportSignals clearStoredPasswordHashes];
    
    if (![nextSecureAlgo isKindOfClass:[TGSecurePasswordKdfAlgoPBKDF2HMACSHA512iter100000 class]])
        return [SSignal fail:nil];
    
    TLRPCaccount_updatePasswordSettings$account_updatePasswordSettings *updatePasswordSettings = [[TLRPCaccount_updatePasswordSettings$account_updatePasswordSettings alloc] init];
    updatePasswordSettings.password = [TGTwoStepUtils srpPasswordWithPassword:currentPassword algo:currentAlgo srpId:srpId srpB:srpB];
    
    TLaccount_PasswordInputSettings_manual *inputSettings = [[TLaccount_PasswordInputSettings_manual alloc] init];
    inputSettings.flags = (1 << 2);
    inputSettings.email = recoveryEmail;

    TLSecureSecretSettings$secureSecretSettings *secureSettings = [[TLSecureSecretSettings$secureSecretSettings alloc] init];
    
    NSData *encryptedSecret = [NSData data];
    if (secret != nil)
    {
        TGSecurePasswordKdfAlgo *secureAlgo = nil;
        encryptedSecret = [TGPassportSignals encryptedSecureSecretWithData:secret password:currentPassword nextSecureAlgo:nextSecureAlgo secureAlgoOut:&secureAlgo];
        
        secureSettings.secure_algo = [secureAlgo tl];
        secureSettings.secure_secret = encryptedSecret;
        secureSettings.secure_secret_id = secret ? [TGPassportSignals secureSecretId:secret] : 0;
    }
    else
    {
        secureSettings.secure_algo = [[TLSecurePasswordKdfAlgo$securePasswordKdfAlgoSHA512 alloc] init];
    }
    inputSettings.n_new_secure_settings = secureSettings;
    
    updatePasswordSettings.n_new_settings = inputSettings;
    
    return [[[[TGTelegramNetworking instance] requestSignal:updatePasswordSettings requestClass:TGRequestClassFailOnFloodErrors] mapToSignal:^SSignal *(__unused id result)
    {
        return [TGTwoStepConfigSignal twoStepConfig];
    }] catch:^SSignal *(id error)
    {
        NSString *errorText = [[TGTelegramNetworking instance] extractNetworkErrorType:error];
        if ([errorText isEqualToString:@"EMAIL_UNCONFIRMED"])
            return [TGTwoStepConfigSignal twoStepConfig];
        else if ([errorText hasPrefix:@"FLOOD_WAIT"])
            return [SSignal fail:errorText];
        return [SSignal fail:error];
    }];
}

@end
