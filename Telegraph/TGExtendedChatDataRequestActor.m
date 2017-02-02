#import "TGExtendedChatDataRequestActor.h"

#import "ActionStage.h"
#import "SGraphObjectNode.h"

#import "TGUpdateStateRequestBuilder.h"

#import "TGUserDataRequestBuilder.h"

#import "TGTelegraph.h"

#import "TGDatabase.h"

#import "TGConversation+Telegraph.h"

#import "TGConversationAddMessagesActor.h"

#import "TGTelegramNetworking.h"

#import "TGBotSignals.h"

static NSMutableDictionary *extendedChatDataDictionary()
{
    static NSMutableDictionary *dict = nil;
    static int updateStateVersion = 0;
    
    if (dict == nil)
    {
        dict = [[NSMutableDictionary alloc] init];
        updateStateVersion = [TGUpdateStateRequestBuilder stateVersion];
    }
    else if (updateStateVersion != [TGUpdateStateRequestBuilder stateVersion])
    {
        [dict removeAllObjects];
        updateStateVersion = [TGUpdateStateRequestBuilder stateVersion];
    }
    
    return dict;
}

@interface TGExtendedChatDataRequestActor ()

@property (nonatomic) int64_t conversationId;

@end

@implementation TGExtendedChatDataRequestActor

@synthesize conversationId = _conversationId;

+ (NSString *)genericPath
{
    return @"/tg/conversationExtended/@";
}

- (void)execute:(NSDictionary *)options
{
    _conversationId = [[options objectForKey:@"conversationId"] longLongValue];
    
    TGConversation *conversation = [TGDatabaseInstance() loadConversationWithId:_conversationId];
    NSDictionary *resultDict = [extendedChatDataDictionary() objectForKey:[[NSNumber alloc] initWithLongLong:_conversationId]];
    if (resultDict != nil && conversation.chatVersion == [resultDict[@"version"] intValue])
    {
        [ActionStageInstance() nodeRetrieved:self.path node:[[SGraphObjectNode alloc] initWithObject:resultDict]];
    }
    else
    {
        self.cancelToken = [TGTelegraphInstance doRequestConversationData:_conversationId actor:self];
    }
}

- (void)chatFullRequestSuccess:(TLmessages_ChatFull *)chatFull
{
    [TGUserDataRequestBuilder executeUserDataUpdate:chatFull.users];
    
    TLPeerNotifySettings *settings = chatFull.full_chat.notify_settings;
    
    int peerSoundId = 0;
    int peerMuteUntil = 0;
    bool peerPreviewText = true;
    bool messagesMuted = false;
    
    if ([settings isKindOfClass:[TLPeerNotifySettings$peerNotifySettings class]])
    {
        TLPeerNotifySettings$peerNotifySettings *concreteSettings = (TLPeerNotifySettings$peerNotifySettings *)settings;
        peerMuteUntil = concreteSettings.mute_until;
        
        if (peerMuteUntil <= [[TGTelegramNetworking instance] approximateRemoteTime])
            peerMuteUntil = 0;

        if (concreteSettings.sound.length == 0)
            peerSoundId = 0;
        else if ([concreteSettings.sound isEqualToString:@"default"])
            peerSoundId = 1;
        else
            peerSoundId = [concreteSettings.sound intValue];
        
        peerPreviewText = concreteSettings.flags & (1 << 0);
        messagesMuted = concreteSettings.flags & (1 << 1);
    }
    
    int64_t conversationId = _conversationId;
    [TGDatabaseInstance() storePeerNotificationSettings:_conversationId soundId:peerSoundId muteUntil:peerMuteUntil previewText:peerPreviewText messagesMuted:messagesMuted writeToActionQueue:false completion:^(bool changed)
    {
        if (changed)
        {
            [ActionStageInstance() dispatchOnStageQueue:^
            {
                NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:peerMuteUntil], @"muteUntil", [NSNumber numberWithInt:peerSoundId], @"soundId", [[NSNumber alloc] initWithBool:peerPreviewText], @"previewText", [[NSNumber alloc] initWithBool:messagesMuted], @"messagesMuted", nil];
                [extendedChatDataDictionary() setObject:dict forKey:[[NSNumber alloc] initWithLongLong:conversationId]];
                
                [ActionStageInstance() dispatchResource:[NSString stringWithFormat:@"/tg/peerSettings/(%lld)", conversationId] resource:[[SGraphObjectNode alloc] initWithObject:dict]];
            }];
        }
    }];
    
    TGConversationParticipantsData *participantsData = nil;
    if ([chatFull.full_chat isKindOfClass:[TLChatFull$chatFull class]])
    {
        TLChatFull$chatFull *concreteChatFull = (TLChatFull$chatFull *)chatFull.full_chat;
        participantsData = [[TGConversationParticipantsData alloc] initWithTelegraphParticipantsDesc:concreteChatFull.participants];
    }
    
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:peerMuteUntil], @"muteUntil", [NSNumber numberWithInt:peerSoundId], @"soundId", @(participantsData.version), @"version", nil];
    [extendedChatDataDictionary() setObject:dict forKey:[[NSNumber alloc] initWithLongLong:_conversationId]];
    
    if ([chatFull.full_chat.exported_invite isKindOfClass:[TLExportedChatInvite$chatInviteExported class]])
    {
        participantsData.exportedChatInviteString = ((TLExportedChatInvite$chatInviteExported *)chatFull.full_chat.exported_invite).link;
    }
    [TGDatabaseInstance() storeConversationParticipantData:-chatFull.full_chat.n_id participantData:participantsData];
    
    if (chatFull.chats.count != 0)
    {
        TGConversation *conversation = [[TGConversation alloc] initWithTelegraphChatDesc:[chatFull.chats lastObject]];
        
        [TGDatabaseInstance() transactionAddMessages:nil updateConversationDatas:@{@(conversation.conversationId): conversation} notifyAdded:true];
    }
    
    if ([chatFull.full_chat isKindOfClass:[TLChatFull$chatFull class]])
    {
        TLChatFull$chatFull *concreteChatFull = (TLChatFull$chatFull *)chatFull.full_chat;
        if (concreteChatFull.bot_info.count != 0)
        {
            for (TLBotInfo *info in concreteChatFull.bot_info)
            {
                if ([info isKindOfClass:[TLBotInfo$botInfo class]])
                {
                    TGBotInfo *botInfo = [TGBotSignals botInfoForInfo:info];
                    if (botInfo != nil)
                        [TGDatabaseInstance() storeBotInfo:botInfo forUserId:((TLBotInfo$botInfo *)info).user_id];
                }
            }
        }
    }
    
    [ActionStageInstance() nodeRetrieved:self.path node:[[SGraphObjectNode alloc] initWithObject:dict]];
}

- (void)chatFullRequestFailed
{
    [ActionStageInstance() nodeRetrieveFailed:self.path];
}

@end
