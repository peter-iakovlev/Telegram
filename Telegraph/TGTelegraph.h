/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <thirdparty/AFNetworking/AFHTTPClient.h>

#import "ActionStage.h"

#import "TGUser.h"

#import "TL/TLMetaScheme.h"

#import "TGTelegraphProtocols.h"

#import "TGDatabase.h"

#import "TGModernConversationActivityManager.h"

#import "TGMusicPlayer.h"

#import <SSignalKit/SSignalKit.h>
#import "TGDialogListRemoteOffset.h"

#import "TGCallManager.h"

#import "MediaBox.h"

#ifdef __cplusplus
#include <map>
#include <memory>
#endif

@protocol TGTransport;

@class TGLoginRequestBuilder;
@class TGLogoutRequestBuilder;
@class TGSendCodeRequestBuilder;
@class TGSendInvitesActor;
@class TGSignInRequestBuilder;
@class TGSignUpRequestBuilder;
@class TGDialogListRequestBuilder;

@class TGSynchronizeContactsActor;
@class TGContactListRequestBuilder;
@class TGSuggestedContactsRequestActor;
@class TGLocateContactsActor;
@class TGContactsGlobalSearchActor;
@class TGContactRequestActionActor;

@class TGUpdatePresenceActor;
@class TGRevokeSessionsActor;

@class TGUpdateStateRequestBuilder;
@class TGSynchronizeActionQueueActor;

@class TGUserDataRequestBuilder;
@class TGExtendedUserDataRequestActor;
@class TGPeerSettingsActor;
@class TGSynchronizeServiceActionsActor;
@class TGExtendedChatDataRequestActor;
@class TGBlockListRequestActor;
@class TGChangeNameActor;
@class TGPrivacySettingsRequestActor;
@class TGUpdateUserStatusesActor;

@class TGConversationHistoryAsyncRequestActor;
@class TGConversationActivityRequestBuilder;
@class TGPushActionsRequestBuilder;
@class TGLongPollingRequestBuilder;
@class TGConversationChangeTitleRequestActor;
@class TGConversationChangePhotoActor;
@class TGConversationCreateChatRequestActor;
@class TGConversationAddMemberRequestActor;
@class TGConversationDeleteMemberRequestActor;

@class TGTimelineHistoryRequestBuilder;
@class TGTimelineUploadPhotoRequestBuilder;
@class TGTimelineRemoveItemsRequestActor;
@class TGTimelineAssignProfilePhotoActor;

@class TGProfilePhotoListActor;

@class TGSaveGeocodingResultActor;

@class TGVideoDownloadActor;

@class TGReportDeliveryActor;

@class TGCheckUpdatesActor;
@class TGWallpaperListRequestActor;

@class TGSynchronizePreferencesActor;

@class TGRequestEncryptedChatActor;
@class TGEncryptedChatResponseActor;

@class TGUpdateConfigActor;
@class TGDownloadMessagesActor;
@class TGModernSendCommonMessageActor;
@class TGModernSendSecretMessageActor;
@class TGModernSendBroadcastMessageActor;

@class TGUpdateMediaHistoryActor;

@class TGMessage;

@class TGTelegraph;
extern TGTelegraph *TGTelegraphInstance;

@interface TGTelegraph : AFHTTPClient <ASWatcher>

@property (nonatomic, strong, readonly) TGMusicPlayer *musicPlayer;

@property (nonatomic, strong, readonly) ASHandle *actionHandle;

@property (nonatomic) int transportRequestClass;

// Application Credentials
@property (nonatomic, strong) NSString *apiId;
@property (nonatomic, strong) NSString *apiHash;

// Session Info
@property (nonatomic) int clientUserId;
@property (nonatomic) bool clientIsActivated;

@property (nonatomic, strong, readonly) SMulticastSignalManager *genericTasksSignalManager;
@property (nonatomic, strong, readonly) SMulticastSignalManager *channelStatesSignalManager;
@property (nonatomic, strong, readonly) SDisposableSet *disposeOnLogout;
@property (nonatomic, strong, readonly) SMetaDisposable *checkLocalizationDisposable;
@property (nonatomic) bool checkedLocalization;

@property (nonatomic, strong, readonly) TGCallManager *callManager;
@property (nonatomic, strong, readonly) MediaBox *mediaBox;

- (void)cancelRequestByToken:(NSObject *)token;
- (void)cancelRequestByToken:(NSObject *)token softCancel:(bool)softCancel;

- (TGModernConversationActivityManager *)activityManagerForConversationId:(int64_t)conversationId accessHash:(int64_t)accessHash;

- (void)doLogout:(NSString *)currentPhoneNumber;
- (void)doLogout;
- (void)updatePresenceNow;

- (int)serviceUserUid;
- (int)createServiceUserIfNeeded;

- (int)voipSupportUserUid;
- (int)createVoipSupportUserIfNeeded;

- (void)locationTranslationSettingsUpdated;

- (void)stateUpdateRequired;

- (void)willSwitchBackends;

- (void)dispatchUserDataChanges:(TGUser *)user changes:(int)changes;
- (void)dispatchUserPresenceChanges:(int64_t)userId presence:(TGUserPresence)presence;
#ifdef __cplusplus
- (void)dispatchMultipleUserPresenceChanges:(std::shared_ptr<std::map<int, TGUserPresence> >)presenceMap;
#endif
- (void)dispatchUserActivity:(int)uid inConversation:(int64_t)conversationId type:(NSString *)type;
- (NSDictionary *)typingUserActivitiesInConversationFromMainThread:(int64_t)conversationId;
- (void)dispatchUserLinkChanged:(int)uid link:(int)link;

- (void)subscribeToUserUpdates:(ASHandle *)watcherHandle;
- (void)unsubscribeFromUserUpdates:(ASHandle *)watcherHandle;

- (id)doGetAppPrefs:(TGSynchronizePreferencesActor *)actor;

- (NSObject *)doRequestRawHttp:(NSString *)url maxRetryCount:(int)maxRetryCount acceptCodes:(NSArray *)acceptCodes actor:(id<TGRawHttpActor>)actor;
- (NSObject *)doRequestRawHttp:(NSString *)url maxRetryCount:(int)maxRetryCount acceptCodes:(NSArray *)acceptCodes httpHeaders:(NSDictionary *)httpHeaders actor:(id<TGRawHttpActor>)actor;
- (NSObject *)doRequestRawHttp:(NSString *)url maxRetryCount:(int)maxRetryCount acceptCodes:(NSArray *)acceptCodes httpHeaders:(NSDictionary *)httpHeaders expectedFileSize:(NSInteger)expectedFileSize actor:(id<TGRawHttpActor>)actor;
- (NSObject *)doRequestRawHttp:(NSString *)url maxRetryCount:(int)maxRetryCount acceptCodes:(NSArray *)acceptCodes httpHeaders:(NSDictionary *)httpHeaders expectedFileSize:(NSInteger)expectedFileSize progressBlock:(void (^)(float progress))progressBlock completionBlock:(void (^)(NSData *response))completionBlock;
- (NSObject *)doRequestRawHttpFile:(NSString *)url actor:(id<TGRawHttpFileActor>)actor;

- (NSObject *)doUploadFilePart:(int64_t)fileId partId:(int)partId data:(NSData *)data actor:(id<TGFileUploadActor>)actor;
- (NSObject *)doUploadBigFilePart:(int64_t)fileId partId:(int)partId data:(NSData *)data totalParts:(int)totalParts actor:(id<TGFileUploadActor>)actor;

- (NSObject *)doSendConfirmationCode:(NSString *)phoneNumber requestBuilder:(TGSendCodeRequestBuilder *)requestBuilder;
- (NSObject *)doSendConfirmationSms:(NSString *)phoneNumber phoneHash:(NSString *)phoneHash requestBuilder:(TGSendCodeRequestBuilder *)requestBuilder;
- (NSObject *)doSendPhoneCall:(NSString *)phoneNumber phoneHash:(NSString *)phoneHash requestBuilder:(TGSendCodeRequestBuilder *)requestBuilder;
- (NSObject *)doSignUp:(NSString *)phoneNumber phoneHash:(NSString *)phoneHash phoneCode:(NSString *)phoneCode firstName:(NSString *)firstName lastName:(NSString *)lastName requestBuilder:(TGSignUpRequestBuilder *)requestBuilder;
- (NSObject *)doSignIn:(NSString *)phoneNumber phoneHash:(NSString *)phoneHash phoneCode:(NSString *)phoneCode requestBuilder:(TGSignInRequestBuilder *)requestBuilder;
- (void)processEncryptedPasscode;
- (void)processAuthorizedWithUserId:(int)uid clientIsActivated:(bool)clientIsActivated;
- (void)processUnauthorized;
- (NSObject *)doRequestLogout:(TGLogoutRequestBuilder *)actor;

- (NSObject *)doSendInvites:(NSArray *)phones text:(NSString *)text actor:(TGSendInvitesActor *)actor;

- (id)doCheckUpdates:(TGCheckUpdatesActor *)actor;

- (NSObject *)doSetPresence:(bool)online actor:(TGUpdatePresenceActor *)actor;
- (NSObject *)doRevokeOtherSessions:(TGRevokeSessionsActor *)actor;

- (NSObject *)doUpdatePushSubscription:(bool)subscribe deviceToken:(NSString *)deviceToken requestBuilder:(TGPushActionsRequestBuilder *)requestBuilder;

- (NSObject *)doRequestUserData:(int)uid requestBuilder:(TGUserDataRequestBuilder *)requestBuilder;
- (NSObject *)doRequestExtendedUserData:(int)uid actor:(TGExtendedUserDataRequestActor *)actor;
- (id)doRequestContactStatuses:(TGUpdateUserStatusesActor *)actor;

- (NSObject *)doRequestState:(TGUpdateStateRequestBuilder *)requestBuilder;
- (NSObject *)doRequestStateDelta:(int)pts date:(int)date qts:(int)qts requestBuilder:(TGUpdateStateRequestBuilder *)requestBuilder;

- (NSObject *)doExportContacts:(NSArray *)users requestBuilder:(TGSynchronizeContactsActor *)requestBuilder;
- (NSObject *)doRequestContactList:(NSString *)hash actor:(TGSynchronizeContactsActor *)actor;
- (NSObject *)doRequestContactIdList:(TGSynchronizeContactsActor *)actor;
- (NSObject *)doRequestSuggestedContacts:(int)limit actor:(TGSuggestedContactsRequestActor *)actor;
- (NSObject *)doLocateContacts:(double)latitude longitude:(double)longitude radius:(int)radius discloseLocation:(bool)discloseLocation actor:(id<TGLocateContactsProtocol>)actor;
- (NSObject *)doSearchContacts:(NSString *)query limit:(int)limit actor:(TGContactsGlobalSearchActor *)actor;
- (NSObject *)doSearchContactsByName:(NSString *)query limit:(int)limit completion:(void (^)(TLcontacts_Found *))completion;
- (NSObject *)doDeleteContacts:(NSArray *)uids actor:(id<TGContactDeleteActorProtocol>)actor;

- (NSObject *)doRequestDialogsListWithOffset:(TGDialogListRemoteOffset *)offset limit:(int)limit requestBuilder:(TGDialogListRequestBuilder *)requestBuilder;

- (NSObject *)doRequestConversationHistory:(int64_t)conversationId accessHash:(int64_t)accessHash maxMid:(int)maxMid orOffset:(int)offset limit:(int)limit actor:(TGConversationHistoryAsyncRequestActor *)actor;
- (NSObject *)doRequestConversationMediaHistory:(int64_t)conversationId accessHash:(int64_t)accessHash maxMid:(int)maxMid maxDate:(int)maxDate limit:(int)limit actor:(TGUpdateMediaHistoryActor *)actor;
- (NSObject *)doConversationSendMessage:(int64_t)conversationId accessHash:(int64_t)accessHash messageText:(NSString *)messageText messageGuid:(NSString *)messageGuid tmpId:(int64_t)tmpId replyMessageId:(int32_t)replyMessageId disableLinkPreviews:(bool)disableLinkPreviews postAsChannel:(bool)postAsChannel notifyMembers:(bool)notifyMembers entities:(NSArray *)entities actor:(TGModernSendCommonMessageActor *)actor;
- (NSObject *)doConversationSendLocation:(int64_t)conversationId accessHash:(int64_t)accessHash latitude:(double)latitude longitude:(double)longitude venue:(TGVenueAttachment *)venue messageGuid:(NSString *)messageGuid tmpId:(int64_t)tmpId replyMessageId:(int32_t)replyMessageId postAsChannel:(bool)postAsChannel notifyMembers:(bool)notifyMembers actor:(TGModernSendCommonMessageActor *)actor;
- (NSObject *)doConversationSendMedia:(int64_t)conversationId accessHash:(int64_t)accessHash media:(TLInputMedia *)media messageGuid:(NSString *)messageGuid tmpId:(int64_t)tmpId replyMessageId:(int32_t)replyMessageId postAsChannel:(bool)postAsChannel notifyMembers:(bool)notifyMembers actor:(TGModernSendCommonMessageActor *)actor;
- (NSObject *)doConversationBotContextResult:(int64_t)conversationId accessHash:(int64_t)accessHash botContextResult:(TGBotContextResultAttachment *)botContextResult tmpId:(int64_t)tmpId replyMessageId:(int32_t)replyMessageId postAsChannel:(bool)postAsChannel notifyMembers:(bool)notifyMembers actor:(TGModernSendCommonMessageActor *)actor;
- (NSObject *)doConversationForwardMessage:(int64_t)conversationId accessHash:(int64_t)accessHash messageId:(int)messageId fromPeer:(int64_t)fromPeer fromPeerAccessHash:(int64_t)fromPeerAccessHash postAsChannel:(bool)postAsChannel notifyMembers:(bool)notifyMembers tmpId:(int64_t)tmpId actor:(TGModernSendCommonMessageActor *)actor;
- (NSObject *)doConversationReadHistory:(int64_t)conversationId accessHash:(int64_t)accessHash maxMid:(int)maxMid offset:(int)offset actor:(TGSynchronizeActionQueueActor *)actor;
- (NSObject *)doReportDelivery:(int)maxMid actor:(TGReportDeliveryActor *)actor;
- (NSObject *)doReportConversationActivity:(int64_t)conversationId accessHash:(int64_t)accessHash activity:(id)activity actor:(TGConversationActivityRequestBuilder *)actor;
- (NSObject *)doChangeConversationTitle:(int64_t)conversationId accessHash:(int64_t)accessHash title:(NSString *)title actor:(TGConversationChangeTitleRequestActor *)actor;
- (NSObject *)doChangeConversationPhoto:(int64_t)conversationId accessHash:(int64_t)accessHash photo:(TLInputChatPhoto *)photo actor:(TGConversationChangePhotoActor *)actor;
- (NSObject *)doCreateChat:(NSArray *)uidList title:(NSString *)title actor:(TGConversationCreateChatRequestActor *)actor;
- (NSObject *)doAddConversationMember:(int64_t)conversationId uid:(int)uid actor:(TGConversationAddMemberRequestActor *)actor;
- (NSObject *)doDeleteConversationMember:(int64_t)conversationId uid:(int)uid actor:(id<TGDeleteChatMemberProtocol>)actor;
- (NSObject *)doDeleteMessages:(NSArray *)messageIds actor:(TGSynchronizeActionQueueActor *)actor;
- (NSObject *)doDeleteConversation:(int64_t)conversationId onlyClear:(bool)onlyClear maxId:(int32_t)maxId accessHash:(int64_t)accessHash offset:(int)offset actor:(TGSynchronizeActionQueueActor *)actor;

- (NSObject *)doRequestTimeline:(int)timelineId maxItemId:(int64_t)maxItemId limit:(int)limit actor:(TGTimelineHistoryRequestBuilder *)actor;
- (NSObject *)doUploadTimelinePhoto:(id)inputFile hasLocation:(bool)hasLocation latitude:(double)latitude longitude:(double)longitude actor:(TGTimelineUploadPhotoRequestBuilder *)actor;
- (NSObject *)doDeleteProfilePhotos:(NSArray *)items actor:(TGSynchronizeServiceActionsActor *)actor;
- (NSObject *)doAssignProfilePhoto:(int64_t)itemId accessHash:(int64_t)accessHash actor:(TGTimelineAssignProfilePhotoActor *)actor;

- (NSObject *)doSaveGeocodingResult:(double)latitude longitude:(double)longitude components:(NSDictionary *)components actor:(TGSaveGeocodingResultActor *)actor;

- (NSObject *)doRequestPeerNotificationSettings:(int64_t)peerId accessHash:(int64_t)accessHash actor:(id<TGPeerSettingsActorProtocol>)actor;
- (NSObject *)doChangePeerNotificationSettings:(int64_t)peerId accessHash:(int64_t)accessHash muteUntil:(int)muteUntil soundId:(int)soundId previewText:(bool)previewText messagesMuted:(bool)messagesMuted actor:(TGSynchronizeServiceActionsActor *)actor;
- (NSObject *)doResetPeerNotificationSettings:(TGSynchronizeServiceActionsActor *)actor;
- (NSObject *)doRequestConversationData:(int64_t)conversationId actor:(TGExtendedChatDataRequestActor *)actor;

- (id)doRequestPeerProfilePhotoList:(int64_t)peerId actor:(TGProfilePhotoListActor *)actor;

- (NSObject *)doRequestBlockList:(TGBlockListRequestActor *)actor;
- (NSObject *)doChangePeerBlockStatus:(int64_t)peerId block:(bool)block actor:(TGSynchronizeServiceActionsActor *)actor;
- (NSObject *)doChangeName:(NSString *)firstName lastName:(NSString *)lastName actor:(TGChangeNameActor *)actor;

- (id)doRequestWallpaperList:(TGWallpaperListRequestActor *)actor;

- (id)doRequestEncryptionConfig:(TGRequestEncryptedChatActor *)actor version:(int)version;
- (id)doRequestEncryptedChat:(int)uid randomId:(int64_t)randomId gABytes:(NSData *)gABytes actor:(TGRequestEncryptedChatActor *)actor;
- (id)doAcceptEncryptedChat:(int64_t)encryptedChatId accessHash:(int64_t)accessHash gBBytes:(NSData *)gBBytes keyFingerprint:(int64_t)keyFingerprint actor:(TGEncryptedChatResponseActor *)actor;
- (id)doRejectEncryptedChat:(int64_t)encryptedConversationId actor:(TGSynchronizeActionQueueActor *)actor;
- (id)doReportEncryptedConversationTypingActivity:(int64_t)encryptedConversationId accessHash:(int64_t)accessHash actor:(TGConversationActivityRequestBuilder *)actor;
- (id)doSendEncryptedMessage:(int64_t)encryptedChatId accessHash:(int64_t)accessHash randomId:(int64_t)randomId data:(NSData *)data encryptedFile:(TLInputEncryptedFile *)encryptedFile actor:(TGModernSendSecretMessageActor *)actor;
- (id)doSendEncryptedServiceMessage:(int64_t)encryptedChatId accessHash:(int64_t)accessHash randomId:(int64_t)randomId data:(NSData *)data actor:(TGSynchronizeServiceActionsActor *)actor;
- (id)doReadEncrytedHistory:(int64_t)encryptedConversationId accessHash:(int64_t)accessHash maxDate:(int32_t)maxDate actor:(TGSynchronizeActionQueueActor *)actor;
- (id)doReportQtsReceived:(int32_t)qts actor:(TGReportDeliveryActor *)actor;

- (id)doRequestInviteText:(TGUpdateConfigActor *)actor;
- (id)doDownloadMessages:(NSArray *)mids peerId:(int64_t)peerId accessHash:(int64_t)accessHash actor:(TGDownloadMessagesActor *)actor;

- (id)doRequestPrefferredSuportPeer:(void (^)(TLhelp_Support *supportDesc))completion fail:(void (^)())fail;

- (id)doChangePasslockSettings:(bool)passlockEnabled completion:(void (^)(bool))completion;

- (TLInputPeer *)createInputPeerForConversation:(int64_t)conversationId accessHash:(int64_t)accessHash;
- (TLInputUser *)createInputUserForUid:(int)uid;

- (NSString *)currentDeviceModel;
- (NSString *)langCode;

@end
