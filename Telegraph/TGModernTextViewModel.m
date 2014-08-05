#import "TGModernTextViewModel.h"

#import "TGModernTextView.h"

#import "TGReusableLabel.h"

@interface TGModernTextViewModel ()
{
    TGReusableLabelLayoutData *_layoutData;
    CGFloat _cachedLayoutContainerWidth;
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
            _font = CFRetain(font);
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
    if (_layoutData == nil || ABS(containerSize.width - _cachedLayoutContainerWidth) > FLT_EPSILON)
        return true;
    return false;
}

- (void)setText:(NSString *)text
{
    if (!TGStringCompare(_text, text))
    {
        _cachedLayoutContainerWidth = 0.0f;
        
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
        
        if (_font != NULL)
        {
            CFRelease(_font);
            _font = NULL;
        }
        
        if (font != NULL)
            _font = CFRetain(font);
    }
}

- (void)layoutForContainerSize:(CGSize)containerSize
{
    if (_layoutData == nil || ABS(containerSize.width - _cachedLayoutContainerWidth) > FLT_EPSILON)
    {
        _layoutData = [TGReusableLabel calculateLayout:_text additionalAttributes:_additionalAttributes textCheckingResults:_textCheckingResults font:_font textColor:_textColor frame:CGRectZero orMaxWidth:containerSize.width flags:_layoutFlags textAlignment:(UITextAlignment)_alignment outIsRTL:&_isRTL additionalTrailingWidth:_additionalTrailingWidth];
        _cachedLayoutContainerWidth = containerSize.width;
    }
    
    CGRect frame = self.frame;
    frame.size = _layoutData.size;
    frame.size.width = CGFloor(frame.size.width);
    frame.size.height = CGFloor(frame.size.height);
    self.frame = frame;
}

- (NSString *)linkAtPoint:(CGPoint)point regionData:(__autoreleasing NSArray **)regionData
{
    CGRect topRegion = CGRectZero;
    CGRect middleRegion = CGRectZero;
    CGRect bottomRegion = CGRectZero;
    
    NSString *result = [_layoutData linkAtPoint:point topRegion:&topRegion middleRegion:&middleRegion bottomRegion:&bottomRegion];
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

@end
