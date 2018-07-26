#import "TGNightBluePresentationPallete.h"
#import "TGPresentation.h"

@implementation TGNightBluePresentationPallete

- (bool)isDark
{
    return true;
}

- (UIColor *)backgroundColor
{
    return UIColorRGB(0x18222d);
}

- (UIColor *)textColor
{
    return [UIColor whiteColor];
}

- (UIColor *)secondaryTextColor
{
    return UIColorRGB(0x788a96);
}

- (UIColor *)accentColor
{
    return UIColorRGB(0x2ea6ff);
}

- (UIColor *)maybeAccentColor
{
    return [self accentColor];
}

- (UIColor *)accentContrastColor
{
    return [UIColor whiteColor];
}

- (UIColor *)destructiveColor
{
    return UIColorRGB(0xef5b5b);
}

- (UIColor *)selectionColor
{
    return [self barSeparatorColor];
}

- (UIColor *)separatorColor
{
    return UIColorRGB(0x131a23);
}

- (UIColor *)linkColor
{
    return [self accentColor];
}

- (UIColor *)padSeparatorColor
{
    return UIColorRGBA(0x0b1015, 0.75f);
}

- (UIColor *)barBackgroundColor
{
    return UIColorRGB(0x213040);
}

- (UIColor *)barSeparatorColor
{
    return [self separatorColor];
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
    return UIColorRGB(0x8497a2);
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
    return UIColorRGB(0x5b646f);
}

- (UIColor *)navigationBadgeColor
{
    return [self destructiveColor];
}

- (UIColor *)navigationBadgeTextColor
{
    return [UIColor whiteColor];
}

- (UIColor *)navigationBadgeBorderColor
{
    return [UIColor clearColor];
}

- (UIColor *)navigationSpinnerColor
{
    return [self navigationSubtitleColor];
}

- (UIColor *)tabIconColor
{
    return UIColorRGB(0x7e939f);
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
    return [self destructiveColor];
}

- (UIColor *)tabBadgeTextColor
{
    return [UIColor whiteColor];
}

- (UIColor *)tabBadgeBorderColor
{
    return [UIColor clearColor];
}

- (UIColor *)searchBarBackgroundColor
{
    return UIColorRGB(0x10161d);
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
    return UIColorRGB(0x182330);
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
    return UIColorRGB(0x788a96);
}

- (UIColor *)dialogDraftColor
{
    return [self destructiveColor];
}

- (UIColor *)dialogDateColor
{
    return UIColorRGB(0x7e929f);
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
    return [UIColor whiteColor];
}

- (UIColor *)dialogBadgeMutedColor
{
    return UIColorRGB(0x667681);
}

- (UIColor *)dialogBadgeMutedTextColor
{
    return [self backgroundColor];
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
    return UIColorRGB(0x3c4e61);
}

- (UIColor *)dialogEditPinColor
{
    return UIColorRGB(0x46596f);
}

- (UIColor *)dialogEditGroupColor
{
    return self.accentColor;
}

- (UIColor *)dialogEditReadColor
{
    return UIColorRGB(0x3c4e61);
}

- (UIColor *)dialogEditUnreadColor
{
    return self.accentColor;
}

- (UIColor *)chatIncomingBubbleColor
{
    return UIColorRGB(0x212f3f);
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
    return UIColorRGB(0x7e929f);
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
    return UIColorRGB(0x7e93a0);
}

- (UIColor *)chatIncomingButtonColor
{
    return UIColorRGB(0xa7acb2);
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
    return UIColorRGB(0x3c6a97);
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
    return UIColorRGB(0x9bbdd5);
}

- (UIColor *)chatOutgoingAccentColor
{
    return [UIColor whiteColor];
}

- (UIColor *)chatOutgoingLinkColor
{
    return [self chatChecksColor];
}

- (UIColor *)chatOutgoingDateColor
{
    return UIColorRGB(0x8eb1cc);
}

- (UIColor *)chatOutgoingButtonColor
{
    return UIColorRGB(0xb5c3d4);
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
    return [[self backgroundColor] colorWithAlphaComponent:0.5f];
}

- (UIColor *)chatSystemTextColor
{
    return [self textColor];
}

- (UIColor *)chatActionBackgroundColor
{
    return [[self backgroundColor] colorWithAlphaComponent:0.6f];
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
    return [[self backgroundColor] colorWithAlphaComponent:0.5f];
}

- (UIColor *)chatReplyButtonHighlightedBackgroundColor
{
    return [[self backgroundColor] colorWithAlphaComponent:0.35f];
}

- (UIColor *)chatReplyButtonBorderColor
{
    return [self chatIncomingBubbleColor];
}
- (UIColor *)chatReplyButtonHighlightedBorderColor
{
    return [[self chatIncomingBubbleColor] colorWithAlphaComponent:0.65f];
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
    return UIColorRGB(0x63befd);
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
    return UIColorRGB(0x121c25);
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
    return UIColorRGB(0x5d6b71);
}

- (UIColor *)chatInputButtonColor
{
    return UIColorRGB(0x7e93a0);
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
    return [UIColor whiteColor];
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
    return [self chatInputBackgroundColor];
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
    return UIColorRGBA(0xffffff, 0.6f);
}

- (UIColor *)chatInputWaveformForegroundColor
{
    return [UIColor whiteColor];
}

- (UIColor *)chatStickersBadgeColor
{
    return [self destructiveColor];
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
    return UIColorRGB(0x5b646f);
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
    return [self selectionColor];
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
    return UIColorRGB(0x7e93a0);
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
    return UIColorRGB(0x83888d);
}

- (UIColor *)collectionMenuBadgeColor
{
    return [self accentColor];
}

- (UIColor *)collectionMenuBadgeTextColor
{
    return [UIColor whiteColor];
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
    return [self selectionColor];
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
    return [self backgroundColor];
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
