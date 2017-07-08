/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <UIKit/UIKit.h>

#import <CoreText/CoreText.h>

@protocol TGConversationMessageAssetsSource <NSObject>

@required

- (int)currentUserId;

- (CTFontRef)messageTextFont;
- (CTFontRef)messageActionTitleFont;
- (CTFontRef)messageActionTitleBoldFont;
- (CTFontRef)messageMediaLabelsFont;
- (CTFontRef)messageRequestActionFont;
- (CTFontRef)messagerequestActorBoldFont;
- (CTFontRef)messageForwardTitleFont;
- (CTFontRef)messageForwardNameFont;
- (CTFontRef)messageForwardPhoneNameFont;
- (CTFontRef)messageForwardPhoneFont;

- (UIFont *)messageLineAttachmentTitleFont;
- (UIFont *)messageLineAttachmentSubtitleFont;
- (UIFont *)messageDocumentLabelFont;
- (UIFont *)messageForwardedUserFont;
- (UIFont *)messageForwardedDateFont;
- (UIColor *)messageTextColor;
- (UIColor *)messageTextShadowColor;
- (UIColor *)messageLineAttachmentTitleColor;
- (UIColor *)messageLineAttachmentSubitleColor;
- (UIColor *)messageDocumentLabelColor;
- (UIColor *)messageDocumentLabelShadowColor;
- (UIColor *)messageForwardedUserColor;
- (UIColor *)messageForwardedDateColor;

- (UIColor *)messageForwardTitleColorIncoming;
- (UIColor *)messageForwardTitleColorOutgoing;
- (UIColor *)messageForwardNameColorIncoming;
- (UIColor *)messageForwardNameColorOutgoing;
- (UIColor *)messageForwardPhoneColor;
- (UIImage *)messageInlineGenericAvatarPlaceholder;
- (UIImage *)messageInlineAvatarPlaceholder:(int)uid;

- (UIColor *)messageActionTextColor;
- (UIColor *)messageActionShadowColor;

- (UIImage *)messageVideoIcon;

- (CTFontRef)messageAuthorNameFont;
- (UIFont *)messageAuthorNameUIFont;
- (UIColor *)messageAuthorNameColor;
- (UIColor *)messageAuthorNameShadowColor;

- (UIImage *)messageChecked;
- (UIImage *)messageUnchecked;
- (UIImage *)messageEditingSeparator;

- (UIImage *)messageProgressBackground;
- (UIImage *)messageProgressForeground;
- (UIImage *)messageProgressCancelButton;
- (UIImage *)messageProgressCancelButtonHighlighted;
- (UIImage *)messageDownloadButton;
- (UIImage *)messageDownloadButtonHighlighted;

- (UIImage *)messageBackgroundBubbleIncomingSingle;
- (UIImage *)messageBackgroundBubbleIncomingDouble;
- (UIImage *)messageBackgroundBubbleIncomingHighlighted;
- (UIImage *)messageBackgroundBubbleIncomingHighlightedShadow;
- (UIImage *)messageBackgroundBubbleIncomingDoubleHighlighted;
- (UIImage *)messageBackgroundBubbleOutgoingSingle;
- (UIImage *)messageBackgroundBubbleOutgoingDouble;
- (UIImage *)messageBackgroundBubbleOutgoingHighlighted;
- (UIImage *)messageBackgroundBubbleOutgoingHighlightedShadow;
- (UIImage *)messageBackgroundBubbleOutgoingDoubleHighlighted;

- (UIImage *)messageDateBadgeOutgoing;
- (UIImage *)messageDateBadgeIncoming;

- (UIImage *)messageDocumentLabelBackground;
- (UIImage *)messageForwardedStripe;

- (UIImage *)messageCheckmarkFullIcon;
- (UIImage *)messageCheckmarkHalfIcon;

- (UIImage *)messageNotSentIcon;

- (UIColor *)messageBackgroundColorNormal;
- (UIColor *)messageBackgroundColorUnread;

- (UIFont *)messageDateFont;
- (UIFont *)messageDateAMPMFont;
- (UIColor *)messageDateColor;
- (UIColor *)messageDateShadowColor;

- (UIImage *)messageLinkFull;
- (UIImage *)messageLinkCornerTB;
- (UIImage *)messageLinkCornerBT;
- (UIImage *)messageLinkCornerLR;
- (UIImage *)messageLinkCornerRL;

- (UIImage *)messageAvatarPlaceholder:(int)uid;
- (UIImage *)messageGenericAvatarPlaceholder;

- (UIImage *)messageAttachmentImagePlaceholderIncoming;
- (UIImage *)messageAttachmentImagePlaceholderOutgoing;
- (UIImage *)messageAttachmentImageIncomingTopCorners;
- (UIImage *)messageAttachmentImageIncomingTopCornersHighlighted;
- (UIImage *)messageAttachmentImageIncomingBottomCorners;
- (UIImage *)messageAttachmentImageIncomingBottomCornersHighlighted;
- (UIImage *)messageAttachmentImageOutgoingTopCorners;
- (UIImage *)messageAttachmentImageOutgoingTopCornersHighlighted;
- (UIImage *)messageAttachmentImageOutgoingBottomCorners;
- (UIImage *)messageAttachmentImageOutgoingBottomCornersHighlighted;
- (UIImage *)messageAttachmentImageLoadingIcon;

- (UIImage *)messageActionConversationPhotoPlaceholder;

- (UIImage *)systemMessageBackground;
- (UIImage *)systemReplyBackground;
- (UIColor *)systemMessageBackgroundColor;
- (UIImage *)dateListMessageBackground;
- (UIImage *)systemShareButton;
- (UIImage *)systemSwipeReplyIcon;
- (UIImage *)systemReplyButton;
- (UIImage *)systemReplyHighlightedButton;

- (UIImage *)systemUnmuteButton;
- (UIImage *)systemMuteButton;

- (UIEdgeInsets)messageBodyMargins;
- (CGSize)messageMinimalBodySize;
- (UIEdgeInsets)messageBodyPaddingsIncoming;
- (UIEdgeInsets)messageBodyPaddingsOutgoing;

- (UIImage *)membersListAddImage;
- (UIImage *)membersListAddImageHighlighted;
- (UIImage *)membersListEditTitleBackground;
- (UIImage *)membersListAvatarPlaceholder;

- (UIImage *)conversationUserPhotoPlaceholder;

@end
