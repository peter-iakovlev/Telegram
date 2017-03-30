#import "TGTwoStepVerifyPasswordSignal.h"

#import "TGTelegramNetworking.h"

#import "TL/TLMetaScheme.h"

#import <MTProtoKit/MTEncryption.h>

#import "TGStoredTmpPassword.h"

@implementation TGTwoStepVerifyPasswordSignal

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
