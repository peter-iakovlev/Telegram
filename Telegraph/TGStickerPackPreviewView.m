#import "TGStickerPackPreviewView.h"

#import "TGFont.h"
#import "TGModernButton.h"
#import "TGPagerView.h"

#import "TGStickerPreviewPagingScrollView.h"

@interface TGStickerPackPreviewView ()
{
    TGStickerPack *_stickerPack;
    NSString *_actionTitle;
    void (^_action)();
    
    UIView *_dimView;
    UIImageView *_backgroundView;
    
    UILabel *_titleLabel;
    TGModernButton *_dismissButton;
    UIButton *_actionButton;
    
    TGPagerView *_pageControl;
    TGStickerPreviewPagingScrollView *_pagingView;
}

@end

@implementation TGStickerPackPreviewView

- (UIImage *)backgroundImage
{
    static UIImage *image = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        CGFloat diameter = 10.0f;
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(diameter, diameter), false, 0.0f);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
        CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, diameter, diameter));
        image = [UIGraphicsGetImageFromCurrentImageContext() stretchableImageWithLeftCapWidth:(NSInteger)(diameter / 2.0f) topCapHeight:(NSInteger)(diameter / 2.0f)];
        UIGraphicsEndImageContext();
    });
    return image;
}

- (UIImage *)actionButtonImage
{
    static UIImage *image = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        CGFloat diameter = 36.0f;
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(diameter, diameter), false, 0.0f);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, UIColorRGB(0x4fc953).CGColor);
        CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, diameter, diameter));
        image = [UIGraphicsGetImageFromCurrentImageContext() stretchableImageWithLeftCapWidth:(NSInteger)(diameter / 2.0f) topCapHeight:(NSInteger)(diameter / 2.0f)];
        UIGraphicsEndImageContext();
    });
    return image;
}

- (UIImage *)dismissImage
{
    static UIImage *image = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        CGSize size = CGSizeMake(13.0f, 13.0f);
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0f);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetStrokeColorWithColor(context, UIColorRGB(0x9c9d9e).CGColor);
        CGFloat lineWidth = 1.4f;
        CGFloat lineInset = lineWidth / 2.0f;
        CGContextSetLineWidth(context, lineWidth);
        CGPoint lineSegments[4] = {
            CGPointMake(lineInset, lineInset),
            CGPointMake(size.width - lineInset, size.height - lineInset),
            CGPointMake(size.width - lineInset, lineInset),
            CGPointMake(lineInset, size.height - lineInset)
        };
        CGContextStrokeLineSegments(context, lineSegments, 4);
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    });
    return image;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        _dimView = [[UIView alloc] init];
        _dimView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.5f];
        [_dimView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dimViewTapped:)]];
        [self addSubview:_dimView];
        
        _backgroundView = [[UIImageView alloc] initWithImage:[self backgroundImage]];
        _backgroundView.userInteractionEnabled = true;
        [self addSubview:_backgroundView];
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.font = TGBoldSystemFontOfSize(16.0f);
        [_backgroundView addSubview:_titleLabel];
        
        _pageControl = [[TGPagerView alloc] initWithDotColors:@[UIColorRGB(0xa1a1a1)] dotSize:5.0f];
        _pageControl.dotSpacing = 5.0f;
        [_pageControl setPage:0.0f];
        [_backgroundView addSubview:_pageControl];
        
        _pagingView = [[TGStickerPreviewPagingScrollView alloc] init];
        __weak TGStickerPackPreviewView *weakSelf = self;
        _pagingView.pageChanged = ^(CGFloat page)
        {
            __strong TGStickerPackPreviewView *strongSelf = weakSelf;
            if (strongSelf != nil)
                [strongSelf->_pageControl setPage:page];
        };
        [_backgroundView addSubview:_pagingView];
        
        UIImage *dismissImage = [self dismissImage];
        _dismissButton = [[TGModernButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, dismissImage.size.width + 20.0f, dismissImage.size.height + 20.0f)];
        [_dismissButton setImage:dismissImage forState:UIControlStateNormal];
        [_dismissButton addTarget:self action:@selector(dismissPressed) forControlEvents:UIControlEventTouchUpInside];
        [_backgroundView addSubview:_dismissButton];
        
        _actionButton = [[UIButton alloc] init];
        [_actionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _actionButton.titleLabel.font = TGMediumSystemFontOfSize(14.0f);
        [_actionButton setBackgroundImage:[self actionButtonImage] forState:UIControlStateNormal];
        _actionButton.hidden = true;
        [_actionButton addTarget:self action:@selector(actionPressed) forControlEvents:UIControlEventTouchUpInside];
        [_backgroundView addSubview:_actionButton];
        
        _dimView.alpha = 0.0f;
        _backgroundView.alpha = 0.0f;
    }
    return self;
}

- (void)animateAppear
{
    _dimView.alpha = 0.0f;
    _backgroundView.alpha = 0.0f;
    _backgroundView.transform = CGAffineTransformMakeScale(0.94f, 0.94f);
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^
    {
        _dimView.alpha = 1.0f;
        _backgroundView.alpha = 1.0f;
        _backgroundView.transform = CGAffineTransformIdentity;
    } completion:nil];
}

- (void)animateDismiss:(void (^)())completion
{
    [UIView animateWithDuration:0.2 animations:^
    {
        _dimView.alpha = 0.0f;
        _backgroundView.transform = CGAffineTransformMakeScale(0.9f, 0.9f);
        _backgroundView.alpha = 0.0f;
    } completion:^(__unused BOOL finished)
    {
        if (completion)
            completion();
    }];
}

- (void)dismissPressed
{
    [self animateDismiss:^
    {
        if (_dismiss)
            _dismiss();
    }];
}

- (void)actionPressed
{
    if (_action)
        _action();
}

- (void)dimViewTapped:(UITapGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        [self dismissPressed];
    }
}

- (void)setStickerPack:(TGStickerPack *)stickerPack
{
    _stickerPack = stickerPack;
    
    NSString *title = stickerPack.title;
    if ([stickerPack.packReference isKindOfClass:[TGStickerPackBuiltinReference class]])
        title = TGLocalized(@"StickerPack.BuiltinPackName");
    _titleLabel.text = title;
    
    [_pagingView setStickerPack:stickerPack];
    [_pageControl setPagesCount:(int)[_pagingView pageCount]];
    
    [self setNeedsLayout];
}

- (void)setAction:(void (^)())action title:(NSString *)title
{
    _action = [action copy];
    _actionTitle = title;
    
    [_actionButton setTitle:title forState:UIControlStateNormal];
    _actionButton.hidden = _action == nil;
    
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _dimView.frame = CGRectMake(0.0f, 0.0f, self.frame.size.width, self.frame.size.height);
    
    CGSize titleSize = [_titleLabel.text sizeWithFont:_titleLabel.font];
    titleSize.width = MIN(278.0f - 20.0f - 40.0f, titleSize.width);
    
    bool reducedMode = self.frame.size.height < 480.0f- FLT_EPSILON;
    
    CGSize pagingViewSize = CGSizeMake(278.0f, 220.0f);
    if (_stickerPack.documents.count < 4)
        pagingViewSize.height = 75.0f;
    else if (_stickerPack.documents.count < 7)
        pagingViewSize.height = 140.0f;
    
    CGSize contentSize = CGSizeMake(278.0f, (reducedMode ? 75.0f : 130.0f) + pagingViewSize.height);
    if (_actionButton.hidden)
        contentSize.height -= 36.0f;
    CGFloat actionAreaHeight = 0.0f;
    
    if (!_actionButton.hidden)
        actionAreaHeight = 36.0f + 12.0f;
    
    CGPoint backgroundOrigin = CGPointMake(CGFloor((self.frame.size.width - contentSize.width) / 2.0f), CGFloor((self.frame.size.height - contentSize.height) / 2.0f) + (reducedMode ? 10.0f : 0.0f));
    CGPoint contentOrigin = CGPointMake(0.0f, 0.0f);
    
    CGAffineTransform backgroundTransform = _backgroundView.transform;
    _backgroundView.transform = CGAffineTransformIdentity;
    _backgroundView.frame = CGRectMake(backgroundOrigin.x, backgroundOrigin.y, contentSize.width, contentSize.height);
    _backgroundView.transform = backgroundTransform;
    
    CGFloat titleControlsOffset = reducedMode ? -10.0f : 0.0f;
    _titleLabel.frame = CGRectMake(contentOrigin.x + 19.0f, contentOrigin.y + 17.0f + titleControlsOffset, titleSize.width, titleSize.height);
    
    _dismissButton.frame = CGRectMake(contentOrigin.x + contentSize.width - 10.0f - _dismissButton.frame.size.width, contentOrigin.y + 10.0f + titleControlsOffset, _dismissButton.frame.size.width, _dismissButton.frame.size.height);
    
    _pageControl.alpha = (reducedMode || [_pagingView pageCount] == 1) ? 0.0f : 1.0f;
    [_pageControl sizeToFit];
    _pageControl.frame = CGRectMake(contentOrigin.x + CGFloor((contentSize.width - _pageControl.frame.size.width) / 2.0f), contentOrigin.y + contentSize.height - actionAreaHeight - 14.0f - _pageControl.frame.size.height, _pageControl.frame.size.width, _pageControl.frame.size.height);
    
    CGFloat pagingViewOffset = reducedMode ? -14.0f : 0.0f;
    _pagingView.frame = CGRectMake(contentOrigin.x + CGFloor((contentSize.width - pagingViewSize.width) / 2.0f), contentOrigin.y + 56.0f + titleControlsOffset + pagingViewOffset, pagingViewSize.width, pagingViewSize.height);
    
    if (!_actionButton.hidden)
    {
        [_actionButton sizeToFit];
        CGFloat actionButtonPadding = 18.0f;
        _actionButton.frame = CGRectMake(contentOrigin.x + CGFloor((contentSize.width - _actionButton.frame.size.width - actionButtonPadding * 2.0f) / 2.0f), contentOrigin.y + contentSize.height - (reducedMode ? 4.0f : 14.0f) - 36.0f, _actionButton.frame.size.width + actionButtonPadding * 2.0f, 36.0f);
    }
}

@end
