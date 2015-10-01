/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <UIKit/UIKit.h>

#import "TGDialogListCellAssetsSource.h"

@interface TGInterfaceAssets : NSObject <TGDialogListCellAssetsSource>

+ (TGInterfaceAssets *)instance;

- (void)clearColorMapping;

+ (UIColor *)listsBackgroundColor;

- (UIColor *)blueLinenBackground;
- (UIColor *)darkLinenBackground;
- (UIColor *)linesBackground;

- (UIColor *)footerBackground;

- (UIColor *)userColor:(int)uid;
- (UIColor *)groupColor:(int64_t)groupId;
- (int)userColorIndex:(int)uid;
- (int)groupColorIndex:(int64_t)groupId;

- (UIImage *)avatarPlaceholder:(int)uid;
- (UIImage *)avatarMask;
- (UIImage *)avatarMaskUnread;
- (UIImage *)avatarMaskHighlighted;
- (UIImage *)callButton;
- (UIImage *)callButtonHighlighted;
- (UIImage *)callButtonPhone;
- (UIImage *)callButtonPhoneHighlighted;

+ (UIImage *)timelineHeaderShadow;
+ (UIImage *)settingsProfileAvatarOverlay;
- (UIImage *)dialogListAuthorAvatarStroke;
+ (UIImage *)profileAvatarOverlay;
+ (UIImage *)profileAvatarPlaceholder:(int)uid;
+ (UIImage *)profileAvatarPlaceholderGeneric;
+ (UIImage *)profileAvatarPlaceholderEmpty;
+ (UIImage *)profileGroupAvatarPlaceholder;
+ (UIImage *)actionButton;
+ (UIImage *)actionButtonHighlighted;
+ (UIImage *)timelineLocationIcon;
+ (UIImage *)timelineImagePlaceholder;
+ (NSArray *)timelineImageCorners;
+ (UIImage *)conversationTitleAvatarOverlay;
+ (UIImage *)conversationTitleAvatarOverlayLandscape;
+ (UIImage *)memberListAvatarOverlay;

+ (UIImage *)conversationAvatarPlaceholder:(int)uid;
+ (UIImage *)conversationGenericAvatarPlaceholder:(bool)useMonochrome;
+ (UIImage *)conversationAvatarOverlay;

+ (UIImage *)timelineDeletePhotoButton;
+ (UIImage *)timelineDeletePhotoButtonHighlighted;
+ (UIImage *)timelineActionPhotoButton;
+ (UIImage *)timelineActionPhotoButtonHighlighted;

+ (UIImage *)groupedCellTop;
+ (UIImage *)groupedCellTopHighlighted;
+ (UIImage *)groupedCellMiddle;
+ (UIImage *)groupedCellMiddleHighlighted;
+ (UIImage *)groupedCellBottom;
+ (UIImage *)groupedCellBottomHighlighted;
+ (UIImage *)groupedCellSingle;
+ (UIImage *)groupedCellSingleHighlighted;

+ (UIImage *)groupedCellDisclosureArrow;
+ (UIImage *)groupedCellDisclosureArrowHighlighted;

+ (UIImage *)mediaGridImagePlaceholder;

+ (UIImage *)notificationBackground;
+ (UIImage *)notificationBackgroundHighlighted;
+ (UIImage *)notificationAvatarOverlay;
+ (UIImage *)notificationAvatarPlaceholder:(int)uid;
+ (UIImage *)notificationAvatarPlaceholderGeneric;
+ (UIImage *)locationNotificationIcon;

+ (UIImage *)menuButtonBackgroundRed;
+ (UIImage *)menuButtonBackgroundRedHighlighted;

+ (UIImage *)menuButtonBackgroundGray;
+ (UIImage *)menuButtonBackgroundGrayHighlighted;

- (UIImage *)conversationUserPhotoOverlay;

@end
