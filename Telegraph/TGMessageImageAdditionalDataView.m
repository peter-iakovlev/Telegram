/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGMessageImageAdditionalDataView.h"

#import "TGFont.h"
#import "TGStaticBackdropAreaData.h"

static const float luminanceThreshold = 0.8f;

@interface TGMessageImageAdditionalDataView ()
{
    TGStaticBackdropAreaData *_backdropArea;
    NSString *_text;
    CGSize _textSize;
    bool _textSizeInitialized;
    NSTextAlignment _textAlignment;
    UIColor *_timestampColor;
}

@end

@implementation TGMessageImageAdditionalDataView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        self.opaque = false;
        _textAlignment = NSTextAlignmentLeft;
        _timestampColor = UIColorRGBA(0x000000, 0.4f);
    }
    return self;
}

- (void)setBackdropArea:(TGStaticBackdropAreaData *)backdropArea transitionDuration:(NSTimeInterval)__unused transitionDuration
{
    if (_backdropArea != backdropArea)
    {
        _backdropArea = backdropArea;
        [self setNeedsDisplay];
    }
}

- (void)setTimestampColor:(UIColor *)timestampColor
{
    if (timestampColor == nil)
        timestampColor = UIColorRGBA(0x000000, 0.4f);
    
    if (_timestampColor != timestampColor)
    {
        _timestampColor = timestampColor;
        [self setNeedsDisplay];
    }
}

- (void)setText:(NSString *)text
{
    if (!TGStringCompare(_text, text))
    {
        _text = text;
        _textSizeInitialized = false;
        [self setNeedsDisplay];
    }
}

- (UIFont *)textFont
{
    static UIFont *font = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        font = TGSystemFontOfSize(11.0f);
    });
    
    return font;
}

- (CGSize)textSize
{
    if (!_textSizeInitialized)
    {
        _textSizeInitialized = true;
        CGSize textSize = [_text sizeWithFont:[self textFont]];
        _textSize = CGSizeMake(CGCeil(textSize.width), CGCeil(textSize.height));
    }
    
    return _textSize;
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment
{
    if (_textAlignment != textAlignment)
    {
        _textAlignment = textAlignment;
        [self setNeedsDisplay];
    }
}

- (void)drawRect:(CGRect)__unused rect
{
    __unused CGPoint position = self.frame.origin;
    __unused CGSize imageSize = self.superview.frame.size;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGFloat contentWidth = MIN([self textSize].width + 11.0f, self.frame.size.width);
    
    CGFloat x = 0.0f;
    if (_textAlignment == NSTextAlignmentCenter)
        x = floor((self.frame.size.width - contentWidth) / 2.0f);
    
    CGRect backgroundRect = CGRectMake(x, 0.0f, contentWidth, 18.0f);
    
    CGContextBeginPath(context);
    CGContextAddEllipseInRect(context, CGRectMake(backgroundRect.origin.x, backgroundRect.origin.y, backgroundRect.size.height, backgroundRect.size.height));
    CGContextAddRect(context, CGRectMake(backgroundRect.origin.x + backgroundRect.size.height / 2.0f, backgroundRect.origin.y, backgroundRect.size.width - backgroundRect.size.height, backgroundRect.size.height));
    CGContextAddEllipseInRect(context, CGRectMake(backgroundRect.origin.x + backgroundRect.size.width - backgroundRect.size.height, backgroundRect.origin.y, backgroundRect.size.height, backgroundRect.size.height));
    CGContextClip(context);
    

    CGContextSetFillColorWithColor(context, _timestampColor.CGColor);
    CGContextFillRect(context, backgroundRect);
    
    CGFloat luminance = 0.0f;
    
    /*if (_backdropArea == nil)
    {
        CGContextSetFillColorWithColor(context, UIColorRGB(0xaaaaaa).CGColor);
        CGContextFillRect(context, backgroundRect);
    }
    else
    {
        luminance = _backdropArea.luminance;
        [_backdropArea drawRelativeToImageRect:CGRectMake(-position.x, -position.y, imageSize.width, imageSize.height)];
    }*/

    UIColor *textColor = luminance > luminanceThreshold ? UIColorRGBA(0x525252, 0.6f) : [UIColor whiteColor];
    CGContextSetFillColorWithColor(context, textColor.CGColor);
    [_text drawInRect:CGRectMake(backgroundRect.origin.x + 6.0f, 2.5f, contentWidth - 11.0f, [self textSize].height) withFont:[self textFont] lineBreakMode:NSLineBreakByTruncatingTail];
}

@end
