#import "TGConversation.h"

#import "TGMessage.h"

@implementation TGEncryptedConversationData

- (BOOL)isEqualToEncryptedData:(TGEncryptedConversationData *)other
{
    if (_encryptedConversationId != other->_encryptedConversationId || _accessHash != other->_accessHash || _keyFingerprint != other->_keyFingerprint || _handshakeState != other->_handshakeState)
        return false;
    
    return true;
}

- (id)copyWithZone:(NSZone *)__unused zone
{
    TGEncryptedConversationData *data = [[TGEncryptedConversationData alloc] init];
    data->_encryptedConversationId = _encryptedConversationId;
    data->_accessHash = _accessHash;
    data->_keyFingerprint = _keyFingerprint;
    data->_handshakeState = _handshakeState;
    
    return data;
}

- (void)serialize:(NSMutableData *)data
{
    uint8_t version = 2;
    [data appendBytes:&version length:1];
    [data appendBytes:&_encryptedConversationId length:8];
    [data appendBytes:&_accessHash length:8];
    [data appendBytes:&_keyFingerprint length:8];
    [data appendBytes:&_handshakeState length:4];
}

+ (TGEncryptedConversationData *)deserialize:(NSData *)data ptr:(int *)ptr
{
    uint8_t version = 0;
    [data getBytes:&version range:NSMakeRange(*ptr, 1)];
    (*ptr) += 1;
    
    if (version != 1 && version != 2)
    {
        TGLog(@"***** Invalid encrypted data version");
        return nil;
    }
    
    TGEncryptedConversationData *encryptedData = [TGEncryptedConversationData new];

    [data getBytes:&encryptedData->_encryptedConversationId range:NSMakeRange(*ptr, 8)];
    (*ptr) += 8;
    
    [data getBytes:&encryptedData->_accessHash range:NSMakeRange(*ptr, 8)];
    (*ptr) += 8;
    
    [data getBytes:&encryptedData->_keyFingerprint range:NSMakeRange(*ptr, 8)];
    (*ptr) += 8;
    
    if (version == 2)
    {
        [data getBytes:&encryptedData->_handshakeState range:NSMakeRange(*ptr, 4)];
        *ptr += 4;
    }
    
    return encryptedData;
}

@end

@implementation TGConversationParticipantsData

- (id)init
{
    self = [super init];
    if (self != nil)
    {
        _serializedData = nil;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)__unused zone
{
    TGConversationParticipantsData *participantsData = [[TGConversationParticipantsData alloc] init];
    
    participantsData.chatAdminId = _chatAdminId;
    participantsData.chatInvitedBy = _chatInvitedBy;
    participantsData.chatInvitedDates = _chatInvitedDates;
    participantsData.chatParticipantUids = _chatParticipantUids;
    participantsData.chatParticipantSecretChatPeerIds = _chatParticipantSecretChatPeerIds;
    participantsData.chatParticipantChatPeerIds = _chatParticipantChatPeerIds;
    participantsData.version = _version;
    
    return participantsData;
}

- (void)addParticipantWithId:(int32_t)uid invitedBy:(int32_t)invitedBy date:(int32_t)date
{
    NSMutableArray *chatParticipantUids = [[NSMutableArray alloc] initWithArray:_chatParticipantUids];
    if (![chatParticipantUids containsObject:@(uid)])
    {
        [chatParticipantUids addObject:@(uid)];
        _chatParticipantUids = chatParticipantUids;
        
        NSMutableDictionary *chatInvitedBy = [[NSMutableDictionary alloc] initWithDictionary:_chatInvitedBy];
        chatInvitedBy[@(uid)] = @(invitedBy);
        _chatInvitedBy = chatInvitedBy;
        
        NSMutableDictionary *chatInvitedDates = [[NSMutableDictionary alloc] initWithDictionary:_chatInvitedDates];
        chatInvitedDates[@(uid)] = @(date);
        _chatInvitedDates = chatInvitedDates;
    }
}

- (void)removeParticipantWithId:(int32_t)uid
{
    NSMutableArray *chatParticipantUids = [[NSMutableArray alloc] initWithArray:_chatParticipantUids];
    [chatParticipantUids removeObject:@(uid)];
    _chatParticipantUids = chatParticipantUids;
    
    NSMutableDictionary *chatInvitedBy = [[NSMutableDictionary alloc] initWithDictionary:_chatInvitedBy];
    [chatInvitedBy removeObjectForKey:@(uid)];
    _chatInvitedBy = chatInvitedBy;
    
    NSMutableDictionary *chatInvitedDates = [[NSMutableDictionary alloc] initWithDictionary:_chatInvitedDates];
    [chatInvitedDates removeObjectForKey:@(uid)];
    _chatInvitedDates = chatInvitedDates;
}

- (void)addSecretChatPeerWithId:(int64_t)peerId
{
    NSMutableArray *chatParticipantSecretChatPeerIds = [[NSMutableArray alloc] initWithArray:_chatParticipantSecretChatPeerIds];
    if (![chatParticipantSecretChatPeerIds containsObject:@(peerId)])
    {
        [chatParticipantSecretChatPeerIds addObject:@(peerId)];
        _chatParticipantSecretChatPeerIds = chatParticipantSecretChatPeerIds;
    }
}

- (void)removeSecretChatPeerWithId:(int64_t)peerId
{
    NSMutableArray *chatParticipantSecretChatPeerIds = [[NSMutableArray alloc] initWithArray:_chatParticipantSecretChatPeerIds];
    [chatParticipantSecretChatPeerIds removeObject:@(peerId)];
    _chatParticipantSecretChatPeerIds = chatParticipantSecretChatPeerIds;
}

- (void)addChatPeerWithId:(int64_t)peerId
{
    NSMutableArray *chatParticipantChatPeerIds = [[NSMutableArray alloc] initWithArray:_chatParticipantChatPeerIds];
    if (![chatParticipantChatPeerIds containsObject:@(peerId)])
    {
        [chatParticipantChatPeerIds addObject:@(peerId)];
        _chatParticipantChatPeerIds = chatParticipantChatPeerIds;
    }
}

- (void)removeChatPeerWithId:(int64_t)peerId
{
    NSMutableArray *chatParticipantChatPeerIds = [[NSMutableArray alloc] initWithArray:_chatParticipantChatPeerIds];
    [chatParticipantChatPeerIds removeObject:@(peerId)];
    _chatParticipantChatPeerIds = chatParticipantChatPeerIds;
}

+ (TGConversationParticipantsData *)deserializeData:(NSData *)data
{
    TGConversationParticipantsData *participantsData = [[TGConversationParticipantsData alloc] init];
    
    int length = data.length;
    int ptr = 0;
    if (ptr + 12 > length)
    {
        return nil;
    }
    
    int version = 0;
    [data getBytes:&version range:NSMakeRange(ptr, 4)];
    ptr += 4;
    
    int32_t formatVersion = 0;
    if (version == 0xabcdef12)
    {
        [data getBytes:&formatVersion range:NSMakeRange(ptr, 4)];
        ptr += 4;
        
        [data getBytes:&version range:NSMakeRange(ptr, 4)];
        ptr += 4;
    }
    
    int adminId = 0;
    [data getBytes:&adminId range:NSMakeRange(ptr, 4)];
    ptr += 4;
    
    int count = 0;
    [data getBytes:&count range:NSMakeRange(ptr, 4)];
    ptr += 4;
    
    NSMutableArray *uids = [[NSMutableArray alloc] init];
    NSMutableDictionary *invitedBy = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *invitedDates = [[NSMutableDictionary alloc] init];
    
    for (int i = 0; i < count; i++)
    {
        if (ptr + 4 > length)
        {
            TGLog(@"***** Invalid participants data");
            return nil;
        }
        
        int uid = 0;
        [data getBytes:&uid range:NSMakeRange(ptr, 4)];
        ptr += 4;
        
        if (ptr + 4 > length)
        {
            TGLog(@"***** Invalid participants data");
            return nil;
        }
        int inviter = 0;
        [data getBytes:&inviter range:NSMakeRange(ptr, 4)];
        ptr += 4;
        
        if (ptr + 4 > length)
        {
            TGLog(@"***** Invalid participants data");
            return nil;
        }
        int date = 0;
        [data getBytes:&date range:NSMakeRange(ptr, 4)];
        ptr += 4;
        
        NSNumber *nUid = [[NSNumber alloc] initWithInt:uid];
        
        [uids addObject:nUid];
        [invitedBy setObject:[[NSNumber alloc] initWithInt:inviter] forKey:nUid];
        [invitedDates setObject:[[NSNumber alloc] initWithInt:date] forKey:nUid];
    }
    
    NSMutableArray *chatParticipantSecretChatPeerIds = [[NSMutableArray alloc] init];
    
    if (formatVersion >= 1)
    {
        int count = 0;
        [data getBytes:&count range:NSMakeRange(ptr, 4)];
        ptr += 4;
        
        for (int i = 0; i < count; i++)
        {
            if (ptr + 8 > length)
            {
                TGLog(@"***** Invalid participants data");
                return nil;
            }
            
            int64_t peerId = 0;
            [data getBytes:&peerId range:NSMakeRange(ptr, 8)];
            ptr += 8;
            
            [chatParticipantSecretChatPeerIds addObject:@(peerId)];
        }
    }
    
    NSMutableArray *chatParticipantChatPeerIds = [[NSMutableArray alloc] init];
    
    if (formatVersion >= 2)
    {
        int count = 0;
        [data getBytes:&count range:NSMakeRange(ptr, 4)];
        ptr += 4;
        
        for (int i = 0; i < count; i++)
        {
            if (ptr + 8 > length)
            {
                TGLog(@"***** Invalid participants data");
                return nil;
            }
            
            int64_t peerId = 0;
            [data getBytes:&peerId range:NSMakeRange(ptr, 8)];
            ptr += 8;
            
            [chatParticipantChatPeerIds addObject:@(peerId)];
        }
    }
    
    participantsData.version = version;
    participantsData.chatAdminId = adminId;
    participantsData.chatParticipantUids = uids;
    participantsData.chatInvitedBy = invitedBy;
    participantsData.chatInvitedDates = invitedDates;
    participantsData.chatParticipantSecretChatPeerIds = chatParticipantSecretChatPeerIds;
    participantsData.chatParticipantChatPeerIds = chatParticipantChatPeerIds;
    
    return participantsData;
}

- (NSData *)serializedData
{
    if (_serializedData == nil)
    {
        NSMutableData *data = [[NSMutableData alloc] init];
        
        int32_t magic = 0xabcdef12;
        [data appendBytes:&magic length:4];
        
        int32_t formatVersion = 2;
        [data appendBytes:&formatVersion length:4];
        
        [data appendBytes:&_version length:4];
        [data appendBytes:&_chatAdminId length:4];
        
        int count = _chatParticipantUids.count;
        [data appendBytes:&count length:4];
        for (NSNumber *nUid in _chatParticipantUids)
        {
            int uid = [nUid intValue];
            [data appendBytes:&uid length:4];
            
            int invitedBy = [[_chatInvitedBy objectForKey:nUid] intValue];
            [data appendBytes:&invitedBy length:4];
            
            int invitedDate = [[_chatInvitedDates objectForKey:nUid] intValue];
            [data appendBytes:&invitedDate length:4];
        }
        
        int32_t chatParticipantSecretChatPeerIdsCount = _chatParticipantSecretChatPeerIds.count;
        [data appendBytes:&chatParticipantSecretChatPeerIdsCount length:4];
        
        for (NSNumber *nPeerId in _chatParticipantSecretChatPeerIds)
        {
            int64_t peerId = [nPeerId longLongValue];
            [data appendBytes:&peerId length:8];
        }
        
        int32_t chatParticipantChatPeerIdsCount = _chatParticipantChatPeerIds.count;
        [data appendBytes:&chatParticipantChatPeerIdsCount length:4];
        
        for (NSNumber *nPeerId in _chatParticipantChatPeerIds)
        {
            int64_t peerId = [nPeerId longLongValue];
            [data appendBytes:&peerId length:8];
        }
        
        _serializedData = data;
    }
    
    return _serializedData;
}

@end

#pragma mark -

@implementation TGConversation

- (id)initWithConversationId:(int64_t)conversationId unreadCount:(int)unreadCount serviceUnreadCount:(int)serviceUnreadCount
{
    self = [super init];
    if (self != nil)
    {
        _conversationId = conversationId;
        _unreadCount = unreadCount;
        _serviceUnreadCount = serviceUnreadCount;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)__unused zone
{
    TGConversation *conversation = [[TGConversation alloc] init];
    
    conversation.conversationId = _conversationId;
    conversation.outgoing = _outgoing;
    conversation.unread = _unread;
    conversation.deliveryError = _deliveryError;
    conversation.deliveryState = _deliveryState;
    conversation.date = _date;
    conversation.fromUid = _fromUid;
    conversation.text = _text;
    conversation.media = _media;
    conversation.unreadCount = _unreadCount;
    conversation.serviceUnreadCount = _serviceUnreadCount;
    conversation.chatTitle = _chatTitle;
    conversation.chatPhotoSmall = _chatPhotoSmall;
    conversation.chatPhotoMedium = _chatPhotoMedium;
    conversation.chatPhotoBig = _chatPhotoBig;
    conversation.chatParticipants = [_chatParticipants copy];
    conversation.chatParticipantCount = _chatParticipantCount;
    conversation.chatVersion = _chatVersion;
    conversation.leftChat = _leftChat;
    conversation.kickedFromChat = _kickedFromChat;
    conversation.dialogListData = _dialogListData;
    conversation.isChat = _isChat;
    conversation.isDeleted = _isDeleted;
    
    conversation.encryptedData = _encryptedData == nil ? nil : [_encryptedData copy];
    
    conversation.isBroadcast = _isBroadcast;
    
    return conversation;
}

- (void)mergeMessage:(TGMessage *)message
{
    _outgoing = message.outgoing;
    _date = (int)message.date;
    _fromUid = (int)message.fromUid;
    _text = message.text;
    _media = message.mediaAttachments;
    _unread = message.unread;
    _deliveryError = message.deliveryState == TGMessageDeliveryStateFailed;
    _deliveryState = message.deliveryState;
}

- (NSData *)mediaData
{
    if (_mediaData != nil)
        return _mediaData;
    
    _mediaData = [TGMessage serializeMediaAttachments:false attachments:_media];
    return _mediaData;
}

- (BOOL)isEqualToConversation:(TGConversation *)other
{
    if (_conversationId != other.conversationId || _outgoing != other.outgoing || _date != other.date || _fromUid != other.fromUid || ![_text isEqualToString:other.text] || _unreadCount != other.unreadCount || _serviceUnreadCount != other.serviceUnreadCount || _unread != other.unread || _isChat != other.isChat || _deliveryError != other.deliveryError || _deliveryState != other.deliveryState)
        return false;
    
    if (_media.count != other.media.count)
        return false;
    if (_media != nil && ![self.mediaData isEqualToData:other.mediaData])
        return false;
    
    if (_isChat)
    {
        if (![_chatTitle isEqualToString:other.chatTitle] || _chatVersion != other.chatVersion || _leftChat != other.leftChat || _kickedFromChat != other.kickedFromChat ||
            (((_chatParticipants != nil) != (other.chatParticipants != nil)) || (_chatParticipants != nil && ![_chatParticipants.serializedData isEqualToData:other.chatParticipants.serializedData]))
           )
            return false;
        if ((_chatPhotoSmall != nil) != (other.chatPhotoSmall != nil) || (_chatPhotoSmall != nil && ![_chatPhotoSmall isEqualToString:other.chatPhotoSmall]))
            return false;
        if ((_chatPhotoMedium != nil) != (other.chatPhotoMedium != nil) || (_chatPhotoMedium != nil && ![_chatPhotoMedium isEqualToString:other.chatPhotoMedium]))
            return false;
        if ((_chatPhotoBig != nil) != (other.chatPhotoBig != nil) || (_chatPhotoBig != nil && ![_chatPhotoBig isEqualToString:other.chatPhotoBig]))
            return false;
    }
    
    if (_encryptedData != nil || other->_encryptedData != nil)
    {
        if ((_encryptedData != nil) != (other->_encryptedData != nil) || (_encryptedData != nil && ![_encryptedData isEqualToEncryptedData:other->_encryptedData]))
            return false;
    }
        
    return true;
}

- (BOOL)isEqualToConversationIgnoringMessage:(TGConversation *)other
{
    if (_conversationId != other.conversationId || _isChat != other.isChat)
        return false;
    
    if (_isChat)
    {
        if (![_chatTitle isEqualToString:other.chatTitle] || _chatVersion != other.chatVersion || _leftChat != other.leftChat || _kickedFromChat != other.kickedFromChat ||
            (((_chatParticipants != nil) != (other.chatParticipants != nil)) || (_chatParticipants != nil && ![_chatParticipants.serializedData isEqualToData:other.chatParticipants.serializedData]))
            )
            return false;
        if ((_chatPhotoSmall != nil) != (other.chatPhotoSmall != nil) || (_chatPhotoSmall != nil && ![_chatPhotoSmall isEqualToString:other.chatPhotoSmall]))
            return false;
        if ((_chatPhotoMedium != nil) != (other.chatPhotoMedium != nil) || (_chatPhotoMedium != nil && ![_chatPhotoMedium isEqualToString:other.chatPhotoMedium]))
            return false;
        if ((_chatPhotoBig != nil) != (other.chatPhotoBig != nil) || (_chatPhotoBig != nil && ![_chatPhotoBig isEqualToString:other.chatPhotoBig]))
            return false;
    }
    
    return true;
}

- (NSData *)serializeChatPhoto
{
    NSMutableData *data = [[NSMutableData alloc] init];
    
    for (int i = 0; i < 3; i++)
    {
        NSString *value = nil;
        if (i == 0)
            value = _chatPhotoSmall;
        else if (i == 1)
            value = _chatPhotoMedium;
        else if (i == 2)
            value = _chatPhotoBig;
        
        NSData *valueData = [value dataUsingEncoding:NSUTF8StringEncoding];
        int length = valueData.length;
        [data appendBytes:&length length:4];
        if (valueData != nil)
            [data appendData:valueData];
    }
    
    if (_encryptedData != nil)
        [_encryptedData serialize:data];
    
    return data;
}

- (void)deserializeChatPhoto:(NSData *)data
{
    int ptr = 0;
    
    for (int i = 0; i < 3; i++)
    {
        int length = 0;
        [data getBytes:&length range:NSMakeRange(ptr, 4)];
        ptr += 4;
        
        uint8_t *valueBytes = malloc(length);
        [data getBytes:valueBytes range:NSMakeRange(ptr, length)];
        ptr += length;
        NSString *value = [[NSString alloc] initWithBytesNoCopy:valueBytes length:length encoding:NSUTF8StringEncoding freeWhenDone:true];
        
        if (i == 0)
            _chatPhotoSmall = value;
        else if (i == 1)
            _chatPhotoMedium = value;
        else if (i == 2)
            _chatPhotoBig = value;
    }
    
    if (ptr + 4 <= data.length)
    {
        _encryptedData = [TGEncryptedConversationData deserialize:data ptr:&ptr];
    }
}

- (bool)isEncrypted
{
    return _encryptedData != nil;
}

@end
