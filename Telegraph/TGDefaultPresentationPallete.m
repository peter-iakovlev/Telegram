#import "TGDefaultPresentationPallete.h"

#import <LegacyComponents/TGImageUtils.h>

@implementation TGDefaultPresentationPallete

- (UIColor *)backgroundColor
{
    return [UIColor whiteColor];
}

- (UIColor *)textColor
{
    return [UIColor blackColor];
}

- (UIColor *)secondaryTextColor
{
    return UIColorRGB(0x8e8e93);
}

- (UIColor *)accentColor
{
    return UIColorRGB(0x007ee5);
}

- (UIColor *)accentContrastColor
{
    return [UIColor whiteColor];
}

- (UIColor *)destructiveColor
{
    return UIColorRGB(0xff3b30);
}

- (UIColor *)selectionColor
{
    static dispatch_once_t onceToken;
    static UIColor *color;
    dispatch_once(&onceToken, ^{
        color = TGIsPad() ? UIColorRGB(0xe4e4e4) : UIColorRGB(0xd9d9d9);
    });
    return color;
}

- (UIColor *)separatorColor
{
    return UIColorRGB(0xc8c7cc);
}

- (UIColor *)linkColor
{
    return UIColorRGB(0x004bad);
}

- (UIColor *)padSeparatorColor
{
    return UIColorRGBA(0x575757, 0.43f);
}

- (UIColor *)barBackgroundColor
{
    return UIColorRGB(0xf7f7f7);
}

- (UIColor *)barSeparatorColor
{
    return UIColorRGB(0xb2b2b2);
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
    return [UIColor blackColor];
}

- (UIColor *)navigationSubtitleColor
{
    return UIColorRGB(0x787878);
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
    return UIColorRGB(0xd0d0d0);
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

- (UIColor *)tabIconColor
{
    return UIColorRGB(0x979797);
}

- (UIColor *)tabTextColor
{
    return UIColorRGB(0x929292);
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
    return UIColorRGB(0xf1f1f1);
}

- (UIColor *)searchBarTextColor
{
    return [UIColor blackColor];
}

- (UIColor *)searchBarPlaceholderColor
{
    return [self secondaryTextColor];
}

- (UIColor *)searchBarMergedBackgroundColor
{
    return UIColorRGB(0xe5e5e5);
}

- (UIColor *)searchBarClearIconColor
{
    return [UIColor whiteColor];
}

- (UIColor *)dialogTitleColor
{
    return [UIColor blackColor];
}

- (UIColor *)dialogNameColor
{
    return [UIColor blackColor];
}

- (UIColor *)dialogTextColor
{
    return [self secondaryTextColor];
}

- (UIColor *)dialogDraftColor
{
    return UIColorRGB(0xdd4b39);
}

- (UIColor *)dialogDateColor
{
    return UIColorRGB(0x969699);
}

- (UIColor *)dialogChecksColor
{
    return UIColorRGB(0x0dc33b);
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
    return UIColorRGB(0xb6b6bb);
}

- (UIColor *)dialogEncryptedColor
{
    return UIColorRGB(0x00a629);
}

- (UIColor *)dialogBadgeColor
{
    return UIColorRGB(0x0f94f3);
}

- (UIColor *)dialogBadgeTextColor
{
    return [UIColor whiteColor];
}

- (UIColor *)dialogBadgeMutedColor
{
    return UIColorRGB(0xb6b6bb);
}

- (UIColor *)dialogBadgeMutedTextColor
{
    return [UIColor whiteColor];
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
    return UIColorRGB(0xff3724);
}

- (UIColor *)dialogEditMuteColor
{
    return UIColorRGB(0xff9500);
}

- (UIColor *)dialogEditPinColor
{
    return UIColorRGB(0x2094fa);
}

- (UIColor *)dialogEditGroupColor
{
    return UIColorRGB(0x48cf5d); //UIColorRGB(0x595ad3); //self.accentColor;
}

- (UIColor *)dialogEditReadColor
{
    return UIColorRGB(0xb6b6bA);
}

- (UIColor *)dialogEditUnreadColor
{
    return self.dialogEditPinColor;
}

- (UIColor *)chatIncomingBubbleColor
{
    return [UIColor whiteColor];
}

- (UIColor *)chatIncomingBubbleBorderColor
{
    return UIColorRGBA(0x7db4e9, 0.4f);
}

- (UIColor *)chatIncomingHighlightedBubbleColor
{
    return UIColorRGB(0xd9f4ff);
}

- (UIColor *)chatIncomingHighlightedBubbleBorderColor
{
    return UIColorRGBA(0x7db4e9, 0.4f);
}

- (UIColor *)chatIncomingTextColor
{
    return [UIColor blackColor];
}

- (UIColor *)chatIncomingSubtextColor
{
    return UIColorRGB(0x979797);
}

- (UIColor *)chatIncomingAccentColor
{
    return [self accentColor];
}

- (UIColor *)chatIncomingLinkColor
{
    return [self linkColor];
}

- (UIColor *)chatIncomingDateColor
{
    return UIColorRGBA(0x525252, 0.6f);
}

- (UIColor *)chatIncomingButtonColor
{
    return [self accentColor];
}

- (UIColor *)chatIncomingButtonIconColor
{
    return [self chatIncomingBubbleColor];
}

- (UIColor *)chatIncomingLineColor
{
    return UIColorRGB(0x3ca7fe);
}

- (UIColor *)chatIncomingAudioBackgroundColor
{
    return UIColorRGB(0xcacaca);
}

- (UIColor *)chatIncomingAudioForegroundColor
{
    return [self accentColor];
}

- (UIColor *)chatIncomingAudioDotColor
{
    return [self accentColor];
}

- (UIColor *)chatOutgoingBubbleColor
{
    return UIColorRGB(0xe1ffc7);
}

- (UIColor *)chatOutgoingBubbleBorderColor
{
    return UIColorRGBA(0x7db4e9, 0.4f);
}

- (UIColor *)chatOutgoingHighlightedBubbleColor
{
    return UIColorRGB(0xc8ffa6);
}

- (UIColor *)chatOutgoingHighlightedBubbleBorderColor
{
    return UIColorRGBA(0x7db4e9, 0.4f);
}

- (UIColor *)chatOutgoingTextColor
{
    return [UIColor blackColor];
}

- (UIColor *)chatOutgoingSubtextColor
{
    return UIColorRGB(0x00a700);
}

- (UIColor *)chatOutgoingAccentColor
{
    return UIColorRGB(0x00a700);
}

- (UIColor *)chatOutgoingLinkColor
{
    return [self linkColor];
}

- (UIColor *)chatOutgoingDateColor
{
    return UIColorRGBA(0x008c09, 0.8f);
}

- (UIColor *)chatOutgoingButtonColor
{
    return UIColorRGB(0x3fc33b);
}

- (UIColor *)chatOutgoingButtonIconColor
{
    return [self chatOutgoingBubbleColor];
}

- (UIColor *)chatOutgoingLineColor
{
    return UIColorRGB(0x29cc10);
}

- (UIColor *)chatOutgoingAudioBackgroundColor
{
    return UIColorRGB(0x93d987);
}

- (UIColor *)chatOutgoingAudioForegroundColor
{
    return UIColorRGB(0x3fc33b);
}

- (UIColor *)chatIncomingCallSuccessfulColor
{
    return UIColorRGB(0x36c033);
}

- (UIColor *)chatIncomingCallFailedColor
{
    return UIColorRGB(0xff4747);
}

- (UIColor *)chatOutgoingCallSuccessfulColor
{
    return [self chatIncomingCallSuccessfulColor];
}

- (UIColor *)chatOutgoingCallFailedColor
{
    return [self chatIncomingCallFailedColor];
}

- (UIColor *)chatOutgoingAudioDotColor
{
    return UIColorRGB(0x19c700);
}

- (UIColor *)chatUnreadBackgroundColor
{
    return UIColorRGBA(0xffffff, 0.8f);
}

- (UIColor *)chatUnreadBorderColor
{
    return UIColorRGBA(0x000000, 0.15f);
}

- (UIColor *)chatUnreadTextColor
{
    return [self secondaryTextColor];
}

- (UIColor *)chatSystemBackgroundColor
{
    return nil; // fallbacks to legacy graphics
}

- (UIColor *)chatSystemTextColor
{
    return [UIColor whiteColor];
}

- (UIColor *)chatActionBackgroundColor
{
    return nil; // fallbacks to legacy graphics
}

- (UIColor *)chatActionIconColor
{
    return nil; // fallbacks to legacy graphics
}

- (UIColor *)chatActionBorderColor
{
    return nil; // fallbacks to legacy graphics
}

- (UIColor *)chatReplyButtonBackgroundColor
{
    return nil; // fallbacks to legacy graphics
}

- (UIColor *)chatReplyButtonHighlightedBackgroundColor
{
    return nil; // fallbacks to legacy graphics
}

- (UIColor *)chatReplyButtonBorderColor
{
    return nil; // fallbacks to legacy graphics
}
- (UIColor *)chatReplyButtonHighlightedBorderColor
{
    return nil; // fallbacks to legacy graphics
}

- (UIColor *)chatReplyButtonIconColor
{
    return [UIColor whiteColor];
}

- (UIColor *)chatImageBorderColor
{
    return [UIColor whiteColor];
}

- (UIColor *)chatImageBorderShadowColor
{
    return UIColorRGBA(0x86a9c9, 0.419f);
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
    return UIColorRGB(0x23ca0a);
}

- (UIColor *)chatChecksMediaColor
{
    return [UIColor whiteColor];
}

- (UIColor *)chatInputBackgroundColor
{
    return [UIColor whiteColor];
}

- (UIColor *)chatInputBorderColor
{
    return UIColorRGB(0xd9dcdf);
}

- (UIColor *)chatInputTextColor
{
    return [UIColor blackColor];
}

- (UIColor *)chatInputPlaceholderColor
{
    return UIColorRGB(0xbebec0);
}

- (UIColor *)chatInputButtonColor
{
    return UIColorRGB(0x858e99);
}

- (UIColor *)chatInputFieldButtonColor
{
    return UIColorRGB(0xa0a7b0);
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
    return UIColorRGB(0xe8ebf0);
}

- (UIColor *)chatInputKeyboardBorderColor
{
    return UIColorRGB(0xbec2c6);
}

- (UIColor *)chatInputKeyboardHeaderColor
{
    return UIColorRGB(0x949599);
}

- (UIColor *)chatInputKeyboardSearchBarColor
{
    return UIColorRGB(0xd9dbe2);
}

- (UIColor *)chatInputKeyboardSearchBarTextColor
{
    return [self searchBarTextColor];
}

- (UIColor *)chatInputSelectionColor
{
    return UIColorRGB(0xe6e7e9);
}

- (UIColor *)chatInputRecordingColor
{
    return UIColorRGB(0xf33d2b);
}

- (UIColor *)chatInputWaveformBackgroundColor
{
    return UIColorRGB(0x9cd6ff);
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
    return UIColorRGB(0xdfdfdf);
}

- (UIColor *)chatInputBotKeyboardBackgroundColor
{
    return UIColorRGB(0xdee2e6);
}

- (UIColor *)chatInputBotKeyboardButtonColor
{
    return [UIColor whiteColor];
}

- (UIColor *)chatInputBotKeyboardButtonHighlightedColor
{
    return UIColorRGB(0xa8b3c0);
}

- (UIColor *)chatInputBotKeyboardButtonShadowColor
{
    return UIColorRGB(0xc3c7c9);
}

- (UIColor *)chatInputBotKeyboardButtonTextColor
{
    return [UIColor blackColor];
}

- (UIColor *)callsOutgoingIconColor
{
    return [self dialogBadgeMutedColor];
}

- (UIColor *)paymentsPayButtonColor
{
    return UIColorRGB(0x027bff);
}

- (UIColor *)paymentsPayButtonDisabledColor
{
    return UIColorRGB(0xcbcbcb);
}

- (UIColor *)locationPinColor
{
    return UIColorRGB(0x008df2);
}

- (UIColor *)locationAccentColor
{
    return UIColorRGB(0x008df2);
}

- (UIColor *)locationLiveColor
{
    return UIColorRGB(0xff6464);
}

- (UIColor *)musicControlsColor
{
    return [self textColor];
}

- (UIColor *)volumeIndicatorBackgroundColor
{
    return UIColorRGB(0xededed);
}

- (UIColor *)volumeIndicatorForegroundColor
{
    return [self textColor];
}

- (UIColor *)collectionMenuBackgroundColor
{
    return UIColorRGB(0xefeff4);
}

- (UIColor *)collectionMenuCellBackgroundColor
{
    return [UIColor whiteColor];
}

- (UIColor *)collectionMenuCellSelectionColor
{
    return [self selectionColor];
}

- (UIColor *)collectionMenuTextColor
{
    return [UIColor blackColor];
}

- (UIColor *)collectionMenuPlaceholderColor
{
    return [self collectionMenuAccessoryColor];
}

- (UIColor *)collectionMenuVariantColor
{
    return [self secondaryTextColor];
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
    return UIColorRGB(0xc8c7cc);
}

- (UIColor *)collectionMenuAccessoryColor
{
    return UIColorRGB(0xc7c7cc);
}

- (UIColor *)collectionMenuCommentColor
{
    return UIColorRGB(0x6d6d72);
}

- (UIColor *)collectionMenuBadgeColor
{
    return UIColorRGB(0x0f94f3);
}

- (UIColor *)collectionMenuBadgeTextColor
{
    return [UIColor whiteColor];
}

- (UIColor *)collectionMenuSwitchColor
{
    return nil;
}

- (UIColor *)collectionMenuCheckColor
{
    return [self accentColor];
}

- (UIColor *)menuBackgroundColor
{
    return [UIColor whiteColor];
}

- (UIColor *)menuSelectionColor
{
    return [self selectionColor];
}

- (UIColor *)menuSeparatorColor
{
    return [self separatorColor];
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
    return [self linkColor];
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
    return [self sectionHeaderBackgroundColor];
}

- (UIColor *)checkButtonBorderColor
{
    return UIColorRGB(0xcacacf);
}

- (UIColor *)checkButtonChatBorderColor
{
    return [UIColor whiteColor];
}

- (UIColor *)checkButtonBackgroundColor
{
    return UIColorRGB(0x29c519);
}

- (UIColor *)checkButtonCheckColor
{
    return [self accentContrastColor];
}

- (UIColor *)checkButtonBlueColor
{
    return [self accentColor];
}

@end
