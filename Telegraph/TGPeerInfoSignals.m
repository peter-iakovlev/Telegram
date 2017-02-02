#import "TGPeerInfoSignals.h"

#import "TL/TLMetaScheme.h"
#import "TGTelegramNetworking.h"

#import "TGUser+Telegraph.h"
#import "TGConversation+Telegraph.h"

#import "TGUserDataRequestBuilder.h"

#import "TGTelegraph.h"

#import "TGAccountSignals.h"

#import "TGRecentContextBotsSignal.h"

#import "TGRemoteImageView.h"
#import "TGRemoteFileSignal.h"
#import "TGImageInfo+Telegraph.h"

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
    return [self resolveBotDomain:query contextBotsOnly:true];
}

+ (SSignal *)resolveBotDomain:(NSString *)query contextBotsOnly:(bool)contextBotsOnly {
    if (query.length == 0) {
        return [SSignal fail:nil];
    }
    
    return [[SSignal defer:^SSignal *{
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
            SSignal *recentCached = [[[TGRecentContextBotsSignal recentBots] take:1] mapToSignal:^SSignal *(NSArray *uids) {
                return [TGDatabaseInstance() modify:^id{
                    for (NSNumber *nUid in uids) {
                        TGUser *user = [TGDatabaseInstance() loadUser:[nUid intValue]];
                        if (user != nil && [user.userName.lowercaseString isEqualToString:query.lowercaseString]) {
                            return user;
                        }
                    }
                    return nil;
                }];
            }];
            
            return [recentCached mapToSignal:^SSignal *(TGUser *cachedUser) {
                if (cachedUser != nil) {
                    return [SSignal single:cachedUser];
                } else {
                    TLRPCcontacts_resolveUsername$contacts_resolveUsername *resolveUsername = [[TLRPCcontacts_resolveUsername$contacts_resolveUsername alloc] init];
                    resolveUsername.username = query;
                    
                    SSignal *memoizedSignal = [[TGTelegraphInstance genericTasksSignalManager] multicastedSignalForKey:[[NSString alloc] initWithFormat:@"resolveBotDomain-%@", [query lowercaseString]] producer:^SSignal *{
                        return [[[[TGTelegramNetworking instance] requestSignal:resolveUsername] mapToSignal:^SSignal *(TLcontacts_ResolvedPeer *resolvedPeer) {
                            if ([resolvedPeer.peer isKindOfClass:[TLPeer$peerUser class]] && resolvedPeer.users.count != 0) {
                                TGUser *user = [[TGUser alloc] initWithTelegraphUserDesc:resolvedPeer.users[0]];
                                if (user.uid != 0 && (!contextBotsOnly || user.isContextBot)) {
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
    }] mapToSignal:^SSignal *(TGUser *user) {
        if (user.photoUrlSmall.length == 0) {
            return [SSignal single:user];
        } else {
            NSString *path = [[TGRemoteImageView sharedCache] pathForCachedData:user.photoUrlSmall];
            if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
                return [SSignal single:user];
            } else {
                int datacenterId = 0;
                int64_t volumeId = 0;
                int localId = 0;
                int64_t secret = 0;
                if (extractFileUrlComponents(user.photoUrlSmall, &datacenterId, &volumeId, &localId, &secret)) {
                    TLInputFileLocation$inputFileLocation *location = [[TLInputFileLocation$inputFileLocation alloc] init];
                    location.volume_id = volumeId;
                    location.local_id = localId;
                    location.secret = secret;
                    
                    return [[[[TGRemoteFileSignal dataForLocation:location datacenterId:datacenterId size:0 reportProgress:false mediaTypeTag:TGNetworkMediaTypeTagImage] take:1] map:^id(NSData *data) {
                        [data writeToFile:path atomically:true];
                        return user;
                    }] catch:^SSignal *(__unused id error) {
                        return [SSignal single:user];
                    }];
                } else {
                    return [SSignal single:user];
                }
            }
        }
    }];
}

+ (SSignal *)dismissReportSpamForPeers {
        return [[TGDatabaseInstance() enqueuedDismissReportPeerSpamPeerIds] mapToQueue:^SSignal *(NSNumber *nPeerId) {
            TGConversation *conversation = [TGDatabaseInstance() loadConversationWithId:[nPeerId longLongValue]];
            if (conversation == nil) {
                return [[TGDatabaseInstance() modify:^id{
                    [TGDatabaseInstance() commitDismissReportPeerSpam:[nPeerId longLongValue]];
                    
                    return [SSignal complete];
                }] switchToLatest];
            } else {
                return [[[[TGAccountSignals dismissReportSpamForPeer:conversation.conversationId accessHash:conversation.accessHash] mapToSignal:^SSignal *(__unused id next) {
                    return [SSignal complete];
                }] catch:^SSignal *(__unused id error) {
                    return [SSignal complete];
                }] then:[[TGDatabaseInstance() modify:^id{
                    [TGDatabaseInstance() commitDismissReportPeerSpam:[nPeerId longLongValue]];
                    
                    return [SSignal complete];
                }] switchToLatest]];
            }
        }];
}

@end
