#import "TGModernConversationRestrictedInputPanel.h"

#import "TGFont.h"
#import "TGImageUtils.h"

#import "TGLocalization.h"

@interface TGModernConversationRestrictedInputPanel ()
{
    CALayer *_stripeLayer;
    
    UILabel *_label;
}

@end

@implementation TGModernConversationRestrictedInputPanel

- (CGFloat)baseHeight {
    static CGFloat value = 0.0f;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^ {
        value = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? 45.0f : 56.0f;
    });

    return value;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, [self baseHeight])];
    if (self)
    {
        self.backgroundColor = UIColorRGB(0xf7f7f7);
        
        _stripeLayer = [[CALayer alloc] init];
        _stripeLayer.backgroundColor = UIColorRGB(0xb2b2b2).CGColor;
        [self.layer addSublayer:_stripeLayer];
        
        _label = [[UILabel alloc] init];
        _label.font = TGSystemFontOfSize(13.0f);
        _label.textColor = UIColorRGB(0x8e8e93);
        _label.numberOfLines = 0;
        _label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_label];
    }
    return self;
}

- (void)setTimeout:(int32_t)timeout {
    if (timeout == 0 || timeout == INT32_MAX) {
        _label.text = TGLocalized(@"Conversation.RestrictedText");
    } else {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"E, d MMM HH:mm"];
        formatter.locale = [NSLocale localeWithLocaleIdentifier:effectiveLocalization().code];
        NSString *dateStringPlain = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:timeout]];
        
        _label.text = [NSString stringWithFormat:TGLocalized(@"Conversation.RestrictedTextTimed"), dateStringPlain];
    }
    [self setNeedsLayout];
}

- (void)adjustForSize:(CGSize)size keyboardHeight:(CGFloat)keyboardHeight duration:(NSTimeInterval)duration animationCurve:(int)animationCurve contentAreaHeight:(CGFloat)contentAreaHeight
{
    [self _adjustForSize:size keyboardHeight:keyboardHeight duration:duration animationCurve:animationCurve contentAreaHeight:contentAreaHeight];
}

- (void)_adjustForSize:(CGSize)size keyboardHeight:(CGFloat)keyboardHeight duration:(NSTimeInterval)duration animationCurve:(int)animationCurve contentAreaHeight:(CGFloat)__unused contentAreaHeight
{
    dispatch_block_t block = ^
    {
        CGSize messageAreaSize = size;
        
        self.frame = CGRectMake(0, messageAreaSize.height - keyboardHeight - [self baseHeight], messageAreaSize.width, [self baseHeight]);
        [self layoutSubviews];
    };
    
    if (duration > DBL_EPSILON)
        [UIView animateWithDuration:duration delay:0 options:animationCurve << 16 animations:block completion:nil];
    else
        block();
}

- (void)changeToSize:(CGSize)size keyboardHeight:(CGFloat)keyboardHeight duration:(NSTimeInterval)duration contentAreaHeight:(CGFloat)contentAreaHeight
{
    [self _adjustForSize:size keyboardHeight:keyboardHeight duration:duration animationCurve:0 contentAreaHeight:contentAreaHeight];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _stripeLayer.frame = CGRectMake(0.0f, -TGRetinaPixel, self.frame.size.width, TGRetinaPixel);
    
    CGSize labelSize = [_label sizeThatFits:CGSizeMake(self.bounds.size.width - 10.0f, self.frame.size.height - 8.0f)];
    _label.frame = CGRectMake(CGFloor((self.bounds.size.width - labelSize.width) / 2.0f), CGFloor((self.bounds.size.height - labelSize.height) / 2.0f), labelSize.width, labelSize.height);
}

@end
