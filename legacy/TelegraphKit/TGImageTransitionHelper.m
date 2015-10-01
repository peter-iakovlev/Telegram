#import "TGImageTransitionHelper.h"

#import "TGViewController.h"

#import "TGImageUtils.h"

#import "TGRemoteImageView.h"

@interface TGImageTransitionHelper ()

@property (nonatomic, strong) UIView *fadeViewLeft;
@property (nonatomic, strong) UIView *fadeViewRight;
@property (nonatomic, strong) UIView *fadeViewTop;
@property (nonatomic, strong) UIView *fadeViewBottom;

@property (nonatomic, strong) UIView *targetImageContainer;
@property (nonatomic, strong) UIView *targetImageBackgroundView;
@property (nonatomic, strong) UIImageView *targetImageView;

@end

@implementation TGImageTransitionHelper

- (void)dealloc
{
    [_targetImageContainer removeFromSuperview];
    [_targetImageBackgroundView removeFromSuperview];
    [_targetImageView removeFromSuperview];
    [_fadeViewLeft removeFromSuperview];
    [_fadeViewRight removeFromSuperview];
    [_fadeViewTop removeFromSuperview];
    [_fadeViewBottom removeFromSuperview];
}

- (void)beginTransitionIn:(UIView *)imageView fromImage:(UIImage *)fromImage fromView:(UIView *)fromView transform:(CGAffineTransform)transform fromRectInWindowSpace:(CGRect)fromRectInWindowSpace aboveView:(UIView *)aboveView toView:(UIView *)toView toRectInWindowSpace:(CGRect)toRectInWindowSpace toInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation completion:(dispatch_block_t)completion keepAspect:(bool)keepAspect
{
    [self beginTransitionIn:imageView fromImage:fromImage fromView:fromView transform:transform fromRectInWindowSpace:fromRectInWindowSpace aboveView:aboveView toView:toView toRectInWindowSpace:toRectInWindowSpace toInterfaceOrientation:toInterfaceOrientation completion:completion keepAspect:keepAspect duration:0.3];
}

- (void)beginTransitionIn:(UIView *)imageView fromImage:(UIImage *)fromImage fromView:(UIView *)fromView transform:(CGAffineTransform)transform fromRectInWindowSpace:(CGRect)fromRectInWindowSpace aboveView:(UIView *)aboveView toView:(UIView *)toView toRectInWindowSpace:(CGRect)toRectInWindowSpace toInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation completion:(dispatch_block_t)completion keepAspect:(bool)keepAspect duration:(NSTimeInterval)duration
{
    CGSize screenSize = [TGViewController screenSizeForInterfaceOrientation:toInterfaceOrientation];
    
    _fadeViewLeft = [[UIView alloc] init];
    _fadeViewLeft.backgroundColor = [UIColor blackColor];
    _fadeViewLeft.alpha = 0.0f;
    [toView insertSubview:_fadeViewLeft belowSubview:imageView];
    
    _fadeViewRight = [[UIView alloc] init];
    _fadeViewRight.backgroundColor = [UIColor blackColor];
    _fadeViewRight.alpha = 0.0f;
    [toView insertSubview:_fadeViewRight belowSubview:imageView];
    
    _fadeViewTop = [[UIView alloc] init];
    _fadeViewTop.backgroundColor = [UIColor blackColor];
    _fadeViewTop.alpha = 0.0f;
    [toView insertSubview:_fadeViewTop belowSubview:imageView];
    
    _fadeViewBottom = [[UIView alloc] init];
    _fadeViewBottom.backgroundColor = [UIColor blackColor];
    _fadeViewBottom.alpha = 0.0f;
    [toView insertSubview:_fadeViewBottom belowSubview:imageView];
    
    CGRect adjustedFrame = [toView convertRect:fromRectInWindowSpace fromView:fromView.window];
    imageView.frame = adjustedFrame;
    
    _fadeViewLeft.hidden = false;
    _fadeViewRight.hidden = false;
    _fadeViewTop.hidden = false;
    _fadeViewBottom.hidden = false;
    
    _fadeViewLeft.alpha = 0.0f;
    _fadeViewRight.alpha = 0.0f;
    _fadeViewTop.alpha = 0.0f;
    _fadeViewBottom.alpha = 0.0f;
    
    _targetImageContainer = [[UIView alloc] initWithFrame:[fromView convertRect:fromRectInWindowSpace fromView:fromView.window]];
    
    _targetImageBackgroundView = [[UIView alloc] initWithFrame:_targetImageContainer.bounds];
    _targetImageBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _targetImageBackgroundView.alpha = 0.0f;
    [_targetImageContainer addSubview:_targetImageBackgroundView];
    
    _targetImageView = [[UIImageView alloc] initWithFrame:_targetImageContainer.bounds];
    _targetImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _targetImageView.image = fromImage;
    _targetImageView.contentMode = keepAspect ? UIViewContentModeScaleAspectFill : UIViewContentModeScaleToFill;
    _targetImageView.clipsToBounds = true;
    _targetImageView.transform = transform;
    [_targetImageContainer addSubview:_targetImageView];
    
    [fromView insertSubview:_targetImageContainer aboveSubview:aboveView];
    
    CGRect targetImageFrame = [fromView convertRect:toRectInWindowSpace fromView:toView.window];
    
    _fadeViewLeft.frame = CGRectMake(0, 0, imageView.frame.origin.x, screenSize.height);
    _fadeViewRight.frame = CGRectMake(imageView.frame.origin.x + imageView.frame.size.width, 0, screenSize.width - imageView.frame.origin.x - imageView.frame.size.width, screenSize.height);
    _fadeViewTop.frame = CGRectMake(_fadeViewLeft.frame.origin.x + _fadeViewLeft.frame.size.width, 0, _fadeViewRight.frame.origin.x - _fadeViewLeft.frame.origin.x - _fadeViewLeft.frame.size.width, imageView.frame.origin.y);
    _fadeViewBottom.frame = CGRectMake(_fadeViewLeft.frame.origin.x + _fadeViewLeft.frame.size.width, imageView.frame.origin.y + imageView.frame.size.height, _fadeViewRight.frame.origin.x - _fadeViewLeft.frame.origin.x - _fadeViewLeft.frame.size.width, screenSize.height - imageView.frame.origin.y - imageView.frame.size.height);
    
    CGRect contentsFrame = [toView convertRect:toRectInWindowSpace fromView:toView.window];
    
    CGRect fadeViewLeftFrame = CGRectIntegral(CGRectMake(0, 0, contentsFrame.origin.x, screenSize.height));
    CGRect fadeViewRightFrame = CGRectIntegral(CGRectMake(contentsFrame.origin.x + contentsFrame.size.width, 0, screenSize.width - contentsFrame.origin.x - contentsFrame.size.width, screenSize.height));
    fadeViewLeftFrame.size.width += 1;
    fadeViewRightFrame.origin.x -= 1;
    fadeViewRightFrame.size.width += 2;
    CGRect fadeViewTopFrame = CGRectIntegral(CGRectMake(fadeViewLeftFrame.origin.x + fadeViewLeftFrame.size.width, 0, fadeViewRightFrame.origin.x - fadeViewLeftFrame.origin.x - fadeViewLeftFrame.size.width, contentsFrame.origin.y));
    CGRect fadeViewBottomFrame = CGRectIntegral(CGRectMake(fadeViewLeftFrame.origin.x + fadeViewLeftFrame.size.width, contentsFrame.origin.y + contentsFrame.size.height, fadeViewRightFrame.origin.x - fadeViewLeftFrame.origin.x - fadeViewLeftFrame.size.width, screenSize.height - contentsFrame.origin.y - contentsFrame.size.height));
    fadeViewTopFrame.size.height += 1;
    fadeViewBottomFrame.origin.y -= 1;
    fadeViewBottomFrame.size.height += 2;
    
    if (_fadeViewLeft == nil)
        _fadeViewLeft.frame = CGRectMake(0, 0, screenSize.width, screenSize.height);
    
    imageView.alpha = 0.0f;
    
    [UIView animateWithDuration:duration - 0.1 animations:^
    {
        imageView.alpha = 1.0f;
    }];
    
    [UIView animateWithDuration:duration animations:^
    {
        _fadeViewLeft.alpha = 1.0f;
        _fadeViewRight.alpha = 1.0f;
        _fadeViewTop.alpha = 1.0f;
        _fadeViewBottom.alpha = 1.0f;
        
        _fadeViewLeft.frame = fadeViewLeftFrame;
        _fadeViewRight.frame = fadeViewRightFrame;
        _fadeViewTop.frame = fadeViewTopFrame;
        _fadeViewBottom.frame = fadeViewBottomFrame;
        
        imageView.frame = contentsFrame;
        _targetImageContainer.frame = targetImageFrame;
        _targetImageBackgroundView.alpha = 1.0f;
    } completion:^(__unused BOOL finished)
    {
        if (completion)
            completion();
    }];
}

#define SIDE_LEFT 1
#define SIDE_TOP 2

static CGRect fixFromFrame(CGRect fromFrame, int side)
{
    if (side == SIDE_LEFT && fromFrame.origin.x < 0)
        fromFrame.size.width = 0;
    if (side == SIDE_TOP && fromFrame.origin.y < 0)
        fromFrame.size.height = 0;
    
    return fromFrame;
}

static CGRect fixFrame(CGRect fromFrame, CGRect toFrame)
{
    toFrame.size.width += toFrame.origin.x - fromFrame.origin.x;
    toFrame.origin.x += fromFrame.origin.x;
    
    return toFrame;
}

- (void)beginTransitionOut:(UIView *)imageView fromView:(UIView *)fromView transform:(CGAffineTransform)transform toView:(UIView *)toView aboveView:(UIView *)aboveView interfaceOrientation:(UIInterfaceOrientation)interfaceOrientation toRectInWindowSpace:(CGRect)toRectInWindowSpace toImage:(UIImage *)toImage keepAspect:(bool)keepAspect swipeVelocity:(float)swipeVelocity completion:(dispatch_block_t)completion
{
    [self beginTransitionOut:imageView fromView:fromView transform:transform toView:toView aboveView:aboveView interfaceOrientation:interfaceOrientation toRectInWindowSpace:toRectInWindowSpace toImage:toImage keepAspect:keepAspect swipeVelocity:swipeVelocity completion:completion duration:0.3];
}

- (void)beginTransitionOut:(UIView *)imageView fromView:(UIView *)fromView transform:(CGAffineTransform)transform toView:(UIView *)toView aboveView:(UIView *)aboveView interfaceOrientation:(UIInterfaceOrientation)interfaceOrientation toRectInWindowSpace:(CGRect)toRectInWindowSpace toImage:(UIImage *)toImage keepAspect:(bool)keepAspect swipeVelocity:(float)swipeVelocity completion:(dispatch_block_t)completion duration:(NSTimeInterval)duration
{
    [TGViewController disableAutorotationFor:duration + 0.05];
    [TGViewController disableUserInteractionFor:duration + 0.05];
    
    UIImage *image = [imageView isKindOfClass:[TGRemoteImageView class]] ? ((TGRemoteImageView *)imageView).currentImage : ((UIImageView *)imageView).image;
    if (image != nil && image.size.width * image.size.height >= 1280 * 1280 && !CGSizeEqualToSize(toRectInWindowSpace.size, CGSizeZero))
    {
        UIImage *smallImage = TGScaleImageToPixelSize(image, TGFitSize(CGSizeMake(300, 300), CGSizeMake(image.size.width * image.scale, image.size.height * image.scale)));
        if ([imageView isKindOfClass:[TGRemoteImageView class]])
            [(TGRemoteImageView *)imageView loadImage:smallImage];
        else
            ((UIImageView *)imageView).image = image;
    }
    
    CGRect targetFrame = CGRectZero;
    
    CGSize screenSize = [TGViewController screenSizeForInterfaceOrientation:interfaceOrientation];
    
    if (_fadingColor != nil)
    {
        _fadeViewLeft = [[UIView alloc] init];
        _fadeViewLeft.backgroundColor = _fadingColor;
        _fadeViewLeft.alpha = 1.0f;
        [fromView insertSubview:_fadeViewLeft belowSubview:imageView];
        
        _fadeViewRight = [[UIView alloc] init];
        _fadeViewRight.backgroundColor = _fadingColor;
        _fadeViewRight.alpha = 1.0f;
        [fromView insertSubview:_fadeViewRight belowSubview:imageView];
        
        _fadeViewTop = [[UIView alloc] init];
        _fadeViewTop.backgroundColor = _fadingColor;
        _fadeViewTop.alpha = 1.0f;
        [fromView insertSubview:_fadeViewTop belowSubview:imageView];
        
        _fadeViewBottom = [[UIView alloc] init];
        _fadeViewBottom.backgroundColor = _fadingColor;
        _fadeViewBottom.alpha = 1.0f;
        [fromView insertSubview:_fadeViewBottom belowSubview:imageView];
    }
    
    CGRect fadeViewLeftFrame = CGRectMake(0, 0, screenSize.width, screenSize.height);
    CGRect fadeViewRightFrame = CGRectZero;
    CGRect fadeViewTopFrame = CGRectZero;
    CGRect fadeViewBottomFrame = CGRectZero;
    
    if (!CGSizeEqualToSize(toRectInWindowSpace.size, CGSizeZero))
    {
        targetFrame = [fromView convertRect:toRectInWindowSpace fromView:fromView.window];
        
        _targetImageContainer = [[UIView alloc] initWithFrame:[toView convertRect:imageView.frame fromView:fromView]];
        [toView insertSubview:_targetImageContainer aboveSubview:aboveView];
        
        _targetImageBackgroundView = [[UIView alloc] initWithFrame:_targetImageContainer.bounds];
        _targetImageBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _targetImageBackgroundView.backgroundColor = _fadingColor;
        _targetImageBackgroundView.alpha = 1.0f;
        [_targetImageContainer addSubview:_targetImageBackgroundView];
        
        _targetImageView = [[UIImageView alloc] initWithFrame:_targetImageContainer.bounds];
        _targetImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _targetImageView.image = toImage;
        _targetImageView.contentMode = keepAspect ? UIViewContentModeScaleAspectFill : UIViewContentModeScaleToFill;
        _targetImageView.clipsToBounds = true;
        _targetImageView.transform = transform;
        [_targetImageContainer addSubview:_targetImageView];
        
        if (_fadingColor != nil)
        {
            _fadeViewLeft.frame = CGRectMake(0, 0, imageView.frame.origin.x, screenSize.height);
            _fadeViewLeft.frame = fixFromFrame(_fadeViewLeft.frame, SIDE_LEFT);
            
            _fadeViewRight.frame = CGRectMake(imageView.frame.origin.x + imageView.frame.size.width, 0, screenSize.width - imageView.frame.origin.x - imageView.frame.size.width, screenSize.height);
            
            _fadeViewTop.frame = CGRectMake(_fadeViewLeft.frame.origin.x + _fadeViewLeft.frame.size.width, 0, _fadeViewRight.frame.origin.x - _fadeViewLeft.frame.origin.x - _fadeViewLeft.frame.size.width, imageView.frame.origin.y);
            
            _fadeViewBottom.frame = CGRectMake(_fadeViewLeft.frame.origin.x + _fadeViewLeft.frame.size.width, imageView.frame.origin.y + imageView.frame.size.height, _fadeViewRight.frame.origin.x - _fadeViewLeft.frame.origin.x - _fadeViewLeft.frame.size.width, screenSize.height - imageView.frame.origin.y - imageView.frame.size.height);
        }
        
        CGRect contentsFrame = targetFrame;
        
        fadeViewLeftFrame = CGRectMake(0, 0, contentsFrame.origin.x, screenSize.height);
        fadeViewRightFrame = CGRectMake(contentsFrame.origin.x + contentsFrame.size.width, 0, screenSize.width - contentsFrame.origin.x - contentsFrame.size.width, screenSize.height);
        fadeViewLeftFrame.size.width += 0.1f;
        fadeViewRightFrame.origin.x -= 0.1f;
        fadeViewRightFrame.size.width += 0.2f;
        
        fadeViewTopFrame = CGRectMake(fadeViewLeftFrame.origin.x + fadeViewLeftFrame.size.width, 0, fadeViewRightFrame.origin.x - fadeViewLeftFrame.origin.x - fadeViewLeftFrame.size.width, contentsFrame.origin.y);
        
        fadeViewBottomFrame = CGRectMake(fadeViewLeftFrame.origin.x + fadeViewLeftFrame.size.width, contentsFrame.origin.y + contentsFrame.size.height, fadeViewRightFrame.origin.x - fadeViewLeftFrame.origin.x - fadeViewLeftFrame.size.width, screenSize.height - contentsFrame.origin.y - contentsFrame.size.height);
        fadeViewTopFrame.size.height += 0.1f;
        fadeViewBottomFrame.origin.y -= 0.1f;
        fadeViewBottomFrame.size.height += 0.2f;
        
        fadeViewLeftFrame = fixFrame(_fadeViewLeft.frame, fadeViewLeftFrame);
    }
    else if (_fadingColor != nil)
    {
        _fadeViewLeft.frame = CGRectMake(0, 0, screenSize.width, screenSize.height);
        
        _fadeViewRight.frame = CGRectZero;
        _fadeViewTop.frame = CGRectZero;
        _fadeViewBottom.frame = CGRectZero;
    }
    
    CGRect targetImageFrame = [toView convertRect:toRectInWindowSpace fromView:fromView.window];
    
    [UIView animateWithDuration:(CGSizeEqualToSize(targetFrame.size, CGSizeZero) ? duration : (duration - 0.1)) delay:(CGSizeEqualToSize(targetFrame.size, CGSizeZero) ? 0.0 : 0.1) options:0 animations:^
    {
        imageView.alpha = 0.0f;
    } completion:nil];
    
    [UIView animateWithDuration:duration animations:^
    {
        if (_fadingColor != nil)
        {
            _fadeViewLeft.alpha = 0.0f;
            _fadeViewRight.alpha = 0.0f;
            _fadeViewTop.alpha = 0.0f;
            _fadeViewBottom.alpha = 0.0f;
        }
        
        if (!CGSizeEqualToSize(targetFrame.size, CGSizeZero))
        {
            imageView.frame = targetFrame;
            _targetImageContainer.frame = targetImageFrame;
            _targetImageBackgroundView.alpha = 0.0f;
            
            if (_fadingColor != nil)
            {
                _fadeViewLeft.frame = fadeViewLeftFrame;
                _fadeViewRight.frame = fadeViewRightFrame;
                _fadeViewTop.frame = fadeViewTopFrame;
                _fadeViewBottom.frame = fadeViewBottomFrame;
            }
        }
        else
        {
            CGFloat offset = MAX(ABS(swipeVelocity * (CGFloat)duration), screenSize.height);
            imageView.frame = CGRectOffset(imageView.frame, 0, swipeVelocity < 0.0f ? -offset : offset);
        }
    } completion:^(__unused BOOL finished)
    {
        if (completion)
            completion();
    }];
}

@end
