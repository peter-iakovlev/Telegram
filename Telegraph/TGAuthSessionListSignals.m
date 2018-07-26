#import "TGAuthSessionListSignals.h"

#import "TGTelegramNetworking.h"
#import "TGUserDataRequestBuilder.h"

#import "TL/TLMetaScheme.h"

#import "TGUser+Telegraph.h"

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

+ (SSignal *)loggedAppsSessionList
{
    TLRPCaccount_getWebAuthorizations$account_getWebAuthorizations *getWebAuthorizations = [[TLRPCaccount_getWebAuthorizations$account_getWebAuthorizations alloc] init];
    return [[[TGTelegramNetworking instance] requestSignal:getWebAuthorizations] map:^id(TLaccount_WebAuthorizations *authorizations)
    {
        NSMutableArray *authSessions = [[NSMutableArray alloc] init];
        NSMutableDictionary *users = [[NSMutableDictionary alloc] init];
        NSMutableArray *updateUsers = [[NSMutableArray alloc] init];
        
        for (TLUser *userDesc in authorizations.users)
        {
            TGUser *user = [[TGUser alloc] initWithTelegraphUserDesc:userDesc];
            if (user != nil)
            {
                users[@(user.uid)] = user;
                [updateUsers addObject:user];
            }
        }
        
        [TGUserDataRequestBuilder executeUserObjectsUpdate:updateUsers];
        
        for (TLWebAuthorization *auth in authorizations.authorizations)
        {
            [authSessions addObject:[[TGAppSession alloc] initWithSessionHash:auth.n_hash bot:users[@(auth.bot_id)] domain:auth.domain browser:auth.browser platform:auth.platform dateCreated:auth.date_created dateActive:auth.date_active ip:auth.ip country:nil region:auth.region]];
        }
        
        return authSessions;
    }];
}

+ (SSignal *)removeAllAppSessions
{
    TLRPCaccount_resetWebAuthorizations$account_resetWebAuthorizations *resetWebAuthorizations = [[TLRPCaccount_resetWebAuthorizations$account_resetWebAuthorizations alloc] init];
    
    return [[TGTelegramNetworking instance] requestSignal:resetWebAuthorizations];
}

+ (SSignal *)removeAppSession:(TGAppSession *)session
{
    TLRPCaccount_resetWebAuthorization$account_resetWebAuthorization *resetWebAuthorization = [[TLRPCaccount_resetWebAuthorization$account_resetWebAuthorization alloc] init];
    resetWebAuthorization.n_hash = session.sessionHash;
    
    return [[[TGTelegramNetworking instance] requestSignal:resetWebAuthorization] mapToSignal:^SSignal *(__unused id result)
    {
        return [self loggedAppsSessionList];
    }];
}
@end
