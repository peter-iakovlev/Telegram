#import "TGNightPresentationPallete.h"
#import "TGPresentation.h"

@implementation TGNightPresentationPallete

- (bool)isDark
{
    return true;
}

- (bool)underlineAllIncomingLinks
{
    return true;
}

- (bool)underlineAllOutgoingLinks
{
    return true;
}

- (UIColor *)backgroundColor
{
    return [UIColor blackColor];
}

- (UIColor *)textColor
{
    return [UIColor whiteColor];
}

- (UIColor *)secondaryTextColor
{
    return UIColorRGB(0x8e8e93);
}

- (UIColor *)accentColor
{
    return [UIColor whiteColor];
}

- (UIColor *)accentContrastColor
{
    return [UIColor blackColor];
}

- (UIColor *)destructiveColor
{
    return UIColorRGB(0xee7b70);
}

- (UIColor *)selectionColor
{
    return UIColorRGB(0x151515);
}

- (UIColor *)separatorColor
{
    return UIColorRGB(0x252525);
}

- (UIColor *)linkColor
{
    return [self accentColor];
}

- (UIColor *)padSeparatorColor
{
    return [self barSeparatorColor];
}

- (UIColor *)barBackgroundColor
{
    return UIColorRGB(0x1c1c1d);
}

- (UIColor *)barSeparatorColor
{
    return [UIColor blackColor];
}

- (UIColor *)sectionHeaderBackgroundColor
{
    return [self barBackgroundColor];
}

- (UIColor *)sectionHeaderTextColor
{
    return [self secondaryTextColor];
}

- (UIColor *)navigationTitleColor
{
    return [UIColor whiteColor];
}

- (UIColor *)navigationSubtitleColor
{
    return [self secondaryTextColor];
}

- (UIColor *)navigationActiveSubtitleColor
{
    return [self accentColor];
}

- (UIColor *)navigationButtonColor
{
    return [self accentColor];
}

- (UIColor *)navigationDisabledButtonColor
{
    return UIColorRGB(0x525252);
}

- (UIColor *)navigationBadgeColor
{
    return [self accentColor];
}

- (UIColor *)navigationBadgeTextColor
{
    return [self accentContrastColor];
}

- (UIColor *)navigationBadgeBorderColor
{
    return [self barBackgroundColor];
}

- (UIColor *)navigationSpinnerColor
{
    return [self navigationSubtitleColor];
}

- (UIColor *)tabIconColor
{
    return UIColorRGB(0x929292);
}

- (UIColor *)tabTextColor
{
    return [self tabIconColor];
}

- (UIColor *)tabActiveIconColor
{
    return [self accentColor];
}

- (UIColor *)tabBadgeColor
{
    return [self accentColor];
}

- (UIColor *)tabBadgeTextColor
{
    return [self accentContrastColor];
}

- (UIColor *)tabBadgeBorderColor
{
    return [self barBackgroundColor];
}

- (UIColor *)searchBarBackgroundColor
{
    return UIColorRGB(0x272728);
}

- (UIColor *)searchBarTextColor
{
    return [UIColor whiteColor];
}

- (UIColor *)searchBarPlaceholderColor
{
    return [self secondaryTextColor];
}

- (UIColor *)searchBarMergedBackgroundColor
{
    return UIColorRGB(0x272728);
}

- (UIColor *)searchBarClearIconColor
{
    return [self searchBarBackgroundColor];
}

- (UIColor *)dialogTitleColor
{
    return [UIColor whiteColor];
}

- (UIColor *)dialogNameColor
{
    return [UIColor whiteColor];
}

- (UIColor *)dialogTextColor
{
    return [self secondaryTextColor];
}

- (UIColor *)dialogDraftColor
{
    return [self destructiveColor];
}

- (UIColor *)dialogDateColor
{
    return [self secondaryTextColor];
}

- (UIColor *)dialogChecksColor
{
    return [self accentColor];
}

- (UIColor *)dialogVerifiedBackgroundColor
{
    return UIColorRGB(0x58a6e1);
}

- (UIColor *)dialogVerifiedIconColor
{
    return [UIColor whiteColor];
}

- (UIColor *)dialogPinnedBackgroundColor
{
    return [self barBackgroundColor];
}

- (UIColor *)dialogPinnedIconColor
{
    return [self dialogBadgeMutedColor];
}

- (UIColor *)dialogEncryptedColor
{
    return UIColorRGB(0x28b772);
}

- (UIColor *)dialogBadgeColor
{
    return [self accentColor];
}

- (UIColor *)dialogBadgeTextColor
{
    return [UIColor blackColor];
}

- (UIColor *)dialogBadgeMutedColor
{
    return UIColorRGB(0x666666);
}

- (UIColor *)dialogBadgeMutedTextColor
{
    return [UIColor blackColor];
}

- (UIColor *)dialogUnsentColor
{
    return [self destructiveColor];
}

- (UIColor *)dialogEditTextColor
{
    return [UIColor whiteColor];
}

- (UIColor *)dialogEditDeleteColor
{
    return [self destructiveColor];
}

- (UIColor *)dialogEditMuteColor
{
    return UIColorRGB(0x414141);
}

- (UIColor *)dialogEditPinColor
{
    return UIColorRGB(0x666666);
}

- (UIColor *)dialogEditGroupColor
{
    return self.barBackgroundColor;
}

- (UIColor *)dialogEditReadColor
{
    return UIColorRGB(0x414141);
}

- (UIColor *)dialogEditUnreadColor
{
    return UIColorRGB(0x666666);
}

- (UIColor *)chatIncomingBubbleColor
{
    return UIColorRGB(0x1f1f1f);
}

- (UIColor *)chatIncomingBubbleBorderColor
{
    return [self chatIncomingBubbleColor];
}

- (UIColor *)chatIncomingHighlightedBubbleColor
{
    return [[self chatIncomingBubbleColor] colorWithHueMultiplier:1.0f saturationMultiplier:1.0f brightnessMultiplier:1.25f];
}

- (UIColor *)chatIncomingHighlightedBubbleBorderColor
{
    return [self chatIncomingHighlightedBubbleColor];
}

- (UIColor *)chatIncomingTextColor
{
    return [UIColor whiteColor];
}

- (UIColor *)chatIncomingSubtextColor
{
    return UIColorRGB(0x909090);
}

- (UIColor *)chatIncomingAccentColor
{
    return [UIColor whiteColor];
}

- (UIColor *)chatIncomingLinkColor
{
    return [self linkColor];
}

- (UIColor *)chatIncomingDateColor
{
    return [self chatIncomingSubtextColor];
}

- (UIColor *)chatIncomingButtonColor
{
    return UIColorRGB(0xa5a5a5);
}

- (UIColor *)chatIncomingButtonIconColor
{
    return [self chatIncomingBubbleColor];
}

- (UIColor *)chatIncomingLineColor
{
    return [self chatOutgoingAccentColor];
}

- (UIColor *)chatIncomingAudioBackgroundColor
{
    return [self chatIncomingSubtextColor];
}

- (UIColor *)chatIncomingAudioForegroundColor
{
    return [self chatIncomingAccentColor];
}

- (UIColor *)chatIncomingAudioDotColor
{
    return [self chatIncomingAccentColor];
}

- (UIColor *)chatOutgoingBubbleColor
{
    return UIColorRGB(0x313131);
}

- (UIColor *)chatOutgoingBubbleBorderColor
{
    return [self chatOutgoingBubbleColor];
}

- (UIColor *)chatOutgoingHighlightedBubbleColor
{
    return [[self chatOutgoingBubbleColor] colorWithHueMultiplier:1.0f saturationMultiplier:1.0f brightnessMultiplier:1.25f];
}

- (UIColor *)chatOutgoingHighlightedBubbleBorderColor
{
    return [self chatOutgoingHighlightedBubbleColor];
}

- (UIColor *)chatOutgoingTextColor
{
    return [UIColor whiteColor];
}

- (UIColor *)chatOutgoingSubtextColor
{
    return UIColorRGB(0x999999);
}

- (UIColor *)chatOutgoingAccentColor
{
    return [UIColor whiteColor];
}

- (UIColor *)chatOutgoingLinkColor
{
    return [self linkColor];
}

- (UIColor *)chatOutgoingDateColor
{
    return [self chatOutgoingSubtextColor];
}

- (UIColor *)chatOutgoingButtonColor
{
    return UIColorRGB(0xa5a5a5);
}

- (UIColor *)chatOutgoingButtonIconColor
{
    return [self chatOutgoingBubbleColor];
}

- (UIColor *)chatOutgoingLineColor
{
    return [self chatOutgoingAccentColor];
}

- (UIColor *)chatOutgoingAudioBackgroundColor
{
    return [self chatOutgoingSubtextColor];
}

- (UIColor *)chatOutgoingAudioForegroundColor
{
    return [self chatOutgoingAccentColor];
}

- (UIColor *)chatOutgoingAudioDotColor
{
    return [self chatOutgoingAccentColor];
}

- (UIColor *)chatIncomingCallSuccessfulColor
{
    return [self dialogEncryptedColor];
}

- (UIColor *)chatIncomingCallFailedColor
{
    return [self destructiveColor];
}

- (UIColor *)chatOutgoingCallSuccessfulColor
{
    return [self chatIncomingCallSuccessfulColor];
}

- (UIColor *)chatOutgoingCallFailedColor
{
    return [self chatIncomingCallFailedColor];
}

- (UIColor *)chatUnreadBackgroundColor
{
    return [self chatIncomingBubbleColor];
}

- (UIColor *)chatUnreadBorderColor
{
    return nil;
}

- (UIColor *)chatUnreadTextColor
{
    return [self secondaryTextColor];
}

- (UIColor *)chatSystemBackgroundColor
{
    return UIColorRGBA(0x000000, 0.6f);
}

- (UIColor *)chatSystemTextColor
{
    return [self accentColor];
}

- (UIColor *)chatActionBackgroundColor
{
    return UIColorRGBA(0x000000, 0.6f);
}

- (UIColor *)chatActionIconColor
{
    return [self chatIncomingButtonColor];
}

- (UIColor *)chatActionBorderColor
{
    return [self chatIncomingBubbleColor];
}

- (UIColor *)chatReplyButtonBackgroundColor
{
    return UIColorRGBA(0x000000, 0.6f);
}

- (UIColor *)chatReplyButtonHighlightedBackgroundColor
{
    return UIColorRGBA(0x000000, 0.45f);
}

- (UIColor *)chatReplyButtonBorderColor
{
    return [self chatIncomingBubbleColor];
}

- (UIColor *)chatReplyButtonHighlightedBorderColor
{
    return [[self chatReplyButtonBorderColor] colorWithAlphaComponent:0.85f];
}

- (UIColor *)chatReplyButtonIconColor
{
    return [self chatIncomingAccentColor];
}

- (UIColor *)chatImageBorderColor
{
    return [self barBackgroundColor];
}

- (UIColor *)chatImageBorderShadowColor
{
    return [UIColor clearColor];
}

- (UIColor *)chatRoundMessageBackgroundColor
{
    return [self chatImageBorderColor];
}

- (UIColor *)chatRoundMessageBorderColor
{
    return [self chatIncomingBubbleBorderColor];
}

- (UIColor *)chatChecksColor
{
    return [self chatOutgoingDateColor];
}

- (UIColor *)chatChecksMediaColor
{
    return [UIColor whiteColor];
}

- (UIColor *)chatServiceBackgroundColor
{
    return nil;
}

- (UIColor *)chatServiceTextColor
{
    return [UIColor whiteColor];
}

- (UIColor *)chatServiceIconColor
{
    return [UIColor whiteColor];
}

- (UIColor *)chatInputBackgroundColor
{
    return UIColorRGB(0x060606);
}

- (UIColor *)chatInputBorderColor
{
    return [self chatInputBackgroundColor];
}

- (UIColor *)chatInputTextColor
{
    return [UIColor whiteColor];
}

- (UIColor *)chatInputPlaceholderColor
{
    return UIColorRGB(0x7b7b7b);
}

- (UIColor *)chatInputButtonColor
{
    return UIColorRGB(0x808080);
}

- (UIColor *)chatInputFieldButtonColor
{
    return [self chatInputPlaceholderColor];
}

- (UIColor *)chatInputSendButtonColor
{
    return [self accentColor];
}

- (UIColor *)chatInputSendButtonIconColor
{
    return [self accentContrastColor];
}

- (UIColor *)chatInputKeyboardBackgroundColor
{
    return [self backgroundColor];
}

- (UIColor *)chatInputKeyboardBorderColor
{
    return [self chatInputKeyboardBackgroundColor];
}

- (UIColor *)chatInputKeyboardHeaderColor
{
    return [self secondaryTextColor];
}

- (UIColor *)chatInputKeyboardSearchBarColor
{
    return [self barBackgroundColor];
}

- (UIColor *)chatInputSelectionColor
{
    return [self chatInputBackgroundColor];
}

- (UIColor *)chatInputRecordingColor
{
    return [self accentColor];
}

- (UIColor *)chatInputWaveformBackgroundColor
{
    return [self secondaryTextColor];
}

- (UIColor *)chatInputWaveformForegroundColor
{
    return [UIColor blackColor];
}

- (UIColor *)chatStickersBadgeColor
{
    return [self accentColor];
}

- (UIColor *)chatBotResultPlaceholderColor
{
    return [self secondaryTextColor];
}

- (UIColor *)chatInputBotKeyboardBackgroundColor
{
    return UIColorRGB(0x171a1f);
}

- (UIColor *)chatInputBotKeyboardButtonColor
{
    return UIColorRGB(0x5c5f62);
}

- (UIColor *)chatInputBotKeyboardButtonHighlightedColor
{
    return UIColorRGB(0x44474a);
}

- (UIColor *)chatInputBotKeyboardButtonShadowColor
{
    return UIColorRGB(0x0e1013);
}

- (UIColor *)chatInputBotKeyboardButtonTextColor
{
    return [UIColor whiteColor];
}

- (UIColor *)callsOutgoingIconColor
{
    return [self dialogBadgeMutedColor];
}

- (UIColor *)paymentsPayButtonColor
{
    return [self accentColor];
}

- (UIColor *)paymentsPayButtonDisabledColor
{
    return UIColorRGB(0x606060);
}

- (UIColor *)locationPinColor
{
    return [self accentColor];
}

- (UIColor *)locationAccentColor
{
    return [self accentColor];
}

- (UIColor *)locationLiveColor
{
    return [self destructiveColor];
}

- (UIColor *)musicControlsColor
{
    return [UIColor whiteColor];
}

- (UIColor *)volumeIndicatorBackgroundColor
{
    return [self collectionMenuVariantColor];
}

- (UIColor *)volumeIndicatorForegroundColor
{
    return [self textColor];
}

- (UIColor *)collectionMenuBackgroundColor
{
    return [self backgroundColor];
}

- (UIColor *)collectionMenuCellBackgroundColor
{
    return [self barBackgroundColor];
}

- (UIColor *)collectionMenuCellSelectionColor
{
    return UIColorRGB(0x101010);
}

- (UIColor *)collectionMenuTextColor
{
    return [UIColor whiteColor];
}

- (UIColor *)collectionMenuPlaceholderColor
{
    return [self collectionMenuAccessoryColor];
}

- (UIColor *)collectionMenuVariantColor
{
    return UIColorRGB(0x8e8e8e);
}

- (UIColor *)collectionMenuAccentColor
{
    return [self accentColor];
}

- (UIColor *)collectionMenuDestructiveColor
{
    return [self destructiveColor];
}

- (UIColor *)collectionMenuSeparatorColor
{
    return [self barSeparatorColor];
}

- (UIColor *)collectionMenuAccessoryColor
{
    return [self collectionMenuVariantColor];
}

- (UIColor *)collectionMenuCommentColor
{
    return [self secondaryTextColor];
}

- (UIColor *)collectionMenuBadgeColor
{
    return [self accentColor];
}

- (UIColor *)collectionMenuBadgeTextColor
{
    return [self accentContrastColor];
}

- (UIColor *)collectionMenuSwitchColor
{
    return [self accentColor];
}

- (UIColor *)collectionMenuCheckColor
{
    return [self accentColor];
}

- (UIColor *)collectionMenuSpinnerColor
{
    return [self collectionMenuAccessoryColor];
}

- (UIColor *)menuBackgroundColor
{
    return [self collectionMenuCellBackgroundColor];
}

- (UIColor *)menuSelectionColor
{
    return [self collectionMenuCellSelectionColor];
}

- (UIColor *)menuSeparatorColor
{
    return [self collectionMenuSeparatorColor];
}

- (UIColor *)menuTextColor
{
    return [self textColor];
}

- (UIColor *)menuSecondaryTextColor
{
    return [self secondaryTextColor];
}

- (UIColor *)menuLinkColor
{
    return [self accentColor];
}

- (UIColor *)menuAccentColor
{
    return [self accentColor];
}

- (UIColor *)menuDestructiveColor
{
    return [self destructiveColor];
}

- (UIColor *)menuSpinnerColor
{
    return [self collectionMenuAccessoryColor];
}

- (UIColor *)menuSectionHeaderBackgroundColor
{
    return [[self sectionHeaderBackgroundColor] colorWithHueMultiplier:1.0f saturationMultiplier:1.0f brightnessMultiplier:0.8f];
}

- (UIColor *)checkButtonBorderColor
{
    return [self secondaryTextColor];
}

- (UIColor *)checkButtonBackgroundColor
{
    return [self accentColor];
}

- (UIColor *)checkButtonCheckColor
{
    return [self accentContrastColor];
}

- (UIColor *)checkButtonBlueColor
{
    return [self accentColor];
}

- (UIColor *)checkButtonChatBorderColor
{
    return [TGPresentationPallete hasWallpaper] ? [UIColor whiteColor] : [self secondaryTextColor];
}

@end

