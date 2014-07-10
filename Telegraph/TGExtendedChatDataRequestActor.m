#import "TGExtendedChatDataRequestActor.h"

#import "ActionStage.h"
#import "SGraphObjectNode.h"

#import "TGUpdateStateRequestBuilder.h"

#import "TGUserDataRequestBuilder.h"

#import "TGTelegraph.h"

#import "TGDatabase.h"

#import "TGConversation+Telegraph.h"

#import "TGConversationAddMessagesActor.h"

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
    
    NSDictionary *resultDict = [extendedChatDataDictionary() objectForKey:[[NSNumber alloc] initWithLongLong:_conversationId]];
    if (resultDict != nil)
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
    bool photoNotificationsEnabled = true;
    
    if ([settings isKindOfClass:[TLPeerNotifySettings$peerNotifySettings class]])
    {
        TLPeerNotifySettings$peerNotifySettings *concreteSettings = (TLPeerNotifySettings$peerNotifySettings *)settings;
        peerMuteUntil = concreteSettings.mute_until;

        if (concreteSettings.sound.length == 0)
            peerSoundId = 0;
        else if ([concreteSettings.sound isEqualToString:@"default"])
            peerSoundId = 1;
        else
            peerSoundId = [concreteSettings.sound intValue];
        
        peerPreviewText = concreteSettings.show_previews;
        
        photoNotificationsEnabled = concreteSettings.events_mask & 1;
    }
    
    int64_t conversationId = _conversationId;
    [TGDatabaseInstance() storePeerNotificationSettings:_conversationId soundId:peerSoundId muteUntil:peerMuteUntil previewText:peerPreviewText photoNotificationsEnabled:photoNotificationsEnabled writeToActionQueue:false completion:^(bool changed)
    {
        if (changed)
        {
            [ActionStageInstance() dispatchOnStageQueue:^
            {
                NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:peerMuteUntil], @"muteUntil", [NSNumber numberWithInt:peerSoundId], @"soundId", [[NSNumber alloc] initWithBool:peerPreviewText], @"previewText", [[NSNumber alloc] initWithBool:photoNotificationsEnabled], @"photoNotificationsEnabled", nil];
                [extendedChatDataDictionary() setObject:dict forKey:[[NSNumber alloc] initWithLongLong:conversationId]];
                
                [ActionStageInstance() dispatchResource:[NSString stringWithFormat:@"/tg/peerSettings/(%lld)", conversationId] resource:[[SGraphObjectNode alloc] initWithObject:dict]];
            }];
        }
    }];
    
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:peerMuteUntil], @"muteUntil", [NSNumber numberWithInt:peerSoundId], @"soundId", nil];
    [extendedChatDataDictionary() setObject:dict forKey:[[NSNumber alloc] initWithLongLong:_conversationId]];
    
    TGConversationParticipantsData *participantsData = [[TGConversationParticipantsData alloc] initWithTelegraphParticipantsDesc:chatFull.full_chat.participants];
    [TGDatabaseInstance() storeConversationParticipantData:-chatFull.full_chat.n_id participantData:participantsData];
    
    if (chatFull.chats.count != 0)
    {
        TGConversation *conversation = [[TGConversation alloc] initWithTelegraphChatDesc:[chatFull.chats lastObject]];
        
        static int actionId = 0;
        [[[TGConversationAddMessagesActor alloc] initWithPath:[[NSString alloc] initWithFormat:@"/tg/addmessage/(chatData%d)", actionId++]] execute:[[NSDictionary alloc] initWithObjectsAndKeys:[[NSArray alloc] initWithObjects:conversation, nil], @"chats", nil]];
    }
    
    [ActionStageInstance() nodeRetrieved:self.path node:[[SGraphObjectNode alloc] initWithObject:dict]];
}

- (void)chatFullRequestFailed
{
    [ActionStageInstance() nodeRetrieveFailed:self.path];
}

@end
