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

- (UIColor *)barBackgroundColor
{
    return UIColorRGB(0xf7f7f7);
}

- (UIColor *)barSeparatorColor
{
    return UIColorRGB(0xb2b2b2);
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

- (UIColor *)chatIncomingBubbleColor
{
    return [UIColor whiteColor];
}

//- (UIColor *)chatIncomingBubbleBorderColor
//{
//
//}
//
//- (UIColor *)chatIncomingHighlightedBubbleColor
//{
//
//}
//
//- (UIColor *)chatIncomingHighlightedBubbleBorderColor
//{
//
//}

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
    return UIColorRGB(0x004bad);
}

- (UIColor *)chatOutgoingBubbleColor
{
    return UIColorRGB(0xe1ffc7);
}

//- (UIColor *)chatOutgoingBubbleBorderColor
//{
//    
//}
//
//- (UIColor *)chatOutgoingHighlightedBubbleColor
//{
//    
//}
//
//- (UIColor *)chatOutgoingHighlightedBubbleBorderColor
//{
//    
//}

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
    return UIColorRGB(0x004bad);
}

- (UIColor *)chatChecksColor
{
    return UIColorRGB(0x23ca0a);
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

- (UIColor *)callsOutgoingIconColor
{
    return [self dialogBadgeMutedColor];
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

@end
