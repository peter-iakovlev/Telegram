#import "TGAuthSessionListSignals.h"

#import "TGTelegramNetworking.h"

#import "TL/TLMetaScheme.h"

#import "TGAuthSession.h"

@implementation TGAuthSessionListSignals

+ (SSignal *)authSessionList
{
    TLRPCaccount_getAuthorizations$account_getAuthorizations *getAuthorizations = [[TLRPCaccount_getAuthorizations$account_getAuthorizations alloc] init];
    return [[[TGTelegramNetworking instance] requestSignal:getAuthorizations] map:^id(TLaccount_Authorizations *authorizations)
    {
        NSMutableArray *authSessions = [[NSMutableArray alloc] init];
        
        for (TLAuthorization *auth in authorizations.authorizations)
        {
            [authSessions addObject:[[TGAuthSession alloc] initWithSessionHash:auth.n_hash flags:auth.flags deviceModel:auth.device_model platform:auth.platform systemVersion:auth.system_version apiId:auth.api_id appName:auth.app_name appVersion:auth.app_version dateCreated:auth.date_created dateActive:auth.date_active ip:auth.ip country:auth.country region:auth.region]];
        }
        
        return authSessions;
    }];
}

+ (SSignal *)removeAllOtherSessions
{
    TLRPCauth_resetAuthorizations$auth_resetAuthorizations *resetAuthorizations = [[TLRPCauth_resetAuthorizations$auth_resetAuthorizations alloc] init];
    return [[[TGTelegramNetworking instance] requestSignal:resetAuthorizations] mapToSignal:^SSignal *(__unused id result)
    {
        return [self authSessionList];
    }];
}

+ (SSignal *)removeSession:(TGAuthSession *)session
{
    TLRPCaccount_resetAuthorization$account_resetAuthorization *resetAuthorization = [[TLRPCaccount_resetAuthorization$account_resetAuthorization alloc] init];
    resetAuthorization.n_hash = session.sessionHash;
    
    return [[[TGTelegramNetworking instance] requestSignal:resetAuthorization] mapToSignal:^SSignal *(__unused id result)
    {
        return [self authSessionList];
    }];
}

@end
