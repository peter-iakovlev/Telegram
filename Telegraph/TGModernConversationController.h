/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGViewController.h"

#import "ASWatcher.h"

#import "TGMessageRange.h"

#import "TGModernConversationInputPanel.h"
#import "TGModernConversationEmptyListPlaceholderView.h"
#import "TGModernConversationCompanion.h"

@class TGModernConversationCompanion;
@class TGModernViewStorage;
@class TGModernConversationItem;
@class TGUser;
@class TGMessage;
@class TGModernTemporaryView;

@class TGModernConversationTitlePanel;

@class TGModernViewInlineMediaContext;

@class TGBotReplyMarkup;

@class TGWebPageMediaAttachment;

extern NSInteger TGModernConversationControllerUnloadHistoryLimit;
extern NSInteger TGModernConversationControllerUnloadHistoryThreshold;

typedef enum {
    TGModernConversationInsertItemIntentGeneric = 0,
    TGModernConversationInsertItemIntentSendTextMessage = 1,
    TGModernConversationInsertItemIntentSendOtherMessage = 2,
    TGModernConversationInsertItemIntentLoadMoreMessagesAbove = 3,
    TGModernConversationInsertItemIntentLoadMoreMessagesBelow = 4
} TGModernConversationInsertItemIntent;

@interface TGModernConversationController : TGViewController <ASWatcher, TGModernConversationInputPanelDelegate>

@property (nonatomic, strong) ASHandle *actionHandle;

@property (nonatomic, strong) TGModernConversationCompanion *companion;
@property (nonatomic) bool shouldIgnoreAppearAnimationOnce;
@property (nonatomic) bool shouldOpenKeyboardOnce;

- (void)setInitialSnapshot:(CGImageRef)image backgroundView:(TGModernTemporaryView *)backgroundView viewStorage:(TGModernViewStorage *)viewStorage topEdge:(CGFloat)topEdge;
- (TGMessage *)latestVisibleMessage;
- (NSArray *)visibleMessageIds;
- (NSArray *)_currentItems;
- (void)replaceItems:(NSArray *)newItems;
- (void)replaceItems:(NSArray *)newItems positionAtMessageId:(int32_t)positionAtMessageId expandAt:(int32_t)expandMessageId jump:(bool)jump;
- (void)replaceItemsWithFastScroll:(NSArray *)newItems intent:(TGModernConversationInsertItemIntent)intent scrollToMessageId:(int32_t)scrollToMessageId scrollBackMessageId:(int32_t)scrollBackMessageId animated:(bool)animated;
- (void)replaceItems:(NSArray *)items atIndices:(NSIndexSet *)indices;
- (void)insertItems:(NSArray *)insertItems atIndices:(NSIndexSet *)indices animated:(bool)animated intent:(TGModernConversationInsertItemIntent)intent;
- (void)insertItems:(NSArray *)itemsArray atIndices:(NSIndexSet *)indexSet animated:(bool)animated intent:(TGModernConversationInsertItemIntent)intent removeAtIndices:(NSIndexSet *)removeIndexSet;
- (void)deleteItemsAtIndices:(NSIndexSet *)indices animated:(bool)animated;
- (void)_deleteItemsAtIndices:(NSIndexSet *)indices animated:(bool)animated animationFactor:(CGFloat)animationFactor;
- (void)moveItems:(NSArray *)moveIndexPairs;
- (void)updateItemAtIndex:(NSUInteger)index toItem:(TGModernConversationItem *)updatedItem;
- (void)updateItemProgressAtIndex:(NSUInteger)index toProgress:(CGFloat)progress animated:(bool)animated;
- (void)imageDataInvalidated:(NSString *)imageUrl;
- (void)updateCheckedMessages;
- (void)updateMessageAttributes:(int32_t)messageId;
- (void)setHasUnseenMessagesBelow:(bool)hasUnseenMessagesBelow;
- (void)setUnreadMessageRangeIfAppropriate:(TGMessageRange)unreadMessageRange;

- (void)scrollToMessage:(int32_t)messageId sourceMessageId:(int32_t)sourceMessageId animated:(bool)animated;
- (void)openMediaFromMessage:(int32_t)messageId instant:(bool)instant;
- (void)closeMediaFromMessage:(int32_t)messageId instant:(bool)instant;
- (void)stopInlineMedia;
- (void)openBrowserFromMessage:(int32_t)messageId url:(NSString *)url;
- (void)showActionsMenuForUnsentMessage:(int32_t)messageId;
- (void)highlightAndShowActionsMenuForMessage:(int32_t)messageId;
- (void)temporaryHighlightMessage:(int32_t)messageId automatically:(bool)automatically;
- (void)showActionsMenuForLink:(NSString *)url;
- (void)showActionsMenuForContact:(TGUser *)contact isContact:(bool)isContact;
- (void)showAddContactMenu:(TGUser *)contact;
- (void)showCallNumberMenu:(NSArray *)phoneNumbers;
- (void)enterEditingMode;
- (void)leaveEditingMode;
- (void)openKeyboard;
- (void)hideTitlePanel;

- (void)reloadBackground;
- (void)refreshMetrics;
- (void)setInputText:(NSString *)inputText replace:(bool)replace;
- (NSString *)inputText;
- (void)setReplyMessage:(TGMessage *)replyMessage animated:(bool)animated;
- (void)setForwardMessages:(NSArray *)forwardMessages animated:(bool)animated;
- (void)setInlineStickerList:(NSArray *)inlineStickerList;
- (void)setTitle:(NSString *)title;
- (void)setAvatarConversationId:(int64_t)conversationId title:(NSString *)title icon:(UIImage *)icon;
- (void)setAvatarConversationId:(int64_t)conversationId firstName:(NSString *)firstName lastName:(NSString *)lastName;
- (void)setTitleIcons:(NSArray *)titleIcons;
- (void)setTitleModalProgressStatus:(NSString *)titleModalProgressStatus;
- (void)setAvatarUrl:(NSString *)avatarUrl;
- (void)setStatus:(NSString *)status accentColored:(bool)accentColored allowAnimation:(bool)allowAnimation toggleMode:(TGModernConversationControllerTitleToggle)toggleMode;
- (void)setAttributedStatus:(NSAttributedString *)status allowAnimation:(bool)allowAnimation;
- (void)setTypingStatus:(NSString *)typingStatus activity:(int)activity;
- (void)setGlobalUnreadCount:(int)unreadCount;
- (void)setCustomInputPanel:(TGModernConversationInputPanel *)customInputPanel;
- (TGModernConversationInputPanel *)customInputPanel;
- (void)setPrimaryTitlePanel:(TGModernConversationTitlePanel *)titlePanel;
- (TGModernConversationTitlePanel *)primaryTitlePanel;
- (void)setSecondaryTitlePanel:(TGModernConversationTitlePanel *)secondaryTitlePanel;
- (void)setSecondaryTitlePanel:(TGModernConversationTitlePanel *)secondaryTitlePanel animated:(bool)animated;
- (TGModernConversationTitlePanel *)secondaryTitlePanel;
- (void)setEmptyListPlaceholder:(TGModernConversationEmptyListPlaceholderView *)emptyListPlaceholder;
- (void)setConversationHeader:(UIView *)conversationHeader;

- (void)setEnableAboveHistoryRequests:(bool)enableAboveHistoryRequests;
- (void)setEnableBelowHistoryRequests:(bool)enableBelowHistoryRequests;
- (void)setEnableUnloadHistoryRequests:(bool)enableUnloadHistoryRequests;
- (void)setEnableSendButton:(bool)enableSendButton;

- (bool)canReadHistory;

- (TGModernViewInlineMediaContext *)inlineMediaContext:(int32_t)messageId;

- (NSArray *)_items;
- (int32_t)_currentReplyMessageId;
- (NSArray *)_currentForwardMessageDescs;

- (void)setReplyMarkup:(TGBotReplyMarkup *)replyMarkup;
- (void)appendCommand:(NSString *)command;
- (void)setHasBots:(bool)hasBots;
- (void)setCanBroadcast:(bool)canBroadcast;
- (void)setIsBroadcasting:(bool)isBroadcasting;
- (void)setIsAlwaysBroadcasting:(bool)isBroadcasting;
- (void)setInputDisabled:(bool)inputDisabled;
- (void)setIsChannel:(bool)isChannel;
- (void)updateControllerShouldHideInputTextByDefault;

- (void)openEmbed:(TGWebPageMediaAttachment *)webPage;

- (void)hideKeyboard;

- (void)activateSearch;

@end
