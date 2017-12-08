#import <Foundation/Foundation.h>

@interface TGPresentationAssets : NSObject

// Tabs
+ (UIImage *)tabBarContactsIcon:(UIColor *)color;
+ (UIImage *)tabBarCallsIcon:(UIColor *)color;
+ (UIImage *)tabBarChatsIcon:(UIColor *)color;
+ (UIImage *)tabBarSettingsIcon:(UIColor *)color;

// Calls
+ (UIImage *)callsNewIcon:(UIColor *)color;
+ (UIImage *)callsInfoIcon:(UIColor *)color;
+ (UIImage *)callsOutgoingIcon:(UIColor *)color;

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

+ (UIImage *)chatEditDeleteIcon;
+ (UIImage *)chatEditMuteIcon;
+ (UIImage *)chatEditUnmuteIcon;
+ (UIImage *)chatEditPinIcon;
+ (UIImage *)chatEditUnpinIcon;

+ (UIImage *)chatsLockBaseIcon:(bool)active;
+ (UIImage *)chatsLockTopIcon:(bool)active;

// Conversation
+ (UIImage *)chatTitleMutedIcon;
+ (UIImage *)chatTitleEncryptedIcon;

+ (UIImage *)chatTitleMuteIcon;
+ (UIImage *)chatTitleUnmuteIcon;
+ (UIImage *)chatTitleSearchIcon;
+ (UIImage *)chatTitleReportIcon;
+ (UIImage *)chatTitleInfoIcon;
+ (UIImage *)chatTitleCallIcon;

+ (UIImage *)chatPlaceholderEncryptedIcon;

+ (UIImage *)chatCallIcon:(UIColor *)color;

+ (UIImage *)chatDeliveredMessageIcon:(UIColor *)color;
+ (UIImage *)chatReadMessageIcon:(UIColor *)color;
+ (UIImage *)chatUnsentMessageIcon:(UIColor *)color;
+ (UIImage *)chatMessageViewsIcon:(UIColor *)color;
+ (UIImage *)chatInstantViewIcon:(UIColor *)color;
+ (UIImage *)chatChannelShareIcon;
+ (UIImage *)chatReplyIcon;
+ (UIImage *)chatGoToIcon;

+ (UIImage *)chatDeleteIcon;
+ (UIImage *)chatShareIcon;
+ (UIImage *)chatForwardIcon;
+ (UIImage *)chatCalendarIcon;
+ (UIImage *)chatAuthorIcon;

+ (UIImage *)inputPanelFieldBackground;
+ (UIImage *)inputPanelAttachIcon;
+ (UIImage *)inputPanelSendIcon;
+ (UIImage *)inputPanelConfirmIcon;
+ (UIImage *)inputPanelMicrophoneIcon:(bool)overlay;
+ (UIImage *)inputPanelVideoMessageIcon:(bool)overlay;
+ (UIImage *)inputPanelArrowIcon;

+ (UIImage *)inputPanelStickersIcon;
+ (UIImage *)inputPanelKeyboardIcon;
+ (UIImage *)inputPanelCommandsIcon;
+ (UIImage *)inputPanelBotKeyboardIcon;
+ (UIImage *)inputPanelBroadcastIcon:(bool)active;
+ (UIImage *)inputPanelTimerIcon;

// Profile
+ (UIImage *)profileVerifiedIcon:(UIColor *)backgroundColor color:(UIColor *)color;
+ (UIImage *)profileCallIcon:(UIColor *)color;

// Collection Menu
+ (UIImage *)collectionMenuDisclosureIcon:(UIColor *)color;
+ (UIImage *)collectionMenuCheckIcon:(UIColor *)color;
+ (UIImage *)collectionMenuReorderIcon:(UIColor *)color;

// Common
+ (UIImage *)badgeWithDiameter:(CGFloat)diameter color:(UIColor *)color border:(CGFloat)border borderColor:(UIColor *)borderColor;


@end
