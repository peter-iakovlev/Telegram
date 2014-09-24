/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGViewController.h"

#import "ASWatcher.h"

#import "TGModernConversationInputPanel.h"
#import "TGModernConversationEmptyListPlaceholderView.h"

@class TGModernConversationCompanion;
@class TGModernViewStorage;
@class TGModernConversationItem;
@class TGUser;

@class TGModernConversationTitlePanel;

@class TGModernViewInlineMediaContext;

extern NSInteger TGModernConversationControllerUnloadHistoryLimit;
extern NSInteger TGModernConversationControllerUnloadHistoryThreshold;

typedef enum {
    TGModernConversationInsertItemIntentGeneric = 0,
    TGModernConversationInsertItemIntentSendTextMessage = 1,
    TGModernConversationInsertItemIntentSendOtherMessage = 2,
    TGModernConversationInsertItemIntentLoadMoreMessagesAbove = 3,
    TGModernConversationInsertItemIntentLoadMoreMessagesBelow = 4
} TGModernConversationInsertItemIntent;

@interface TGModernConversationController : TGViewController <ASWatcher, TGModernConversationInputPanelDelegate, TGModernConversationEmptyListPlaceholderViewDelegate>

@property (nonatomic, strong) ASHandle *actionHandle;

@property (nonatomic, strong) TGModernConversationCompanion *companion;
@property (nonatomic) bool shouldIgnoreAppearAnimationOnce;

- (void)setInitialSnapshot:(CGImageRef)image backgroundView:(UIView *)backgroundView viewStorage:(TGModernViewStorage *)viewStorage;
- (void)replaceItems:(NSArray *)newItems;
- (void)replaceItemsWithFastScroll:(NSArray *)newItems intent:(TGModernConversationInsertItemIntent)intent;
- (void)replaceItems:(NSArray *)items atIndices:(NSIndexSet *)indices;
- (void)insertItems:(NSArray *)insertItems atIndices:(NSIndexSet *)indices animated:(bool)animated intent:(TGModernConversationInsertItemIntent)intent;
- (void)deleteItemsAtIndices:(NSIndexSet *)indices animated:(bool)animated;
- (void)moveItems:(NSArray *)moveIndexPairs;
- (void)updateItemAtIndex:(NSUInteger)index toItem:(TGModernConversationItem *)updatedItem;
- (void)updateItemProgressAtIndex:(NSUInteger)index toProgress:(float)progress animated:(bool)animated;
- (void)imageDataInvalidated:(NSString *)imageUrl;
- (void)updateCheckedMessages;
- (void)updateMessageAttributes:(int32_t)messageId;
- (void)setHasUnseenMessagesBelow:(bool)hasUnseenMessagesBelow;

- (void)openMediaFromMessage:(int32_t)messageId instant:(bool)instant;
- (void)closeMediaFromMessage:(int32_t)messageId instant:(bool)instant;
- (void)pauseMediaFromMessage:(int32_t)messageId;
- (void)stopInlineMedia;
- (void)openBrowserFromMessage:(int32_t)messageId url:(NSString *)url;
- (void)showActionsMenuForUnsentMessage:(int32_t)messageId;
- (void)highlightAndShowActionsMenuForMessage:(int32_t)messageId;
- (void)showActionsMenuForLink:(NSString *)url;
- (void)showActionsMenuForContact:(TGUser *)contact isContact:(bool)isContact;
- (void)showAddContactMenu:(TGUser *)contact;
- (void)showCallNumberMenu:(NSArray *)phoneNumbers;
- (void)enterEditingMode;
- (void)leaveEditingMode;

- (void)reloadBackground;
- (void)refreshMetrics;
- (void)setInputText:(NSString *)inputText replace:(bool)replace;
- (void)setTitle:(NSString *)title;
- (void)setAvatarConversationId:(int64_t)conversationId title:(NSString *)title icon:(UIImage *)icon;
- (void)setAvatarConversationId:(int64_t)conversationId firstName:(NSString *)firstName lastName:(NSString *)lastName;
- (void)setTitleIcons:(NSArray *)titleIcons;
- (void)setTitleModalProgressStatus:(NSString *)titleModalProgressStatus;
- (void)setAvatarUrl:(NSString *)avatarUrl;
- (void)setStatus:(NSString *)status accentColored:(bool)accentColored allowAnimation:(bool)allowAnimation;
- (void)setAttributedStatus:(NSAttributedString *)status allowAnimation:(bool)allowAnimation;
- (void)setTypingStatus:(NSString *)typingStatus;
- (void)setGlobalUnreadCount:(int)unreadCount;
- (void)setCustomInputPanel:(TGModernConversationInputPanel *)customInputPanel;
- (void)setPrimaryTitlePanel:(TGModernConversationTitlePanel *)titlePanel;
- (TGModernConversationTitlePanel *)primaryTitlePanel;
- (void)setSecondaryTitlePanel:(TGModernConversationTitlePanel *)secondaryTitlePanel;
- (TGModernConversationTitlePanel *)secondaryTitlePanel;
- (void)setEmptyListPlaceholder:(TGModernConversationEmptyListPlaceholderView *)emptyListPlaceholder;

- (void)setEnableAboveHistoryRequests:(bool)enableAboveHistoryRequests;
- (void)setEnableBelowHistoryRequests:(bool)enableBelowHistoryRequests;
- (void)setEnableUnloadHistoryRequests:(bool)enableUnloadHistoryRequests;
- (void)setEnableSendButton:(bool)enableSendButton;

- (bool)canReadHistory;

- (TGModernViewInlineMediaContext *)inlineMediaContext:(int32_t)messageId;

@end
