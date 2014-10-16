#import "TGModernConversationUpgradeStateTitlePanel.h"

#import "TGImageUtils.h"
#import "TGFont.h"

#import "TGModernButton.h"
#import "TGBackdropView.h"

@interface TGModernConversationUpgradeStateTitlePanel ()
{
    CALayer *_stripeLayer;
    UIView *_backgroundView;
    
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
        
        _actionButton = [[TGModernButton alloc] init];
        _actionButton.adjustsImageWhenDisabled = false;
        _actionButton.adjustsImageWhenHighlighted = false;
        [_actionButton setTitleColor:TGAccentColor()];
        _actionButton.titleLabel.font = TGSystemFontOfSize(15);
        [_actionButton addTarget:self action:@selector(actionButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_actionButton];
    }
    return self;
}

- (void)setCurrentLayer:(NSUInteger)currentLayer
{
    [_actionButton setTitle:[[NSString alloc] initWithFormat:@"Current Layer: %d", (int)currentLayer] forState:UIControlStateNormal];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _backgroundView.frame = self.bounds;
    _stripeLayer.frame = CGRectMake(0.0f, self.frame.size.height - TGRetinaPixel, self.frame.size.width, TGRetinaPixel);
    _actionButton.frame = CGRectInset(self.bounds, 40.0f, 0.0f);
}

- (void)actionButtonPressed
{
}

@end
