#import "TGReplyHeaderModel.h"

#import <CoreText/CoreText.h>

#import "TGModernColorViewModel.h"
#import "TGModernTextViewModel.h"

#import "TGUser.h"
#import "TGConversation.h"

#import "TGImageUtils.h"
#import "TGFont.h"

#import "TGReusableLabel.h"

@interface TGReplyHeaderModel ()
{
    CGFloat _cachedLayoutWidth;
    CGFloat _cachedLeftInset;
}

@end

@implementation TGReplyHeaderModel

static CTFontRef nameFont()
{
    static CTFontRef font = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        if (iosMajorVersion() >= 7) {
            font = CTFontCreateWithFontDescriptor((__bridge CTFontDescriptorRef)[TGMediumSystemFontOfSize(14.0f) fontDescriptor], 0.0f, NULL);
        } else {
            UIFont *systemFont = TGMediumSystemFontOfSize(14.0f);
            font = CTFontCreateWithName((__bridge CFStringRef)systemFont.fontName, systemFont.pointSize, nil);
        }
    });
    
    return font;
}

static CTFontRef textFont()
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

static UIColor *colorForTitle(bool incoming)
{
    static UIColor *incomingColor = nil;
    static UIColor *outgoingColor = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        incomingColor = UIColorRGB(0x0b8bed);
        outgoingColor = UIColorRGB(0x00a700);
    });
    return incoming ? incomingColor : outgoingColor;
}

static UIColor *colorForLine(bool incoming)
{
    static UIColor *incomingColor = nil;
    static UIColor *outgoingColor = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        incomingColor = UIColorRGB(0x3ca7fe);
        outgoingColor = UIColorRGB(0x29cc10);
    });
    return incoming ? incomingColor : outgoingColor;
}

- (instancetype)initWithPeer:(id)peer incoming:(bool)incoming text:(NSString *)text truncateTextInTheMiddle:(bool)truncateTextInTheMiddle textColor:(UIColor *)textColor leftInset:(CGFloat)leftInset system:(bool)system
{
    self = [super init];
    if (self != nil)
    {   
        _leftInset = leftInset;
        _system = system;
        
        _lineModel = [[TGModernColorViewModel alloc] initWithColor:system ? [UIColor whiteColor] : colorForLine(incoming)];
        [self addSubmodel:_lineModel];
        
        NSString *title = @"";
        if ([peer isKindOfClass:[TGUser class]]) {
            title = ((TGUser *)peer).displayName;
        } else if ([peer isKindOfClass:[TGConversation class]]) {
            title = ((TGConversation *)peer).chatTitle;
        }
        
        _nameModel = [[TGModernTextViewModel alloc] initWithText:title font:nameFont()];
        _nameModel.textColor = system ? [UIColor whiteColor] : colorForTitle(incoming);
        [self addSubmodel:_nameModel];
        
        _textModel = [[TGModernTextViewModel alloc] initWithText:text font:textFont()];
        if (truncateTextInTheMiddle)
            _textModel.layoutFlags = TGReusableLabelTruncateInTheMiddle;
        _textModel.textColor = system ? [UIColor whiteColor] : textColor;
        [self addSubmodel:_textModel];
    }
    return self;
}

+ (UIColor *)colorForMediaText:(bool)incoming
{
    static UIColor *incomingColor = nil;
    static UIColor *outgoingColor = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        incomingColor = UIColorRGB(0x979797);
        outgoingColor = UIColorRGB(0x00a700);
    });
    return incoming ? incomingColor : outgoingColor;
}

+ (CGFloat)thumbnailCornerRadius
{
    return 4.0f;
}

- (void)bindSpecialViewsToContainer:(UIView *)__unused container viewStorage:(TGModernViewStorage *)__unused viewStorage atItemPosition:(CGPoint)__unused itemPosition
{
}

- (void)layoutForContainerSize:(CGSize)containerSize
{
    [self layoutForContainerSize:containerSize updateContent:NULL];
}

- (void)layoutForContainerSize:(CGSize)containerSize updateContent:(bool *)updateContent
{
    if (ABS(_cachedLayoutWidth - containerSize.width) > FLT_EPSILON || ABS(_cachedLeftInset - _leftInset) > FLT_EPSILON)
    {
        _cachedLayoutWidth = containerSize.width;
        _cachedLeftInset = _leftInset;
        if (updateContent)
            *updateContent = true;
    }
    
    CGFloat leftInset = 11.0f + _leftInset;
    
    CGSize maxTextSize = containerSize;
    maxTextSize.width -= leftInset + 6.0f;
    [_nameModel layoutForContainerSize:maxTextSize];
    [_textModel layoutForContainerSize:maxTextSize];
    
    CGFloat additionalOffset = _system ? 1.0f : 0.0f;
    
    CGRect nameFrame = _nameModel.frame;
    nameFrame.origin.x = leftInset;
    nameFrame.origin.y = 3.0f + additionalOffset;;
    _nameModel.frame = nameFrame;
    
    CGRect textFrame = _textModel.frame;
    textFrame.origin.y = CGRectGetMaxY(nameFrame) + 2.0f;
    textFrame.origin.x = leftInset;
    _textModel.frame = textFrame;
    
    CGFloat additionalHeight = _system ? 2.0f : 0.0f;
    
    self.frame = CGRectMake(0.0f, 0.0f, leftInset + MAX(_nameModel.frame.size.width, _textModel.frame.size.width), _nameModel.frame.size.height + _textModel.frame.size.height + 8.0f + additionalHeight);
    
    _lineModel.frame = CGRectMake(1.0f, 7.0f, 2.0f, self.frame.size.height - 10.0f + additionalHeight);
}

@end
