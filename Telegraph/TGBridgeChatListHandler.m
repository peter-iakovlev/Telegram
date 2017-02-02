#import "TGBridgeChatListHandler.h"
#import "TGBridgeChatListSubscription.h"
#import "TGBridgeServer.h"

#import "TGChatListSignals.h"
#import "TGConversation.h"
#import "TGUserSignal.h"
#import "TGUser.h"

#import "TGBridgeChat+TGConversation.h"
#import "TGBridgeUser+TGUser.h"

@implementation TGBridgeChatListHandler

+ (SSignal *)handlingSignalForSubscription:(TGBridgeSubscription *)subscription server:(TGBridgeServer *)server
{
    if ([subscription isKindOfClass:[TGBridgeChatListSubscription class]])
    {
        TGBridgeChatListSubscription *chatListSubscription = (TGBridgeChatListSubscription *)subscription;
        
        return [[[server server] mapToSignal:^SSignal *(TGBridgeServer *server) {
            return [server serviceSignalForKey:@"chatList" producer:nil];
        }] mapToSignal:^SSignal *(NSArray *chats)
        {
            NSMutableArray *bridgeChats = [[NSMutableArray alloc] init];
            
            return [[self _combinedSignalWithChats:chats bridgeChats:bridgeChats limit:chatListSubscription.limit] map:^id(NSArray *users)
            {
                NSMutableDictionary *bridgeUsers = [[NSMutableDictionary alloc] init];
                for (TGUser *user in users)
                {
                    if (![user isKindOfClass:[TGUser class]])
                        continue;
                    
                    TGBridgeUser *bridgeUser = [TGBridgeUser userWithTGUser:user];
                    if (bridgeUser != nil)
                        bridgeUsers[@(bridgeUser.identifier)] = bridgeUser;
                }
                
                return @{ TGBridgeChatsArrayKey: bridgeChats, TGBridgeUsersDictionaryKey: bridgeUsers };
            }];
        }];
    }
    
    return [SSignal fail:nil];
}

+ (SSignal *)_combinedSignalWithChats:(NSArray *)chats bridgeChats:(NSMutableArray *)bridgeChats limit:(NSUInteger)limit
{
    NSMutableIndexSet *userIds = [[NSMutableIndexSet alloc] init];
    
    NSUInteger i = 0;
    for (TGConversation *chat in chats)
    {
        if (chat.isBroadcast || chat.isEncrypted)
            continue;
        
        if (i >= limit)
            break;
        
        TGBridgeChat *bridgeChat = [TGBridgeChat chatWithTGConversation:chat];
        if (bridgeChat != nil)
        {
            [bridgeChats addObject:bridgeChat];
            [userIds addIndexes:[bridgeChat involvedUserIds]];
        }
        
        i++;
    }
    
    NSMutableArray *userSignals = [[NSMutableArray alloc] init];
    [userIds enumerateIndexesUsingBlock:^(NSUInteger index, __unused BOOL *stop)
    {
        if (index != 0)
        {
            [userSignals addObject:[[TGUserSignal userWithUserId:(int32_t)index] catch:^SSignal *(__unused id error)
            {
                return [SSignal single:[NSNull null]];
            }]];
        }
    }];
    
    SSignal *combinedUserSignal = [SSignal single:nil];
    if (userSignals.count > 0)
        combinedUserSignal = [SSignal combineSignals:userSignals];
    
    return combinedUserSignal;
}

+ (NSArray *)handledSubscriptions
{
    return @[ [TGBridgeChatListSubscription class] ];
}

@end
