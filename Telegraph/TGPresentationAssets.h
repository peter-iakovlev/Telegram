#import <Foundation/Foundation.h>

@interface TGPresentationAssets : NSObject

// Tabs
+ (UIImage *)tabBarContactsIcon:(UIColor *)color;
+ (UIImage *)tabBarCallsIcon:(UIColor *)color;
+ (UIImage *)tabBarChatsIcon:(UIColor *)color downArrow:(NSNumber *)downArrow;
+ (UIImage *)tabBarSettingsIcon:(UIColor *)color;

// Contacts
+ (UIImage *)contactsInviteIcon:(UIColor *)color;
+ (UIImage *)contactsShareIcon:(UIColor *)color;
+ (UIImage *)contactsNewGroupIcon:(UIColor *)color;
+ (UIImage *)contactsNewEncryptedIcon:(UIColor *)color;
+ (UIImage *)contactsNewChannelIcon:(UIColor *)color;
+ (UIImage *)contactsUpgradeIcon:(UIColor *)color;
+ (UIImage *)contactsInviteLinkIcon:(UIColor *)color;

// Calls
+ (UIImage *)callsNewIcon:(UIColor *)color;
+ (UIImage *)callsInfoIcon:(UIColor *)color;
+ (UIImage *)callsOutgoingIcon:(UIColor *)color;

// Search
+ (UIImage *)searchClearIcon:(UIColor *)backgroundColor color:(UIColor *)color;

// Dialogs List
+ (UIImage *)chatMutedIcon:(UIColor *)color;
+ (UIImage *)chatVerifiedIcon:(UIColor *)backgroundColor color:(UIColor *)color;
+ (UIImage *)chatEncryptedIcon:(UIColor *)color;
+ (UIImage *)chatDeliveredIcon:(UIColor *)color;
+ (UIImage *)chatReadIcon:(UIColor *)color;
+ (UIImage *)chatPendingIcon:(UIColor *)color;
+ (UIImage *)chatUnsentIcon:(UIColor *)color;
+ (UIImage *)chatPinnedIcon:(UIColor *)color;
+ (UIImage *)chatMentionedIcon:(UIColor *)backgroundColor color:(UIColor *)color;

+ (UIImage *)chatEditDeleteIcon:(UIColor *)color;
+ (UIImage *)chatEditMuteIcon:(UIColor *)color;
+ (UIImage *)chatEditUnmuteIcon:(UIColor *)color;
+ (UIImage *)chatEditPinIcon:(UIColor *)color;
+ (UIImage *)chatEditUnpinIcon:(UIColor *)color;
+ (UIImage *)chatEditGroupIcon:(UIColor *)color;
+ (UIImage *)chatEditUngroupIcon:(UIColor *)color;

+ (UIImage *)chatsLockBaseIcon:(UIColor *)color;
+ (UIImage *)chatsLockTopIcon:(UIColor *)color active:(bool)active;

+ (UIImage *)chatsProxyIcon:(UIColor *)color connected:(bool)connected onlyShield:(bool)onlyShield;
+ (UIImage *)chatsProxySpinner:(UIColor *)color;

// Conversation
+ (UIImage *)chatTitleMutedIcon:(UIColor *)color;
+ (UIImage *)chatTitleEncryptedIcon:(UIColor *)color;

+ (UIImage *)chatTitleLiveLocationIcon:(UIColor *)color active:(bool)active;

+ (UIImage *)chatTitleMuteIcon:(UIColor *)color;
+ (UIImage *)chatTitleUnmuteIcon:(UIColor *)color;
+ (UIImage *)chatTitleSearchIcon:(UIColor *)color;
+ (UIImage *)chatTitleReportIcon:(UIColor *)color;
+ (UIImage *)chatTitleInfoIcon:(UIColor *)color;
+ (UIImage *)chatTitleCallIcon:(UIColor *)color;
+ (UIImage *)chatTitleGroupIcon:(UIColor *)color;

+ (UIImage *)chatSearchNextIcon:(UIColor *)color;
+ (UIImage *)chatSearchPreviousIcon:(UIColor *)color;
+ (UIImage *)chatSearchCalendarIcon:(UIColor *)color;
+ (UIImage *)chatSearchNameIcon:(UIColor *)color;

+ (UIImage *)chatPlaceholderEncryptedIcon;

+ (UIImage *)chatBubbleImage:(UIColor *)color borderColor:(UIColor *)borderColor outgoing:(bool)outgoing hasTail:(bool)hasTail;
+ (UIImage *)chatRoundMessageBackgroundImage:(UIColor *)color borderColor:(UIColor *)borderColor;

+ (UIImage *)chatPlaceholderBackgroundImage:(UIColor *)color;
+ (UIImage *)chatUnreadBackgroundImage:(UIColor *)color borderColor:(UIColor *)borderColor;
+ (UIImage *)chatSystemBackgroundImage:(UIColor *)color;
+ (UIImage *)chatReplyBackgroundImage:(UIColor *)color;

+ (UIImage *)chatActionShareImage:(UIColor *)color backgroundColor:(UIColor *)backgroundColor borderColor:(UIColor *)borderColor;
+ (UIImage *)chatActionReplyImage:(UIColor *)color backgroundColor:(UIColor *)backgroundColor borderColor:(UIColor *)borderColor;
+ (UIImage *)chatActionGoToImage:(UIColor *)color backgroundColor:(UIColor *)backgroundColor borderColor:(UIColor *)borderColor;

+ (UIImage *)chatReplyButtonImage:(UIColor *)color borderColor:(UIColor *)borderColor;
+ (UIImage *)chatReplyButtonUrlIcon:(UIColor *)color;
+ (UIImage *)chatReplyButtonPhoneIcon:(UIColor *)color;
+ (UIImage *)chatReplyButtonLocationIcon:(UIColor *)color;
+ (UIImage *)chatReplyButtonSwitchInlineIcon:(UIColor *)color;
+ (UIImage *)chatReplyButtonActionIcon:(UIColor *)color;

+ (UIImage *)chatCallIcon:(UIColor *)color;

+ (UIImage *)chatClockFrameIcon:(UIColor *)color;
+ (UIImage *)chatClockHourIcon:(UIColor *)color;
+ (UIImage *)chatClockMinuteIcon:(UIColor *)color;
+ (UIImage *)chatDeliveredMessageIcon:(UIColor *)color;
+ (UIImage *)chatReadMessageIcon:(UIColor *)color;
+ (UIImage *)chatUnsentMessageIcon:(UIColor *)color color:(UIColor *)iconColor;
+ (UIImage *)chatMessageViewsIcon:(UIColor *)color;
+ (UIImage *)chatInstantViewIcon:(UIColor *)color;

+ (UIImage *)chatMentionsButton:(UIColor *)color backgroundColor:(UIColor *)backgroundColor borderColor:(UIColor *)borderColor;
+ (UIImage *)chatDownButton:(UIColor *)color backgroundColor:(UIColor *)backgroundColor borderColor:(UIColor *)borderColor;

+ (UIImage *)chatDeleteIcon:(UIColor *)color;
+ (UIImage *)chatShareIcon:(UIColor *)color;
+ (UIImage *)chatForwardIcon:(UIColor *)color;

+ (UIImage *)inputPanelFieldBackground:(UIColor *)color borderColor:(UIColor *)borderColor;
+ (UIImage *)inputPanelAttachIcon:(UIColor *)color accentColor:(UIColor *)accentColor;
+ (UIImage *)inputPanelSendIcon:(UIColor *)backgroundColor color:(UIColor *)color;
+ (UIImage *)inputPanelConfirmIcon:(UIColor *)backgroundColor color:(UIColor *)color;
+ (UIImage *)inputPanelMicrophoneIcon:(UIColor *)color;
+ (UIImage *)inputPanelVideoMessageIcon:(UIColor *)color;
+ (UIImage *)inputPanelArrowIcon:(UIColor *)color;

+ (UIImage *)inputPanelStickersIcon:(UIColor *)color;
+ (UIImage *)inputPanelKeyboardIcon:(UIColor *)color;
+ (UIImage *)inputPanelCommandsIcon:(UIColor *)color;
+ (UIImage *)inputPanelBotKeyboardIcon:(UIColor *)color;
+ (UIImage *)inputPanelBroadcastIcon:(UIColor *)color active:(bool)active;
+ (UIImage *)inputPanelTimerIcon:(UIColor *)color;
+ (UIImage *)inputPanelClearIcon:(UIColor *)backgroundColor color:(UIColor *)color;

+ (UIImage *)replyCloseIcon:(UIColor *)color;
+ (UIImage *)pinCloseIcon:(UIColor *)color;

+ (UIImage *)stickersGifIcon:(UIColor *)color;
+ (UIImage *)stickersTrendingIcon:(UIColor *)color;
+ (UIImage *)stickersRecentIcon:(UIColor *)color;
+ (UIImage *)stickersFavoritesIcon:(UIColor *)color;
+ (UIImage *)stickersSettingsIcon:(UIColor *)color;
+ (UIImage *)stickersHollowButton:(UIColor *)color radius:(CGFloat)radius;
+ (UIImage *)stickersPlaceholderImage:(UIColor *)color;

+ (UIImage *)commandsButtonImage:(UIColor *)color shadowColor:(UIColor *)shadowColor;

// Profile
+ (UIImage *)profileVerifiedIcon:(UIColor *)backgroundColor color:(UIColor *)color;
+ (UIImage *)profileCallIcon:(UIColor *)color;
+ (UIImage *)profilePhoneDisclosureIcon:(UIColor *)color;

// Collection Menu
+ (UIImage *)collectionMenuDisclosureIcon:(UIColor *)color;
+ (UIImage *)collectionMenuCheckIcon:(UIColor *)color;
+ (UIImage *)collectionMenuAddIcon:(UIColor *)color;
+ (UIImage *)collectionMenuReorderIcon:(UIColor *)color;

// Menu
+ (UIImage *)menuCornersImage:(UIColor *)color;

// Appearance
+ (UIImage *)fontSizeSmallIcon:(UIColor *)color;
+ (UIImage *)fontSizeLargeIcon:(UIColor *)color;

+ (UIImage *)brightnessMinIcon:(UIColor *)color;
+ (UIImage *)brightnessMaxIcon:(UIColor *)color;

// Video Player
+ (UIImage *)videoPlayerPlayIcon:(UIColor *)color;
+ (UIImage *)videoPlayerPauseIcon:(UIColor *)color;
+ (UIImage *)videoPlayerForwardIcon:(UIColor *)color;
+ (UIImage *)videoPlayerBackwardIcon:(UIColor *)color;
+ (UIImage *)videoPlayerPIPIcon:(UIColor *)color;

// Music
+ (UIImage *)speakerIcon:(UIColor *)color;
+ (UIImage *)rate2xIcon:(UIColor *)color;

// Shared Media
+ (UIImage *)sharedMediaDownloadIcon:(UIColor *)color;
+ (UIImage *)sharedMediaPauseIcon:(UIColor *)color;

// Share
+ (UIImage *)shareSearchIcon:(UIColor *)color;
+ (UIImage *)shareExternalIcon:(UIColor *)color;
+ (UIImage *)shareSelectionImage:(UIColor *)color;

// Passport
+ (UIImage *)passportIcon:(UIColor *)color;
+ (UIImage *)passportScanIcon:(UIColor *)color;

// Appearance
+ (UIImage *)appearanceSwatchCheckIcon:(UIColor *)color;

// Proxy
+ (UIImage *)proxyShieldImage:(UIColor *)color;

// Common
+ (UIImage *)badgeWithDiameter:(CGFloat)diameter color:(UIColor *)color border:(CGFloat)border borderColor:(UIColor *)borderColor;
+ (UIImage *)avatarPlaceholderWithDiameter:(CGFloat)diameter color:(UIColor *)color border:(CGFloat)border borderColor:(UIColor *)borderColor;
+ (UIImage *)imageWithColor:(UIColor *)color border:(CGFloat)border borderColor:(UIColor *)borderColor;

+ (UIImage *)plusMinusIcon:(bool)plus backgroundColor:(UIColor *)backgroundColor color:(UIColor *)color;

+ (UIImage *)segmentedControlBackgroundImage:(UIColor *)color;
+ (UIImage *)segmentedControlSelectedImage:(UIColor *)color;
+ (UIImage *)segmentedControlHighlightedImage:(UIColor *)color;
+ (UIImage *)segmentedControlDividerImage:(UIColor *)color;

+ (UIImage *)modernButtonImageWithColor:(UIColor *)color solid:(bool)solid;

@end
