#import "TGTelegraphConversationMessageAssetsSource.h"

#import "TGImageUtils.h"
#import "TGInterfaceAssets.h"

#import "TGTelegraph.h"

#import "TGViewController.h"

#import "TGFont.h"

int TGBaseFontSize = 16;
static int defaultMonochromeColor = 0x000000;

static UIColor *colorWithFactor(UIColor *baseColor, CGFloat factor, CGFloat alphaFactor)
{
    CGFloat r = 0.0f, g = 0.0f, b = 0.0f, a = 0.0f;
    [baseColor getRed:&r green:&g blue:&b alpha:&a];
    return [UIColor colorWithRed:MIN(r * factor, 1.0f) green:MIN(g * factor, 1.0f) blue:MIN(b * factor, 1.0f) alpha:MIN(1.0f, a * alphaFactor)];
}

@implementation TGTelegraphConversationMessageAssetsSource

+ (TGTelegraphConversationMessageAssetsSource *)instance
{
    static TGTelegraphConversationMessageAssetsSource *singleton = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        singleton = [[TGTelegraphConversationMessageAssetsSource alloc] init];
    });
    
    return singleton;
}

- (int)currentUserId
{
    return TGTelegraphInstance.clientUserId;
}

- (CTFontRef)messageTextFont
{
    static CTFontRef font = nil;
    static int fontSize = 0;
    
    if (font == nil || fontSize != TGBaseFontSize)
    {
        if (font != nil)
            CFRelease(font);
        
        fontSize = TGBaseFontSize;
        if (iosMajorVersion() >= 7) {
            font = CTFontCreateWithFontDescriptor((__bridge CTFontDescriptorRef)[TGSystemFontOfSize(TGBaseFontSize) fontDescriptor], 0.0f, NULL);
        } else {
            UIFont *systemFont = TGSystemFontOfSize(TGBaseFontSize);
            font = CTFontCreateWithName((__bridge CFStringRef)systemFont.fontName, systemFont.pointSize, nil);
        }
    }
    
    return font;
}

- (CTFontRef)messageActionTitleFont
{
    static CTFontRef font = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        if (iosMajorVersion() >= 7) {
            font = CTFontCreateWithFontDescriptor((__bridge CTFontDescriptorRef)[TGSystemFontOfSize(13.0f) fontDescriptor], 0.0f, NULL);
        } else {
            UIFont *systemFont = TGSystemFontOfSize(13.0f);
            font = CTFontCreateWithName((__bridge CFStringRef)systemFont.fontName, systemFont.pointSize, nil);
        }
    });
    
    return font;
}

- (CTFontRef)messageActionTitleBoldFont
{
    static CTFontRef font = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        if (iosMajorVersion() >= 7) {
            font = CTFontCreateWithFontDescriptor((__bridge CTFontDescriptorRef)[TGBoldSystemFontOfSize(13.0f) fontDescriptor], 0.0f, NULL);
        } else {
            UIFont *systemFont = TGMediumSystemFontOfSize(13.0f);
            font = CTFontCreateWithName((__bridge CFStringRef)systemFont.fontName, systemFont.pointSize, nil);
        }
    });
    
    return font;
}

- (CTFontRef)messageMediaLabelsFont
{
    static CTFontRef font = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        if (iosMajorVersion() >= 7) {
            font = CTFontCreateWithFontDescriptor((__bridge CTFontDescriptorRef)[TGSystemFontOfSize(12.0f) fontDescriptor], 0.0f, NULL);
        } else {
            UIFont *systemFont = TGSystemFontOfSize(12.0f);
            font = CTFontCreateWithName((__bridge CFStringRef)systemFont.fontName, systemFont.pointSize, nil);
        }
    });
    
    return font;
}

- (CTFontRef)messageRequestActionFont
{
    static CTFontRef font = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        if (iosMajorVersion() >= 7) {
            font = CTFontCreateWithFontDescriptor((__bridge CTFontDescriptorRef)[TGSystemFontOfSize(13.0f) fontDescriptor], 0.0f, NULL);
        } else {
            UIFont *systemFont = TGSystemFontOfSize(13.0f);
            font = CTFontCreateWithName((__bridge CFStringRef)systemFont.fontName, systemFont.pointSize, nil);
        }
    });
    
    return font;
}

- (CTFontRef)messagerequestActorBoldFont
{
    static CTFontRef font = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        if (iosMajorVersion() >= 7) {
            font = CTFontCreateWithFontDescriptor((__bridge CTFontDescriptorRef)[TGSystemFontOfSize(13.0f) fontDescriptor], 0.0f, NULL);
        } else {
            UIFont *systemFont = TGSystemFontOfSize(13.0f);
            font = CTFontCreateWithName((__bridge CFStringRef)systemFont.fontName, systemFont.pointSize, nil);
        }
    });
    
    return font;
}

- (CTFontRef)messageForwardTitleFont
{
    static CTFontRef font = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        if (iosMajorVersion() >= 7) {
            font = CTFontCreateWithFontDescriptor((__bridge CTFontDescriptorRef)[TGSystemFontOfSize(13.0f) fontDescriptor], 0.0f, NULL);
        } else {
            UIFont *systemFont = TGSystemFontOfSize(13.0f);
            font = CTFontCreateWithName((__bridge CFStringRef)systemFont.fontName, systemFont.pointSize, nil);
        }
    });
    
    return font;
}

- (CTFontRef)messageForwardNameFont
{
    static CTFontRef font = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        if (iosMajorVersion() >= 7) {
            font = CTFontCreateWithFontDescriptor((__bridge CTFontDescriptorRef)[TGMediumSystemFontOfSize(13.0f) fontDescriptor], 0.0f, NULL);
        } else {
            UIFont *systemFont = TGMediumSystemFontOfSize(13.0f);
            font = CTFontCreateWithName((__bridge CFStringRef)systemFont.fontName, systemFont.pointSize, nil);
        }
    });
    
    return font;
}

- (CTFontRef)messageForwardPhoneNameFont
{
    static CTFontRef font = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        if (iosMajorVersion() >= 7) {
            font = CTFontCreateWithFontDescriptor((__bridge CTFontDescriptorRef)[TGSystemFontOfSize(14.0f) fontDescriptor], 0.0f, NULL);
        } else {
            UIFont *systemFont = TGSystemFontOfSize(14.0f);
            font = CTFontCreateWithName((__bridge CFStringRef)systemFont.fontName, systemFont.pointSize, nil);
        }
    });
    
    return font;
}

- (CTFontRef)messageForwardPhoneFont
{
    return [self messageTextFont];
}

- (UIFont *)messageLineAttachmentTitleFont
{
    static UIFont *font = nil;
    if (font == nil)
        font = [UIFont boldSystemFontOfSize:15];
    return font;
}

- (UIFont *)messageLineAttachmentSubtitleFont
{
    static UIFont *font = nil;
    if (font == nil)
        font = [UIFont systemFontOfSize:15];
    return font;
}

- (UIFont *)messageDocumentLabelFont
{
    static UIFont *font = nil;
    if (font == nil)
        font = [UIFont systemFontOfSize:10];
    return font;
}
- (UIFont *)messageForwardedUserFont
{
    static UIFont *font = nil;
    if (font == nil)
        font = [UIFont boldSystemFontOfSize:13];
    return font;
}


- (UIFont *)messageForwardedDateFont
{
    static UIFont *font = nil;
    if (font == nil)
        font = [UIFont systemFontOfSize:10];
    return font;
}

- (UIColor *)messageTextColor
{
    static UIColor *color = nil;
    if (color == nil)
        color = [UIColor colorWithRed:(20.0f / 255.0f) green:(22.0f / 255.0f) blue:(23.0f / 255.0f) alpha:1.0f];
    return color;
}

- (UIColor *)messageTextShadowColor
{
    return nil;
    
    /*static UIColor *color = nil;
    if (color == nil)
        color = UIColorRGBA(0xffffff, 0.5f);
    return color;*/
}

- (UIColor *)messageLineAttachmentTitleColor
{
    static UIColor *color = nil;
    if (color == nil)
        color = UIColorRGB(0x62768a);
    return color;
}

- (UIColor *)messageLineAttachmentSubitleColor
{
    static UIColor *color = nil;
    if (color == nil)
        color = UIColorRGB(0x72879b);
    return color;
}

- (UIColor *)messageDocumentLabelColor
{
    static UIColor *color = nil;
    if (color == nil)
        color = UIColorRGB(0xffffff);
    return color;
}

- (UIColor *)messageDocumentLabelShadowColor
{
    static UIColor *color = nil;
    if (color == nil)
        color = UIColorRGB(0x111111);
    return color;
}

- (UIColor *)messageForwardedUserColor
{
    static UIColor *color = nil;
    if (color == nil)
        color = [UIColor colorWithRed:(20.0f / 255.0f) green:(22.0f / 255.0f) blue:(23.0f / 255.0f) alpha:1.0f];
    return color;
}

- (UIColor *)messageForwardedDateColor
{
    static UIColor *color = nil;
    if (color == nil)
        color = UIColorRGB(0x999999);
    return color;
}

- (UIColor *)messageForwardTitleColorIncoming
{
    static UIColor *color = nil;
    if (color == nil)
        color = UIColorRGB(0x0e7acd);
    return color;
}

- (UIColor *)messageForwardTitleColorOutgoing
{
    static UIColor *color = nil;
    if (color == nil)
        color = UIColorRGB(0x3a8e26);
    return color;
}

- (UIColor *)messageForwardNameColorIncoming
{
    static UIColor *color = nil;
    if (color == nil)
        color = UIColorRGB(0x0e7acd);
    return color;
}

- (UIColor *)messageForwardNameColorOutgoing
{
    static UIColor *color = nil;
    if (color == nil)
        color = UIColorRGB(0x169600);
    return color;
}

- (UIColor *)messageForwardPhoneColor
{
    static UIColor *color = nil;
    if (color == nil)
        color = UIColorRGB(010101);
    return color;
}

- (UIImage *)messageInlineGenericAvatarPlaceholder
{
    return [UIImage imageNamed:@"InlineAvatarPlaceholder.png"];
}

- (UIImage *)messageInlineAvatarPlaceholder:(int)uid
{
    return [[TGInterfaceAssets instance] smallAvatarPlaceholder:uid];
}

- (UIColor *)messageActionTextColor
{
    static UIColor *color = nil;
    if (color == nil)
        color = [UIColor whiteColor];
    return color;
}

- (UIColor *)messageActionShadowColor
{
    return nil;
    
    /*if (_monochromeColor != -1)
    {
        static UIColor *color = nil;
        if (color == nil)
            color = UIColorRGBA(_monochromeColor, 0.15f);
        return color;
    }
    else
    {
        static UIColor *color = nil;
        if (color == nil)
            color = UIColorRGBA(0x5e7590, 0.2f);
        return color;
    }*/
}

- (UIImage *)messageVideoIcon
{
    return [UIImage imageNamed:@"MessageInlineVideoIcon.png"];
}

- (CTFontRef)messageAuthorNameFont
{
    static CTFontRef font = nil;
    if (font == nil)
    {
        if (iosMajorVersion() >= 7) {
            font = CTFontCreateWithFontDescriptor((__bridge CTFontDescriptorRef)[TGSystemFontOfSize(14.0f) fontDescriptor], 0.0f, NULL);
        } else {
            UIFont *systemFont = TGSystemFontOfSize(14.0f);
            font = CTFontCreateWithName((__bridge CFStringRef)systemFont.fontName, systemFont.pointSize, nil);
        }
    }
    return font;
}

- (UIFont *)messageAuthorNameUIFont
{
    static UIFont *font = nil;
    if (font == nil)
        font = [UIFont boldSystemFontOfSize:13];
    return font;
}

- (UIColor *)messageAuthorNameColor
{
    static UIColor *color = nil;
    if (color == nil)
        color = UIColorRGB(0x4d688c);
    return color;
}

- (UIColor *)messageAuthorNameShadowColor
{
    return nil;
    
    /*static UIColor *color = nil;
    if (color == nil)
        color = UIColorRGBA(0xffffff, 0.5f);
    return color;*/
}

- (UIImage *)messageChecked
{
    static UIImage *image = nil;
    if (image == nil)
        image = [UIImage imageNamed:@"MessagesChecked.png"];
    return image;
}

- (UIImage *)messageUnchecked
{
    static UIImage *image = nil;
    if (image == nil)
        image = [UIImage imageNamed:@"MessagesUnchecked.png"];
    return image;
}

- (UIImage *)messageEditingSeparator
{
    static UIImage *image = nil;
    if (image == nil)
        image = [UIImage imageNamed:@"MessagesEditingSeparator.png"];
    return image;
}

static UIImage *generateProgressBackground(int baseColor, CGFloat alphaFactor, CGFloat colorFactor)
{
    TGLog(@"Generating progress background");
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(6, 6), false, 0.0f);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGRect bounds = CGRectMake(0, 0, 6, 6);
    
    CGFloat radius = CGFloor(bounds.size.height / 2.0f);
    
    CGMutablePathRef visiblePath = CGPathCreateMutable();
    CGRect innerRect = CGRectInset(bounds, radius, radius);
    CGPathMoveToPoint(visiblePath, NULL, innerRect.origin.x, bounds.origin.y);
    CGPathAddLineToPoint(visiblePath, NULL, innerRect.origin.x + innerRect.size.width, bounds.origin.y);
    CGPathAddArcToPoint(visiblePath, NULL, bounds.origin.x + bounds.size.width, bounds.origin.y, bounds.origin.x + bounds.size.width, innerRect.origin.y, radius);
    CGPathAddLineToPoint(visiblePath, NULL, bounds.origin.x + bounds.size.width, innerRect.origin.y + innerRect.size.height);
    CGPathAddArcToPoint(visiblePath, NULL,  bounds.origin.x + bounds.size.width, bounds.origin.y + bounds.size.height, innerRect.origin.x + innerRect.size.width, bounds.origin.y + bounds.size.height, radius);
    CGPathAddLineToPoint(visiblePath, NULL, innerRect.origin.x, bounds.origin.y + bounds.size.height);
    CGPathAddArcToPoint(visiblePath, NULL,  bounds.origin.x, bounds.origin.y + bounds.size.height, bounds.origin.x, innerRect.origin.y + innerRect.size.height, radius);
    CGPathAddLineToPoint(visiblePath, NULL, bounds.origin.x, innerRect.origin.y);
    CGPathAddArcToPoint(visiblePath, NULL,  bounds.origin.x, bounds.origin.y, innerRect.origin.x, bounds.origin.y, radius);
    CGPathCloseSubpath(visiblePath);
    
    CGContextSetFillColorWithColor(context, colorWithFactor(UIColorRGBA(baseColor, 1.0f), colorFactor, alphaFactor).CGColor);
    CGContextAddPath(context, visiblePath);
    CGContextFillPath(context);
    
    CGPathRelease(visiblePath);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (UIImage *)messageProgressBackground
{
    static UIImage *cachedImage = nil;
    static int cachedColor = -1;
    
    int requestedColor = _monochromeColor == -1 ? defaultMonochromeColor : _monochromeColor;
    if (requestedColor != cachedColor)
    {
        cachedColor = requestedColor;
        UIImage *rawImage = generateProgressBackground(requestedColor, _progressAlpha, 1.0f);
        cachedImage = [rawImage stretchableImageWithLeftCapWidth:(int)(rawImage.size.width / 2) topCapHeight:0];
    }
    
    return cachedImage;
}

static UIImage *generateProgressForeground(int baseColor, float alphaFactor, float colorFactor)
{
    TGLog(@"Generating progress foreground");
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(8, 6), false, 0.0f);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGRect bounds = CGRectMake(1, 1, 6, 4);
    
    CGFloat radius = CGFloor(bounds.size.height / 2.0f);
    
    CGMutablePathRef visiblePath = CGPathCreateMutable();
    CGRect innerRect = CGRectInset(bounds, radius, radius);
    CGPathMoveToPoint(visiblePath, NULL, innerRect.origin.x, bounds.origin.y);
    CGPathAddLineToPoint(visiblePath, NULL, innerRect.origin.x + innerRect.size.width, bounds.origin.y);
    CGPathAddArcToPoint(visiblePath, NULL, bounds.origin.x + bounds.size.width, bounds.origin.y, bounds.origin.x + bounds.size.width, innerRect.origin.y, radius);
    CGPathAddLineToPoint(visiblePath, NULL, bounds.origin.x + bounds.size.width, innerRect.origin.y + innerRect.size.height);
    CGPathAddArcToPoint(visiblePath, NULL,  bounds.origin.x + bounds.size.width, bounds.origin.y + bounds.size.height, innerRect.origin.x + innerRect.size.width, bounds.origin.y + bounds.size.height, radius);
    CGPathAddLineToPoint(visiblePath, NULL, innerRect.origin.x, bounds.origin.y + bounds.size.height);
    CGPathAddArcToPoint(visiblePath, NULL,  bounds.origin.x, bounds.origin.y + bounds.size.height, bounds.origin.x, innerRect.origin.y + innerRect.size.height, radius);
    CGPathAddLineToPoint(visiblePath, NULL, bounds.origin.x, innerRect.origin.y);
    CGPathAddArcToPoint(visiblePath, NULL,  bounds.origin.x, bounds.origin.y, innerRect.origin.x, bounds.origin.y, radius);
    CGPathCloseSubpath(visiblePath);
    
    CGContextSetFillColorWithColor(context, colorWithFactor(UIColorRGBA(baseColor, 1.0f), colorFactor, alphaFactor).CGColor);
    CGContextAddPath(context, visiblePath);
    CGContextFillPath(context);
    
    CGPathRelease(visiblePath);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (UIImage *)messageProgressForeground
{
    static UIImage *cachedImage = nil;
    
    if (cachedImage == nil)
    {
        UIImage *rawImage = generateProgressForeground(0xffffff, 1.0f, 1.0f);
        cachedImage = [rawImage stretchableImageWithLeftCapWidth:(int)(rawImage.size.width / 2) topCapHeight:0];
    }
    
    return cachedImage;
}

static UIImage *generateInlineCancelButton(int baseColor, CGFloat alphaFactor, CGFloat colorFactor)
{
    TGLog(@"Generating inline cancel button variant");
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(20, 20), false, 0.0f);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGRect bounds = CGRectMake(0, 0, 20, 20);
    
    CGFloat radius = CGFloor(bounds.size.height / 2.0f);
    
    CGContextSaveGState(context);
    
    CGMutablePathRef visiblePath = CGPathCreateMutable();
    CGRect innerRect = CGRectInset(bounds, radius, radius);
    CGPathMoveToPoint(visiblePath, NULL, innerRect.origin.x, bounds.origin.y);
    CGPathAddLineToPoint(visiblePath, NULL, innerRect.origin.x + innerRect.size.width, bounds.origin.y);
    CGPathAddArcToPoint(visiblePath, NULL, bounds.origin.x + bounds.size.width, bounds.origin.y, bounds.origin.x + bounds.size.width, innerRect.origin.y, radius);
    CGPathAddLineToPoint(visiblePath, NULL, bounds.origin.x + bounds.size.width, innerRect.origin.y + innerRect.size.height);
    CGPathAddArcToPoint(visiblePath, NULL,  bounds.origin.x + bounds.size.width, bounds.origin.y + bounds.size.height, innerRect.origin.x + innerRect.size.width, bounds.origin.y + bounds.size.height, radius);
    CGPathAddLineToPoint(visiblePath, NULL, innerRect.origin.x, bounds.origin.y + bounds.size.height);
    CGPathAddArcToPoint(visiblePath, NULL,  bounds.origin.x, bounds.origin.y + bounds.size.height, bounds.origin.x, innerRect.origin.y + innerRect.size.height, radius);
    CGPathAddLineToPoint(visiblePath, NULL, bounds.origin.x, innerRect.origin.y);
    CGPathAddArcToPoint(visiblePath, NULL,  bounds.origin.x, bounds.origin.y, innerRect.origin.x, bounds.origin.y, radius);
    CGPathCloseSubpath(visiblePath);
    
    CGContextSetFillColorWithColor(context, colorWithFactor(UIColorRGBA(baseColor, 1.0f), colorFactor, alphaFactor).CGColor);
    CGContextAddPath(context, visiblePath);
    CGContextFillPath(context);
    
    CGPathRelease(visiblePath);
    
    CGContextRestoreGState(context);
    
    CGContextTranslateCTM(context, 10, 10);
    CGContextRotateCTM(context, (float)M_PI_4);
    CGContextTranslateCTM(context, -10, -10);
    
    float height = 11;
    
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextFillRect(context, CGRectMake(9.25f, (20 - height) / 2.0f, 1.5f, height));
    CGContextFillRect(context, CGRectMake((20 - height) / 2.0f, 9.25f, height, 1.5f));
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (UIImage *)messageProgressCancelButton
{
    static UIImage *cachedImage = nil;
    static int cachedColor = -1;
    
    int requestedColor = _monochromeColor == -1 ? defaultMonochromeColor : _monochromeColor;
    
    if (cachedColor != requestedColor)
    {
        cachedImage = generateInlineCancelButton(requestedColor, _buttonsAlpha, 1.0f);
        cachedColor = requestedColor;
    }
    
    return cachedImage;
}

- (UIImage *)messageProgressCancelButtonHighlighted
{
    static UIImage *cachedImage = nil;
    static int cachedColor = -1;
    
    int requestedColor = _monochromeColor == -1 ? defaultMonochromeColor : _monochromeColor;
    
    if (cachedColor != requestedColor)
    {
        cachedImage = generateInlineCancelButton(requestedColor, _highlighteButtonAlpha, 0.9f);
        cachedColor = requestedColor;
    }
    
    return cachedImage;
}

static UIImage *generateDownloadButton(int baseColor, CGFloat alphaFactor, CGFloat colorFactor)
{
    TGLog(@"Generating download button variant");
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(29, 29), false, 0.0f);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGRect bounds = CGRectMake(0, 0, 29, 29);
    
    CGFloat radius = CGFloor(bounds.size.height / 2.0f);
    
    CGMutablePathRef visiblePath = CGPathCreateMutable();
    CGRect innerRect = CGRectInset(bounds, radius, radius);
    CGPathMoveToPoint(visiblePath, NULL, innerRect.origin.x, bounds.origin.y);
    CGPathAddLineToPoint(visiblePath, NULL, innerRect.origin.x + innerRect.size.width, bounds.origin.y);
    CGPathAddArcToPoint(visiblePath, NULL, bounds.origin.x + bounds.size.width, bounds.origin.y, bounds.origin.x + bounds.size.width, innerRect.origin.y, radius);
    CGPathAddLineToPoint(visiblePath, NULL, bounds.origin.x + bounds.size.width, innerRect.origin.y + innerRect.size.height);
    CGPathAddArcToPoint(visiblePath, NULL,  bounds.origin.x + bounds.size.width, bounds.origin.y + bounds.size.height, innerRect.origin.x + innerRect.size.width, bounds.origin.y + bounds.size.height, radius);
    CGPathAddLineToPoint(visiblePath, NULL, innerRect.origin.x, bounds.origin.y + bounds.size.height);
    CGPathAddArcToPoint(visiblePath, NULL,  bounds.origin.x, bounds.origin.y + bounds.size.height, bounds.origin.x, innerRect.origin.y + innerRect.size.height, radius);
    CGPathAddLineToPoint(visiblePath, NULL, bounds.origin.x, innerRect.origin.y);
    CGPathAddArcToPoint(visiblePath, NULL,  bounds.origin.x, bounds.origin.y, innerRect.origin.x, bounds.origin.y, radius);
    CGPathCloseSubpath(visiblePath);
    
    CGContextSetFillColorWithColor(context, colorWithFactor(UIColorRGBA(baseColor, 1.0f), colorFactor, alphaFactor).CGColor);
    CGContextAddPath(context, visiblePath);
    CGContextFillPath(context);
    
    CGPathRelease(visiblePath);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (UIImage *)messageDownloadButton
{
    static UIImage *image = nil;
    static int cachedColor = -1;
    
    int requestedColor = _monochromeColor == -1 ? defaultMonochromeColor : _monochromeColor;
    if (cachedColor != requestedColor || image == nil)
    {
        cachedColor = requestedColor;
        UIImage *rawImage = generateDownloadButton(requestedColor, _buttonsAlpha, 1.0f);
        image = [rawImage stretchableImageWithLeftCapWidth:(int)(rawImage.size.width / 2) topCapHeight:0];
    }
    
    return image;
}

- (UIImage *)messageDownloadButtonHighlighted
{
    static UIImage *image = nil;
    static int cachedColor = -1;
    
    int requestedColor = _monochromeColor == -1 ? defaultMonochromeColor : _monochromeColor;
    if (cachedColor != requestedColor || image == nil)
    {
        cachedColor = requestedColor;
        UIImage *rawImage = generateDownloadButton(requestedColor, _highlighteButtonAlpha, 1.0f);
        image = [rawImage stretchableImageWithLeftCapWidth:(int)(rawImage.size.width / 2) topCapHeight:0];
    }
    
    return image;
}

- (UIImage *)messageBackgroundBubbleIncomingSingle
{
    static UIImage *image = nil;
    if (image == nil)
        image = [[UIImage imageNamed:@"Msg_In.png"] stretchableImageWithLeftCapWidth:20 topCapHeight:15];
    return image;
}

- (UIImage *)messageBackgroundBubbleIncomingDouble
{
    static UIImage *image = nil;
    if (image == nil)
    {
        UIImage *rawImage = [UIImage imageNamed:@"Msg_In_High.png"];
        if ([rawImage respondsToSelector:@selector(resizableImageWithCapInsets:resizingMode:)])
        {
            image = [rawImage resizableImageWithCapInsets:UIEdgeInsetsMake(15, 23, 15, rawImage.size.width - 23 - 1) resizingMode:UIImageResizingModeStretch];
        }
        else
        {
            image = rawImage;
            //image = [self messageBackgroundBubbleIncomingSingle];
        }
    }
    return image;
}

- (UIImage *)messageBackgroundBubbleIncomingHighlighted
{
    static UIImage *image = nil;
    if (image == nil)
    {
        UIImage *rawImage = [UIImage imageNamed:@"Msg_In_Selected.png"];
        image = [rawImage stretchableImageWithLeftCapWidth:20 topCapHeight:15];
    }
    return image;
}
    
- (UIImage *)messageBackgroundBubbleIncomingHighlightedShadow
{
    static UIImage *image = nil;
    if (image == nil)
    {
        UIImage *rawImage = [UIImage imageNamed:@"Msg_In_Selected_Shadow.png"];
        image = [rawImage stretchableImageWithLeftCapWidth:20 topCapHeight:15];
    }
    return image;
}

- (UIImage *)messageBackgroundBubbleIncomingDoubleHighlighted
{
    static UIImage *image = nil;
    if (image == nil)
    {
        UIImage *rawImage = [UIImage imageNamed:@"Msg_In_High_Selected.png"];
        if ([rawImage respondsToSelector:@selector(resizableImageWithCapInsets:resizingMode:)])
        {
            image = [rawImage resizableImageWithCapInsets:UIEdgeInsetsMake(15, 23, 15, rawImage.size.width - 23 - 1) resizingMode:UIImageResizingModeStretch];
        }
        else
        {
            image = rawImage;
            //image = [self messageBackgroundBubbleIncomingSingle];
        }
    }
    return image;
}

- (UIImage *)messageBackgroundBubbleOutgoingSingle
{
    static UIImage *image = nil;
    if (image == nil)
    {
        image = [[UIImage imageNamed:@"Msg_Out.png"] stretchableImageWithLeftCapWidth:15 topCapHeight:15];
    }
    return image;
}

- (UIImage *)messageBackgroundBubbleOutgoingDouble
{
    static UIImage *image = nil;
    if (image == nil)
    {
        UIImage *rawImage = [UIImage imageNamed:@"Msg_Out_High.png"];
        if ([rawImage respondsToSelector:@selector(resizableImageWithCapInsets:resizingMode:)])
        {
            image = [rawImage resizableImageWithCapInsets:UIEdgeInsetsMake(15, 17, 15, rawImage.size.width - 17 - 1) resizingMode:UIImageResizingModeStretch];
        }
        else
        {
            image = rawImage;
            //image = [self messageBackgroundBubbleOutgoingSingle];
        }
    }
    return image;
}

- (UIImage *)messageBackgroundBubbleOutgoingHighlighted
{
    static UIImage *image = nil;
    if (image == nil)
    {
        UIImage *rawImage = [UIImage imageNamed:@"Msg_Out_Selected.png"];
        //if ([rawImage respondsToSelector:@selector(resizableImageWithCapInsets:resizingMode:)])
        //    image = [rawImage resizableImageWithCapInsets:UIEdgeInsetsMake(14, 16, 15, rawImage.size.width - 16) resizingMode:UIImageResizingModeStretch];
        //else
            image = [rawImage stretchableImageWithLeftCapWidth:15 topCapHeight:15];
    }
    return image;
}
    
- (UIImage *)messageBackgroundBubbleOutgoingHighlightedShadow
{
    static UIImage *image = nil;
    if (image == nil)
    {
        UIImage *rawImage = [UIImage imageNamed:@"Msg_Out_Selected_Shadow.png"];
        image = [rawImage stretchableImageWithLeftCapWidth:15 topCapHeight:15];
    }
    return image;
}

- (UIImage *)messageBackgroundBubbleOutgoingDoubleHighlighted
{
    static UIImage *image = nil;
    if (image == nil)
    {
        UIImage *rawImage = [UIImage imageNamed:@"Msg_Out_High_Selected.png"];
        if ([rawImage respondsToSelector:@selector(resizableImageWithCapInsets:resizingMode:)])
        {
            image = [rawImage resizableImageWithCapInsets:UIEdgeInsetsMake(15, 17, 15, rawImage.size.width - 17 - 1) resizingMode:UIImageResizingModeStretch];
        }
        else
        {
            image = rawImage;
            //image = [self messageBackgroundBubbleOutgoingSingle];
        }
    }
    return image;
}

- (UIImage *)messageDateBadgeOutgoing
{
    static UIImage *image = nil;
    if (image == nil)
    {
        UIImage *rawImage = [UIImage imageNamed:@"MessageTimestampBackground.png"];
        image = [rawImage stretchableImageWithLeftCapWidth:(int)(rawImage.size.width / 2) topCapHeight:0];
    }
    return image;
}

- (UIImage *)messageDateBadgeIncoming
{
    static UIImage *image = nil;
    if (image == nil)
    {
        UIImage *rawImage = [UIImage imageNamed:@"MessageTimestampBackgroundIncoming.png"];
        image = [rawImage stretchableImageWithLeftCapWidth:(int)(rawImage.size.width / 2) topCapHeight:0];
    }
    return image;
}

- (UIImage *)messageDocumentLabelBackground
{
    static UIImage *image = nil;
    if (image == nil)
        image = [[UIImage imageNamed:@"DocumentLabelBg.png"] stretchableImageWithLeftCapWidth:8 topCapHeight:1];
    return image;
}

- (UIImage *)messageForwardedStripe
{
    static UIImage *image = nil;
    if (image == nil)
        image = [[UIImage imageNamed:@"AttachedMessageBackground.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:5];
    return image;
}

- (UIImage *)messageCheckmarkFullIcon
{
    static UIImage *image = nil;
    if (image == nil)
        image = [UIImage imageNamed:@"MessageCheckFull.png"];
    return image;
}

- (UIImage *)messageCheckmarkHalfIcon
{
    static UIImage *image = nil;
    if (image == nil)
        image = [UIImage imageNamed:@"MessageCheckHalf.png"];
    return image;
}

- (UIImage *)messageNotSentIcon
{
    static UIImage *image = nil;
    if (image == nil)
        image = [UIImage imageNamed:@"NotSent.png"];
    return image;
}

- (UIColor *)messageBackgroundColorNormal
{
    static UIColor *color = nil;
    if (color == nil)
        color = [UIColor clearColor];
    return color;
}

- (UIColor *)messageBackgroundColorUnread
{
    static UIColor *color = nil;
    if (color == nil)
        color = UIColorRGBA(0x003871, 0.07f);
    return color;
}

- (UIFont *)messageDateFont
{
    static UIFont *font = nil;
    if (font == nil)
        font = [UIFont systemFontOfSize:11.0f];
    return font;
}

- (UIFont *)messageDateAMPMFont
{
    static UIFont *font = nil;
    if (font == nil)
        font = [UIFont systemFontOfSize:9.0f];
    return font;
}

- (UIColor *)messageDateColor
{
    static UIColor *color = nil;
    if (color == nil)
        color = UIColorRGB(0x232d37);
    return color;
}

- (UIColor *)messageDateShadowColor
{
    return nil;
}

- (UIImage *)messageLinkFull
{
    static UIImage *image = nil;
    if (image == nil)
    {
        UIImage *rawImage = [UIImage imageNamed:@"LinkFull.png"];
        image = [rawImage stretchableImageWithLeftCapWidth:(int)(rawImage.size.width / 2) topCapHeight:(int)(rawImage.size.height / 2)];
    }
    return image;
}

- (UIImage *)messageLinkCornerTB
{
    static UIImage *image = nil;
    if (image == nil)
    {
        image = [UIImage imageNamed:@"LinkCornerTB.png"];
    }
    return image;
}

- (UIImage *)messageLinkCornerBT
{
    static UIImage *image = nil;
    if (image == nil)
    {
        image = [UIImage imageNamed:@"LinkCornerBT.png"];
    }
    return image;
}

- (UIImage *)messageLinkCornerLR
{
    static UIImage *image = nil;
    if (image == nil)
    {
        image = [UIImage imageNamed:@"LinkCornerLR.png"];
    }
    return image;
}

- (UIImage *)messageLinkCornerRL
{
    static UIImage *image = nil;
    if (image == nil)
    {
        image = [UIImage imageNamed:@"LinkCornerRL.png"];
    }
    return image;
}

- (UIImage *)messageAvatarPlaceholder:(int)uid
{
    return [TGInterfaceAssets conversationAvatarPlaceholder:uid];
}

- (UIImage *)messageGenericAvatarPlaceholder
{
    return [TGInterfaceAssets conversationGenericAvatarPlaceholder:_monochromeColor != -1];
}

- (UIImage *)messageAttachmentImagePlaceholderIncoming
{
    return [self messageAttachmentImagePlaceholderOutgoing];
}

- (UIImage *)messageAttachmentImagePlaceholderOutgoing
{
    static UIImage *image = nil;
    if (image == nil)
    {
        UIImage *rawImage = [UIImage imageNamed:@"AttachmentPhotoBubblePlaceholder.png"];
        image = [rawImage stretchableImageWithLeftCapWidth:(int)(rawImage.size.width / 2) topCapHeight:(int)(rawImage.size.height / 2)];
    }
    return image;
}

- (UIImage *)messageAttachmentImageIncomingTopCorners
{
    static UIImage *image = nil;
    if (image == nil)
    {
        UIImage *rawImage = [UIImage imageNamed:@"AttachmentCornersIncomingTop.png"];
        image = [rawImage stretchableImageWithLeftCapWidth:(int)(rawImage.size.width / 2) topCapHeight:0];
    }
    return image;
}

- (UIImage *)messageAttachmentImageIncomingTopCornersHighlighted
{
    static UIImage *image = nil;
    if (image == nil)
    {
        UIImage *rawImage = [UIImage imageNamed:@"AttachmentCornersIncomingTop_Highlighted.png"];
        image = [rawImage stretchableImageWithLeftCapWidth:(int)(rawImage.size.width / 2) topCapHeight:0];
    }
    return image;
}

- (UIImage *)messageAttachmentImageIncomingBottomCorners
{
    static UIImage *image = nil;
    if (image == nil)
    {
        UIImage *rawImage = [UIImage imageNamed:@"AttachmentCornersIncomingBottom.png"];
        image = [rawImage stretchableImageWithLeftCapWidth:(int)(rawImage.size.width / 2) topCapHeight:0];
    }
    return image;
}

- (UIImage *)messageAttachmentImageIncomingBottomCornersHighlighted
{
    static UIImage *image = nil;
    if (image == nil)
    {
        UIImage *rawImage = [UIImage imageNamed:@"AttachmentCornersIncomingBottom_Highlighted.png"];
        image = [rawImage stretchableImageWithLeftCapWidth:(int)(rawImage.size.width / 2) topCapHeight:0];
    }
    return image;
}

- (UIImage *)messageAttachmentImageOutgoingTopCorners
{
    static UIImage *image = nil;
    if (image == nil)
    {
        UIImage *rawImage = [UIImage imageNamed:@"AttachmentCornersOutgoingTop.png"];
        image = [rawImage stretchableImageWithLeftCapWidth:(int)(rawImage.size.width / 2) topCapHeight:0];
    }
    return image;
}

- (UIImage *)messageAttachmentImageOutgoingTopCornersHighlighted
{
    static UIImage *image = nil;
    if (image == nil)
    {
        UIImage *rawImage = [UIImage imageNamed:@"AttachmentCornersIncomingTop_Highlighted.png"];
        image = [rawImage stretchableImageWithLeftCapWidth:(int)(rawImage.size.width / 2) topCapHeight:0];
    }
    return image;
}

- (UIImage *)messageAttachmentImageOutgoingBottomCorners
{
    static UIImage *image = nil;
    if (image == nil)
    {
        UIImage *rawImage = [UIImage imageNamed:@"AttachmentCornersOutgoingBottom.png"];
        image = [rawImage stretchableImageWithLeftCapWidth:(int)(rawImage.size.width / 2) topCapHeight:0];
    }
    return image;
}

- (UIImage *)messageAttachmentImageOutgoingBottomCornersHighlighted
{
    static UIImage *image = nil;
    if (image == nil)
    {
        UIImage *rawImage = [UIImage imageNamed:@"AttachmentCornersIncomingBottom_Highlighted.png"];
        image = [rawImage stretchableImageWithLeftCapWidth:(int)(rawImage.size.width / 2) topCapHeight:0];
    }
    return image;
}

- (UIImage *)messageAttachmentImageLoadingIcon
{
    static UIImage *image = nil;
    if (image == nil)
        image = [UIImage imageNamed:@"MediaInlineDownloadingIcon.png"];
    return image;
}

- (UIImage *)messageActionConversationPhotoPlaceholder
{
    if (_monochromeColor != -1)
    {
        static UIImage *image = nil;
        if (image == nil)
        {
            UIImage *rawImage = [UIImage imageNamed:@"ProfilePhotoPlaceholder_Mono.png"];
            image = [rawImage stretchableImageWithLeftCapWidth:(int)(rawImage.size.width / 2) topCapHeight:0];
        }
        return image;
    }
    else
        return [TGInterfaceAssets profileGroupAvatarPlaceholder];
    
    return nil;
}

- (UIImage *)systemMessageBackground
{
    static int cachedImageColor = -1;
    static UIImage *image = nil;
    if (cachedImageColor != _monochromeColor || image == nil)
    {
        TGLog(@"Generating system message background");
        
        UIImage *rawImage = [self generateSystemMessageBackground:_monochromeColor];
        image = [rawImage stretchableImageWithLeftCapWidth:(int)(rawImage.size.width / 2) topCapHeight:(int)(rawImage.size.height / 2)];
        
        cachedImageColor = _monochromeColor;
    }
    return image;
}

- (UIImage *)systemReplyBackground
{
    static int cachedImageColor = -1;
    static UIImage *image = nil;
    if (cachedImageColor != _monochromeColor || image == nil)
    {
        UIImage *rawImage = [self generateSystemReplyBackground:_monochromeColor];
        image = [rawImage stretchableImageWithLeftCapWidth:(int)(rawImage.size.width / 2) topCapHeight:(int)(rawImage.size.height / 2)];
        
        cachedImageColor = _monochromeColor;
    }
    return image;
}

- (UIColor *)systemMessageBackgroundColor
{
    return UIColorRGBA(_monochromeColor, _systemAlpha); //UIColorRGBA(0x000000, MIN(1.0f, 0.3f));
}

- (UIImage *)dateListMessageBackground
{
    static int cachedImageColor = -1;
    static UIImage *image = nil;
    if (cachedImageColor != _monochromeColor || image == nil)
    {
        TGLog(@"Generating system message background");
        
        UIImage *rawImage = [self generateSystemMessageBackground:_monochromeColor];
        image = [rawImage stretchableImageWithLeftCapWidth:(int)(rawImage.size.width / 2) topCapHeight:(int)(rawImage.size.height / 2)];
        
        cachedImageColor = _monochromeColor;
    }
    return image;
}

- (UIImage *)systemShareButton {
    static int cachedImageColor = -1;
    static UIImage *image = nil;
    if (cachedImageColor != _monochromeColor || image == nil)
    {
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(29.0f, 29.0f), false, 0.0f);
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGFloat backgroundAlpha = _systemAlpha;
        UIColor *color = UIColorRGBA(_monochromeColor, backgroundAlpha);
        
        CGContextSetFillColorWithColor(context, color.CGColor);
        CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, 29.0f, 29.0f));
        
        UIImage *iconImage = [UIImage imageNamed:@"ConversationChannelInlineShareIcon.png"];
        [iconImage drawAtPoint:CGPointMake(CGFloor((29.0f - iconImage.size.width) / 2.0f), CGFloor((29.0f - iconImage.size.height) / 2.0f))];
        
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        cachedImageColor = _monochromeColor;
    }
    return image;
}

- (UIImage *)systemSwipeReplyIcon
{
    static int cachedImageColor = -1;
    static UIImage *image = nil;
    if (cachedImageColor != _monochromeColor || image == nil)
    {
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(33.0f, 33.0f), false, 0.0f);
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGFloat backgroundAlpha = _systemAlpha;
        UIColor *color = UIColorRGBA(_monochromeColor, backgroundAlpha);
        
        CGContextSetFillColorWithColor(context, color.CGColor);
        CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, 33.0f, 33.0f));
        
        CGContextTranslateCTM(context, 33.0f, 0);
        CGContextScaleCTM(context, -1.0, 1.0);
        UIImage *iconImage = [UIImage imageNamed:@"ConversationChannelInlineShareIcon.png"];
        [iconImage drawAtPoint:CGPointMake(CGFloor((33.0f - iconImage.size.width) / 2.0f), CGFloor((33.0f - iconImage.size.height) / 2.0f))];
        
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        cachedImageColor = _monochromeColor;
    }
    return image;
}

- (UIImage *)systemUnmuteButton {
    static int cachedImageColor = -1;
    static UIImage *image = nil;
    if (cachedImageColor != _monochromeColor || image == nil)
    {
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(24.0f, 24.0f), false, 0.0f);
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        UIColor *color = UIColorRGBA(0x000000, 0.4f);
        
        CGContextSetFillColorWithColor(context, color.CGColor);
        CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, 24.0f, 24.0f));
        
        UIImage *iconImage = [UIImage imageNamed:@"VideoMessageMutedIcon.png"];
        [iconImage drawAtPoint:CGPointMake(CGFloor((24.0f - iconImage.size.width) / 2.0f), CGFloor((24.0f - iconImage.size.height) / 2.0f))];
        
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        cachedImageColor = _monochromeColor;
    }
    return image;
}

- (UIImage *)systemMuteButton {
    static int cachedImageColor = -1;
    static UIImage *image = nil;
    if (cachedImageColor != _monochromeColor || image == nil)
    {
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(24.0f, 24.0f), false, 0.0f);
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGFloat backgroundAlpha = _systemAlpha;
        UIColor *color = UIColorRGBA(_monochromeColor, backgroundAlpha);
        
        CGContextSetFillColorWithColor(context, color.CGColor);
        CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, 24.0f, 24.0f));
        
        UIImage *iconImage = [UIImage imageNamed:@"VideoMessageUnmutedIcon.png"];
        [iconImage drawAtPoint:CGPointMake(CGFloor((24.0f - iconImage.size.width) / 2.0f), CGFloor((24.0f - iconImage.size.height) / 2.0f))];
        
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        cachedImageColor = _monochromeColor;
    }
    return image;
}

- (UIImage *)systemReplyButton {
    static int cachedImageColor = -1;
    static UIImage *image = nil;
    if (cachedImageColor != _monochromeColor || image == nil)
    {
        CGFloat size = 14.0f;
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(size, size), false, 0.0f);
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGFloat backgroundAlpha = _systemAlpha;
        UIColor *color = UIColorRGBA(_monochromeColor, backgroundAlpha);
        
        CGContextSetFillColorWithColor(context, color.CGColor);
        CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, size, size));
        
        image = [UIGraphicsGetImageFromCurrentImageContext() stretchableImageWithLeftCapWidth:(NSInteger)(size / 2.0f) topCapHeight:(NSInteger)(size / 2.0f)];
        UIGraphicsEndImageContext();
        
        cachedImageColor = _monochromeColor;
    }
    return image;
}

- (UIImage *)systemReplyHighlightedButton {
    static int cachedImageColor = -1;
    static UIImage *image = nil;
    if (cachedImageColor != _monochromeColor || image == nil)
    {
        CGFloat size = 14.0f;
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(size, size), false, 0.0f);
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGFloat backgroundAlpha = _systemAlpha * 0.8;
        UIColor *color = UIColorRGBA(_monochromeColor, backgroundAlpha);
        
        CGContextSetFillColorWithColor(context, color.CGColor);
        CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, size, size));
        
        image = [UIGraphicsGetImageFromCurrentImageContext() stretchableImageWithLeftCapWidth:(NSInteger)(size / 2.0f) topCapHeight:(NSInteger)(size / 2.0f)];
        UIGraphicsEndImageContext();
        
        cachedImageColor = _monochromeColor;
    }
    return image;
}

- (UIImage *)generateSystemReplyBackground:(int)baseColor
{
    CGFloat backgroundAlpha = _systemAlpha;
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(16.0f, 16.0f), false, 0.0f);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGRect bounds = CGRectMake(0.0f, 0.0f, 16.0f, 16.0f);
    
    CGFloat radius = 0.5f * CGRectGetHeight(bounds);
    
    CGMutablePathRef visiblePath = CGPathCreateMutable();
    CGRect innerRect = CGRectInset(bounds, radius, radius);
    CGPathMoveToPoint(visiblePath, NULL, innerRect.origin.x, bounds.origin.y);
    CGPathAddLineToPoint(visiblePath, NULL, innerRect.origin.x + innerRect.size.width, bounds.origin.y);
    CGPathAddArcToPoint(visiblePath, NULL, bounds.origin.x + bounds.size.width, bounds.origin.y, bounds.origin.x + bounds.size.width, innerRect.origin.y, radius);
    CGPathAddLineToPoint(visiblePath, NULL, bounds.origin.x + bounds.size.width, innerRect.origin.y + innerRect.size.height);
    CGPathAddArcToPoint(visiblePath, NULL,  bounds.origin.x + bounds.size.width, bounds.origin.y + bounds.size.height, innerRect.origin.x + innerRect.size.width, bounds.origin.y + bounds.size.height, radius);
    CGPathAddLineToPoint(visiblePath, NULL, innerRect.origin.x, bounds.origin.y + bounds.size.height);
    CGPathAddArcToPoint(visiblePath, NULL,  bounds.origin.x, bounds.origin.y + bounds.size.height, bounds.origin.x, innerRect.origin.y + innerRect.size.height, radius);
    CGPathAddLineToPoint(visiblePath, NULL, bounds.origin.x, innerRect.origin.y);
    CGPathAddArcToPoint(visiblePath, NULL,  bounds.origin.x, bounds.origin.y, innerRect.origin.x, bounds.origin.y, radius);
    CGPathCloseSubpath(visiblePath);
    
    CGContextSaveGState(context);
    
    UIColor *color = nil;
    
    //color = UIColorRGBA(0xffffff, 0.4f);
    //CGContextSetShadowWithColor(context, CGSizeMake(0.0f, 1.0f), 0.0f, [color CGColor]);
    
    color = UIColorRGBA(baseColor, backgroundAlpha);
    [color setFill];
    CGContextAddPath(context, visiblePath);
    CGContextFillPath(context);
    
    CGContextRestoreGState(context);
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectInset(bounds, -2, -2));
    
    CGPathAddPath(path, NULL, visiblePath);
    CGPathCloseSubpath(path);
    
    CGContextAddPath(context, visiblePath);
    CGContextClip(context);
    
    CGContextSaveGState(context);
    
    //color = UIColorRGBA(baseColor, shadowAlpha);
    //CGContextSetShadowWithColor(context, CGSizeMake(0.0f, 1.0f), 1.0f, [color CGColor]);
    
    [color setFill];
    CGContextAddPath(context, path);
    CGContextEOFillPath(context);
    
    CGContextRestoreGState(context);
    
    CGPathRelease(path);
    CGPathRelease(visiblePath);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (UIImage *)generateSystemMessageBackground:(int)baseColor
{    
    CGFloat backgroundAlpha = _systemAlpha;
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(21, 21), false, 0.0f);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGRect bounds = CGRectMake(0.5f, 0, 20, 20);
    
    CGFloat radius = 0.5f * CGRectGetHeight(bounds);
    
    CGMutablePathRef visiblePath = CGPathCreateMutable();
    CGRect innerRect = CGRectInset(bounds, radius, radius);
    CGPathMoveToPoint(visiblePath, NULL, innerRect.origin.x, bounds.origin.y);
    CGPathAddLineToPoint(visiblePath, NULL, innerRect.origin.x + innerRect.size.width, bounds.origin.y);
    CGPathAddArcToPoint(visiblePath, NULL, bounds.origin.x + bounds.size.width, bounds.origin.y, bounds.origin.x + bounds.size.width, innerRect.origin.y, radius);
    CGPathAddLineToPoint(visiblePath, NULL, bounds.origin.x + bounds.size.width, innerRect.origin.y + innerRect.size.height);
    CGPathAddArcToPoint(visiblePath, NULL,  bounds.origin.x + bounds.size.width, bounds.origin.y + bounds.size.height, innerRect.origin.x + innerRect.size.width, bounds.origin.y + bounds.size.height, radius);
    CGPathAddLineToPoint(visiblePath, NULL, innerRect.origin.x, bounds.origin.y + bounds.size.height);
    CGPathAddArcToPoint(visiblePath, NULL,  bounds.origin.x, bounds.origin.y + bounds.size.height, bounds.origin.x, innerRect.origin.y + innerRect.size.height, radius);
    CGPathAddLineToPoint(visiblePath, NULL, bounds.origin.x, innerRect.origin.y);
    CGPathAddArcToPoint(visiblePath, NULL,  bounds.origin.x, bounds.origin.y, innerRect.origin.x, bounds.origin.y, radius);
    CGPathCloseSubpath(visiblePath);
    
    CGContextSaveGState(context);
    
    UIColor *color = nil;
    
    //color = UIColorRGBA(0xffffff, 0.4f);
    //CGContextSetShadowWithColor(context, CGSizeMake(0.0f, 1.0f), 0.0f, [color CGColor]);
    
    color = UIColorRGBA(baseColor, backgroundAlpha);
    [color setFill];
    CGContextAddPath(context, visiblePath);
    CGContextFillPath(context);
    
    CGContextRestoreGState(context);
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectInset(bounds, -2, -2));
    
    CGPathAddPath(path, NULL, visiblePath);
    CGPathCloseSubpath(path);
    
    CGContextAddPath(context, visiblePath);
    CGContextClip(context);
    
    CGContextSaveGState(context);
    
    //color = UIColorRGBA(baseColor, shadowAlpha);
    //CGContextSetShadowWithColor(context, CGSizeMake(0.0f, 1.0f), 1.0f, [color CGColor]);
    
    [color setFill];
    CGContextAddPath(context, path);
    CGContextEOFillPath(context);
    
    CGContextRestoreGState(context);
    
    CGPathRelease(path);
    CGPathRelease(visiblePath);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (UIEdgeInsets)messageBodyMargins
{
    return UIEdgeInsetsMake(0, 2, 3, 2);
}
- (CGSize)messageMinimalBodySize
{
    return CGSizeMake(40, 31);
}

- (UIEdgeInsets)messageBodyPaddingsIncoming
{
    return UIEdgeInsetsMake(5, 15 + 1, 5, 9 + 1);
}

- (UIEdgeInsets)messageBodyPaddingsOutgoing
{
    return UIEdgeInsetsMake(5, 9 + 1, 5, 15 + 1);
}

- (UIImage *)membersListAddImage
{
    static UIImage *image = nil;
    if (image == nil)
    {
        image = [UIImage imageNamed:@"ConversationAddMember.png"];
    }
    return image;
}

- (UIImage *)membersListAddImageHighlighted
{
    static UIImage *image = nil;
    if (image == nil)
    {
        image = [UIImage imageNamed:@"ConversationAddMember_Pressed.png"];
    }
    return image;
}

- (UIImage *)membersListEditTitleBackground
{
    static UIImage *image = nil;
    if (image == nil)
    {
        UIImage *rawImage = [UIImage imageNamed:@"ConversationEditTitle.png"];
        image = [rawImage stretchableImageWithLeftCapWidth:(int)(rawImage.size.width / 2) topCapHeight:(int)(rawImage.size.height / 2)];
    }
    return image;
}

- (UIImage *)membersListAvatarPlaceholder
{
    static UIImage *image = nil;
    if (image == nil)
    {
        image = TGScaleAndRoundCornersWithOffset([UIImage imageNamed:@"AvatarPlaceholderSmall.png"], CGSizeMake(40, 40), CGPointMake(2, 2), CGSizeMake(44, 44), 4, [TGInterfaceAssets memberListAvatarOverlay], false, nil);
    }
    return image;
}

- (UIImage *)conversationUserPhotoPlaceholder
{
    return [UIImage imageNamed:@"ConversationUserPhotoPlaceholder.png"];
}

@end
