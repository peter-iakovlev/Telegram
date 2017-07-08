#import "TGModernConversationUpgradeStateTitlePanel.h"

#import "TGImageUtils.h"
#import "TGFont.h"

#import "TGModernButton.h"
#import "TGBackdropView.h"

@interface TGModernConversationUpgradeStateTitlePanel ()
{
    CALayer *_stripeLayer;
    UIView *_backgroundView;
    
    UILabel *_label;
    TGModernButton *_actionButton;
}

@end

@implementation TGModernConversationUpgradeStateTitlePanel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, 35.0f)];
    if (self)
    {
        if (!TGBackdropEnabled())
        {
            _backgroundView = [TGBackdropView viewWithLightNavigationBarStyle];
            [self addSubview:_backgroundView];
        }
        else
        {
            UIToolbar *toolbar = [[UIToolbar alloc] init];
            _backgroundView = toolbar;
            [self addSubview:_backgroundView];
        }
        
        _stripeLayer = [[CALayer alloc] init];
        _stripeLayer.backgroundColor = UIColorRGB(0xb2b2b2).CGColor;
        [self.layer addSublayer:_stripeLayer];
        
        _label = [[UILabel alloc] init];
        _label.textColor = UIColorRGB(0x777777);
        _label.font = TGSystemFontOfSize(15);
        [self addSubview:_label];
        
        _actionButton = [[TGModernButton alloc] init];
        _actionButton.adjustsImageWhenDisabled = false;
        _actionButton.adjustsImageWhenHighlighted = false;
        [_actionButton setTitleColor:TGAccentColor()];
        _actionButton.titleLabel.font = TGSystemFontOfSize(15);
        [_actionButton addTarget:self action:@selector(actionButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [_actionButton setTitle:@"Rekey" forState:UIControlStateNormal];
        _actionButton.hidden = true;
        [_actionButton sizeToFit];
        _actionButton.frame = CGRectMake(0.0f, 0.0f, _actionButton.frame.size.width + 20.0f, 35.0f);
        [self addSubview:_actionButton];
    }
    return self;
}

- (void)setCurrentLayer:(NSUInteger)currentLayer keyId:(int64_t)keyId rekeySessionId:(int64_t)rekeySessionId canRekey:(bool)canRekey
{
    NSMutableString *string = [[NSMutableString alloc] init];
    [string appendFormat:@"L:%d", (int)currentLayer];
    [string appendFormat:@" K:%" PRIx64 "", keyId];
    if (rekeySessionId != 0)
        [string appendFormat:@" R:%" PRIx64 "", rekeySessionId];
    _label.text = string;
    [_label sizeToFit];
    
    _actionButton.hidden = !canRekey;
    
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _backgroundView.frame = self.bounds;
    _stripeLayer.frame = CGRectMake(0.0f, self.frame.size.height - TGScreenPixel, self.frame.size.width, TGScreenPixel);
    
    if (_actionButton.hidden)
    {
        _label.frame = CGRectMake(CGFloor((self.frame.size.width - _label.frame.size.width) / 2.0f), CGFloor((self.frame.size.height - _label.frame.size.height) / 2.0f), _label.frame.size.width, _label.frame.size.height);
    }
    else
    {
        _label.frame = CGRectMake(CGFloor((self.frame.size.width - _label.frame.size.width - _actionButton.frame.size.width) / 2.0f), CGFloor((self.frame.size.height - _label.frame.size.height) / 2.0f), _label.frame.size.width, _label.frame.size.height);
        _actionButton.frame = CGRectMake(CGRectGetMaxX(_label.frame), 0.0f, _actionButton.frame.size.width, self.frame.size.height);
    }
}

- (void)actionButtonPressed
{
    if (_rekey)
        _rekey();
}

@end
