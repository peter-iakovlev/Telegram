#import "TGTwoStepVerifyPasswordSignal.h"

#import "TGTelegramNetworking.h"

#import "TL/TLMetaScheme.h"

#import "TGTwoStepConfigSignal.h"

#import <MTProtoKit/MTEncryption.h>
#import <CommonCrypto/CommonCrypto.h>

#import "TGStoredTmpPassword.h"
#import "TGPassportSignals.h"

@implementation TGTwoStepVerifyPasswordSignal

+ (SSignal *)passwordSettings:(NSString *)password config:(TGTwoStepConfig *)config
{
    return [self passwordSettings:password config:config outPasswordHash:NULL];
}

+ (SSignal *)passwordSettings:(NSString *)password config:(TGTwoStepConfig *)config outPasswordHash:(NSData **)outPasswordHash
{
    NSMutableData *data = [[NSMutableData alloc] init];
    [data appendData:config.currentSalt];
    [data appendData:[password dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:config.currentSalt];
    NSData *currentPasswordHash = MTSha256(data);
    
    if (outPasswordHash != NULL)
        *outPasswordHash = currentPasswordHash;
    
    TLRPCaccount_getPasswordSettings$account_getPasswordSettings *getPasswordSettings = [[TLRPCaccount_getPasswordSettings$account_getPasswordSettings alloc] init];
    getPasswordSettings.current_password_hash = currentPasswordHash;
    
    return [[[[TGTelegramNetworking instance] requestSignal:getPasswordSettings requestClass:TGRequestClassFailOnFloodErrors] catch:^SSignal *(id error)
    {
        return [SSignal fail:[[TGTelegramNetworking instance] extractNetworkErrorType:error]];
    }] map:^id(TLaccount_PasswordSettings *result) {
        NSData *decryptedSecret = nil;
        if (result.secure_secret != nil)
            decryptedSecret = [TGPassportSignals decryptedSecureSecretWithData:result.secure_secret passord:password secureSalt:result.secure_salt];
        
        return [[TGPasswordSettings alloc] initWithPassword:password email:result.email secret:decryptedSecret secretHash:result.secure_secret_id secureSalt:result.secure_salt];
    }];
}

+ (SSignal *)passwordHashSettings:(NSData *)currentPasswordHash secretPasswordHash:(NSData *)secretPasswordHash
{
    TLRPCaccount_getPasswordSettings$account_getPasswordSettings *getPasswordSettings = [[TLRPCaccount_getPasswordSettings$account_getPasswordSettings alloc] init];
    getPasswordSettings.current_password_hash = currentPasswordHash;
    
    return [[[[TGTelegramNetworking instance] requestSignal:getPasswordSettings requestClass:TGRequestClassFailOnFloodErrors] catch:^SSignal *(id error)
    {
        return [SSignal fail:[[TGTelegramNetworking instance] extractNetworkErrorType:error]];
    }] map:^id(TLaccount_PasswordSettings *result) {
        NSData *decryptedSecret = nil;
        if (result.secure_secret != nil)
            decryptedSecret = [TGPassportSignals decryptedSecureSecretWithData:result.secure_secret passwordHash:secretPasswordHash];
        
        return [[TGPasswordSettings alloc] initWithPassword:nil email:result.email secret:decryptedSecret secretHash:result.secure_secret_id secureSalt:result.secure_salt];
    }];
}

+ (SSignal *)checkPassword:(NSString *)password config:(TGTwoStepConfig *)config
{
    NSMutableData *data = [[NSMutableData alloc] init];
    [data appendData:config.currentSalt];
    [data appendData:[password dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:config.currentSalt];
    NSData *currentPasswordHash = MTSha256(data);
    
    TLRPCaccount_getPasswordSettings$account_getPasswordSettings *getPasswordSettings = [[TLRPCaccount_getPasswordSettings$account_getPasswordSettings alloc] init];
    getPasswordSettings.current_password_hash = currentPasswordHash;
    
    return [[[TGTelegramNetworking instance] requestSignal:getPasswordSettings requestClass:TGRequestClassFailOnFloodErrors] catch:^SSignal *(id error)
    {
        return [SSignal fail:[[TGTelegramNetworking instance] extractNetworkErrorType:error]];
    }];
}

+ (SSignal *)verifiedPasswordHash:(NSString *)password config:(TGTwoStepConfig *)config
{
    NSMutableData *data = [[NSMutableData alloc] init];
    [data appendData:config.currentSalt];
    [data appendData:[password dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:config.currentSalt];
    NSData *currentPasswordHash = MTSha256(data);
    
    TLRPCaccount_getPasswordSettings$account_getPasswordSettings *getPasswordSettings = [[TLRPCaccount_getPasswordSettings$account_getPasswordSettings alloc] init];
    getPasswordSettings.current_password_hash = currentPasswordHash;
    
    return [[[[TGTelegramNetworking instance] requestSignal:getPasswordSettings requestClass:TGRequestClassFailOnFloodErrors] catch:^SSignal *(id error)
    {
        return [SSignal fail:[[TGTelegramNetworking instance] extractNetworkErrorType:error]];
    }] map:^id(__unused id result) {
        return currentPasswordHash;
    }];
}

+ (SSignal *)authorizeWithPassword:(NSString *)password config:(TGTwoStepConfig *)config
{
    NSMutableData *data = [[NSMutableData alloc] init];
    [data appendData:config.currentSalt];
    [data appendData:[password dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:config.currentSalt];
    NSData *currentPasswordHash = MTSha256(data);
    
    TLRPCauth_checkPassword$auth_checkPassword *checkPassword = [[TLRPCauth_checkPassword$auth_checkPassword alloc] init];
    checkPassword.password_hash = currentPasswordHash;
    
    return [[[TGTelegramNetworking instance] requestSignal:checkPassword requestClass:TGRequestClassFailOnFloodErrors] catch:^SSignal *(id error)
    {
        return [SSignal fail:[[TGTelegramNetworking instance] extractNetworkErrorType:error]];
    }];
}

+ (SSignal *)tmpPassword:(NSString *)password config:(TGTwoStepConfig *)config durationSeconds:(int32_t)durationSeconds {
    TLRPCaccount_getTmpPassword$account_getTmpPassword *getTmpPassword = [[TLRPCaccount_getTmpPassword$account_getTmpPassword alloc] init];
    
    NSMutableData *data = [[NSMutableData alloc] init];
    [data appendData:config.currentSalt];
    [data appendData:[password dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:config.currentSalt];
    NSData *currentPasswordHash = MTSha256(data);
    
    getTmpPassword.password_hash = currentPasswordHash;
    getTmpPassword.period = durationSeconds;
    
    return [[[[TGTelegramNetworking instance] requestSignal:getTmpPassword requestClass:TGRequestClassFailOnFloodErrors] catch:^SSignal *(id error) {
        return [SSignal fail:[[TGTelegramNetworking instance] extractNetworkErrorType:error]];
    }] map:^id(TLaccount_TmpPassword *result) {
        return [[TGStoredTmpPassword alloc] initWithData:result.tmp_password validUntil:result.valid_until];
    }];
}

@end
