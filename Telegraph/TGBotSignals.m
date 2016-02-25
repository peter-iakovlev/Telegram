#import "TGBotSignals.h"

#import "TGDatabase.h"
#import "TGTelegramNetworking.h"

#import "TGTelegraph.h"

#import "TL/TLMetaScheme.h"
#import "TLChat$chat.h"

#import "TLUpdates+TG.h"
#import "TGUserDataRequestBuilder.h"
#import "TGMessage+Telegraph.h"
#import "TGConversation+Telegraph.h"
#import "TGConversationAddMessagesActor.h"

#import "TGPeerIdAdapter.h"

#import "TGBotContextResults.h"
#import "TGBotContextExternalResult.h"
#import "TGBotContextDocumentResult.h"
#import "TGBotContextImageResult.h"

#import "TLWebPage$webPageExternal.h"
#import "TGWebPageMediaAttachment+Telegraph.h"
#import "TGDocumentMediaAttachment+Telegraph.h"
#import "TGImageMediaAttachment+Telegraph.h"

#import "TLMessages_BotResults$botResults.h"

#import "TLWebPage_manual.h"
#import "TLBotInlineResult$botInlineResult.h"
#import "TLBotInlineMessage$botInlineMessageText.h"

#import "TGBotContextResultSendMessageAuto.h"
#import "TGBotContextResultSendMessageText.h"

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
        
        return [[TGBotReplyMarkup alloc] initWithUserId:userId messageId:messageId rows:rows matchDefaultHeight:(concreteMarkup.flags & (1 << 0)) == 0 hideKeyboardOnActivation:(concreteMarkup.flags & (1 << 1)) != 0 alreadyActivated:false manuallyHidden:false];
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
    startBot.peer = [TGTelegraphInstance createInputPeerForConversation:userId accessHash:0];
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

+ (SSignal *)botInviteUserId:(int32_t)userId toPeerId:(int64_t)peerId accessHash:(int64_t)accessHash payload:(NSString *)payload {
    TLRPCmessages_startBot$messages_startBot *startBot = [[TLRPCmessages_startBot$messages_startBot alloc] init];
    startBot.bot = [TGTelegraphInstance createInputUserForUid:userId];
    startBot.peer = [TGTelegraphInstance createInputPeerForConversation:peerId accessHash:accessHash];
    int64_t randomId = 0;
    arc4random_buf(&randomId, 8);
    startBot.random_id = randomId;
    startBot.start_param = payload;
    
    return [[[TGTelegramNetworking instance] requestSignal:startBot] map:^id(TLUpdates *updates)
    {
        [TGUserDataRequestBuilder executeUserDataUpdate:updates.users];
        
        NSMutableArray<TGConversation *> *channelConversations = [[NSMutableArray alloc] init];
        for (TLChat *chat in [updates chats]) {
            TGConversation *conversation = [[TGConversation alloc] initWithTelegraphChatDesc:chat];
            if (conversation.isChannel) {
                [channelConversations addObject:conversation];
            }
        }
        
        if (channelConversations.count != 0) {
            [TGDatabaseInstance() updateChannels:channelConversations];
        }
        
        if (!TGPeerIdIsChannel(peerId)) {
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
        }
        
        [[TGTelegramNetworking instance] addUpdates:updates];
        
        return nil;
    }];
}

+ (SSignal *)botContextResultForUserId:(int32_t)userId query:(NSString *)query offset:(NSString *)offset {
    return [[TGDatabaseInstance() modify:^id{
        return [TGDatabaseInstance() loadUser:userId];
    }] mapToSignal:^SSignal *(TGUser *user) {
        if (user != nil) {
            TLRPCmessages_getInlineBotResults$messages_getInlineBotResults *getContextBotResults = [[TLRPCmessages_getInlineBotResults$messages_getInlineBotResults alloc] init];
            TLInputUser$inputUser *inputUser = [[TLInputUser$inputUser alloc] init];
            inputUser.user_id = user.uid;
            inputUser.access_hash = user.phoneNumberHash;
            getContextBotResults.bot = inputUser;
            getContextBotResults.query = query;
            getContextBotResults.offset = offset;
            return [[[TGTelegramNetworking instance] requestSignal:getContextBotResults] map:^id(TLMessages_BotResults$botResults *result) {
                NSMutableArray *array = [[NSMutableArray alloc] init];
                
                for (TLBotInlineResult *item in result.results) {
                    if ([item isKindOfClass:[TLBotInlineResult$botInlineMediaResultDocument class]]) {
                        TLBotInlineResult$botInlineMediaResultDocument *concreteResult = (TLBotInlineResult$botInlineMediaResultDocument *)item;
                        TGDocumentMediaAttachment *document = [[TGDocumentMediaAttachment alloc] initWithTelegraphDocumentDesc:concreteResult.document];
                        if (document.documentId != 0) {
                            [array addObject:[[TGBotContextDocumentResult alloc] initWithQueryId:result.query_id resultId:concreteResult.n_id type:concreteResult.type document:document sendMessage:[self parseBotContextSendMessage:concreteResult.send_message]]];
                        }
                    } else if ([item isKindOfClass:[TLBotInlineResult$botInlineMediaResultPhoto class]]) {
                        TLBotInlineResult$botInlineMediaResultPhoto *concreteResult = (TLBotInlineResult$botInlineMediaResultPhoto *)item;
                        TGImageMediaAttachment *image = [[TGImageMediaAttachment alloc] initWithTelegraphDesc:concreteResult.photo];
                        if (image.imageId != 0) {
                            [array addObject:[[TGBotContextImageResult alloc] initWithQueryId:result.query_id resultId:concreteResult.n_id type:concreteResult.type image:image sendMessage:[self parseBotContextSendMessage:concreteResult.send_message]]];
                        }
                    } else if ([item isKindOfClass:[TLBotInlineResult$botInlineResult class]]) {
                        TLBotInlineResult$botInlineResult *concreteResult = (TLBotInlineResult$botInlineResult *)item;
                        [array addObject:[[TGBotContextExternalResult alloc] initWithQueryId:result.query_id resultId:concreteResult.n_id sendMessage:[self parseBotContextSendMessage:concreteResult.send_message] url:concreteResult.url displayUrl:concreteResult.url type:concreteResult.type title:concreteResult.title pageDescription:concreteResult.n_description thumbUrl:concreteResult.thumb_url originalUrl:concreteResult.content_url contentType:concreteResult.content_type size:CGSizeMake(concreteResult.w, concreteResult.h) duration:concreteResult.duration]];
                    }
                }
                
                return [[TGBotContextResults alloc] initWithUserId:userId isMedia:result.isMedia query:query nextOffset:result.next_offset results:array];
            }];
        } else {
            return [SSignal fail:nil];
        }
    }];
}
                        
+ (id)parseBotContextSendMessage:(TLBotInlineMessage *)message {
    if ([message isKindOfClass:[TLBotInlineMessage$botInlineMessageMediaAuto class]]) {
        return [[TGBotContextResultSendMessageAuto alloc] initWithCaption:((TLBotInlineMessage$botInlineMessageMediaAuto *)message).caption];
    } else if ([message isKindOfClass:[TLBotInlineMessage$botInlineMessageText class]]) {
        TLBotInlineMessage$botInlineMessageText *concreteMessage = (TLBotInlineMessage$botInlineMessageText *)message;
        return [[TGBotContextResultSendMessageText alloc] initWithMessage:concreteMessage.message entities:[TGMessage parseTelegraphEntities:concreteMessage.entities] noWebpage:concreteMessage.no_webpage];
    }
    return nil;
}

@end
