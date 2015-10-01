#import "TGConversationAddMessagesActor.h"

#import "ActionStage.h"

#import "TGTelegraph.h"
#import "TGTelegramNetworking.h"

#import "TGDatabase.h"
#import "TGMessage.h"

#import "TGAppDelegate.h"

#import "SGraphObjectNode.h"

#import "TGInterfaceManager.h"

#import "TGPeerIdAdapter.h"

#include <set>

@interface TGConversationAddMessagesActor ()

@end

@implementation TGConversationAddMessagesActor

+ (NSString *)genericPath
{
    return @"/tg/addmessage/@";
}

- (id)initWithPath:(NSString *)path
{
    self = [super initWithPath:path];
    if (self != nil)
    {
        self.requestQueueName = @"messages";
        self.cancelTimeout = 0;
    }
    return self;
}

- (void)execute:(NSDictionary *)options
{
    NSArray *messages = [options objectForKey:@"messages"];
    NSMutableDictionary *chats = [options objectForKey:@"chats"];
    bool doNotModifyDates = [options[@"doNotModifyDates"] boolValue];
    bool doNotAdd = [options[@"doNotAdd"] boolValue];
    
    if (!doNotAdd) {
        if (messages == nil && chats.count != 0)
        {
            if ([chats respondsToSelector:@selector(allKeys)])
            {
                [chats enumerateKeysAndObjectsUsingBlock:^(__unused id key, TGConversation *conversation, __unused BOOL *stop)
                {
                    [[TGDatabase instance] addMessagesToConversation:nil conversationId:conversation.conversationId updateConversation:conversation dispatch:true countUnread:false];
                }];
            }
            else
            {
                for (TGConversation *conversation in chats)
                {
                    [[TGDatabase instance] addMessagesToConversation:nil conversationId:conversation.conversationId updateConversation:conversation dispatch:true countUnread:false];
                }
            }
            
            [ActionStageInstance() actionCompleted:self.path result:nil];
            
            return;
        }
    }
    
    int currentTime = (int)[[TGTelegramNetworking instance] globalTime];
    
    bool playNotification = false;
    bool needsSound = false;
    
    std::tr1::shared_ptr<std::map<int64_t, std::set<int> > > pProcessedUsersStoppedTyping(new std::map<int64_t, std::set<int> >());

    NSMutableDictionary *messagesByConversation = [[NSMutableDictionary alloc] init];
    std::set<int64_t> conversationsWithNotification;
    
    std::map<int64_t, int> messageLifetimeByConversation;
    
    int maxMid = 0;
    
    for (TGMessage *message in messages)
    {
        if (TGPeerIdIsChannel(message.cid) && TGMessageSortKeySpace(message.sortKey) != TGMessageSpaceImportant) {
            continue;
        }
        
        TGMessage *storeMessage = message;
        
        if (!message.outgoing && (message.unread || TGPeerIdIsChannel(message.cid)) && (message.toUid != message.fromUid || TGPeerIdIsChannel(message.cid)))
        {
            if (message.mid < TGMessageLocalMidBaseline && message.actionInfo == nil)
            {
                playNotification = true;
                needsSound = true;
                conversationsWithNotification.insert(message.cid);
            }
            else
            {
                if (message.actionInfo.actionType == TGMessageActionUserChangedPhoto)
                {
                    playNotification = true;
                    conversationsWithNotification.insert(message.cid);
                }
            }
        }
        
        int64_t conversationId = message.cid;
        NSNumber *nConversationId = [NSNumber numberWithLongLong:conversationId];
        NSMutableArray *array = [messagesByConversation objectForKey:nConversationId];
        if (array == nil)
        {
            array = [[NSMutableArray alloc] init];
            [messagesByConversation setObject:array forKey:nConversationId];
        }
        
        if (message.date > currentTime - 20)
        {
            std::map<int64_t, std::set<int> >::iterator it = pProcessedUsersStoppedTyping->find(conversationId);
            if (it == pProcessedUsersStoppedTyping->end())
            {
                std::set<int> usersStoppedTypingInConversation;
                usersStoppedTypingInConversation.insert((int)message.fromUid);
                pProcessedUsersStoppedTyping->insert(std::make_pair(conversationId, usersStoppedTypingInConversation));
            }
            else
            {
                it->second.insert((int)message.fromUid);
            }
        }
        
        if (conversationId <= INT_MIN)
        {
            if (messageLifetimeByConversation.find(conversationId) == messageLifetimeByConversation.end())
                messageLifetimeByConversation[conversationId] = [TGDatabaseInstance() messageLifetimeForPeerId:conversationId];
            
            if (message.mediaAttachments != nil)
            {
                for (TGMediaAttachment *attachment in message.mediaAttachments)
                {
                    if (attachment.type == TGActionMediaAttachmentType)
                    {
                        TGActionMediaAttachment *actionAttachment = (TGActionMediaAttachment *)attachment;
                        if (actionAttachment.actionType == TGMessageActionEncryptedChatMessageLifetime)
                        {
                            messageLifetimeByConversation[conversationId] = [actionAttachment.actionData[@"messageLifetime"] intValue];
                            
                            [TGDatabaseInstance() setMessageLifetimeForPeerId:conversationId encryptedConversationId:0 messageLifetime:[actionAttachment.actionData[@"messageLifetime"] intValue] writeToActionQueue:false];
                            
                            [ActionStageInstance() dispatchResource:[[NSString alloc] initWithFormat:@"/tg/encrypted/messageLifetime/(%lld)", conversationId] resource:actionAttachment.actionData[@"messageLifetime"]];
                        }
                        
                        break;
                    }
                }
            }
            
            if (!message.outgoing && messageLifetimeByConversation[conversationId] != 0 && message.layer < 17)
            {
                storeMessage = [message copy];
                NSTimeInterval minLifetime = 0.0;
                for (id attachment in storeMessage.mediaAttachments)
                {
                    if ([attachment isKindOfClass:[TGVideoMediaAttachment class]])
                    {
                        minLifetime = ((TGVideoMediaAttachment *)attachment).duration;
                    }
                    else if ([attachment isKindOfClass:[TGAudioMediaAttachment class]])
                    {
                        minLifetime = ((TGAudioMediaAttachment *)attachment).duration;
                    }
                }
                storeMessage.messageLifetime = (int)MAX(minLifetime, (NSTimeInterval)messageLifetimeByConversation[conversationId]);
            }
        }
        
        int mid = message.mid;
        if (!message.outgoing && mid < TGMessageLocalMidBaseline && mid > maxMid && !TGPeerIdIsChannel(conversationId))
            maxMid = mid;
        
        [array addObject:storeMessage];
    }
    
    NSMutableArray *lastMessages = [[NSMutableArray alloc] init];
    
    NSMutableDictionary *lastIncomingMessageByConversation = [[NSMutableDictionary alloc] init];
    
    for (NSNumber *nConversationId in messagesByConversation)
    {
        NSArray *conversationMessages = [messagesByConversation objectForKey:nConversationId];
        
        TGMessage *lastMessage = nil;
        NSTimeInterval lastMessageDate = 0;
        int minRemoteMid = INT_MAX;
        int maxRemoteMid = 0;
        for (TGMessage *message in conversationMessages)
        {
            NSTimeInterval messageDate = message.date;
            
            if (lastMessage == nil || messageDate > lastMessageDate || ((int)(lastMessageDate) == (int)(messageDate) && message.mid > lastMessage.mid))
            {
                lastMessage = message;
                lastMessageDate = messageDate;
            }
            
            if (message.mid < TGMessageLocalMidBaseline)
            {
                minRemoteMid = MIN(minRemoteMid, message.mid);
                maxRemoteMid = MAX(maxRemoteMid, message.mid);
            }
        }
        if (lastMessage != nil)
            [lastMessages addObject:lastMessage];
        
        if (lastMessage != nil && !lastMessage.outgoing)
            lastIncomingMessageByConversation[nConversationId] = lastMessage;
        
        if (!doNotAdd) {
            TGConversation *conversation = [chats objectForKey:nConversationId];
            if (TGPeerIdIsChannel([nConversationId longLongValue])) {
                if (conversation != nil) {
                    [TGDatabaseInstance() updateChannels:@[conversation]];
                }
            } else {
                [[TGDatabase instance] addMessagesToConversation:conversationMessages conversationId:[nConversationId longLongValue] updateConversation:conversation dispatch:true countUnread:true updateDates:!doNotModifyDates];
            }
        
            if (minRemoteMid > 0 && maxRemoteMid > 0 && (minRemoteMid != 0 || maxRemoteMid != 0) && minRemoteMid <= maxRemoteMid)
            {
                [TGDatabaseInstance() fillConversationHistoryHole:[nConversationId longLongValue] indexSet:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(minRemoteMid, maxRemoteMid - minRemoteMid)]];
            }
            
            if (TGPeerIdIsChannel([nConversationId longLongValue])) {
            } else {
                [ActionStageInstance() dispatchResource:[NSString stringWithFormat:@"/tg/conversation/(%lld)/messages", [nConversationId longLongValue]] resource:[[SGraphObjectNode alloc] initWithObject:conversationMessages]];
            }
        }
    }
    
    bool playChatSound = false;
    TGMessage *messageForNotification = nil;
    
    if (playNotification)
    {
        playNotification = false;
        bool supposedToPlaySound = needsSound;
        needsSound = false;
        for (std::set<int64_t>::iterator it = conversationsWithNotification.begin(); it != conversationsWithNotification.end(); it++)
        {
            int64_t notificationPeerId = (!TGPeerIdIsChannel(*it) && *it <= INT_MIN) ? [TGDatabaseInstance() encryptedParticipantIdForConversationId:*it] : *it;
            int64_t mutePeerId = notificationPeerId;
            if (!TGPeerIdIsChannel(notificationPeerId) && notificationPeerId < 0)
            {
                TGMessage *message = lastIncomingMessageByConversation[@(*it)];
                if (message.containsMention)
                    mutePeerId = message.fromUid;
            }
            if (![TGDatabaseInstance() isPeerMuted:mutePeerId])
            {
                TGMessage *lastMessage = lastIncomingMessageByConversation[@(*it)];
                if (lastMessage != nil)
                {
                    if (messageForNotification == nil || messageForNotification.date < lastMessage.date || (messageForNotification.date == lastMessage.date && messageForNotification.mid < lastMessage.mid))
                    {
                        messageForNotification = lastMessage;
                    }
                }
                
                if (notificationPeerId < 0)
                    playChatSound = true;
                playNotification = true;
                needsSound = supposedToPlaySound;
                break;
            }
        }
    }
    
    if (playNotification)
    {
        if (needsSound)
        {
            [TGAppDelegateInstance playSound:TGAppDelegateInstance.soundEnabled ? (playChatSound ? @"notification.caf" : @"notification.caf") : nil vibrate:true];
        }
        
        if (messageForNotification != nil)
        {
            [[TGInterfaceManager instance] displayBannerIfNeeded:messageForNotification conversationId:messageForNotification.cid];
        }
    }
    
    dispatch_async([ActionStageInstance() globalStageDispatchQueue], ^
    {
        if (!pProcessedUsersStoppedTyping->empty())
        {
            for (std::map<int64_t, std::set<int> >::iterator it = pProcessedUsersStoppedTyping->begin(); it != pProcessedUsersStoppedTyping->end(); it++)
            {
                for (std::set<int>::iterator it2 = it->second.begin(); it2 != it->second.end(); it2++)
                {
                    [TGTelegraphInstance dispatchUserActivity:*it2 inConversation:it->first type:nil];
                }
            }
        }
    });
    
    if (maxMid > 0 && !doNotAdd)
    {
        [TGDatabaseInstance() updateLatestMessageId:maxMid applied:false completion:^(int greaterMidForSynchronization)
        {
            if (greaterMidForSynchronization > 0)
            {
                [ActionStageInstance() requestActor:[[NSString alloc] initWithFormat:@"/tg/messages/reportDelivery/(messages)"] options:[[NSDictionary alloc] initWithObjectsAndKeys:[[NSNumber alloc] initWithInt:maxMid], @"mid", nil] watcher:TGTelegraphInstance];
            }
        }];
    }
    
    [ActionStageInstance() actionCompleted:self.path result:nil];
}

- (void)cancel
{
    [super cancel];
}

@end
