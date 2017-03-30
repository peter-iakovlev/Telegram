#import "TGPaymentAlertView.h"

@interface TGPaymentAlertView () {
    UIView *_dimView;
    UIImageView *_backgroundView;
}

@end

@implementation TGPaymentAlertView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        _dimView = [[UIView alloc] init];
        _dimView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.5f];
        [_dimView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dimViewTapped:)]];
        _dimView.alpha = 0.0f;
        [self addSubview:_dimView];
    }
    return self;
}

- (void)animateAppear {
    _dimView.alpha = 0.0f;
    _backgroundView.alpha = 0.0f;
    _backgroundView.transform = CGAffineTransformMakeScale(0.94f, 0.94f);
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^ {
        _dimView.alpha = 1.0f;
        _backgroundView.alpha = 1.0f;
        _backgroundView.transform = CGAffineTransformIdentity;
    } completion:nil];
}

- (void)animateDismiss:(void (^)())completion {
    [UIView animateWithDuration:0.2 animations:^ {
        _dimView.alpha = 0.0f;
        _backgroundView.transform = CGAffineTransformMakeScale(0.9f, 0.9f);
        _backgroundView.alpha = 0.0f;
    } completion:^(__unused BOOL finished) {
        if (completion)
            completion();
    }];
}

- (void)dismissPressed {
    [self animateDismiss:^{
        if (_dismiss)
            _dismiss();
    }];
}

- (void)dimViewTapped:(UITapGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        [self dismissPressed];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _dimView.frame = CGRectMake(0.0f, 0.0f, self.frame.size.width, self.frame.size.height);
    
    CGFloat contentWidth = MIN(320.0f, self.frame.size.width - 56.0f);
    
    /*CGSize titleSize = [_titleLabel.text sizeWithFont:_titleLabel.font constrainedToSize:CGSizeMake(contentWidth - 36.0f, 1000.0f)];
    
    CGFloat scrollHeight = MIN(3, (int)_stickerPacks.count) * 56.0f;
    CGSize contentSize = CGSizeMake(contentWidth, titleSize.height + 36.0f + 56.0f + scrollHeight);
    
    CGPoint backgroundOrigin = CGPointMake(CGFloor((self.frame.size.width - contentSize.width) / 2.0f), CGFloor((self.frame.size.height - contentSize.height) / 2.0f));
    CGPoint contentOrigin = CGPointMake(0.0f, 0.0f);
    
    CGAffineTransform backgroundTransform = _backgroundView.transform;
    _backgroundView.transform = CGAffineTransformIdentity;
    _backgroundView.frame = CGRectMake(backgroundOrigin.x, backgroundOrigin.y, contentSize.width, contentSize.height);
    _backgroundView.transform = backgroundTransform;
    
    _topSeparator.frame = CGRectMake(0.0f, titleSize.height + 36.0f, contentWidth, 1.0f / TGScreenScaling());
    
    _bottomSeparator.frame = CGRectMake(0.0f, contentSize.height - 56.0f - 1.0f / TGScreenScaling(), contentWidth, 1.0f / TGScreenScaling());
    
    _titleLabel.frame = CGRectMake(contentOrigin.x + CGFloor((contentSize.width - titleSize.width) / 2.0f), contentOrigin.y + 20.0f, titleSize.width, titleSize.height);
    
    _stickerPacksScrollView.frame = CGRectMake(0.0f, titleSize.height + 36.0f, contentSize.width, scrollHeight);
    _stickerPacksScrollView.contentSize = CGSizeMake(contentSize.width, _stickerPacks.count * 56.0f);
    CGFloat viewOffset = 0.0f;
    for (UIView *view in _stickerPackViews) {
        view.frame = CGRectMake(0.0f, viewOffset, contentSize.width, 56.0f);
        viewOffset += 56.0f;
    }
    _actionButton.frame = CGRectMake(contentOrigin.x, contentOrigin.y + contentSize.height - 56.0f, contentSize.width, 56.0f);*/
}

@end
