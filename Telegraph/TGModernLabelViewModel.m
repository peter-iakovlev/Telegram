#import "TGModernLabelViewModel.h"

#import "TGFont.h"

@interface TGModernLabelViewModel ()
{
    NSString *_text;
    CTLineRef _line;
    CTFontRef _font;
    CGFloat _maxWidth;
}

@end

@implementation TGModernLabelViewModel

- (instancetype)initWithText:(NSString *)text textColor:(UIColor *)textColor font:(CTFontRef)font maxWidth:(CGFloat)maxWidth
{
    self = [super init];
    if (self != nil)
    {
        self.hasNoView = true;
        
        _textColor = textColor;
        
        if (font != NULL)
            _font = CFRetain(font);
        
        [self setText:text == nil ? @"" : text maxWidth:maxWidth];
    }
    return self;
}

- (void)dealloc
{
    if (_line != NULL)
    {
        CFRelease(_line);
        _line = NULL;
    }
    
    if (_font != NULL)
    {
        CFRelease(_font);
        _font = nil;
    }
}

- (void)setText:(NSString *)text maxWidth:(CGFloat)maxWidth
{
    _text = text;
    _maxWidth = maxWidth;
    
    if (_line != NULL)
    {
        CFRelease(_line);
        _line = nil;
    }
    
    if (_font != NULL)
    {
        _line = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)[[NSAttributedString alloc] initWithString:text attributes:[[NSDictionary alloc] initWithObjectsAndKeys:(__bridge id)_font, (__bridge id)kCTFontAttributeName, kCFBooleanTrue, (__bridge id)kCTForegroundColorFromContextAttributeName, nil]]);
        if (_line != NULL)
        {
            if (maxWidth < FLT_MAX - FLT_EPSILON)
            {
                if (CTLineGetTypographicBounds(_line, NULL, NULL, NULL) - (float)CTLineGetTrailingWhitespaceWidth(_line) > maxWidth)
                {
                    static NSString *tokenString = nil;
                    if (tokenString == nil)
                    {
                        unichar tokenChar = 0x2026;
                        tokenString = [[NSString alloc] initWithCharacters:&tokenChar length:1];
                    }
                    
                    NSMutableDictionary *truncationTokenAttributes = [[NSMutableDictionary alloc] initWithObjectsAndKeys:(__bridge id)_font, (NSString *)kCTFontAttributeName, (__bridge id)_textColor.CGColor, (NSString *)kCTForegroundColorAttributeName, nil];
                    
                    NSAttributedString *truncationTokenString = [[NSAttributedString alloc] initWithString:tokenString attributes:truncationTokenAttributes];
                    CTLineRef truncationToken = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)truncationTokenString);
                    
                    CTLineRef truncatedLine = CTLineCreateTruncatedLine(_line, maxWidth, kCTLineTruncationEnd, truncationToken);
                    CFRelease(truncationToken);
                    
                    CFRelease(_line);
                    _line = truncatedLine;
                }
            }
            
            if (_line != NULL)
            {
                CGRect bounds = CTLineGetBoundsWithOptions(_line, 0);
                bounds.origin = CGPointZero;
                bounds.size.width = floorf(bounds.size.width);
                bounds.size.height = floorf(bounds.size.height);
                if (!CGRectIsNull(bounds))
                {
                    CGRect frame = self.frame;
                    frame.size = bounds.size;
                    self.frame = frame;
                }
            }
        }
    }
}

- (NSString *)text
{
    return _text;
}

- (void)setMaxWidth:(CGFloat)maxWidth
{
    if (ABS(_maxWidth - maxWidth) > FLT_EPSILON)
    {
        _maxWidth = maxWidth;
        [self setText:_text maxWidth:_maxWidth];
    }
}

- (void)drawInContext:(CGContextRef)context
{
    [super drawInContext:context];
    
    CGContextSetTextPosition(context, 0.0f, 0.0f);
    CGAffineTransform xform = CGAffineTransformMake(1.0, 0.0, 0.0, -1.0, 0.0, floorf(self.frame.size.height / 1.0f));
    CGContextSetTextMatrix(context, xform);
    
    if (_textColor == nil)
        CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
    else
        CGContextSetFillColorWithColor(context, _textColor.CGColor);
    
    if (_line != NULL)
        CTLineDraw(_line, context);
    
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
}

@end
