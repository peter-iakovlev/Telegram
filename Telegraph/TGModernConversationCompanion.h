/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <Foundation/Foundation.h>

#import <SSignalKit/SSignalKit.h>

#import "ASWatcher.h"

#import "TGMessageRange.h"

#import "TGApplicationFeatures.h"

#import "TGVisibleMessageHole.h"

@class TGModernConversationController;
@class TGModernViewContext;
@class TGMessage;
@class TGMessageModernConversationItem;
@class TGVideoMediaAttachment;
@class TGDocumentMediaAttachment;
@class TGUser;
@class TGVenueAttachment;

@class TGModernConversationEmptyListPlaceholderView;
@class TGModernConversationInputPanel;
@class TGModernViewInlineMediaContext;
@class TGLiveUploadActorData;
@class TGDataItem;

@class TGBingSearchResultItem;
@class TGGiphySearchResultItem;
@class TGWebSearchInternalImageResult;
@class TGWebSearchInternalGifResult;

@class TGICloudItem;
@class TGDropboxItem;
@class TGGoogleDriveItem;

typedef enum {
    TGInitialScrollPositionTop = 0,
    TGInitialScrollPositionCenter = 1,
    TGInitialScrollPositionBottom = 2
} TGInitialScrollPosition;

typedef enum {
    TGModernConversationAddMessageIntentGeneric = 0,
    TGModernConversationAddMessageIntentSendTextMessage = 1,
    TGModernConversationAddMessageIntentSendOtherMessage = 2,
    TGModernConversationAddMessageIntentLoadMoreMessagesAbove = 3,
    TGModernConversationAddMessageIntentLoadMoreMessagesBelow = 4
} TGModernConversationAddMessageIntent;

typedef enum {
    TGModernConversationControllerTitleToggleNone,
    TGModernConversationControllerTitleToggleShowDiscussion,
    TGModernConversationControllerTitleToggleHideDiscussion
} TGModernConversationControllerTitleToggle;

@interface TGModernConversationCompanion : NSObject <ASWatcher>
{
    NSArray *_items;
}

@property (nonatomic, strong) ASHandle *actionHandle;

@property (nonatomic, weak) TGModernConversationController *controller;
@property (nonatomic, strong) TGModernViewContext *viewContext;

@property (nonatomic) int32_t mediaHiddenMessageId;

+ (void)warmupResources;

+ (bool)isMessageQueue;
+ (void)dispatchOnMessageQueue:(dispatch_block_t)block;
+ (SQueue *)messageQueue;
- (void)lockSendMessageSemaphore;
- (void)unlockSendMessageSemaphore;

- (void)setInitialMessagePositioning:(int32_t)initialPositionedMessageId position:(TGInitialScrollPosition)position;
- (void)setUnreadMessageRange:(TGMessageRange)unreadMessageRange;
- (TGMessageRange)unreadMessageRange;
- (int32_t)initialPositioningMessageId;
- (TGInitialScrollPosition)initialPositioningScrollPosition;
- (CGFloat)initialPositioningOverflowForScrollPosition:(TGInitialScrollPosition)scrollPosition;

- (void)bindController:(TGModernConversationController *)controller;
- (void)unbindController;
- (void)loadInitialState;
- (void)subscribeToUpdates;

- (void)_setTitle:(NSString *)title;
- (void)_setAvatarConversationId:(int64_t)conversationId title:(NSString *)title icon:(UIImage *)icon;
- (void)_setAvatarConversationId:(int64_t)conversationId firstName:(NSString *)firstName lastName:(NSString *)lastName;
- (void)_setTitleIcons:(NSArray *)titleIcons;
- (void)_setAvatarUrl:(NSString *)avatarUrl;
- (void)_setStatus:(NSString *)status accentColored:(bool)accentColored allowAnimation:(bool)allowAnimation toggleMode:(TGModernConversationControllerTitleToggle)toggleMode;
- (void)_setTitle:(NSString *)title andStatus:(NSString *)status accentColored:(bool)accentColored allowAnimatioon:(bool)allowAnimation toggleMode:(TGModernConversationControllerTitleToggle)toggleMode;
- (void)_setTypingStatus:(NSString *)typingStatus activity:(int)activity;

- (void)_controllerWillAppearAnimated:(bool)animated firstTime:(bool)firstTime;
- (void)_controllerDidAppear:(bool)firstTime;
- (void)_controllerAvatarPressed;
- (void)_dismissController;
- (void)_setControllerWidthForItemCalculation:(CGFloat)width;
- (void)_loadControllerPrimaryTitlePanel;
- (TGModernConversationEmptyListPlaceholderView *)_conversationEmptyListPlaceholder;
- (TGModernConversationInputPanel *)_conversationGenericInputPanel;
- (TGModernConversationInputPanel *)_conversationEmptyListInputPanel;
- (void)_updateInputPanel;
- (UIView *)_conversationHeader;
- (UIView *)_controllerInputTextPanelAccessoryView;
- (NSString *)_controllerInfoButtonText;
- (void)updateControllerInputText:(NSString *)inputText;
- (void)controllerDidUpdateTypingActivity;
- (void)controllerDidCancelTypingActivity;
- (void)controllerDidChangeInputText:(NSString *)inputText;
- (void)controllerWantsToSendTextMessage:(NSString *)text asReplyToMessageId:(int32_t)replyMessageId withAttachedMessages:(NSArray *)withAttachedMessages disableLinkPreviews:(bool)disableLinkPreviews;
- (void)controllerWantsToSendMapWithLatitude:(double)latitude longitude:(double)longitude venue:(TGVenueAttachment *)venue asReplyToMessageId:(int32_t)replyMessageId;
- (NSURL *)fileUrlForDocumentMedia:(TGDocumentMediaAttachment *)documentMedia;
- (NSDictionary *)imageDescriptionFromImage:(UIImage *)image caption:(NSString *)caption optionalAssetUrl:(NSString *)assetUrl;
- (NSDictionary *)imageDescriptionFromBingSearchResult:(TGBingSearchResultItem *)item caption:(NSString *)caption;
- (NSDictionary *)documentDescriptionFromGiphySearchResult:(TGGiphySearchResultItem *)item;
- (NSDictionary *)documentDescriptionFromICloudDriveItem:(TGICloudItem *)item;
- (NSDictionary *)documentDescriptionFromDropboxItem:(TGDropboxItem *)item;
- (NSDictionary *)documentDescriptionFromGoogleDriveItem:(TGGoogleDriveItem *)item;
- (NSDictionary *)imageDescriptionFromInternalSearchImageResult:(TGWebSearchInternalImageResult *)item caption:(NSString *)caption;
- (NSDictionary *)documentDescriptionFromInternalSearchResult:(TGWebSearchInternalGifResult *)item;
- (NSDictionary *)documentDescriptionFromFileAtTempUrl:(NSURL *)url fileName:(NSString *)fileName mimeType:(NSString *)mimeType;
- (void)controllerWantsToSendImagesWithDescriptions:(NSArray *)imageDescriptions asReplyToMessageId:(int32_t)replyMessageId;
- (void)controllerWantsToSendLocalVideoWithTempFilePath:(NSString *)tempVideoFilePath fileSize:(int32_t)fileSize previewImage:(UIImage *)previewImage duration:(NSTimeInterval)duration dimensions:(CGSize)dimenstions caption:(NSString *)caption assetUrl:(NSString *)assetUrl liveUploadData:(TGLiveUploadActorData *)liveUploadData asReplyToMessageId:(int32_t)replyMessageId;
- (TGVideoMediaAttachment *)serverCachedAssetWithId:(NSString *)assetId;
- (void)controllerWantsToSendDocumentWithTempFileUrl:(NSURL *)tempFileUrl fileName:(NSString *)fileName mimeType:(NSString *)mimeType asReplyToMessageId:(int32_t)replyMessageId;
- (void)controllerWantsToSendDocumentsWithDescriptions:(NSArray *)descriptions asReplyToMessageId:(int32_t)replyMessageId;
- (void)controllerWantsToSendRemoteDocument:(TGDocumentMediaAttachment *)document asReplyToMessageId:(int32_t)replyMessageId;
- (void)controllerWantsToSendCloudDocumentsWithDescriptions:(NSArray *)descriptions asReplyToMessageId:(int32_t)replyMessageId;
- (void)controllerWantsToSendLocalAudioWithDataItem:(TGDataItem *)dataItem duration:(NSTimeInterval)duration liveData:(TGLiveUploadActorData *)liveData asReplyToMessageId:(int32_t)replyMessageId;
- (void)controllerWantsToSendRemoteVideoWithMedia:(TGVideoMediaAttachment *)media asReplyToMessageId:(int32_t)replyMessageId;
- (void)controllerWantsToSendContact:(TGUser *)contactUser asReplyToMessageId:(int32_t)replyMessageId;
- (void)controllerWantsToResendMessages:(NSArray *)messageIds;
- (void)controllerWantsToForwardMessages:(NSArray *)messageIds;
- (void)controllerWantsToCreateContact:(int32_t)uid firstName:(NSString *)firstName lastName:(NSString *)lastName phoneNumber:(NSString *)phoneNumber;
- (void)controllerWantsToAddContactToExisting:(int32_t)uid phoneNumber:(NSString *)phoneNumber;
- (void)controllerWantsToApplyLocalization:(NSString *)filePath;
- (void)controllerClearedConversation;
- (void)systemClearedConversation;
- (void)controllerDeletedMessages:(NSArray *)messageIds completion:(void (^)())completion;
- (void)controllerCanReadHistoryUpdated;
- (void)controllerCanRegroupUnreadIncomingMessages;
- (void)controllerRequestedNavigationToConversationWithUser:(int32_t)uid;
- (bool)controllerShouldStoreCapturedAssets;
- (bool)controllerShouldCacheServerAssets;
- (bool)controllerShouldLiveUploadVideo;
- (bool)imageDownloadsShouldAutosavePhotos;
- (bool)shouldAutomaticallyDownloadPhotos;
- (bool)allowMessageForwarding;
- (bool)allowReplies;
- (bool)allowContactSharing;
- (bool)allowVenueSharing;
- (bool)allowCaptionedMedia;
- (bool)encryptUploads;
- (NSDictionary *)userActivityData;
- (TGApplicationFeaturePeerType)applicationFeaturePeerType;

- (void)updateControllerEmptyState;
- (void)clearCheckedMessages;
- (void)setMessageChecked:(int32_t)messageId checked:(bool)checked;
- (int)checkedMessageCount;
- (NSArray *)checkedMessageIds;
- (bool)_isMessageChecked:(int32_t)messageId;

- (void)_setMessageFlags:(int32_t)messageId flags:(int)flags;
- (void)_setMessageViewDate:(int32_t)messageId viewDate:(NSTimeInterval)viewDate;
- (void)_setMessageFlagsAndViewDate:(int32_t)messageId flags:(int)flags viewDate:(NSTimeInterval)viewDate;
- (bool)_isSecretMessageViewed:(int32_t)messageId;
- (bool)_isSecretMessageScreenshotted:(int32_t)messageId;
- (NSTimeInterval)_secretMessageViewDate:(int32_t)messageId;

- (TGModernViewInlineMediaContext *)_inlineMediaContext:(int32_t)messageId;

- (void)_updateMessageItemsWithData:(NSArray *)items;
- (void)_updateMediaStatusDataForCurrentItems;
- (void)_updateMediaStatusDataForItemsInIndexSet:(NSIndexSet *)indexSet animated:(bool)animated;
- (void)_updateMediaStatusDataForItemsWithMessageIdsInSet:(NSMutableSet *)messageIds;
- (void)_downloadMediaInMessage:(TGMessage *)message highPriority:(bool)highPriority;
- (void)_updateProgressForItemsInIndexSet:(NSIndexSet *)indexSet animated:(bool)animated;
- (TGMessageModernConversationItem *)_updateMediaStatusData:(TGMessageModernConversationItem *)item;
- (void)_updateImportantMediaStatusDataInplace:(TGMessageModernConversationItem *)item;

- (void)_itemsUpdated;

- (void)loadMoreMessagesAbove;
- (void)loadMoreMessagesBelow;
- (void)unloadMessagesAbove;
- (void)unloadMessagesBelow;

- (void)_performFastScrollDown:(bool)becauseOfSendTextAction;
- (void)_replaceMessages:(NSArray *)newMessages;
- (void)_replaceMessages:(NSArray *)newMessages atMessageId:(int32_t)atMessageId expandFrom:(int32_t)expandMessageId jump:(bool)jump;
- (void)_replaceMessagesWithFastScroll:(NSArray *)newMessages intent:(TGModernConversationAddMessageIntent)intent scrollToMessageId:(int32_t)scrollToMessageId scrollBackMessageId:(int32_t)scrollBackMessageId animated:(bool)animated;
- (void)_addMessages:(NSArray *)addedMessages animated:(bool)animated intent:(TGModernConversationAddMessageIntent)intent;
- (void)_addMessages:(NSArray *)addedMessages animated:(bool)animated intent:(TGModernConversationAddMessageIntent)intent deletedMessageIds:(NSArray *)deletedMessageIds;
- (void)_deleteMessages:(NSArray *)messageIds animated:(bool)animated;
- (void)_updateMessagesRead:(NSArray *)messageIds;
- (void)_updateMessageDelivered:(int32_t)previousMid;
- (void)_updateMessageDelivered:(int32_t)previousMid mid:(int32_t)mid date:(int32_t)date message:(TGMessage *)message unread:(NSNumber *)unread;
- (void)_updateMessageDeliveryFailed:(int32_t)previousMid;
- (void)_updateMessages:(NSDictionary *)messagesByIds;

- (void)updateMediaAccessTimeForMessageId:(int32_t)messageId;

- (id)acquireAudioRecordingActivityHolder;
- (id)acquireLocationPickingActivityHolder;

- (void)serviceNotificationsForMessageIds:(NSArray *)messageIds;
- (void)markMessagesAsViewed:(NSArray *)messageIds;

- (SSignal *)userListForMention:(NSString *)mention;
- (SSignal *)hashtagListForHashtag:(NSString *)hashtag;
- (SSignal *)commandListForCommand:(NSString *)command;

- (void)navigateToMessageId:(int32_t)messageId scrollBackMessageId:(int32_t)scrollBackMessageId animated:(bool)animated;

- (void)navigateToMessageSearch;

- (bool)isASingleBotGroup;

- (void)_controllerDidUpdateVisibleHoles:(NSArray *)holes;
- (void)_controllerDidUpdateVisibleUnseenMessageIds:(NSArray *)unseenMessageIds;
- (bool)_controllerShouldHideInputTextByDefault;
- (bool)canDeleteMessage:(TGMessage *)message;
- (bool)canDeleteMessages;
- (bool)canDeleteAllMessages;

- (int64_t)requestPeerId;
- (int64_t)requestAccessHash;

- (void)_toggleBroadcastMode;

- (void)updateMessageViews:(NSDictionary *)messageIdToViews markAsSeen:(bool)markAsSeen;
- (void)_toggleTitleMode;

@end
