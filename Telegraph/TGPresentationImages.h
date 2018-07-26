#import <Foundation/Foundation.h>

#define IMAGE @property (nonatomic, readonly) UIImage *

@class TGPresentationPallete;

@interface TGPresentationImages : NSObject

+ (instancetype)imagesWithPallete:(TGPresentationPallete *)pallete;

IMAGE tabBarContactsIcon;
IMAGE tabBarCallsIcon;
IMAGE tabBarChatsIcon;
IMAGE tabBarChatsUpIcon;
IMAGE tabBarChatsDownIcon;
IMAGE tabBarSettingsIcon;
IMAGE tabBarBadgeImage;

IMAGE contactsInviteIcon;
IMAGE contactsShareIcon;
IMAGE contactsNewGroupIcon;
IMAGE contactsNewEncryptedIcon;
IMAGE contactsNewChannelIcon;
IMAGE contactsUpgradeIcon;
IMAGE contactsInviteLinkIcon;

IMAGE searchClearIcon;

IMAGE dialogMutedIcon;
IMAGE dialogVerifiedIcon;
IMAGE dialogEncryptedIcon;
IMAGE dialogDeliveredIcon;
IMAGE dialogReadIcon;
IMAGE dialogPendingIcon;
IMAGE dialogUnsentIcon;
IMAGE dialogPinnedIcon;
IMAGE dialogMentionedIcon;
IMAGE dialogBadgeImage;
IMAGE dialogMutedBadgeImage;

IMAGE dialogRecentBadgeImage;

IMAGE dialogEditingDeleteImage;
IMAGE dialogEditingReorderImage;

IMAGE dialogEditDeleteIcon;
IMAGE dialogEditMuteIcon;
IMAGE dialogEditUnmuteIcon;
IMAGE dialogEditPinIcon;
IMAGE dialogEditUnpinIcon;
IMAGE dialogEditGroupIcon;
IMAGE dialogEditUngroupIcon;

IMAGE dialogLockBaseIcon;
IMAGE dialogLockBaseActiveIcon;
IMAGE dialogLockTopIcon;
IMAGE dialogLockTopActiveIcon;

IMAGE dialogProxyShieldIcon;
IMAGE dialogProxyConnectIcon;
IMAGE dialogProxyConnectedIcon;
IMAGE dialogProxySpinner;

IMAGE callsNewIcon;
IMAGE callsInfoIcon;
IMAGE callsOutgoingIcon;

IMAGE chatNavBadgeImage;

IMAGE chatTitleMutedIcon;
IMAGE chatTitleEncryptedIcon;

IMAGE chatLiveLocationIcon;
IMAGE chatLiveLocationActiveIcon;

IMAGE chatTitleMuteIcon;
IMAGE chatTitleUnmuteIcon;
IMAGE chatTitleSearchIcon;
IMAGE chatTitleReportIcon;
IMAGE chatTitleInfoIcon;
IMAGE chatTitleCallIcon;
IMAGE chatTitleGroupIcon;

IMAGE chatSearchNextIcon;
IMAGE chatSearchNextDisabledIcon;
IMAGE chatSearchPreviousIcon;
IMAGE chatSearchPreviousDisabledIcon;
IMAGE chatSearchCalendarIcon;
IMAGE chatSearchNameIcon;

IMAGE chatMentionsImage;
IMAGE chatDownImage;
IMAGE chatBadgeImage;

IMAGE chatBubbleIncomingFullImage;
IMAGE chatBubbleIncomingFullHighlightedImage;
IMAGE chatBubbleIncomingPartialImage;
IMAGE chatBubbleIncomingPartialHighlightedImage;

IMAGE chatBubbleOutgoingFullImage;
IMAGE chatBubbleOutgoingFullHighlightedImage;
IMAGE chatBubbleOutgoingPartialImage;
IMAGE chatBubbleOutgoingPartialHighlightedImage;

IMAGE chatPlaceholderBackground;
IMAGE chatUnreadBackground;
IMAGE chatSystemBackground;
IMAGE chatReplyBackground;

IMAGE chatActionShareImage;
IMAGE chatActionReplyImage;
IMAGE chatActionGoToImage;

IMAGE chatReplyButtonBackgroundImage;
IMAGE chatReplyButtonHighlightedBackgroundImage;

IMAGE chatReplyButtonUrlIcon;
IMAGE chatReplyButtonPhoneIcon;
IMAGE chatReplyButtonLocationIcon;
IMAGE chatReplyButtonSwitchInlineIcon;
IMAGE chatReplyButtonActionIcon;

IMAGE chatRoundMessageBackgroundImage;

IMAGE chatClockFrameIconIncoming;
IMAGE chatClockFrameIconOutgoing;
IMAGE chatClockFrameIconMedia;

IMAGE chatClockHourIconIncoming;
IMAGE chatClockHourIconOutgoing;
IMAGE chatClockHourIconMedia;

IMAGE chatClockMinuteIconIncoming;
IMAGE chatClockMinuteIconOutgoing;
IMAGE chatClockMinuteIconMedia;

IMAGE chatUnsentIcon;
IMAGE chatDeliveredIcon;
IMAGE chatDeliveredIconMedia;
IMAGE chatDeliveredIconSticker;
IMAGE chatReadIcon;
IMAGE chatReadIconMedia;
IMAGE chatReadIconSticker;

IMAGE chatIncomingMessageViewsIcon;
IMAGE chatOutgoingMessageViewsIcon;
IMAGE chatMediaMessageViewsIcon;
IMAGE chatStickerMessageViewsIcon;

IMAGE chatInputFieldImage;
IMAGE chatInputAttachIcon;
IMAGE chatInputAttachEditIcon;
IMAGE chatInputSendIcon;
IMAGE chatInputConfirmIcon;
IMAGE chatInputMicrophoneIcon;
IMAGE chatInputVideoMessageIcon;
IMAGE chatInputArrowIcon;

IMAGE chatInputStickersIcon;
IMAGE chatInputKeyboardIcon;
IMAGE chatInputCommandsIcon;
IMAGE chatInputBotKeyboardIcon;
IMAGE chatInputBroadcastIcon;
IMAGE chatInputBroadcastActiveIcon;
IMAGE chatInputTimerIcon;
IMAGE chatInputClearIcon;

IMAGE chatBotResultPlaceholderImage;

IMAGE replyCloseIcon;
IMAGE pinCloseIcon;

IMAGE chatStickersGifIcon;
IMAGE chatStickersTrendingIcon;
IMAGE chatStickersRecentIcon;
IMAGE chatStickersFavoritesIcon;
IMAGE chatStickersSettingsIcon;
IMAGE chatStickersBadge;
IMAGE chatStickersGroupButton;
IMAGE chatStickersAddButton;
IMAGE chatStickersPlaceholderImage;

IMAGE chatCommandsKeyboardButtonImage;
IMAGE chatCommandsKeyboardHighlightedButtonImage;

IMAGE chatEditDeleteIcon;
IMAGE chatEditDeleteDisabledIcon;
IMAGE chatEditShareIcon;
IMAGE chatEditShareDisabledIcon;
IMAGE chatEditForwardIcon;
IMAGE chatEditForwardDisabledIcon;

IMAGE chatCallIconIncoming;
IMAGE chatCallIconOutgoing;

IMAGE profileVerifiedIcon;
IMAGE profileCallIcon;
IMAGE profilePhoneDisclosureIcon;

IMAGE fontSizeSmallIcon;
IMAGE fontSizeLargeIcon;

IMAGE brightnessMinIcon;
IMAGE brightnessMaxIcon;

IMAGE videoPlayerPlayIcon;
IMAGE videoPlayerPauseIcon;
IMAGE videoPlayerForwardIcon;
IMAGE videoPlayerBackwardIcon;
IMAGE videoPlayerPIPIcon;

IMAGE musicPlayerRate2xIcon;
IMAGE musicPlayerRate2xActiveIcon;

IMAGE sharedMediaInstantViewIcon;
IMAGE sharedMediaDownloadIcon;
IMAGE sharedMediaPauseIcon;

IMAGE shareSearchIcon;
IMAGE shareExternalIcon;
IMAGE shareSelectionImage;
IMAGE shareBadgeImage;
IMAGE shareCloseIcon;

IMAGE passportIcon;
IMAGE passportScanIcon;

IMAGE mediaBadgeImage;

IMAGE collectionMenuDisclosureIcon;
IMAGE collectionMenuCheckImage;
IMAGE collectionMenuUnimportantCheckImage;
IMAGE collectionMenuAddImage;
IMAGE collectionMenuReorderIcon;
IMAGE collectionMenuUnreadIcon;
IMAGE collectionMenuBadgeImage;
IMAGE collectionMenuClearImage;
IMAGE collectionMenuPlusImage;
IMAGE collectionMenuMinusImage;

IMAGE menuCornersImage;
IMAGE menuContrastBadgeImage;

IMAGE menuDefaultButtonImage;
IMAGE menuSendButtonImage;
IMAGE menuDestructiveButtonImage;

IMAGE segmentedControlBackgroundImage;
IMAGE segmentedControlSelectedImage;
IMAGE segmentedControlHighlightedImage;
IMAGE segmentedControlDividerImage;

IMAGE placeholderImage;

- (UIImage *)avatarPlaceholderWithDiameter:(CGFloat)diameter;
- (UIImage *)avatarPlaceholderWithDiameter:(CGFloat)diameter color:(UIColor *)color borderColor:(UIColor *)borderColor;

- (void)resetBubbleBackgrounds;

@end

#undef IMAGE
