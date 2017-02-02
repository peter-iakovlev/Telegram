#import "TGCallEncryptionKeyView.h"

#import "TGStringUtils.h"
#import "TGImageUtils.h"
#import "TGCallUtils.h"
#import "TGFont.h"
#import "TGBlurEffect.h"

#import "TGViewController.h"

#import "UIControl+HitTestEdgeInsets.h"
#import "TGModernButton.h"

#import "TGCallSession.h"
#import "TGUser.h"

typedef enum
{
    TGCallKeyViewTransitionTypeUsual,
    TGCallKeyViewTransitionTypeSimplified,
    TGCallKeyViewTransitionTypeLegacy
} TGCallKeyViewTransitionType;

@interface TGCallEncryptionKeyView ()
{
    UIView *_backgroundView;
    
    UIView *_wrapperView;
    TGModernButton *_backButton;
    UILabel *_titleLabel;
    
    UIImageView *_keyImageView;
    UILabel *_fingerprintLabel;
    UILabel *_descriptionLabel;
    UIButton *_linkButton;
    
    NSString *_name;
    
    NSData *_sha1;
    
    bool _keyInitialized;
    
    UIView *_initialIdenticonSuperview;
    CGRect _initialIdenticonFrame;
}

@end

@implementation TGCallEncryptionKeyView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        TGCallKeyViewTransitionType type = [self _transitionType];
        
        if (type != TGCallKeyViewTransitionTypeLegacy)
        {
            _backgroundView = [[UIVisualEffectView alloc] initWithEffect:nil];
            if (type == TGCallKeyViewTransitionTypeSimplified)
            {
                ((UIVisualEffectView *)_backgroundView).effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
                _backgroundView.alpha = 0.0f;
            }
        }
        else
        {
            _backgroundView = [[UIView alloc] init];
            _backgroundView.alpha = 0.0f;
            _backgroundView.backgroundColor = UIColorRGBA(0x000000, 0.5f);
        }
        _backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _backgroundView.frame = self.bounds;
        [self addSubview:_backgroundView];
        
        _wrapperView = [[UIView alloc] initWithFrame:self.bounds];
        _wrapperView.alpha = 0.0f;
        _wrapperView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:_wrapperView];
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = TGMediumSystemFontOfSize(17);
        _titleLabel.text = TGLocalized(@"Call.EncryptionKey.Title");
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = [UIColor whiteColor];
        [_titleLabel sizeToFit];
        [_wrapperView addSubview:_titleLabel];
        
        _keyImageView = [[UIImageView alloc] init];
        [self addSubview:_keyImageView];
        
        _fingerprintLabel = [[UILabel alloc] init];
        _fingerprintLabel.textColor = [UIColor blackColor];
        _fingerprintLabel.backgroundColor = [UIColor clearColor];
        NSString *fontName = @"CourierNew-Bold";
        if (iosMajorVersion() >= 7) {
            fontName = @"Menlo-Bold";
        }
        _fingerprintLabel.font = [UIFont fontWithName:fontName size:14];
        _fingerprintLabel.numberOfLines = 4;
        [_wrapperView addSubview:_fingerprintLabel];
        
        _descriptionLabel = [[UILabel alloc] init];
        _descriptionLabel.textColor = [UIColor blackColor];
        _descriptionLabel.backgroundColor = [UIColor clearColor];
        _descriptionLabel.font = [UIFont systemFontOfSize:14];
        _descriptionLabel.textAlignment = NSTextAlignmentCenter;
        _descriptionLabel.numberOfLines = 0;
        [_wrapperView addSubview:_descriptionLabel];
        
        _linkButton = [[UIButton alloc] init];
        [_linkButton setBackgroundImage:[UIImage imageNamed:@"Transparent.png"] forState:UIControlStateNormal];
        UIImage *rawLinkImage = [UIImage imageNamed:@"LinkFull.png"];
        [_linkButton setBackgroundImage:[rawLinkImage stretchableImageWithLeftCapWidth:(int)(rawLinkImage.size.width / 2) topCapHeight:(int)(rawLinkImage.size.height / 2)] forState:UIControlStateHighlighted];
        [_linkButton addTarget:self action:@selector(linkButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [_wrapperView addSubview:_linkButton];

        _backButton = [[TGModernButton alloc] initWithFrame:CGRectZero];
        _backButton.exclusiveTouch = true;
        _backButton.hitTestEdgeInsets = UIEdgeInsetsMake(-5, -20, -5, -5);
        _backButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        _backButton.titleLabel.textAlignment = NSTextAlignmentLeft;
        _backButton.titleLabel.font = TGSystemFontOfSize(17);
        [_backButton setTitle:@"00:00" forState:UIControlStateNormal];
        [_backButton setTitleColor:[UIColor whiteColor]];
        [_backButton addTarget:self action:@selector(backButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_backButton];
        
        UIImageView *arrowView = [[UIImageView alloc] initWithFrame:CGRectMake(-19, 5.5f, 13, 22)];
        arrowView.image = [UIImage imageNamed:@"NavigationBackArrow"];
        [_backButton addSubview:arrowView];
    }
    return self;
}

- (TGCallKeyViewTransitionType)_transitionType
{
    static dispatch_once_t onceToken;
    static TGCallKeyViewTransitionType type;
    dispatch_once(&onceToken, ^
    {
        CGSize screenSize = TGScreenSize();
        if (iosMajorVersion() < 8 || (NSInteger)screenSize.height == 480)
            type = TGCallKeyViewTransitionTypeLegacy;
        else if (iosMajorVersion() == 8)
            type = TGCallKeyViewTransitionTypeSimplified;
        else
            type = TGCallKeyViewTransitionTypeUsual;
    });
    return type;
}

- (void)present
{
    self.hidden = false;
    
    _backButton.hidden = false;
    
    TGCallKeyViewTransitionType type = [self _transitionType];
    [UIView animateWithDuration:0.3 animations:^
    {
        if (type == TGCallKeyViewTransitionTypeUsual)
            ((UIVisualEffectView *)_backgroundView).effect = [TGBlurEffect callBlurEffect];
        else
            _backgroundView.alpha = 1.0f;

        _wrapperView.alpha = 1.0f;
    }];
    
    self.identiconView.frame = [self convertRect:self.identiconView.frame fromView:self.identiconView.superview];
    _initialIdenticonFrame = self.identiconView.frame;
    _initialIdenticonSuperview = self.identiconView.superview;
    [self addSubview:self.identiconView];
    
    [UIView animateWithDuration:0.3 delay:0.0 options:(7 << 16) animations:^
    {
        self.identiconView.frame = _keyImageView.frame;
    } completion:nil];
}

- (void)dismiss
{
    _backButton.hidden = true;
    
    TGCallKeyViewTransitionType type = [self _transitionType];
    [UIView animateWithDuration:0.3 animations:^
    {
        if (type == TGCallKeyViewTransitionTypeUsual)
            ((UIVisualEffectView *)_backgroundView).effect = nil;
        else
            _backgroundView.alpha = 0.0f;
        
        _wrapperView.alpha = 0.0f;
    } completion:nil];
    
    [UIView animateWithDuration:0.3 delay:0.0 options:(7 << 16) animations:^
    {
        self.identiconView.frame = _initialIdenticonFrame;
    } completion:^(__unused BOOL finished)
    {
        [_initialIdenticonSuperview addSubview:self.identiconView];
        self.identiconView.frame = [self convertRect:self.identiconView.frame toView:self.identiconView.superview];
        self.hidden = true;
    }];
}

- (void)backButtonPressed
{
    if (self.backPressed != nil)
        self.backPressed();
}

- (void)setState:(TGCallSessionState *)state duration:(NSTimeInterval)duration
{
    NSString *durationString = duration >= 60 * 60 ? [NSString stringWithFormat:@"%02d:%02d:%02d", (int)(duration / 3600.0), (int)(duration / 60.0) % 60, (int)duration % 60] : [NSString stringWithFormat:@"%02d:%02d", (int)(duration / 60.0) % 60, (int)duration % 60];
    [_backButton setTitle:durationString forState:UIControlStateNormal];
    
    [self setName:state.peer.firstName];
    [self setSha1:state.keySha1 sha256:state.keySha256];
}

- (void)setName:(NSString *)name
{
    if ([name isEqualToString:_name])
        return;
    
    _name = name;
        
    NSString *textFormat = TGLocalized(@"Call.EncryptionKey.Description");
    NSString *baseText = [[NSString alloc] initWithFormat:textFormat, name, name];
    
    if ([_descriptionLabel respondsToSelector:@selector(setAttributedText:)])
    {
        NSDictionary *attrs = @{NSFontAttributeName: _descriptionLabel.font, NSForegroundColorAttributeName: [UIColor whiteColor]}; //[NSDictionary dictionaryWithObjectsAndKeys:@{_descriptionLabel.font, NSFontAttributeName, nil];
        NSDictionary *subAttrs = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:_descriptionLabel.font.pointSize], NSForegroundColorAttributeName: [UIColor whiteColor]};
        NSDictionary *linkAtts = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
        
        NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:baseText attributes:attrs];
        
        [attributedText setAttributes:subAttrs range:NSMakeRange([textFormat rangeOfString:@"%1$@"].location, name.length)];
        [attributedText setAttributes:subAttrs range:NSMakeRange([textFormat rangeOfString:@"%2$@"].location + (name.length - @"%1$@".length), name.length)];
        [attributedText setAttributes:linkAtts range:[baseText rangeOfString:@"telegram.org"]];
        
        [_descriptionLabel setAttributedText:attributedText];
    }
    else
    {
        [_descriptionLabel setText:baseText];
    }
    
    [self setNeedsLayout];
}

- (void)setSha1:(NSData *)sha1 sha256:(NSData *)sha256
{
    if (sha1 == nil || _keyInitialized)
        return;
    
    _keyInitialized = true;
    
    if (sha1 != nil)
    {
        NSData *hashData = sha1;
        if (hashData != nil)
        {
            if (sha256 != nil) {
                NSMutableData *data = [[NSMutableData alloc] init];
                [data appendData:sha1];
                [data appendData:sha256];
                
                NSString *s1 = [[data subdataWithRange:NSMakeRange(0, 8)] stringByEncodingInHex];
                NSString *s2 = [[data subdataWithRange:NSMakeRange(8, 8)] stringByEncodingInHex];
                NSString *s3 = [[sha256 subdataWithRange:NSMakeRange(0, 8)] stringByEncodingInHex];
                NSString *s4 = [[sha256 subdataWithRange:NSMakeRange(8, 8)] stringByEncodingInHex];
                NSString *text = [[NSString alloc] initWithFormat:@"%@\n%@\n%@\n%@", s1, s2, s3, s4];
                
                if (![TGViewController isWidescreen]) {
                    text = [[NSString alloc] initWithFormat:@"%@%@\n%@%@", s1, s2, s3, s4];
                }
                
                NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
                style.lineSpacing = 3.0f;
                style.lineBreakMode = NSLineBreakByWordWrapping;
                style.alignment = NSTextAlignmentCenter;
                
                CGFloat kerning = 1.75f;
                CGSize screenSize = TGScreenSize();
                if ((int)screenSize.height == 480)
                {
                    kerning = 1.0f;
                    style.lineSpacing = 1.5f;
                }
                
                NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:text attributes:@{NSParagraphStyleAttributeName: style, NSFontAttributeName: _fingerprintLabel.font, NSForegroundColorAttributeName: [UIColor whiteColor], NSKernAttributeName: @(kerning)}];
                
                _fingerprintLabel.attributedText = attributedString;
            }
        }
    }
    
    [self setNeedsLayout];
}

- (void)linkButtonPressed
{
    [[UIApplication sharedApplication] openURL:[[NSURL alloc] initWithString:@"https://telegram.org/faq#secret-chats"]];
}

- (void)layoutSubviews
{
    [_backButton sizeToFit];
    _backButton.frame = CGRectMake(27, 25.5f, ceil(_backButton.frame.size.width) + 4.0f, ceil(_backButton.frame.size.height));
    
    CGSize screenSize = TGScreenSize();
    
    _fingerprintLabel.alpha = 1.0f;
    
    _titleLabel.frame = CGRectMake(ceil((self.frame.size.width - _titleLabel.frame.size.width) / 2.0f), 32, _titleLabel.frame.size.width, _titleLabel.frame.size.height);
    
    CGFloat keyOffset = 0.0f;
    CGFloat topInset = 0.0f;
    CGFloat fingerprintOffset = 0.0f;
    CGFloat keySize = 264;
    
    if (TGIsPad()) {
        keyOffset += 12.0f;
        fingerprintOffset += -12.0f;
        topInset += 70.0f;
    } else if ([TGViewController hasVeryLargeScreen]) {
        keyOffset += 60.0f;
        fingerprintOffset += 15.0f;
        topInset += 102.0f;
    } else if ([TGViewController hasLargeScreen]) {
        keyOffset += 50.0f;
        fingerprintOffset += 10.0f;
        topInset += 89.0f;
    } else if ([TGViewController isWidescreen]) {
        keyOffset += 30.0f;
        fingerprintOffset += 2.0f;
        topInset += 70.0f;
        keySize = 240.0f;
    } else {
        keyOffset += 24.0f;
        fingerprintOffset += -2.0f;
        topInset += 20.0f;
        keySize = 216.0f;
    }
    
    keyOffset += 44;
    topInset += 25;
    
    if (_fingerprintLabel.text.length != 0) {
        [_fingerprintLabel sizeToFit];
        CGSize fingerprintSize = _fingerprintLabel.frame.size;
        
        _fingerprintLabel.frame = CGRectMake(CGFloor((screenSize.width - fingerprintSize.width) / 2), fingerprintOffset + keyOffset + keySize + 24, fingerprintSize.width, fingerprintSize.height);
    }
    
    CGSize labelSize = [_descriptionLabel sizeThatFits:CGSizeMake(screenSize.width - 20, 1000)];
    
    _keyImageView.frame = CGRectMake(CGFloor((self.frame.size.width - keySize) / 2), keyOffset, keySize, keySize);
    
    _descriptionLabel.frame = CGRectMake(CGFloor((screenSize.width - labelSize.width) / 2), _keyImageView.frame.origin.y + _keyImageView.frame.size.height + 24 + topInset, labelSize.width, labelSize.height);
    
    NSString *lineText = @"Learn more at telegram.org";
    CGFloat lastWidth = [lineText sizeWithFont:_descriptionLabel.font].width;
    CGFloat prefixWidth = [@"Learn more at " sizeWithFont:_descriptionLabel.font].width;
    CGFloat suffixWidth = [@"telegram.org" sizeWithFont:_descriptionLabel.font].width;
    
    _linkButton.frame = CGRectMake(_descriptionLabel.frame.origin.x + CGFloor((_descriptionLabel.frame.size.width - lastWidth) / 2) + prefixWidth - 3, _descriptionLabel.frame.origin.y + _descriptionLabel.frame.size.height - 18, suffixWidth + 4, 19);
}

@end
