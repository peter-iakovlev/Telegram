#import "TGCallDebugView.h"

#import "TGFont.h"

#import "TGCallSession.h"

@interface TGCallDebugView ()
{
    SMetaDisposable *_debugDisposable;
    
    UILabel *_debugLabel;
    UIButton *_debugSettingsButton;
    UIView *_debugSettingsView;
    UIButton *_debugSettingsDoneButton;
    
    UIView *_controlsWrapper;
    UILabel *_bitrateLabel;
    UIStepper *_bitrateStepper;
    
    UILabel *_packetLossLabel;
    UIStepper *_packetLossStepper;
    
    UILabel *_p2pLabel;
    UISwitch *_p2pSwitch;
}
@end

@implementation TGCallDebugView

- (instancetype)initWithFrame:(CGRect)frame callSession:(TGCallSession *)session
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.backgroundColor = UIColorRGBA(0xffffff, 0.75f);
        
        CGRect debugLabelFrame = CGRectInset(self.bounds, 15.0f, 0.0f);
        debugLabelFrame.size.height -= 40.0f;
        _debugLabel = [[UILabel alloc] initWithFrame:debugLabelFrame];
        _debugLabel.numberOfLines = 0;
        [self addSubview:_debugLabel];
        
        UIButton *hideButton = [[UIButton alloc] initWithFrame:self.bounds];
        hideButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [hideButton addTarget:self action:@selector(hideDebug) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:hideButton];
        
        _debugSettingsButton = [[UIButton alloc] init];
        [_debugSettingsButton setTitle:@"Tune Parameters" forState:UIControlStateNormal];
        [_debugSettingsButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _debugSettingsButton.titleLabel.font = TGMediumSystemFontOfSize(18);
        [_debugSettingsButton sizeToFit];
        _debugSettingsButton.frame = CGRectMake(ceil((self.frame.size.width - _debugSettingsButton.frame.size.width) / 2.0f), self.frame.size.height - _debugSettingsButton.frame.size.height - 20.0f, _debugSettingsButton.frame.size.width, _debugSettingsButton.frame.size.height);
        [_debugSettingsButton addTarget:self action:@selector(debugSettingsPressed) forControlEvents:UIControlEventTouchUpInside];
        //[self addSubview:_debugSettingsButton];
        
        _debugSettingsView = [[UIView alloc] initWithFrame:self.bounds];
        _debugSettingsView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _debugSettingsView.hidden = true;
        [self addSubview:_debugSettingsView];
        
        _controlsWrapper = [[UIView alloc] initWithFrame:CGRectMake((self.frame.size.width - 300.0f) / 2.0f, (self.frame.size.height - 100.0f) / 2.0f, 300, 100)];
        [_debugSettingsView addSubview:_controlsWrapper];
        
        _bitrateLabel = [[UILabel alloc] init];
        _bitrateLabel.text = @"Audio Bitrate:";
        _bitrateLabel.frame = CGRectMake(0, 6, 180, 25);
        [_controlsWrapper addSubview:_bitrateLabel];
        
        _bitrateStepper = [[UIStepper alloc] init];
        _bitrateStepper.minimumValue = 8;
        _bitrateStepper.maximumValue = 32;
        _bitrateStepper.value = 25;
        _bitrateStepper.stepValue = 1;
        _bitrateStepper.frame = CGRectMake(_controlsWrapper.frame.size.width - _bitrateStepper.frame.size.width, 0, _bitrateStepper.frame.size.width, _bitrateStepper.frame.size.height);
        [_bitrateStepper addTarget:self action:@selector(bitrateChanged:) forControlEvents:UIControlEventValueChanged];
        [_controlsWrapper addSubview:_bitrateStepper];
        
        _packetLossLabel = [[UILabel alloc] init];
        _packetLossLabel.text = @"Packet Loss:";
        _packetLossLabel.frame = CGRectMake(0, 42, 180, 25);
        [_controlsWrapper addSubview:_packetLossLabel];
        
        _packetLossStepper = [[UIStepper alloc] init];
        _packetLossStepper.minimumValue = 0;
        _packetLossStepper.maximumValue = 100;
        _packetLossStepper.value = 0;
        _packetLossStepper.stepValue = 5;
        _packetLossStepper.frame = CGRectMake(_controlsWrapper.frame.size.width - _packetLossStepper.frame.size.width, _bitrateStepper.frame.size.height + 10, _packetLossStepper.frame.size.width, _packetLossStepper.frame.size.height);
        [_packetLossStepper addTarget:self action:@selector(packetLossChanged:) forControlEvents:UIControlEventValueChanged];
        [_controlsWrapper addSubview:_packetLossStepper];
        
        _p2pLabel = [[UILabel alloc] init];
        _p2pLabel.text = @"P2P:";
        _p2pLabel.frame = CGRectMake(0, 78, 180, 25);
        [_controlsWrapper addSubview:_p2pLabel];
        
        _p2pSwitch = [[UISwitch alloc] init];
        _p2pSwitch.frame = CGRectMake(_controlsWrapper.frame.size.width - _p2pSwitch.frame.size.width, CGRectGetMaxY(_packetLossStepper.frame) + 10, _p2pSwitch.frame.size.width, _p2pSwitch.frame.size.height);
        [_p2pSwitch addTarget:self action:@selector(p2pChanged:) forControlEvents:UIControlEventValueChanged];
        [_controlsWrapper addSubview:_p2pSwitch];
        
        _debugSettingsDoneButton = [[UIButton alloc] init];
        [_debugSettingsDoneButton setTitle:@"Apply Settings" forState:UIControlStateNormal];
        [_debugSettingsDoneButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _debugSettingsDoneButton.titleLabel.font = TGMediumSystemFontOfSize(18);
        [_debugSettingsDoneButton sizeToFit];
        _debugSettingsDoneButton.frame = CGRectMake(ceil((self.frame.size.width - _debugSettingsDoneButton.frame.size.width) / 2.0f), self.frame.size.height - _debugSettingsDoneButton.frame.size.height - 20.0f, _debugSettingsDoneButton.frame.size.width, _debugSettingsButton.frame.size.height);
        [_debugSettingsDoneButton addTarget:self action:@selector(debugSettingsDonePressed) forControlEvents:UIControlEventTouchUpInside];
        [_debugSettingsView addSubview:_debugSettingsDoneButton];
        
        __weak TGCallDebugView *weakSelf = self;
        _debugDisposable = [[SMetaDisposable alloc] init];
        [_debugDisposable setDisposable:[[session debugSignal] startWithNext:^(NSString *next)
        {
            __strong TGCallDebugView *strongSelf = weakSelf;
            if (strongSelf != nil)
                strongSelf->_debugLabel.attributedText = [strongSelf _formatDebugString:next];
        }]];
        
        [self _updateValues];
    }
    return self;
}

- (void)bitrateChanged:(UIStepper *)__unused sender
{
    [self _updateValues];
}

- (void)packetLossChanged:(UIStepper *)__unused sender
{
    [self _updateValues];
}

- (void)p2pChanged:(UIStepper *)__unused sender
{
    [self _updateValues];
}

- (void)_updateValues
{
    _bitrateLabel.text = [NSString stringWithFormat:@"Audio Bitrate: %d kbps", (int)_bitrateStepper.value];
    _packetLossLabel.text = [NSString stringWithFormat:@"Packet Loss: %d%%", (int)_packetLossStepper.value];
}

- (void)setBitrate:(NSInteger)bitrate packetLoss:(NSInteger)packetLoss p2p:(bool)p2p
{
    _bitrateStepper.value = bitrate;
    _packetLossStepper.value = packetLoss;
    _p2pSwitch.on = p2p;
    [self _updateValues];
}

- (NSAttributedString *)_formatDebugString:(NSString *)string
{
    if (string.length == 0)
    {
        return [[NSAttributedString alloc] initWithString:@" " attributes:nil];
    }
    else
    {
        string = [string stringByReplacingOccurrencesOfString:@"Jitter " withString:@"\nJitter "];
        string = [string stringByReplacingOccurrencesOfString:@"Key fingerprint:\n" withString:@"Key fingerprint: "];
    }
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string attributes:@{ NSFontAttributeName: TGSystemFontOfSize(16) }];
    
    NSMutableParagraphStyle *titleStyle = [[NSMutableParagraphStyle alloc] init];
    titleStyle.alignment = NSTextAlignmentCenter;
    titleStyle.lineSpacing = 10.0f;
    NSDictionary *titleAttributes = @{ NSFontAttributeName: TGBoldSystemFontOfSize(18), NSParagraphStyleAttributeName: titleStyle };
    NSDictionary *nameAttributes = @{ NSFontAttributeName: TGMediumSystemFontOfSize(16), NSForegroundColorAttributeName: UIColorRGBA(0x555555, 1.0f) };
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineHeightMultiple = 1.15f;
    NSDictionary *styleAttributes = @{ NSParagraphStyleAttributeName: style };
    
    NSDictionary *typeAttributes = @{ NSForegroundColorAttributeName: UIColorRGBA(0x555555, 1.0f) };
    NSDictionary *activeAttributes = @{ NSFontAttributeName: TGMediumSystemFontOfSize(16), NSForegroundColorAttributeName: UIColorRGBA(0x4c7a47, 1.0f) };
    
    [string enumerateSubstringsInRange:NSMakeRange(0, string.length) options:NSStringEnumerationByLines usingBlock:^(NSString *substring, NSRange substringRange, __unused NSRange enclosingRange, __unused BOOL *stop)
    {
        if (substringRange.location == 0)
        {
            [attributedString addAttributes:titleAttributes range:substringRange];
        }
        else
        {
            NSUInteger semicolonLocation = [substring rangeOfString:@":"].location;
            if (semicolonLocation != NSNotFound)
            {
                NSUInteger bracketLocation = [substring rangeOfString:@"["].location;
                if (bracketLocation != NSNotFound)
                {
                    NSUInteger inUseLocation = [substring rangeOfString:@"IN_USE"].location;
                    if (inUseLocation != NSNotFound)
                    {
                        [attributedString addAttributes:activeAttributes range:substringRange];
                    }
                    else
                    {
                        [attributedString addAttributes:typeAttributes range:NSMakeRange(substringRange.location + bracketLocation, substringRange.length - bracketLocation)];
                    }
                }
                else
                {
                    [attributedString addAttributes:styleAttributes range:substringRange];
                    [attributedString addAttributes:nameAttributes range:NSMakeRange(substringRange.location, semicolonLocation + 1)];
                }
            }
        }
    }];
    
    return attributedString;
}

- (void)debugSettingsPressed
{
    _debugLabel.hidden = true;
    _debugSettingsButton.hidden = true;
    _debugSettingsView.hidden = false;
}

- (void)debugSettingsDonePressed
{
    if (self.valuesChanged != nil)
        self.valuesChanged((NSInteger)_bitrateStepper.value, (NSInteger)_packetLossStepper.value, _p2pSwitch.on);
    
    _debugSettingsView.hidden = true;
    _debugLabel.hidden = false;
    _debugSettingsButton.hidden = false;
}

- (void)hideDebug
{
    [_debugDisposable setDisposable:nil];
    _debugDisposable = nil;
    
    if (self.dismissBlock != nil)
        self.dismissBlock();
}

@end
