#import "TGUpdateStateRequestBuilder.h"

#import "ActionStage.h"
#import "SGraphObjectNode.h"
#import "SGraphListNode.h"

#import "TGTelegraph.h"
#import "TGTelegramNetworking.h"
#import <MTProtoKit/MTProto.h>
#import <MTProtoKit/MTDatacenterAddress.h>

#import "TGAppDelegate.h"

#import "TGInterfaceManager.h"

#import "TGUserDataRequestBuilder.h"
#import "TGApplyStateRequestBuilder.h"
#import "TGConversationAddMessagesActor.h"
#import "TGConversationReadMessagesActor.h"

#import "TGSynchronizeActionQueueActor.h"

#import "TGMessage+Telegraph.h"
#import "TGConversation+Telegraph.h"
#import "TGDatabase.h"

#import "TGImageInfo+Telegraph.h"

#import "TGTimelineItem.h"

#import "TGUser+Telegraph.h"

#import "TGLiveNearbyActor.h"

#import "TGStringUtils.h"
#import "TGDateUtils.h"
#import <MTProtoKit/MTEncryption.h>

#import "TGUpdate.h"

#import "TGRequestEncryptedChatActor.h"

#import "TLMetaClassStore.h"

#import "TGModernSendSecretMessageActor.h"

#import <set>

static int stateVersion = 0;
static bool didRequestUpdates = false;

static std::map<int, std::set<int64_t> > _ignoredConversationIds;

static NSMutableDictionary *delayedMessagesInConversations()
{
    static NSMutableDictionary *dict = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        dict = [[NSMutableDictionary alloc] init];
    });
    return dict;
}

static bool _initialUpdatesScheduled = false;

@interface TGUpdateStateRequestBuilder ()

@property (nonatomic, strong) TGSynchronizeActionQueueActor *synchronizeActionQueueActor;

@property (nonatomic, strong) TLupdates_State *state;
@property (nonatomic, strong) SGraphNode *dialogListNode;

@end

@implementation TGUpdateStateRequestBuilder

+ (NSString *)genericPath
{
    return @"/tg/service/updatestate";
}

+ (void)scheduleInitialUpdates
{
    _initialUpdatesScheduled = true;
}

+ (void)clearStateHistory
{
    stateVersion = 0;
    didRequestUpdates = false;
    
    [delayedMessagesInConversations() removeAllObjects];
}

+ (int)stateVersion
{
    return stateVersion;
}

+ (void)invalidateStateVersion
{
    stateVersion++;
    
    [TGDatabaseInstance() upgradeUserLinks];
}

+ (void)addIgnoreConversationId:(int64_t)conversationId
{
    _ignoredConversationIds[TGTelegraphInstance.clientUserId].insert(conversationId);
}

+ (bool)ignoringConversationId:(int64_t)conversationId
{
    return _ignoredConversationIds[TGTelegraphInstance.clientUserId].find(conversationId) != _ignoredConversationIds[TGTelegraphInstance.clientUserId].end();
}

+ (void)removeIgnoreConversationId:(int64_t)conversationId
{
    _ignoredConversationIds[TGTelegraphInstance.clientUserId].erase(conversationId);
}

- (id)initWithPath:(NSString *)path
{
    self = [super initWithPath:path];
    if (self != nil)
    {
        _actionHandle = [[ASHandle alloc] initWithDelegate:self releaseOnMainThread:false];
    }
    return self;
}

- (void)dealloc
{
    [_actionHandle reset];
    [ActionStageInstance() removeWatcher:self];
}

- (void)prepare:(NSDictionary *)__unused options
{
    self.requestQueueName = @"messages";
    
    [TGUpdateStateRequestBuilder invalidateStateVersion];
    
    int state = 1;
    if ([[TGTelegramNetworking instance] isUpdating])
        state |= 1;
    if ([[TGTelegramNetworking instance] isConnecting])
        state |= 2;
    if (![[TGTelegramNetworking instance] isNetworkAvailable])
        state |= 4;
    
    [ActionStageInstance() dispatchResource:@"/tg/service/synchronizationstate" resource:[[SGraphObjectNode alloc] initWithObject:[NSNumber numberWithInt:state]]];
    
    [ActionStageInstance() requestActor:@"/tg/service/synchronizeserviceactions/(other)" options:nil watcher:TGTelegraphInstance];
}

- (void)execute:(NSDictionary *)__unused options
{
    TGDatabaseState state = [[TGDatabase instance] databaseState];
/*#ifdef DEBUG
    if (state.pts == 0)
    {
        state.pts = 1;
        state.seq = 1;
        state.date = 1;
        state.qts = 0;
        
        [TGDatabaseInstance() applyPts:state.pts date:state.date seq:state.seq qts:state.qts unreadCount:0];
    }
#endif*/
    if (state.pts != 0)
    {
        [ActionStageInstance() requestActor:@"/tg/service/synchronizeactionqueue/(bypass)" options:[[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithBool:true], @"bypassQueue", nil] watcher:self];
    }
    else
    {
        self.cancelToken = [TGTelegraphInstance doRequestState:self];
    }
}

- (void)actorCompleted:(int)__unused resultCode path:(NSString *)path result:(id)__unused result
{
    if ([path hasPrefix:@"/tg/service/synchronizeactionqueue"])
    {
        TGDatabaseState state = [[TGDatabase instance] databaseState];
        self.cancelToken = [TGTelegraphInstance doRequestStateDelta:state.pts date:state.date qts:state.qts requestBuilder:self];
        
        _synchronizeActionQueueActor = nil;
    }
    else if ([path hasPrefix:@"/tg/dialoglist"])
    {
        [ActionStageInstance() requestActor:[NSString stringWithFormat:@"/tg/peerSettings/(%d,cached)", INT_MAX - 1] options:[NSDictionary dictionaryWithObject:[NSNumber numberWithLongLong:INT_MAX - 1] forKey:@"peerId"] watcher:TGTelegraphInstance];
        [ActionStageInstance() requestActor:[NSString stringWithFormat:@"/tg/peerSettings/(%d,cached)", INT_MAX - 2] options:[NSDictionary dictionaryWithObject:[NSNumber numberWithLongLong:INT_MAX - 2] forKey:@"peerId"] watcher:TGTelegraphInstance];
        [ActionStageInstance() requestActor:@"/tg/privacySettings/(cached)" options:nil watcher:TGTelegraphInstance];
        
        NSMutableArray *dialogList = [((SGraphListNode *)result).items mutableCopy];
        [dialogList sortUsingComparator:^NSComparisonResult(TGConversation *conversation1, TGConversation *conversation2)
        {
            int date1 = conversation1.date;
            int date2 = conversation2.date;
            
            if (date1 > date2)
                return NSOrderedAscending;
            else if (date1 < date2)
                return NSOrderedDescending;
            else
                return NSOrderedSame;
        }];
        
        const int maxDialogs = 50;
        if (dialogList.count > maxDialogs)
            [dialogList removeObjectsInRange:NSMakeRange(maxDialogs, dialogList.count - maxDialogs)];
        
        int connectionState = 0;
        if ([[TGTelegramNetworking instance] isUpdating])
            connectionState |= 1;
        if ([[TGTelegramNetworking instance] isConnecting])
            connectionState |= 2;
        if (![[TGTelegramNetworking instance] isNetworkAvailable])
            connectionState |= 4;
        
        [ActionStageInstance() dispatchResource:@"/tg/service/synchronizationstate" resource:[[SGraphObjectNode alloc] initWithObject:[NSNumber numberWithInt:connectionState]]];
        
        TLupdates_State *state = _state;
        
        [[[TGApplyStateRequestBuilder alloc] initWithPath:[NSString stringWithFormat:@"/tg/service/applystate/(%d,%d,%d,%d,%d)", state.pts, state.date, state.seq, state.qts, state.unread_count]] execute:[[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:state.pts], @"pts", [NSNumber numberWithInt:state.date], @"date", [NSNumber numberWithInt:state.seq], @"seq", @(state.qts), @"qts", [NSNumber numberWithInt:state.unread_count], @"unreadCount", nil]];
        
        [ActionStageInstance() dispatchResource:path resource:[[SGraphListNode alloc] initWithItems:dialogList]];
        
        [self completeDifferenceUpdate];
        
        [ActionStageInstance() dispatchResource:@"/tg/service/stateUpdated" resource:nil];
        
        [ActionStageInstance() requestActor:@"/tg/service/synchronizeserviceactions/(settings)" options:nil watcher:TGTelegraphInstance];
    }
}

- (void)completeDifferenceUpdate
{
    [ActionStageInstance() actionCompleted:self.path result:nil];
    
    if (_initialUpdatesScheduled)
    {
        _initialUpdatesScheduled = false;
     
        [[TGTelegramNetworking instance] performDeferredServiceTasks];
        
        [ActionStageInstance() requestActor:@"/tg/service/settings/push/(subscribe)" options:nil watcher:TGTelegraphInstance];
        
        [ActionStageInstance() requestActor:@"/tg/service/updateConfig" options:nil flags:0 watcher:TGTelegraphInstance];
    }
    
    [TGTelegraphInstance updatePresenceNow];
    
    [[[TGTelegramNetworking instance] mtProto] requestTimeResync];
}

+ (bool)applyUpdates:(NSArray *)addedMessagesDesc addedParsedMessages:(NSArray *)addedParsedMessages otherUpdates:(NSArray *)otherUpdates addedEncryptedActions:(NSArray *)addedEncryptedActions usersDesc:(NSArray *)usersDesc chatsDesc:(NSArray *)chatsDesc chatParticipantsDesc:(NSArray *)chatParticipantsDesc updatesWithDates:(NSArray *)updatesWithDates
{
    static Class updateReadMessagesClass = [TLUpdate$updateReadMessages class];
    static Class updateDeleteMessagesClass = [TLUpdate$updateDeleteMessages class];
    static Class updateContactLinkClass = [TLUpdate$updateContactLink class];
    static Class updateActivationClass = [TLUpdate$updateActivation class];
    static Class updateContactRegisteredClass = [TLUpdate$updateContactRegistered class];
    static Class updateUserTypingClass = [TLUpdate$updateUserTyping class];
    static Class updateChatUserTypingClass = [TLUpdate$updateChatUserTyping class];
    static Class updateUserStatusClass = [TLUpdate$updateUserStatus class];
    static Class updateUserPhotoClass = [TLUpdate$updateUserPhoto class];
    static Class updateUserNameClass = [TLUpdate$updateUserName class];
    static Class updateChatParticipantsClass = [TLUpdate$updateChatParticipants class];
    static Class updateChatParticipantAddClass = [TLUpdate$updateChatParticipantAdd class];
    static Class updateChatParticipantDeleteClass = [TLUpdate$updateChatParticipantDelete class];
    static Class updateMessageIdClass = [TLUpdate$updateMessageID class];
    static Class updateEncryptedChatTypingClass = [TLUpdate$updateEncryptedChatTyping class];
    static Class updateEncryptedMessagesReadClass = [TLUpdate$updateEncryptedMessagesRead class];
    
    [TGUserDataRequestBuilder executeUserDataUpdate:usersDesc];
    
    NSMutableDictionary *chatItems = [[NSMutableDictionary alloc] init];
    for (TLChat *chatDesc in chatsDesc)
    {
        TGConversation *conversation = [[TGConversation alloc] initWithTelegraphChatDesc:chatDesc];
        if (conversation.conversationId != 0)
        {
            [chatItems setObject:conversation forKey:[NSNumber numberWithInt:(int)conversation.conversationId]];
        }
    }
    
    NSMutableArray *addedMessages = [[NSMutableArray alloc] init];
    NSMutableArray *newAddedEncryptedActions = [[NSMutableArray alloc] init];
    NSMutableDictionary *updatedEncryptedChats = [[NSMutableDictionary alloc] init];
    
    std::set<int64_t> &ignoredConversationsForCurrentUser = _ignoredConversationIds[TGTelegraphInstance.clientUserId];
    
    std::map<int64_t, int64_t> cachedPeerIds;
    std::map<int64_t, std::pair<int64_t, NSData *> > cachedKeys;
    std::map<int64_t, int32_t> cachedParticipantIds;
    
    std::set<int> readMessageIds;
    std::set<int> deleteMessageIds;
    std::map<int64_t, std::pair<int32_t, int32_t> > maxReadDateInEncryptedConversation;
    
    std::set<int64_t> addingRandomIds;
    
    std::vector<std::pair<int64_t, int> > messageIdUpdates;
    
    std::set<int64_t> acceptEncryptedChats;
    
    std::map<int, std::vector<id> > chatParticipantUpdateArrays;
    
    NSMutableArray *userPhotoUpdates = nil;
    
    NSMutableArray *userTypingUpdates = [[NSMutableArray alloc] init];
    
    bool dispatchBlocked = false;
    
    for (TLUpdate *update in otherUpdates)
    {
        if ([update isKindOfClass:updateReadMessagesClass])
        {
            TLUpdate$updateReadMessages *concreteUpdate = (TLUpdate$updateReadMessages *)update;
            
            for (NSNumber *nMid in concreteUpdate.messages)
            {
                readMessageIds.insert([nMid intValue]);
            }
        }
        else if ([update isKindOfClass:updateEncryptedMessagesReadClass])
        {
            TLUpdate$updateEncryptedMessagesRead *concreteUpdate = (TLUpdate$updateEncryptedMessagesRead *)update;
            
            int64_t peerId = [TGDatabaseInstance() peerIdForEncryptedConversationId:concreteUpdate.chat_id createIfNecessary:false];
            
            if (maxReadDateInEncryptedConversation[peerId].first < concreteUpdate.max_date)
            {
                maxReadDateInEncryptedConversation[peerId].first = concreteUpdate.max_date;
                maxReadDateInEncryptedConversation[peerId].second = concreteUpdate.date;
            }
        }
        else if ([update isKindOfClass:updateDeleteMessagesClass])
        {
            TLUpdate$updateDeleteMessages *deleteMessages = (TLUpdate$updateDeleteMessages *)update;
            
            for (NSNumber *nMid in deleteMessages.messages)
            {
                deleteMessageIds.insert([nMid intValue]);
            }
        }
        else if ([update isKindOfClass:updateMessageIdClass])
        {
            TLUpdate$updateMessageID *updateMessageId = (TLUpdate$updateMessageID *)update;
            
            messageIdUpdates.push_back(std::pair<int64_t, int>(updateMessageId.random_id, updateMessageId.n_id));
        }
        else if ([update isKindOfClass:updateChatParticipantsClass])
        {
            TLUpdate$updateChatParticipants *updateChatParticipants = (TLUpdate$updateChatParticipants *)update;
            
            chatParticipantUpdateArrays[updateChatParticipants.participants.chat_id].push_back(updateChatParticipants.participants);
        }
        else if ([update isKindOfClass:updateChatParticipantAddClass])
        {
            TLUpdate$updateChatParticipantAdd *updateChatParticipantAdd = (TLUpdate$updateChatParticipantAdd *)update;
            chatParticipantUpdateArrays[updateChatParticipantAdd.chat_id].push_back(update);
        }
        else if ([update isKindOfClass:updateChatParticipantDeleteClass])
        {
            TLUpdate$updateChatParticipantDelete *updateChatParticipantDelete = (TLUpdate$updateChatParticipantDelete *)update;
            chatParticipantUpdateArrays[updateChatParticipantDelete.chat_id].push_back(update);
        }
        else if ([update isKindOfClass:updateContactLinkClass])
        {
            TLUpdate$updateContactLink *contactLinkUpdate = (TLUpdate$updateContactLink *)update;
            
            if (contactLinkUpdate.user_id != 0)
            {   
                int userLink = extractUserLinkFromUpdate(contactLinkUpdate);
                [TGUserDataRequestBuilder executeUserLinkUpdates:[[NSArray alloc] initWithObjects:[[NSArray alloc] initWithObjects:[[NSNumber alloc] initWithInt:contactLinkUpdate.user_id], [[NSNumber alloc] initWithInt:userLink], nil], nil]];
            }
        }
        else if ([update isKindOfClass:updateActivationClass])
        {
            TGTelegraphInstance.clientIsActivated = true;
            [TGAppDelegateInstance saveSettings];
            
            [ActionStageInstance() dispatchResource:@"/tg/activation" resource:[[SGraphObjectNode alloc] initWithObject:[[NSNumber alloc] initWithBool:true]]];
        }
        else if ([update isKindOfClass:updateContactRegisteredClass])
        {
            TLUpdate$updateContactRegistered *contactRegistered = (TLUpdate$updateContactRegistered *)update;
            
            TGMessage *message = [[TGMessage alloc] init];
            message.mid = [[[TGDatabaseInstance() generateLocalMids:1] objectAtIndex:0] intValue];
            
            message.fromUid = contactRegistered.user_id;
            message.toUid = TGTelegraphInstance.clientUserId;
            message.date = contactRegistered.date;
            message.unread = false;
            message.outgoing = false;
            message.cid = contactRegistered.user_id;
            
            TGActionMediaAttachment *actionAttachment = [[TGActionMediaAttachment alloc] init];
            actionAttachment.actionType = TGMessageActionContactRegistered;
            message.mediaAttachments = [[NSArray alloc] initWithObjects:actionAttachment, nil];
            
            [addedMessages addObject:message];
        }
        else if ([update isKindOfClass:updateUserTypingClass])
        {
            [userTypingUpdates addObject:update];
        }
        else if ([update isKindOfClass:updateChatUserTypingClass])
        {
            [userTypingUpdates addObject:update];
        }
        else if ([update isKindOfClass:updateEncryptedChatTypingClass])
        {
            [userTypingUpdates addObject:update];
        }
        else if ([update isKindOfClass:updateUserStatusClass])
        {
            TLUpdate$updateUserStatus *userStatus = (TLUpdate$updateUserStatus *)update;
            
            TGUserPresence presence = extractUserPresence(userStatus.status);
            
            [TGTelegraphInstance dispatchUserPresenceChanges:userStatus.user_id presence:presence];
        }
        else if ([update isKindOfClass:updateUserPhotoClass])
        {
            TLUpdate$updateUserPhoto *photoUpdate = (TLUpdate$updateUserPhoto *)update;
            
            TGUser *originalUser = [[TGDatabase instance] loadUser:photoUpdate.user_id];
            if (originalUser != nil)
            {
                TGUser *user = [originalUser copy];
                TLUserProfilePhoto *photo = photoUpdate.photo;
                if ([photo isKindOfClass:[TLUserProfilePhoto$userProfilePhoto class]])
                {
                    extractUserPhoto(photo, user);
                }
                else
                {
                    user.photoUrlBig = nil;
                    user.photoUrlMedium = nil;
                    user.photoUrlSmall = nil;
                }
                
                if (!photoUpdate.previous)
                {
                    if (userPhotoUpdates == nil)
                        userPhotoUpdates = [[NSMutableArray alloc] init];
                    
                    [userPhotoUpdates addObject:[[NSDictionary alloc] initWithObjectsAndKeys:[[NSNumber alloc] initWithInt:user.uid], @"uid", photo, @"photo", [[NSNumber alloc] initWithInt:photoUpdate.date], @"date", nil]];
                }
                
                [TGUserDataRequestBuilder executeUserObjectsUpdate:[NSArray arrayWithObject:user]];
            }
        }
        else if ([update isKindOfClass:updateUserNameClass])
        {
            TLUpdate$updateUserName *userNameUpdate = (TLUpdate$updateUserName *)update;
            
            TGUser *originalUser = [[TGDatabase instance] loadUser:userNameUpdate.user_id];
            if (originalUser != nil)
            {
                TGUser *user = [originalUser copy];
                
                user.firstName = userNameUpdate.first_name;
                user.lastName = userNameUpdate.last_name;
                
                if (![user isEqualToUser:originalUser])
                {
                    [TGUserDataRequestBuilder executeUserObjectsUpdate:[NSArray arrayWithObject:user]];
                }
            }
        }
        else if ([update isKindOfClass:[TLUpdate$updateNewAuthorization class]])
        {
            int uid = [TGTelegraphInstance createServiceUserIfNeeded];
            
            TLUpdate$updateNewAuthorization *authUpdate = (TLUpdate$updateNewAuthorization *)update;
            
            TGMessage *message = [[TGMessage alloc] init];
            message.mid = [[[TGDatabaseInstance() generateLocalMids:1] objectAtIndex:0] intValue];
            
            message.fromUid = uid;
            message.toUid = TGTelegraphInstance.clientUserId;
            message.date = authUpdate.date;
            message.unread = false;
            message.outgoing = false;
            message.cid = uid;
            
            TGUser *selfUser = [TGDatabaseInstance() loadUser:TGTelegraphInstance.clientUserId];
            
            NSString *displayName = selfUser.firstName;
            if (displayName.length == 0)
                displayName = selfUser.lastName;
            
            message.text = [[NSString alloc] initWithFormat:TGLocalized(@"Notification.NewAuthDetected"), displayName, [TGDateUtils stringForDayOfWeek:(int)message.date], [TGDateUtils stringForDialogTime:(int)message.date], [TGDateUtils stringForShortTime:(int)message.date], authUpdate.device, authUpdate.location];
            
            [addedMessages addObject:message];
        }
        else if ([update isKindOfClass:[TLUpdate$updateEncryption class]])
        {
            TLUpdate$updateEncryption *updateEncryption = (TLUpdate$updateEncryption *)update;
            
            TGConversation *conversation = nil;
            conversation = [[TGConversation alloc] initWithTelegraphEncryptedChatDesc:updateEncryption.chat];
            if (conversation != nil)
            {
                conversation.date = updateEncryption.date;
                
                if ([updateEncryption.chat isKindOfClass:[TLEncryptedChat$encryptedChatWaiting class]])
                {
                }
                else if ([updateEncryption.chat isKindOfClass:[TLEncryptedChat$encryptedChatRequested class]])
                {
                    updatedEncryptedChats[@(conversation.conversationId)] = conversation;
                    
                    TLEncryptedChat$encryptedChatRequested *concreteChat = (TLEncryptedChat$encryptedChatRequested *)updateEncryption.chat;

                    conversation.encryptedData.handshakeState = 2;
                    
                    [TGDatabaseInstance() setConversationCustomProperty:conversation.conversationId name:murMurHash32(@"a") value:concreteChat.g_a];
                    
                    acceptEncryptedChats.insert(concreteChat.n_id);
                }
                else if ([updateEncryption.chat isKindOfClass:[TLEncryptedChat$encryptedChat class]])
                {
                    if ([TGDatabaseInstance() loadConversationWithId:conversation.conversationId].encryptedData.handshakeState != 4)
                    {
                        updatedEncryptedChats[@(conversation.conversationId)] = conversation;
                        
                        TLEncryptedChat$encryptedChat *concreteChat = (TLEncryptedChat$encryptedChat *)updateEncryption.chat;
                        NSData *aBytes = [TGDatabaseInstance() conversationCustomPropertySync:conversation.conversationId name:murMurHash32(@"a")];
                        
                        TLmessages_DhConfig$messages_dhConfig *config = [TGRequestEncryptedChatActor cachedEncryptionConfig];
                        
                        NSMutableData *key = [MTExp(concreteChat.g_a_or_b, aBytes, config.p) mutableCopy];
                        
                        if (key.length > 256)
                            [key replaceBytesInRange:NSMakeRange(0, 1) withBytes:NULL length:0];
                        while (key.length < 256)
                        {
                            uint8_t zero = 0;
                            [key replaceBytesInRange:NSMakeRange(0, 0) withBytes:&zero length:1];
                            TGLog(@"(adding key padding)");
                        }
                        
                        NSData *keyHash = MTSha1(key);
                        NSData *nKeyId = [[NSData alloc] initWithBytes:(((uint8_t *)keyHash.bytes) + keyHash.length - 8) length:8];
                        int64_t keyId = 0;
                        [nKeyId getBytes:&keyId length:8];
                        
                        if (keyId == concreteChat.key_fingerprint)
                        {
                            conversation.encryptedData.handshakeState = 4;
                            
                            [TGDatabaseInstance() storeEncryptionKeyForConversationId:conversation.conversationId key:key keyFingerprint:keyId];
                            
                            conversation.encryptedData.keyFingerprint = keyId;
                        }
                        else
                        {
                            conversation.encryptedData.handshakeState = 3;
                            
                            [ActionStageInstance() requestActor:[[NSString alloc] initWithFormat:@"/tg/encrypted/discardEncryptedChat/(%" PRId64 ")", (int64_t)concreteChat.n_id] options:@{@"encryptedConversationId": @((int64_t)concreteChat.n_id)} flags:0 watcher:TGTelegraphInstance];
                        }
                    }
                }
                else if ([updateEncryption.chat isKindOfClass:[TLEncryptedChat$encryptedChatDiscarded class]])
                {
                    if ([TGDatabaseInstance() loadConversationWithId:conversation.conversationId] != nil)
                    {
                        updatedEncryptedChats[@(conversation.conversationId)] = conversation;
                        
                        conversation.encryptedData.handshakeState = 3;
                    }
                    else
                        TGLog(@"***** ignoring discarded encryption in chat %lld", updateEncryption.chat.n_id);
                }
                else if ([updateEncryption.chat isKindOfClass:[TLEncryptedChat$encryptedChatEmpty class]])
                {
                    TGLog(@"***** empty chat %lld in updateEncryption", updateEncryption.chat.n_id);
                }
            }
        }
        else if ([update isKindOfClass:[TLUpdate$updateNewEncryptedMessage class]])
        {
            TLEncryptedMessage *encryptedMessage = ((TLUpdate$updateNewEncryptedMessage *)update).message;
            
            int64_t conversationId = 0;
            int32_t fromUid = 0;
            TLDecryptedMessage *decryptedMessage = [TGUpdateStateRequestBuilder decryptMessageObject:encryptedMessage cachedPeerIds:&cachedPeerIds cachedKeys:&cachedKeys cachedParticipantIds:&cachedParticipantIds outConversationId:&conversationId outFromUid:&fromUid];
            if (decryptedMessage != nil)
            {
                bool decodeMessage = false;
                bool flushHistory = false;
                NSDictionary *decryptedAction = [TGUpdateStateRequestBuilder parseDecryptedAction:decryptedMessage conversationId:conversationId decodeMessageWithAction:&decodeMessage flushHistory:&flushHistory];
                if (decryptedAction != nil)
                    [newAddedEncryptedActions addObject:decryptedAction];
                
                if (decryptedAction == nil || decodeMessage)
                {
                    TGMessage *message = [TGUpdateStateRequestBuilder parseDecryptedMessage:decryptedMessage encryptedMessage:encryptedMessage conversationId:conversationId fromUid:fromUid];
                    if (message != nil)
                        [addedMessages addObject:message];
                }
            }
        }
        else if ([update isKindOfClass:[TLUpdate$updateDcOptions class]])
        {
            TLUpdate$updateDcOptions *datacenterOptionsUpdate = (TLUpdate$updateDcOptions *)update;
            
            for (TLDcOption *datacenterOption in datacenterOptionsUpdate.dc_options)
            {
                if (datacenterOption.ip_address.length == 0)
                    continue;
                
                [[TGTelegramNetworking instance] mergeDatacenterAddress:datacenterOption.n_id address:[[MTDatacenterAddress alloc] initWithIp:datacenterOption.ip_address port:(uint16_t)(datacenterOption.port == 0 ? 443 : datacenterOption.port)]];
            }
        }
        else if ([update isKindOfClass:[TLUpdate$updateUserBlocked class]])
        {
            TLUpdate$updateUserBlocked *userBlocked = (TLUpdate$updateUserBlocked *)update;
            
            if ([TGDatabaseInstance() loadUser:userBlocked.user_id] != nil)
            {
                [TGDatabaseInstance() setPeerIsBlocked:userBlocked.user_id blocked:userBlocked.blocked writeToActionQueue:false];
                dispatchBlocked = true;
            }
        }
        else if ([update isKindOfClass:[TLUpdate$updateNotifySettings class]])
        {
            TLUpdate$updateNotifySettings *notifySettings = (TLUpdate$updateNotifySettings *)update;
            
            int64_t peerId = 0;
            if ([notifySettings.peer isKindOfClass:[TLNotifyPeer$notifyPeer class]])
            {
                TLNotifyPeer$notifyPeer *concretePeer = (TLNotifyPeer$notifyPeer *)notifySettings.peer;
                if ([concretePeer.peer isKindOfClass:[TLPeer$peerUser class]])
                    peerId = ((TLPeer$peerUser *)concretePeer.peer).user_id;
                else if ([concretePeer.peer isKindOfClass:[TLPeer$peerChat class]])
                    peerId = -((TLPeer$peerChat *)concretePeer.peer).chat_id;
            }
            else if ([notifySettings.peer isKindOfClass:[TLNotifyPeer$notifyAll class]])
            {
            }
            else if ([notifySettings.peer isKindOfClass:[TLNotifyPeer$notifyChats class]])
                peerId = INT_MAX - 1;
            else if ([notifySettings.peer isKindOfClass:[TLNotifyPeer$notifyUsers class]])
                peerId = INT_MAX - 2;
            
            if (peerId != 0)
            {
                int peerSoundId = 0;
                int peerMuteUntil = 0;
                bool peerPreviewText = true;
                
                if ([notifySettings.notify_settings isKindOfClass:[TLPeerNotifySettings$peerNotifySettings class]])
                {
                    TLPeerNotifySettings$peerNotifySettings *concreteSettings = (TLPeerNotifySettings$peerNotifySettings *)notifySettings.notify_settings;
                    
                    peerMuteUntil = concreteSettings.mute_until;
                    
                    if (concreteSettings.sound.length == 0)
                        peerSoundId = 0;
                    else if ([concreteSettings.sound isEqualToString:@"default"])
                        peerSoundId = 1;
                    else
                        peerSoundId = [concreteSettings.sound intValue];
                    
                    peerPreviewText = concreteSettings.show_previews;
                    
                    [TGDatabaseInstance() storePeerNotificationSettings:peerId soundId:peerSoundId muteUntil:peerMuteUntil previewText:peerPreviewText photoNotificationsEnabled:false writeToActionQueue:false completion:^(bool changed)
                    {
                        if (changed)
                        {
                            NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:peerMuteUntil], @"muteUntil", [NSNumber numberWithInt:peerSoundId], @"soundId", [[NSNumber alloc] initWithBool:peerPreviewText], @"previewText", [[NSNumber alloc] initWithBool:false], @"photoNotificationsEnabled", nil];
                            
                            [ActionStageInstance() dispatchResource:[NSString stringWithFormat:@"/tg/peerSettings/(%lld)", peerId] resource:[[SGraphObjectNode alloc] initWithObject:dict]];
                        }
                    }];
                }
            }
        }
    }
    
    NSMutableArray *dispatchPeerPhotoListUpdatesArray = nil;
    
    if (userPhotoUpdates != nil)
    {
        std::vector<int> uidsList;
        
        for (NSDictionary *dict in userPhotoUpdates)
        {
            uidsList.push_back([dict[@"uid"] intValue]);
        }
        
        std::set<int> uidsWithEnabledNotifications = [TGDatabaseInstance() filterPeerPhotoNotificationsEnabled:uidsList];
        
        dispatchPeerPhotoListUpdatesArray = [[NSMutableArray alloc] init];
        
        for (NSDictionary *dict in userPhotoUpdates)
        {
            int64_t conversationId = [dict[@"uid"] intValue];
            if (uidsWithEnabledNotifications.find((int)conversationId) != uidsWithEnabledNotifications.end())
            {
                [dispatchPeerPhotoListUpdatesArray addObject:[[NSNumber alloc] initWithLongLong:conversationId]];
            }
        }
    }
    
    std::set<int> addedMessageIds;
    
    for (TLMessage *messageDesc in addedMessagesDesc)
    {
        TGMessage *message = [[TGMessage alloc] initWithTelegraphMessageDesc:messageDesc];
        if (message != nil && message.mid != 0 && ignoredConversationsForCurrentUser.find(message.cid) == ignoredConversationsForCurrentUser.end())
        {
            std::set<int>::iterator it = readMessageIds.find(message.mid);
            if (it != readMessageIds.end())
                message.unread = false;
            
            /*if (message.cid <= INT_MIN)
            {
                auto it = maxReadDateInEncryptedConversation.find(message.cid);
                if (it != maxReadDateInEncryptedConversation.end() && (int32_t)message.date <= it->second.first)
                    message.unread = false;
            }*/
            
            addedMessageIds.insert(message.mid);
            
            [addedMessages addObject:message];
        }
    }
    
    for (TGMessage *message in addedParsedMessages)
    {
        if (message.randomId != 0)
        {
            addingRandomIds.insert(message.randomId);
        }
        
        /*if (message.cid <= INT_MIN)
        {
            auto it = maxReadDateInEncryptedConversation.find(message.cid);
            if (it != maxReadDateInEncryptedConversation.end() && (int32_t)message.date <= it->second)
                message.unread = false;
        }*/
    }
    
    [newAddedEncryptedActions addObjectsFromArray:addedEncryptedActions];
    
    if (!addingRandomIds.empty())
        [TGDatabaseInstance() filterExistingRandomIds:&addingRandomIds];
    
    for (TGMessage *message in addedParsedMessages)
    {
        if (message != nil && (message.mid != 0 || message.local) && ignoredConversationsForCurrentUser.find(message.cid) == ignoredConversationsForCurrentUser.end())
        {
            if (message.randomId != 0 && addingRandomIds.find(message.randomId) == addingRandomIds.end())
            {
                TGLog(@"(filtered existing message %lld)", message.randomId);
                continue;
            }
            
            std::set<int>::iterator it = readMessageIds.find(message.mid);
            if (it != readMessageIds.end())
                message.unread = false;
            
            addedMessageIds.insert(message.mid);
            
            [addedMessages addObject:message];
        }
    }
    
    std::map<int64_t, NSMutableDictionary *> secretMessageFlagChangesByPeerId;
    
    for (NSDictionary *actionDesc in newAddedEncryptedActions)
    {
        NSString *actionType = actionDesc[@"actionType"];
        if ([actionType isEqualToString:@"viewMessage"])
        {
            int64_t randomId = (int64_t)[actionDesc[@"randomId"] longLongValue];
            [TGDatabaseInstance() raiseSecretMessageFlagsByRandomId:randomId flagsToRise:TGSecretMessageFlagViewed];
            
            NSNumber *nRandomId = @(randomId);
            
            NSMutableDictionary *peerMessageFlagChanges = secretMessageFlagChangesByPeerId[(int64_t)[actionDesc[@"peerId"] longLongValue]];
            if (peerMessageFlagChanges == nil)
            {
                peerMessageFlagChanges = [[NSMutableDictionary alloc] init];
                secretMessageFlagChangesByPeerId[(int64_t)[actionDesc[@"peerId"] longLongValue]] = peerMessageFlagChanges;
            }
            
            if (peerMessageFlagChanges[nRandomId] == nil)
                peerMessageFlagChanges[nRandomId] = @(TGSecretMessageFlagViewed);
            else
                peerMessageFlagChanges[nRandomId] = @([peerMessageFlagChanges[nRandomId] intValue] | TGSecretMessageFlagViewed);
        }
        else if ([actionType isEqualToString:@"screenshotMessage"])
        {
            int64_t randomId = (int64_t)[actionDesc[@"randomId"] longLongValue];
            [TGDatabaseInstance() raiseSecretMessageFlagsByRandomId:randomId flagsToRise:TGSecretMessageFlagScreenshot];
            
            NSNumber *nRandomId = @(randomId);

            NSMutableDictionary *peerMessageFlagChanges = secretMessageFlagChangesByPeerId[(int64_t)[actionDesc[@"peerId"] longLongValue]];
            if (peerMessageFlagChanges == nil)
            {
                peerMessageFlagChanges = [[NSMutableDictionary alloc] init];
                secretMessageFlagChangesByPeerId[(int64_t)[actionDesc[@"peerId"] longLongValue]] = peerMessageFlagChanges;
            }
            
            if (peerMessageFlagChanges[nRandomId] == nil)
                peerMessageFlagChanges[nRandomId] = @(TGSecretMessageFlagScreenshot);
            else
                peerMessageFlagChanges[nRandomId] = @([peerMessageFlagChanges[nRandomId] intValue] | TGSecretMessageFlagScreenshot);
        }
        else if ([actionType isEqualToString:@"deleteMessages"])
        {
            std::map<int64_t, int32_t> mapping;
            [TGDatabaseInstance() messageIdsForRandomIds:actionDesc[@"randomIds"] mapping:&mapping];
            
            for (auto it : mapping)
            {
                deleteMessageIds.insert(it.second);
            }
            
            for (NSNumber *nRandomId in actionDesc[@"randomIds"])
            {
                int64_t randomId = [nRandomId longLongValue];
                int index = -1;
                for (TGMessage *message in addedMessages)
                {
                    index++;
                    if (message.randomId == randomId)
                    {
                        [addedMessages removeObjectAtIndex:index];
                        
                        break;
                    }
                }
            }
        }
        else if ([actionType isEqualToString:@"flushHistory"])
        {
            NSArray *messageIds = [TGDatabaseInstance() messageIdsInConversation:[actionDesc[@"peerId"] longLongValue]];
            for (NSNumber *nMid in messageIds)
            {
                deleteMessageIds.insert([nMid intValue]);
            }
        }
    }
    
    if (!messageIdUpdates.empty())
    {
        NSMutableArray *tempMessageIds = [[NSMutableArray alloc] init];
        
        for (auto it : messageIdUpdates)
        {
            [tempMessageIds addObject:[[NSNumber alloc] initWithLongLong:it.first]];
        }
        
        std::map<int64_t, int> messageIdMap;
        [TGDatabaseInstance() messageIdsForTempIds:tempMessageIds mapping:&messageIdMap];
        
        for (auto it : messageIdUpdates)
        {
            auto clientIt = messageIdMap.find(it.first);
            if (clientIt != messageIdMap.end() && it.second != clientIt->second)
            {
                std::vector<TGDatabaseMessageFlagValue> flags;
                TGDatabaseMessageFlagValue midValue = { TGDatabaseMessageFlagMid, it.second };
                flags.push_back(midValue);
                TGDatabaseMessageFlagValue deliveryStateValue = { TGDatabaseMessageFlagDeliveryState, TGMessageDeliveryStateDelivered };
                flags.push_back(deliveryStateValue);
                
                [TGDatabaseInstance() updateMessage:clientIt->second flags:flags media:nil dispatch:addedMessageIds.find(it.second) == addedMessageIds.end()];
            }
            
            [TGDatabaseInstance() setTempIdForMessageId:it.second tempId:it.first];
        }
    }
    
    static int messageActionId = 1000000;
    if (addedMessages.count != 0)
    {
        if ([ActionStageInstance() isExecutingActorsWithGenericPath:@"/tg/sendCommonMessage/@/@"] || [ActionStageInstance() isExecutingActorsWithGenericPath:@"/tg/sendSecretMessage/@/@"])
        {
            std::map<int64_t, bool> checkedConversations;
            
            int count = addedMessages.count;
            for (int i = 0; i < count; i++)
            {
                TGMessage *message = [addedMessages objectAtIndex:i];
                
                if (message.outgoing)
                {
                    bool isSendingMessages = false;
                    
                    std::map<int64_t, bool>::iterator it = checkedConversations.find(message.cid);
                    if (it == checkedConversations.end())
                    {
                        isSendingMessages = [ActionStageInstance() isExecutingActorsWithPathPrefix:[[NSString alloc] initWithFormat:@"/tg/sendCommonMessage/(%" PRId64 ")/", message.cid]];
                        if (!isSendingMessages)
                        {
                            isSendingMessages = [ActionStageInstance() isExecutingActorsWithPathPrefix:[[NSString alloc] initWithFormat:@"/tg/sendSecretMessage/(%" PRId64 ")/", message.cid]];
                        }
                        checkedConversations.insert(std::pair<int64_t, bool>(message.cid, isSendingMessages));
                    }
                    else
                        isSendingMessages = it->second;
                    
                    if (isSendingMessages)
                    {
                        id key = [[NSNumber alloc] initWithLongLong:message.cid];
                        NSArray *delayedMessagesDesc = [delayedMessagesInConversations() objectForKey:key];
                        if (delayedMessagesDesc == nil)
                        {
                            delayedMessagesDesc = [[NSArray alloc] initWithObjects:[[NSMutableArray alloc] init], [[NSMutableDictionary alloc] init], nil];
                            [delayedMessagesInConversations() setObject:delayedMessagesDesc forKey:key];
                        }
                        
                        NSMutableArray *delayedMessages = [delayedMessagesDesc objectAtIndex:0];
                        NSMutableDictionary *delayedMessagesChats = [delayedMessagesDesc objectAtIndex:1];
                        [delayedMessages addObject:message];
                        [delayedMessagesChats addEntriesFromDictionary:chatItems];
                        
                        [addedMessages removeObjectAtIndex:i];
                        i--;
                        count--;
                    }
                }
            }
        }
    }
    
    if (updatedEncryptedChats.count != 0)
    {
        [[[TGConversationAddMessagesActor alloc] initWithPath:[NSString stringWithFormat:@"/tg/addmessage/(%dcf)", messageActionId++]] execute:[NSDictionary dictionaryWithObjectsAndKeys:updatedEncryptedChats, @"chats", nil]];
    }
    
    if (addedMessages.count != 0)
    {
        [[[TGConversationAddMessagesActor alloc] initWithPath:[NSString stringWithFormat:@"/tg/addmessage/(%dcf)", messageActionId++]] execute:[NSDictionary dictionaryWithObjectsAndKeys:addedMessages, @"messages", chatItems, @"chats", nil]];
    }
    
    if (!secretMessageFlagChangesByPeerId.empty())
    {
        auto pSecretMessageFlagChangesByPeerId = &secretMessageFlagChangesByPeerId;
        
        std::map<int64_t, NSMutableDictionary *> secretMessageFlagChangesByPeerIdWithMessageIds;
        auto pSecretMessageFlagChangesByPeerIdWithMessageIds = &secretMessageFlagChangesByPeerIdWithMessageIds;
        
        [TGDatabaseInstance() dispatchOnDatabaseThread:^
        {
            for (auto it = pSecretMessageFlagChangesByPeerId->begin(); it != pSecretMessageFlagChangesByPeerId->end(); it++)
            {
                [it->second enumerateKeysAndObjectsUsingBlock:^(NSNumber *nRandomId, NSNumber *nFlags, __unused BOOL *stop)
                {
                    int32_t messageId = [TGDatabaseInstance() messageIdForRandomId:(int64_t)[nRandomId longLongValue]];
                    if (messageId != 0)
                    {
                        NSMutableDictionary *peerMessageFlagsByMessageId = (*pSecretMessageFlagChangesByPeerIdWithMessageIds)[it->first];
                        if (peerMessageFlagsByMessageId == nil)
                        {
                            peerMessageFlagsByMessageId = [[NSMutableDictionary alloc] init];
                            (*pSecretMessageFlagChangesByPeerIdWithMessageIds)[it->first] = peerMessageFlagsByMessageId;
                        }
                        
                        peerMessageFlagsByMessageId[@(messageId)] = nFlags;
                    }
                }];
            };
        } synchronous:true];
        
        for (auto it = secretMessageFlagChangesByPeerIdWithMessageIds.begin(); it != secretMessageFlagChangesByPeerIdWithMessageIds.end(); it++)
        {
            if (it->second.count != 0)
            {
                [ActionStageInstance() dispatchResource:[[NSString alloc] initWithFormat:@"/tg/conversation/(%" PRId64 ")/messageFlagChanges", it->first] resource:it->second];
            }
        }
    }
    
    static int readMessagesCounter = 0;
    NSMutableArray *readMessageIdsArray = [[NSMutableArray alloc] initWithCapacity:readMessageIds.size()];
    for (std::set<int>::iterator it = readMessageIds.begin(); it != readMessageIds.end(); it++)
    {
        [readMessageIdsArray addObject:[[NSNumber alloc] initWithInt:*it]];
    }
    
    if (readMessageIdsArray.count != 0)
    {
        [[[TGConversationReadMessagesActor alloc] initWithPath:[NSString stringWithFormat:@"/tg/readmessages/(hfs%d)", readMessagesCounter++]] execute:[NSDictionary dictionaryWithObjectsAndKeys:readMessageIdsArray, @"mids", nil]];
    }
    
    if (!maxReadDateInEncryptedConversation.empty())
    {
        for (auto it : maxReadDateInEncryptedConversation)
        {
            [TGDatabaseInstance() markMessagesAsReadInConversation:it.first maxDate:it.second.first referenceDate:it.second.second];
            
            [ActionStageInstance() dispatchResource:[[NSString alloc] initWithFormat:@"/tg/conversation/(%lld)/readByDateMessages", it.first] resource:@{@"maxDate": [[NSNumber alloc] initWithInt:it.second.first]}];
        }
    }
    
    NSMutableArray *deleteMessageIdsArray = [[NSMutableArray alloc] initWithCapacity:deleteMessageIds.size()];
    for (std::set<int>::iterator it = deleteMessageIds.begin(); it != deleteMessageIds.end(); it++)
    {
        [deleteMessageIdsArray addObject:[[NSNumber alloc] initWithInt:*it]];
    }
    
    if (deleteMessageIdsArray.count != 0)
    {
        NSMutableDictionary *messagesByConversation = [[NSMutableDictionary alloc] init];
        [TGDatabaseInstance() deleteMessages:deleteMessageIdsArray populateActionQueue:false fillMessagesByConversationId:messagesByConversation];
        [messagesByConversation enumerateKeysAndObjectsUsingBlock:^(NSNumber *nConversationId, NSArray *messagesInConversation, __unused BOOL *stop)
        {
            [ActionStageInstance() dispatchResource:[[NSString alloc] initWithFormat:@"/tg/conversation/(%lld)/messagesDeleted", [nConversationId longLongValue]] resource:[[SGraphObjectNode alloc] initWithObject:messagesInConversation]];
        }];
    }
    
    NSMutableArray *chatParticipantsArray = [[NSMutableArray alloc] init];
    
    if (chatParticipantsDesc != nil)
        [chatParticipantsArray addObjectsFromArray:chatParticipantsDesc];
    
    for (auto it = chatParticipantUpdateArrays.begin(); it != chatParticipantUpdateArrays.end(); it++)
    {
        for (auto it2 = it->second.begin(); it2 != it->second.end(); it2++)
        {
            id update = *(it2);
            if ([update isKindOfClass:[TLChatParticipants class]])
                [chatParticipantsArray addObject:update];
        }
    }
    
    for (TLChatParticipants *chatParticipants in chatParticipantsArray)
    {
        TGConversationParticipantsData *participantsData = [[TGConversationParticipantsData alloc] initWithTelegraphParticipantsDesc:chatParticipants];
        [TGDatabaseInstance() storeConversationParticipantData:-chatParticipants.chat_id participantData:participantsData];
    }
    
    for (auto it = chatParticipantUpdateArrays.begin(); it != chatParticipantUpdateArrays.end(); it++)
    {
        for (auto it2 = it->second.begin(); it2 != it->second.end(); it2++)
        {
            id update = *(it2);
            
            if ([update isKindOfClass:[TLUpdate$updateChatParticipantAdd class]] || [update isKindOfClass:[TLUpdate$updateChatParticipantDelete class]])
            {
                int date = 0;
                for (NSArray *item in updatesWithDates)
                {
                    if (item == update)
                        date = [item[1] intValue];
                }
                
                int64_t conversationId = 0;
                int version = 0;
                int32_t userId = 0;
                
                if ([update isKindOfClass:[TLUpdate$updateChatParticipantAdd class]])
                {
                    conversationId = -((TLUpdate$updateChatParticipantAdd *)update).chat_id;
                    version = ((TLUpdate$updateChatParticipantAdd *)update).version;
                    userId = ((TLUpdate$updateChatParticipantAdd *)update).user_id;
                }
                else
                {
                    conversationId = -((TLUpdate$updateChatParticipantDelete *)update).chat_id;
                    version = ((TLUpdate$updateChatParticipantDelete *)update).version;
                    userId = ((TLUpdate$updateChatParticipantDelete *)update).user_id;
                }
                
                TGConversation *conversation = [TGDatabaseInstance() loadConversationWithId:conversationId];
                if (conversation != 0 && conversation.chatParticipants != nil && conversation.chatParticipants.version < version)
                {
                    TGConversationParticipantsData *participants = [[conversation chatParticipants] copy];
                    if ([update isKindOfClass:[TLUpdate$updateChatParticipantAdd class]])
                        [participants addParticipantWithId:userId invitedBy:((TLUpdate$updateChatParticipantAdd *)update).inviter_id date:date];
                    else
                        [participants removeParticipantWithId:userId];
                    
                    participants.version = version;
                    
                    [TGDatabaseInstance() storeConversationParticipantData:conversationId participantData:participants];
                }
            }
        }
    }
    
    for (int64_t encryptedConversationId : acceptEncryptedChats)
    {
        [TGDatabaseInstance() storeFutureActions:@[[[TGAcceptEncryptionFutureAction alloc] initWithEncryptedConversationId:encryptedConversationId]]];
    }
    
    if (!acceptEncryptedChats.empty())
        [ActionStageInstance() requestActor:@"/tg/service/synchronizeserviceactions/(settings)" options:nil watcher:TGTelegraphInstance];
    
    for (id update in userTypingUpdates)
    {
        if ([update isKindOfClass:updateUserTypingClass])
        {
            TLUpdate$updateUserTyping *userTyping = (TLUpdate$updateUserTyping *)update;
            
            if ([TGDatabaseInstance() loadUser:userTyping.user_id] != nil)
                [TGTelegraphInstance dispatchUserTyping:userTyping.user_id inConversation:userTyping.user_id typing:true];
        }
        else if ([update isKindOfClass:updateChatUserTypingClass])
        {
            TLUpdate$updateChatUserTyping *userTyping = (TLUpdate$updateChatUserTyping *)update;
            
            if ([TGDatabaseInstance() loadUser:userTyping.user_id] != nil)
                [TGTelegraphInstance dispatchUserTyping:userTyping.user_id inConversation:-userTyping.chat_id typing:true];
        }
        else if ([update isKindOfClass:updateEncryptedChatTypingClass])
        {
            TLUpdate$updateEncryptedChatTyping *updateEncryptedChatTyping = (TLUpdate$updateEncryptedChatTyping *)update;
            
            int64_t conversationId = [TGDatabaseInstance() peerIdForEncryptedConversationId:updateEncryptedChatTyping.chat_id createIfNecessary:false];
            if (conversationId != 0)
            {
                int uid = [TGDatabaseInstance() encryptedParticipantIdForConversationId:conversationId];
                if (uid != 0)
                {
                    [TGTelegraphInstance dispatchUserTyping:uid inConversation:conversationId typing:true];
                }
            }
        }
    }
    
    if (dispatchPeerPhotoListUpdatesArray != nil)
    {
        for (NSNumber *nPeerId in dispatchPeerPhotoListUpdatesArray)
        {
            [TGDatabaseInstance() dispatchOnDatabaseThread:^
            {
                [TGDatabaseInstance() loadPeerProfilePhotos:[nPeerId longLongValue] completion:^(NSArray *photosArray)
                {
                    if (photosArray != nil)
                    {
                        [ActionStageInstance() dispatchResource:[[NSString alloc] initWithFormat:@"/tg/profilePhotos/(%lld)", [nPeerId longLongValue]] resource:photosArray];
                    }
                }];
            } synchronous:false];
        }
    }
    
    if (dispatchBlocked)
    {
        [TGDatabaseInstance() loadBlockedList:^(NSArray *blockedList)
        {
            NSMutableArray *users = [[NSMutableArray alloc] init];
            for (NSNumber *nUid in blockedList)
            {
                TGUser *user = [TGDatabaseInstance() loadUser:[nUid intValue]];
                if (user != nil)
                    [users addObject:user];
            }
            [ActionStageInstance() dispatchResource:@"/tg/blockedUsers" resource:[[SGraphObjectNode alloc] initWithObject:users]];
        }];
    }
    
    return true;
}

+ (void)processDelayedMessagesInConversation:(int64_t)conversationId completedPath:(NSString *)path
{
    NSArray *delayedMessagesDesc = [delayedMessagesInConversations() objectForKey:[[NSNumber alloc] initWithLongLong:conversationId]];
    if (delayedMessagesDesc != nil)
    {
        bool isSendingMessages = false;
        
        for (ASActor *actor in [ActionStageInstance() executingActorsWithPathPrefix:[[NSString alloc] initWithFormat:@"/tg/sendCommonMessage/(%" PRId64 ")/", conversationId]])
        {
            if (![actor.path isEqualToString:path])
            {
                isSendingMessages = true;
                break;
            }
        }
        
        if (!isSendingMessages)
        {
            for (ASActor *actor in [ActionStageInstance() executingActorsWithPathPrefix:[[NSString alloc] initWithFormat:@"/tg/sendSecretMessage/(%" PRId64 ")/", conversationId]])
            {
                if (![actor.path isEqualToString:path])
                {
                    isSendingMessages = true;
                    break;
                }
            }
        }
        
        if (!isSendingMessages)
            [TGUpdateStateRequestBuilder applyDelayedOutgoingMessages:conversationId];
    }
}

+ (void)applyDelayedOutgoingMessages:(int64_t)conversationId
{
    id key = [[NSNumber alloc] initWithLongLong:conversationId];
    NSArray *messagesDesc = [delayedMessagesInConversations() objectForKey:key];
    if (messagesDesc != nil)
    {
        NSMutableArray *messages = [messagesDesc objectAtIndex:0];
        NSMutableDictionary *chats = [messagesDesc objectAtIndex:1];
        [[[TGConversationAddMessagesActor alloc] initWithPath:@"/tg/addmessage/(meta)"] execute:[NSDictionary dictionaryWithObjectsAndKeys:messages, @"messages", chats, @"chats", nil]];
        
        [delayedMessagesInConversations() removeObjectForKey:key];
    }
}

- (void)stateDeltaRequestSuccess:(TLupdates_Difference *)difference
{
    if ([difference isKindOfClass:[TLupdates_Difference$updates_difference class]] || [difference isKindOfClass:[TLupdates_Difference$updates_differenceSlice class]])
    {
        NSArray *newMessages = ((TLupdates_Difference$updates_difference *)difference).n_new_messages;
        NSMutableArray *newEncryptedMessages = nil;
        NSMutableArray *newEncryptedActions = nil;
        
        if (((TLupdates_Difference$updates_difference *)difference).n_new_encrypted_messages.count != 0)
        {
            newEncryptedMessages = [[NSMutableArray alloc] initWithCapacity:((TLupdates_Difference$updates_difference *)difference).n_new_encrypted_messages.count];
            newEncryptedActions = [[NSMutableArray alloc] init];
            
            std::map<int64_t, int64_t> cachedPeerIds;
            std::map<int64_t, std::pair<int64_t, NSData *> > cachedKeys;
            std::map<int64_t, int32_t> cachedParticipantIds;
            
            for (TLEncryptedMessage *encryptedMessage in ((TLupdates_Difference$updates_difference *)difference).n_new_encrypted_messages)
            {
                int64_t conversationId = 0;
                int32_t fromUid = 0;
                TLDecryptedMessage *decryptedMessage = [TGUpdateStateRequestBuilder decryptMessageObject:encryptedMessage cachedPeerIds:&cachedPeerIds cachedKeys:&cachedKeys cachedParticipantIds:&cachedParticipantIds outConversationId:&conversationId outFromUid:&fromUid];
                if (decryptedMessage != nil)
                {
                    bool decodeMessage = false;
                    bool flushHistory = false;
                    NSDictionary *decryptedAction = [TGUpdateStateRequestBuilder parseDecryptedAction:decryptedMessage conversationId:conversationId decodeMessageWithAction:&decodeMessage flushHistory:&flushHistory];
                    
                    if (flushHistory)
                        [newEncryptedMessages removeAllObjects];
                    
                    if (decryptedAction != nil)
                        [newEncryptedActions addObject:decryptedAction];
                    
                    if (decryptedAction == nil || decodeMessage)
                    {
                        TGMessage *message = [TGUpdateStateRequestBuilder parseDecryptedMessage:decryptedMessage encryptedMessage:encryptedMessage conversationId:conversationId fromUid:fromUid];
                        if (message != nil)
                            [newEncryptedMessages addObject:message];
                    }
                }
            }
        }
        
        NSArray *otherUpdates = ((TLupdates_Difference$updates_difference *)difference).other_updates;
        NSArray *usersDesc = ((TLupdates_Difference$updates_difference *)difference).users;
        NSArray *chatsDesc = ((TLupdates_Difference$updates_difference *)difference).chats;
        
        [TGUpdateStateRequestBuilder applyUpdates:newMessages addedParsedMessages:newEncryptedMessages otherUpdates:otherUpdates addedEncryptedActions:newEncryptedActions usersDesc:usersDesc chatsDesc:chatsDesc chatParticipantsDesc:nil updatesWithDates:nil];
    }
    
    static int applyStateCounter = 0;
    
    if ([difference isKindOfClass:[TLupdates_Difference$updates_differenceSlice class]])
    {
        TLupdates_Difference$updates_differenceSlice *concreteDifference = (TLupdates_Difference$updates_differenceSlice *)difference;
        
        [[[TGApplyStateRequestBuilder alloc] initWithPath:[NSString stringWithFormat:@"/tg/service/applystate/(c%d)", applyStateCounter++]] execute:[[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:concreteDifference.intermediate_state.pts], @"pts", [NSNumber numberWithInt:concreteDifference.intermediate_state.date], @"date", [NSNumber numberWithInt:concreteDifference.intermediate_state.seq], @"seq", @(concreteDifference.intermediate_state.qts), @"qts", [NSNumber numberWithInt:-1], @"unreadCount", nil]];
        
        self.cancelToken = [TGTelegraphInstance doRequestStateDelta:concreteDifference.intermediate_state.pts date:concreteDifference.intermediate_state.date qts:concreteDifference.intermediate_state.qts requestBuilder:self];
    }
    else if ([difference isKindOfClass:[TLupdates_Difference$updates_difference class]] || [difference isKindOfClass:[TLupdates_Difference$updates_differenceEmpty class]])
    {
        int differencePts = 0;
        if ([difference isKindOfClass:[TLupdates_Difference$updates_difference class]])
            differencePts = ((TLupdates_Difference$updates_difference *)difference).state.pts;
        
        int differenceDate = 0;
        int differenceQts = 0;
        
        int differenceSeq = 0;
        if ([difference isKindOfClass:[TLupdates_Difference$updates_difference class]])
        {
            differenceSeq = ((TLupdates_Difference$updates_difference *)difference).state.seq;
            differenceDate = ((TLupdates_Difference$updates_difference *)difference).state.date;
            differenceQts = ((TLupdates_Difference$updates_difference *)difference).state.qts;
        }
        else if ([difference isKindOfClass:[TLupdates_Difference$updates_differenceEmpty class]])
        {
            differenceSeq = ((TLupdates_Difference$updates_differenceEmpty *)difference).seq;
            differenceDate = ((TLupdates_Difference$updates_differenceEmpty *)difference).date;
        }
        
        if (differenceQts > 0)
        {
            [TGDatabaseInstance() updateLatestQts:differenceQts applied:false completion:^(int greaterQtsForSynchronization)
            {
                if (greaterQtsForSynchronization > 0)
                {
                    [ActionStageInstance() requestActor:[[NSString alloc] initWithFormat:@"/tg/messages/reportDelivery/(qts)"] options:[[NSDictionary alloc] initWithObjectsAndKeys:[[NSNumber alloc] initWithInt:differenceQts], @"qts", nil] watcher:TGTelegraphInstance];
                }
            }];
        }
        
        [[[TGApplyStateRequestBuilder alloc] initWithPath:[NSString stringWithFormat:@"/tg/service/applystate/(d%d)", applyStateCounter++]] execute:[[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:differencePts], @"pts", [NSNumber numberWithInt:differenceDate], @"date", [NSNumber numberWithInt:differenceSeq], @"seq", @(differenceQts), @"qts", [NSNumber numberWithInt:-1], @"unreadCount", nil]];
        
        [self completeDifferenceUpdate];

        int state = 0;
        if ([[TGTelegramNetworking instance] isUpdating])
            state |= 1;
        if ([[TGTelegramNetworking instance] isConnecting])
            state |= 2;
        if (![[TGTelegramNetworking instance] isNetworkAvailable])
            state |= 4;
        
        [ActionStageInstance() dispatchResource:@"/tg/service/synchronizationstate" resource:[[SGraphObjectNode alloc] initWithObject:[NSNumber numberWithInt:state]]];
        
        [ActionStageInstance() dispatchResource:@"/tg/service/stateUpdated" resource:nil];
        
        [ActionStageInstance() requestActor:@"/tg/service/synchronizeserviceactions/(settings)" options:nil watcher:TGTelegraphInstance];
        
        if (!didRequestUpdates)
        {
            didRequestUpdates = true;
            [ActionStageInstance() requestActor:@"/tg/service/checkUpdates" options:nil watcher:TGTelegraphInstance];
        }
        
        [ActionStageInstance() requestActor:@"/tg/updateUserStatuses" options:nil watcher:TGTelegraphInstance];
        
        [TGDatabaseInstance() tempIdsForLocalMessages:^(std::vector<std::pair<int64_t, int> > mapping)
        {
            if (!mapping.empty())
            {
                NSMutableArray *tempIds = [[NSMutableArray alloc] initWithCapacity:mapping.size()];
                NSMutableArray *failMids = [[NSMutableArray alloc] initWithCapacity:mapping.size()];
                
                for (auto item : mapping)
                {
                    [tempIds addObject:[[NSNumber alloc] initWithLongLong:item.first]];
                    [failMids addObject:[[NSNumber alloc] initWithLongLong:item.second]];
                    
                    std::vector<TGDatabaseMessageFlagValue> flags;
                    TGDatabaseMessageFlagValue deliveryFlag = { TGDatabaseMessageFlagDeliveryState, TGMessageDeliveryStateFailed };
                    flags.push_back(deliveryFlag);
                    
                    [TGDatabaseInstance() updateMessage:item.second flags:flags media:nil dispatch:true];
                }
                
                [TGDatabaseInstance() removeTempIds:tempIds];
                
                [ActionStageInstance() dispatchResource:@"/tg/conversation/*/failmessages" resource:@{@"mids": failMids}];
            }
        }];
    }
    else
    {
        [ActionStageInstance() actionFailed:self.path reason:-1];
    }
}

- (void)stateDeltaRequestFailed
{
    [ActionStageInstance() actionFailed:self.path reason:-1];
    
    int state = 0;
    if ([[TGTelegramNetworking instance] isUpdating])
        state |= 1;
    if ([[TGTelegramNetworking instance] isConnecting])
        state |= 2;
    if (![[TGTelegramNetworking instance] isNetworkAvailable])
        state |= 4;
    
    [ActionStageInstance() dispatchResource:@"/tg/service/synchronizationstate" resource:[[SGraphObjectNode alloc] initWithObject:[NSNumber numberWithInt:state]]];
}

- (void)stateRequestSuccess:(TLupdates_State *)state
{
    _state = state;
    
    [ActionStageInstance() requestActor:[NSString stringWithFormat:@"/tg/dialoglist/(%d)", INT_MAX] options:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:true] forKey:@"inline"] watcher:self];
}

- (void)stateRequestFailed
{
    [ActionStageInstance() requestActor:[NSString stringWithFormat:@"/tg/dialoglist/(%d)", INT_MAX] options:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:true] forKey:@"inline"] watcher:self];
}

- (void)cancel
{
    if (self.cancelToken != nil)
    {
        [TGTelegraphInstance cancelRequestByToken:self.cancelToken];
        self.cancelToken = nil;
    }
    
    [super cancel];
}

+ (TGMessage *)parseDecryptedMessage:(TLDecryptedMessage *)decryptedMessage encryptedMessage:(TLEncryptedMessage *)encryptedMessage conversationId:(int64_t)conversationId fromUid:(int32_t)fromUid
{
    TLEncryptedFile *encryptedFile = nil;
    if ([encryptedMessage isKindOfClass:[TLEncryptedMessage$encryptedMessage class]])
        encryptedFile = ((TLEncryptedMessage$encryptedMessage *)encryptedMessage).file;
    
    TGMessage *message = [[TGMessage alloc] initWithTelegraphDecryptedMessageDesc:decryptedMessage encryptedFile:encryptedFile conversationId:conversationId fromUid:fromUid date:encryptedMessage.date];
    message.mid = INT_MIN;
    
    return message;
}

+ (NSDictionary *)parseDecryptedAction:(TLDecryptedMessage *)decryptedMessage conversationId:(int64_t)conversationId decodeMessageWithAction:(bool *)decodeMessageWithAction flushHistory:(bool *)flushHistory
{
    if ([decryptedMessage isKindOfClass:[TLDecryptedMessage$decryptedMessageService class]])
    {
        TLDecryptedMessageAction *action = ((TLDecryptedMessage$decryptedMessageService *)decryptedMessage).action;
        
        if ([action isKindOfClass:[TLDecryptedMessageAction$decryptedMessageActionViewMessage class]])
        {
            TLDecryptedMessageAction$decryptedMessageActionViewMessage *concreteAction = (TLDecryptedMessageAction$decryptedMessageActionViewMessage *)action;
            
            return @{
                @"peerId": @(conversationId),
                @"actionType": @"viewMessage",
                @"randomId": @(concreteAction.random_id)
            };
        }
        else if ([action isKindOfClass:[TLDecryptedMessageAction$decryptedMessageActionScreenshotMessage class]])
        {
            TLDecryptedMessageAction$decryptedMessageActionScreenshotMessage *concreteAction = (TLDecryptedMessageAction$decryptedMessageActionScreenshotMessage *)action;
            
            if (decodeMessageWithAction != NULL)
                *decodeMessageWithAction = true;
            
            return @{
                @"peerId": @(conversationId),
                @"actionType": @"screenshotMessage",
                @"randomId": @(concreteAction.random_id)
            };
        }
        else if ([action isKindOfClass:[TLDecryptedMessageAction$decryptedMessageActionDeleteMessages class]])
        {
            TLDecryptedMessageAction$decryptedMessageActionDeleteMessages *concreteAction = (TLDecryptedMessageAction$decryptedMessageActionDeleteMessages *)action;

            return @{
                @"peerId": @(conversationId),
                @"actionType": @"deleteMessages",
                @"randomIds": concreteAction.random_ids == nil ? @[] : concreteAction.random_ids
            };
        }
        else if ([action isKindOfClass:[TLDecryptedMessageAction$decryptedMessageActionFlushHistory class]])
        {
            if (flushHistory != NULL)
                *flushHistory = true;
            
            return @{
                @"peerId": @(conversationId),
                @"actionType": @"flushHistory"
            };
        }
    }
    
    return nil;
}

+ (TLDecryptedMessage *)decryptMessageObject:(TLEncryptedMessage *)encryptedMessage cachedPeerIds:(std::map<int64_t, int64_t> *)cachedPeerIds cachedKeys:(std::map<int64_t, std::pair<int64_t, NSData *> > *)cachedKeys cachedParticipantIds:(std::map<int64_t, int> *)cachedParticipantIds outConversationId:(int64_t *)outConversationId outFromUid:(int32_t *)outFromUid
{
    int64_t conversationId = 0;
    bool peerFound = false;
    
    if (cachedPeerIds != NULL)
    {
        auto it = cachedPeerIds->find(encryptedMessage.chat_id);
        if (it != cachedPeerIds->end())
        {
            conversationId = it->second;
            peerFound = true;
        }
    }
    
    if (!peerFound)
    {
        conversationId = [TGDatabaseInstance() peerIdForEncryptedConversationId:encryptedMessage.chat_id createIfNecessary:false];
        
        if (cachedPeerIds != NULL)
            (*cachedPeerIds)[encryptedMessage.chat_id] = conversationId;
    }
    
    if (encryptedMessage.bytes.length < 8 + 16 + 16)
    {
        TGLog(@"***** Ignoring message from conversation %lld (too short)", encryptedMessage.chat_id);
    }
    else if (conversationId != 0)
    {
        int64_t keyId = 0;
        [encryptedMessage.bytes getBytes:&keyId range:NSMakeRange(0, 8)];
        NSData *messageKey = [encryptedMessage.bytes subdataWithRange:NSMakeRange(8, 16)];
        
        int64_t localKeyId = 0;
        NSData *key = nil;
        bool keyFound = false;
        
        if (cachedKeys != NULL)
        {
            auto it = cachedKeys->find(conversationId);
            if (it != cachedKeys->end())
            {
                keyFound = true;
                localKeyId = it->second.first;
                key = it->second.second;
            }
        }
        
        if (!keyFound)
        {
            key = [TGDatabaseInstance() encryptionKeyForConversationId:conversationId keyFingerprint:&localKeyId];
            
            if (cachedKeys != NULL)
                (*cachedKeys)[conversationId] = std::pair<int64_t, NSData *>(localKeyId, key);
        }
        
        if (key != nil && keyId == localKeyId)
        {
            MessageKeyData keyData = [TGModernSendSecretMessageActor generateMessageKeyData:messageKey incoming:false key:key];
            
            NSMutableData *messageData = [[encryptedMessage.bytes subdataWithRange:NSMakeRange(8 + 16, encryptedMessage.bytes.length - (8 + 16))] mutableCopy];
            MTAesDecryptInplace(messageData, keyData.aesKey, keyData.aesIv);
            
            int32_t messageLength = 0;
            [messageData getBytes:&messageLength range:NSMakeRange(0, 4)];
            
            if (messageLength > (int32_t)messageData.length - 4)
                TGLog(@"***** Ignoring message from conversation %lld with invalid message length", encryptedMessage.chat_id);
            else
            {
                NSData *localMessageKeyFull = MTSubdataSha1(messageData, 0, messageLength + 4);
                NSData *localMessageKey = [[NSData alloc] initWithBytes:(((int8_t *)localMessageKeyFull.bytes) + localMessageKeyFull.length - 16) length:16];
                if (![localMessageKey isEqualToData:messageKey])
                    TGLog(@"***** Ignoring message from conversation with message key mismatch %lld", encryptedMessage.chat_id);
                else
                {
                    NSInputStream *is = [[NSInputStream alloc] initWithData:messageData];
                    [is open];
                    [is readInt32];
                    
                    int32_t signature = [is readInt32];
                    id decryptedObject = TLMetaClassStore::constructObject(is, signature, nil, nil, nil);
                    
                    [is close];
                    
                    if ([decryptedObject isKindOfClass:[TLDecryptedMessage$decryptedMessage class]] || [decryptedObject isKindOfClass:[TLDecryptedMessage$decryptedMessageService class]])
                    {
                        int fromUid = 0;
                        bool fromFound = false;
                        
                        if (cachedParticipantIds != NULL)
                        {
                            auto it = cachedParticipantIds->find(encryptedMessage.chat_id);
                            if (it != cachedParticipantIds->end())
                            {
                                fromFound = true;
                                fromUid = it->second;
                            }
                        }
                        
                        if (!fromFound)
                        {
                            fromUid = [TGDatabaseInstance() encryptedParticipantIdForConversationId:conversationId];
                            
                            if (cachedParticipantIds != NULL)
                                (*cachedParticipantIds)[encryptedMessage.chat_id] = fromUid;
                        }
                        
                        if (fromUid != 0)
                        {
                            if (outConversationId != NULL)
                                *outConversationId = conversationId;
                            
                            if (outFromUid != NULL)
                                *outFromUid = fromUid;
                            
                            return decryptedObject;
                        }
                        else
                            TGLog(@"***** Couldn't find participant uid for conversation %lld", encryptedMessage.chat_id);
                    }
                    else
                        TGLog(@"***** Ignoring unknown decrypted object %@", decryptedObject);
                }
            }
        }
        else if (key != nil && keyId != localKeyId)
            TGLog(@"***** Ignoring message from conversation with key fingerprint mismatch %lld", encryptedMessage.chat_id);
        else
            TGLog(@"***** Ignoring message from conversation with missing key %lld", encryptedMessage.chat_id);
    }
    else
    {
        TGLog(@"***** Ignoring message from unknown encrypted conversation %lld", encryptedMessage.chat_id);
        
        [ActionStageInstance() requestActor:[[NSString alloc] initWithFormat:@"/tg/encrypted/discardEncryptedChat/(%lld)", (int64_t)encryptedMessage.chat_id] options:@{@"encryptedConversationId": @((int64_t)encryptedMessage.chat_id)} flags:0 watcher:TGTelegraphInstance];
    }
    
    return nil;
}

@end
