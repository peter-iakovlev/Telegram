#import "TGRecentPeersSignals.h"

#import "TGTelegraph.h"
#import "TGDatabase.h"
#import "TGTelegramNetworking.h"
#import "TL/TLMetaScheme.h"
#import "TGUserDataRequestBuilder.h"
#import "TGConversation+Telegraph.h"
#import "TGMessage+Telegraph.h"
#import "TGPeerIdAdapter.h"

#import "TGRecentHashtagsSignal.h"

#import "TGDialogListRecentPeers.h"

#import "TGDatabase.h"

#import "TGRemoteRecentPeer.h"
#import "TGRemoteRecentPeerSet.h"
#import "TGRemoteRecentPeerCategories.h"

@implementation TGRecentPeersSignals

+ (SSignal *)recentPeers {
    return [TGDatabaseInstance() cachedRecentPeers];
}

+ (SSignal *)updateRecentPeers {
    return [SSignal defer:^SSignal *{
        NSTimeInterval cacheInvalidationTimeout = 24 * 60 * 60;
#if TARGET_IPHONE_SIMULATOR
        //cacheInvalidationTimeout = 10.0;
#endif
        
        return [TGTelegraphInstance.genericTasksSignalManager multicastedSignalForKey:@"updateRecentPeers" producer:^SSignal *{
            SSignal *current = [[self recentPeers] take:1];
            return [[[current mapToSignal:^SSignal *(TGRemoteRecentPeerCategories *categories) {
                NSTimeInterval timeout = (cacheInvalidationTimeout + categories.lastRefreshTimestamp) - CFAbsoluteTimeGetCurrent();
                if (timeout < DBL_EPSILON) {
                    return [self remoteRecentPeerCategories];
                } else {
                    return [[SSignal complete] delay:MAX(0.0, timeout) onQueue:[SQueue concurrentDefaultQueue]];
                }
            }] restart] onNext:^(TGRemoteRecentPeerCategories *categories) {
                [TGDatabaseInstance() replaceCachedRecentPeers:categories];
            }];
        }];
    }];
}

+ (TGPeerRatingCategory)identifierForRemoteCategory:(TLTopPeerCategory *)category {
    if ([category isKindOfClass:[TLTopPeerCategory$topPeerCategoryBotsPM class]]) {
        return TGPeerRatingCategoryBots;
    } else if ([category isKindOfClass:[TLTopPeerCategory$topPeerCategoryGroups class]]) {
        return TGPeerRatingCategoryGroups;
    } else if ([category isKindOfClass:[TLTopPeerCategory$topPeerCategoryChannels class]]) {
        return TGPeerRatingCategoryNone;
    } else if ([category isKindOfClass:[TLTopPeerCategory$topPeerCategoryBotsInline class]]) {
        return TGPeerRatingCategoryInlineBots;
    } else if ([category isKindOfClass:[TLTopPeerCategory$topPeerCategoryCorrespondents class]]) {
        return TGPeerRatingCategoryPeople;
    }
    return TGPeerRatingCategoryNone;
}

+ (TGRemoteRecentPeer *)peerFromRemotePeer:(TLTopPeer *)peer timestamp:(int32_t)timestamp {
    int64_t peerId = 0;
    if ([peer.peer isKindOfClass:[TLPeer$peerChat class]]) {
        peerId = TGPeerIdFromGroupId(((TLPeer$peerChat *)peer.peer).chat_id);
    } else if ([peer.peer isKindOfClass:[TLPeer$peerUser class]]) {
        peerId = ((TLPeer$peerUser *)peer.peer).user_id;
    } else if ([peer.peer isKindOfClass:[TLPeer$peerChannel class]]) {
        peerId = TGPeerIdFromChannelId(((TLPeer$peerChannel *)peer.peer).channel_id);
    }
    
    return [[TGRemoteRecentPeer alloc] initWithPeerId:peerId rating:peer.rating timestamp:timestamp];
}

+ (SSignal *)remoteRecentPeerCategories {
    TLRPCcontacts_getTopPeers$contacts_getTopPeers *getTopPeers = [[TLRPCcontacts_getTopPeers$contacts_getTopPeers alloc] init];
    getTopPeers.flags = (1 << 0) | (1 << 1) | (1 << 10) | (1 << 2);
    getTopPeers.offset = 0;
    getTopPeers.limit = 100;
    getTopPeers.n_hash = 0;
    return [[[TGTelegramNetworking instance] requestSignalWithResponseTimestamp:getTopPeers] map:^id(NSDictionary *dict) {
        TLcontacts_TopPeers *result = dict[@"result"];
        int32_t timestamp = (int32_t)[dict[@"timestamp"] doubleValue];
        if ([result isKindOfClass:[TLcontacts_TopPeers$contacts_topPeersNotModified class]]) {
            return [SSignal complete];
        } else if ([result isKindOfClass:[TLcontacts_TopPeers$contacts_topPeers class]]) {
            TLcontacts_TopPeers$contacts_topPeers *topPeers = (TLcontacts_TopPeers$contacts_topPeers *)result;
            [TGUserDataRequestBuilder executeUserDataUpdate:topPeers.users];
            
            NSMutableDictionary<NSNumber *, TGRemoteRecentPeerSet *> *categories = [[NSMutableDictionary alloc] init];
            for (TLTopPeerCategoryPeers *category in topPeers.categories) {
                TGPeerRatingCategory parsedCategory = [self identifierForRemoteCategory:category.category];
                if (parsedCategory != TGPeerRatingCategoryNone) {
                    NSMutableArray<TGRemoteRecentPeer *> *peers = [[NSMutableArray alloc] init];
                    for (TLTopPeer *peer in category.peers) {
                        [peers addObject:[self peerFromRemotePeer:peer timestamp:timestamp]];
                    }
                    
                    categories[@(parsedCategory)] = [[TGRemoteRecentPeerSet alloc] initWithPeers:peers];
                }
            }
            
            return [[TGRemoteRecentPeerCategories alloc] initWithLastRefreshTimestamp:CFAbsoluteTimeGetCurrent() categories:categories];
        } else {
            return [[TGRemoteRecentPeerCategories alloc] initWithLastRefreshTimestamp:CFAbsoluteTimeGetCurrent() categories:@{}];
        }
    }];
}

+ (SSignal *)genericCategoryForPeerId:(int64_t)peerId {
    return [TGDatabaseInstance() modify:^id{
        if (TGPeerIdIsChannel(peerId) || TGPeerIdIsGroup(peerId)) {
            TGConversation *conversation = [TGDatabaseInstance() loadConversationWithId:peerId];
            if (conversation != nil) {
                if (conversation.isChannel) {
                    if (conversation.isChannelGroup) {
                        return [[TLTopPeerCategory$topPeerCategoryGroups alloc] init];
                    } else {
                        return [[TLTopPeerCategory$topPeerCategoryChannels alloc] init];
                    }
                } else {
                    return [[TLTopPeerCategory$topPeerCategoryGroups alloc] init];
                }
            }
        } else {
            TGUser *user = [TGDatabaseInstance() loadUser:(int)peerId];
            if (user != nil) {
                if (user.kind == TGUserKindBot || user.kind == TGUserKindSmartBot) {
                    return [[TLTopPeerCategory$topPeerCategoryBotsPM alloc] init];
                } else {
                    return [[TLTopPeerCategory$topPeerCategoryCorrespondents alloc] init];
                }
            }
        }
        return nil;
    }];
}

+ (SSignal *)resetGenericPeerRating:(int64_t)peerId accessHash:(int64_t)accessHash {
    return [[self genericCategoryForPeerId:peerId] mapToSignal:^SSignal *(id inputCategory) {
        if (inputCategory == nil) {
            return [SSignal fail:nil];
        } else {
            TLRPCcontacts_resetTopPeerRating$contacts_resetTopPeerRating *resetTopPeerRating = [[TLRPCcontacts_resetTopPeerRating$contacts_resetTopPeerRating alloc] init];
            resetTopPeerRating.peer = [TGTelegraphInstance createInputPeerForConversation:peerId accessHash:accessHash];
            resetTopPeerRating.category = inputCategory;
            return [[[TGTelegramNetworking instance] requestSignal:resetTopPeerRating] mapToSignal:^SSignal *(__unused id result) {
                return [[SSignal defer:^SSignal *{
                    [TGDatabaseInstance() resetPeerRating:peerId category:[self identifierForRemoteCategory:inputCategory]];
                    
                    return [SSignal complete];
                }] startOn:[SQueue wrapConcurrentNativeQueue:[TGDatabaseInstance() databaseQueue]]];
            }];
        }
    }];
}

@end
