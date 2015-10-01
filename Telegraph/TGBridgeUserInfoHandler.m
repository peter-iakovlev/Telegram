#import "TGBridgeUserInfoHandler.h"
#import "TGBridgeUserInfoSubscription.h"

#import "TGUserSignal.h"
#import "TGBotSignals.h"

#import "TGDatabase.h"

#import "TGUser.h"
#import "TGBridgeMessage+TGMessage.h"
#import "TGBridgeUser+TGUser.h"
#import "TGBridgeBotInfo+TGBotInfo.h"
#import "TGBridgeBotReplyMarkup+TGBotReplyMarkup.h"

@implementation TGBridgeUserInfoHandler

+ (SSignal *)handlingSignalForSubscription:(TGBridgeSubscription *)subscription server:(TGBridgeServer *)__unused server
{
    if ([subscription isKindOfClass:[TGBridgeUserInfoSubscription class]])
    {
        TGBridgeUserInfoSubscription *userInfoSubscription = (TGBridgeUserInfoSubscription *)subscription;
        
        NSMutableArray *userSignals = [[NSMutableArray alloc] init];
        for (NSNumber *userId in userInfoSubscription.userIds)
        {
            SSignal *userSignal = [[TGUserSignal userWithUserId:userId.int32Value] mapToSignal:^SSignal *(TGUser *user)
            {
                return [SSignal single:[TGBridgeUser userWithTGUser:user]];
            }];
            
            [userSignals addObject:userSignal];
        }
        
        return [[SSignal combineSignals:userSignals] map:^NSDictionary *(NSArray *users)
        {
            NSMutableDictionary *bridgeUsers = [[NSMutableDictionary alloc] init];
            for (TGBridgeUser *user in users)
                bridgeUsers[@(user.identifier)] = user;
            
            return bridgeUsers;
        }];
    }
    else if ([subscription isKindOfClass:[TGBridgeUserBotInfoSubscription class]])
    {
        TGBridgeUserBotInfoSubscription *botSubscription = (TGBridgeUserBotInfoSubscription *)subscription;
        
        NSMutableArray *infoSignals = [[NSMutableArray alloc] init];
        for (NSNumber *userId in botSubscription.userIds)
        {
            SSignal *botInfoSignal = [[TGBotSignals botInfoForUserId:userId.int32Value] map:^TGBridgeBotInfo *(TGBotInfo *botInfo)
            {
                return [TGBridgeBotInfo botInfoWithTGBotInfo:botInfo userId:userId.int32Value];
            }];
            
            [infoSignals addObject:botInfoSignal];
        }
        
        return [[SSignal combineSignals:infoSignals] map:^NSDictionary *(NSArray *botInfos)
        {
            NSMutableDictionary *bridgeBotInfos = [[NSMutableDictionary alloc] init];
            for (TGBridgeBotInfo *botInfo in botInfos)
                bridgeBotInfos[@(botInfo.userId)] = botInfo;

            return bridgeBotInfos;
        }];
    }
    else if ([subscription isKindOfClass:[TGBridgeBotReplyMarkupSubscription class]])
    {
        TGBridgeBotReplyMarkupSubscription *markupSubscription = (TGBridgeBotReplyMarkupSubscription *)subscription;
        
        return [[[TGDatabase instance] signalBotReplyMarkupForPeerId:markupSubscription.peerId] map:^TGBridgeBotReplyMarkup *(TGBotReplyMarkup *replyMarkup)
        {
            TGMessage *message = [[TGDatabase instance] loadMessageWithMid:replyMarkup.messageId peerId:markupSubscription.peerId];
                        
            return [TGBridgeBotReplyMarkup botReplyMarkupWithTGBotReplyMarkup:replyMarkup message:message];
        }];
    }
    
    return [SSignal fail:nil];
}

+ (NSArray *)handledSubscriptions
{
    return @[ [TGBridgeUserInfoSubscription class], [TGBridgeUserBotInfoSubscription class], [TGBridgeBotReplyMarkupSubscription class] ];
}

@end
