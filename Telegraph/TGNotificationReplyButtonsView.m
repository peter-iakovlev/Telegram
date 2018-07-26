#import "TGNotificationReplyButtonsView.h"

#import <LegacyComponents/TGBotReplyMarkup.h>

#import <LegacyComponents/TGFont.h>
#import <LegacyComponents/TGImageUtils.h>
#import <LegacyComponents/TGModernButton.h>

@interface TGNotificationReplyButtonsView ()
{
    TGBotReplyMarkup *_replyMarkup;
    
    UIView *_separatorView;
    NSArray *_buttons;
}
@end

@implementation TGNotificationReplyButtonsView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        CGFloat thickness = TGScreenPixel;
        _separatorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, thickness)];
        _separatorView.alpha = 0.7f;
        _separatorView.backgroundColor = UIColorRGB(0xb2b2b2);
        [self addSubview:_separatorView];
    }
    return self;
}

- (void)setReplyMarkup:(TGBotReplyMarkup *)replyMarkup
{
    _replyMarkup = replyMarkup;
    
    for (UIView *button in _buttons)
    {
        [button removeFromSuperview];
    }
    
    NSMutableArray *buttons = [[NSMutableArray alloc] init];
    NSInteger index = -1;
    for (TGBotReplyMarkupRow *row in replyMarkup.rows) {
        for (TGBotReplyMarkupButton *button in row.buttons) {
            index++;
            NSString *text = button.text;
            TGModernButton *button = [[TGModernButton alloc] init];
            button.adjustsImageWhenHighlighted = false;
            [button setTitleColor:UIColorRGBA(0xffffff, 0.82f)];
            static dispatch_once_t onceToken;
            static UIImage *backgroundImage;
            dispatch_once(&onceToken, ^{
                UIGraphicsBeginImageContextWithOptions(CGSizeMake(16.0f, 16.0f), false, 0.0f);
                CGContextRef context = UIGraphicsGetCurrentContext();
                CGContextSetStrokeColorWithColor(context, UIColorRGBA(0xffffff, 0.82f).CGColor);
                
                CGFloat lineWidth = 1.0f;
                CGContextSetLineWidth(context, lineWidth);
                
                UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(lineWidth / 2.0f, lineWidth / 2.0f, 16.0f - lineWidth, 16.0f - lineWidth) cornerRadius:8.0f];
                CGContextAddPath(context, path.CGPath);
                CGContextDrawPath(context, kCGPathStroke);
                
                backgroundImage = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                
                backgroundImage = [backgroundImage resizableImageWithCapInsets:UIEdgeInsetsMake(8.0f, 8.0f, 8.0f, 8.0f)];
            });
            [button setBackgroundImage:backgroundImage forState:UIControlStateNormal];
            [button setTitle:text forState:UIControlStateNormal];
            button.titleLabel.font = TGMediumSystemFontOfSize(16.0f);
            [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
            button.tag = index;
            [buttons addObject:button];
            [self addSubview:button];
        }
    }
    _buttons = buttons;
}

- (void)buttonPressed:(TGModernButton *)sender
{
    if (self.activateCommand != nil)
    {
        id action = nil;
        NSInteger index = -1;
        for (TGBotReplyMarkupRow *row in _replyMarkup.rows) {
            for (TGBotReplyMarkupButton *button in row.buttons) {
                index++;
                
                if (index == sender.tag)
                {
                    action = button.action;
                    break;
                }
            }
        }
        self.activateCommand(action, sender.tag);
    }
}

- (UIEdgeInsets)insets
{
    return UIEdgeInsetsMake(9.0f, 6.0f, 5.0f, 6.0f);
}

- (CGFloat)rowSpacing
{
    return 6.0f;
}

- (CGFloat)columnSpacing
{
    return 6.0f;
}

- (CGSize)buttonSize
{
    return CGSizeMake(100, 32);
}

- (CGFloat)heightForWidth:(CGFloat)__unused width
{
    int rowCount = (int)_replyMarkup.rows.count;
    return [self buttonSize].height * rowCount + MAX(rowCount - 1, 0) * [self rowSpacing] + [self insets].top + [self insets].bottom;
}

- (void)layoutSubviews
{
    _separatorView.frame = CGRectMake(0, 0, self.frame.size.width, _separatorView.frame.size.height);
    
    CGSize containerSize = self.bounds.size;
    CGSize contentSize = CGSizeZero;
    contentSize.width = containerSize.width;
    UIEdgeInsets insets = [self insets];
    CGSize buttonSize = [self buttonSize];
    
    CGFloat rowSpacing = [self rowSpacing];
    CGFloat columnSpacing = [self columnSpacing];
    
    contentSize.height = insets.top + insets.bottom + _replyMarkup.rows.count * buttonSize.height + MAX((int)_replyMarkup.rows.count - 1, 0) * rowSpacing;
    
    NSInteger buttonIndex = 0;
    NSInteger rowIndex = 0;
    for (TGBotReplyMarkupRow *row in _replyMarkup.rows)
    {
        NSInteger columnCount = row.buttons.count;
        buttonSize.width = CGFloor(((containerSize.width - insets.left - insets.right) + columnSpacing - columnCount * columnSpacing) / columnCount);
        
        CGFloat topEdge = insets.top + rowIndex * (buttonSize.height + rowSpacing);
        NSInteger columnIndex = 0;
        for (__unused TGBotReplyMarkupButton *button in row.buttons)
        {
            CGFloat leftEdge = insets.left + columnIndex * (buttonSize.width + columnSpacing);
            
            TGModernButton *button = _buttons[buttonIndex];
            button.frame = CGRectMake(leftEdge, topEdge, buttonSize.width, buttonSize.height);
            
            buttonIndex++;
            columnIndex++;
        }
        rowIndex++;
    }
}

@end
