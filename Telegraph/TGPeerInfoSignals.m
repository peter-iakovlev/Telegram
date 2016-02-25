#import "TGPeerInfoSignals.h"

#import "TL/TLMetaScheme.h"
#import "TGTelegramNetworking.h"

#import "TGUser+Telegraph.h"
#import "TGConversation+Telegraph.h"

#import "TGUserDataRequestBuilder.h"

#import "TGTelegraph.h"

@implementation TGPeerInfoSignals

+ (NSMutableDictionary *)cachedDomains {
    static NSMutableDictionary *dict = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dict = [[NSMutableDictionary alloc] init];
        [[TGTelegraphInstance disposeOnLogout] add:[[SBlockDisposable alloc] initWithBlock:^{
            @synchronized(dict) {
                [dict removeAllObjects];
            }
        }]];
    });
    return dict;
}

+ (SSignal *)resolveBotDomain:(NSString *)query {
    if (query.length == 0) {
        return [SSignal fail:nil];
    }
    
    return [SSignal defer:^SSignal *{
        NSMutableDictionary *cachedDomains = [self cachedDomains];
        NSNumber *cachedUserId = nil;
        @synchronized(cachedDomains) {
            cachedUserId = cachedDomains[[query lowercaseString]];
        }
        if (cachedUserId != nil) {
            if ([cachedUserId respondsToSelector:@selector(intValue)]) {
                TGUser *user = [TGDatabaseInstance() loadUser:[cachedUserId intValue]];
                if (user != nil) {
                    return [SSignal single:user];
                } else {
                    return [SSignal fail:nil];
                }
            } else {
                return [SSignal fail:nil];
            }
        } else {
            TLRPCcontacts_resolveUsername$contacts_resolveUsername *resolveUsername = [[TLRPCcontacts_resolveUsername$contacts_resolveUsername alloc] init];
            resolveUsername.username = query;
            
            SSignal *memoizedSignal = [[TGTelegraphInstance genericTasksSignalManager] multicastedSignalForKey:[[NSString alloc] initWithFormat:@"resolveBotDomain-%@", [query lowercaseString]] producer:^SSignal *{
                return [[[[TGTelegramNetworking instance] requestSignal:resolveUsername] mapToSignal:^SSignal *(TLcontacts_ResolvedPeer *resolvedPeer) {
                    if ([resolvedPeer.peer isKindOfClass:[TLPeer$peerUser class]] && resolvedPeer.users.count != 0) {
                        TGUser *user = [[TGUser alloc] initWithTelegraphUserDesc:resolvedPeer.users[0]];
                        if (user.uid != 0 && user.isContextBot) {
                            [TGUserDataRequestBuilder executeUserObjectsUpdate:@[user]];
                            @synchronized(cachedDomains) {
                                cachedDomains[[query lowercaseString]] = @(user.uid);
                            }
                            return [SSignal single:user];
                        } else {
                            @synchronized(cachedDomains) {
                                cachedDomains[[query lowercaseString]] = [NSNull null];
                            }
                            return [SSignal fail:nil];
                        }
                    } else {
                        @synchronized(cachedDomains) {
                            cachedDomains[[query lowercaseString]] = [NSNull null];
                        }
                        
                        return [SSignal fail:nil];
                    }
                }] onError:^(__unused id error) {
                    @synchronized(cachedDomains) {
                        cachedDomains[[query lowercaseString]] = [NSNull null];
                    }
                }];
            }];
            
            return memoizedSignal;
        }
    }];
}

@end
