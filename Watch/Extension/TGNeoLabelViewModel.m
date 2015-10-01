#import "TGNeoLabelViewModel.h"

@implementation TGNeoLabelViewModel

- (instancetype)initWithText:(NSString *)text font:(UIFont *)font color:(UIColor *)color attributes:(NSDictionary *)attributes
{
    self = [super init];
    if (self != nil)
    {
        _text = text;
        _multiline = true;
        
        NSMutableDictionary *finalAttributes = [NSMutableDictionary dictionaryWithDictionary:attributes];
        finalAttributes[NSFontAttributeName] = font;
        finalAttributes[NSForegroundColorAttributeName] = color;
        _attributes = finalAttributes;
    }
    return self;
}

- (instancetype)initWithAttributedText:(NSAttributedString *)attributedText
{
    self = [super init];
    if (self != nil)
    {
        _attributedText = attributedText;
    }
    return self;
}

- (CGSize)contentSizeWithContainerSize:(CGSize)containerSize
{
    NSAttributedString *string = nil;
    
    if (_attributedText != nil)
        string = _attributedText;
    else if (self.text.length > 0)
        string = [[NSAttributedString alloc] initWithString:self.text attributes:_attributes];
    else
        string = [[NSAttributedString alloc] initWithString:@" "];
    
    CGSize contentSize = [string boundingRectWithSize:containerSize options:[self _stringDrawingOptions] context:nil].size;
    contentSize.width = ceilf(contentSize.width);
    contentSize.height = ceilf(contentSize.height);

    return contentSize;
}

- (void)drawInContext:(CGContextRef)context
{
    UIGraphicsPushContext(context);
    if (self.attributedText.length > 0)
        [self.attributedText drawWithRect:self.bounds options:[self _stringDrawingOptions] context:nil];
    else if (self.text.length > 0)
        [self.text drawWithRect:self.bounds options:[self _stringDrawingOptions] attributes:self.attributes context:nil];
    UIGraphicsPopContext();
}

- (NSStringDrawingOptions)_stringDrawingOptions
{
    NSStringDrawingOptions options = NSStringDrawingUsesLineFragmentOrigin;
    if (!self.multiline)
        options |= NSStringDrawingTruncatesLastVisibleLine;
    
    return options;
}

@end
