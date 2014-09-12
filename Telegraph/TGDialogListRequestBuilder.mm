#import "TGDialogListRequestBuilder.h"

#import "TGTelegraph.h"

#import "TGMessage+Telegraph.h"
#import "TGConversation+Telegraph.h"

#import "ActionStage.h"
#import "SGraphListNode.h"

#import "TGUserDataRequestBuilder.h"

#import "TGDatabase.h"

#include <set>

@interface TGDialogListRequestBuilder ()
{
    std::set<int64_t> _ignoreConversationIds;
}

@property (nonatomic) bool replaceList;

@end

@implementation TGDialogListRequestBuilder

+ (NSString *)genericPath
{
    return @"/tg/dialoglist/@";
}

- (void)prepare:(NSDictionary *)options
{
    if (![[options objectForKey:@"inline"] boolValue] && [options objectForKey:@"date"] == nil)
    {
        self.requestQueueName = @"messages";
    }
}

- (void)execute:(NSDictionary *)__unused options
{
    NSNumber *date = [options objectForKey:@"date"];
    NSNumber *limit = [options objectForKey:@"limit"];
    
    if (date == nil)
    {
        _replaceList = true;
    
        int limit = 200;
        
        self.cancelToken = [TGTelegraphInstance doRequestDialogsList:0 limit:limit requestBuilder:self];
    }
    else
    {
        [[TGDatabase instance] loadConversationListFromDate:[date intValue] limit:[limit intValue] excludeConversationIds:options[@"excludeConversationIds"] completion:^(NSArray *result)
        {
            if (result.count == 0)
            {
                [TGDatabaseInstance() customProperty:@"dialogListLoaded" completion:^(NSData *value)
                {
                    if (value.length != 0)
                    {
                        [ActionStageInstance() nodeRetrieved:self.path node:[[SGraphListNode alloc] initWithItems:result]];
                    }
                    else
                    {
                        int offset = [TGDatabaseInstance() loadConversationListRemoteOffset];
                        
                        [ActionStageInstance() dispatchOnStageQueue:^
                        {
                            for (NSNumber *nConversationId in options[@"excludeConversationIds"])
                            {
                                _ignoreConversationIds.insert([nConversationId longLongValue]);
                            }
                            
                            TGLog(@"Requesting dialog list with offset = %d", offset);
                            self.cancelToken = [TGTelegraphInstance doRequestDialogsList:offset limit:80 requestBuilder:self];
                        }];
                    }
                }];
            }
            else
                [ActionStageInstance() nodeRetrieved:self.path node:[[SGraphListNode alloc] initWithItems:result]];
        }];
    }
}

- (void)dialogListRequestSuccess:(TLmessages_Dialogs *)dialogs
{
    [TGUserDataRequestBuilder executeUserDataUpdate:dialogs.users];
    
    NSMutableDictionary *chatItems = [[NSMutableDictionary alloc] init];
    for (TLChat *chatDesc in dialogs.chats)
    {
        TGConversation *conversation = [[TGConversation alloc] initWithTelegraphChatDesc:chatDesc];
        if (conversation.conversationId != 0)
        {
            [chatItems setObject:conversation forKey:[NSNumber numberWithInt:(int)conversation.conversationId]];
        }
    }
    
    NSMutableDictionary *messagesDict = [[NSMutableDictionary alloc] init];
    for (TLMessage *messageDesc in dialogs.messages)
    {
        TGMessage *message = [[TGMessage alloc] initWithTelegraphMessageDesc:messageDesc];
        if (message.mid != 0)
            [messagesDict setObject:message forKey:[NSNumber numberWithInt:message.mid]];
    }
    
    NSMutableArray *conversations = [[NSMutableArray alloc] init];
    
    NSMutableDictionary *messagesByConversation = [[NSMutableDictionary alloc] init];
    
    for (TLDialog *dialog in dialogs.dialogs)
    {
        if ([dialog.peer isKindOfClass:[TLPeer$peerUser class]])
        {
            if (_ignoreConversationIds.find(((TLPeer$peerUser *)dialog.peer).user_id) == _ignoreConversationIds.end())
            {
                TGConversation *conversation = [[TGConversation alloc] initWithConversationId:((TLPeer$peerUser *)dialog.peer).user_id unreadCount:dialog.unread_count serviceUnreadCount:0];
                TGMessage *message = [messagesDict objectForKey:[NSNumber numberWithInt:dialog.top_message]];
                if (message != nil)
                    [conversation mergeMessage:message];
                
                if (conversation.conversationId != 0)
                {
                    //TGLog(@"Dialog with %@", [TGDatabaseInstance() loadUser:conversation.conversationId].displayName);
                    
                    [conversations addObject:conversation];
                    
                    if (message != nil)
                        [messagesByConversation setObject:message forKey:[[NSNumber alloc] initWithLongLong:conversation.conversationId]];
                }
                
                if ([dialog.notify_settings isKindOfClass:[TLPeerNotifySettings$peerNotifySettings class]])
                {
                    TLPeerNotifySettings$peerNotifySettings *concreteSettings = (TLPeerNotifySettings$peerNotifySettings *)dialog.notify_settings;
                    
                    int peerSoundId = 0;
                    int peerMuteUntil = 0;
                    bool peerPreviewText = true;
                    
                    peerMuteUntil = concreteSettings.mute_until;
                    
                    if (concreteSettings.sound.length == 0)
                        peerSoundId = 0;
                    else if ([concreteSettings.sound isEqualToString:@"default"])
                        peerSoundId = 1;
                    else
                        peerSoundId = [concreteSettings.sound intValue];
                    
                    peerPreviewText = concreteSettings.show_previews;
                    
                    [TGDatabaseInstance() storePeerNotificationSettings:conversation.conversationId soundId:peerSoundId muteUntil:peerMuteUntil previewText:peerPreviewText photoNotificationsEnabled:false writeToActionQueue:false completion:nil];
                }
            }
        }
        else if ([dialog.peer isKindOfClass:[TLPeer$peerChat class]])
        {
            if (_ignoreConversationIds.find(-((TLPeer$peerChat *)dialog.peer).chat_id) == _ignoreConversationIds.end())
            {
                TGConversation *conversation = [chatItems objectForKey:[[NSNumber alloc] initWithLongLong:-((TLPeer$peerChat *)dialog.peer).chat_id]];
                conversation.unreadCount = dialog.unread_count;
                TGMessage *message = [messagesDict objectForKey:[NSNumber numberWithInt:dialog.top_message]];
                if (message != nil)
                    [conversation mergeMessage:message];
                
                if (conversation.conversationId != 0)
                {
                    //TGLog(@"Chat %@", conversation.chatTitle);
                    
                    [conversations addObject:conversation];
                    
                    if (message != nil)
                        [messagesByConversation setObject:message forKey:[[NSNumber alloc] initWithLongLong:conversation.conversationId]];
                }
                
                if ([dialog.notify_settings isKindOfClass:[TLPeerNotifySettings$peerNotifySettings class]])
                {
                    TLPeerNotifySettings$peerNotifySettings *concreteSettings = (TLPeerNotifySettings$peerNotifySettings *)dialog.notify_settings;
                    
                    int peerSoundId = 0;
                    int peerMuteUntil = 0;
                    bool peerPreviewText = true;
                    
                    peerMuteUntil = concreteSettings.mute_until;
                    
                    if (concreteSettings.sound.length == 0)
                        peerSoundId = 0;
                    else if ([concreteSettings.sound isEqualToString:@"default"])
                        peerSoundId = 1;
                    else
                        peerSoundId = [concreteSettings.sound intValue];
                    
                    peerPreviewText = concreteSettings.show_previews;
                    
                    [TGDatabaseInstance() storePeerNotificationSettings:conversation.conversationId soundId:peerSoundId muteUntil:peerMuteUntil previewText:peerPreviewText photoNotificationsEnabled:false writeToActionQueue:false completion:nil];
                }
            }
        }
    }
    
    [[TGDatabase instance] storeConversationList:conversations replace:_replaceList];
    
    if (dialogs.dialogs.count == 0)
    {
        uint8_t loaded = 1;
        [TGDatabaseInstance() setCustomProperty:@"dialogListLoaded" value:[[NSData alloc] initWithBytes:&loaded length:1]];
    }
    
    [messagesByConversation enumerateKeysAndObjectsUsingBlock:^(NSNumber *nConversationId, TGMessage *message, __unused  BOOL *stop)
    {
        [TGDatabaseInstance() addMessagesToConversation:[[NSArray alloc] initWithObjects:message, nil] conversationId:[nConversationId longLongValue] updateConversation:nil dispatch:false countUnread:false];
        [TGDatabaseInstance() fillConversationHistoryHole:[nConversationId longLongValue] indexSet:[NSIndexSet indexSetWithIndex:message.mid]];
    }];
    
    SGraphListNode *dialogListNode = [[SGraphListNode alloc] initWithItems:conversations];
    [ActionStageInstance() nodeRetrieved:self.path node:dialogListNode];
}

- (void)dialogListRequestFailed
{
    [ActionStageInstance() nodeRetrieveFailed:self.path];
}

@end
