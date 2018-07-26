#import "TGTwoStepSetPaswordSignal.h"

#import "TGTwoStepConfig.h"
#import "TGTelegramNetworking.h"

#import "TL/TLMetaScheme.h"

#import <MTProtoKit/MTEncryption.h>

#import "TGTwoStepConfigSignal.h"

#import "TGPassportSignals.h"

#import "TLaccount_PasswordInputSettings_manual.h"

@implementation TGTwoStepSetPaswordSignal

+ (SSignal *)setPassword:(NSString *)password hint:(NSString *)hint email:(NSString *)email {
    return [[TGTwoStepConfigSignal twoStepConfig] mapToSignal:^SSignal *(TGTwoStepConfig *config) {
        return [self setPasswordWithCurrentSalt:nil currentPassword:nil currentSecret:nil nextSalt:config.nextSalt nextPassword:password nextHint:hint email:email secretRandom:config.secretRandom nextSecureSalt:config.nextSecureSalt];
    }];
}

+ (SSignal *)setPasswordWithCurrentSalt:(NSData *)currentSalt currentPassword:(NSString *)currentPassword currentSecret:(NSData *)currentSecret nextSalt:(NSData *)nextSalt nextPassword:(NSString *)nextPassword nextHint:(NSString *)nextHint email:(NSString *)email secretRandom:(NSData *)secretRandom nextSecureSalt:(NSData *)nextSecureSalt
{
    [TGPassportSignals clearStoredPasswordHashes];
    
    TLRPCaccount_updatePasswordSettings$account_updatePasswordSettings *updatePasswordSettings = [[TLRPCaccount_updatePasswordSettings$account_updatePasswordSettings alloc] init];
    
    NSData *currentPasswordHash = [NSData data];
    if (currentSalt != nil)
    {
        NSMutableData *data = [[NSMutableData alloc] init];
        [data appendData:currentSalt];
        [data appendData:[currentPassword dataUsingEncoding:NSUTF8StringEncoding]];
        [data appendData:currentSalt];
        currentPasswordHash = MTSha256(data);
    }
    updatePasswordSettings.current_password_hash = currentPasswordHash;
    
    if (nextPassword.length == 0)
    {
        NSData *newPasswordHash = [NSData data];
        NSData *newPasswordSalt = [NSData data];
        
        TLaccount_PasswordInputSettings_manual *inputSettings = [[TLaccount_PasswordInputSettings_manual alloc] init];
        if (currentSalt.length == 0)
            inputSettings.flags = 2;
        else
            inputSettings.flags = 1 | 2;
        
        inputSettings.n_newSalt = newPasswordSalt;
        inputSettings.n_newPasswordHash = newPasswordHash;
        inputSettings.hint = @"";
        inputSettings.email = @"";
        
        inputSettings.flags |= (1 >> 3);
        inputSettings.n_new_secure_secret = nil;
        updatePasswordSettings.n_new_settings = inputSettings;
    }
    else
    {
        NSData *newPasswordHash = [NSData data];
        NSData *newPasswordSalt = nextSalt;
        if (nextSalt != nil)
        {
            NSMutableData *salt = [[NSMutableData alloc] initWithData:nextSalt];
            uint8_t bytes[32];
            arc4random_buf(bytes, 32);
            [salt appendBytes:bytes length:32];
            newPasswordSalt = salt;
            
            NSMutableData *data = [[NSMutableData alloc] init];
            [data appendData:newPasswordSalt];
            [data appendData:[nextPassword dataUsingEncoding:NSUTF8StringEncoding]];
            [data appendData:newPasswordSalt];
            newPasswordHash = MTSha256(data);
        }
        
        TLaccount_PasswordInputSettings_manual *inputSettings = [[TLaccount_PasswordInputSettings_manual alloc] init];
        inputSettings.flags = 1 | (email == nil ? 0 : 2);

        inputSettings.n_newSalt = newPasswordSalt;
        inputSettings.n_newPasswordHash = newPasswordHash;
        inputSettings.hint = nextHint;
        inputSettings.email = email;

        inputSettings.flags |= (1 << 2);

        if (currentSecret == nil)
            currentSecret = [TGPassportSignals secretWithSecretRandom:secretRandom];

        NSData *secureSalt = nil;
        inputSettings.n_new_secure_secret = [TGPassportSignals encryptedSecureSecretWithData:currentSecret passord:nextPassword nextSecureSalt:nextSecureSalt secureSaltOut:&secureSalt];
        inputSettings.n_new_secure_salt = secureSalt;
        inputSettings.n_new_secure_secret_id = [TGPassportSignals secureSecretId:currentSecret];
        
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

+ (SSignal *)setRecoveryEmail:(NSData *)currentSalt currentPassword:(NSString *)currentPassword recoveryEmail:(NSString *)recoveryEmail
{
    [TGPassportSignals clearStoredPasswordHashes];
    
    TLRPCaccount_updatePasswordSettings$account_updatePasswordSettings *updatePasswordSettings = [[TLRPCaccount_updatePasswordSettings$account_updatePasswordSettings alloc] init];
    
    NSData *currentPasswordHash = [NSData data];
    if (currentSalt != nil)
    {
        NSMutableData *data = [[NSMutableData alloc] init];
        [data appendData:currentSalt];
        [data appendData:[currentPassword dataUsingEncoding:NSUTF8StringEncoding]];
        [data appendData:currentSalt];
        currentPasswordHash = MTSha256(data);
    }
    updatePasswordSettings.current_password_hash = currentPasswordHash;
    
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

+ (SSignal *)setSecureSecret:(NSData *)secret nextSecureSalt:(NSData *)nextSecureSalt currentSalt:(NSData *)currentSalt currentPassword:(NSString *)currentPassword recoveryEmail:(NSString *)recoveryEmail
{
    [TGPassportSignals clearStoredPasswordHashes];
    
    TLRPCaccount_updatePasswordSettings$account_updatePasswordSettings *updatePasswordSettings = [[TLRPCaccount_updatePasswordSettings$account_updatePasswordSettings alloc] init];
    
    NSData *currentPasswordHash = [NSData data];
    if (currentSalt != nil)
    {
        NSMutableData *data = [[NSMutableData alloc] init];
        [data appendData:currentSalt];
        [data appendData:[currentPassword dataUsingEncoding:NSUTF8StringEncoding]];
        [data appendData:currentSalt];
        currentPasswordHash = MTSha256(data);
    }
    updatePasswordSettings.current_password_hash = currentPasswordHash;
    
    TLaccount_PasswordInputSettings_manual *inputSettings = [[TLaccount_PasswordInputSettings_manual alloc] init];
    inputSettings.flags = (1 << 2);
    inputSettings.email = recoveryEmail;

    NSData *secureSalt = [NSData data];
    NSData *encryptedSecret = [NSData data];
    if (secret != nil)
        encryptedSecret = [TGPassportSignals encryptedSecureSecretWithData:secret passord:currentPassword nextSecureSalt:nextSecureSalt secureSaltOut:&secureSalt];

    inputSettings.n_new_secure_secret = encryptedSecret;
    inputSettings.n_new_secure_salt = secureSalt;
    inputSettings.n_new_secure_secret_id = secret ? [TGPassportSignals secureSecretId:secret] : 0;
    
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
