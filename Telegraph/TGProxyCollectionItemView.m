#import "TGProxyCollectionItemView.h"

#import <LegacyComponents/TGFont.h>
#import <LegacyComponents/TGImageUtils.h>
#import <LegacyComponents/TGModernButton.h>

#import "TGPresentation.h"

#import "TGProxyItem.h"

@interface TGProxyCollectionItemView ()
{
    UILabel *_titleLabel;
    UILabel *_subtitleLabel;
    
    NSString *_server;
    int32_t _port;
    bool _mtproto;
    
    UIImageView *_checkView;
    TGModernButton *_infoButton;
    UIActivityIndicatorView *_activityIndicator;
    
    UIImageView *_reorderingControl;
    
    TGConnectionState _state;
    TGProxyCachedAvailability *_availability;
}
@end

@implementation TGProxyCollectionItemView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        self.separatorInset = 50.0f;
        self.optionText = TGLocalized(@"Common.Delete");
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.font = TGSystemFontOfSize(17.0f);
        [self.editingContentView addSubview:_titleLabel];
        
        _subtitleLabel = [[UILabel alloc] init];
        _subtitleLabel.textAlignment = NSTextAlignmentLeft;
        _subtitleLabel.backgroundColor = [UIColor clearColor];
        _subtitleLabel.textColor = [UIColor blackColor];
        _subtitleLabel.font = TGSystemFontOfSize(14.0f);
        _subtitleLabel.text = @"connected";
        [self.editingContentView addSubview:_subtitleLabel];
        
        _checkView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 14.0f, 11.0f)];
        [self.editingContentView addSubview:_checkView];
        
        _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self.editingContentView addSubview:_activityIndicator];
        
        _infoButton = [[TGModernButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 63.0f, 63.0f)];
        _infoButton.adjustsImageWhenHighlighted = false;
        [_infoButton addTarget:self action:@selector(infoButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self.editingContentView addSubview:_infoButton];
        
        _reorderingControl = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 22.0f, 9.0f)];
        _reorderingControl.alpha = 0.0f;
        [self.contentView addSubview:_reorderingControl];
    }
    return self;
}

- (void)setPresentation:(TGPresentation *)presentation
{
    [super setPresentation:presentation];
    
    [self updateTitleLabel];
    [self updateSubtitle];
    _checkView.image = presentation.images.collectionMenuCheckImage;
    _activityIndicator.color = presentation.pallete.collectionMenuVariantColor;
    _reorderingControl.image = presentation.images.collectionMenuReorderIcon;
    [_infoButton setImage:presentation.images.callsInfoIcon forState:UIControlStateNormal];
}

- (void)setIsChecked:(bool)isChecked
{
    if (isChecked && _checkView.superview == nil)
        [self.editingContentView addSubview:_checkView];
    else if (!isChecked && _checkView.superview != nil)
        [_checkView removeFromSuperview];
}

- (void)setProxy:(TGProxyItem *)proxy
{
    _server = proxy.server;
    _port = proxy.port;
    _mtproto = proxy.secret.length > 0;
    
    [self updateTitleLabel];
}

- (void)setStatus:(TGConnectionState)status
{
    _state = status;
    [self updateSubtitle];
}

- (void)setAvailability:(TGProxyCachedAvailability *)availability
{
    _availability = availability;
    [self updateSubtitle];
}

- (void)updateSubtitle
{
    bool active = false;
    UIColor *color = self.presentation.pallete.collectionMenuVariantColor;
    UIColor *failColor = self.presentation.pallete.collectionMenuDestructiveColor;
    UIColor *statusColor = color;
    
    NSString *type =  _mtproto ? TGLocalized(@"SocksProxySetup.ProxyTelegram") : TGLocalized(@"SocksProxySetup.ProxySocks5");
    
    if (_state == TGConnectionStateNotConnected)
    {
        NSString *status = TGLocalized(@"SocksProxySetup.ProxyStatusChecking");
        switch (_availability.availability) {
            case TGProxyAvailable:
                status = [NSString stringWithFormat:TGLocalized(@"SocksProxySetup.ProxyStatusPing"), [NSString stringWithFormat:@"%d", (int)(_availability.rtt * 1000)]];
                break;
                
            case TGProxyUnavailable:
                status = TGLocalized(@"SocksProxySetup.ProxyStatusUnavailable");
                statusColor = failColor;
                break;
                
            case TGProxyUnknown:
                
                break;
                
            default:
                break;
        }
        
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@, %@", type, status] attributes:@{NSFontAttributeName: _subtitleLabel.font, NSForegroundColorAttributeName: statusColor}];
        
        _subtitleLabel.attributedText = string;
    }
    else
    {
        NSString *status = TGLocalized(@"SocksProxySetup.ProxyStatusConnecting");
        NSMutableAttributedString *string = nil;
        switch (_state) {
            case TGConnectionStateTimedOut:
            case TGConnectionStateConnecting:
            case TGConnectionStateUpdating:
            case TGConnectionStateWaitingForNetwork:
                status = TGLocalized(@"SocksProxySetup.ProxyStatusConnecting");
                active = true;
                string = [[NSMutableAttributedString alloc] initWithString:status attributes:@{NSFontAttributeName: _subtitleLabel.font, NSForegroundColorAttributeName: statusColor}];
                break;
                
            default:
                status = TGLocalized(@"SocksProxySetup.ProxyStatusConnected");
                statusColor = self.presentation.pallete.collectionMenuAccentColor;
                if (_availability.rtt > 0)
                {
                    NSString *ping = [NSString stringWithFormat:TGLocalized(@"SocksProxySetup.ProxyStatusPing"), [NSString stringWithFormat:@"%d", (int)(_availability.rtt * 1000)]];
                    string = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@, %@", status, ping] attributes:@{NSFontAttributeName: _subtitleLabel.font, NSForegroundColorAttributeName: statusColor}];
                }
                else
                {
                    string = [[NSMutableAttributedString alloc] initWithString:status attributes:@{NSFontAttributeName: _subtitleLabel.font, NSForegroundColorAttributeName: statusColor}];
                }
                break;
        }
        
        _subtitleLabel.attributedText = string;
    }
    
    if (active)
    {
        _checkView.hidden = true;
        if (_activityIndicator.hidden)
        {
            _activityIndicator.hidden = false;
            [_activityIndicator startAnimating];
        }
    }
    else
    {
        _checkView.hidden = false;
        _activityIndicator.hidden = true;
        [_activityIndicator stopAnimating];
    }
}

- (void)updateTitleLabel
{
    if (_server == nil || self.presentation == nil)
        return;
    
    NSString *port = [NSString stringWithFormat:@"%d", _port];
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@:%@", _server, port] attributes:@{NSFontAttributeName:_titleLabel.font, NSForegroundColorAttributeName:self.presentation.pallete.collectionMenuTextColor}];
    [string addAttribute:NSForegroundColorAttributeName value:self.presentation.pallete.collectionMenuVariantColor range:NSMakeRange(string.length - port.length - 1, port.length + 1)];
    
    _titleLabel.attributedText = string;
}

- (void)infoButtonPressed
{
    if (self.infoPressed != nil)
        self.infoPressed();
}

- (void)deleteAction
{
    [super deleteAction];
    
    if (_removeRequested)
        _removeRequested();
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat leftInset = 50.0f + (self.enableEditing && self.showsDeleteIndicator ? 38.0f : 0.0f) + self.safeAreaInset.left;
    
    CGSize titleSize = [_titleLabel.text sizeWithFont:_titleLabel.font];
    titleSize.width = self.editingContentView.frame.size.width - leftInset - self.safeAreaInset.right - 63.0f;
    titleSize.height = CGCeil(titleSize.height);
    _titleLabel.frame = CGRectMake(leftInset, 11.0f, titleSize.width, titleSize.height);
    
    CGSize subtitleSize = [_subtitleLabel.text sizeWithFont:_subtitleLabel.font];
    subtitleSize.width = self.editingContentView.frame.size.width - leftInset - self.safeAreaInset.right - 63.0f;
    subtitleSize.height = CGCeil(subtitleSize.height);
    _subtitleLabel.frame = CGRectMake(leftInset, 35.0f, subtitleSize.width, subtitleSize.height);
    
    CGSize checkSize = _checkView.frame.size;
    _checkView.frame = CGRectMake(19.0f + (self.enableEditing && self.showsDeleteIndicator ? 38.0f : 0.0f) + self.safeAreaInset.left, TGScreenPixelFloor((self.editingContentView.frame.size.height - checkSize.height) / 2.0f), checkSize.width, checkSize.height);
    
    _activityIndicator.center = CGPointMake(_checkView.center.x, _checkView.center.y);
    
    _reorderingControl.alpha = self.showsDeleteIndicator ? 1.0f : 0.0f;
    _reorderingControl.frame = CGRectMake(self.contentView.frame.size.width - 15.0f - _reorderingControl.frame.size.width - self.safeAreaInset.right, CGFloor((self.contentView.frame.size.height - _reorderingControl.frame.size.height) / 2.0f), _reorderingControl.frame.size.width, _reorderingControl.frame.size.height);

    _infoButton.alpha = self.showsDeleteIndicator ? 0.0f : 1.0f;
    _infoButton.userInteractionEnabled = !self.showsDeleteIndicator;
    _infoButton.frame = CGRectMake(self.editingContentView.frame.size.width - _infoButton.frame.size.width + 5.0f, 0.0f, _infoButton.frame.size.width, _infoButton.frame.size.height);
}

@end
