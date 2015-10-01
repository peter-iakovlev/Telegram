/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <UIKit/UIKit.h>

@protocol TGDialogListCellAssetsSource <NSObject>

- (UIColor *)dialogListBackgroundColor;
- (UIColor *)dialogListTableBackgroundColor;
- (UIColor *)dialogListHeaderColor;
- (bool)dialogListSearchStripeHidden;
- (UIImage *)dialogListSearchIcon;
- (UIImage *)dialogListSearchCancelButton;
- (UIImage *)dialogListSearchCancelButtonHighlighted;

- (UIImage *)dialogListGroupChatIcon;
- (UIImage *)dialogListGroupChatIconHighlighted;

- (UIImage *)dialogListUnreadCountBadge;
- (UIImage *)dialogListUnreadCountBadgeHighlighted;

- (UIImage *)dialogListDeliveryErrorBadge;
- (UIImage *)dialogListDeliveryErrorBadgeHighlighted;

- (UIImage *)avatarPlaceholder:(int)uid;
- (UIImage *)avatarPlaceholderGeneric;
- (UIImage *)authorAvatarPlaceholder;
- (UIImage *)groupAvatarPlaceholder:(int64_t)conversationId;
- (UIImage *)groupAvatarPlaceholderGeneric;
- (UIImage *)smallAvatarPlaceholder:(int)uid;
- (UIImage *)smallAvatarPlaceholderGeneric;
- (UIImage *)smallGroupAvatarPlaceholder:(int64_t)conversationId;
- (UIImage *)smallGroupAvatarPlaceholderGeneric;

@end
