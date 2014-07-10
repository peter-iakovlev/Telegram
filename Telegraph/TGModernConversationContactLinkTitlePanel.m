/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGModernConversationContactLinkTitlePanel.h"

#import "TGImageUtils.h"
#import "TGFont.h"

#import "TGModernButton.h"
#import "TGBackdropView.h"

@interface TGModernConversationContactLinkTitlePanel ()
{
    CALayer *_stripeLayer;
    UIView *_backgroundView;
    
    TGModernButton *_actionButton;
    TGModernButton *_closeButton;
    
    bool _actionIsShareContact;
}

@end

@implementation TGModernConversationContactLinkTitlePanel

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
        
        UIImage *closeImage = [UIImage imageNamed:@"ModernConversationTitlePanelClose.png"];
        _closeButton = [[TGModernButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 34, 34)];
        _closeButton.adjustsImageWhenDisabled = false;
        _closeButton.adjustsImageWhenHighlighted = false;
        _closeButton.modernHighlight = true;
        [_closeButton setImage:closeImage forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(closeButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_closeButton];
    }
    return self;
}

- (void)setShareContact:(bool)shareContact
{
    _actionIsShareContact = shareContact;
    
    [_actionButton setTitle:shareContact ? TGLocalized(@"Conversation.ShareMyContactInfo") : TGLocalized(@"Conversation.AddContact") forState:UIControlStateNormal];
}

- (bool)shareContact
{
    return _actionIsShareContact;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _backgroundView.frame = self.bounds;
    _stripeLayer.frame = CGRectMake(0.0f, self.frame.size.height - TGRetinaPixel, self.frame.size.width, TGRetinaPixel);
    _actionButton.frame = CGRectInset(self.bounds, 40.0f, 0.0f);
    
    CGRect closeButtonFrame = _closeButton.frame;
    closeButtonFrame.origin = CGPointMake(self.frame.size.width - 4.0f - TGRetinaPixel - closeButtonFrame.size.width, TGRetinaPixel);
    _closeButton.frame = closeButtonFrame;
}

- (void)actionButtonPressed
{
    id<TGModernConversationContactLinkTitlePanelDelegate> delegate = _delegate;
    if (_actionIsShareContact && [delegate respondsToSelector:@selector(contactLinkTitlePanelShareContactPressed:)])
        [delegate contactLinkTitlePanelShareContactPressed:self];
    else if (!_actionIsShareContact && [delegate respondsToSelector:@selector(contactLinkTitlePanelAddContactPressed:)])
        [delegate contactLinkTitlePanelAddContactPressed:self];
}

- (void)closeButtonPressed
{
    id<TGModernConversationContactLinkTitlePanelDelegate> delegate = _delegate;
    if ([delegate respondsToSelector:@selector(contactLinkTitlePanelDismissed:)])
        [delegate contactLinkTitlePanelDismissed:self];
}

@end
