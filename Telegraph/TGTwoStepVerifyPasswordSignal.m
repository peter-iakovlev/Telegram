#import "TGTwoStepVerifyPasswordSignal.h"

#import "TGTelegramNetworking.h"

#import "TL/TLMetaScheme.h"

#import "TGTwoStepConfigSignal.h"
#import "TGTwoStepUtils.h"

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
    NSData *x = nil;
    TLRPCaccount_getPasswordSettings$account_getPasswordSettings *getPasswordSettings = [[TLRPCaccount_getPasswordSettings$account_getPasswordSettings alloc] init];
    getPasswordSettings.password = [TGTwoStepUtils srpPasswordWithPassword:password algo:config.currentAlgo srpId:config.srpId srpB:config.srpB outX:&x];
    
    if (outPasswordHash != NULL && x != nil)
        *outPasswordHash = x;
    
    return [[[[TGTelegramNetworking instance] requestSignal:getPasswordSettings requestClass:TGRequestClassFailOnFloodErrors] catch:^SSignal *(id error)
    {
        return [SSignal fail:[[TGTelegramNetworking instance] extractNetworkErrorType:error]];
    }] map:^id(TLaccount_PasswordSettings *result) {
        NSData *decryptedSecret = nil;
        int64_t secretHash = 0;
        TGSecurePasswordKdfAlgo *secureAlgo = nil;
        if (result.secure_settings != nil) {
            if (result.secure_settings.secure_secret != nil) {
                secureAlgo = [TGSecurePasswordKdfAlgo algoWithTL:result.secure_settings.secure_algo];
                decryptedSecret = [TGPassportSignals decryptedSecureSecretWithData:result.secure_settings.secure_secret password:password secureAlgo:secureAlgo];
            }
            secretHash = result.secure_settings.secure_secret_id;
        }
        
        return [[TGPasswordSettings alloc] initWithPassword:password email:result.email secret:decryptedSecret secretHash:secretHash secureAlgo:secureAlgo];
    }];
}

+ (SSignal *)passwordHashSettings:(NSData *)currentPasswordHash secretPasswordHash:(NSData *)secretPasswordHash config:(TGTwoStepConfig *)config
{
    TLRPCaccount_getPasswordSettings$account_getPasswordSettings *getPasswordSettings = [[TLRPCaccount_getPasswordSettings$account_getPasswordSettings alloc] init];
    getPasswordSettings.password = [TGTwoStepUtils srpPasswordWithX:currentPasswordHash algo:config.currentAlgo srpId:config.srpId srpB:config.srpB];
    
    return [[[[TGTelegramNetworking instance] requestSignal:getPasswordSettings requestClass:TGRequestClassFailOnFloodErrors] catch:^SSignal *(id error)
    {
        return [SSignal fail:[[TGTelegramNetworking instance] extractNetworkErrorType:error]];
    }] map:^id(TLaccount_PasswordSettings *result) {
        NSData *decryptedSecret = nil;
        int64_t secretHash = 0;
        TGSecurePasswordKdfAlgo *secureAlgo = nil;
        if (result.secure_settings != nil) {
            if (result.secure_settings.secure_secret != nil) {
                secureAlgo = [TGSecurePasswordKdfAlgo algoWithTL:result.secure_settings.secure_algo];
                decryptedSecret = [TGPassportSignals decryptedSecureSecretWithData:result.secure_settings.secure_secret passwordHash:secretPasswordHash];
            }
            secretHash = result.secure_settings.secure_secret_id;
        }
        return [[TGPasswordSettings alloc] initWithPassword:nil email:result.email secret:decryptedSecret secretHash:secretHash secureAlgo:secureAlgo];
    }];
}

+ (SSignal *)checkPassword:(NSString *)password config:(TGTwoStepConfig *)config
{
    TLRPCaccount_getPasswordSettings$account_getPasswordSettings *getPasswordSettings = [[TLRPCaccount_getPasswordSettings$account_getPasswordSettings alloc] init];
    getPasswordSettings.password = [TGTwoStepUtils srpPasswordWithPassword:password algo:config.currentAlgo srpId:config.srpId srpB:config.srpB];
    
    return [[[TGTelegramNetworking instance] requestSignal:getPasswordSettings requestClass:TGRequestClassFailOnFloodErrors] catch:^SSignal *(id error)
    {
        return [SSignal fail:[[TGTelegramNetworking instance] extractNetworkErrorType:error]];
    }];
}

+ (SSignal *)tmpPassword:(NSString *)password config:(TGTwoStepConfig *)config durationSeconds:(int32_t)durationSeconds
{
    TLRPCaccount_getTmpPassword$account_getTmpPassword *getTmpPassword = [[TLRPCaccount_getTmpPassword$account_getTmpPassword alloc] init];
    getTmpPassword.password = [TGTwoStepUtils srpPasswordWithPassword:password algo:config.currentAlgo srpId:config.srpId srpB:config.srpB];
    getTmpPassword.period = durationSeconds;
    
    return [[[[TGTelegramNetworking instance] requestSignal:getTmpPassword requestClass:TGRequestClassFailOnFloodErrors] catch:^SSignal *(id error) {
        return [SSignal fail:[[TGTelegramNetworking instance] extractNetworkErrorType:error]];
    }] map:^id(TLaccount_TmpPassword *result) {
        return [[TGStoredTmpPassword alloc] initWithData:result.tmp_password validUntil:result.valid_until];
    }];
}

@end
