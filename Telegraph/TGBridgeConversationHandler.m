#import "TGBridgeConversationHandler.h"
#import "TGBridgeConversationSubscription.h"

#import "TGConversationSignals.h"
#import "TGUserSignal.h"

#import "TGBridgeChat+TGConversation.h"
#import "TGBridgeUser+TGUser.h"

@implementation TGBridgeConversationHandler

+ (SSignal *)handlingSignalForSubscription:(TGBridgeSubscription *)subscription server:(TGBridgeServer *)__unused server
{
    if ([subscription isKindOfClass:[TGBridgeConversationSubscription class]])
    {
        TGBridgeConversationSubscription *conversationSubscription = (TGBridgeConversationSubscription *)subscription;
        
        return [[TGConversationSignals conversationWithPeerId:conversationSubscription.peerId] mapToSignal:^SSignal *(TGConversation *conversation)
        {
            TGBridgeChat *bridgeChat = [TGBridgeChat chatWithTGConversation:conversation];
            NSMutableIndexSet *userIds = [[NSMutableIndexSet alloc] init];
            [userIds addIndexes:[bridgeChat involvedUserIds]];
            [userIds addIndexes:[bridgeChat participantsUserIds]];
            
            NSMutableArray *userSignals = [[NSMutableArray alloc] init];
            [userIds enumerateIndexesUsingBlock:^(NSUInteger index, __unused BOOL *stop)
            {
                if (index != 0)
                    [userSignals addObject:[TGUserSignal userWithUserId:(int32_t)index]];
            }];
            
            return [[SSignal combineSignals:userSignals] map:^id(NSArray *users)
            {
                NSMutableDictionary *bridgeUsers = [[NSMutableDictionary alloc] init];
                for (TGUser *user in users)
                {
                    TGBridgeUser *bridgeUser = [TGBridgeUser userWithTGUser:user];
                    if (bridgeUser != nil)
                        bridgeUsers[@(bridgeUser.identifier)] = bridgeUser;
                }
                
                return @{ TGBridgeChatKey: bridgeChat, TGBridgeUsersDictionaryKey: bridgeUsers };
            }];
        }];
    }
    
    return [SSignal fail:nil];
}

+ (NSArray *)handledSubscriptions
{
    return @[ [TGBridgeConversationSubscription class] ];
}

@end
