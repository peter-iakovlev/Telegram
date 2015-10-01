#import "TGChangePhoneNumberHelpView.h"

#import "TGFont.h"

#import "TGModernButton.h"
#import "TGImageUtils.h"

@interface TGChangePhoneNumberHelpView ()
{
    UIEdgeInsets _insets;
    
    UIImageView *_iconView;
    UILabel *_label;
    TGModernButton *_changeButton;
}

@end

@implementation TGChangePhoneNumberHelpView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        _iconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ChangePhoneHelpIcon.png"]];
        _iconView.userInteractionEnabled = true;
        UITapGestureRecognizer *debugTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(debugTapGesture:)];
        debugTapRecognizer.numberOfTapsRequired = 7;
        [_iconView addGestureRecognizer:debugTapRecognizer];
        [self addSubview:_iconView];
        
        _label = [[UILabel alloc] init];
        _label.backgroundColor = [UIColor clearColor];
        _label.font = TGSystemFontOfSize(14.0f);
        _label.textColor = UIColorRGB(0x6d6d72);
        _label.lineBreakMode = NSLineBreakByWordWrapping;
        _label.numberOfLines = 0;
        
        NSMutableArray *boldRanges = [[NSMutableArray alloc] init];
        
        NSMutableString *cleanText = [[NSMutableString alloc] initWithString:TGLocalized(@"PhoneNumberHelp.Help")];
        while (true)
        {
            NSRange startRange = [cleanText rangeOfString:@"**"];
            if (startRange.location == NSNotFound)
                break;
            
            [cleanText deleteCharactersInRange:startRange];
            
            NSRange endRange = [cleanText rangeOfString:@"**"];
            if (endRange.location == NSNotFound)
                break;
            
            [cleanText deleteCharactersInRange:endRange];
            
            [boldRanges addObject:[NSValue valueWithRange:NSMakeRange(startRange.location, endRange.location - startRange.location)]];
        }
        
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:cleanText attributes:@{
            NSFontAttributeName: _label.font,
            NSForegroundColorAttributeName: _label.textColor
        }];
        
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.lineSpacing = 2;
        style.lineBreakMode = NSLineBreakByWordWrapping;
        style.alignment = NSTextAlignmentCenter;
        [attributedString addAttributes:@{NSParagraphStyleAttributeName: style} range:NSMakeRange(0, attributedString.length)];
        
        NSDictionary *boldAttributes = @{NSFontAttributeName: TGBoldSystemFontOfSize(14.0f)};
        for (NSValue *nRange in boldRanges)
        {
            [attributedString addAttributes:boldAttributes range:[nRange rangeValue]];
        }

        _label.attributedText = attributedString;
        
        [self addSubview:_label];
        
        _changeButton = [[TGModernButton alloc] init];
        _changeButton.backgroundColor = [UIColor clearColor];
        [_changeButton setTitleColor:TGAccentColor()];
        _changeButton.titleLabel.font = TGSystemFontOfSize(19.0f);
        [_changeButton setTitle:TGLocalized(@"PhoneNumberHelp.ChangeNumber") forState:UIControlStateNormal];
        [_changeButton setContentEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 20.0f)];
        [_changeButton sizeToFit];
        CGSize buttonSize = _changeButton.frame.size;
        _changeButton.frame = CGRectMake(0.0f, 0.0f, buttonSize.width, buttonSize.height + 20.0f);
        
        UIImageView *arrowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ModernTourButtonRightArrow.png"]];
        CGSize arrowSize = arrowView.frame.size;
        arrowView.frame = CGRectMake(_changeButton.frame.size.width - arrowSize.width, CGFloor((_changeButton.frame.size.height - arrowView.frame.size.height) / 2.0f) + 1.0f + TGRetinaPixel, arrowSize.width, arrowSize.height);
        
        [_changeButton addSubview:arrowView];
        [_changeButton addTarget:self action:@selector(actionButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_changeButton];
    }
    return self;
}

- (void)actionButtonPressed
{
    if (_changePhonePressed)
        _changePhonePressed();
}

- (void)setInsets:(UIEdgeInsets)insets
{
    _insets = insets;
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat availableHeight = self.frame.size.height - _insets.top - _insets.bottom;
    
    bool largeScreen = availableHeight >= 420.0f;
    CGFloat contentHeight = largeScreen ? 420.0f : 400.0f;
    
    _iconView.frame = (CGRect){{CGFloor((self.frame.size.width - _iconView.frame.size.width) / 2.0f), _insets.top + CGFloor((availableHeight - contentHeight) / 2.0f + _iconView.frame.size.height * (largeScreen ? 0.2f : 0.5f))}, _iconView.frame.size};
    
    CGSize labelSize = [_label sizeThatFits:CGSizeMake(295.0f, CGFLOAT_MAX)];
    _label.frame = (CGRect){{CGFloor((self.frame.size.width - labelSize.width) / 2.0f), _insets.top + CGFloor((availableHeight - contentHeight) / 2.0f) + CGFloor((contentHeight - labelSize.height) / 2.0f) + CGFloor((contentHeight - _iconView.frame.size.height - _changeButton.frame.size.height) * (largeScreen ? 0.11f : 0.11f))}, labelSize};
    
    _changeButton.frame = (CGRect){{CGFloor((self.frame.size.width - _changeButton.frame.size.width) / 2.0f), _insets.top + CGFloor((availableHeight - contentHeight) / 2.0f) + contentHeight - _changeButton.frame.size.height}, _changeButton.frame.size};
}

- (void)debugTapGesture:(UITapGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        if (_debugPressed)
            _debugPressed();
    }
}

@end
