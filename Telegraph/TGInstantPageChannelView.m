#import "TGInstantPageChannelView.h"

#import "TGDatabase.h"
#import "TGConversation.h"
#import "TGChannelManagementSignals.h"

#import "TGFont.h"
#import "TGImageUtils.h"

#import "TGModernButton.h"

@interface TGInstantPageChannelView ()
{
    TGConversation *_channel;
    bool _overlay;
    
    UIButton *_backgroundButton;
    UILabel *_titleLabel;
    TGModernButton *_joinButton;
    UIImageView *_checkView;
    
    SMetaDisposable *_disposable;
    
    TGInstantPagePresentation *_presentation;
    
    void (^_openChannel)(TGConversation *);
    void (^_joinChannel)(TGConversation *);
}
@end

@implementation TGInstantPageChannelView

- (instancetype)initWithFrame:(CGRect)frame channel:(TGConversation *)channel overlay:(bool)overlay presentation:(TGInstantPagePresentation *)presentation {
    self = [super initWithFrame:frame];
    if (self != nil) {
        _overlay = overlay;
        
        _backgroundButton = [[UIButton alloc] initWithFrame:self.bounds];
        [_backgroundButton addTarget:self action:@selector(buttonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_backgroundButton];
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = TGMediumSystemFontOfSize(16.0f);
        [self addSubview:_titleLabel];
        
        _joinButton = [[TGModernButton alloc] init];
        _joinButton.titleLabel.font = TGMediumSystemFontOfSize(16.0f);
        [_joinButton setTitle:TGLocalized(@"Channel.JoinChannel") forState:UIControlStateNormal];
        [_joinButton addTarget:self action:@selector(joinPressed) forControlEvents:UIControlEventTouchUpInside];
        [_joinButton sizeToFit];
        _joinButton.alpha = 0.0f;
        _joinButton.userInteractionEnabled = false;
        [self addSubview:_joinButton];
        
        _checkView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"InstantViewCheck"]];
        _checkView.alpha = 0.0f;
        [self addSubview:_checkView];
        
        __weak TGInstantPageChannelView *weakSelf = self;
        _disposable = [[SMetaDisposable alloc] init];
        
        SSignal *channelSignal = [SSignal defer:^SSignal *{
            bool exists = [TGDatabaseInstance() _channelExists:channel.conversationId];
            if (exists)
                return [[TGDatabaseInstance() existingChannel:channel.conversationId] take:1];
            else
                return [SSignal single:channel];
        }];
        
        [_disposable setDisposable:[[channelSignal deliverOn:[SQueue mainQueue]] startWithNext:^(TGConversation *next) {
            __strong TGInstantPageChannelView *strongSelf = weakSelf;
            if (strongSelf != nil)
                [strongSelf updateWithChannel:next];
        }]];
        
        [self updatePresentation:presentation];
    }
    return self;
}

- (void)dealloc {
    [_disposable dispose];
}

- (void)updatePresentation:(TGInstantPagePresentation *)presentation {
    if ([presentation isEqual:_presentation]) {
        return;
    }
    
    _presentation = presentation;
    
    self.backgroundColor = _overlay ? [UIColor clearColor] : presentation.panelColor;
    bool opaque = _overlay ? false : true;
    UIColor *panelColor = _overlay ? UIColorRGBA(0x000000, 0.6f) : presentation.panelColor;
    UIColor *panelHighlightColor = _overlay ? UIColorRGBA(0x131313, 0.6f) : presentation.panelHighlightColor;
    UIColor *panelTextColor = _overlay ? [UIColor whiteColor] : presentation.panelTextColor;
    UIColor *actionColor = _overlay ? [UIColor whiteColor] : presentation.actionColor;
    UIColor *panelSubtextColor = _overlay ? [UIColor whiteColor] : presentation.panelSubtextColor;
    
    UIImage *defaultImage = nil;
    UIImage *highlightedImage = nil;
    
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContextWithOptions(rect.size, opaque, 1.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, panelColor.CGColor);
    CGContextFillRect(context, rect);
    defaultImage = UIGraphicsGetImageFromCurrentImageContext();
    
    CGContextClearRect(context, rect);
    CGContextSetFillColorWithColor(context, panelHighlightColor.CGColor);
    CGContextFillRect(context, rect);
    highlightedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [_backgroundButton setBackgroundImage:defaultImage forState:UIControlStateNormal];
    [_backgroundButton setBackgroundImage:highlightedImage forState:UIControlStateHighlighted];
    
    _titleLabel.textColor = panelTextColor;
    [_joinButton setTitleColor:actionColor forState:UIControlStateNormal];
    _checkView.image = TGTintedImage([UIImage imageNamed:@"InstantViewCheck"], panelSubtextColor);
}

- (void)buttonPressed {
    if (_openChannel)
        _openChannel(_channel);
}

- (void)joinPressed {
    if (_joinChannel)
        _joinChannel(_channel);
    
    _joinButton.userInteractionEnabled = false;
    
    if (iosMajorVersion() >= 7)
    {
        _checkView.alpha = 0.0f;
        _checkView.transform = CGAffineTransformMakeScale(0.3f, 0.3f);
        
        [UIView animateWithDuration:0.4 delay:0.0 usingSpringWithDamping:1.5 initialSpringVelocity:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^
        {
            _checkView.transform = CGAffineTransformIdentity;
            _joinButton.transform = CGAffineTransformMakeScale(0.001f, 0.001f);
        } completion:nil];
        
        dispatch_async(dispatch_get_main_queue(), ^
        {
            [UIView animateWithDuration:0.15 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^
            {
                _checkView.alpha = 1.0f;
                _joinButton.alpha = 0.0f;
            } completion:nil];
        });
    }
    else
    {
        _joinButton.alpha = 0.0f;
        _checkView.alpha = 1.0f;
    }
}

- (void)setOpenChannel:(void (^)(TGConversation *))openChannel {
    _openChannel = [openChannel copy];
}

- (void)setJoinChannel:(void (^)(TGConversation *))joinChannel {
    _joinChannel = [joinChannel copy];
}

- (void)updateWithChannel:(TGConversation *)channel {
    _channel = channel;
    
    if (channel.kind != TGConversationKindPersistentChannel)
    {
        _joinButton.userInteractionEnabled = true;
        
        [UIView animateWithDuration:0.2 animations:^{
            _joinButton.alpha = 1.0f;
        }];
    }
    
    _titleLabel.text = channel.chatTitle;
    [_titleLabel sizeToFit];
    [self setNeedsLayout];
}

- (void)setIsVisible:(bool)__unused isVisible {
}

+ (UIEdgeInsets)insets {
    return UIEdgeInsetsMake(10.0f, 18.0f, 10.0f, 18.0f);
}

- (void)layoutSubviews {
    _backgroundButton.frame = self.bounds;
    
    UIEdgeInsets insets = [TGInstantPageChannelView insets];
    _titleLabel.frame = CGRectMake(insets.left, floor((self.frame.size.height - _titleLabel.frame.size.height) / 2.0f), _titleLabel.frame.size.width, _titleLabel.frame.size.height);
    _joinButton.frame = CGRectMake(self.frame.size.width - _joinButton.bounds.size.width - insets.right, 0.0f, _joinButton.bounds.size.width, self.frame.size.height);
    _checkView.frame = CGRectMake(self.frame.size.width - _checkView.bounds.size.width - insets.right, floor((self.frame.size.height - _checkView.bounds.size.height) / 2.0f), _checkView.bounds.size.width, _checkView.bounds.size.height);
}

+ (CGFloat)height {
    return 40.0f;
}

@end
