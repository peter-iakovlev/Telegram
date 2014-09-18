#import "TGReusableLabel.h"

#import "TGStringUtils.h"

#import <CoreText/CoreText.h>

#import "NSObject+TGLock.h"

#include <tr1/unordered_map>
#include <tr1/unordered_set>
#include <vector>

#import "TGDateUtils.h"

@interface TGReusableLabelLayoutData ()
{
    std::tr1::unordered_map<int, std::tr1::unordered_map<int, int> > _lineOffsets;
    std::vector<TGLinePosition> _lineOrigins;
    
    std::vector<TGLinkData> _links;
}

@property (nonatomic, strong) NSArray *textLines;
@property (nonatomic) CGSize drawingSize;
@property (nonatomic) CGPoint drawingOffset;

- (std::tr1::unordered_map<int, std::tr1::unordered_map<int, int> > *)lineOffsets;

@end

@implementation TGReusableLabelLayoutData


- (std::tr1::unordered_map<int, std::tr1::unordered_map<int, int> > *)lineOffsets
{
    return &_lineOffsets;
}

- (std::vector<TGLinePosition> *)lineOrigins
{
    return &_lineOrigins;
}

- (std::vector<TGLinkData> *)links
{
    return &_links;
}

- (NSString *)linkAtPoint:(CGPoint)point topRegion:(CGRect *)topRegion middleRegion:(CGRect *)middleRegion bottomRegion:(CGRect *)bottomRegion
{
    if (!_links.empty())
    {
        for (std::vector<TGLinkData>::iterator it = _links.begin(); it != _links.end(); it++)
        {
            if ((it->topRegion.size.height != 0 && CGRectContainsPoint(CGRectInset(it->topRegion, -2, -2), point)) || (it->middleRegion.size.height != 0 && CGRectContainsPoint(CGRectInset(it->middleRegion, -2, -2), point)) || (it->bottomRegion.size.height != 0 && CGRectContainsPoint(CGRectInset(it->bottomRegion, -2, -2), point)))
            {
                if (topRegion != NULL)
                    *topRegion = it->topRegion;
                if (middleRegion != NULL)
                    *middleRegion = it->middleRegion;
                if (bottomRegion != NULL)
                    *bottomRegion = it->bottomRegion;
                return it->url;
            }
        }
    }
    return nil;
}

@end

@interface TGReusableLabel ()

@end

@implementation TGReusableLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _reuseIdentifier = @"ReusableLabel";
    }
    return self;
}

- (void)setHighlighted:(bool)highlighted
{
    if (highlighted != _highlighted)
    {
        _highlighted = highlighted;
        [self setNeedsDisplay];
    }
}

- (void)setFrame:(CGRect)frame
{
    if (!CGSizeEqualToSize(self.frame.size, frame.size))
    {
        [self setNeedsDisplay];
    }
    [super setFrame:frame];
}

- (void)setText:(NSString *)text
{
    if (text != _text)
    {
        _text = text;
        [self setNeedsDisplay];
    }
}

+ (void)preloadData
{
}

+ (TGReusableLabelLayoutData *)calculateLayout:(NSString *)text additionalAttributes:(NSArray *)additionalAttributes textCheckingResults:(NSArray *)textCheckingResults font:(CTFontRef)font textColor:(UIColor *)textColor frame:(CGRect)frame orMaxWidth:(float)maxWidth flags:(int)flags textAlignment:(UITextAlignment)textAlignment outIsRTL:(bool *)outIsRTL
{
    return [self calculateLayout:text additionalAttributes:additionalAttributes textCheckingResults:textCheckingResults font:font textColor:textColor frame:frame orMaxWidth:maxWidth flags:flags textAlignment:textAlignment outIsRTL:outIsRTL additionalTrailingWidth:0.0f];
}

+ (TGReusableLabelLayoutData *)calculateLayout:(NSString *)text additionalAttributes:(NSArray *)additionalAttributes textCheckingResults:(NSArray *)textCheckingResults font:(CTFontRef)font textColor:(UIColor *)textColor frame:(CGRect)frame orMaxWidth:(float)maxWidth flags:(int)flags textAlignment:(UITextAlignment)textAlignment outIsRTL:(bool *)outIsRTL additionalTrailingWidth:(CGFloat)additionalTrailingWidth
{
    if (font == NULL || text == nil)
        return nil;
    
    static bool needToOffsetEmoji = false;
    static bool needToOffsetEmojiInitialized = false;
    if (!needToOffsetEmojiInitialized)
    {
        needToOffsetEmojiInitialized = true;
        needToOffsetEmoji = iosMajorVersion() < 6;
    }
    
    TGReusableLabelLayoutData *layout = [[TGReusableLabelLayoutData alloc] init];
    
    float fontAscent = CTFontGetAscent(font);
    float fontDescent = CTFontGetDescent(font);
    
    float fontLineHeight = floorf(fontAscent + fontDescent);
    float fontLineSpacing = floorf(fontLineHeight * 1.12f);
    
    NSMutableDictionary *attributes = [[NSMutableDictionary alloc] initWithObjectsAndKeys:(__bridge id)font, (NSString *)kCTFontAttributeName, [[NSNumber alloc] initWithFloat:0.0f], (NSString *)kCTKernAttributeName, nil];
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:text attributes:attributes];
    
    if (textColor != NULL)
        CFAttributedStringSetAttribute((CFMutableAttributedStringRef)string, CFRangeMake(0, string.length), kCTForegroundColorAttributeName, textColor.CGColor);
    
    if (additionalAttributes != nil)
    {
        int count = additionalAttributes.count;
        for (int i = 0; i < count; i += 2)
        {
            NSRange range = NSMakeRange(0, 0);
            [(NSValue *)[additionalAttributes objectAtIndex:i] getValue:&range];
            NSArray *attributes = [additionalAttributes objectAtIndex:i + 1];
            
            if (range.location + range.length <= string.length)
            {
                CFAttributedStringSetAttribute((CFMutableAttributedStringRef)string, CFRangeMake(range.location, range.length), (CFStringRef)[attributes objectAtIndex:1], (CFTypeRef)[attributes objectAtIndex:0]);
            }
        }
    }
    
    static CGColorRef defaultLinkColor = nil;
    if (defaultLinkColor == nil)
        defaultLinkColor = (CGColorRef)CFRetain(UIColorRGB(0x004bad).CGColor);
    
    CGColorRef linkColor = defaultLinkColor;
    
    NSRange *pLinkRanges = NULL;
    int linkRangesCount = 0;
    
    if (textCheckingResults != nil && textCheckingResults.count != 0)
    {
        NSNumber *underlineStyle = [[NSNumber alloc] initWithInt:kCTUnderlineStyleSingle];
        
        int index = -1;
        for (NSTextCheckingResult *match in textCheckingResults)
        {
            index++;
            
            NSRange linkRange = [match range];
            
            if (pLinkRanges == NULL)
            {
                linkRangesCount = textCheckingResults.count;
                pLinkRanges = new NSRange[linkRangesCount];
            }
            
            pLinkRanges[index] = linkRange;
            
            NSString *url = match.resultType == NSTextCheckingTypePhoneNumber ? [[NSString alloc] initWithFormat:@"tel:%@", match.phoneNumber] : [match.URL absoluteString];
            layout.links->push_back(TGLinkData(linkRange, url));
            
            if (flags & TGReusableLabelLayoutHighlightLinks)
            {
                CFAttributedStringSetAttribute((CFMutableAttributedStringRef)string, CFRangeMake(linkRange.location, linkRange.length), kCTForegroundColorAttributeName, linkColor);
                CFAttributedStringSetAttribute((CFMutableAttributedStringRef)string, CFRangeMake(linkRange.location, linkRange.length), kCTUnderlineStyleAttributeName, (CFNumberRef)underlineStyle);
            }
        }
    }
    
    NSArray *resultLines = nil;
    std::vector<TGLinePosition> *pLineOrigins = layout.lineOrigins;
    bool resultHadRTL = false;
    CGRect resultRect = CGRectZero;
    
    if (flags & TGReusableLabelLayoutMultiline)
    {
        CGRect rect = CGRectZero;
        rect.origin = frame.origin;
        
        pLineOrigins->erase(pLineOrigins->begin(), pLineOrigins->end());
        
        NSMutableArray *textLines = [[NSMutableArray alloc] init];
        
        bool hadRTL = false;
        
        float lastLineWidth = 0.0f;
        
        CTTypesetterRef typesetter = CTTypesetterCreateWithAttributedString((__bridge CFAttributedStringRef)string);
        
        CFIndex lastIndex = 0;
        float currentLineOffset = 0;
        
        while (true)
        {
            CFIndex lineCharacterCount = CTTypesetterSuggestLineBreak(typesetter, lastIndex, maxWidth);
            
            if (pLinkRanges != NULL && flags & TGReusableLabelLayoutHighlightLinks)
            {
                CFIndex endIndex = lastIndex + lineCharacterCount;
                
                for (int i = 0; i < linkRangesCount; i++)
                {
                    if (pLinkRanges[i].location < endIndex && pLinkRanges[i].location + pLinkRanges[i].length >= endIndex)
                    {
                        lineCharacterCount = MAX(lineCharacterCount, CTTypesetterSuggestClusterBreak(typesetter, lastIndex, maxWidth));
                        
                        if (pLinkRanges[i].location > lastIndex && lineCharacterCount < pLinkRanges[i].location + pLinkRanges[i].length - lastIndex)
                            lineCharacterCount = pLinkRanges[i].location - lastIndex;
                        
                        break;
                    }
                }
            }
            
            if (lineCharacterCount > 0)
            {
                CTLineRef line = CTTypesetterCreateLineWithOffset(typesetter, CFRangeMake(lastIndex, lineCharacterCount), 100.0);
                [textLines addObject:(__bridge id)line];
                
                bool rightAligned = false;
                
                CFArrayRef glyphRuns = CTLineGetGlyphRuns(line);
                if (CFArrayGetCount(glyphRuns) != 0)
                {
                    if (CTRunGetStatus((CTRunRef)CFArrayGetValueAtIndex(glyphRuns, 0)) & kCTRunStatusRightToLeft)
                        rightAligned = true;
                }
                
                hadRTL |= rightAligned;
                
                float lineWidth = (float)CTLineGetTypographicBounds(line, NULL, NULL, NULL) - (float)CTLineGetTrailingWhitespaceWidth(line);
                
                TGLinePosition linePosition = {.offset = currentLineOffset + fontLineHeight, .horizontalOffset = 0.0f, .alignment = (textAlignment == NSTextAlignmentCenter ? 1 : (rightAligned ? 2 : 0)), .lineWidth = lineWidth};
                pLineOrigins->push_back(linePosition);
                
                currentLineOffset += fontLineSpacing;
                rect.size.height += fontLineSpacing;
                rect.size.width = MAX(rect.size.width, lineWidth);
                
                CFRelease(line);
                
                lastLineWidth = lineWidth;
                
                lastIndex += lineCharacterCount;
            }
            else
                break;
        }
        
        if (flags & TGReusableLabelLayoutDateSpacing)
        {
            float dateSpacing = ((flags & TGReusableLabelLayoutExtendedDateSpacing) ? 61.0f : 42.0f) + (TGUse12hDateFormat() ? 10.0f : 0.0f) + additionalTrailingWidth;
            
            if (textLines.count == 1)
            {
                if (lastLineWidth + dateSpacing <= maxWidth)
                {
                    rect.size.width += dateSpacing;
                    if (pLineOrigins->at(textLines.count - 1).alignment == 2)
                    {
                        pLineOrigins->at(textLines.count - 1).horizontalOffset -= dateSpacing;
                    }
                }
                else
                    rect.size.height += fontLineHeight * 0.7f;
            }
            else if (textLines.count != 0)
            {
                if (rect.size.width - lastLineWidth < dateSpacing)
                {
                    if (lastLineWidth + dateSpacing <= maxWidth)
                    {
                        if (pLineOrigins->at(textLines.count - 1).alignment == 2)
                        {
                            rect.size.height += fontLineHeight * 0.7f;
                            rect.size.width = MAX(rect.size.width, dateSpacing - 12);
                        }
                        else
                            rect.size.width = lastLineWidth + dateSpacing;
                    }
                    else
                    {
                        rect.size.height += fontLineHeight * 0.7f;
                    
                        if (rect.size.width < dateSpacing - 12)
                            rect.size.width = dateSpacing - 12;
                    }
                }
                else
                {
                    if (pLineOrigins->at(textLines.count - 1).alignment == 2)
                        rect.size.height += fontLineHeight * 0.7f;
                }
            }
        }
        
        layout.size = CGSizeMake(floorf(rect.size.width), floorf(rect.size.height + fontLineHeight * 0.1f));
        layout.drawingSize = rect.size;
        
        layout.textLines = textLines;
        
        if (typesetter != NULL)
            CFRelease(typesetter);
        
        resultLines = textLines;
        resultHadRTL = hadRTL;
        resultRect = rect;
    }
    else
    {
        CGRect rect = CGRectZero;
        rect.origin = frame.origin;
        
        pLineOrigins->erase(pLineOrigins->begin(), pLineOrigins->end());
        
        NSMutableArray *textLines = [[NSMutableArray alloc] init];
        
        NSMutableDictionary *truncationTokenAttributes = [[NSMutableDictionary alloc] initWithObjectsAndKeys:(__bridge id)font, (NSString *)kCTFontAttributeName, (__bridge id)textColor.CGColor, (NSString *)kCTForegroundColorAttributeName, nil];
        
        static NSString *tokenString = nil;
        if (tokenString == nil)
        {
            unichar tokenChar = 0x2026;
            tokenString = [[NSString alloc] initWithCharacters:&tokenChar length:1];
        }
        
        CTLineRef line = NULL;
        
        NSAttributedString *truncationTokenString = [[NSAttributedString alloc] initWithString:tokenString attributes:truncationTokenAttributes];
        CTLineRef truncationToken = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)truncationTokenString);
        
        CTLineRef originalLine = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)string);
        if (CTLineGetTypographicBounds(originalLine, NULL, NULL, NULL) - (float)CTLineGetTrailingWhitespaceWidth(originalLine) <= maxWidth)
            line = originalLine;
        else
        {
            line = CTLineCreateTruncatedLine(originalLine, maxWidth, kCTLineTruncationEnd, truncationToken);
            CFRelease(originalLine);
        }
        
        if (line != NULL)
        {
            CGFloat lineWidth = (float)CTLineGetTypographicBounds(line, NULL, NULL, NULL) - (float)CTLineGetTrailingWhitespaceWidth(line);
            
            TGLinePosition linePosition = {.offset = 0.0f + fontLineHeight, .horizontalOffset = 0.0f, .alignment = 0, .lineWidth = lineWidth};
            pLineOrigins->push_back(linePosition);
            
            layout.size = CGSizeMake(lineWidth, fontLineSpacing);
            layout.drawingSize = layout.size;
            
            [textLines addObject:(__bridge id)line];
            layout.textLines = textLines;
            
            CFRelease(line);
        }
        
        resultLines = textLines;
        resultRect = rect;
    }
    
    if (!layout.links->empty())
    {
        std::vector<TGLinkData>::iterator linksBegin = layout.links->begin();
        std::vector<TGLinkData>::iterator linksEnd = layout.links->end();
        
        CGSize layoutSize = layout.size;
        layoutSize.height -= 1;
        
        int numberOfLines = resultLines.count;
        for (int iLine = 0; iLine < numberOfLines; iLine++)
        {
            CTLineRef line = (__bridge CTLineRef)[resultLines objectAtIndex:iLine];
            CFRange lineRange = CTLineGetStringRange(line);
            
            TGLinePosition const &linePosition = pLineOrigins->at(iLine);
            CGPoint lineOrigin = CGPointMake(linePosition.alignment == 0 ? 0.0f : ((float)CTLineGetPenOffsetForFlush(line, linePosition.alignment == 1 ? 0.5f : 1.0f, resultRect.size.width)) + linePosition.horizontalOffset, linePosition.offset);
            
            for (std::vector<TGLinkData>::iterator it = linksBegin; it != linksEnd; it++)
            {
                NSRange intersectionRange = NSIntersectionRange(it->range, NSMakeRange(lineRange.location, lineRange.length));
                if (intersectionRange.length != 0)
                {
                    float startX = 0.0f;
                    float endX = 0.0f;
                 
                    if (resultHadRTL)
                    {
                        bool appliedAnyPosition = false;
                        
                        CFArrayRef glyphRuns = CTLineGetGlyphRuns(line);
                        int glyphRunCount = CFArrayGetCount(glyphRuns);
                        for (int iRun = 0; iRun < glyphRunCount; iRun++)
                        {
                            CTRunRef run = (CTRunRef)CFArrayGetValueAtIndex(glyphRuns, iRun);
                            CFIndex glyphCount = CTRunGetGlyphCount(run);
                            if (glyphCount > 0)
                            {
                                CFIndex startIndex = 0;
                                CFIndex endIndex = 0;
                                
                                CTRunGetStringIndices(run, CFRangeMake(0, 1), &startIndex);
                                CTRunGetStringIndices(run, CFRangeMake(glyphCount - 1, 1), &endIndex);
                                
                                if (startIndex >= it->range.location && endIndex < it->range.location + it->range.length)
                                {
                                    CGPoint leftPosition = CGPointZero;
                                    CGPoint rightPosition = CGPointZero;
                                    
                                    CTRunGetPositions(run, CFRangeMake(0, 1), &leftPosition);
                                    float runWidth = (float)CTRunGetTypographicBounds(run, CFRangeMake(0, glyphCount), NULL, NULL, NULL);
                                    rightPosition.x = leftPosition.x + runWidth;
                                    
                                    if (!appliedAnyPosition)
                                    {
                                        appliedAnyPosition = true;
                                        
                                        startX = leftPosition.x;
                                        endX = rightPosition.x;
                                    }
                                    else
                                    {
                                        if (leftPosition.x < startX)
                                            startX = leftPosition.x;
                                        if (rightPosition.x > endX)
                                            endX = rightPosition.x;
                                    }
                                }
                            }
                        }
                        
                        startX = floorf(startX + lineOrigin.x);
                        endX = ceilf(endX + lineOrigin.x);
                    }
                    else
                    {
                        startX = ceilf(CTLineGetOffsetForStringIndex(line, intersectionRange.location, NULL) + lineOrigin.x);
                        endX = ceilf(CTLineGetOffsetForStringIndex(line, intersectionRange.location + intersectionRange.length, NULL) + lineOrigin.x);
                    }
                    
                    if (startX > endX)
                    {
                        float tmp = startX;
                        startX = endX;
                        endX = tmp;
                    }
                    
                    bool tillEndOfLine = false;
                    if (intersectionRange.location + intersectionRange.length >= lineRange.location + lineRange.length && ABS(endX - layoutSize.width) < 16)
                    {
                        tillEndOfLine = true;
                        endX = layoutSize.width + lineOrigin.x;
                    }
                    CGRect region = CGRectMake(ceilf(startX - 3), ceilf(lineOrigin.y - fontLineHeight + fontLineHeight * 0.1f), ceilf(endX - startX + 6), ceilf(fontLineSpacing));
                    
                    if (it->topRegion.size.height == 0)
                        it->topRegion = region;
                    else
                    {
                        if (it->middleRegion.size.height == 0)
                            it->middleRegion = region;
                        else if (intersectionRange.location == lineRange.location && intersectionRange.length == lineRange.length && tillEndOfLine)
                            it->middleRegion.size.height += region.size.height;
                        else
                            it->bottomRegion = region;
                    }
                }
            }
        }
    }
    
    if (pLinkRanges != NULL)
        delete pLinkRanges;
    
    if (outIsRTL != NULL)
        *outIsRTL = resultHadRTL;
    
    return layout;
}

- (void)drawRect:(CGRect)__unused rect
{
    if (_richText)
        [TGReusableLabel drawRichTextInRect:self.bounds precalculatedLayout:_precalculatedLayout linesRange:NSMakeRange(0, 0) shadowColor:_shadowColor shadowOffset:_shadowOffset];
    else
        [TGReusableLabel drawTextInRect:self.bounds text:_text richText:_richText font:_font highlighted:_highlighted textColor:_textColor highlightedColor:_highlightedTextColor shadowColor:_shadowColor shadowOffset:_shadowOffset numberOfLines:_numberOfLines];
}

+ (void)drawTextInRect:(CGRect)rect text:(NSString *)text richText:(bool)richText font:(UIFont *)font highlighted:(bool)highlighted textColor:(UIColor *)textColor highlightedColor:(UIColor *)highlightedColor shadowColor:(UIColor *)shadowColor shadowOffset:(CGSize)shadowOffset numberOfLines:(int)numberOfLines
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (!richText)
    {
        CGContextSetFillColorWithColor(context, ((highlighted && highlightedColor != nil) ? highlightedColor : textColor).CGColor);
        
        UIColor *shadow = highlighted ? nil : shadowColor;
        if (shadowColor != nil)
            CGContextSetShadowWithColor(context, shadowOffset, 0, shadow.CGColor);
        
        CGRect textRect = rect;
        [text drawInRect:textRect withFont:font lineBreakMode:(numberOfLines == 0 ? UILineBreakModeWordWrap : UILineBreakModeTailTruncation)];
    }
}

+ (void)drawRichTextInRect:(CGRect)rect precalculatedLayout:(TGReusableLabelLayoutData *)precalculatedLayout linesRange:(NSRange)linesRange shadowColor:(UIColor *)shadowColor shadowOffset:(CGSize)shadowOffset
{
    CFArrayRef lines = (__bridge CFArrayRef)precalculatedLayout.textLines;
    if (lines == nil)
    {
#if TARGET_IPHONE_SIMULATOR
        TGLog(@"%s:%d: warning: lines is nil", __PRETTY_FUNCTION__, __LINE__);
#endif
        
        return;
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    if (shadowColor != nil)
        CGContextSetShadowWithColor(context, shadowOffset, 0, shadowColor.CGColor);
    
    CGContextSetTextMatrix(context, CGAffineTransformMakeScale(1.0f, -1.0f));
    CGContextTranslateCTM(context, rect.origin.x, rect.origin.y);
    
    CGRect clipRect = CGContextGetClipBoundingBox(context);
    
    NSInteger numberOfLines = CFArrayGetCount(lines);
    
    if (linesRange.length == 0)
        linesRange = NSMakeRange(0, numberOfLines);
    
    const std::vector<TGLinePosition> *pLineOrigins = precalculatedLayout.lineOrigins;
    
    CGFloat lineHeight = 64.0f;
    if (pLineOrigins->size() >= 2)
        lineHeight = ABS(pLineOrigins->at(0).offset - pLineOrigins->at(1).offset);
    
    CGFloat upperOriginBound = clipRect.origin.y;
    CGFloat lowerOriginBound = clipRect.origin.y + clipRect.size.height + lineHeight;
    
    for (CFIndex lineIndex = linesRange.location; lineIndex < linesRange.location + linesRange.length; lineIndex++)
    {
        CTLineRef line = (CTLineRef)CFArrayGetValueAtIndex(lines, lineIndex);
        
        TGLinePosition const &linePosition = pLineOrigins->at(lineIndex);
        
        CGFloat horizontalOffset = 0.0f;
        switch (linePosition.alignment)
        {
            case 1:
                horizontalOffset = CGFloor((rect.size.width - linePosition.lineWidth) / 2.0f);
                break;
            case 2:
                horizontalOffset = rect.size.width - linePosition.lineWidth;
                break;
            default:
                break;
        }
        
        CGPoint lineOrigin = CGPointMake(horizontalOffset + linePosition.horizontalOffset, linePosition.offset);
        
        if (lineOrigin.y < upperOriginBound || lineOrigin.y > lowerOriginBound)
            continue;
        
        CGContextSetTextPosition(context, lineOrigin.x, lineOrigin.y);
        CTLineDraw(line, context);
    }

    CGContextRestoreGState(context);
}

@end
