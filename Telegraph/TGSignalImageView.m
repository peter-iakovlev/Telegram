#import "TGSignalImageView.h"

#import "TGModernGalleryTransitionView.h"

#import "TGInlineVideoView.h"
#import "TGModernGalleryVideoView.h"

@interface TGSignalImageView () <TGModernGalleryTransitionView>
{
    TGInlineVideoView *_inlineVideoView;
    
    UIView *_videoViewWrapper;
    TGModernGalleryVideoView *_videoView;
}

@property (nonatomic, strong) NSString *viewIdentifier;
@property (nonatomic, strong) NSString *viewStateIdentifier;

@end

@implementation TGSignalImageView

- (void)willBecomeRecycled
{
    [self reset];
    
    [_inlineVideoView setVideoPathSignal:nil];
    
    [_inlineVideoView removeFromSuperview];
    _inlineVideoView = nil;
}

- (UIImage *)transitionImage
{
    return self.image;
}

- (CGRect)transitionContentRect
{
    return _transitionContentRect;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    CGRect bounds = self.bounds;
    bounds.origin.x += _inlineVideoInsets.left;
    bounds.origin.y += _inlineVideoInsets.top;
    bounds.size.width -= _inlineVideoInsets.left + _inlineVideoInsets.right;
    bounds.size.height -= _inlineVideoInsets.top + _inlineVideoInsets.bottom;
    _inlineVideoView.frame = bounds;
}

- (CGRect)_videoFrame
{
    CGRect frame = self.bounds;
    frame.origin.x += _inlineVideoInsets.left;
    frame.origin.y += _inlineVideoInsets.top;
    frame.size.width -= _inlineVideoInsets.left + _inlineVideoInsets.right;
    frame.size.height -= _inlineVideoInsets.top + _inlineVideoInsets.bottom;
    return frame;
}

- (void)setVideoPathSignal:(SSignal *)videoPathSignal {
    if (_inlineVideoView == nil) {
        _inlineVideoView = [[TGInlineVideoView alloc] initWithFrame:[self _videoFrame]];
        _inlineVideoView.cornerRadius = _inlineVideoCornerRadius;
        _inlineVideoView.insets = UIEdgeInsetsZero;
        [self insertSubview:_inlineVideoView atIndex:0];
    }
    [_inlineVideoView setVideoPathSignal:videoPathSignal];
}

- (void)showVideo
{
    _inlineVideoView.hidden = false;
}

- (void)hideVideo
{
    [_inlineVideoView removeFromSuperview];
    _inlineVideoView = nil;
}

- (void)setInlineVideoInsets:(UIEdgeInsets)inlineVideoInsets {
    _inlineVideoInsets = inlineVideoInsets;
    
    CGRect bounds = self.bounds;
    bounds.origin.x += _inlineVideoInsets.left;
    bounds.origin.y += _inlineVideoInsets.top;
    bounds.size.width -= _inlineVideoInsets.left + _inlineVideoInsets.right;
    bounds.size.height -= _inlineVideoInsets.top + _inlineVideoInsets.bottom;
    _inlineVideoView.frame = bounds;
}

- (void)setInlineVideoCornerRadius:(CGFloat)inlineVideoCornerRadius
{
    _inlineVideoCornerRadius = inlineVideoCornerRadius;
    
    _inlineVideoView.cornerRadius = inlineVideoCornerRadius;
}

- (void)setVideoView:(TGModernGalleryVideoView *)videoView
{
    if (videoView != nil && _videoView == videoView && _videoViewWrapper != nil && videoView.superview == _videoViewWrapper)
        return;
    
    if (_videoView != nil && _videoView.superview == _videoViewWrapper)
    {
        [_videoView removeFromSuperview];
        _videoView = nil;
    }
    
    _videoView = videoView;
    
    if (videoView == nil)
    {
        [_videoViewWrapper removeFromSuperview];
        _videoViewWrapper = nil;
        return;
    }
    
    if (_videoViewWrapper == nil)
    {
        _videoViewWrapper = [[UIView alloc] initWithFrame:[self _videoFrame]];
        _videoViewWrapper.clipsToBounds = true;
        _videoViewWrapper.layer.cornerRadius = _inlineVideoCornerRadius;
        if (_inlineVideoView)
            [self insertSubview:_videoViewWrapper aboveSubview:_inlineVideoView];
        else
            [self insertSubview:_videoViewWrapper atIndex:0];
    }
    
    _videoView.frame = CGRectInset(_videoViewWrapper.bounds, -2.0f, -2.0f);
    [_videoViewWrapper addSubview:_videoView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _inlineVideoView.frame = self.bounds;
}

@end
