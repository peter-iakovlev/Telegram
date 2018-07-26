#import "TGProxyButtonItemView.h"

@interface TGProxyButtonItemView ()
{
    NSString *_title;
    
    UILabel *_connectingLabel;
    UILabel *_failedLabel;
    
    UIActivityIndicatorView *_activityIndicator;
}
@end

@implementation TGProxyButtonItemView

- (instancetype)initWithTitle:(NSString *)title action:(void (^)(TGProxyButtonItemView *))action
{
    self = [super initWithTitle:title type:TGMenuSheetButtonTypeSend action:nil];
    if (self != nil)
    {
        _title = title;
        
        __weak TGProxyButtonItemView *weakSelf = self;
        self.action = ^
        {
            __strong TGProxyButtonItemView *strongSelf = weakSelf;
            if (strongSelf != nil)
                action(strongSelf);
        };
        
        _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _activityIndicator.hidden = true;
        [self addSubview:_activityIndicator];
        
        _connectingLabel = [[UILabel alloc] init];
        _connectingLabel.alpha = 0.0f;
        _connectingLabel.font = TGMediumSystemFontOfSize(20.0f);
        _connectingLabel.text = TGLocalized(@"SocksProxySetup.Connecting");
        _connectingLabel.userInteractionEnabled = false;
        [_connectingLabel sizeToFit];
        [self addSubview:_connectingLabel];
        
        _failedLabel = [[UILabel alloc] init];
        _failedLabel.alpha = 0.0f;
        _failedLabel.font = TGMediumSystemFontOfSize(20.0f);
        _failedLabel.text = TGLocalized(@"SocksProxySetup.FailedToConnect");
        _failedLabel.userInteractionEnabled = false;
        [_failedLabel sizeToFit];
        [self addSubview:_failedLabel];
    }
    return self;
}

- (void)setPallete:(TGMenuSheetPallete *)pallete
{
    [super setPallete:pallete];
    _connectingLabel.textColor = pallete.textColor;
    _failedLabel.textColor = pallete.destructiveColor;
    _activityIndicator.color = pallete.textColor;
}

- (void)setConnecting
{
    _button.userInteractionEnabled = false;
    
    _activityIndicator.hidden = false;
    _activityIndicator.alpha = 0.0f;
    [_activityIndicator startAnimating];
    
    [UIView animateWithDuration:0.15 animations:^
    {
        _activityIndicator.alpha = 1.0f;
        _button.alpha = 0.0f;
        _connectingLabel.alpha = 1.0f;
    }];
}

- (void)setFailed
{
    _button.userInteractionEnabled = true;
    _button.alpha = 1.0f;
    [self setTitle:nil];
    
    [UIView animateWithDuration:0.15 animations:^
    {
        _activityIndicator.alpha = 0.0f;
        _connectingLabel.alpha = 0.0f;
        _failedLabel.alpha = 1.0f;
    } completion:^(__unused BOOL finished)
    {
        [_activityIndicator stopAnimating];
        _activityIndicator.hidden = true;
    }];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _connectingLabel.frame = CGRectMake(TGScreenPixelFloor((self.frame.size.width - _connectingLabel.frame.size.width) / 2.0f) + 17.0f, TGScreenPixelFloor((self.frame.size.height - _connectingLabel.frame.size.height) / 2.0f), _connectingLabel.frame.size.width, _connectingLabel.frame.size.height);
    _activityIndicator.frame = CGRectMake(_connectingLabel.frame.origin.x - 33.0f, TGScreenPixelFloor((self.frame.size.height - _activityIndicator.frame.size.height) / 2.0f), _activityIndicator.frame.size.width, _activityIndicator.frame.size.height);
    
    _failedLabel.frame = CGRectMake(TGScreenPixelFloor((self.frame.size.width - _failedLabel.frame.size.width) / 2.0f), TGScreenPixelFloor((self.frame.size.height - _failedLabel.frame.size.height) / 2.0f), _failedLabel.frame.size.width, _failedLabel.frame.size.height);
}

@end
