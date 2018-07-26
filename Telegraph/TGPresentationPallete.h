#import <Foundation/Foundation.h>

#define COLOR @property (nonatomic, readonly) UIColor *

@interface TGPresentationPallete : NSObject

@property (nonatomic, readonly) bool isDark;

@property (nonatomic, readonly) bool underlineAllIncomingLinks;
@property (nonatomic, readonly) bool underlineAllOutgoingLinks;

COLOR backgroundColor;
COLOR textColor;
COLOR secondaryTextColor;
COLOR accentColor;
COLOR maybeAccentColor;
COLOR accentContrastColor;
COLOR destructiveColor;
COLOR selectionColor;
COLOR separatorColor;
COLOR linkColor;

COLOR checkButtonBorderColor;
COLOR checkButtonChatBorderColor;
COLOR checkButtonBackgroundColor;
COLOR checkButtonCheckColor;
COLOR checkButtonBlueColor;

COLOR padSeparatorColor;

COLOR barBackgroundColor;
COLOR barSeparatorColor;

COLOR sectionHeaderBackgroundColor;
COLOR sectionHeaderTextColor;

COLOR navigationTitleColor;
COLOR navigationSubtitleColor;
COLOR navigationActiveSubtitleColor;
COLOR navigationButtonColor;
COLOR navigationDisabledButtonColor;
COLOR navigationBadgeColor;
COLOR navigationBadgeTextColor;
COLOR navigationBadgeBorderColor;
COLOR navigationSpinnerColor;

COLOR tabTextColor;
COLOR tabIconColor;
COLOR tabActiveIconColor;
COLOR tabBadgeColor;
COLOR tabBadgeTextColor;
COLOR tabBadgeBorderColor;

COLOR searchBarBackgroundColor;
COLOR searchBarTextColor;
COLOR searchBarPlaceholderColor;
COLOR searchBarMergedBackgroundColor;
COLOR searchBarClearIconColor;

COLOR dialogTitleColor;
COLOR dialogNameColor;
COLOR dialogTextColor;
COLOR dialogDraftColor;
COLOR dialogDateColor;
COLOR dialogChecksColor;
COLOR dialogVerifiedBackgroundColor;
COLOR dialogVerifiedIconColor;
COLOR dialogPinnedBackgroundColor;
COLOR dialogPinnedIconColor;
COLOR dialogEncryptedColor;
COLOR dialogBadgeColor;
COLOR dialogBadgeTextColor;
COLOR dialogBadgeMutedColor;
COLOR dialogBadgeMutedTextColor;
COLOR dialogUnsentColor;

COLOR dialogEditTextColor;
COLOR dialogEditDeleteColor;
COLOR dialogEditMuteColor;
COLOR dialogEditPinColor;
COLOR dialogEditGroupColor;
COLOR dialogEditReadColor;
COLOR dialogEditUnreadColor;

COLOR chatIncomingBubbleColor;
COLOR chatIncomingBubbleBorderColor;
COLOR chatIncomingHighlightedBubbleColor;
COLOR chatIncomingHighlightedBubbleBorderColor;
COLOR chatIncomingTextColor;
COLOR chatIncomingSubtextColor;
COLOR chatIncomingAccentColor;
COLOR chatIncomingLinkColor;
COLOR chatIncomingDateColor;
COLOR chatIncomingButtonColor;
COLOR chatIncomingButtonIconColor;
COLOR chatIncomingLineColor;
COLOR chatIncomingAudioBackgroundColor;
COLOR chatIncomingAudioForegroundColor;
COLOR chatIncomingAudioDotColor;

COLOR chatOutgoingBubbleColor;
COLOR chatOutgoingBubbleBorderColor;
COLOR chatOutgoingHighlightedBubbleColor;
COLOR chatOutgoingHighlightedBubbleBorderColor;
COLOR chatOutgoingTextColor;
COLOR chatOutgoingSubtextColor;
COLOR chatOutgoingAccentColor;
COLOR chatOutgoingLinkColor;
COLOR chatOutgoingDateColor;
COLOR chatOutgoingButtonColor;
COLOR chatOutgoingButtonIconColor;
COLOR chatOutgoingLineColor;
COLOR chatOutgoingAudioBackgroundColor;
COLOR chatOutgoingAudioForegroundColor;
COLOR chatOutgoingAudioDotColor;

COLOR chatIncomingCallSuccessfulColor;
COLOR chatIncomingCallFailedColor;

COLOR chatOutgoingCallSuccessfulColor;
COLOR chatOutgoingCallFailedColor;

COLOR chatUnreadBackgroundColor;
COLOR chatUnreadBorderColor;
COLOR chatUnreadTextColor;

COLOR chatSystemBackgroundColor;
COLOR chatSystemTextColor;

COLOR chatActionBackgroundColor;
COLOR chatActionIconColor;
COLOR chatActionBorderColor;

COLOR chatReplyButtonBackgroundColor;
COLOR chatReplyButtonHighlightedBackgroundColor;
COLOR chatReplyButtonBorderColor;
COLOR chatReplyButtonHighlightedBorderColor;
COLOR chatReplyButtonIconColor;

COLOR chatImageBorderColor;
COLOR chatImageBorderShadowColor;
COLOR chatRoundMessageBackgroundColor;
COLOR chatRoundMessageBorderColor;

COLOR chatChecksColor;
COLOR chatChecksMediaColor;

COLOR chatInputBackgroundColor;
COLOR chatInputBorderColor;
COLOR chatInputTextColor;
COLOR chatInputPlaceholderColor;
COLOR chatInputButtonColor;
COLOR chatInputFieldButtonColor;
COLOR chatInputSendButtonColor;
COLOR chatInputSendButtonIconColor;
COLOR chatInputKeyboardBackgroundColor;
COLOR chatInputKeyboardBorderColor;
COLOR chatInputKeyboardHeaderColor;
COLOR chatInputKeyboardSearchBarColor;
COLOR chatInputKeyboardSearchBarTextColor;
COLOR chatInputSelectionColor;
COLOR chatInputRecordingColor;
COLOR chatInputWaveformBackgroundColor;
COLOR chatInputWaveformForegroundColor;
COLOR chatStickersBadgeColor;

COLOR chatBotResultPlaceholderColor;

COLOR chatInputBotKeyboardBackgroundColor;
COLOR chatInputBotKeyboardButtonColor;
COLOR chatInputBotKeyboardButtonHighlightedColor;
COLOR chatInputBotKeyboardButtonShadowColor;
COLOR chatInputBotKeyboardButtonTextColor;

COLOR callsOutgoingIconColor;

COLOR paymentsPayButtonColor;
COLOR paymentsPayButtonDisabledColor;

COLOR locationPinColor;
COLOR locationAccentColor;
COLOR locationLiveColor;

COLOR musicControlsColor;

COLOR volumeIndicatorBackgroundColor;
COLOR volumeIndicatorForegroundColor;

COLOR collectionMenuBackgroundColor;
COLOR collectionMenuCellBackgroundColor;
COLOR collectionMenuCellSelectionColor;
COLOR collectionMenuTextColor;
COLOR collectionMenuPlaceholderColor;
COLOR collectionMenuVariantColor;
COLOR collectionMenuAccentColor;
COLOR collectionMenuDestructiveColor;
COLOR collectionMenuSeparatorColor;
COLOR collectionMenuAccessoryColor;
COLOR collectionMenuCommentColor;
COLOR collectionMenuBadgeColor;
COLOR collectionMenuBadgeTextColor;
COLOR collectionMenuSwitchColor;
COLOR collectionMenuCheckColor;
COLOR collectionMenuSpinnerColor;

COLOR menuBackgroundColor;
COLOR menuSelectionColor;
COLOR menuSeparatorColor;
COLOR menuTextColor;
COLOR menuSecondaryTextColor;
COLOR menuLinkColor;
COLOR menuAccentColor;
COLOR menuDestructiveColor;
COLOR menuSpinnerColor;
COLOR menuSectionHeaderBackgroundColor;

+ (bool)hasWallpaper;

@end

#undef COLOR
