#import "TGShareRecentPeersSignals.h"

#import "TGShareContext.h"
#import "TGLegacyDatabase.h"
#import "TGLegacyUser.h"

#import "TGPeerIdAdapter.h"
#import "TGUserModel.h"
#import "TGChatModel.h"
#import "TGPrivateChatModel.h"

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

+ (SSignal *)recentPeerResultsWithContext:(TGShareContext *)context cachedChats:(NSArray *)cachedChats
{
    TGLegacyDatabase *database = context.legacyDatabase;
    NSArray<TGLegacyUser *> *topUsers =  [database topUsers];
    
    NSMutableArray *topPeers = [[NSMutableArray alloc] init];
    NSMutableArray *recentPeers = [[NSMutableArray alloc] init];

    NSMutableDictionary *usersMapping = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *chatMapping = [[NSMutableDictionary alloc] init];

    for (TGLegacyUser *user in topUsers)
    {
        if (chatMapping[@(TGPeerIdPrivate)] == nil)
            chatMapping[@(TGPeerIdPrivate)] = [[NSMutableDictionary alloc] init];
        
        chatMapping[@(TGPeerIdPrivate)][@(user.userId)] = [[TGPrivateChatModel alloc] initWithUserId:user.userId];
        
        TGUserModel *userModel = [[TGUserModel alloc] initWithUserId:user.userId accessHash:user.accessHash firstName:user.firstName lastName:user.lastName avatarLocation:[[TGFileLocation alloc] initWithFileUrl:user.photoSmall]];
        usersMapping[@(user.userId)] = userModel;
        
        [topPeers addObject:userModel];
    }
    
    for (TGChatModel *model in cachedChats)
    {
        if (chatMapping[@(model.peerId.namespaceId)] == nil)
            chatMapping[@(model.peerId.namespaceId)] = [[NSMutableDictionary alloc] init];

        chatMapping[@(model.peerId.namespaceId)][@(model.peerId.peerId)] = model;
    }
    
    NSArray *recentChatsIds = [[self userDefaults] objectForKey:TGRecentSearchDefaultsKey];
    for (NSNumber *peerIdVal in recentChatsIds)
    {
        int64_t peerId = peerIdVal.integerValue;
        if (TGPeerIdIsGroup(peerId))
        {
            TGChatModel *chat = chatMapping[@(TGPeerIdGroup)][@(TGGroupIdFromPeerId(peerId))];
            if (chat == nil)
                chat = [database conversationWithIdSync:peerId];
            
            if (chat != nil)
                [recentPeers addObject:chat];
        }
        else if (TGPeerIdIsChannel(peerId))
        {
            TGChatModel *chat = chatMapping[@(TGPeerIdChannel)][@(TGChannelIdFromPeerId(peerId))];
            if (chat == nil)
                chat = [database conversationWithIdSync:peerId];
            
            if (chat != nil)
                [recentPeers addObject:chat];
        }
        else
        {
            TGChatModel *chat = chatMapping[@(TGPeerIdPrivate)][@(peerId)];
            if (chat == nil)
                chat = [database conversationWithIdSync:peerId];
            
            if (chat != nil)
                [recentPeers addObject:chat];
        }
    }
    
    return [SSignal single:@{ @"top": topPeers, @"recent": recentPeers, @"users": usersMapping }];
}

@end
