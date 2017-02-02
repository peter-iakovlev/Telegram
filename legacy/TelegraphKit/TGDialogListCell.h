/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <UIKit/UIKit.h>

#import "TGDialogListCellAssetsSource.h"

#import "ASWatcher.h"

#import "TGMessage.h"

@class TGDatabaseMessageDraft;

@interface TGDialogListCell : UITableViewCell

@property (nonatomic, strong) id<TGDialogListCellAssetsSource> assetsSource;

@property (nonatomic, copy) void (^deleteConversation)(int64_t);
@property (nonatomic, copy) void (^toggleMuteConversation)(int64_t, bool);
@property (nonatomic, copy) void (^togglePinConversation)(int64_t, bool);

@property (nonatomic, strong) ASHandle *watcherHandle;

@property (nonatomic) intptr_t reuseTag;
@property (nonatomic) int64_t conversationId;

@property (nonatomic, strong) NSString *titleText;
@property (nonatomic, strong) NSString *messageText;
@property (nonatomic) bool rawText;
@property (nonatomic, strong) NSArray *messageAttachments;
@property (nonatomic, strong) NSDictionary *users;

@property (nonatomic, strong) NSArray *titleLetters;
@property (nonatomic, strong) UIColor *titleColor;

@property (nonatomic) NSTimeInterval date;
@property (nonatomic) bool outgoing;
@property (nonatomic) bool unread;
@property (nonatomic) bool pinnedToTop;
@property (nonatomic) TGMessageDeliveryState deliveryState;
@property (nonatomic) int unreadCount;
@property (nonatomic) int serviceUnreadCount;

@property (nonatomic, strong) NSString *avatarUrl;
@property (nonatomic) bool isOnline;

@property (nonatomic) bool isMuted;

@property (nonatomic) bool isGroupChat;
@property (nonatomic) int groupChatAvatarCount;
@property (nonatomic, strong) NSArray *groupChatAvatarUrls;

@property (nonatomic) bool isEncrypted;
@property (nonatomic) int encryptionStatus;
@property (nonatomic) int encryptedUserId;
@property (nonatomic) bool encryptionOutgoing;
@property (nonatomic) NSString *encryptionFirstName;

@property (nonatomic) NSString *authorName;
@property (nonatomic) bool authorIsSelf;

@property (nonatomic) NSString *typingString;

@property (nonatomic) bool enableEditing;

@property (nonatomic) bool isBroadcast;
@property (nonatomic) bool isChannel;
@property (nonatomic) bool isChannelGroup;

@property (nonatomic) bool isVerified;

@property (nonatomic) bool isLastCell;
@property (nonatomic) bool disableActions;

@property (nonatomic, strong) TGDatabaseMessageDraft *draft;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier assetsSource:(id<TGDialogListCellAssetsSource>)assetsSource;

- (void)collectCachedPhotos:(NSMutableDictionary *)dict;

- (void)setTypingString:(NSString *)typingString animated:(bool)animated;
- (void)restartAnimations:(bool)force;
- (void)stopAnimations;

- (void)resetView:(bool)keepState;

- (void)dismissEditingControls:(bool)animated;

- (bool)showingDeleteConfirmationButton;

- (bool)isEditingControlsExpanded;
- (void)setEditingConrolsExpanded:(bool)expanded animated:(bool)animated;

- (void)resetLocalization;

- (UIView *)avatarSnapshotView;
- (CGRect)avatarFrame;
- (CGRect)textContentFrame;

@end
