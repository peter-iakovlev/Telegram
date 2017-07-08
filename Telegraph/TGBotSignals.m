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
#import "TGBotContextMediaResult.h"

#import "TLWebPage$webPageExternal.h"
#import "TGWebPageMediaAttachment+Telegraph.h"
#import "TGDocumentMediaAttachment+Telegraph.h"
#import "TGImageMediaAttachment+Telegraph.h"

#import "TLMessages_BotResults$botResults.h"

#import "TLWebPage_manual.h"
#import "TLBotInlineResult$botInlineResult.h"

#import "TLBotInlineMessage$botInlineMessageMediaAuto.h"
#import "TLBotInlineMessage$botInlineMessageText.h"
#import "TLBotInlineMessage$botInlineMessageMediaGeo.h"
#import "TLBotInlineMessage$botInlineMessageMediaVenue.h"
#import "TLBotInlineMessage$botInlineMessageMediaContact.h"

#import "TGBotContextResultSendMessageAuto.h"
#import "TGBotContextResultSendMessageText.h"
#import "TGBotContextResultSendMessageGeo.h"
#import "TGBotContextResultSendMessageContact.h"

#import "TLUserFull$userFull.h"

#import "TLmessages_BotCallbackAnswer$botCallbackAnswer.h"

#import "TLRPCmessages_getInlineBotResults.h"

#import "TGLocationSignals.h"

#import "TLBotInlineResult$botInlineMediaResult.h"

#import "TGStringUtils.h"

#import "TGAppDelegate.h"
#import "TGAlertView.h"

#import "TLRPCmessages_getBotCallbackAnswer.h"
#import "TLRPCmessages_sendMedia_manual.h"

#import "TLpayments_PaymentForm$payments_paymentForm.h"
#import "TLInvoice$invoice.h"
#import "TLpayments_SavedInfo$payments_savedInfo.h"
#import "TLPaymentRequestedInfo$paymentRequestedInfo.h"
#import "TLPayments_sendPaymentForm.h"

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
        TGBotInfo *botInfo = [[TGBotInfo alloc] initWithVersion:INT32_MAX shortDescription:nil botDescription:concreteBotInfo.n_description commandList:commands];
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
                id<NSCoding, PSCoding> action = nil;
                
                if ([button isKindOfClass:[TLKeyboardButton$keyboardButtonUrl class]]) {
                    action = [[TGBotReplyMarkupButtonActionUrl alloc] initWithUrl:((TLKeyboardButton$keyboardButtonUrl *)button).url];
                } else if ([button isKindOfClass:[TLKeyboardButton$keyboardButtonCallback class]]) {
                    action = [[TGBotReplyMarkupButtonActionCallback alloc] initWithData:((TLKeyboardButton$keyboardButtonCallback *)button).data];
                } else if ([button isKindOfClass:[TLKeyboardButton$keyboardButtonRequestPhone class]]) {
                    action = [[TGBotReplyMarkupButtonActionRequestPhone alloc] init];
                } else if ([button isKindOfClass:[TLKeyboardButton$keyboardButtonRequestGeoLocation class]]) {
                    action = [[TGBotReplyMarkupButtonActionRequestLocation alloc] init];
                } else if ([button isKindOfClass:[TLKeyboardButton$keyboardButtonSwitchInline class]]) {
                    action = [[TGBotReplyMarkupButtonActionSwitchInline alloc] initWithQuery:((TLKeyboardButton$keyboardButtonSwitchInline *)button).query samePeer:((TLKeyboardButton$keyboardButtonSwitchInline *)button).flags & (1 << 0)];
                } else if ([button isKindOfClass:[TLKeyboardButton$keyboardButtonGame class]]) {
                    TLKeyboardButton$keyboardButtonGame *gameButton = (TLKeyboardButton$keyboardButtonGame *)button;
                    action = [[TGBotReplyMarkupButtonActionGame alloc] initWithText:gameButton.text];
                } else if ([button isKindOfClass:[TLKeyboardButton$keyboardButtonBuy class]]) {
                    TLKeyboardButton$keyboardButtonBuy *purchaseButton = (TLKeyboardButton$keyboardButtonBuy *)button;
                    action = [[TGBotReplyMarkupButtonActionPurchase alloc] initWithText:purchaseButton.text];
                }
                
                [buttons addObject:[[TGBotReplyMarkupButton alloc] initWithText:button.text action:action]];
            }
            [rows addObject:[[TGBotReplyMarkupRow alloc] initWithButtons:buttons]];
        }
        
        if (onlyIfRelevantToUser)
            *onlyIfRelevantToUser = concreteMarkup.flags & (1 << 2);
        
        return [[TGBotReplyMarkup alloc] initWithUserId:userId messageId:messageId rows:rows matchDefaultHeight:(concreteMarkup.flags & (1 << 0)) == 0 hideKeyboardOnActivation:(concreteMarkup.flags & (1 << 1)) != 0 alreadyActivated:false manuallyHidden:false isInline:false];
    }
    else if ([markup isKindOfClass:[TLReplyMarkup$replyInlineMarkup class]]) {
        TLReplyMarkup$replyInlineMarkup *concreteMarkup = (TLReplyMarkup$replyInlineMarkup *)markup;
        
        NSMutableArray *rows = [[NSMutableArray alloc] init];
        for (TLKeyboardButtonRow *rowInfo in concreteMarkup.rows)
        {
            NSMutableArray *buttons = [[NSMutableArray alloc] init];
            for (TLKeyboardButton *button in rowInfo.buttons)
            {
                id<NSCoding, PSCoding> action = nil;
                
                if ([button isKindOfClass:[TLKeyboardButton$keyboardButtonUrl class]]) {
                    action = [[TGBotReplyMarkupButtonActionUrl alloc] initWithUrl:((TLKeyboardButton$keyboardButtonUrl *)button).url];
                } else if ([button isKindOfClass:[TLKeyboardButton$keyboardButtonCallback class]]) {
                    action = [[TGBotReplyMarkupButtonActionCallback alloc] initWithData:((TLKeyboardButton$keyboardButtonCallback *)button).data];
                } else if ([button isKindOfClass:[TLKeyboardButton$keyboardButtonRequestPhone class]]) {
                    action = [[TGBotReplyMarkupButtonActionRequestPhone alloc] init];
                } else if ([button isKindOfClass:[TLKeyboardButton$keyboardButtonRequestGeoLocation class]]) {
                    action = [[TGBotReplyMarkupButtonActionRequestLocation alloc] init];
                } else if ([button isKindOfClass:[TLKeyboardButton$keyboardButtonSwitchInline class]]) {
                    action = [[TGBotReplyMarkupButtonActionSwitchInline alloc] initWithQuery:((TLKeyboardButton$keyboardButtonSwitchInline *)button).query samePeer:((TLKeyboardButton$keyboardButtonSwitchInline *)button).flags & (1 << 0)];
                } else if ([button isKindOfClass:[TLKeyboardButton$keyboardButtonGame class]]) {
                    TLKeyboardButton$keyboardButtonGame *gameButton = (TLKeyboardButton$keyboardButtonGame *)button;
                    action = [[TGBotReplyMarkupButtonActionGame alloc] initWithText:gameButton.text];
                } else if ([button isKindOfClass:[TLKeyboardButton$keyboardButtonBuy class]]) {
                    TLKeyboardButton$keyboardButtonBuy *purchaseButton = (TLKeyboardButton$keyboardButtonBuy *)button;
                    action = [[TGBotReplyMarkupButtonActionPurchase alloc] initWithText:purchaseButton.text];
                }
                
                [buttons addObject:[[TGBotReplyMarkupButton alloc] initWithText:button.text action:action]];
            }
            [rows addObject:[[TGBotReplyMarkupRow alloc] initWithButtons:buttons]];
        }
        
        return [[TGBotReplyMarkup alloc] initWithUserId:userId messageId:messageId rows:rows matchDefaultHeight:false hideKeyboardOnActivation:false alreadyActivated:false manuallyHidden:false isInline:true];
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
        SSignal *remote = [[[TGTelegramNetworking instance] requestSignal:getFullUser] mapToSignal:^SSignal *(TLUserFull$userFull *result)
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
                
                [TGDatabaseInstance() transactionAddMessages:@[message] updateConversationDatas:chats notifyAdded:true];
            }
        }
        
        [[TGTelegramNetworking instance] addUpdates:updates];
        
        return nil;
    }];
}

+ (SSignal *)userLocationForInlineBot:(int32_t)userId {
    return [[SSignal defer:^SSignal *{
        static NSMutableDictionary *disabledTimestamps = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            disabledTimestamps = [[NSMutableDictionary alloc] init];
        });
        
        NSTimeInterval disabledTimestamp = 0.0;
        @synchronized (disabledTimestamps) {
            disabledTimestamp = [disabledTimestamps[@(userId)] doubleValue];
        }
        
        NSData *data = [TGDatabaseInstance() conversationCustomPropertySync:userId name:murMurHash32(@"botLocationAccessGranted")];
        
        if (data != nil) {
            return [SSignal single:@true];
        } else if (disabledTimestamp > CFAbsoluteTimeGetCurrent() - 10.0 * 60.0) {
            return [SSignal single:@false];
        } else {
            return [[[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber) {
                [TGAlertView presentAlertWithTitle:TGLocalized(@"Conversation.ShareBotLocationConfirmationTitle") message:TGLocalized(@"Conversation.ShareInlineBotLocationConfirmation") cancelButtonTitle:TGLocalized(@"Common.Cancel") okButtonTitle:TGLocalized(@"Common.OK") completionBlock:^(bool okButtonPressed) {
                    if (okButtonPressed) {
                        int8_t one = 1;
                        [TGDatabaseInstance() setConversationCustomProperty:userId name:murMurHash32(@"botLocationAccessGranted") value:[NSData dataWithBytes:&one length:1]];
                        [subscriber putNext:@true];
                        [subscriber putCompletion];
                    } else {
                        @synchronized (disabledTimestamps) {
                            disabledTimestamps[@(userId)] = @(CFAbsoluteTimeGetCurrent());
                        }
                        [subscriber putNext:@false];
                        [subscriber putCompletion];
                    }
                }];
                
                return nil;
            }] startOn:[SQueue mainQueue]];
        }
    }] mapToSignal:^SSignal *(id next) {
        if ([next boolValue]) {
            SVariable *locationRequired = [[SVariable alloc] init];
            [locationRequired set:[SSignal single:@true]];
            return [TGLocationSignals userLocation:locationRequired];
        } else {
            return [SSignal single:nil];
        }
    }];
}

+ (SSignal *)botContextResultForUserId:(int32_t)userId peerId:(int64_t)peerId accessHash:(int64_t)accessHash query:(NSString *)query geoPoint:(SSignal *)__unused geoPoint offset:(NSString *)offset {
    return [[TGDatabaseInstance() modify:^id{
        return [TGDatabaseInstance() loadUser:userId];
    }] mapToSignal:^SSignal *(TGUser *user) {
        if (user != nil) {
            SSignal *geoSignal = [SSignal single:nil];
            if (user.botInlineGeo) {
                geoSignal = [[self userLocationForInlineBot:userId] take:1];
            }
            return [geoSignal mapToSignal:^SSignal *(CLLocation *location) {
                TLRPCmessages_getInlineBotResults *getContextBotResults = [[TLRPCmessages_getInlineBotResults alloc] init];
                TLInputUser$inputUser *inputUser = [[TLInputUser$inputUser alloc] init];
                inputUser.user_id = user.uid;
                inputUser.access_hash = user.phoneNumberHash;
                if (peerId != 0) {
                    getContextBotResults.peer = [TGTelegraphInstance createInputPeerForConversation:peerId accessHash:accessHash];
                } else {
                    getContextBotResults.peer = [[TLInputPeer$inputPeerEmpty alloc] init];
                }
                getContextBotResults.bot = inputUser;
                getContextBotResults.query = query;
                getContextBotResults.offset = offset;
                if (location != nil) {
                    getContextBotResults.flags |= (1 << 0);
                    TLInputGeoPoint$inputGeoPoint *geoPoint = [[TLInputGeoPoint$inputGeoPoint alloc] init];
                    geoPoint.lat = location.coordinate.latitude;
                    geoPoint.n_long = location.coordinate.longitude;
                    getContextBotResults.geo_point = geoPoint;
                }
                
                return [[TGDatabaseInstance() modify:^id {
                    NSMutableData *request = [[NSMutableData alloc] init];
                    int32_t magic = 0x751236f4;
                    [request appendBytes:&magic length:4];
                    int32_t userId = user.uid;
                    [request appendBytes:&userId length:4];
                    int64_t localPeerId = peerId;
                    [request appendBytes:&localPeerId length:8];
                    [request appendData:[query dataUsingEncoding:NSUTF8StringEncoding]];
                    [request appendData:[offset dataUsingEncoding:NSUTF8StringEncoding]];
                    
                    NSData *response = location != nil ? nil : [TGDatabaseInstance() _cachedBotCallbackResponse:request];
                    TGBotContextResults *result = nil;
                    @try {
                        if (response != nil) {
                            NSDictionary *maybeResult = [NSKeyedUnarchiver unarchiveObjectWithData:response];
                            if ([maybeResult respondsToSelector:@selector(objectForKey:)]) {
                                if ([maybeResult[@"result"] isKindOfClass:[TGBotContextResults class]]) {
                                    int32_t timestamp = (int32_t)[[TGTelegramNetworking instance] approximateRemoteTime];
                                    if (maybeResult[@"cacheTime"] != nil && maybeResult[@"cacheTimestamp"] != nil && timestamp <= ([maybeResult[@"cacheTimestamp"] intValue] + [maybeResult[@"cacheTime"] intValue])) {
                                        result = maybeResult[@"result"];
                                    }
                                }
                            }
                        }
                    } @catch (__unused NSException *e) {
                    }
                    
                    if (result != nil) {
                        return [SSignal single:result];
                    }
                    
                    SSignal *ensuredGeoSignal = [[[TGTelegramNetworking instance] requestSignal:getContextBotResults] catch:^SSignal *(id error) {
                        NSString *errorType = [[TGTelegramNetworking instance] extractNetworkErrorType:error];
                        if ([errorType isEqual:@"BOT_INLINE_GEO_REQUIRED"]) {
                            SSignal *geoSignal = [[self userLocationForInlineBot:userId] take:1];
                            return [geoSignal mapToSignal:^SSignal *(CLLocation *location) {
                                TLRPCmessages_getInlineBotResults *getContextBotResults = [[TLRPCmessages_getInlineBotResults alloc] init];
                                TLInputUser$inputUser *inputUser = [[TLInputUser$inputUser alloc] init];
                                inputUser.user_id = user.uid;
                                inputUser.access_hash = user.phoneNumberHash;
                                getContextBotResults.bot = inputUser;
                                getContextBotResults.query = query;
                                getContextBotResults.offset = offset;
                                if (location != nil) {
                                    getContextBotResults.flags |= (1 << 0);
                                    TLInputGeoPoint$inputGeoPoint *geoPoint = [[TLInputGeoPoint$inputGeoPoint alloc] init];
                                    geoPoint.lat = location.coordinate.latitude;
                                    geoPoint.n_long = location.coordinate.longitude;
                                    getContextBotResults.geo_point = geoPoint;
                                }
                                return [[TGTelegramNetworking instance] requestSignal:getContextBotResults];
                            }];
                        }
                        return [SSignal fail:error];
                    }];
                    
                    return [ensuredGeoSignal map:^id(TLMessages_BotResults$botResults *result) {
                        NSMutableArray *array = [[NSMutableArray alloc] init];
                        
                        for (TLBotInlineResult *item in result.results) {
                            if ([item isKindOfClass:[TLBotInlineResult$botInlineMediaResult class]]) {
                                TLBotInlineResult$botInlineMediaResult *concreteResult = (TLBotInlineResult$botInlineMediaResult *)item;
                                
                                TGImageMediaAttachment *photo = nil;
                                if (concreteResult.photo != nil) {
                                    photo = [[TGImageMediaAttachment alloc] initWithTelegraphDesc:concreteResult.photo];
                                }
                                
                                TGDocumentMediaAttachment *document = nil;
                                if (concreteResult.document != nil) {
                                    document = [[TGDocumentMediaAttachment alloc] initWithTelegraphDocumentDesc:concreteResult.document];
                                }
                                
                                [array addObject:[[TGBotContextMediaResult alloc] initWithQueryId:result.query_id resultId:concreteResult.n_id type:concreteResult.type photo:photo document:document title:concreteResult.title resultDescription:concreteResult.n_description sendMessage:[self parseBotContextSendMessage:concreteResult.send_message]]];
                            } else if ([item isKindOfClass:[TLBotInlineResult$botInlineResult class]]) {
                                TLBotInlineResult$botInlineResult *concreteResult = (TLBotInlineResult$botInlineResult *)item;
                                [array addObject:[[TGBotContextExternalResult alloc] initWithQueryId:result.query_id resultId:concreteResult.n_id sendMessage:[self parseBotContextSendMessage:concreteResult.send_message] url:concreteResult.url displayUrl:concreteResult.url type:concreteResult.type title:concreteResult.title pageDescription:concreteResult.n_description thumbUrl:concreteResult.thumb_url originalUrl:concreteResult.content_url contentType:concreteResult.content_type size:CGSizeMake(concreteResult.w, concreteResult.h) duration:concreteResult.duration]];
                            }
                        }
                        
                        TGBotContextResultsSwitchPm *switchPm = nil;
                        if (result.switch_pm != nil) {
                            switchPm = [[TGBotContextResultsSwitchPm alloc] initWithText:result.switch_pm.text startParam:result.switch_pm.start_param];
                        }
                        
                        TGBotContextResults *apiResults = [[TGBotContextResults alloc] initWithUserId:userId peerId:peerId accessHash:accessHash isMedia:result.isMedia query:query nextOffset:result.next_offset results:array switchPm:switchPm];
                        
                        if (location == nil && result.cache_time > 0) {
                            @try {
                                int32_t cacheTime = result.cache_time;
                                int32_t timestamp = (int32_t)[[TGTelegramNetworking instance] approximateRemoteTime];
                                NSData *data = [NSKeyedArchiver archivedDataWithRootObject:@{@"result": apiResults, @"cacheTimestamp": @(timestamp), @"cacheTime": @(cacheTime)}];
                                [TGDatabaseInstance() cacheBotCallbackResponse:request response:data];
                            } @catch(__unused NSException *e) {
                            }
                        }
                        
                        return apiResults;
                    }];
                }] switchToLatest];
            }];
        } else {
            return [SSignal fail:nil];
        }
    }];
}
            
+ (id)parseBotContextSendMessage:(TLBotInlineMessage *)message {
    if ([message isKindOfClass:[TLBotInlineMessage$botInlineMessageMediaAuto class]]) {
        TLBotInlineMessage$botInlineMessageMediaAuto *concreteMessage = ((TLBotInlineMessage$botInlineMessageMediaAuto *)message);
        TGBotReplyMarkup *replyMarkup = nil;
        if (concreteMessage.reply_markup != nil) {
            replyMarkup = [self botReplyMarkupForMarkup:concreteMessage.reply_markup userId:0 messageId:0 hidePreviousMarkup:NULL forceReply:NULL onlyIfRelevantToUser:NULL];
        }
        return [[TGBotContextResultSendMessageAuto alloc] initWithCaption:((TLBotInlineMessage$botInlineMessageMediaAuto *)message).caption replyMarkup:replyMarkup];
    } else if ([message isKindOfClass:[TLBotInlineMessage$botInlineMessageText class]]) {
        TLBotInlineMessage$botInlineMessageText *concreteMessage = (TLBotInlineMessage$botInlineMessageText *)message;
        TGBotReplyMarkup *replyMarkup = nil;
        if (concreteMessage.reply_markup != nil) {
            replyMarkup = [self botReplyMarkupForMarkup:concreteMessage.reply_markup userId:0 messageId:0 hidePreviousMarkup:NULL forceReply:NULL onlyIfRelevantToUser:NULL];
        }
        return [[TGBotContextResultSendMessageText alloc] initWithMessage:concreteMessage.message entities:[TGMessage parseTelegraphEntities:concreteMessage.entities] noWebpage:concreteMessage.no_webpage replyMarkup:replyMarkup];
    } else if ([message isKindOfClass:[TLBotInlineMessage$botInlineMessageMediaGeo class]]) {
        TLBotInlineMessage$botInlineMessageMediaGeo *concreteMessage = (TLBotInlineMessage$botInlineMessageMediaGeo *)message;
        TGLocationMediaAttachment *locationMediaAttachment = [[TGLocationMediaAttachment alloc] init];
        if ([concreteMessage.geo_point isKindOfClass:[TLGeoPoint$geoPoint class]]) {
            TLGeoPoint$geoPoint *concreteGeo = (TLGeoPoint$geoPoint *)concreteMessage.geo_point;
            locationMediaAttachment.latitude = concreteGeo.lat;
            locationMediaAttachment.longitude = concreteGeo.n_long;
            
            TGBotReplyMarkup *replyMarkup = nil;
            if (concreteMessage.reply_markup != nil) {
                replyMarkup = [self botReplyMarkupForMarkup:concreteMessage.reply_markup userId:0 messageId:0 hidePreviousMarkup:NULL forceReply:NULL onlyIfRelevantToUser:NULL];
            }
            
            return [[TGBotContextResultSendMessageGeo alloc] initWithLocation:locationMediaAttachment replyMarkup:replyMarkup];
        }
    } else if ([message isKindOfClass:[TLBotInlineMessage$botInlineMessageMediaVenue class]]) {
        TLBotInlineMessage$botInlineMessageMediaVenue *concreteMessage = (TLBotInlineMessage$botInlineMessageMediaVenue *)message;
        TGLocationMediaAttachment *locationMediaAttachment = [[TGLocationMediaAttachment alloc] init];
        if ([concreteMessage.geo_point isKindOfClass:[TLGeoPoint$geoPoint class]]) {
            TLGeoPoint$geoPoint *concreteGeo = (TLGeoPoint$geoPoint *)concreteMessage.geo_point;
            
            locationMediaAttachment.latitude = concreteGeo.lat;
            locationMediaAttachment.longitude = concreteGeo.n_long;
            
            TGVenueAttachment *venue = [[TGVenueAttachment alloc] initWithTitle:concreteMessage.title address:concreteMessage.address provider:concreteMessage.provider venueId:concreteMessage.venue_id];
            
            locationMediaAttachment.venue = venue;
            
            TGBotReplyMarkup *replyMarkup = nil;
            if (concreteMessage.reply_markup != nil) {
                replyMarkup = [self botReplyMarkupForMarkup:concreteMessage.reply_markup userId:0 messageId:0 hidePreviousMarkup:NULL forceReply:NULL onlyIfRelevantToUser:NULL];
            }
            
            return [[TGBotContextResultSendMessageGeo alloc] initWithLocation:locationMediaAttachment replyMarkup:replyMarkup];
        }
    } else if ([message isKindOfClass:[TLBotInlineMessage$botInlineMessageMediaContact class]]) {
        TLBotInlineMessage$botInlineMessageMediaContact *concreteMessage = (TLBotInlineMessage$botInlineMessageMediaContact *)message;
        TGContactMediaAttachment *contactAttachment = [[TGContactMediaAttachment alloc] init];
        contactAttachment.firstName = concreteMessage.first_name;
        contactAttachment.lastName = concreteMessage.last_name;
        contactAttachment.phoneNumber = concreteMessage.phone_number;
        
        TGBotReplyMarkup *replyMarkup = nil;
        if (concreteMessage.reply_markup != nil) {
            replyMarkup = [self botReplyMarkupForMarkup:concreteMessage.reply_markup userId:0 messageId:0 hidePreviousMarkup:NULL forceReply:NULL onlyIfRelevantToUser:NULL];
        }
        
        return [[TGBotContextResultSendMessageContact alloc] initWithContact:contactAttachment replyMarkup:replyMarkup];
    }
    return nil;
}

+ (SSignal *)botCallback:(int64_t)conversationId accessHash:(int64_t)accessHash messageId:(int32_t)messageId data:(NSData *)data isGame:(bool)isGame {
    return [[TGDatabaseInstance() modify:^id{
        NSMutableData *request = [[NSMutableData alloc] init];
        int64_t peerId = conversationId;
        int64_t localAccessHash = accessHash;
        int32_t localMessageId = messageId;
        [request appendBytes:&peerId length:8];
        [request appendBytes:&localAccessHash length:8];
        [request appendBytes:&localMessageId length:4];
        if (data != nil) {
            [request appendData:data];
        }
        int8_t localIsGame = isGame ? 1 : 0;
        [request appendBytes:&localIsGame length:1];
        NSData *response = [TGDatabaseInstance() _cachedBotCallbackResponse:request];
        NSDictionary *result = nil;
        if (response != nil) {
            @try {
                NSDictionary *maybeResult = [NSKeyedUnarchiver unarchiveObjectWithData:response];
                if ([maybeResult respondsToSelector:@selector(objectForKey:)]) {
                    int32_t timestamp = (int32_t)[[TGTelegramNetworking instance] approximateRemoteTime];
                    if (maybeResult[@"cacheTime"] != nil && maybeResult[@"cacheTimestamp"] != nil && timestamp <= [maybeResult[@"cacheTimestamp"] intValue] + [maybeResult[@"cacheTime"] intValue]) {
                        result = maybeResult;
                    }
                }
            } @catch(__unused NSException *e) {
            }
        }
        if (result != nil) {
            return [SSignal single:result];
        } else {
            TLRPCmessages_getBotCallbackAnswer *getBotCallbackAnswer = [[TLRPCmessages_getBotCallbackAnswer alloc] init];
            getBotCallbackAnswer.peer = [TGTelegraphInstance createInputPeerForConversation:conversationId accessHash:accessHash];
            getBotCallbackAnswer.msg_id = messageId;
            getBotCallbackAnswer.data = data;
            getBotCallbackAnswer.game = isGame;
            return [[[TGTelegramNetworking instance] requestSignal:getBotCallbackAnswer continueOnServerErrors:false failOnFloodErrors:false failOnServerErrorsImmediately:true] map:^id(TLmessages_BotCallbackAnswer$botCallbackAnswer *result) {
                NSDictionary *response = @{@"text": result.message == nil ? @"" : result.message, @"alert": @(result.alert), @"url": result.url == nil ? @"" : result.url, @"cacheTimestamp": @((int32_t)[[TGTelegramNetworking instance] approximateRemoteTime]), @"cacheTime": @(result.cache_time)};
                if (result.cache_time > 0) {
                    [TGDatabaseInstance() cacheBotCallbackResponse:request response:[NSKeyedArchiver archivedDataWithRootObject:response]];
                }
                return response;
            }];
        }
    }] switchToLatest];
}

+ (TLInputPeer *)inputPeerWithPeerId:(int64_t)peerId {
    if (TGPeerIdIsUser(peerId)) {
        TGUser *user = [TGDatabaseInstance() loadUser:(int32_t)peerId];
        if (user != nil) {
            TLInputPeer$inputPeerUser *inputPeerUser = [[TLInputPeer$inputPeerUser alloc] init];
            inputPeerUser.user_id = user.uid;
            inputPeerUser.access_hash = user.phoneNumberHash;
            return inputPeerUser;
        }
    } else {
        TGConversation *conversation = [TGDatabaseInstance() loadConversationWithId:peerId];
        if (conversation != nil) {
            if (TGPeerIdIsChannel(peerId)) {
                TLInputPeer$inputPeerChannel *inputPeerChannel = [[TLInputPeer$inputPeerChannel alloc] init];
                inputPeerChannel.channel_id = TGChannelIdFromPeerId(peerId);
                inputPeerChannel.access_hash = conversation.accessHash;
                return inputPeerChannel;
            } else{
                TLInputPeer$inputPeerChat *inputPeerChat = [[TLInputPeer$inputPeerChat alloc] init];
                inputPeerChat.chat_id = TGGroupIdFromPeerId(peerId);
                return inputPeerChat;
            }
        }
    }
    return nil;
}

+ (SSignal *)shareBotGame:(int64_t)fromPeerId messageId:(int32_t)messageId toPeerId:(int64_t)peerId withScore:(bool)withScore {
    return [[TGDatabaseInstance() modify:^id{
        TLInputPeer *fromPeer = [self inputPeerWithPeerId:fromPeerId];
        TLInputPeer *toPeer = [self inputPeerWithPeerId:peerId];
        
        if (fromPeer != nil && toPeer != nil) {
            return @[fromPeer, toPeer];
        } else {
            return nil;
        }
    }] mapToSignal:^SSignal *(NSArray *peers) {
        if (peers == nil) {
            return [SSignal fail:nil];
        } else {
            TLRPCmessages_forwardMessages$messages_forwardMessages *forwardMessages = [[TLRPCmessages_forwardMessages$messages_forwardMessages alloc] init];
            /*
             @property (nonatomic) int32_t flags;
             @property (nonatomic, retain) TLInputPeer *from_peer;
             @property (nonatomic, retain) NSArray *n_id;
             @property (nonatomic, retain) NSArray *random_id;
             @property (nonatomic, retain) TLInputPeer *to_peer;
             */
            forwardMessages.flags |= (withScore ? (1 << 8) : 0);
            forwardMessages.from_peer = peers[0];
            forwardMessages.n_id = @[@(messageId)];
            int64_t randomId = 0;
            arc4random_buf(&randomId, 8);
            forwardMessages.random_id = @[@(randomId)];
            forwardMessages.to_peer = peers[1];
            
            return [[[TGTelegramNetworking instance] requestSignal:forwardMessages] mapToQueue:^SSignal *(TLUpdates *updates) {
                [[TGTelegramNetworking instance] addUpdates:updates];
                return [SSignal complete];
            }];
        }
    }];
}

+ (SSignal *)sendBotGame:(NSString *)shortName toPeerId:(int64_t)peerId botId:(int32_t)botId {
    return [[TGDatabaseInstance() modify:^id{
        TLInputPeer *toPeer = [self inputPeerWithPeerId:peerId];
        TLInputUser *botUser = [TGTelegraphInstance createInputUserForUid:botId];
        if (toPeer == nil || botUser == nil) {
            return nil;
        } else {
            return @[toPeer, botUser];
        }
    }] mapToSignal:^SSignal *(NSArray *peers) {
        if (peers == nil) {
            return [SSignal fail:nil];
        } else {
            TLInputPeer *toPeer = peers[0];
            TLInputUser *botUser = peers[1];
            
            TLRPCmessages_sendMedia_manual *sendMedia = [[TLRPCmessages_sendMedia_manual alloc] init];
            sendMedia.peer = toPeer;
            int64_t randomId = 0;
            arc4random_buf(&randomId, 8);
            sendMedia.random_id = randomId;
            
            TLInputMedia$inputMediaGame *inputMediaGame = [[TLInputMedia$inputMediaGame alloc] init];
            TLInputGame$inputGameShortName *inputGame = [[TLInputGame$inputGameShortName alloc] init];
            inputGame.short_name = shortName;
            inputGame.bot_id = botUser;
            inputMediaGame.n_id = inputGame;
            
            sendMedia.media = inputMediaGame;
            
            return [[[TGTelegramNetworking instance] requestSignal:sendMedia] mapToQueue:^SSignal *(TLUpdates *updates) {
                [[TGTelegramNetworking instance] addUpdates:updates];
                return [SSignal complete];
            }];
        }
    }];
}

+ (TGInvoice *)invoiceWithDesc:(TLInvoice$invoice *)invoiceDesc {
    NSMutableArray<TGInvoicePrice *> *amounts = [[NSMutableArray alloc] init];
    for (TLLabeledPrice *amount in invoiceDesc.prices) {
        [amounts addObject:[[TGInvoicePrice alloc] initWithLabel:amount.label amount:amount.amount]];
    }
    
    return [[TGInvoice alloc] initWithIsTest:invoiceDesc.test nameRequested:invoiceDesc.name_requested phoneRequested:invoiceDesc.phone_requested emailRequested:invoiceDesc.email_requested shippingAddressRequested:invoiceDesc.shipping_address_requested flexible:invoiceDesc.flexible currency:invoiceDesc.currency prices:amounts];
}

+ (TGPaymentRequestedInfo *)requestedInfoWithDesc:(TLPaymentRequestedInfo$paymentRequestedInfo *)savedInfoDesc {
    TGPostAddress *shippingAddress = nil;
    if (savedInfoDesc.shipping_address != nil) {
        TLPostAddress *postAddress = savedInfoDesc.shipping_address;
        shippingAddress = [[TGPostAddress alloc] initWithStreetLine1:postAddress.street_line1 streetLine2:postAddress.street_line2 city:postAddress.city state:postAddress.state countryIso2:postAddress.country_iso2 postCode:postAddress.post_code];
    }
    
    return [[TGPaymentRequestedInfo alloc] initWithName:savedInfoDesc.name phone:savedInfoDesc.phone email:savedInfoDesc.email shippingAddress:shippingAddress];
}

+ (SSignal *)paymentForm:(int32_t)messageId {
    TLRPCpayments_getPaymentForm$payments_getPaymentForm *getPaymentForm = [[TLRPCpayments_getPaymentForm$payments_getPaymentForm alloc] init];
    getPaymentForm.msg_id = messageId;
    return [[[TGTelegramNetworking instance] requestSignal:getPaymentForm] map:^id(TLpayments_PaymentForm$payments_paymentForm *result) {
        [TGUserDataRequestBuilder executeUserDataUpdate:result.users];
        
        TGInvoice *invoice = [self invoiceWithDesc:(TLInvoice$invoice *)result.invoice];
        
        TGPaymentRequestedInfo *savedInfo = [self requestedInfoWithDesc:(TLPaymentRequestedInfo$paymentRequestedInfo *)result.saved_info];
        
        TGPaymentSavedCredentialsCard *savedCredentials = nil;
        if (result.saved_credentials != nil) {
            TLPaymentSavedCredentials *credentials = result.saved_credentials;
            savedCredentials = [[TGPaymentSavedCredentialsCard alloc] initWithCardId:credentials.n_id title:credentials.title];
        }
        
        return [[TGPaymentForm alloc] initWithCanSaveCredentials:result.can_save_credentials passwordMissing:result.password_missing botId:result.bot_id url:result.url invoice:invoice providerId:result.provider_id nativeProvider:result.native_provider nativeParams:result.native_params.data savedInfo:savedInfo savedCredentials:savedCredentials];
    }];
}

+ (SSignal *)paymentReceipt:(int32_t)messageId {
    TLRPCpayments_getPaymentReceipt$payments_getPaymentReceipt *getPaymentReceipt = [[TLRPCpayments_getPaymentReceipt$payments_getPaymentReceipt alloc] init];
    getPaymentReceipt.msg_id = messageId;
    return [[[TGTelegramNetworking instance] requestSignal:getPaymentReceipt] map:^id(TLpayments_PaymentReceipt$payments_paymentReceiptMeta *result) {
        TGInvoice *invoice = [self invoiceWithDesc:(TLInvoice$invoice *)result.invoice];
        TGPaymentRequestedInfo *info = result.info != nil ? [self requestedInfoWithDesc:(TLPaymentRequestedInfo$paymentRequestedInfo *)result.info] : nil;
        TGShippingOption *shippingOption = result.shipping != nil ? [self shippingOptionWithDesc:result.shipping] : nil;
        
        return [[TGPaymentReceipt alloc] initWithDate:result.date botId:result.bot_id invoice:invoice providerId:result.provider_id info:info shippingOption:shippingOption currency:result.currency totalAmount:result.total_amount credentialsTitle:result.credentials_title];
    }];
}

+ (TLPaymentRequestedInfo$paymentRequestedInfo *)paymentInfoFromInfo:(TGPaymentRequestedInfo *)info {
    TLPaymentRequestedInfo$paymentRequestedInfo *requestedInfo = [[TLPaymentRequestedInfo$paymentRequestedInfo alloc] init];
    if (info.name != nil) {
        requestedInfo.flags |= (1 << 0);
        requestedInfo.name = info.name;
    }
    if (info.phone != nil) {
        requestedInfo.flags |= (1 << 1);
        requestedInfo.phone = info.phone;
    }
    if (info.email != nil) {
        requestedInfo.flags |= (1 << 2);
        requestedInfo.email = info.email;
    }
    if (info.shippingAddress != nil) {
        requestedInfo.flags |= (1 << 3);
        
        TLPostAddress$postAddress *postAddress = [[TLPostAddress$postAddress alloc] init];
        postAddress.street_line1 = info.shippingAddress.streetLine1;
        postAddress.street_line2 = info.shippingAddress.streetLine2;
        postAddress.city = info.shippingAddress.city;
        postAddress.state = info.shippingAddress.state;
        postAddress.country_iso2 = info.shippingAddress.countryIso2;
        postAddress.post_code = info.shippingAddress.postCode;
        requestedInfo.shipping_address = postAddress;
    }

    return requestedInfo;
}
            
+ (TGShippingOption *)shippingOptionWithDesc:(TLShippingOption *)option {
    NSMutableArray *prices = [[NSMutableArray alloc] init];
    for (TLLabeledPrice *price in option.prices) {
        [prices addObject:[[TGInvoicePrice alloc] initWithLabel:price.label amount:price.amount]];
    }
    return [[TGShippingOption alloc] initWithOptionId:option.n_id title:option.title prices:prices];
}

+ (SSignal *)validateRequestedPaymentInfo:(int32_t)messageId info:(TGPaymentRequestedInfo *)info saveInfo:(bool)saveInfo {
    TLRPCpayments_validateRequestedInfo$payments_validateRequestedInfo *validateInfo = [[TLRPCpayments_validateRequestedInfo$payments_validateRequestedInfo alloc] init];
    if (saveInfo) {
        validateInfo.flags |= (1 << 0);
    }
    validateInfo.msg_id = messageId;
    
    validateInfo.info = [self paymentInfoFromInfo:info];
    
    SSignal *clearInfo = [SSignal single:@true];
    if (!saveInfo) {
        TLRPCpayments_clearSavedInfo$payments_clearSavedInfo *clearSavedInfo = [[TLRPCpayments_clearSavedInfo$payments_clearSavedInfo alloc] init];
        clearSavedInfo.flags = (1 << 1);
        clearInfo = [[TGTelegramNetworking instance] requestSignal:clearSavedInfo];
    }
    
    return [[SSignal combineSignals:@[clearInfo, [[TGTelegramNetworking instance] requestSignal:validateInfo]]] map:^id(NSArray *combined) {
        TLpayments_ValidatedRequestedInfo *result = combined[1];
        NSMutableArray *shippingOptions = [[NSMutableArray alloc] init];
        for (TLShippingOption *option in result.shipping_options) {
            TGShippingOption *parsedOption = [self shippingOptionWithDesc:option];
            [shippingOptions addObject:parsedOption];
        }
        return [[TGValidatedRequestedInfo alloc] initWithInfoId:result.n_id shippingOptions:shippingOptions];
    }];
}

//payments.sendPaymentForm flags:# msg_id:int requested_info_id:flags.0?string shipping_option_id:flags.1?string credentials:InputPaymentCredentials = payments.PaymentResult;
+ (SSignal *)sendPayment:(int32_t)messageId infoId:(NSString *)infoId shippingOptionId:(NSString *)shippingOptionId credentials:(id)credentials {
    TLPayments_sendPaymentForm *sendPaymentForm = [[TLPayments_sendPaymentForm alloc] init];
    
    sendPaymentForm.msg_id = messageId;
    if (infoId != nil) {
        sendPaymentForm.flags |= (1 << 0);
        sendPaymentForm.requested_info_id = infoId;
    }
    if (shippingOptionId != nil) {
        sendPaymentForm.flags |= (1 << 1);
        sendPaymentForm.shipping_option_id = shippingOptionId;
    }
    
    if ([credentials isKindOfClass:[TGPaymentCredentialsSaved class]]) {
        TGPaymentCredentialsSaved *concreteCredentials = credentials;
        TLInputPaymentCredentials$inputPaymentCredentialsSaved *savedCredentials = [[TLInputPaymentCredentials$inputPaymentCredentialsSaved alloc] init];
        savedCredentials.n_id = concreteCredentials.cardId;
        savedCredentials.tmp_password = concreteCredentials.tmpPassword;
        sendPaymentForm.credentials = savedCredentials;
    } else if ([credentials isKindOfClass:[TGPaymentCredentialsStripeToken class]]) {
        TGPaymentCredentialsStripeToken *concreteCredentials = credentials;
        TLInputPaymentCredentials$inputPaymentCredentials *newCredentials = [[TLInputPaymentCredentials$inputPaymentCredentials alloc] init];
        TLDataJSON$dataJSON *dataJson = [[TLDataJSON$dataJSON alloc] init];
        dataJson.data = [NSString stringWithFormat:@"{\"type\": \"card\", \"id\": \"%@\"}", concreteCredentials.tokenId];
        newCredentials.data = dataJson;
        if (concreteCredentials.saveCredentials) {
            newCredentials.flags |= (1 << 0);
        }
        sendPaymentForm.credentials = newCredentials;
    } else if ([credentials isKindOfClass:[TGPaymentCredentialsWebToken class]]) {
        TGPaymentCredentialsWebToken *concreteCredentials = credentials;
        TLInputPaymentCredentials$inputPaymentCredentials *newCredentials = [[TLInputPaymentCredentials$inputPaymentCredentials alloc] init];
        TLDataJSON$dataJSON *dataJson = [[TLDataJSON$dataJSON alloc] init];
        dataJson.data = concreteCredentials.data;
        newCredentials.data = dataJson;
        if (concreteCredentials.saveCredentials) {
            newCredentials.flags |= (1 << 0);
        }
        sendPaymentForm.credentials = newCredentials;
    } else {
        return [SSignal fail:nil];
    }
    
    return [[[TGTelegramNetworking instance] requestSignal:sendPaymentForm] map:^id(TLpayments_PaymentResult *result) {
        if ([result isKindOfClass:[TLpayments_PaymentResult$payments_paymentResult class]]) {
            [[TGTelegramNetworking instance] addUpdates:((TLpayments_PaymentResult$payments_paymentResult *)result).updates];
            return nil;
        } else if ([result isKindOfClass:[TLpayments_PaymentResult$payments_paymentVerficationNeeded class]]) {
            return ((TLpayments_PaymentResult$payments_paymentVerficationNeeded *)result).url;
        } else {
            NSAssert(false, @"unexpected payment result");
            return nil;
        }
    }];
}

@end
