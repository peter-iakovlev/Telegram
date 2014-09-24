/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <Foundation/Foundation.h>

#import "ASWatcher.h"

#import "TGMessageRange.h"

@class TGModernConversationController;
@class TGModernViewContext;
@class TGMessage;
@class TGMessageModernConversationItem;
@class TGVideoMediaAttachment;
@class TGDocumentMediaAttachment;
@class TGUser;

@class TGModernConversationEmptyListPlaceholderView;
@class TGModernViewInlineMediaContext;
@class TGLiveUploadActorData;

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

@interface TGModernConversationCompanion : NSObject <ASWatcher>
{
    NSMutableArray *_items;
}

@property (nonatomic, strong) ASHandle *actionHandle;

@property (nonatomic, weak) TGModernConversationController *controller;
@property (nonatomic, strong) TGModernViewContext *viewContext;

@property (nonatomic) int32_t mediaHiddenMessageId;

+ (void)warmupResources;

+ (bool)isMessageQueue;
+ (void)dispatchOnMessageQueue:(dispatch_block_t)block;
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
- (void)_setStatus:(NSString *)status accentColored:(bool)accentColored allowAnimation:(bool)allowAnimation;
- (void)_setTitle:(NSString *)title andStatus:(NSString *)status accentColored:(bool)accentColored allowAnimatioon:(bool)allowAnimation;
- (void)_setTypingStatus:(NSString *)typingStatus;

- (void)_controllerWillAppearAnimated:(bool)animated firstTime:(bool)firstTime;
- (void)_controllerDidAppear:(bool)firstTime;
- (void)_controllerAvatarPressed;
- (void)_dismissController;
- (void)_setControllerWidthForItemCalculation:(CGFloat)width;
- (void)_loadControllerPrimaryTitlePanel;
- (TGModernConversationEmptyListPlaceholderView *)_conversationEmptyListPlaceholder;
- (UIView *)_controllerInputTextPanelAccessoryView;
- (NSString *)_controllerInfoButtonText;
- (void)updateControllerInputText:(NSString *)inputText;
- (void)controllerDidUpdateTypingActivity;
- (void)controllerWantsToSendTextMessage:(NSString *)text;
- (void)controllerWantsToSendMapWithLatitude:(double)latitude longitude:(double)longitude;
- (NSURL *)fileUrlForDocumentMedia:(TGDocumentMediaAttachment *)documentMedia;
- (NSDictionary *)imageDescriptionFromImage:(UIImage *)image optionalAssetUrl:(NSString *)assetUrl;
- (void)controllerWantsToSendImagesWithDescriptions:(NSArray *)imageDescriptions;
- (void)controllerWantsToSendLocalVideoWithTempFilePath:(NSString *)tempVideoFilePath fileSize:(int32_t)fileSize previewImage:(UIImage *)previewImage duration:(NSTimeInterval)duration dimensions:(CGSize)dimenstions assetUrl:(NSString *)assetUrl liveUploadData:(TGLiveUploadActorData *)liveUploadData;
- (TGVideoMediaAttachment *)serverCachedAssetWithId:(NSString *)assetId;
- (void)controllerWantsToSendDocumentWithTempFileUrl:(NSURL *)tempFileUrl fileName:(NSString *)fileName mimeType:(NSString *)mimeType;
- (void)controllerWantsToSendLocalAudioWithTempFileUrl:(NSURL *)tempFileUrl duration:(NSTimeInterval)duration liveData:(TGLiveUploadActorData *)liveData;
- (void)controllerWantsToSendRemoteVideoWithMedia:(TGVideoMediaAttachment *)media;
- (void)controllerWantsToSendContact:(TGUser *)contactUser;
- (void)controllerWantsToResendMessages:(NSArray *)messageIds;
- (void)controllerWantsToForwardMessages:(NSArray *)messageIds;
- (void)controllerWantsToCreateContact:(int32_t)uid firstName:(NSString *)firstName lastName:(NSString *)lastName phoneNumber:(NSString *)phoneNumber;
- (void)controllerWantsToAddContactToExisting:(int32_t)uid phoneNumber:(NSString *)phoneNumber;
- (void)controllerWantsToApplyLocalization:(NSString *)filePath;
- (void)controllerClearedConversation;
- (void)systemClearedConversation;
- (void)controllerDeletedMessages:(NSArray *)messageIds;
- (void)controllerCanReadHistoryUpdated;
- (void)controllerRequestedNavigationToConversationWithUser:(int32_t)uid;
- (bool)controllerShouldStoreCapturedAssets;
- (bool)controllerShouldCacheServerAssets;
- (bool)controllerShouldLiveUploadVideo;
- (bool)imageDownloadsShouldAutosavePhotos;
- (bool)shouldAutomaticallyDownloadPhotos;
- (bool)allowMessageForwarding;
- (bool)allowContactSharing;
- (bool)encryptUploads;

- (void)updateControllerEmptyState;
- (void)clearCheckedMessages;
- (void)setMessageChecked:(int32_t)messageId checked:(bool)checked;
- (int)checkedMessageCount;
- (NSArray *)checkedMessageIds;
- (bool)_isMessageChecked:(int32_t)messageId;

- (void)_setMessageFlags:(int32_t)messageId flags:(int)flags;
- (bool)_isSecretMessageViewed:(int32_t)messageId;
- (bool)_isSecretMessageScreenshotted:(int32_t)messageId;

- (TGModernViewInlineMediaContext *)_inlineMediaContext:(int32_t)messageId;

- (void)_updateMessageItemsWithData:(NSArray *)items;
- (void)_updateMediaStatusDataForCurrentItems;
- (void)_updateMediaStatusDataForItemsInIndexSet:(NSIndexSet *)indexSet animated:(bool)animated;
- (void)_downloadMediaInMessage:(TGMessage *)message highPriority:(bool)highPriority;
- (void)_updateProgressForItemsInIndexSet:(NSIndexSet *)indexSet animated:(bool)animated;
- (TGMessageModernConversationItem *)_updateMediaStatusData:(TGMessageModernConversationItem *)item;
- (void)_updateImportantMediaStatusDataInplace:(TGMessageModernConversationItem *)item;

- (void)loadMoreMessagesAbove;
- (void)loadMoreMessagesBelow;
- (void)unloadMessagesAbove;
- (void)unloadMessagesBelow;

- (void)_performFastScrollDown:(bool)becauseOfSendTextAction;
- (void)_replaceMessages:(NSArray *)newMessages;
- (void)_replaceMessagesWithFastScroll:(NSArray *)newMessages intent:(TGModernConversationAddMessageIntent)intent;
- (void)_addMessages:(NSArray *)addedMessages animated:(bool)animated intent:(TGModernConversationAddMessageIntent)intent;
- (void)_deleteMessages:(NSArray *)messageIds animated:(bool)animated;
- (void)_updateMessagesRead:(NSArray *)messageIds;
- (void)_updateMessageDelivered:(int32_t)previousMid;
- (void)_updateMessageDelivered:(int32_t)previousMid mid:(int32_t)mid date:(int32_t)date message:(TGMessage *)message;
- (void)_updateMessageDeliveryFailed:(int32_t)previousMid;

@end
