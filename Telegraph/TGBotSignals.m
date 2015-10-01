#import "TGBotSignals.h"

#import "TGDatabase.h"
#import "TGTelegramNetworking.h"

#import "TGTelegraph.h"

#import "TL/TLMetaScheme.h"

#import "TLUpdates+TG.h"
#import "TGUserDataRequestBuilder.h"
#import "TGMessage+Telegraph.h"
#import "TGConversation+Telegraph.h"
#import "TGConversationAddMessagesActor.h"

@implementation TGBotSignals

+ (TGBotInfo *)botInfoForInfo:(TLBotInfo *)info
{
    if ([info isKindOfClass:[TLBotInfo$botInfo class]])
    {
        TLBotInfo$botInfo *concreteBotInfo = (TLBotInfo$botInfo *)info;
        NSMutableArray *commands = [[NSMutableArray alloc] init];
        for (TLBotCommand *command in concreteBotInfo.commands)
        {
            [commands addObject:[[TGBotComandInfo alloc] initWithCommand:command.command commandDescription:command.n_description]];
        }
        TGBotInfo *botInfo = [[TGBotInfo alloc] initWithVersion:concreteBotInfo.version shortDescription:concreteBotInfo.share_text botDescription:concreteBotInfo.n_description commandList:commands];
        return botInfo;
    }
    else
        return nil;
}

+ (TGBotReplyMarkup *)botReplyMarkupForMarkup:(TLReplyMarkup *)markup userId:(int32_t)userId messageId:(int32_t)messageId hidePreviousMarkup:(bool *)hidePreviousMarkup forceReply:(bool *)forceReply onlyIfRelevantToUser:(bool *)onlyIfRelevantToUser
{
    if ([markup isKindOfClass:[TLReplyMarkup$replyKeyboardMarkup class]])
    {
        TLReplyMarkup$replyKeyboardMarkup *concreteMarkup = (TLReplyMarkup$replyKeyboardMarkup *)markup;
        
        NSMutableArray *rows = [[NSMutableArray alloc] init];
        for (TLKeyboardButtonRow *rowInfo in concreteMarkup.rows)
        {
            NSMutableArray *buttons = [[NSMutableArray alloc] init];
            for (TLKeyboardButton *button in rowInfo.buttons)
            {
                [buttons addObject:[[TGBotReplyMarkupButton alloc] initWithText:button.text]];
            }
            [rows addObject:[[TGBotReplyMarkupRow alloc] initWithButtons:buttons]];
        }
        
        if (onlyIfRelevantToUser)
            *onlyIfRelevantToUser = concreteMarkup.flags & (1 << 2);
        
        return [[TGBotReplyMarkup alloc] initWithUserId:userId messageId:messageId rows:rows matchDefaultHeight:(concreteMarkup.flags & (1 << 0)) == 0 hideKeyboardOnActivation:(concreteMarkup.flags & (1 << 1)) != 0 alreadyActivated:false];
    }
    else if ([markup isKindOfClass:[TLReplyMarkup$replyKeyboardHide class]])
    {
        TLReplyMarkup$replyKeyboardHide *concreteMarkup = (TLReplyMarkup$replyKeyboardHide *)markup;
        
        if (hidePreviousMarkup)
            *hidePreviousMarkup = true;
        if (onlyIfRelevantToUser)
            *onlyIfRelevantToUser = concreteMarkup.flags & (1 << 2);
        return nil;
    }
    else if ([markup isKindOfClass:[TLReplyMarkup$replyKeyboardForceReply class]])
    {
        TLReplyMarkup$replyKeyboardForceReply *concreteMarkup = (TLReplyMarkup$replyKeyboardForceReply *)markup;
        if (forceReply)
            *forceReply = true;
        if (onlyIfRelevantToUser)
            *onlyIfRelevantToUser = concreteMarkup.flags & (1 << 2);
    }
    
    return nil;
}

+ (SSignal *)botInfoForUserId:(int32_t)userId
{
    SSignal *cached = [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
    {
        TGUser *user = [TGDatabaseInstance() loadUser:userId];
        TGBotInfo *botInfo = [TGDatabaseInstance() botInfoForUserId:userId];
        if (botInfo == nil)
            [subscriber putError:nil];
        else
        {
            [subscriber putNext:botInfo];
            if (botInfo.version < user.botInfoVersion)
                [subscriber putError:nil];
            else
                [subscriber putCompletion];
        }
        return nil;
    }];
    
    return [cached catch:^SSignal *(__unused id error)
    {
        TLRPCusers_getFullUser$users_getFullUser *getFullUser = [[TLRPCusers_getFullUser$users_getFullUser alloc] init];
        getFullUser.n_id = [TGTelegraphInstance createInputUserForUid:userId];
        SSignal *remote = [[[TGTelegramNetworking instance] requestSignal:getFullUser] mapToSignal:^SSignal *(TLUserFull *result)
        {
            TGBotInfo *botInfo = [self botInfoForInfo:result.bot_info];
            if (botInfo != nil)
            {
                [TGDatabaseInstance() storeBotInfo:botInfo forUserId:userId];
                return [SSignal single:botInfo];
            }
            else
                return [SSignal fail:nil];
        }];
        
        return remote;
    }];
}

+ (SSignal *)botStartForUserId:(int32_t)userId payload:(NSString *)payload
{
    TLRPCmessages_startBot$messages_startBot *startBot = [[TLRPCmessages_startBot$messages_startBot alloc] init];
    startBot.bot = [TGTelegraphInstance createInputUserForUid:userId];
    startBot.chat_id = 0;
    int64_t randomId = 0;
    arc4random_buf(&randomId, 8);
    startBot.random_id = randomId;
    startBot.start_param = payload;
    
    return [[[TGTelegramNetworking instance] requestSignal:startBot] map:^id(TLUpdates *updates)
    {
        [[TGTelegramNetworking instance] addUpdates:updates];
        
        return nil;
    }];
}

+ (SSignal *)botInviteUserId:(int32_t)userId toGroupId:(int32_t)groupId payload:(NSString *)payload
{
    TLRPCmessages_startBot$messages_startBot *startBot = [[TLRPCmessages_startBot$messages_startBot alloc] init];
    startBot.bot = [TGTelegraphInstance createInputUserForUid:userId];
    startBot.chat_id = -groupId;
    int64_t randomId = 0;
    arc4random_buf(&randomId, 8);
    startBot.random_id = randomId;
    startBot.start_param = payload;
    
    return [[[TGTelegramNetworking instance] requestSignal:startBot] map:^id(TLUpdates *updates)
    {
        [TGUserDataRequestBuilder executeUserDataUpdate:updates.users];
        
        TGConversation *chatConversation = nil;
        
        if (updates.chats.count != 0)
        {
            NSMutableDictionary *chats = [[NSMutableDictionary alloc] init];
            
            TGMessage *message = updates.messages.count == 0 ? nil : [[TGMessage alloc] initWithTelegraphMessageDesc:updates.messages.firstObject];
            
            for (TLChat *chatDesc in updates.chats)
            {
                TGConversation *conversation = [[TGConversation alloc] initWithTelegraphChatDesc:chatDesc];
                if (conversation != nil)
                {
                    if (chatConversation == nil)
                    {
                        chatConversation = conversation;
                        
                        TGConversation *oldConversation = [TGDatabaseInstance() loadConversationWithId:chatConversation.conversationId];
                        chatConversation.chatParticipants = [oldConversation.chatParticipants copy];
                        
                        if ([chatDesc isKindOfClass:[TLChat$chat class]])
                        {
                            chatConversation.chatParticipants.version = ((TLChat$chat *)chatDesc).version;
                            chatConversation.chatVersion = ((TLChat$chat *)chatDesc).version;
                        }
                        
                        if (![chatConversation.chatParticipants.chatParticipantUids containsObject:@(userId)])
                        {
                            NSMutableArray *newUids = [[NSMutableArray alloc] initWithArray:chatConversation.chatParticipants.chatParticipantUids];
                            [newUids addObject:@(userId)];
                            chatConversation.chatParticipants.chatParticipantUids = newUids;
                            
                            NSMutableDictionary *newInvitedBy = [[NSMutableDictionary alloc] initWithDictionary:chatConversation.chatParticipants.chatInvitedBy];
                            [newInvitedBy setObject:@(TGTelegraphInstance.clientUserId) forKey:@(userId)];
                            chatConversation.chatParticipants.chatInvitedBy = newInvitedBy;
                            
                            NSMutableDictionary *newInvitedDates = [[NSMutableDictionary alloc] initWithDictionary:chatConversation.chatParticipants.chatInvitedDates];
                            [newInvitedDates setObject:@(message.date) forKey:@(userId)];
                            chatConversation.chatParticipants.chatInvitedDates = newInvitedDates;
                        }
                        
                        conversation = chatConversation;
                    }
                    
                    [chats setObject:conversation forKey:[[NSNumber alloc] initWithLongLong:conversation.conversationId]];
                }
            }
            
            static int actionId = 0;
            [[[TGConversationAddMessagesActor alloc] initWithPath:[[NSString alloc] initWithFormat:@"/tg/addmessage/(addMember%d)", actionId++] ] execute:[[NSDictionary alloc] initWithObjectsAndKeys:chats, @"chats", message == nil ? @[] : @[message], @"messages", nil]];
        }
        
        [[TGTelegramNetworking instance] addUpdates:updates];
        
        return nil;
    }];
}

@end
