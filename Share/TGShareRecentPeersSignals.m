#import "TGShareRecentPeersSignals.h"

#import "TGPeerIdAdapter.h"
#import "TGChatModel.h"

NSString *const TGRecentSearchDefaultsKey = @"Telegram_recentSearch_peers";
const NSInteger TGRecentSearchLimit = 20;

@implementation TGShareRecentPeersSignals

+ (NSUserDefaults *)userDefaults
{
    static dispatch_once_t onceToken;
    static NSUserDefaults *userDefaults;
    dispatch_once(&onceToken, ^
    {
        NSString *groupName = [@"group." stringByAppendingString:[[NSBundle mainBundle] bundleIdentifier]];
        
        if ([groupName hasSuffix:@".Share"])
            groupName = [groupName substringWithRange:NSMakeRange(0, groupName.length - @".Share".length)];
        
        userDefaults = [[NSUserDefaults alloc] initWithSuiteName:groupName];
    });
    
    return userDefaults;
}

+ (void)clearRecentResults
{
    [[self userDefaults] removeObjectForKey:TGRecentSearchDefaultsKey];
    [[self userDefaults] synchronize];
}

+ (void)addRecentPeerResult:(TGPeerId)peerId
{
    int64_t appPeerId = 0;
    switch (peerId.namespaceId)
    {
        case TGPeerIdGroup:
            appPeerId = TGPeerIdFromGroupId(peerId.peerId);
            break;
            
        case TGPeerIdChannel:
            appPeerId = TGPeerIdFromChannelId(peerId.peerId);
            break;
            
        default:
            appPeerId = peerId.peerId;
            break;
    }
    
    NSMutableArray *items = [[NSMutableArray alloc] initWithArray:[[self userDefaults] objectForKey:TGRecentSearchDefaultsKey]];
    [items removeObject:@(appPeerId)];
    [items insertObject:@(appPeerId) atIndex:0];
    if (items.count > TGRecentSearchLimit)
        [items removeObjectsInRange:NSMakeRange(TGRecentSearchLimit, items.count - TGRecentSearchLimit)];
    [[self userDefaults] setObject:items forKey:TGRecentSearchDefaultsKey];
    [[self userDefaults] synchronize];
}

+ (void)removeRecentPeerResult:(TGPeerId)peerId
{
    int64_t appPeerId = 0;
    switch (peerId.namespaceId)
    {
        case TGPeerIdGroup:
            appPeerId = TGPeerIdFromGroupId(peerId.peerId);
            break;
            
        case TGPeerIdChannel:
            appPeerId = TGPeerIdFromChannelId(peerId.peerId);
            break;
            
        default:
            appPeerId = peerId.peerId;
            break;
    }
    
    NSMutableArray *items = [[NSMutableArray alloc] initWithArray:[[self userDefaults] objectForKey:TGRecentSearchDefaultsKey]];
    [items removeObject:@(appPeerId)];
    [[self userDefaults] setObject:items forKey:TGRecentSearchDefaultsKey];
    [[self userDefaults] synchronize];
}

+ (SSignal *)recentPeerResultsWithChats:(NSArray *)chats
{
    return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
    {
        NSArray *array = [[self userDefaults] objectForKey:TGRecentSearchDefaultsKey];
        NSMutableArray *peers = [[NSMutableArray alloc] init];
        
        NSMutableDictionary *chatMapping = [[NSMutableDictionary alloc] init];
        
        for (TGChatModel *model in chats)
        {
            if (chatMapping[@(model.peerId.namespaceId)] == nil)
                chatMapping[@(model.peerId.namespaceId)] = [[NSMutableDictionary alloc] init];
            
            chatMapping[@(model.peerId.namespaceId)][@(model.peerId.peerId)] = model;
        }
        
        for (NSNumber *peerIdVal in array)
        {
            int64_t peerId = peerIdVal.integerValue;
            if (TGPeerIdIsGroup(peerId))
            {
                TGChatModel *chat = chatMapping[@(TGPeerIdGroup)][@(TGGroupIdFromPeerId(peerId))];
                if (chat != nil)
                    [peers addObject:chat];
            }
            else if (TGPeerIdIsChannel(peerId))
            {
                TGChatModel *chat = chatMapping[@(TGPeerIdChannel)][@(TGChannelIdFromPeerId(peerId))];
                if (chat != nil)
                    [peers addObject:chat];
            }
            else
            {
                TGChatModel *chat = chatMapping[@(TGPeerIdPrivate)][@(peerId)];
                if (chat != nil)
                    [peers addObject:chat];
            }
        }
        
        [subscriber putNext:peers];
        [subscriber putCompletion];
        
        return nil;
    }];
}

@end
