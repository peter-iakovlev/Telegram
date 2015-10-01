/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "ASActor.h"

#import <SSignalKit/SSignalKit.h>

#import "ActionStage.h"

#import "TL/TLMetaScheme.h"

@class TGWebPageMediaAttachment;

@interface TGUpdateStateRequestBuilder : ASActor <ASWatcher>

@property (nonatomic, strong) ASHandle *actionHandle;

+ (void)scheduleInitialUpdates;

+ (void)clearStateHistory;
+ (int)stateVersion;
+ (void)invalidateStateVersion;

+ (void)applyDelayedOutgoingMessages:(int64_t)conversationId;

+ (void)addIgnoreConversationId:(int64_t)conversationId;
+ (bool)ignoringConversationId:(int64_t)conversationId;
+ (void)removeIgnoreConversationId:(int64_t)conversationId;

+ (TGWebPageMediaAttachment *)webPageWithId:(int64_t)webPageId;
+ (TGWebPageMediaAttachment *)webPageWithLink:(NSString *)link;
+ (SSignal *)requestWebPageByText:(NSString *)text;

+ (void)applyUpdates:(NSArray *)addedMessagesDesc otherUpdates:(NSArray *)otherUpdates usersDesc:(NSArray *)usersDesc chatsDesc:(NSArray *)chatsDesc chatParticipantsDesc:(NSArray *)chatParticipantsDesc updatesWithDates:(NSArray *)updatesWithDates addedEncryptedActionsByPeerId:(NSDictionary *)addedEncryptedActionsByPeerId addedEncryptedUnparsedActionsByPeerId:(NSDictionary *)addedEncryptedUnparsedActionsByPeerId completion:(void (^)(bool))completion;
+ (void)processDelayedMessagesInConversation:(int64_t)conversationId completedPath:(NSString *)path;

- (void)stateDeltaRequestSuccess:(TLupdates_Difference *)difference;
- (void)stateDeltaRequestFailed;

- (void)stateRequestSuccess:(TLupdates_State *)state;
- (void)stateRequestFailed;

+ (void)updateNotifiedVersionUpdate;

#ifdef __cplusplus
+ (NSData *)decryptEncryptedMessageData:(TLEncryptedMessage *)encryptedMessage decryptedLayer:(NSUInteger *)decryptedLayer cachedPeerIds:(std::map<int64_t, int64_t> *)cachedPeerIds cachedParticipantIds:(std::map<int64_t, int> *)cachedParticipantIds outConversationId:(int64_t *)outConversationId outKeyId:(int64_t *)outKeyId outSeqIn:(int32_t *)outSeqIn outSeqOut:(int32_t *)outSeqOut;
#endif

@end
