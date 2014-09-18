#import "TGDateLabel.h"

#import "TGDateUtils.h"

typedef enum {
    TGDateLabelFormatModeNone = 0,
    TGDateLabelFormatModeAm = 1,
    TGDateLabelFormatModePm = 2
} TGDateLabelFormatMode;

@interface TGDateLabel ()
{
    CGSize _measuredTextSize;
    bool _measuredTextSizeIsValid;
}

@property (nonatomic) TGDateLabelFormatMode formatMode;

@end

@implementation TGDateLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
    }
    return self;
}

- (void)setText:(NSString *)text
{
    _measuredTextSizeIsValid = false;
    
    [self setDateText:text];
}

- (void)setDateText:(NSString *)dateText
{
    if (dateText != _dateText)
    {
        _measuredTextSizeIsValid = false;
        
        _rawDateText = dateText;
        
        if (TGUse12hDateFormat())
        {
            bool isAm = [dateText hasSuffix:@" AM"];
            if (isAm || [dateText hasSuffix:@" PM"])
            {
                _dateText = [dateText substringToIndex:dateText.length - 3];
                _formatMode = isAm ? TGDateLabelFormatModeAm : TGDateLabelFormatModePm;
            }
            else
            {
                _dateText = dateText;
                _formatMode = TGDateLabelFormatModeNone;
            }
        }
        else
        {
            _dateText = dateText;
            _formatMode = TGDateLabelFormatModeNone;
        }
        
        [self setNeedsDisplay];
    }
}

- (CGSize)measureTextSize
{
    if (_measuredTextSizeIsValid)
        return _measuredTextSize;
    
    CGSize textSize = [_dateText sizeWithFont:_formatMode != TGDateLabelFormatModeNone ? _dateTextFont : _dateFont];
    if (_formatMode == TGDateLabelFormatModeAm)
        textSize.width += _amWidth;
    else if (_formatMode == TGDateLabelFormatModePm)
        textSize.width += _pmWidth;
    
    _measuredTextSize = textSize;
    _measuredTextSizeIsValid = true;
    return textSize;
}

- (void)setHighlighted:(BOOL)__unused highlighted
{
}

- (void)drawTextInRect:(CGRect)__unused rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    switch (self.textAlignment)
    {
        case NSTextAlignmentCenter:
            CGContextTranslateCTM(context, floorf((self.frame.size.width - _measuredTextSize.width) / 2), 0);
            break;
        default:
            break;
    }
    
    if (self.shadowColor != nil)
        CGContextSetShadowWithColor(context, self.shadowOffset, 0.0f, self.shadowColor.CGColor);
    
    if (_isDisabled)
    {
        if (_disabledColor != nil)
            CGContextSetFillColorWithColor(context, [_disabledColor CGColor]);
        else
        {
            static UIColor *disabledColor = nil;
            if (disabledColor == nil)
                disabledColor = UIColorRGB(0xaeaeae);
            CGContextSetFillColorWithColor(context, disabledColor.CGColor);
        }
    }
    else
    {
        CGContextSetFillColorWithColor(context, self.textColor.CGColor);
    }
    
    [_dateText drawAtPoint:CGPointMake(0, 0) withFont:_formatMode != TGDateLabelFormatModeNone ? _dateTextFont : _dateFont];
    
    if (_formatMode != TGDateLabelFormatModeNone)
        [_formatMode == TGDateLabelFormatModeAm ? @"AM" : @"PM" drawInRect:CGRectMake(0, _dstOffset, _measuredTextSize.width, self.bounds.size.height) withFont:_dateLabelFont lineBreakMode:NSLineBreakByClipping alignment:NSTextAlignmentRight];
}

- (void)drawRect:(CGRect)__unused rect
{
    [self drawTextInRect:self.bounds];
}

@end
