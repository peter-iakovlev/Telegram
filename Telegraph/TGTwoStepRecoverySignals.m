#import "TGTwoStepRecoverySignals.h"

#import "TGTelegramNetworking.h"
#import "TL/TLMetaScheme.h"

#import "TLUser$modernUser.h"

@implementation TGTwoStepRecoverySignals

+ (SSignal *)requestPasswordRecovery
{
    TLRPCauth_requestPasswordRecovery$auth_requestPasswordRecovery *requestPasswordRecovery = [[TLRPCauth_requestPasswordRecovery$auth_requestPasswordRecovery alloc] init];
    return [[[[TGTelegramNetworking instance] requestSignal:requestPasswordRecovery] map:^id (TLauth_PasswordRecovery *result)
    {
        return result.email_pattern;
    }] catch:^SSignal *(id error)
    {
        return [SSignal fail:[[TGTelegramNetworking instance] extractNetworkErrorType:error]];
    }];
}

+ (SSignal *)recoverPasswordWithCode:(NSString *)code
{
    TLRPCauth_recoverPassword$auth_recoverPassword *recoverPassword = [[TLRPCauth_recoverPassword$auth_recoverPassword alloc] init];
    recoverPassword.code = code;
    return [[[[TGTelegramNetworking instance] requestSignal:recoverPassword] map:^id(TLauth_Authorization *result)
    {
        return @(((TLUser$modernUser *)result.user).n_id);
    }] catch:^SSignal *(id error)
    {
        NSString *errorType = [[TGTelegramNetworking instance] extractNetworkErrorType:error];
        if ([errorType isEqualToString:@"PASSWORD_RECOVERY_EXPIRED"])
        {
            return [[[self requestPasswordRecovery] mapToSignal:^SSignal *(__unused id result)
            {
                return [SSignal fail:@(TGTwoStepRecoveryErrorCodeExpired)];
            }] catch:^SSignal *(id error)
            {
                NSString *errorType = [[TGTelegramNetworking instance] extractNetworkErrorType:error];
                if ([errorType hasPrefix:@"FLOOD_WAIT"])
                    return [SSignal fail:@(TGTwoStepRecoveryErrorFlood)];
                return [SSignal fail:@(TGTwoStepRecoveryErrorInvalidCode)];
            }];
        }
        else if ([errorType hasPrefix:@"FLOOD_WAIT"])
        {
            return [SSignal fail:@(TGTwoStepRecoveryErrorFlood)];
        }
        
        return [SSignal fail:@(TGTwoStepRecoveryErrorInvalidCode)];
    }];
}

@end
