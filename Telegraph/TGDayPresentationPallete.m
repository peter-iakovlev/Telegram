#import "TGDayPresentationPallete.h"
#import "TGPresentation.h"

@interface TGDayPresentationPallete ()
{
    UIColor *_accentColor;
}
@end

@implementation TGDayPresentationPallete

- (bool)isLightAccentColor
{
    return [_accentColor isEqual:UIColorRGB(0xff7519)] || [_accentColor isEqual:UIColorRGB(0xeba239)] || [_accentColor isEqual:UIColorRGB(0x00c2ed)] || [_accentColor isEqual:UIColorRGB(0xff5da2)];
}

- (bool)underlineAllOutgoingLinks
{
    return true;
}

- (UIColor *)accentColor
{
    return _accentColor;
}

- (UIColor *)maybeAccentColor
{
    return _accentColor;
}

- (UIColor *)dialogChecksColor
{
    return _accentColor;
}

- (UIColor *)tabBadgeBorderColor
{
    return [self barBackgroundColor];
}

- (UIColor *)navigationBadgeBorderColor
{
    return [self barBackgroundColor];
}

- (UIColor *)chatIncomingBubbleColor
{
    return [TGPresentationPallete hasWallpaper] ? [UIColor whiteColor] : UIColorRGB(0xf1f1f4);
}

- (UIColor *)chatIncomingBubbleBorderColor
{
    return [self chatIncomingBubbleColor];
}

- (UIColor *)chatIncomingHighlightedBubbleColor
{
    return [[self chatIncomingBubbleColor] colorWithHueMultiplier:1.0f saturationMultiplier:1.0f brightnessMultiplier:0.87f];
}

- (UIColor *)chatIncomingHighlightedBubbleBorderColor
{
    return [self chatIncomingHighlightedBubbleColor];
}

- (UIColor *)chatIncomingTextColor
{
    return [UIColor blackColor];
}

- (UIColor *)chatIncomingAccentColor
{
    return _accentColor;
}

- (UIColor *)chatIncomingLineColor
{
    return _accentColor;
}

- (UIColor *)chatIncomingDateColor
{
    return UIColorRGB(0x929292);
}

- (UIColor *)chatOutgoingBubbleColor
{
    return _accentColor;
}

- (UIColor *)chatOutgoingBubbleBorderColor
{
    return [self chatOutgoingBubbleColor];
}

- (UIColor *)chatOutgoingHighlightedBubbleColor
{
    return [[self chatOutgoingBubbleColor] colorWithHueMultiplier:1.0f saturationMultiplier:1.0f brightnessMultiplier:0.8f];
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
    CGFloat alpha = [self isLightAccentColor] ? 0.68f : 0.58f;
    return UIColorRGBA(0xffffff, alpha);
}

- (UIColor *)chatOutgoingLinkColor
{
    return [self chatOutgoingTextColor];
}

- (UIColor *)chatOutgoingAccentColor
{
    return [self chatOutgoingTextColor];
}

- (UIColor *)chatOutgoingDateColor
{
    return [self chatOutgoingSubtextColor];
}

- (UIColor *)chatOutgoingButtonColor
{
    return [UIColor whiteColor];
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
    if ([_accentColor isEqual:UIColorRGB(0xf83b4c)] || UIColorRGB(0x29b327) || UIColorRGB(0xff5da2))
        return [UIColor whiteColor];
    else
        return [self chatIncomingCallSuccessfulColor];
}

- (UIColor *)chatOutgoingCallFailedColor
{
    if ([_accentColor isEqual:UIColorRGB(0xf83b4c)] || UIColorRGB(0x29b327) || UIColorRGB(0xff5da2))
        return [self chatOutgoingSubtextColor];
    else
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
    return [TGPresentationPallete hasWallpaper] ? [super chatSystemBackgroundColor] : UIColorRGBA(0xffffff, 0.8f);
}

- (UIColor *)chatSystemTextColor
{
    return [TGPresentationPallete hasWallpaper] ? [super chatSystemTextColor] : [self secondaryTextColor];
}

- (UIColor *)chatActionBackgroundColor
{
    return [TGPresentationPallete hasWallpaper] ? [super chatActionBackgroundColor] : UIColorRGBA(0xffffff, 0.65f);
}

- (UIColor *)chatActionIconColor
{
    return [TGPresentationPallete hasWallpaper] ? [super chatActionIconColor] : [self accentColor];
}

- (UIColor *)chatActionBorderColor
{
    return [TGPresentationPallete hasWallpaper] ? [super chatActionBorderColor] : UIColorRGB(0xe5e5ea);
}

- (UIColor *)chatReplyButtonBackgroundColor
{
    return [TGPresentationPallete hasWallpaper] ? [super chatReplyButtonBackgroundColor] : UIColorRGBA(0xffffff, 0.8f);
}

- (UIColor *)chatReplyButtonHighlightedBackgroundColor
{
    return [TGPresentationPallete hasWallpaper] ? [super chatReplyButtonHighlightedBackgroundColor] : UIColorRGBA(0xffffff, 0.6f);
}

- (UIColor *)chatReplyButtonBorderColor
{
    return [TGPresentationPallete hasWallpaper] ? [super chatReplyButtonBorderColor] : [self chatIncomingAccentColor];
}

- (UIColor *)chatReplyButtonHighlightedBorderColor
{
    return [TGPresentationPallete hasWallpaper] ? [super chatReplyButtonHighlightedBorderColor] : [[self chatReplyButtonBorderColor] colorWithAlphaComponent:0.5f];
}

- (UIColor *)chatReplyButtonIconColor
{
    return [TGPresentationPallete hasWallpaper] ? [super chatReplyButtonIconColor] : [self chatIncomingAccentColor];
}

- (UIColor *)chatImageBorderColor
{
    return [UIColor whiteColor];
}

- (UIColor *)chatImageBorderShadowColor
{
    return [UIColor whiteColor];
}

- (UIColor *)chatRoundMessageBackgroundColor
{
    return [self chatImageBorderColor];
}

- (UIColor *)chatRoundMessageBorderColor
{
    return [TGPresentationPallete hasWallpaper] ? [self chatIncomingBubbleBorderColor] : [self chatImageBorderColor];
}

- (UIColor *)chatChecksColor
{
    return [self chatOutgoingDateColor];
}

- (UIColor *)collectionMenuBadgeColor
{
    return [self accentColor];
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
    return [TGPresentationPallete hasWallpaper] ? [UIColor whiteColor] : UIColorRGB(0xdededf);
}

- (instancetype)initWithAccentColor:(UIColor *)accentColor
{
    self = [super init];
    if (self != nil)
    {
        if (accentColor == nil || [accentColor isEqual:[UIColor blackColor]])
            accentColor = UIColorRGB(0x007ee5);
        
        _accentColor = accentColor;
    }
    return self;
}

+ (instancetype)dayPalleteWithAccentColor:(UIColor *)accentColor
{
    return [[TGDayPresentationPallete alloc] initWithAccentColor:accentColor];
}

- (instancetype)init
{
    return [self initWithAccentColor:nil];
}

@end
