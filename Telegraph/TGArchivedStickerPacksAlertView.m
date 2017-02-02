#import "TGArchivedStickerPacksAlertView.h"

#import "TGFont.h"
#import "TGModernButton.h"
#import "TGPagerView.h"

#import "TGImageUtils.h"

#import "TGStickerPackCollectionItemView.h"

@interface TGArchivedStickerPacksAlertView () {
    NSArray *_stickerPacks;
    
    UIView *_dimView;
    UIImageView *_backgroundView;
    
    UILabel *_titleLabel;
    TGModernButton *_actionButton;
    
    UIView *_topSeparator;
    UIView *_bottomSeparator;
    
    UIScrollView *_stickerPacksScrollView;
    NSArray *_stickerPackViews;
}

@end

@implementation TGArchivedStickerPacksAlertView

- (UIImage *)backgroundImage
{
    static UIImage *image = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CGFloat diameter = 20.0f;
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(diameter, diameter), false, 0.0f);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
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
        _titleLabel.font = TGSystemFontOfSize(14.0f);
        _titleLabel.text = TGLocalized(@"ArchivedPacksAlert.Title");
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.numberOfLines = 0;
        _titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [_backgroundView addSubview:_titleLabel];
        
        _actionButton = [[TGModernButton alloc] init];
        [_actionButton setTitleColor:TGAccentColor() forState:UIControlStateNormal];
        _actionButton.titleLabel.font = TGSystemFontOfSize(19.0f);
        _actionButton.modernHighlight = true;
        [_actionButton addTarget:self action:@selector(dismissPressed) forControlEvents:UIControlEventTouchUpInside];
        [_actionButton setTitle:TGLocalized(@"Common.OK") forState:UIControlStateNormal];
        [_backgroundView addSubview:_actionButton];
        
        _stickerPacksScrollView = [[UIScrollView alloc] init];
        [_backgroundView addSubview:_stickerPacksScrollView];
        
        _topSeparator = [[UIView alloc] init];
        _topSeparator.backgroundColor = TGSeparatorColor();
        [_backgroundView addSubview:_topSeparator];
        
        _bottomSeparator = [[UIView alloc] init];
        _bottomSeparator.backgroundColor = TGSeparatorColor();
        [_backgroundView addSubview:_bottomSeparator];
        
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

- (void)dimViewTapped:(UITapGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        [self dismissPressed];
    }
}

- (void)setStickerPacks:(NSArray *)stickerPacks
{
    _stickerPacks = stickerPacks;
    
    for (UIView *view in _stickerPackViews) {
        [view removeFromSuperview];
    }
    NSMutableArray *stickerPackViews = [[NSMutableArray alloc] init];
    for (TGStickerPack *pack in stickerPacks) {
        TGStickerPackCollectionItemView *packView = [[TGStickerPackCollectionItemView alloc] init];
        packView.enableEditing = false;
        [packView setStickerPack:pack];
        [_stickerPacksScrollView addSubview:packView];
        [stickerPackViews addObject:packView];
    }
    _stickerPackViews = stickerPackViews;
    
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _dimView.frame = CGRectMake(0.0f, 0.0f, self.frame.size.width, self.frame.size.height);
    
    CGFloat contentWidth = MIN(320.0f, self.frame.size.width - 56.0f);
    
    CGSize titleSize = [_titleLabel.text sizeWithFont:_titleLabel.font constrainedToSize:CGSizeMake(contentWidth - 36.0f, 1000.0f)];
    
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
    _actionButton.frame = CGRectMake(contentOrigin.x, contentOrigin.y + contentSize.height - 56.0f, contentSize.width, 56.0f);
}

@end
