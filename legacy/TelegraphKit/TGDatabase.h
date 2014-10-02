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
#import "TGAcceptEncryptionFutureAction.h"
#import "TGEncryptedChatServiceAction.h"

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
#include <tr1/memory>
#include <set>
#endif

typedef enum {
    TGDatabaseMessageFlagUnread = 1,
    TGDatabaseMessageFlagDeliveryState = 2,
    TGDatabaseMessageFlagMid = 3,
    TGDatabaseMessageFlagDate = 4
    
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
    TGDatabaseActionClearSecretConversation = 6
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

#ifdef __cplusplus
extern "C" {
#endif
TGDatabase *TGDatabaseInstance();
#ifdef __cplusplus
}
#endif

typedef void (^TGDatabaseMessageCleanupBlock)(TGMediaAttachment *attachment);
typedef void (^TGDatabaseCleanupEverythingBlock)();

@interface TGDatabase : NSObject

+ (void)setDatabaseName:(NSString *)name;
+ (void)setLiveMessagesDispatchPath:(NSString *)path;
+ (void)setLiveBroadcastMessagesDispatchPath:(NSString *)path;
+ (void)setLiveUnreadCountDispatchPath:(NSString *)path;

+ (TGDatabase *)instance;

@property (nonatomic, copy) TGDatabaseMessageCleanupBlock messageCleanupBlock;
@property (nonatomic, copy) TGDatabaseCleanupEverythingBlock cleanupEverythingBlock;

@property (nonatomic) NSTimeInterval timeDifferenceFromUTC;

- (void)dispatchOnDatabaseThread:(dispatch_block_t)block synchronous:(bool)synchronous;
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
- (NSArray *)loadPhonebookContacts;

- (void)replaceRemoteContactUids:(NSArray *)uids;
- (void)addRemoteContactUids:(NSArray *)uids;
- (void)deleteRemoteContactUids:(NSArray *)uids;

- (TGContactBinding *)contactBindingWithId:(int)contactId;
- (NSArray *)contactBindings;
- (void)addContactBindings:(NSArray *)contactBindings;
- (void)deleteContactBinding:(int)phoneId;
- (void)replaceContactBindings:(NSArray *)contactBindings;

- (void)storeConversationList:(NSArray *)conversations replace:(bool)replace;

- (void)loadConversationListInitial:(void (^)(NSArray *dialogList, NSArray *userIds))completion;
- (void)loadConversationListFromDate:(int)date limit:(int)limit excludeConversationIds:(NSArray *)excludeConversationIds completion:(void (^)(NSArray *))completion;
- (void)loadBroadcastConversationListFromDate:(int)date limit:(int)limit excludeConversationIds:(NSArray *)excludeConversationIds completion:(void (^)(NSArray *))completion;
- (int)loadConversationListRemoteOffset;
- (TGConversation *)loadConversationWithId:(int64_t)conversationId;
- (TGConversation *)loadConversationWithIdCached:(int64_t)conversationId;
- (BOOL)containsConversationWithId:(int64_t)conversationId;

- (void)buildTransliterationCache;
- (void)searchDialogs:(NSString *)query ignoreUid:(int)ignoreUid completion:(void (^)(NSDictionary *))completion;
- (void)searchContacts:(NSString *)query ignoreUid:(int)ignoreUid searchPhonebook:(bool)searchPhonebook completion:(void (^)(NSDictionary *))completion;
- (NSArray *)searchPhonebookContacts:(NSString *)query contacts:(NSArray *)contacts;

- (void)searchMessages:(NSString *)query completion:(void (^)(NSArray *, NSSet *))completion;

- (void)setLocalUserId:(int)localUserId;
- (TGUser *)loadUser:(int)uid;
- (int)loadCachedPhoneIdByUid:(int)uid;
- (void)storeUsers:(NSArray *)userList;
- (int)loadUsersOnlineCount:(NSArray *)uids alwaysOnlineUid:(int)alwaysOnlineUid;
#ifdef __cplusplus
- (void)loadCachedUsersWithContactIds:(std::set<int> const &)contactIds resultMap:(std::map<int, TGUser *> &)resultMap;
- (std::tr1::shared_ptr<std::map<int, TGUser *> >)loadUsers:(std::vector<int> const &)uidList;
- (void)storeUsersPresences:(std::map<int, TGUserPresence> *)presenceMap;
#endif

- (int)loadUserLink:(int)uid outdated:(bool *)outdated;
- (void)storeUserLink:(int)uid link:(int)link;
- (void)upgradeUserLinks;

- (TGMessage *)loadMessageWithMid:(int)mid;
- (TGMessage *)loadMediaMessageWithMid:(int)mid;
- (void)loadUnreadMessagesHeadFromConversation:(int64_t)conversationId limit:(int)limit completion:(void (^)(NSArray *messages, bool isAtBottom))completion;
- (void)loadMessagesFromConversation:(int64_t)conversationId maxMid:(int)maxMid maxDate:(int)maxDate maxLocalMid:(int)maxLocalMid atMessageId:(int)atMessageId limit:(int)limit extraUnread:(bool)extraUnread completion:(void (^)(NSArray *messages, bool historyExistsBelow))completion;
- (void)loadMessagesFromConversationDownwards:(int64_t)conversationId minMid:(int)argMinMid minLocalMid:(int)argMinLocalMid minDate:(int)argMinDate limit:(int)argLimit completion:(void (^)(NSArray *messages))completion;
- (void)addMessagesToConversation:(NSArray *)messages conversationId:(int64_t)conversationId updateConversation:(TGConversation *)conversation dispatch:(bool)dispatch countUnread:(bool)countUnread;
- (void)addMessagesToConversation:(NSArray *)argMessages conversationId:(int64_t)conversationId updateConversation:(TGConversation *)conversation dispatch:(bool)dispatch countUnread:(bool)countUnread updateDates:(bool)updateDates;
- (void)replaceMediaInMessagesWithLocalMediaId:(int)localMediaId media:(NSData *)media;
- (NSArray *)generateLocalMids:(int)count;
- (void)renewLocalMessagesInConversation:(NSArray *)messages conversationId:(int64_t)conversationId;
- (void)deleteMessages:(NSArray *)mids populateActionQueue:(bool)populateActionQueue fillMessagesByConversationId:(NSMutableDictionary *)messagesByConversationId;
- (void)deleteConversation:(int64_t)conversationId populateActionQueue:(bool)populateActionQueue;
- (void)clearConversation:(int64_t)conversationId populateActionQueue:(bool)populateActionQueue;
- (void)markMessagesAsRead:(NSArray *)mids;
- (void)markMessagesAsReadInConversation:(int64_t)conversationId maxDate:(int32_t)maxDate referenceDate:(int32_t)referenceDate;

#ifdef __cplusplus
- (void)updateMessage:(int)mid flags:(std::vector<TGDatabaseMessageFlagValue> const &)flags media:(NSArray *)media dispatch:(bool)dispatch;
- (void)updateMessageIds:(std::vector<std::pair<int, int> > const &)mapping;
#endif

- (void)setTempIdForMessageId:(int)messageId tempId:(int64_t)tempId;
- (int)messageIdForTempId:(int64_t)tempId;
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

- (void)preloadConversationStates:(NSArray *)conversationIds;
- (NSString *)loadConversationState:(int64_t)conversationId;
- (void)storeConversationState:(int64_t)conversationId state:(NSString *)state;
- (void)storeConversationParticipantData:(int64_t)conversationId participantData:(TGConversationParticipantsData *)participantData;

- (void)readHistory:(int64_t)conversationId includeOutgoing:(bool)includeOutgoing populateActionQueue:(bool)populateActionQueue minRemoteMid:(int)minRemoteMid completion:(void (^)(bool hasItemsOnActionQueue))completion;

- (void)loadMediaPositionInConversation:(int64_t)conversationId messageId:(int)messageId completion:(void (^)(int position, int count))completion;
- (NSArray *)loadMediaInConversation:(int64_t)conversationId atMessageId:(int)atMessageId limitAfter:(int)limitAfter count:(int *)count;
- (NSArray *)loadMediaInConversation:(int64_t)conversationId maxMid:(int)maxMid maxLocalMid:(int)maxLocalMid maxDate:(int)maxDate limit:(int)limit count:(int *)count;
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
- (void)loadPeerNotificationSettings:(int64_t)peerId soundId:(int *)soundId muteUntil:(int *)muteUntil previewText:(bool *)previewText photoNotificationsEnabled:(bool *)photoNotificationsEnabled notFound:(bool *)notFound;
- (BOOL)isPeerMuted:(int64_t)peerId;

#ifdef __cplusplus
- (std::set<int>)filterPeerPhotoNotificationsEnabled:(std::vector<int> const &)uidList;
#endif

- (int)minAutosaveMessageIdForConversation:(int64_t)conversationId;
- (void)storePeerMinMid:(int64_t)peerId minMid:(int)minMid;
- (void)storePeerMinMediaMid:(int64_t)peerId minMediaMid:(int)minMediaMid;

- (void)storePeerNotificationSettings:(int64_t)peerId soundId:(int)soundId muteUntil:(int)muteUntil previewText:(bool)previewText photoNotificationsEnabled:(bool)photoNotificationsEnabled writeToActionQueue:(bool)writeToActionQueue completion:(void (^)(bool))completion;

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
- (NSData *)encryptionKeyForConversationId:(int64_t)conversationId keyFingerprint:(int64_t *)keyFingerprint;
- (void)storeEncryptionKeyForConversationId:(int64_t)conversationId key:(NSData *)key keyFingerprint:(int64_t)keyFingerprint;
- (void)raiseSecretMessageFlagsByMessageId:(int32_t)messageId flagsToRise:(int)flagsToRise;
- (int)encryptedParticipantIdForConversationId:(int64_t)conversationId;

- (int64_t)activeEncryptedPeerIdForUserId:(int)userId;

- (bool)hasBroadcastConversations;
- (void)addBroadcastConversation:(NSString *)title userIds:(NSArray *)userIds completion:(void (^)(TGConversation *conversation))completion;

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

@end
