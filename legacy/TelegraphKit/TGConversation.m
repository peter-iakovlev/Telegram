#import "TGConversation.h"

#import "TGMessage.h"

#import "PSKeyValueCoder.h"

typedef enum {
    TGConversationFlagDisplayExpanded = (1 << 0),
    TGConversationFlagPostAsChannel = (1 << 1),
    TGConversationFlagKicked = (1 << 2),
    TGConversationFlagVerified = (1 << 3)
} TGConversationFlags;

@implementation TGEncryptedConversationData

- (BOOL)isEqualToEncryptedData:(TGEncryptedConversationData *)other
{
    if (_encryptedConversationId != other->_encryptedConversationId || _accessHash != other->_accessHash || _keyFingerprint != other->_keyFingerprint || _handshakeState != other->_handshakeState || _currentRekeyExchangeId != other->_currentRekeyExchangeId)
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
    data->_currentRekeyExchangeId = _currentRekeyExchangeId;
    data->_currentRekeyIsInitiatedByLocalClient = _currentRekeyIsInitiatedByLocalClient;
    data->_currentRekeyNumber = _currentRekeyNumber;
    data->_currentRekeyKey = _currentRekeyKey;
    data->_currentRekeyKeyId = _currentRekeyKeyId;
    
    return data;
}

- (void)serialize:(NSMutableData *)data
{
    uint8_t version = 3;
    [data appendBytes:&version length:1];
    [data appendBytes:&_encryptedConversationId length:8];
    [data appendBytes:&_accessHash length:8];
    [data appendBytes:&_keyFingerprint length:8];
    [data appendBytes:&_handshakeState length:4];
    [data appendBytes:&_currentRekeyExchangeId length:8];
    uint8_t currentRekeyIsInitiatedByLocalClient = _currentRekeyIsInitiatedByLocalClient ? 1 : 0;
    [data appendBytes:&currentRekeyIsInitiatedByLocalClient length:1];
    int32_t currentRekeyNumberLength = (int32_t)_currentRekeyNumber.length;
    [data appendBytes:&currentRekeyNumberLength length:4];
    if (_currentRekeyNumber != nil)
        [data appendData:_currentRekeyNumber];
    int32_t currentRekeyKeyLength = (int32_t)_currentRekeyKey.length;
    [data appendBytes:&currentRekeyKeyLength length:4];
    if (_currentRekeyKey != nil)
        [data appendData:_currentRekeyKey];
    [data appendBytes:&_currentRekeyKeyId length:8];
}

+ (TGEncryptedConversationData *)deserialize:(NSData *)data ptr:(int *)ptr
{
    uint8_t version = 0;
    [data getBytes:&version range:NSMakeRange(*ptr, 1)];
    (*ptr) += 1;
    
    if (version != 1 && version != 2 && version != 3)
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
    
    if (version >= 2)
    {
        [data getBytes:&encryptedData->_handshakeState range:NSMakeRange(*ptr, 4)];
        *ptr += 4;
    }
    
    if (version >= 3)
    {
        [data getBytes:&encryptedData->_currentRekeyExchangeId range:NSMakeRange(*ptr, 8)];
        *ptr += 8;
        
        uint8_t currentRekeyIsInitiatedByLocalClient = 0;
        [data getBytes:&currentRekeyIsInitiatedByLocalClient range:NSMakeRange(*ptr, 1)];
        encryptedData->_currentRekeyIsInitiatedByLocalClient = currentRekeyIsInitiatedByLocalClient;
        *ptr += 1;
        
        int32_t currentRekeyNumberLength = 0;
        [data getBytes:&currentRekeyNumberLength range:NSMakeRange(*ptr, 4)];
        *ptr += 4;
        
        if (currentRekeyNumberLength != 0)
        {
            encryptedData->_currentRekeyNumber = [data subdataWithRange:NSMakeRange(*ptr, currentRekeyNumberLength)];
            *ptr += currentRekeyNumberLength;
        }
        
        int32_t currentRekeyKeyLength = 0;
        [data getBytes:&currentRekeyKeyLength range:NSMakeRange(*ptr, 4)];
        *ptr += 4;
        
        if (currentRekeyKeyLength != 0)
        {
            encryptedData->_currentRekeyKey = [data subdataWithRange:NSMakeRange(*ptr, currentRekeyKeyLength)];
            *ptr += currentRekeyKeyLength;
        }
        
        [data getBytes:&encryptedData->_currentRekeyKeyId range:NSMakeRange(*ptr, 8)];
        *ptr += 8;
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
    participantsData.exportedChatInviteString = _exportedChatInviteString;
    
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
    
    int length = (int)data.length;
    int ptr = 0;
    if (ptr + 12 > length)
    {
        return nil;
    }
    
    int version = 0;
    [data getBytes:&version range:NSMakeRange(ptr, 4)];
    ptr += 4;
    
    int32_t formatVersion = 0;
    if (version == (int)0xabcdef12)
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
    
    if (formatVersion >= 3)
    {
        int32_t length = 0;
        [data getBytes:&length range:NSMakeRange(ptr, 4)];
        ptr += 4;
        
        NSData *linkData = [data subdataWithRange:NSMakeRange(ptr, length)];
        ptr += length;
        
        participantsData.exportedChatInviteString = [[NSString alloc] initWithData:linkData encoding:NSUTF8StringEncoding];
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
        
        int32_t formatVersion = 3;
        [data appendBytes:&formatVersion length:4];
        
        [data appendBytes:&_version length:4];
        [data appendBytes:&_chatAdminId length:4];
        
        int count = (int)_chatParticipantUids.count;
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
        
        int32_t chatParticipantSecretChatPeerIdsCount = (int32_t)_chatParticipantSecretChatPeerIds.count;
        [data appendBytes:&chatParticipantSecretChatPeerIdsCount length:4];
        
        for (NSNumber *nPeerId in _chatParticipantSecretChatPeerIds)
        {
            int64_t peerId = [nPeerId longLongValue];
            [data appendBytes:&peerId length:8];
        }
        
        int32_t chatParticipantChatPeerIdsCount = (int32_t)_chatParticipantChatPeerIds.count;
        [data appendBytes:&chatParticipantChatPeerIdsCount length:4];
        
        for (NSNumber *nPeerId in _chatParticipantChatPeerIds)
        {
            int64_t peerId = [nPeerId longLongValue];
            [data appendBytes:&peerId length:8];
        }
        
        int32_t linkLength = (int32_t)_exportedChatInviteString.length;
        [data appendBytes:&linkLength length:4];
        if (linkLength != 0)
            [data appendData:[_exportedChatInviteString dataUsingEncoding:NSUTF8StringEncoding]];
        
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

- (instancetype)initWithKeyValueCoder:(PSKeyValueCoder *)coder
{
    self = [super init];
    if (self != nil) {
        _conversationId = [coder decodeInt64ForCKey:"i"];
        _accessHash = [coder decodeInt64ForCKey:"ah"];
        _displayVariant = [coder decodeInt32ForCKey:"dv"];
        _kind = (uint8_t)[coder decodeInt32ForCKey:"kind"];
        _pts = [coder decodeInt32ForCKey:"pts"];
        _variantSortKey = TGConversationSortKeyDecode(coder, "vsort");
        _importantSortKey = TGConversationSortKeyDecode(coder, "isort");
        _unimportantSortKey = TGConversationSortKeyDecode(coder, "usort");
        _maxReadMessageId = [coder decodeInt32ForCKey:"mread"];
        _about = [coder decodeStringForCKey:"about"];
        _username = [coder decodeStringForCKey:"username"];
        _outgoing = [coder decodeInt32ForCKey:"out"];
        _unread = [coder decodeInt32ForCKey:"unr"];
        _deliveryError = [coder decodeInt32ForCKey:"der"];
        _deliveryState = [coder decodeInt32ForCKey:"ds"];
        _date = [coder decodeInt32ForCKey:"date"];
        _fromUid = [coder decodeInt32ForCKey:"from"];
        _text = [coder decodeStringForCKey:"text"];
        _media = [TGMessage parseMediaAttachments:[coder decodeDataCorCKey:"media"]];
        _unreadCount = [coder decodeInt32ForCKey:"ucount"];
        _serviceUnreadCount = [coder decodeInt32ForCKey:"sucount"];
        _chatTitle = [coder decodeStringForCKey:"ct"];
        _chatPhotoSmall = [coder decodeStringForCKey:"cp.s"];
        _chatPhotoMedium = [coder decodeStringForCKey:"cp.m"];
        _chatPhotoBig = [coder decodeStringForCKey:"cp.l"];
        _chatParticipants = nil;
        _chatParticipantCount = 0;
        _chatVersion = [coder decodeInt32ForCKey:"ver"];
        _chatIsAdmin = [coder decodeInt32ForCKey:"adm"];
        _channelRole = [coder decodeInt32ForCKey:"role"];
        _channelIsReadOnly = [coder decodeInt32ForCKey:"ro"];
        _flags = [coder decodeInt64ForCKey:"flags"];
        _leftChat = false;
        _kickedFromChat = [coder decodeInt32ForCKey:"kk"];
        _isChat = false;
        _isChannel = true;
        _isDeleted = false;
        _encryptedData = nil;
        _isBroadcast = false;
    }
    return self;
}

- (void)encodeWithKeyValueCoder:(PSKeyValueCoder *)coder {
    [coder encodeInt64:_conversationId forCKey:"i"];
    [coder encodeInt64:_accessHash forCKey:"ah"];
    [coder encodeInt32:_displayVariant forCKey:"dv"];
    [coder encodeInt32:_kind forCKey:"kind"];
    [coder encodeInt32:_pts forCKey:"pts"];
    TGConversationSortKeyEncode(coder, "vsort", _variantSortKey);
    TGConversationSortKeyEncode(coder, "isort", _importantSortKey);
    TGConversationSortKeyEncode(coder, "usort", _unimportantSortKey);
    [coder encodeInt32:_maxReadMessageId forCKey:"mread"];
    [coder encodeString:_about forCKey:"about"];
    [coder encodeString:_username forCKey:"username"];
    [coder encodeInt32:_outgoing ? 1 : 0 forCKey:"out"];
    [coder encodeInt32:_unread ? 1 : 0 forCKey:"unr"];
    [coder encodeInt32:_deliveryError ? 1 : 0 forCKey:"der"];
    [coder encodeInt32:_deliveryState forCKey:"ds"];
    [coder encodeInt32:_date forCKey:"date"];
    [coder encodeInt32:_fromUid forCKey:"from"];
    [coder encodeString:_text forCKey:"text"];
    [coder encodeData:[TGMessage serializeMediaAttachments:true attachments:_media] forCKey:"media"];
    [coder encodeInt32:_unreadCount forCKey:"ucount"];
    [coder encodeInt32:_serviceUnreadCount forCKey:"sucount"];
    [coder encodeString:_chatTitle forCKey:"ct"];
    [coder encodeString:_chatPhotoSmall forCKey:"cp.s"];
    [coder encodeString:_chatPhotoMedium forCKey:"cp.m"];
    [coder encodeString:_chatPhotoBig forCKey:"cp.l"];
    [coder encodeInt32:_chatVersion forCKey:"ver"];
    [coder encodeInt32:_chatIsAdmin ? 1 : 0 forCKey:"adm"];
    [coder encodeInt32:_channelRole forCKey:"role"];
    [coder encodeInt32:_channelIsReadOnly ? 1 : 0 forCKey:"ro"];
    [coder encodeInt64:_flags forCKey:"flags"];
    [coder encodeInt32:_kickedFromChat forCKey:"kk"];
}

- (id)copyWithZone:(NSZone *)__unused zone
{
    TGConversation *conversation = [[TGConversation alloc] init];
    
    conversation.conversationId = _conversationId;
    conversation.accessHash = _accessHash;
    conversation.displayVariant = _displayVariant;
    conversation->_kind = _kind;
    conversation.pts = _pts;
    conversation.variantSortKey = _variantSortKey;
    conversation.importantSortKey = _importantSortKey;
    conversation.unimportantSortKey = _unimportantSortKey;
    conversation.maxReadMessageId = _maxReadMessageId;
    conversation.about = _about;
    conversation.username = _username;
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
    conversation.chatIsAdmin = _chatIsAdmin;
    conversation.channelRole = _channelRole;
    conversation.leftChat = _leftChat;
    conversation.kickedFromChat = _kickedFromChat;
    conversation.dialogListData = _dialogListData;
    conversation.isChat = _isChat;
    conversation.isDeleted = _isDeleted;
    
    conversation.encryptedData = _encryptedData == nil ? nil : [_encryptedData copy];
    
    conversation.isBroadcast = _isBroadcast;
    conversation.isChannel = _isChannel;
    conversation.channelIsReadOnly = _channelIsReadOnly;
    conversation.flags = _flags;
    
    return conversation;
}

- (void)setKind:(uint8_t)kind {
    if (_kind != kind || kind != TGConversationSortKeyKind(_variantSortKey)) {
        _kind = kind;
        
        _variantSortKey = TGConversationSortKeyUpdateKind(_variantSortKey, kind);
        _importantSortKey = TGConversationSortKeyUpdateKind(_importantSortKey, kind);
        _unimportantSortKey = TGConversationSortKeyUpdateKind(_unimportantSortKey, kind);
    }
}

- (void)setVariantSortKey:(TGConversationSortKey)variantSortKey {
    _variantSortKey = variantSortKey;
    
    _date = TGConversationSortKeyTimestamp(variantSortKey);
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
        int length = (int)valueData.length;
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
    
    if (ptr + 4 <= (int)data.length)
    {
        _encryptedData = [TGEncryptedConversationData deserialize:data ptr:&ptr];
    }
}

- (bool)isEncrypted
{
    return _encryptedData != nil;
}

- (void)mergeChannel:(TGConversation *)channel {
    _chatTitle = channel.chatTitle;
    _chatVersion = channel.chatVersion;
    _chatPhotoBig = channel.chatPhotoBig;
    _chatPhotoMedium = channel.chatPhotoMedium;
    _chatPhotoSmall = channel.chatPhotoSmall;
    _accessHash = channel.accessHash;
    _username = channel.username;
    _chatIsAdmin = channel.chatIsAdmin;
    self.channelRole = channel.channelRole;
    _channelIsReadOnly = channel.channelIsReadOnly;
    _leftChat = channel.leftChat;
    _kickedFromChat = channel.kickedFromChat;
    self.kind = channel.leftChat ? TGConversationKindTemporaryChannel : TGConversationKindPersistentChannel;
    self.isVerified = channel.isVerified;
}

- (bool)currentUserCanSendMessages {
    return (_channelRole == TGChannelRoleCreator || _channelRole == TGChannelRolePublisher || !_channelIsReadOnly) && !_leftChat && !_kickedFromChat;
}

+ (NSString *)chatTitleForDecoder:(PSKeyValueCoder *)coder {
    return [coder decodeStringForCKey:"ct"];
}

- (bool)postAsChannel {
    return _flags & TGConversationFlagPostAsChannel;
}

- (void)setPostAsChannel:(bool)postAsChannel {
    if (postAsChannel) {
        _flags |= TGConversationFlagPostAsChannel;
    } else {
        _flags &= ~TGConversationFlagPostAsChannel;
    }
}

- (bool)displayExpanded {
    return _flags & TGConversationFlagDisplayExpanded;
}

- (void)setDisplayExpanded:(bool)displayExpanded {
    if (displayExpanded) {
        _flags |= TGConversationFlagDisplayExpanded;
    } else {
        _flags &= ~TGConversationFlagDisplayExpanded;
    }
}

- (bool)isVerified {
    return _flags & TGConversationFlagVerified;
}

- (void)setIsVerified:(bool)isVerified {
    if (isVerified) {
        _flags |= TGConversationFlagVerified;
    } else {
        _flags &= ~TGConversationFlagVerified;
    }
}

@end
