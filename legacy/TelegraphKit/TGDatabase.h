/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <Foundation/Foundation.h>

#import "TGUser.h"
#import "TGContactBinding.h"
#import "TGPhonebookContact.h"
#import "TGMessage.h"
#import "TGConversation.h"

#import "TGFutureAction.h"
#import "TGChangeNotificationSettingsFutureAction.h"
#import "TGClearNotificationsFutureAction.h"
#import "TGChangePrivacySettingsFutureAction.h"
#import "TGChangePeerBlockStatusFutureAction.h"
#import "TGUploadAvatarFutureAction.h"
#import "TGDeleteProfilePhotoFutureAction.h"
#import "TGRemoveContactFutureAction.h"
#import "TGExportContactFutureAction.h"
#import "TGSynchronizeEncryptedChatSettingsFutureAction.h"
#import "TGChangePasslockSettingsFutureAction.h"
#import "TGAcceptEncryptionFutureAction.h"
#import "TGEncryptedChatServiceAction.h"
#import "TGUpdatePeerLayerFutureAction.h"

#import "TGStoredSecretAction.h"

#import "TGAccountSettings.h"

#import "TGSharedMediaCacheSignals.h"

#import "TGBotReplyMarkup.h"
#import "TGMessageHole.h"
#import "TGMessageGroup.h"
#import "TGQueuedDeleteChannelMessages.h"
#import "TGQueuedReadChannelMessages.h"
#import "TGQueuedLeaveChannel.h"

#import "TGCachedConversationData.h"
#import "TGCachedUserData.h"
#import "TGCachedPeerSettings.h"

#import "TGConversationScrollState.h"
#import "TGInstantPageScrollState.h"

#import "TGPeerRatingUpdates.h"

#import "TGPeerReadState.h"
#import "TGDatabaseUpdateMessage.h"
#import "TGDatabaseReadMessagesByDate.h"

#import "TGDatabaseMessageDraft.h"

@class TGCdnData;

@class TGMessageEditingContext;
@class TGRemoteRecentPeerCategories;
@class TGSynchronizePinnedConversationsAction;

#define DEBUG_DATABASE_INVOKATIONS

typedef struct {
    int pts;
    int date;
    int seq;
    int unreadCount;
    int qts;
} TGDatabaseState;

#ifdef __cplusplus
#include <map>
#include <vector>
#include <memory>
#include <set>
#endif

typedef enum {
    TGDatabaseMessageFlagDeliveryState = 2,
    TGDatabaseMessageFlagMid = 3,
    TGDatabaseMessageFlagDate = 4,
    TGDatabaseMessageFlagPts = 5
} TGDatabaseMessageFlag;

typedef struct
{
    TGDatabaseMessageFlag flag;
    int value;
} TGDatabaseMessageFlagValue;

typedef enum {
    TGDatabaseActionEmpty = 0,
    TGDatabaseActionReadConversation = 1,
    TGDatabaseActionDeleteMessage = 2,
    TGDatabaseActionDeleteConversation = 3,
    TGDatabaseActionClearConversation = 4,
    TGDatabaseActionDeleteSecretMessage = 5,
    TGDatabaseActionClearSecretConversation = 6,
    TGDatabaseActionReadMessageContents = 7,
    TGDatabaseActionScreenshotMessage = 8
} TGDatabaseActionType;

typedef struct
{
    TGDatabaseActionType type;
    int64_t subject;
    int arg0;
    int arg1;
} TGDatabaseAction;

typedef struct
{
    bool photoNotificationsEnabled;
    bool messagesMuted;
} TGPeerCustomSettings;

typedef enum {
    TGSecretMessageFlagViewed = 1,
    TGSecretMessageFlagScreenshot = 2
} TGSecretMessageFlags;

typedef enum {
    TGMediaTypeRemoteImage = 0,
    TGMediaTypeRemoteVideo = 1,
    TGMediaTypeRemoteAudio = 2,
    TGMediaTypeRemoteDocument = 3
} TGMediaType;

@class TGDatabase;

typedef void (^TGDatabasePasswordCheckResultBlock)(bool);
typedef void (^TGDatabaseUpgradeCompletedBlock)();

#ifdef __cplusplus
extern "C" {
#endif
TGDatabase *TGDatabaseInstance();
#ifdef __cplusplus
}
#endif

typedef enum {
    TGChannelHistoryRequestAround = 1 | 2,
    TGChannelHistoryRequestEarlier = 1,
    TGChannelHistoryRequestLater = 2
} TGChannelHistoryRequestMode;

typedef void (^TGDatabaseMessageCleanupBlock)(TGMediaAttachment *attachment);
typedef void (^TGDatabaseCleanupEverythingBlock)();

@interface TGDatabase : NSObject

+ (void)setDatabaseName:(NSString *)name;
+ (void)setPasswordRequiredBlock:(TGDatabasePasswordCheckResultBlock (^)(void (^)(NSString *), bool))passwordRequiredBlock;
+ (void)setUpgradingBlock:(TGDatabaseUpgradeCompletedBlock (^)())upgradingBlock;
+ (void)setLiveMessagesDispatchPath:(NSString *)path;
+ (void)setLiveUnreadCountDispatchPath:(NSString *)path;

+ (TGDatabase *)instance;

- (dispatch_queue_t)databaseQueue;

- (SSignal *)appliedPts;

@property (nonatomic, copy) TGDatabaseMessageCleanupBlock messageCleanupBlock;
@property (nonatomic, copy) TGDatabaseCleanupEverythingBlock cleanupEverythingBlock;

@property (nonatomic) NSTimeInterval timeDifferenceFromUTC;

#ifdef DEBUG_DATABASE_INVOKATIONS
- (void)dispatchOnDatabaseThreadDebug:(const char *)file line:(int)line block:(dispatch_block_t)block synchronous:(bool)synchronous;
#else
- (void)dispatchOnDatabaseThread:(dispatch_block_t)block synchronous:(bool)synchronous;
#endif
- (void)dispatchOnIndexThread:(dispatch_block_t)block synchronous:(bool)synchronous;

- (void)closeDatabase;
- (void)dropDatabase;
- (void)dropDatabase:(bool)fullDrop;

- (void)markAllPendingMessagesAsFailed;

- (void)applyPts:(int)pts date:(int)date seq:(int)seq qts:(int)qts unreadCount:(int)unreadCount;
- (void)setUnreadCount:(int)unreadCount;
- (TGDatabaseState)databaseState;

- (int)cachedUnreadCount;
- (int)unreadCountForConversation:(int64_t)conversationId;

- (void)setCustomProperty:(NSString *)key value:(NSData *)value;
- (void)customProperty:(NSString *)key completion:(void (^)(NSData *value))completion;
- (NSData *)customProperty:(NSString *)key;

- (void)setContactListPreloaded:(bool)contactListPreloaded;
- (NSArray *)loadContactUsers;
#ifdef __cplusplus
- (void)loadRemoteContactUids:(std::vector<int> &)contactUids;
- (void)loadRemoteContactUidsContactIds:(std::map<int, int> &)contactUidsAndIds;
#endif
- (bool)haveRemoteContactUids;
- (bool)uidIsRemoteContact:(int)uid;

- (void)replacePhonebookContacts:(NSArray *)phonebookContacts;
- (void)replacePhonebookContact:(int)nativeId phonebookContact:(TGPhonebookContact *)phonebookContact generateContactBindings:(bool)generateContactBindings;
- (TGPhonebookContact *)phonebookContactByNativeId:(int)nativeId;
- (TGPhonebookContact *)phonebookContactByPhoneId:(int)phoneId;
- (NSArray *)loadPhonebookContacts:(bool)force;

- (void)replaceRemoteContactUids:(NSArray *)uids;
- (void)addRemoteContactUids:(NSArray *)uids;
- (void)deleteRemoteContactUids:(NSArray *)uids;

- (TGContactBinding *)contactBindingWithId:(int)contactId;
- (NSArray *)contactBindings;
- (void)addContactBindings:(NSArray *)contactBindings;
- (void)deleteContactBinding:(int)phoneId;
- (void)replaceContactBindings:(NSArray *)contactBindings;

- (void)storeConversationList:(NSArray *)conversations replace:(bool)replace;

- (void)loadConversationListFromDate:(int)date limit:(int)limit excludeConversationIds:(NSArray *)excludeConversationIds completion:(void (^)(NSArray *result, bool loadedAllRegular))completion;
- (int)loadConversationListRemoteOffsetDate;
- (NSInteger)secretUnreadCount;
- (TGConversation *)loadConversationWithId:(int64_t)conversationId;
- (TGConversation *)loadConversationWithIdCached:(int64_t)conversationId;
- (BOOL)containsConversationWithId:(int64_t)conversationId;

- (void)buildTransliterationCache;
- (void)searchDialogs:(NSString *)query ignoreUid:(int)ignoreUid partial:(bool)partial completion:(void (^)(NSDictionary *, bool))completion isCancelled:(bool (^)())isCancelled;
- (dispatch_block_t)searchContacts:(NSString *)query ignoreUid:(int)ignoreUid searchPhonebook:(bool)searchPhonebook completion:(void (^)(NSDictionary *))completion;
- (NSArray *)searchPhonebookContacts:(NSString *)query contacts:(NSArray *)contacts;

- (dispatch_block_t)searchMessages:(NSString *)query peerId:(int64_t)peerId completion:(void (^)(NSArray *, NSSet *))completion;

- (void)setLocalUserId:(int)localUserId;
- (void)setLocalUserStatusPrivacyRules:(TGNotificationPrivacyAccountSetting *)privacyRules changedLoadedUsers:(void (^)(NSArray *))changedLoadedUsers;
- (TGUser *)loadUser:(int)uid;
- (int)loadCachedPhoneIdByUid:(int)uid;
- (void)storeUsers:(NSArray *)userList;
- (int)loadUsersOnlineCount:(NSArray *)uids alwaysOnlineUid:(int)alwaysOnlineUid;
#ifdef __cplusplus
- (void)loadCachedUsersWithContactIds:(std::set<int> const &)contactIds resultMap:(std::map<int, TGUser *> &)resultMap;
- (std::shared_ptr<std::map<int, TGUser *> >)loadUsers:(std::vector<int> const &)uidList;
- (void)storeUsersPresences:(std::map<int, TGUserPresence> *)presenceMap;
#endif

- (int)loadUserLink:(int)uid outdated:(bool *)outdated;
- (void)storeUserLink:(int)uid link:(int)link;
- (void)upgradeUserLinks;
- (void)clearCachedUserLinks;

- (TGMessage *)loadMessageWithMid:(int)mid peerId:(int64_t)peerId;
- (TGMessage *)loadMediaMessageWithMid:(int)mid;
- (void)loadUnreadMessagesHeadFromConversation:(int64_t)conversationId limit:(int)limit completion:(void (^)(NSArray *messages, bool isAtBottom))completion;
- (void)loadMessagesFromConversation:(int64_t)conversationId maxMid:(int)maxMid maxDate:(int)maxDate maxLocalMid:(int)maxLocalMid atMessageId:(int)atMessageId limit:(int)limit extraUnread:(bool)extraUnread completion:(void (^)(NSArray *messages, bool historyExistsBelow))completion;
- (NSArray *)messagesWithDateInConversation:(int64_t)peerId date:(int32_t)date;
- (void)loadMessagesFromConversationDownwards:(int64_t)conversationId minMid:(int)argMinMid minLocalMid:(int)argMinLocalMid minDate:(int)argMinDate limit:(int)argLimit completion:(void (^)(NSArray *messages))completion;

//- (void)addMessagesToConversation:(NSArray *)messages conversationId:(int64_t)conversationId updateConversation:(TGConversation *)conversation dispatch:(bool)dispatch countUnread:(bool)countUnread;
//- (void)addMessagesToConversation:(NSArray *)argMessages conversationId:(int64_t)conversationId updateConversation:(TGConversation *)conversation dispatch:(bool)dispatch countUnread:(bool)countUnread updateDates:(bool)updateDates;

- (void)replaceContentPropertiesInMessageWithId:(int32_t)messageId contentProperties:(NSDictionary *)contentProperties;
- (NSArray *)generateLocalMids:(int)count;
//- (void)deleteMessages:(NSArray *)mids populateActionQueue:(bool)populateActionQueue fillMessagesByConversationId:(NSMutableDictionary *)messagesByConversationId;
//- (void)deleteConversation:(int64_t)conversationId populateActionQueue:(bool)populateActionQueue;
//- (void)clearConversation:(int64_t)conversationId populateActionQueue:(bool)populateActionQueue;
//- (void)markMessagesAsReadInConversation:(int64_t)conversationId maxDate:(int32_t)maxDate referenceDate:(int32_t)referenceDate;

#ifdef __cplusplus
/*- (void)updateMessage:(int)mid peerId:(int64_t)peerId flags:(std::vector<TGDatabaseMessageFlagValue> const &)flags media:(NSArray *)media dispatch:(bool)dispatch;
- (void)updateMessage:(int)mid peerId:(int64_t)peerId flags:(std::vector<TGDatabaseMessageFlagValue> const &)flags media:(NSArray *)media text:(NSString *)text dispatch:(bool)dispatch;*/
#endif

//- (void)updateMessageTextOrMedia:(int)mid peerId:(int64_t)peerId media:(NSArray *)media text:(NSString *)text messageFlags:(NSNumber *)flags dispatch:(bool)dispatch;

//- (void)updateMessage:(int32_t)mid peerId:(int64_t)peerId withMessage:(TGMessage *)message;
//- (void)updateMessages:(NSArray *)messages;

- (void)updateMessageViews:(int64_t)peerId messageIdToViews:(NSDictionary *)messageIdToViews;
- (void)updateMessageRangesPts:(int64_t)peerId messageRanges:(NSArray *)messageRanges pts:(int32_t)pts;

- (void)setTempIdForMessageId:(int)messageId peerId:(int64_t)peerId tempId:(int64_t)tempId;
- (void)removeTempIds:(NSArray *)tempIds;

#ifdef __cplusplus
- (void)messageIdsForTempIds:(NSArray *)tempIds mapping:(std::map<int64_t, int> *)mapping;
- (void)tempIdsForLocalMessages:(void (^)(std::vector<std::pair<int64_t, int> >))completion;
#endif

- (int32_t)messageIdForRandomId:(int64_t)randomId;
- (int64_t)randomIdForMessageId:(int32_t)messageId;
#ifdef __cplusplus
- (void)messageIdsForRandomIds:(NSArray *)randomIds mapping:(std::map<int64_t, int32_t> *)mapping;
- (void)randomIdsForMessageIds:(NSArray *)messageIds mapping:(std::map<int32_t, int64_t> *)mapping;
#endif
- (NSArray *)messageIdsInConversation:(int64_t)conversationId;

- (void)loadConversationState:(int64_t)conversationId forwardMessageDescs:(__autoreleasing NSArray **)forwardMessageDescs messageEditingContext:(__autoreleasing TGMessageEditingContext **)messageEditingContext scrollState:(__autoreleasing TGConversationScrollState **)scrollState;
- (void)storeConversationState:(int64_t)conversationId messageEditingContext:(TGMessageEditingContext *)messageEditingContext forwardMessageDescs:(NSArray *)forwardMessageDescs scrollState:(TGConversationScrollState *)scrollState;
- (void)storeConversationParticipantData:(int64_t)conversationId participantData:(TGConversationParticipantsData *)participantData;

//- (void)readHistory:(int64_t)conversationId includeOutgoing:(bool)includeOutgoing populateActionQueue:(bool)populateActionQueue minRemoteMid:(int)minRemoteMid completion:(void (^)(bool hasItemsOnActionQueue))completion;

- (void)loadMediaPositionInConversation:(int64_t)conversationId messageId:(int)messageId completion:(void (^)(int position, int count))completion;
- (NSArray *)loadMediaInConversation:(int64_t)conversationId atMessageId:(int)atMessageId limitAfter:(int)limitAfter count:(int *)count important:(bool)important;
- (NSArray *)loadMediaInConversation:(int64_t)conversationId maxMid:(int)maxMid maxLocalMid:(int)maxLocalMid maxDate:(int)maxDate limit:(int)limit count:(int *)count important:(bool)important;
- (void)addMediaToConversation:(int64_t)conversationId messages:(NSArray *)messages completion:(void (^)(int count))completion;
- (void)loadLastRemoteMediaMessageIdInConversation:(int64_t)conversationId completion:(void (^)(int32_t messageId))completion;
- (int32_t)mediaCountInConversation:(int64_t)conversationId;

- (void)storeQueuedActions:(NSArray *)actions;
- (void)confirmQueuedActions:(NSArray *)actions requireFullMatch:(bool)requireFullMatch;
- (void)loadQueuedActions:(NSArray *)actionTypes completion:(void (^)(NSMutableDictionary *actionSetsByType))completion;

- (void)storeFutureActions:(NSArray *)actions;
- (void)removeFutureAction:(int64_t)uniqueId type:(int)type randomId:(int)randomId;
- (void)removeFutureActionsWithType:(int)type uniqueIds:(NSArray *)uniqueIds;
- (NSArray *)loadOneFutureAction;
- (NSArray *)loadFutureActionsWithType:(int)type;
- (TGFutureAction *)loadFutureAction:(int64_t)uniqueId type:(int)type;

- (int)loadPeerMinMid:(int64_t)peerId;
- (int)loadPeerMinMediaMid:(int64_t)peerId;
- (void)loadPeerNotificationSettings:(int64_t)peerId soundId:(int *)soundId muteUntil:(int *)muteUntil previewText:(bool *)previewText messagesMuted:(bool *)messagesMuted notFound:(bool *)notFound;
- (BOOL)isPeerMuted:(int64_t)peerId;

#ifdef __cplusplus
- (std::set<int>)filterPeerPhotoNotificationsEnabled:(std::vector<int> const &)uidList;
#endif

- (int)minAutosaveMessageIdForConversation:(int64_t)conversationId;
- (void)storePeerMinMid:(int64_t)peerId minMid:(int)minMid;
- (void)storePeerMinMediaMid:(int64_t)peerId minMediaMid:(int)minMediaMid;

- (void)storePeerNotificationSettings:(int64_t)peerId soundId:(int)soundId muteUntil:(int)muteUntil previewText:(bool)previewText messagesMuted:(bool)messagesMuted writeToActionQueue:(bool)writeToActionQueue completion:(void (^)(bool))completion;

- (void)setConversationCustomProperty:(int64_t)conversationId name:(int)name value:(NSData *)value;
- (void)conversationCustomProperty:(int64_t)conversationId name:(int)name completion:(void (^)(NSData *value))completion;
- (NSData *)conversationCustomPropertySync:(int64_t)conversationId name:(int)name;
- (void)clearPeerNotificationSettings:(bool)writeToActionQueue;
- (void)addConversationHistoryHole:(int64_t)peerId minMessageId:(int32_t)minMessageId maxMessageId:(int32_t)maxMessageId;
- (void)addConversationHistoryHoleToLoadedLaterMessages:(int64_t)peerId maxMessageId:(int32_t)maxMessageId;
- (void)fillConversationHistoryHole:(int64_t)peerId indexSet:(NSIndexSet *)indexSet;
- (bool)conversationContainsHole:(int64_t)peerId minMessageId:(int32_t)minMessageId maxMessageId:(int32_t)maxMessageId;
- (NSArray *)excludeMessagesWithHolesFromArray:(NSArray *)messages peerId:(int64_t)peerId aroundMessageId:(int32_t)aroundMessageId;

- (void)setAssetIsStored:(NSString *)url;
- (void)checkIfAssetIsStored:(NSString *)url completion:(void (^)(bool stored))completion;

- (void)setPeerIsBlocked:(int64_t)peerId blocked:(bool)blocked writeToActionQueue:(bool)writeToActionQueue;
- (void)loadPeerIsBlocked:(int64_t)peerId completion:(void (^)(bool blocked))completion;
- (void)replaceBlockedList:(NSArray *)blockedPeers;
- (void)loadBlockedList:(void (^)(NSArray *blockedList))completion;
- (int)loadBlockedDate:(int64_t)peerId;

- (void)storePeerProfilePhotos:(int64_t)peerId photosArray:(NSArray *)photosArray append:(bool)append;
- (NSArray *)addPeerProfilePhotos:(int64_t)peerId photosArray:(NSArray *)photosArray;
- (void)loadPeerProfilePhotos:(int64_t)peerId completion:(void (^)(NSArray *photosArray))completion;
- (void)deletePeerProfilePhotos:(int64_t)peerId imageIds:(NSArray *)imageIds;
- (void)clearPeerProfilePhotos;
- (void)clearPeerProfilePhotos:(int64_t)peerId;

- (void)updateLatestMessageId:(int)mid applied:(bool)applied completion:(void (^)(int greaterMidForSynchronization))completion;
- (void)updateLatestQts:(int32_t)qts applied:(bool)applied completion:(void (^)(int greaterQtsForSynchronization))completion;
- (void)checkIfLatestMessageIdIsNotApplied:(void (^)(int midForSinchronization))completion;
- (void)checkIfLatestQtsIsNotApplied:(void (^)(int qtsForSinchronization))completion;

- (TGMediaAttachment *)loadServerAssetData:(NSString *)key;
- (void)storeServerAssetData:(NSString *)key attachment:(TGMediaAttachment *)attachment;
- (void)clearServerAssetData;

- (int64_t)peerIdForEncryptedConversationId:(int64_t)encryptedConversationId;
- (int64_t)peerIdForEncryptedConversationId:(int64_t)encryptedConversationId createIfNecessary:(bool)createIfNecessary;
- (int64_t)encryptedConversationIdForPeerId:(int64_t)peerId;
- (int64_t)encryptedConversationAccessHash:(int64_t)conversationId;
- (NSData *)encryptionKeyForConversationId:(int64_t)conversationId requestedKeyFingerprint:(int64_t)requestedKeyFingerprint outKeyFingerprint:(int64_t *)outKeyFingerprint;
- (NSData *)encryptionKeySignatureForConversationId:(int64_t)conversationId additionalSignature:(__autoreleasing NSData **)additionalSignature;
- (int32_t)currentEncryptionKeyUseCount:(int64_t)peerId;
- (void)storeEncryptionKeyForConversationId:(int64_t)conversationId key:(NSData *)key keyFingerprint:(int64_t)keyFingerprint firstSeqOut:(int32_t)firstSeqOut;
- (void)discardEncryptionKeysForConversationId:(int64_t)conversationId beforeSeqOut:(int32_t)beforeSeqOut;
- (void)raiseSecretMessageFlagsByMessageId:(int32_t)messageId flagsToRise:(int)flagsToRise;
- (int)encryptedParticipantIdForConversationId:(int64_t)conversationId;
- (bool)encryptedConversationIsCreator:(int64_t)conversationId;

- (int64_t)activeEncryptedPeerIdForUserId:(int)userId;

- (void)setLastReportedToPeerLayer:(int64_t)peerId layer:(NSUInteger)layer;
- (NSUInteger)lastReportedToPeerLayer:(int64_t)peerId;
- (void)setPeerLayer:(int64_t)peerId layer:(NSUInteger)layer;
- (void)maybeCreateAdditionalEncryptedHashForPeer:(int64_t)peerId;
- (NSUInteger)peerLayer:(int64_t)peerId;
- (void)loadAllSercretChatPeerIds:(void (^)(NSArray *))completion;

- (SSignal *)channelShouldMuteMembers:(int64_t)peerId;
- (void)setChannelShouldMuteMembers:(int64_t)peerId value:(bool)value;

- (void)processAndScheduleSelfDestruct;

#ifdef __cplusplus
- (void)filterExistingRandomIds:(std::set<int64_t> *)randomIds;
#endif

- (int)messageLifetimeForPeerId:(int64_t)peerId;
- (void)setMessageLifetimeForPeerId:(int64_t)peerId encryptedConversationId:(int64_t)encryptedConversationId messageLifetime:(int)messageLifetime writeToActionQueue:(bool)writeToActionQueue;

- (void)initiateSelfDestructForMessageIds:(NSArray *)messageIds;
- (NSTimeInterval)messageCountdownLocalTime:(int32_t)mid enqueueIfNotQueued:(bool)enqueueIfNotQueued initiatedCountdown:(bool *)initiatedCountdown;
- (void)raiseSecretMessageFlagsByRandomId:(int64_t)randomId flagsToRise:(int)flagsToRise;
- (int)secretMessageFlags:(int32_t)messageId;

- (void)findAllMediaMessages:(void (^)(NSArray *))completion isCancelled:(bool (^)())isCancelled;

- (void)updateLastUseDateForMediaType:(int32_t)mediaType mediaId:(int64_t)mediaId messageId:(int32_t)messageId;
- (void)processAndScheduleMediaCleanup;

- (void)peersWithOutgoingAndIncomingActions:(void (^)(NSArray *, NSArray *))completion;
- (int32_t)peerNextSeqOut:(int64_t)peerId;
- (void)enqueuePeerOutgoingAction:(int64_t)peerId action:(id<PSCoding>)action useSeq:(bool)useSeq seqOut:(int32_t *)seqOut seqIn:(int32_t *)seqIn actionId:(int32_t *)actionId;
- (void)dequeuePeerOutgoingActions:(int64_t)peerId completion:(void (^)(NSArray *, NSArray *))completion;
- (void)enqueuePeerOutgoingResendActions:(int64_t)peerId fromSeq:(int32_t)fromSeq toSeq:(int32_t)toSeq completion:(void (^)(bool))completion;
- (void)deletePeerOutgoingActions:(int64_t)peerId actionIds:(NSArray *)actionIds;
- (void)enqueuePeerIncomingActions:(int64_t)peerId actions:(NSArray *)actions;
- (void)enqueuePeerIncomingEncryptedActions:(int64_t)peerId actions:(NSArray *)actions;
- (void)dequeuePeerIncomingActions:(int64_t)peerId completion:(void (^)(NSArray *, int32_t, NSArray *))completion;
- (void)deletePeerOutgoingResendActions:(int64_t)peerId actionIds:(NSArray *)actionIds;
- (void)confirmPeerSeqOut:(int64_t)peerId seqOut:(int32_t)seqOut;
- (void)applyPeerSeqOut:(int64_t)peerId seqOut:(int32_t)seqOut;
- (int32_t)currentPeerSentSeqOut:(int64_t)peerId;
- (void)applyPeerSeqIn:(int64_t)peerId seqIn:(int32_t)seqIn;
- (bool)currentPeerResendSeqIn:(int64_t)peerId seqIn:(int32_t *)seqIn;
- (void)setCurrentPeerResendSeqIn:(int64_t)peerId seqIn:(int32_t)seqIn;
- (void)deletePeerIncomingActions:(int64_t)peerId actionIds:(NSArray *)actionIds;
- (void)deletePeerIncomingEncryptedActions:(int64_t)peerId actionIds:(NSArray *)actionIds;

- (void)processAndScheduleMute;

- (void)cacheMediaForPeerId:(int64_t)peerId messages:(NSArray *)messages;
- (void)cachedMediaForPeerId:(int64_t)peerId itemType:(TGSharedMediaCacheItemType)itemType limit:(NSUInteger)limit important:(bool)important completion:(void (^)(NSArray *, bool))completion buildIndex:(bool)buildIndex isCancelled:(bool (^)())isCancelled;
- (void)setSharedMediaIndexDownloadedForPeerId:(int64_t)peerId itemType:(TGSharedMediaCacheItemType)itemType;
- (void)clearCachedMedia;

- (NSString *)currentPassword;
- (void)setPassword:(NSString *)password isStrong:(bool)isStrong completion:(void (^)())completion;
- (bool)isPasswordSet:(bool *)isStrong;
- (bool)verifyPassword:(NSString *)password;
- (void)setEncryptionEnabled:(bool)encryptionEnabled completion:(void (^)())completion;
- (bool)isEncryptionEnabled;

- (TGBotInfo *)botInfoForUserId:(int32_t)userId;
- (void)storeBotInfo:(TGBotInfo *)botInfo forUserId:(int32_t)userId;
- (SSignal *)signalBotReplyMarkupForPeerId:(int64_t)peerId;
- (TGBotReplyMarkup *)botReplyMarkupForPeerId:(int64_t)peerId;
- (void)storeBotReplyMarkupActivated:(TGBotReplyMarkup *)botReplyMarkup forPeerId:(int64_t)peerId;
- (void)storeBotReplyMarkupManuallyHidden:(TGBotReplyMarkup *)botReplyMarkup forPeerId:(int64_t)peerId manuallyHidden:(bool)manuallyHidden;

- (NSArray *)backedUpDatabasePaths;

- (void)initializeChannel:(TGConversation *)conversation;
- (void)storeSynchronizedChannels:(NSArray *)channels;
- (void)updateChannels:(NSArray *)channels;

- (void)updateChannelDisplayVariant:(int64_t)peerId displayVariant:(int32_t)displayVariant;

- (void)updateChannelPostAsChannel:(int64_t)peerId postAsChannel:(bool)postAsChannel;

- (void)updateChannelPinnedMessageId:(int64_t)peerId pinnedMessageId:(int32_t)pinnedMessageId hidden:(NSNumber *)hidden;
- (void)updateChannelAbout:(int64_t)peerId about:(NSString *)about;
- (void)updateChannelUsername:(int64_t)peerId username:(NSString *)username;
- (void)updateChannelReadState:(int64_t)peerId maxReadId:(int32_t)maxReadId unreadImportantCount:(int32_t)unreadImportantCount unreadUnimportantCount:(int32_t)unreadUnimportantCount;
- (void)updateChannelRead:(int64_t)peerId maxReadId:(int32_t)maxReadId maxReadOutgoingId:(int32_t)maxReadOutgoingId;
- (void)channelMessages:(int64_t)peerId maxTransparentSortKey:(TGMessageTransparentSortKey)maxSortKey count:(NSUInteger)count important:(bool)important mode:(TGChannelHistoryRequestMode)mode completion:(void (^)(NSArray *messages, bool hasLater))completion;
- (void)channelMessageExists:(int64_t)peerId messageId:(int32_t)messageId completion:(void (^)(bool exists, TGMessageSortKey key))completion;
- (void)closestChannelMessageKey:(int64_t)peerId messageId:(int32_t)messageId completion:(void (^)(bool exists, TGMessageSortKey key))completion;
- (void)nextChannelIncomingMessageKey:(int64_t)peerId messageId:(int32_t)messageId completion:(void (^)(bool exists, TGMessageSortKey key))completion;
- (void)channelEarlierMessage:(int64_t)peerId messageId:(int32_t)messageId timestamp:(int32_t)timestamp important:(bool)important completion:(void (^)(bool exists, TGMessageSortKey key))completion;

- (void)addMessagesToChannel:(int64_t)peerId messages:(NSArray *)messages deleteMessages:(NSArray *)deleteMessages unimportantGroups:(NSArray *)unimportantGroups addedHoles:(NSArray *)addedHoles removedHoles:(NSArray *)removedHoles removedUnimportantHoles:(NSArray *)removedUnimportantHoles updatedMessageSortKeys:(NSArray *)updatedMessageSortKeys returnGroups:(bool)returnGroups keepUnreadCounters:(bool)keepUnreadCounters changedMessages:(void (^)(NSArray *addedMessages, NSArray *removedMessages, NSDictionary *updatedMessages, NSArray *addedUnimportantHoles, NSArray *removedUnimportantHoles))changedMessages;

- (void)addTrailingHoleToChannelAndDispatch:(int64_t)peerId messages:(NSArray *)messages pts:(int32_t)pts importantUnreadCount:(int32_t)importantUnreadCount unimportantUnreadCount:(int32_t)unimportantUnreadCount maxReadId:(int32_t)maxReadId;
- (void)addMessagesToChannelAndDispatch:(int64_t)peerId messages:(NSArray *)messages deletedMessages:(NSArray *)deletedMessages holes:(NSArray *)holes pts:(int32_t)pts;
- (SSignal *)deleteMessagesInChannel:(int64_t)peerId fromUserId:(int32_t)userId;
- (void)channelPts:(int64_t)peerId completion:(void (^)(int32_t pts))completion;
- (SSignal *)existingChannel:(int64_t)peerId;
- (bool)_channelExists:(int64_t)peerId;
- (NSDictionary *)loadChannels:(NSArray *)peerIds;
- (SSignal *)areChannelsSynchronized;
- (SSignal *)channelList;

- (void)enqueueDeleteChannelMessages:(int64_t)peerId messageIds:(NSArray *)messageIds;
- (void)confirmChannelMessagesDeleted:(TGQueuedDeleteChannelMessages *)messages;
- (SSignal *)enqueuedDeleteChannelMessages;

- (void)enqueueReadChannelHistory:(int64_t)peerId;
- (void)confirmChannelHistoryRead:(TGQueuedReadChannelMessages *)messages;
- (SSignal *)enqueuedReadChannelMessages;

- (void)enqueueLeaveChannel:(int64_t)peerId;
- (void)confirmChannelLeaved:(TGQueuedLeaveChannel *)leaveChannel;
- (SSignal *)enqueuedLeaveChannels;

- (void)updateChannelCachedData:(int64_t)peerId block:(TGCachedConversationData *(^)(TGCachedConversationData *))block;
- (SSignal *)channelCachedData:(int64_t)peerId;
- (TGCachedConversationData *)_channelCachedDataSync:(int64_t)peerId;

- (void)updateCachedUserData:(int64_t)peerId block:(TGCachedUserData *(^)(TGCachedUserData *))block;
- (SSignal *)userCachedData:(int64_t)peerId;
- (TGCachedUserData *)_userCachedDataSync:(int64_t)peerId;

- (SSignal *)modify:(id (^)())block;
- (SSignal *)modifyChannel:(int64_t)peerId block:(id (^)(int32_t pts))block;

- (void)_dropChannels;

- (void)clearSpotlightIndex:(void (^)())completion;
- (void)updateSpotlightIndex;

- (void)readDeactivatedConversations;

- (void)updateHistoryPtsForPeerId:(int64_t)peerId pts:(int32_t)pts;
- (SSignal *)channelHistoryPtsForPeerId:(int64_t)peerId;

- (SSignal *)evaluatedDiskCacheStats;
- (SSignal *)evaluatePeerCacheStats:(int64_t)peerId;

- (SSignal *)cachedPeerSettings:(int64_t)peerId;
- (void)updateCachedPeerSettings:(int64_t)peerId block:(TGCachedPeerSettings *(^)(TGCachedPeerSettings *))block;

- (SSignal *)shouldReportSpamForPeerId:(int64_t)peerId;
- (void)hideReportSpamForPeerId:(int64_t)peerId;
- (SSignal *)enqueuedDismissReportPeerSpamPeerIds;
- (void)commitDismissReportPeerSpam:(int64_t)peerId;

- (SSignal *)cachedRecentPeers;
- (NSArray<TGUser *> *)_syncCachedRecentInlineBots:(CGFloat)rating;
- (void)replaceCachedRecentPeers:(TGRemoteRecentPeerCategories *)categories;
- (void)updatePeerRatings:(NSArray<TGPeerRatingUpdates *> *)updates;
- (NSArray<TGPeerRatingUpdates *> *)peerRatingUpdatesFromOutgoingMessageEvents:(NSDictionary<NSNumber *, NSArray<NSNumber *> *> *)outgoingMessageEvents;
- (void)resetPeerRating:(int64_t)peerId category:(TGPeerRatingCategory)category;

- (void)transactionAddMessages:(NSArray<TGMessage *> *)addMessages updateConversationDatas:(NSDictionary <NSNumber *, TGConversation *> *)updateConversationDatas notifyAdded:(bool)notifyAdded;
- (void)transactionRemoveMessages:(NSDictionary<NSNumber *, NSArray<NSNumber *> *> *)removeMessages updateConversationDatas:(NSDictionary <NSNumber *, TGConversation *> *)updateConversationDatas;
- (void)transactionUpdateMessages:(NSArray<TGDatabaseUpdateMessage *> *)updateMessages updateConversationDatas:(NSDictionary <NSNumber *, TGConversation *> *)updateConversationDatas;
- (void)transactionRemoveMessagesInteractive:(NSDictionary<NSNumber *, NSArray<NSNumber *> *> *)removeMessagesInteractive keepDates:(bool)keepDates removeMessagesInteractiveForEveryone:(bool) removeMessagesInteractiveForEveryone updateConversationDatas:(NSDictionary <NSNumber *, TGConversation *> *)updateConversationDatas;
- (void)transactionResetPeerReadStates:(NSDictionary<NSNumber *, TGPeerReadState *> *)resetPeerReadStates;
- (void)transactionReadHistoryForPeerIds:(NSSet<NSNumber *> *)peerIds;
- (void)transactionApplyMaxOutgoingReadIds:(NSDictionary<NSNumber *, NSNumber *> *)applyMaxOutgoingReadIds;
- (void)transactionClearConversationsWithPeerIds:(NSArray<NSNumber *> *)peerIds;
- (void)transactionRemoveConversationsWithPeerIds:(NSArray<NSNumber *> *)peerIds;
- (void)transactionUpdatePinnedConversations:(NSArray<NSNumber *> *)pinnedConversations synchronizePinnedConversations:(bool)synchronizePinnedConversations forceReplacePinnedConversations:(bool)forceReplacePinnedConversations;

- (void)transactionAddMessages:(NSArray<TGMessage *> *)addMessages
           notifyAddedMessages:(bool)notifyAddedMessages
                removeMessages:(NSDictionary<NSNumber *, NSArray<NSNumber *> *> *)removeMessages
                updateMessages:(NSArray<TGDatabaseUpdateMessage *> *)updateMessages
              updatePeerDrafts:(NSDictionary<NSNumber *, TGDatabaseMessageDraft *> *)updatePeerDrafts
     removeMessagesInteractive:(NSDictionary<NSNumber *, NSArray<NSNumber *> *> *)removeMessagesInteractive
                     keepDates:(bool)keepDates
removeMessagesInteractiveForEveryone:(bool)removeMessagesInteractiveForEveryone
       updateConversationDatas:(NSDictionary<NSNumber *, TGConversation *> *)updateConversationDatas
       applyMaxIncomingReadIds:(NSDictionary<NSNumber *, NSNumber *> *)applyMaxIncomingReadIds
       applyMaxOutgoingReadIds:(NSDictionary<NSNumber *, NSNumber *> *)applyMaxOutgoingReadIds
     applyMaxOutgoingReadDates:(NSDictionary<NSNumber *, TGDatabaseReadMessagesByDate *> *)applyMaxOutgoingReadDates
         readHistoryForPeerIds:(NSSet<NSNumber *> *)readHistoryForPeerIds
           resetPeerReadStates:(NSDictionary<NSNumber *, TGPeerReadState *> *)resetPeerReadStates
 clearConversationsWithPeerIds:(NSArray<NSNumber *> *)clearConversationsWithPeerIds
removeConversationsWithPeerIds:(NSArray<NSNumber *> *)removeConversationsWithPeerIds
     updatePinnedConversations:(NSArray<NSNumber *> *)updatePinnedConversations
synchronizePinnedConversations:(bool)synchronizePinnedConversations
forceReplacePinnedConversations:(bool)forceReplacePinnedConversations;

- (SSignal *)conversationsForReadStateValidation;

- (void)_addedNewMessages:(NSArray<TGMessage *> *)messages;

- (TGDatabaseMessageDraft *)_peerDraft:(int64_t)peerId;
- (void)updatePeerDraftInteractive:(int64_t)peerId draft:(TGDatabaseMessageDraft *)draft;

- (SSignal *)verifySynchronizedDraft:(int64_t)peerId draft:(TGDatabaseMessageDraft *)draft;
- (SSignal *)synchronizePeerMessageDraftPeers;

- (TGSynchronizePinnedConversationsAction *)currentSynchronizePinnedConversationsAction;
- (void)_setCurrentSynchronizePinnedConversationsAction:(TGSynchronizePinnedConversationsAction *)action;
- (SSignal *)synchronizePinnedConversationsActionUpdated;
- (void)schedulePullPinnedConversations;
- (void)schedulePushPinnedConversations;

- (void)commitSynchronizedPinnedConversationPeers:(NSArray *)peerIds;

- (TGWebPageMediaAttachment *)_webpageWithId:(int64_t)webPageId;
- (void)updateWebpages:(NSArray<TGWebPageMediaAttachment *> *)webpages;

- (void)cacheBotCallbackResponse:(NSData *)key response:(NSData *)response;
- (NSData *)_cachedBotCallbackResponse:(NSData *)data;

- (NSArray<TGUser *> *)contactUsersMatchingPhone:(NSString *)phoneNumber;

- (NSArray<TGConversation *> *)_getPinnedConversations;

- (TGInstantPageScrollState *)loadInstantPageScrollState:(int64_t)webPageId;
- (void)storeInstantPageScrollState:(int64_t)webPageId scrollState:(TGInstantPageScrollState *)scrollState;

- (void)switchToWal;

- (void)setSuggestedLocalizationCode:(NSString *)code;
- (SSignal *)suggestedLocalizationCode;

+ (NSArray *)searchUsersInArray:(NSArray *)users query:(NSString *)query;

- (NSDictionary *)loadPopularInvitees;
- (void)replacePopularInvitees:(NSArray *)invitees;

@end

#ifdef DEBUG_DATABASE_INVOKATIONS
#define dispatchOnDatabaseThread dispatchOnDatabaseThreadDebug:__FILE__ line:__LINE__ block
#endif
