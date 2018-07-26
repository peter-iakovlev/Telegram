#import "TGProxyInfoItemView.h"
#import "TGProxyItem.h"

@interface TGProxyInfoItemView ()
{
    UILabel *_serverTitleLabel;
    UILabel *_serverValueLabel;
    UILabel *_portTitleLabel;
    UILabel *_portValueLabel;
    UILabel *_usernameTitleLabel;
    UILabel *_usernameValueLabel;
    UILabel *_passwordTitleLabel;
    UILabel *_passwordValueLabel;
}
@end

@implementation TGProxyInfoItemView

- (instancetype)initWithProxy:(TGProxyItem *)proxy
{
    self = [super initWithType:TGMenuSheetItemTypeDefault];
    if (self != nil)
    {
        _serverTitleLabel = [[UILabel alloc] init];
        _serverTitleLabel.font = TGSystemFontOfSize(17.0f);
        _serverTitleLabel.text = TGLocalized(@"SocksProxySetup.Hostname");
        [_serverTitleLabel sizeToFit];
        [self addSubview:_serverTitleLabel];
        
        _serverValueLabel = [[UILabel alloc] init];
        _serverValueLabel.font = TGSystemFontOfSize(17.0f);
        _serverValueLabel.text = proxy.server;
        _serverValueLabel.textAlignment = NSTextAlignmentRight;
        _serverValueLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        [_serverValueLabel sizeToFit];
        [self addSubview:_serverValueLabel];
        
        _portTitleLabel = [[UILabel alloc] init];
        _portTitleLabel.font = TGSystemFontOfSize(17.0f);
        _portTitleLabel.text = TGLocalized(@"SocksProxySetup.Port");
        [_portTitleLabel sizeToFit];
        [self addSubview:_portTitleLabel];
        
        _portValueLabel = [[UILabel alloc] init];
        _portValueLabel.font = TGSystemFontOfSize(17.0f);
        _portValueLabel.text = [NSString stringWithFormat:@"%d", proxy.port];
        _portValueLabel.textAlignment = NSTextAlignmentRight;
        [_portValueLabel sizeToFit];
        [self addSubview:_portValueLabel];
        
        if (proxy.username.length > 0)
        {
            _usernameTitleLabel = [[UILabel alloc] init];
            _passwordTitleLabel.font = TGSystemFontOfSize(17.0f);
            _usernameTitleLabel.text = TGLocalized(@"SocksProxySetup.Username");
            [_usernameTitleLabel sizeToFit];
            [self addSubview:_usernameTitleLabel];
            
            _usernameValueLabel = [[UILabel alloc] init];
            _usernameValueLabel.font = TGSystemFontOfSize(17.0f);
            _usernameValueLabel.text = proxy.username;
            _usernameValueLabel.textAlignment = NSTextAlignmentRight;
            _usernameValueLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
            [_usernameValueLabel sizeToFit];
            [self addSubview:_usernameValueLabel];
        }
        
        if (proxy.password.length > 0)
        {
            _passwordTitleLabel = [[UILabel alloc] init];
            _passwordTitleLabel.font = TGSystemFontOfSize(17.0f);
            _passwordTitleLabel.text = TGLocalized(@"SocksProxySetup.Password");
            [_passwordTitleLabel sizeToFit];
            [self addSubview:_passwordTitleLabel];
            
            _passwordValueLabel = [[UILabel alloc] init];
            _passwordValueLabel.font = TGSystemFontOfSize(17.0f);
            _passwordValueLabel.text = proxy.password;
            _passwordValueLabel.textAlignment = NSTextAlignmentRight;
            _passwordValueLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
            [_passwordValueLabel sizeToFit];
            [self addSubview:_passwordValueLabel];
        }
    }
    return self;
}

- (void)setPallete:(TGMenuSheetPallete *)pallete
{
    [super setPallete:pallete];
    
    _serverTitleLabel.textColor = pallete.secondaryTextColor;
    _portTitleLabel.textColor = pallete.secondaryTextColor;
    _usernameTitleLabel.textColor = pallete.secondaryTextColor;
    _passwordTitleLabel.textColor = pallete.secondaryTextColor;
    
    _serverValueLabel.textColor = pallete.textColor;
    _portValueLabel.textColor = pallete.textColor;
    _usernameValueLabel.textColor = pallete.textColor;
    _passwordValueLabel.textColor = pallete.textColor;
}

- (CGFloat)preferredHeightForWidth:(CGFloat)__unused width screenHeight:(CGFloat)__unused screenHeight
{
    CGFloat height = 22.0f + 39.0f + 18.0f + 22.0f;
    if (_usernameTitleLabel != nil)
        height += 39.0f;
    if (_passwordTitleLabel != nil)
        height += 39.0f;
    return height;
}

- (bool)requiresDivider
{
    return true;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat originY = 22.0f;
    _serverTitleLabel.frame = CGRectMake(22.0f, originY, _serverTitleLabel.frame.size.width, _serverTitleLabel.frame.size.height);
    
    CGFloat availableWidth = self.frame.size.width - 66.0f - _serverTitleLabel.frame.size.width;
    CGFloat width = MIN(_serverValueLabel.frame.size.width, availableWidth);
    _serverValueLabel.frame = CGRectMake(self.frame.size.width - width - 22.0f, originY, width, _serverValueLabel.frame.size.height);
    
    originY += 39.0f;
    _portTitleLabel.frame = CGRectMake(22.0f, originY, _portTitleLabel.frame.size.width, _portTitleLabel.frame.size.height);
    
    availableWidth = self.frame.size.width - 66.0f - _portTitleLabel.frame.size.width;
    width = MIN(_portValueLabel.frame.size.width, availableWidth);
    _portValueLabel.frame = CGRectMake(self.frame.size.width - width - 22.0f, originY, width, _portValueLabel.frame.size.height);
    
    originY += 39.0f;
    _usernameTitleLabel.frame = CGRectMake(22.0f, originY, _usernameTitleLabel.frame.size.width, _usernameTitleLabel.frame.size.height);
    
    availableWidth = self.frame.size.width - 66.0f - _usernameTitleLabel.frame.size.width;
    width = MIN(_usernameValueLabel.frame.size.width, availableWidth);
    _usernameValueLabel.frame = CGRectMake(self.frame.size.width - width - 22.0f, originY, width, _usernameValueLabel.frame.size.height);
    
    originY += 39.0f;
    _passwordTitleLabel.frame = CGRectMake(22.0f, originY, _passwordTitleLabel.frame.size.width, _passwordTitleLabel.frame.size.height);
    
    availableWidth = self.frame.size.width - 66.0f - _passwordTitleLabel.frame.size.width;
    width = MIN(_passwordValueLabel.frame.size.width, availableWidth);
    _passwordValueLabel.frame = CGRectMake(self.frame.size.width - width - 22.0f, originY, width, _passwordValueLabel.frame.size.height);
}

@end
