/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <Foundation/Foundation.h>

#import "TGImageInfo.h"

#import "TGMessage.h"

@interface TGConversationParticipantsData : NSObject <NSCopying>
{
    NSData *_serializedData;
}

@property (nonatomic, strong) NSArray *chatParticipantUids;
@property (nonatomic, strong) NSDictionary *chatInvitedBy;
@property (nonatomic, strong) NSDictionary *chatInvitedDates;

@property (nonatomic, strong) NSArray *chatParticipantSecretChatPeerIds;
@property (nonatomic, strong) NSArray *chatParticipantChatPeerIds;

@property (nonatomic) int chatAdminId;

@property (nonatomic) int version;

+ (TGConversationParticipantsData *)deserializeData:(NSData *)data;
- (NSData *)serializedData;

- (void)addParticipantWithId:(int32_t)uid invitedBy:(int32_t)invitedBy date:(int32_t)date;
- (void)removeParticipantWithId:(int32_t)uid;

- (void)addSecretChatPeerWithId:(int64_t)peerId;
- (void)removeSecretChatPeerWithId:(int64_t)peerId;
- (void)addChatPeerWithId:(int64_t)peerId;
- (void)removeChatPeerWithId:(int64_t)peerId;

@end

@interface TGEncryptedConversationData : NSObject <NSCopying>

@property (nonatomic) int64_t encryptedConversationId;
@property (nonatomic) int64_t accessHash;
@property (nonatomic) int64_t keyFingerprint;
@property (nonatomic) int32_t handshakeState;

@end

@interface TGConversation : NSObject <NSCopying>

@property (nonatomic) int64_t conversationId;
@property (nonatomic) id additionalProperties;

@property (nonatomic) bool outgoing;
@property (nonatomic) bool unread;
@property (nonatomic) bool deliveryError;
@property (nonatomic) TGMessageDeliveryState deliveryState;
@property (nonatomic) int date;
@property (nonatomic) int fromUid;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSArray *media;
@property (nonatomic, strong) NSData *mediaData;

@property (nonatomic) int unreadCount;
@property (nonatomic) int serviceUnreadCount;

@property (nonatomic, strong) NSString *chatTitle;
@property (nonatomic, strong) NSString *chatPhotoSmall;
@property (nonatomic, strong) NSString *chatPhotoMedium;
@property (nonatomic, strong) NSString *chatPhotoBig;

@property (nonatomic) int chatParticipantCount;

@property (nonatomic) bool leftChat;
@property (nonatomic) bool kickedFromChat;

@property (nonatomic) int chatVersion;
@property (nonatomic, strong) TGConversationParticipantsData *chatParticipants;

@property (nonatomic, strong) NSDictionary *dialogListData;

@property (nonatomic) bool isChat;
@property (nonatomic) bool isDeleted;
@property (nonatomic) bool isBroadcast;

@property (nonatomic, strong) TGEncryptedConversationData *encryptedData;

- (id)initWithConversationId:(int64_t)conversationId unreadCount:(int)unreadCount serviceUnreadCount:(int)serviceUnreadCount;

- (void)mergeMessage:(TGMessage *)message;

- (BOOL)isEqualToConversation:(TGConversation *)other;
- (BOOL)isEqualToConversationIgnoringMessage:(TGConversation *)other;

- (NSData *)serializeChatPhoto;
- (void)deserializeChatPhoto:(NSData *)data;

- (bool)isEncrypted;

@end
