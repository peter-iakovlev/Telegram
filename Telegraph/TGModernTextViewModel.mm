#import "TGModernTextViewModel.h"

#import "TGModernTextView.h"

#import "TGReusableLabel.h"

@implementation TGModernTextViewLinesInset

- (instancetype)initWithNumberOfLinesToInset:(NSUInteger)numberOfLinesToInset inset:(CGFloat)inset
{
    self = [super init];
    if (self != nil)
    {
        _numberOfLinesToInset = numberOfLinesToInset;
        _inset = inset;
    }
    return self;
}

@end

@interface TGModernTextViewModel ()
{
    TGReusableLabelLayoutData *_layoutData;
    CGFloat _cachedLayoutContainerWidth;
    int _cachedLayoutFlags;
    CGFloat _cachedAdditionalTrailingWidth;
}

@end

@implementation TGModernTextViewModel

- (instancetype)initWithText:(NSString *)text font:(CTFontRef)font
{
    self = [super init];
    if (self != nil)
    {
        if (text.length != 0)
            _text = text;
        else
            _text = @" ";
        
        if (font != NULL)
            _font = (CTFontRef)CFRetain(font);
    }
    return self;
}

- (void)dealloc
{
    if (_font != NULL)
    {
        CFRelease(_font);
        _font = NULL;
    }
}

- (Class)viewClass
{
    return [TGModernTextView class];
}

- (void)sizeToFit
{
    
}

- (void)drawInContext:(CGContextRef)context
{
    [super drawInContext:context];
    
    if (_layoutData != nil)
    {
        [TGReusableLabel drawRichTextInRect:self.bounds precalculatedLayout:_layoutData linesRange:NSMakeRange(0, 0) shadowColor:nil shadowOffset:CGSizeZero];
    }
}

- (bool)layoutNeedsUpdatingForContainerSize:(CGSize)containerSize
{
    return [self layoutNeedsUpdatingForContainerSize:containerSize additionalTrailingWidth:_additionalTrailingWidth layoutFlags:_layoutFlags];
}

- (bool)layoutNeedsUpdatingForContainerSize:(CGSize)containerSize additionalTrailingWidth:(CGFloat)additionalTrailingWidth layoutFlags:(int)layoutFlags
{
    if (_layoutData == nil || ABS(containerSize.width - _cachedLayoutContainerWidth) > FLT_EPSILON || _cachedLayoutFlags != layoutFlags || ABS(_cachedAdditionalTrailingWidth - additionalTrailingWidth) > FLT_EPSILON)
    {
        return true;
    }
    return false;
}

- (void)setText:(NSString *)text
{
    if (!TGStringCompare(_text, text))
    {
        _cachedLayoutContainerWidth = 0.0f;
        _cachedLayoutFlags = 0;
        
        if (text.length != 0)
            _text = text;
        else
            _text = @" ";
    }
}

- (void)setFont:(CTFontRef)font
{
    if (_font != font)
    {
        _cachedLayoutContainerWidth = 0.0f;
        _cachedLayoutFlags = 0;
        
        if (_font != NULL)
        {
            CFRelease(_font);
            _font = NULL;
        }
        
        if (font != NULL)
            _font = (CTFontRef)CFRetain(font);
    }
}

- (void)layoutForContainerSize:(CGSize)containerSize
{
    if (_layoutData == nil || ABS(containerSize.width - _cachedLayoutContainerWidth) > FLT_EPSILON || _cachedLayoutFlags != _layoutFlags || ABS(_additionalTrailingWidth - _cachedAdditionalTrailingWidth) > FLT_EPSILON)
    {
        _layoutData = [TGReusableLabel calculateLayout:_text additionalAttributes:_additionalAttributes textCheckingResults:_textCheckingResults font:_font textColor:_textColor frame:CGRectZero orMaxWidth:(float)containerSize.width flags:_layoutFlags textAlignment:(NSTextAlignment)_alignment outIsRTL:&_isRTL additionalTrailingWidth:_additionalTrailingWidth maxNumberOfLines:_maxNumberOfLines numberOfLinesToInset:_linesInset.numberOfLinesToInset linesInset:_linesInset.inset containsEmptyNewline:&_containsEmptyNewline additionalLineSpacing:_additionalLineSpacing ellipsisString:_ellipsisString];
        _cachedLayoutContainerWidth = containerSize.width;
        _cachedLayoutFlags = _layoutFlags;
        _cachedAdditionalTrailingWidth = _additionalTrailingWidth;
    }
    
    CGRect frame = self.frame;
    frame.size = _layoutData.size;
    frame.size.width = CGFloor(frame.size.width);
    frame.size.height = CGFloor(frame.size.height);
    self.frame = frame;
}

- (NSString *)linkAtPoint:(CGPoint)point regionData:(__autoreleasing NSArray **)regionData
{
    return [self linkAtPoint:point regionData:regionData hiddenLink:NULL];
}

- (NSString *)linkAtPoint:(CGPoint)point regionData:(__autoreleasing NSArray **)regionData hiddenLink:(bool *)hiddenLink {
    return [self linkAtPoint:point regionData:regionData hiddenLink:hiddenLink linkText:nil];
}

- (NSString *)linkAtPoint:(CGPoint)point regionData:(__autoreleasing NSArray **)regionData hiddenLink:(bool *)hiddenLink linkText:(__autoreleasing NSString **)linkText
{
    CGRect topRegion = CGRectZero;
    CGRect middleRegion = CGRectZero;
    CGRect bottomRegion = CGRectZero;
    
    NSString *result = [_layoutData linkAtPoint:point topRegion:&topRegion middleRegion:&middleRegion bottomRegion:&bottomRegion hiddenLink:hiddenLink linkText:linkText];
    if (result != nil)
    {
        NSMutableArray *array = [[NSMutableArray alloc] init];
        if (!CGRectIsEmpty(topRegion))
            [array addObject:[NSValue valueWithCGRect:topRegion]];
        if (!CGRectIsEmpty(middleRegion))
            [array addObject:[NSValue valueWithCGRect:middleRegion]];
        if (!CGRectIsEmpty(bottomRegion))
            [array addObject:[NSValue valueWithCGRect:bottomRegion]];
        
        if (regionData != NULL)
            *regionData = array;
    }
    
    return result;
}

- (void)enumerateSearchRegionsForString:(NSString *)string withBlock:(void (^)(CGRect))block
{
    [_layoutData enumerateSearchRegionsForString:string withBlock:block];
}

- (NSUInteger)measuredNumberOfLines
{
    if (_layoutData.lineOrigins == NULL)
        return 0;
    return (NSUInteger)_layoutData.lineOrigins->size();
}

@end
