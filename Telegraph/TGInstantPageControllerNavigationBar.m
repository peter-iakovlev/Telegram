#import "TGInstantPageControllerNavigationBar.h"

#import "TGModernButton.h"
#import "TGImageUtils.h"

static UIImage *arrowImage() {
    static UIImage *image = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        image = [UIImage imageNamed:@"InstantPageBackArrow.png"];
    });
    return image;
}

@interface TGInstantPageControllerNavigationBar () {
    TGModernButton *_backButton;
    TGModernButton *_shareButton;
    UIButton *_scrollToTopButton;
    UIImageView *_arrowView;
    UILabel *_shareLargeLabel;
    UILabel *_shareSmallLabel;
}

@end

@implementation TGInstantPageControllerNavigationBar

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        self.backgroundColor = [UIColor blackColor];
        _backButton = [[TGModernButton alloc] init];
        _backButton.modernHighlight = true;
        _shareButton = [[TGModernButton alloc] init];
        _shareButton.modernHighlight = true;
        _arrowView = [[UIImageView alloc] initWithImage:arrowImage()];
        
        _shareLargeLabel = [[UILabel alloc] init];
        _shareLargeLabel.font = [UIFont systemFontOfSize:17.0];
        _shareLargeLabel.backgroundColor = nil;
        _shareLargeLabel.opaque = false;
        _shareLargeLabel.textColor = [UIColor colorWithWhite:1.0f alpha:0.7f];
        _shareLargeLabel.text = TGLocalized(@"Channel.Share");
        [_shareLargeLabel sizeToFit];
        _shareLargeLabel.alpha = 1.0f;
        
        _shareSmallLabel = [[UILabel alloc] init];
        _shareSmallLabel.font = [UIFont systemFontOfSize:12.0];
        _shareSmallLabel.backgroundColor = nil;
        _shareSmallLabel.opaque = false;
        _shareSmallLabel.textColor = [UIColor colorWithWhite:1.0f alpha:0.7f];
        _shareSmallLabel.text = TGLocalized(@"Channel.Share");
        [_shareSmallLabel sizeToFit];
        _shareSmallLabel.alpha = 1.0f;
        
        [_backButton addSubview:_arrowView];
        [_shareButton addSubview:_shareLargeLabel];
        //[_shareButton addSubview:_shareSmallLabel];
        [self addSubview:_backButton];
        [self addSubview:_shareButton];
        
        _scrollToTopButton = [[UIButton alloc] init];
        [_scrollToTopButton addTarget:self action:@selector(scrollToTopPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_scrollToTopButton];
        
        [_backButton addTarget:self action:@selector(backButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [_shareButton addTarget:self action:@selector(shareButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGSize size = self.bounds.size;
    
    _backButton.frame = CGRectMake(1.0f, 0.0f, 100.0f, size.height);
    CGFloat arrowHeight = 0.0f;
    CGSize arrowImageSize = arrowImage().size;
    if (size.height >= 64.0 - FLT_EPSILON) {
        arrowHeight = 21.0f;
    } else {
        arrowHeight = 9.0f * size.height / 44.0f + 87.0f / 11.0f;
    }
    CGSize scaledArrowSize = CGSizeMake(arrowImageSize.width * arrowHeight / arrowImageSize.height, arrowHeight);
    _arrowView.frame = CGRectMake(8.0f + TGRetinaPixel, MAX(0.0f, size.height - 44.0f) + TGRetinaFloor((MIN(size.height, 44.0f) - scaledArrowSize.height) / 2.0f), scaledArrowSize.width, scaledArrowSize.height);
    
    _shareButton.frame = CGRectMake(size.width - 100.0f, 0.0f, 100.0f, size.height);
    _shareLargeLabel.transform = CGAffineTransformIdentity;
    _shareSmallLabel.transform = CGAffineTransformIdentity;
    CGSize shareImageSize = _shareLargeLabel.bounds.size;
    CGSize shareSmallImageSize = _shareSmallLabel.bounds.size;
    CGFloat shareHeight = 0.0f;
    if (size.height >= 64.0 - FLT_EPSILON) {
        shareHeight = shareImageSize.height;
    } else {
        // shareImageSize.height = k * 64.0 + b
        // shareSmallImageSize.height = k * 20.0 + b
        // shareImageSize.height - shareSmallImageSize.height = k * 44.0
        // k = (shareImageSize.height - shareSmallImageSize.height) / 44.0
        // b = shareSmallImageSize.height - k * 20.0
        CGFloat k = (shareImageSize.height - shareSmallImageSize.height) / 44.0f;
        CGFloat b = shareSmallImageSize.height - k * 20.0f;
        shareHeight = k * size.height + b;
    }
    CGFloat shareHeightFactor = shareHeight / shareImageSize.height;
    _shareLargeLabel.transform = CGAffineTransformMakeScale(shareHeightFactor, shareHeightFactor);
    
    CGFloat shareSmallHeightFactor = shareHeight / shareSmallImageSize.height;
    _shareSmallLabel.transform = CGAffineTransformMakeScale(shareSmallHeightFactor, shareSmallHeightFactor);
    
    CGSize scaledShareSize = CGSizeMake(shareImageSize.width * shareHeightFactor, shareImageSize.height * shareHeightFactor);
    CGSize scaledShareSmallSize = CGSizeMake(shareSmallImageSize.width * shareSmallHeightFactor, shareSmallImageSize.height * shareSmallHeightFactor);
    _shareLargeLabel.center = CGPointMake(100.0f - 8.0f - scaledShareSize.width / 2.0f, MAX(0.0f, size.height - 44.0f) + MIN(size.height, 44.0f) / 2.0f);
    _shareSmallLabel.center = CGPointMake(100.0f - 8.0f - scaledShareSmallSize.width / 2.0f, MAX(0.0f, size.height - 44.0f) + MIN(size.height, 44.0f) / 2.0f);
    
    _scrollToTopButton.frame = CGRectMake(100.0f, 0.0f, size.width - 200.0f, size.height);
    
    //_shareLargeLabel.frame = CGRectMake(100.0f - scaledShareSize.width - 8.0f, MAX(0.0f, size.height - 44.0f) + TGRetinaFloor((MIN(size.height, 44.0f) - scaledShareSize.height) / 2.0f), scaledShareSize.width, scaledShareSize.height);
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

- (void)scrollToTopPressed {
    if (_scrollToTop) {
        _scrollToTop();
    }
}

@end
