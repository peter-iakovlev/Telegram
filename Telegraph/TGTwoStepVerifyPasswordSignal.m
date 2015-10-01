#import "TGTwoStepVerifyPasswordSignal.h"

#import "TGTelegramNetworking.h"

#import "TL/TLMetaScheme.h"

#import <MTProtoKit/MTEncryption.h>

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

@end
