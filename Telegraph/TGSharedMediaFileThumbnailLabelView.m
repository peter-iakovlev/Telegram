#import "TGSharedMediaFileThumbnailLabelView.h"

#import <CoreText/CoreText.h>

typedef enum {
    TGSharedMediaFileThumbnailLabelViewLineEllipsisNone = 0,
    TGSharedMediaFileThumbnailLabelViewLineEllipsisLeft,
    TGSharedMediaFileThumbnailLabelViewLineEllipsisRight
} TGSharedMediaFileThumbnailLabelViewLineEllipsis;

@interface TGSharedMediaFileThumbnailLabelViewLine : NSObject

@property (nonatomic, readonly) CTLineRef line;
@property (nonatomic) CGSize size;
@property (nonatomic) CGFloat intrinsicWidth;
@property (nonatomic) TGSharedMediaFileThumbnailLabelViewLineEllipsis ellipsis;

@end

@implementation TGSharedMediaFileThumbnailLabelViewLine

- (instancetype)initWithLine:(CTLineRef)line size:(CGSize)size ellipsis:(TGSharedMediaFileThumbnailLabelViewLineEllipsis)ellipsis
{
    self = [super init];
    if (self != nil)
    {
        if (line != NULL)
            _line = CFRetain(line);
        _size = size;
        _intrinsicWidth = size.width;
        _ellipsis = ellipsis;
    }
    return self;
}

- (void)dealloc
{
    if (_line != NULL)
        CFRelease(_line);
}

@end

@interface TGSharedMediaFileThumbnailLabelView ()
{
    NSAttributedString *_attributedString;
    TGSharedMediaFileThumbnailLabelViewLine *_ellipsisLine;
    NSArray *_lines;
    bool _needsLayoutText;
    CGFloat _lineHeight;
    bool _displayBackground;
}

@end

@implementation TGSharedMediaFileThumbnailLabelView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        _lineHeight = 15.0f;
        self.opaque = false;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setAttributedString:(NSAttributedString *)attributedString displayBackground:(bool)displayBackground
{
    _attributedString = attributedString;
    _needsLayoutText = true;
    _displayBackground = displayBackground;
    [self setNeedsDisplay];
}

- (void)setFrame:(CGRect)frame
{
    if (!CGSizeEqualToSize(self.frame.size, frame.size))
    {
        _needsLayoutText = true;
        [self setNeedsDisplay];
    }
    
    [super setFrame:frame];
}

- (void)_layoutText
{
    _needsLayoutText = false;
    if (_attributedString == nil)
        return;
    
    
    {
        NSDictionary *attributes = [_attributedString attributesAtIndex:0 effectiveRange:NULL];
        
        static NSString *tokenString = nil;
        if (tokenString == nil)
        {
            unichar tokenChar = 0x2026;
            tokenString = [[NSString alloc] initWithCharacters:&tokenChar length:1];
        }
        
        NSAttributedString *truncationTokenString = [[NSAttributedString alloc] initWithString:tokenString attributes:attributes];
        CTLineRef truncationToken = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)truncationTokenString);
        CGFloat lineWidth = (float)CTLineGetTypographicBounds(truncationToken, NULL, NULL, NULL) - (float)CTLineGetTrailingWhitespaceWidth(truncationToken);
        
        _ellipsisLine = [[TGSharedMediaFileThumbnailLabelViewLine alloc] initWithLine:truncationToken size:CGSizeMake(lineWidth, _lineHeight) ellipsis:TGSharedMediaFileThumbnailLabelViewLineEllipsisNone];
        
        CFRelease(truncationToken);
    }
    
    CTTypesetterRef typesetter = CTTypesetterCreateWithAttributedString((__bridge CFAttributedStringRef)_attributedString);
    
    CFIndex preventClusteredBreakIndex = INT_MAX;
    //preventClusteredBreakIndex = _attributedString.length - [_attributedString.string pathExtension].length;
    
    NSMutableArray *lines = [[NSMutableArray alloc] init];
    CFIndex lastIndex = 0;
    CGFloat maxWidth = 64.0f;
    CFIndex firstLineIndex = 0;
    while (true)
    {
        CFIndex lineCharacterCount = CTTypesetterSuggestClusterBreak(typesetter, lastIndex, maxWidth);
        if (lastIndex + lineCharacterCount > preventClusteredBreakIndex)
        {
            lineCharacterCount = preventClusteredBreakIndex - lastIndex;
            preventClusteredBreakIndex = INT_MAX;
        }
        
        if (lineCharacterCount == 0)
            break;
        if (firstLineIndex == 0)
            firstLineIndex = lineCharacterCount;
        CTLineRef line = CTTypesetterCreateLineWithOffset(typesetter, CFRangeMake(lastIndex, lineCharacterCount), 100.0);
        
        CGFloat lineWidth = (float)CTLineGetTypographicBounds(line, NULL, NULL, NULL) - (float)CTLineGetTrailingWhitespaceWidth(line);
        
        [lines addObject:[[TGSharedMediaFileThumbnailLabelViewLine alloc] initWithLine:line size:CGSizeMake(lineWidth, _lineHeight) ellipsis:TGSharedMediaFileThumbnailLabelViewLineEllipsisNone]];
        
        lastIndex += lineCharacterCount;
        CFRelease(line);
    }
    
    if (lines.count >= 2)
    {
        if (lines.count > 2)
        {
            TGSharedMediaFileThumbnailLabelViewLine *lastLine = nil;
            
            CFIndex index = _attributedString.length - 1;
            while (index > firstLineIndex)
            {
                CTLineRef line = CTTypesetterCreateLine(typesetter, CFRangeMake(index, _attributedString.length - index));
                CGFloat lineWidth = (float)CTLineGetTypographicBounds(line, NULL, NULL, NULL) - (float)CTLineGetTrailingWhitespaceWidth(line);
                if (lineWidth > maxWidth)
                    break;
                
                lastLine = [[TGSharedMediaFileThumbnailLabelViewLine alloc] initWithLine:line size:CGSizeMake(lineWidth + _ellipsisLine.size.width + 1.0f, _lineHeight) ellipsis:TGSharedMediaFileThumbnailLabelViewLineEllipsisLeft];
                
                CFRelease(line);
                index--;
            }
            
            ((TGSharedMediaFileThumbnailLabelViewLine *)lines[0]).ellipsis = TGSharedMediaFileThumbnailLabelViewLineEllipsisRight;
            ((TGSharedMediaFileThumbnailLabelViewLine *)lines[0]).size = (CGSize){((TGSharedMediaFileThumbnailLabelViewLine *)lines[0]).size.width + _ellipsisLine.size.width - 1.0f, _lineHeight};
            lines = [[NSMutableArray alloc] initWithArray:@[lines.firstObject, lastLine != nil ? lastLine : lines.lastObject]];
        }
        
        CGFloat radius = 4.0f;
        for (NSUInteger i = 0; i < lines.count - 1; i++)
        {
            TGSharedMediaFileThumbnailLabelViewLine *line = lines[i];
            TGSharedMediaFileThumbnailLabelViewLine *nextLine = lines[i + 1];
            if (ABS(line.size.width - nextLine.size.width) < radius * 2.0f)
            {
                if (line.size.width > nextLine.size.width)
                    line.size = (CGSize){nextLine.size.width + radius * 2.0f, line.size.height};
                else
                    nextLine.size = (CGSize){line.size.width + radius * 2.0f, nextLine.size.height};
            }
        }
    }
    
    CFRelease(typesetter);
    
    _lines = lines;
}

- (void)sizeToFit
{
    if (_needsLayoutText)
        [self _layoutText];
    
    CGSize size = CGSizeZero;
    for (TGSharedMediaFileThumbnailLabelViewLine *line in _lines)
    {
        size.width = MAX(size.width, line.size.width);
        size.height += line.size.height;
    }
    self.frame = (CGRect){self.frame.origin, {size.width + 8.0f, size.height + 2.0f}};
}

- (void)drawRect:(CGRect)__unused rect
{
    if (_needsLayoutText)
        [self _layoutText];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);

    CGContextTranslateCTM(context, self.frame.size.width / 2.0f, self.frame.size.height / 2.0f);
    CGContextScaleCTM(context, 1.0f, -1.0f);
    CGContextTranslateCTM(context, -self.frame.size.width / 2.0f, -self.frame.size.height / 2.0f);
    
    if (_displayBackground)
    {
        CGContextSetFillColorWithColor(context, [UIColor colorWithWhite:0.0f alpha:0.3f].CGColor);
        CGContextBeginPath(context);
        
        CGFloat radius = 2.0f;
        
        CGFloat lineOffset = 0.0f;
        CGRect lastLineFrame = CGRectZero;
        
        NSUInteger index = 0;
        for (TGSharedMediaFileThumbnailLabelViewLine *line in _lines.reverseObjectEnumerator)
        {
            CGRect lineFrame = (CGRect){CGPointMake(CGFloor((self.frame.size.width - (line.size.width + 4.0f)) / 2.0f), 0.0f + lineOffset), {line.size.width + 4.0f, line.size.height}};
            
            if (index == 0)
                CGContextMoveToPoint(context, CGRectGetMidX(lineFrame), CGRectGetMinY(lineFrame));
            
            if (index != 0)
            {
                if (lastLineFrame.size.width < lineFrame.size.width)
                {
                    CGContextAddArcToPoint(context, CGRectGetMaxX(lastLineFrame), CGRectGetMaxY(lastLineFrame), CGRectGetMaxX(lastLineFrame) + radius, CGRectGetMaxY(lastLineFrame), radius);
                    CGContextAddLineToPoint(context, CGRectGetMaxX(lineFrame) - radius, CGRectGetMinY(lineFrame));
                }
                else
                {
                    CGContextAddArcToPoint(context, CGRectGetMaxX(lastLineFrame), CGRectGetMaxY(lastLineFrame), CGRectGetMaxX(lastLineFrame) - radius, CGRectGetMaxY(lastLineFrame), radius);
                    CGContextAddLineToPoint(context, CGRectGetMaxX(lineFrame) + radius, CGRectGetMinY(lineFrame));
                }
                
                CGContextAddArcToPoint(context, CGRectGetMaxX(lineFrame), CGRectGetMinY(lineFrame), CGRectGetMaxX(lineFrame), CGRectGetMinY(lineFrame) + radius, radius);
                CGContextAddLineToPoint(context, CGRectGetMaxX(lineFrame), CGRectGetMaxY(lineFrame) - radius);
            }
            else
            {
                CGContextAddLineToPoint(context, CGRectGetMaxX(lineFrame) - radius, CGRectGetMinY(lineFrame));
                CGContextAddArcToPoint(context, CGRectGetMaxX(lineFrame), CGRectGetMinY(lineFrame), CGRectGetMaxX(lineFrame), CGRectGetMinY(lineFrame) + radius, radius);
                CGContextAddLineToPoint(context, CGRectGetMaxX(lineFrame), CGRectGetMaxY(lineFrame) - radius);
            }
            
            if (index == _lines.count - 1)
            {
                CGContextAddArcToPoint(context, CGRectGetMaxX(lineFrame), CGRectGetMaxY(lineFrame), CGRectGetMaxX(lineFrame) - radius, CGRectGetMaxY(lineFrame), radius);
                CGContextAddLineToPoint(context, CGRectGetMidX(lineFrame), CGRectGetMaxY(lineFrame));
            }
            
            lineOffset += _lineHeight;
            lastLineFrame = lineFrame;
            
            index++;
        }
        
        lineOffset -= _lineHeight;
        lastLineFrame = CGRectZero;
        index = _lines.count - 1;
        for (TGSharedMediaFileThumbnailLabelViewLine *line in _lines)
        {
            CGRect lineFrame = (CGRect){CGPointMake(CGFloor((self.frame.size.width - (line.size.width + 4.0f)) / 2.0f), 0.0f + lineOffset), {line.size.width + 4.0f, line.size.height}};
            
            if (index == _lines.count - 1)
            {
                CGContextAddLineToPoint(context, CGRectGetMinX(lineFrame) + radius, CGRectGetMaxY(lineFrame));
                CGContextAddArcToPoint(context, CGRectGetMinX(lineFrame), CGRectGetMaxY(lineFrame), CGRectGetMinX(lineFrame), CGRectGetMaxY(lineFrame) - radius, radius);
                CGContextAddLineToPoint(context, CGRectGetMinX(lineFrame), CGRectGetMinY(lineFrame) + radius);
            }
            else
            {
                if (lastLineFrame.size.width > lineFrame.size.width)
                {
                    CGContextAddArcToPoint(context, CGRectGetMinX(lastLineFrame), CGRectGetMinY(lastLineFrame), CGRectGetMinX(lastLineFrame) + radius, CGRectGetMinY(lastLineFrame), radius);
                    CGContextAddLineToPoint(context, CGRectGetMinX(lineFrame) - radius, CGRectGetMaxY(lineFrame));
                }
                else
                {
                    CGContextAddArcToPoint(context, CGRectGetMinX(lastLineFrame), CGRectGetMinY(lastLineFrame), CGRectGetMinX(lastLineFrame) - radius, CGRectGetMinY(lastLineFrame), radius);
                    CGContextAddLineToPoint(context, CGRectGetMinX(lineFrame) + radius, CGRectGetMaxY(lineFrame));
                }
                CGContextAddArcToPoint(context, CGRectGetMinX(lineFrame), CGRectGetMaxY(lineFrame), CGRectGetMinX(lineFrame), CGRectGetMaxY(lineFrame) - radius, radius);
                CGContextAddLineToPoint(context, CGRectGetMinX(lineFrame), CGRectGetMinY(lineFrame) + radius);
            }
            
            if (index == 0)
            {
                //CGContextAddLineToPoint(context, -100.0f, 100.0f);
                CGContextAddArcToPoint(context, CGRectGetMinX(lineFrame), CGRectGetMinY(lineFrame), CGRectGetMinX(lineFrame) + radius, CGRectGetMinY(lineFrame), radius);
            }
            
            lineOffset -= _lineHeight;
            
            index--;
            lastLineFrame = lineFrame;
        }
        
        CGContextClosePath(context);
        CGContextFillPath(context);
    }
    
    CGFloat lineOffset = 0.0f;
    for (TGSharedMediaFileThumbnailLabelViewLine *line in _lines.reverseObjectEnumerator)
    {
        CGPoint lineOrigin = CGPointMake(CGFloor((self.frame.size.width - line.size.width) / 2.0f), 3.0f + lineOffset);
        if (line.ellipsis == TGSharedMediaFileThumbnailLabelViewLineEllipsisLeft)
        {
            CGContextSetTextPosition(context, lineOrigin.x, lineOrigin.y);
            CTLineDraw(_ellipsisLine.line, context);
            
            lineOrigin.x += _ellipsisLine.size.width;
        }
        CGContextSetTextPosition(context, lineOrigin.x, lineOrigin.y);
        CTLineDraw(line.line, context);
        
        if (line.ellipsis == TGSharedMediaFileThumbnailLabelViewLineEllipsisRight)
        {
            CGContextSetTextPosition(context, lineOrigin.x + line.intrinsicWidth, lineOrigin.y);
            CTLineDraw(_ellipsisLine.line, context);
        }
        
        lineOffset += _lineHeight;
    }
    
    CGContextRestoreGState(context);
}

@end
