#import "TGInstantPageControllerNavigationBar.h"

#import <LegacyComponents/LegacyComponents.h>

#import <LegacyComponents/TGModernButton.h>

static UIImage *arrowImage() {
    static UIImage *image = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        image = TGImageNamed(@"InstantPageBackArrow.png");
    });
    return image;
}

@interface TGInstantPageControllerNavigationBar () {
    CGFloat _progress;
    
    UIView *_progressView;
    TGModernButton *_backButton;
    TGModernButton *_shareButton;
    TGModernButton *_settingsButton;
    UIButton *_scrollToTopButton;
    UIImageView *_arrowView;
}

@end

@implementation TGInstantPageControllerNavigationBar

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        self.backgroundColor = [UIColor blackColor];
        _progressView = [[UIView alloc] init];
        _progressView.backgroundColor = UIColorRGB(0x242425);
        _progressView.userInteractionEnabled = false;
        [self addSubview:_progressView];
        
        _backButton = [[TGModernButton alloc] init];
        _backButton.modernHighlight = true;
        _arrowView = [[UIImageView alloc] initWithImage:arrowImage()];
        [_backButton addSubview:_arrowView];
        [self addSubview:_backButton];
        [self addSubview:_shareButton];
        
        _shareButton = [[TGModernButton alloc] init];
        _shareButton.adjustsImageWhenHighlighted = false;
        [_shareButton setImage:TGImageNamed(@"InstantViewShareIcon") forState:UIControlStateNormal];
        [self addSubview:_shareButton];
        
        _settingsButton = [[TGModernButton alloc] init];
        _settingsButton.adjustsImageWhenHighlighted = false;
        [_settingsButton setImage:TGImageNamed(@"InstantViewMoreIcon") forState:UIControlStateNormal];
        [self addSubview:_settingsButton];
        
        _scrollToTopButton = [[UIButton alloc] init];
        [_scrollToTopButton addTarget:self action:@selector(scrollToTopPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_scrollToTopButton];
        
        [_backButton addTarget:self action:@selector(backButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [_shareButton addTarget:self action:@selector(shareButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [_settingsButton addTarget:self action:@selector(settingsButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        
        if (iosMajorVersion() >= 11)
            self.accessibilityIgnoresInvertColors = true;
    }
    return self;
}

- (void)setProgress:(CGFloat)progress {
    _progress = progress;
    [self layoutProgress];
}

- (CGPoint)settingsButtonCenter {
    return _settingsButton.center;
}

- (void)setNavigationButtonsDimmed:(bool)dimmed animated:(bool)animated {
    void (^changeBlock)(void) = ^{
        _backButton.alpha = dimmed ? 0.5f : 1.0f;
        _shareButton.alpha = dimmed ? 0.5f : 1.0f;
    };
    
    if (animated) {
        [UIView animateWithDuration:0.2 animations:changeBlock];
    } else {
        changeBlock();
    }
}

- (void)setSafeAreaInset:(UIEdgeInsets)safeAreaInset
{
    _safeAreaInset = safeAreaInset;
    [self setNeedsLayout];
}

- (void)setCollapsedHeight:(CGFloat)collapsedHeight
{
    _collapsedHeight = collapsedHeight;
    [self setNeedsLayout];
}

- (void)setExpandedHeight:(CGFloat)expandedHeight
{
    _expandedHeight = expandedHeight;
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGSize size = self.bounds.size;
    
    _backButton.frame = CGRectMake(1.0f, 0.0f, 100.0f, size.height);
    CGFloat arrowHeight = 0.0f;
    CGSize arrowImageSize = arrowImage().size;
    
    CGFloat delta = _expandedHeight - _collapsedHeight;
    CGFloat x = 9.0f;
    CGFloat y = 87.0f / 11.0f;
    CGFloat collapsedLineHeight = 20.0f;
    if (_collapsedHeight > 20.0f)
    {
        x = 10.8f;
        y = -10.5f;
        collapsedLineHeight = 18.0f;
    }
    
    CGFloat alpha = (size.height - _collapsedHeight) / delta;
    if (size.height >= self.expandedHeight - FLT_EPSILON)
        arrowHeight = 21.0f;
    else
        arrowHeight = 12 + 9.0f * alpha;
    CGSize scaledArrowSize = CGSizeMake(arrowImageSize.width * arrowHeight / arrowImageSize.height, arrowHeight);
    CGPoint arrowCenter = CGPointMake(8.0f + TGScreenPixel + _safeAreaInset.left + scaledArrowSize.width / 2.0f, (size.height - 44.0f / 2.0f) * alpha + (size.height - collapsedLineHeight / 2.0f) * (1 - alpha));
    
    _arrowView.frame = CGRectMake(arrowCenter.x - scaledArrowSize.width / 2.0f, arrowCenter.y - scaledArrowSize.height / 2.0f, scaledArrowSize.width, scaledArrowSize.height);
    
    CGFloat scale = MIN(1.0f, 0.35f + alpha);
    CGFloat offset = delta * (1.0f - scale) / 6.0f;
    
    _shareButton.transform = CGAffineTransformIdentity;
    _shareButton.frame = CGRectMake(self.frame.size.width - 44.0f - 44.0f - _safeAreaInset.right + offset * 2.0f, arrowCenter.y - 44.0f / 2.0f, 44.0f, 44.0f);
    _shareButton.transform = CGAffineTransformMakeScale(scale, scale);
    _shareButton.alpha = alpha;
    
    _settingsButton.transform = CGAffineTransformIdentity;
    _settingsButton.frame = CGRectMake(self.frame.size.width - 44.0f - _safeAreaInset.right + offset, arrowCenter.y - 44.0f / 2.0f, 44.0f, 44.0f);
    _settingsButton.transform = CGAffineTransformMakeScale(scale, scale);
    _settingsButton.alpha = alpha;
    
    _scrollToTopButton.frame = CGRectMake(100.0f, 0.0f, size.width - 100.0f - 80.0f - 44.0f, size.height);
    
    [self layoutProgress];
}

- (void)layoutProgress {
    CGFloat height = self.frame.size.height;
    CGFloat inset = 0.0f;
    if (_safeAreaInset.top > FLT_EPSILON)
    {
        inset = _safeAreaInset.top - 12.0f;
        height = self.frame.size.height - inset;
    }
    _progressView.frame = CGRectMake(0.0f, inset, self.frame.size.width * _progress, height);
}

- (void)backButtonPressed {
    if (_backPressed) {
        _backPressed();
    }
}

- (void)shareButtonPressed {
    if (_sharePressed) {
        _sharePressed();
    }
}

- (void)settingsButtonPressed {
    if (_settingsPressed) {
        _settingsPressed();
    }
}

- (void)scrollToTopPressed {
    if (_scrollToTop) {
        _scrollToTop();
    }
}

@end
