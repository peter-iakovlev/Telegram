#import "TGReusableLabel.h"

#import "TGStringUtils.h"

#import <CoreText/CoreText.h>

#import "NSObject+TGLock.h"

#include <unordered_map>
#include <unordered_set>
#include <vector>

#import "TGDateUtils.h"
#import "TGFont.h"

#import "TGTextCheckingResult.h"
#import "TGMessage.h"

@interface TGReusableLabelLayoutData ()
{
    std::unordered_map<int, std::unordered_map<int, int> > _lineOffsets;
    std::vector<TGLinePosition> _lineOrigins;
    
    std::vector<TGLinkData> _links;
}

@property (nonatomic, strong) NSArray *textLines;
@property (nonatomic) CGSize drawingSize;
@property (nonatomic) CGPoint drawingOffset;
@property (nonatomic, strong) NSString *text;

@property (nonatomic) CGFloat fontLineHeight;
@property (nonatomic) CGFloat fontLineSpacing;

- (std::unordered_map<int, std::unordered_map<int, int> > *)lineOffsets;

@end

@implementation TGReusableLabelLayoutData


- (std::unordered_map<int, std::unordered_map<int, int> > *)lineOffsets
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

- (NSString *)linkAtPoint:(CGPoint)point topRegion:(CGRect *)topRegion middleRegion:(CGRect *)middleRegion bottomRegion:(CGRect *)bottomRegion hiddenLink:(bool *)hiddenLink linkText:(NSString *__autoreleasing *)linkText
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
                if (hiddenLink) {
                    *hiddenLink = it->hidden;
                }
                if (linkText) {
                    *linkText = it->text;
                }
                return it->url;
            }
        }
    }
    return nil;
}

- (void)enumerateSearchRegionsForString:(NSString *)string withBlock:(void (^)(CGRect))block
{
    if (string.length == 0)
        return;
    
    static NSCharacterSet *alphaSet = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        alphaSet = [NSCharacterSet alphanumericCharacterSet];
    });
    
    NSUInteger length = _text.length;
    for (NSUInteger offset = 0; offset != NSNotFound && offset < length; )
    {
        NSRange range = [_text rangeOfString:string options:NSCaseInsensitiveSearch range:NSMakeRange(offset, length - offset)];
        if (range.location == NSNotFound)
            break;
        offset = range.location + range.length;
        if (range.location > 0)
        {
            unichar c = [_text characterAtIndex:range.location - 1];
            if ([alphaSet characterIsMember:c])
                continue;
        }
        
        int lineIndex = -1;
        for (id bridgedLine in _textLines)
        {
            lineIndex++;
            CTLineRef line = (__bridge CTLineRef)bridgedLine;
            
            CFRange lineRange = CTLineGetStringRange(line);
            CGPoint lineOrigin = CGPointMake(_lineOrigins[lineIndex].horizontalOffset, _lineOrigins[lineIndex].offset);
            
            NSRange intersectionRange = NSIntersectionRange(range, NSMakeRange(lineRange.location, lineRange.length));
            if (intersectionRange.length != 0)
            {
                CGFloat startX = 0.0f;
                CGFloat endX = 0.0f;
                
                /*if (resultHadRTL)
                {
                    bool appliedAnyPosition = false;
                    
                    CFArrayRef glyphRuns = CTLineGetGlyphRuns(line);
                    int glyphRunCount = (int)CFArrayGetCount(glyphRuns);
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
                            
                            if (startIndex >= (CFIndex)it->range.location && endIndex < (CFIndex)(it->range.location + it->range.length))
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
                    
                    startX = CGFloor(startX + lineOrigin.x);
                    endX = CGCeil(endX + lineOrigin.x);
                }
                else*/
                {
                    startX = CGCeil(CTLineGetOffsetForStringIndex(line, intersectionRange.location, NULL) + lineOrigin.x);
                    endX = CGCeil(CTLineGetOffsetForStringIndex(line, intersectionRange.location + intersectionRange.length, NULL) + lineOrigin.x);
                }
                
                if (startX > endX)
                {
                    CGFloat tmp = startX;
                    startX = endX;
                    endX = tmp;
                }
                
                /*bool tillEndOfLine = false;
                if (intersectionRange.location + intersectionRange.length >= (NSUInteger)(lineRange.location + lineRange.length) && ABS(endX - layoutSize.width) < 16)
                {
                    tillEndOfLine = true;
                    endX = layoutSize.width + lineOrigin.x;
                }*/
                CGRect region = CGRectMake(CGCeil(startX - 3), CGCeil(lineOrigin.y - _fontLineHeight + _fontLineHeight * 0.1f), CGCeil(endX - startX + 6), CGCeil(_fontLineSpacing));
                if (block)
                    block(region);
            }
        }
    }
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

+ (TGReusableLabelLayoutData *)calculateLayout:(NSString *)text additionalAttributes:(NSArray *)additionalAttributes textCheckingResults:(NSArray *)textCheckingResults font:(CTFontRef)font textColor:(UIColor *)textColor frame:(CGRect)frame orMaxWidth:(float)maxWidth flags:(int)flags textAlignment:(NSTextAlignment)textAlignment outIsRTL:(bool *)outIsRTL
{
    return [self calculateLayout:text additionalAttributes:additionalAttributes textCheckingResults:textCheckingResults font:font textColor:textColor frame:frame orMaxWidth:maxWidth flags:flags textAlignment:textAlignment outIsRTL:outIsRTL additionalTrailingWidth:0.0f maxNumberOfLines:0 numberOfLinesToInset:0 linesInset:0.0f containsEmptyNewline:NULL additionalLineSpacing:0.0f ellipsisString:nil];
}

+ (TGReusableLabelLayoutData *)calculateLayout:(NSString *)text additionalAttributes:(NSArray *)additionalAttributes textCheckingResults:(NSArray *)textCheckingResults font:(CTFontRef)font textColor:(UIColor *)textColor frame:(CGRect)frame orMaxWidth:(float)maxWidth flags:(int)flags textAlignment:(NSTextAlignment)textAlignment outIsRTL:(bool *)outIsRTL additionalTrailingWidth:(CGFloat)additionalTrailingWidth maxNumberOfLines:(NSUInteger)maxNumberOfLines numberOfLinesToInset:(NSUInteger)numberOfLinesToInset linesInset:(CGFloat)linesInset containsEmptyNewline:(bool *)containsEmptyNewline additionalLineSpacing:(CGFloat)additionalLineSpacing ellipsisString:(NSString *)ellipsisString
{
    if (font == NULL || text == nil)
        return nil;
    
    bool justify = textAlignment == NSTextAlignmentJustified;
    if (justify) {
        textAlignment = NSTextAlignmentLeft;
    }
    
    static bool needToOffsetEmoji = false;
    static bool needToOffsetEmojiInitialized = false;
    static bool enableUnderline = true;
    if (!needToOffsetEmojiInitialized)
    {
        needToOffsetEmojiInitialized = true;
        needToOffsetEmoji = iosMajorVersion() < 6;
        enableUnderline = !(iosMajorVersion() == 7 && (iosMinorVersion() == 0 || iosMinorVersion() == 1));
    }
    
    TGReusableLabelLayoutData *layout = [[TGReusableLabelLayoutData alloc] init];
    layout.text = text;
    
    CGFloat fontSize = CTFontGetSize(font);
    CGFloat fontAscent = CTFontGetAscent(font);
    CGFloat fontDescent = CTFontGetDescent(font);
    
    CGFloat fontLineHeight = CGFloor(fontAscent + fontDescent);
    CGFloat fontLineSpacing = CGFloor(fontLineHeight * 1.12f + additionalLineSpacing);
    
    layout.fontLineHeight = fontLineHeight;
    layout.fontLineSpacing = fontLineSpacing;
    
    NSMutableDictionary *attributes = [[NSMutableDictionary alloc] initWithObjectsAndKeys:(__bridge id)font, (NSString *)kCTFontAttributeName, nil];
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:text attributes:attributes];
    
    if (textColor != NULL)
        CFAttributedStringSetAttribute((CFMutableAttributedStringRef)string, CFRangeMake(0, string.length), kCTForegroundColorAttributeName, textColor.CGColor);
    
    if (additionalAttributes != nil)
    {
        int count = (int)additionalAttributes.count;
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
    
    CTFontRef boldFont = NULL;
    CTFontRef ultraBoldFont = NULL;
    CTFontRef italicFont = NULL;
    CTFontRef fixedFont = NULL;
    
    CGColorRef linkColor = defaultLinkColor;
    
    NSRange *pLinkRanges = NULL;
    int linkRangeActualCount = 0;
    
    if (textCheckingResults != nil && textCheckingResults.count != 0)
    {
        NSNumber *underlineStyle = [[NSNumber alloc] initWithInt:kCTUnderlineStyleSingle];
        
        int index = -1;
        for (id match in textCheckingResults)
        {
            NSRange linkRange = [match range];
            
            bool useRange = false;
            bool useRangeUnderline = false;
            
            if ([match isKindOfClass:[NSTextCheckingResult class]])
            {
                NSString *url = ((NSTextCheckingResult *)match).resultType == NSTextCheckingTypePhoneNumber ? [[NSString alloc] initWithFormat:@"tel:%@", ((NSTextCheckingResult *)match).phoneNumber] : [((NSTextCheckingResult *)match).URL absoluteString];
                bool hidden = [(NSTextCheckingResult *)match isTelegramHiddenLink];
                NSString *linkText = nil;
                if (linkRange.location < text.length) {
                    NSRange fixedLinkRange = NSMakeRange(linkRange.location, MIN(text.length - linkRange.location, linkRange.location + linkRange.length));
                    if (fixedLinkRange.length > 0) {
                        linkText = [text substringWithRange:fixedLinkRange];
                    }
                }
                layout.links->push_back(TGLinkData(linkRange, url, linkText, hidden));
                
                if (flags & TGReusableLabelLayoutHighlightLinks)
                {
                    CFAttributedStringSetAttribute((CFMutableAttributedStringRef)string, CFRangeMake(linkRange.location, linkRange.length), kCTForegroundColorAttributeName, linkColor);
                    
                    if (enableUnderline) {
                        CFAttributedStringSetAttribute((CFMutableAttributedStringRef)string, CFRangeMake(linkRange.location, linkRange.length), kCTUnderlineStyleAttributeName, (CFNumberRef)underlineStyle);
                    }
                }
                
                useRange = true;
            }
            else if ([match isKindOfClass:[TGTextCheckingResult class]])
            {
                NSString *url = nil;
                
                switch (((TGTextCheckingResult *)match).type)
                {
                    case TGTextCheckingResultTypeMention:
                    {
                        url = [[NSString alloc] initWithFormat:@"mention://%@", ((TGTextCheckingResult *)match).contents];
                        useRange = true;
                        break;
                    }
                    case TGTextCheckingResultTypeHashtag:
                    {
                        useRange = true;
                        url = [[NSString alloc] initWithFormat:@"hashtag://%@", ((TGTextCheckingResult *)match).contents];
                        break;
                    }
                    case TGTextCheckingResultTypeCommand:
                    {
                        if (flags & TGReusableLabelLayoutHighlightCommands)
                        {
                            useRange = true;
                            url = [[NSString alloc] initWithFormat:@"command://%@", ((TGTextCheckingResult *)match).contents];
                        }
                        break;
                    }
                    case TGTextCheckingResultTypeCode:
                    {
                        if (fixedFont == nil) {
                            fixedFont = TGCoreTextFixedFontOfSize(fontSize);
                        }
                        
                        CFAttributedStringSetAttribute((CFMutableAttributedStringRef)string, CFRangeMake(linkRange.location, linkRange.length), kCTFontAttributeName, fixedFont);
                        
                        break;
                    }
                    case TGTextCheckingResultTypeItalic:
                    {
                        if (italicFont == nil) {
                            italicFont = TGCoreTextItalicFontOfSize(fontSize);
                        }
                        
                        CFAttributedStringSetAttribute((CFMutableAttributedStringRef)string, CFRangeMake(linkRange.location, linkRange.length), kCTFontAttributeName, italicFont);
                        
                        break;
                    }
                    case TGTextCheckingResultTypeBold:
                    {
                        if (boldFont == nil) {
                            boldFont = TGCoreTextBoldFontOfSize(fontSize);
                        }
                        
                        CFAttributedStringSetAttribute((CFMutableAttributedStringRef)string, CFRangeMake(linkRange.location, linkRange.length), kCTFontAttributeName, boldFont);
                        
                        break;
                    }
                    case TGTextCheckingResultTypeColor:
                    {
                        if (((TGTextCheckingResult *)match).value != nil) {
                            UIColor *color = ((TGTextCheckingResult *)match).value;
                            CFAttributedStringSetAttribute((CFMutableAttributedStringRef)string, CFRangeMake(linkRange.location, linkRange.length), kCTForegroundColorAttributeName, color.CGColor);
                        }
                        
                        break;
                    }
                    case TGTextCheckingResultTypeUltraBold:
                    {
                        if (ultraBoldFont == nil) {
                            ultraBoldFont = TGCoreTextBoldFontOfSize(fontSize);
                        }
                        
                        CFAttributedStringSetAttribute((CFMutableAttributedStringRef)string, CFRangeMake(linkRange.location, linkRange.length), kCTFontAttributeName, ultraBoldFont);
                        
                        break;
                    }
                    case TGTextCheckingResultTypeLink:
                    {
                        url = ((TGTextCheckingResult *)match).contents;
                        useRange = true;
                        useRangeUnderline = ((TGTextCheckingResult *)match).highlightAsLink;
                        
                        break;
                    }
                }
                
                if (useRange)
                {
                    NSString *linkText = nil;
                    if (linkRange.location < text.length) {
                        NSRange fixedLinkRange = NSMakeRange(linkRange.location, MIN(text.length - linkRange.location, linkRange.location + linkRange.length));
                        if (fixedLinkRange.length > 0) {
                            linkText = [text substringWithRange:fixedLinkRange];
                        }
                    }
                    layout.links->push_back(TGLinkData(linkRange, url, linkText, false));
                
                    if (flags & TGReusableLabelLayoutHighlightLinks)
                    {
                        CFAttributedStringSetAttribute((CFMutableAttributedStringRef)string, CFRangeMake(linkRange.location, linkRange.length), kCTForegroundColorAttributeName, linkColor);
                        
                        if (enableUnderline && useRangeUnderline) {
                            CFAttributedStringSetAttribute((CFMutableAttributedStringRef)string, CFRangeMake(linkRange.location, linkRange.length), kCTUnderlineStyleAttributeName, (CFNumberRef)underlineStyle);
                        }
                    }
                }
            }
            
            if (useRange)
            {
                if (pLinkRanges == NULL)
                {
                    pLinkRanges = new NSRange[(int)textCheckingResults.count];
                }
                
                pLinkRanges[++index] = linkRange;
                linkRangeActualCount++;
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
        
        CGFloat lastLineWidth = 0.0f;
        
        CTTypesetterRef typesetter = CTTypesetterCreateWithAttributedString((__bridge CFAttributedStringRef)string);
        
        CFIndex lastIndex = 0;
        float currentLineOffset = 0;
        
        while (true)
        {
            CGFloat currentMaxWidth = maxWidth;
            CGFloat currentLineInset = 0.0f;
            if (numberOfLinesToInset != 0 && textLines.count < numberOfLinesToInset)
            {
                currentMaxWidth -= linesInset;
                currentLineInset = linesInset;
            }
            
            CFIndex lineCharacterCount = CTTypesetterSuggestLineBreak(typesetter, lastIndex, currentMaxWidth);
            
            if (pLinkRanges != NULL && flags & TGReusableLabelLayoutHighlightLinks)
            {
                CFIndex endIndex = lastIndex + lineCharacterCount;
                
                for (int i = 0; i < linkRangeActualCount; i++)
                {
                    if (pLinkRanges[i].location < (NSUInteger)endIndex && pLinkRanges[i].location + pLinkRanges[i].length >= (NSUInteger)endIndex)
                    {
                        lineCharacterCount = MAX(lineCharacterCount, CTTypesetterSuggestClusterBreak(typesetter, lastIndex, currentMaxWidth));
                        
                        if (pLinkRanges[i].location > (NSUInteger)lastIndex && lineCharacterCount < (CFIndex)(pLinkRanges[i].location + pLinkRanges[i].length - (NSUInteger)lastIndex))
                        {
                            lineCharacterCount = pLinkRanges[i].location - lastIndex;
                        }
                        
                        break;
                    }
                }
            }
            
            if (lineCharacterCount > 0)
            {
                CTLineRef line = NULL;
                
                if (maxNumberOfLines != 0 && textLines.count == maxNumberOfLines - 1)
                {
                    CTLineRef originalLine = CTTypesetterCreateLineWithOffset(typesetter, CFRangeMake(lastIndex, MAX(lineCharacterCount, (CFIndex)text.length - lastIndex)), 100.0);
                    
                    if (CTLineGetTypographicBounds(originalLine, NULL, NULL, NULL) - (float)CTLineGetTrailingWhitespaceWidth(originalLine) <= currentMaxWidth)
                        line = originalLine;
                    else
                    {
                        NSMutableDictionary *truncationTokenAttributes = [[NSMutableDictionary alloc] initWithObjectsAndKeys:(__bridge id)font, (NSString *)kCTFontAttributeName, (__bridge id)textColor.CGColor, (NSString *)kCTForegroundColorAttributeName, nil];
                        
                        static NSString *tokenString = nil;
                        if (tokenString == nil)
                        {
                            unichar tokenChar = 0x2026;
                            tokenString = [[NSString alloc] initWithCharacters:&tokenChar length:1];
                        }
                        
                        NSAttributedString *truncationTokenString = [[NSAttributedString alloc] initWithString:ellipsisString == nil ? tokenString : ellipsisString attributes:truncationTokenAttributes];
                        CTLineRef truncationToken = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)truncationTokenString);
                        
                        line = CTLineCreateTruncatedLine(originalLine, currentMaxWidth, (flags & TGReusableLabelTruncateInTheMiddle) ? kCTLineTruncationMiddle : kCTLineTruncationEnd, truncationToken);
                        CFRelease(originalLine);
                        CFRelease(truncationToken);
                    }
                }
                else
                {
                    line = CTTypesetterCreateLineWithOffset(typesetter, CFRangeMake(lastIndex, lineCharacterCount), 100.0);
                }
                
                if (line != NULL)
                {
                    [textLines addObject:(__bridge id)line];
                
                    bool rightAligned = false;
                    
                    CFArrayRef glyphRuns = CTLineGetGlyphRuns(line);
                    if (CFArrayGetCount(glyphRuns) != 0)
                    {
                        if (CTRunGetStatus((CTRunRef)CFArrayGetValueAtIndex(glyphRuns, 0)) & kCTRunStatusRightToLeft)
                            rightAligned = true;
                    }
                    
                    hadRTL |= rightAligned;
                    
                    CGFloat lineWidth = (CGFloat)CTLineGetTypographicBounds(line, NULL, NULL, NULL) - (CGFloat)CTLineGetTrailingWhitespaceWidth(line) + currentLineInset;
                    
                    TGLinePosition linePosition = {.offset = (CGFloat)(currentLineOffset + fontLineHeight), .horizontalOffset = 0.0f, .alignment = (uint8_t)(textAlignment == NSTextAlignmentCenter ? 1 : (rightAligned ? 2 : 0)), .lineWidth = lineWidth};
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
            else
                break;
            
            if (maxNumberOfLines != 0 && textLines.count == maxNumberOfLines)
                break;
        }
        
        if (additionalTrailingWidth > FLT_EPSILON)
        {
            if (textLines.count == 1)
            {
                if (lastLineWidth + additionalTrailingWidth <= maxWidth)
                {
                    rect.size.width += additionalTrailingWidth;
                    if (pLineOrigins->at(textLines.count - 1).alignment == 2)
                    {
                        pLineOrigins->at(textLines.count - 1).horizontalOffset -= additionalTrailingWidth;
                    }
                }
                else
                {
                    rect.size.height += fontLineHeight * 0.7f;
                    if (containsEmptyNewline)
                        *containsEmptyNewline = true;
                }
            }
            else if (textLines.count != 0)
            {
                if (rect.size.width - lastLineWidth < additionalTrailingWidth)
                {
                    if (lastLineWidth + additionalTrailingWidth <= maxWidth)
                    {
                        if (pLineOrigins->at(textLines.count - 1).alignment == 2)
                        {
                            rect.size.height += fontLineHeight * 0.7f;
                            if (containsEmptyNewline)
                                *containsEmptyNewline = true;
                            rect.size.width = MAX(rect.size.width, additionalTrailingWidth - 12);
                        }
                        else
                            rect.size.width = lastLineWidth + additionalTrailingWidth;
                    }
                    else
                    {
                        rect.size.height += fontLineHeight * 0.7f;
                        if (containsEmptyNewline)
                            *containsEmptyNewline = true;
                    
                        if (rect.size.width < additionalTrailingWidth - 12)
                            rect.size.width = additionalTrailingWidth - 12;
                    }
                }
                else
                {
                    if (pLineOrigins->at(textLines.count - 1).alignment == 2)
                    {
                        rect.size.height += fontLineHeight * 0.7f;
                        if (containsEmptyNewline)
                            *containsEmptyNewline = true;
                    }
                }
            }
        }
        
        if ((flags & TGReusableLabelLayoutOffsetLastLine) && textLines.count != 0) {
            pLineOrigins->at(textLines.count - 1).offset += 2.0f;
            rect.size.height += 3.0f;
        }
        
        layout.size = CGSizeMake(CGFloor(rect.size.width), CGFloor(rect.size.height + fontLineHeight * 0.1f));
        layout.drawingSize = rect.size;
        
        if (justify) {
            NSMutableArray *justifiedLines = [[NSMutableArray alloc] init];
            for (NSInteger i = 0; i < (NSInteger)textLines.count; i++) {
                if (i != (NSInteger)textLines.count - 1) {
                    CGFloat width = layout.size.width;
                    if (i < (NSInteger)numberOfLinesToInset) {
                        width -= linesInset;
                    }
                    
                    CTLineRef line = CTLineCreateJustifiedLine((__bridge CTLineRef)textLines[i], 1.0f, width);
                    if (line != NULL) {
                        [justifiedLines addObject:(__bridge id)line];
                        CFRelease(line);
                    } else {
                        [justifiedLines addObject:textLines[i]];
                    }
                } else {
                    [justifiedLines addObject:textLines[i]];
                }
            }
            textLines = justifiedLines;
        }
        
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
        
        NSAttributedString *truncationTokenString = [[NSAttributedString alloc] initWithString:ellipsisString == nil ? tokenString : ellipsisString attributes:truncationTokenAttributes];
        CTLineRef truncationToken = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)truncationTokenString);
        
        CTLineRef originalLine = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)string);
        if (CTLineGetTypographicBounds(originalLine, NULL, NULL, NULL) - (float)CTLineGetTrailingWhitespaceWidth(originalLine) <= maxWidth)
            line = originalLine;
        else
        {
            line = CTLineCreateTruncatedLine(originalLine, maxWidth, (flags & TGReusableLabelTruncateInTheMiddle) ? kCTLineTruncationMiddle : kCTLineTruncationEnd, truncationToken);
            CFRelease(originalLine);
        }
        
        CFRelease(truncationToken);
        
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
        
        int numberOfLines = (int)resultLines.count;
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
                    CGFloat startX = 0.0f;
                    CGFloat endX = 0.0f;
                 
                    if (resultHadRTL)
                    {
                        bool appliedAnyPosition = false;
                        
                        CFArrayRef glyphRuns = CTLineGetGlyphRuns(line);
                        int glyphRunCount = (int)CFArrayGetCount(glyphRuns);
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
                                
                                if (startIndex >= (CFIndex)it->range.location && endIndex < (CFIndex)(it->range.location + it->range.length))
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
                        
                        startX = CGFloor(startX + lineOrigin.x);
                        endX = CGCeil(endX + lineOrigin.x);
                    }
                    else
                    {
                        startX = CGCeil(CTLineGetOffsetForStringIndex(line, intersectionRange.location, NULL) + lineOrigin.x);
                        endX = CGCeil(CTLineGetOffsetForStringIndex(line, intersectionRange.location + intersectionRange.length, NULL) + lineOrigin.x);
                    }
                    
                    if (startX > endX)
                    {
                        CGFloat tmp = startX;
                        startX = endX;
                        endX = tmp;
                    }
                    
                    bool tillEndOfLine = false;
                    if (intersectionRange.location + intersectionRange.length >= (NSUInteger)(lineRange.location + lineRange.length) && ABS(endX - layoutSize.width) < 16)
                    {
                        tillEndOfLine = true;
                        endX = layoutSize.width + lineOrigin.x;
                    }
                    CGRect region = CGRectMake(CGCeil(startX - 3), CGCeil(lineOrigin.y - fontLineHeight + fontLineHeight * 0.1f), CGCeil(endX - startX + 6), CGCeil(fontLineSpacing));
                    
                    if (it->topRegion.size.height == 0)
                        it->topRegion = region;
                    else
                    {
                        if (it->middleRegion.size.height == 0)
                            it->middleRegion = region;
                        else if (intersectionRange.location == (NSUInteger)lineRange.location && intersectionRange.length == (NSUInteger)lineRange.length && tillEndOfLine)
                            it->middleRegion.size.height += region.size.height;
                        else
                            it->bottomRegion = region;
                    }
                }
            }
        }
    }
    
    if (pLinkRanges != NULL)
        delete[] pLinkRanges;
    
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
        [text drawInRect:textRect withFont:font lineBreakMode:(numberOfLines == 0 ? NSLineBreakByWordWrapping : NSLineBreakByTruncatingTail)];
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
    
    CGFloat upperOriginBound = clipRect.origin.y - lineHeight;
    CGFloat lowerOriginBound = clipRect.origin.y + clipRect.size.height + lineHeight + lineHeight;
    
    for (CFIndex lineIndex = linesRange.location; lineIndex < (CFIndex)(linesRange.location + linesRange.length); lineIndex++)
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
