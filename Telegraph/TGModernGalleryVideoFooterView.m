#import "TGModernGalleryVideoFooterView.h"

#import <LegacyComponents/TGModernButton.h>

#import "TGPresentation.h"

@interface TGModernGalleryVideoFooterView ()
{
    TGModernButton *_playPauseButton;
    TGModernButton *_backwardButton;
    TGModernButton *_forwardButton;
}

@end

@implementation TGModernGalleryVideoFooterView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        _playPauseButton = [[TGModernButton alloc] init];
        _playPauseButton.exclusiveTouch = true;
        [_playPauseButton setImage:TGPresentation.current.images.videoPlayerPlayIcon forState:UIControlStateNormal];
        _playPauseButton.modernHighlight = true;
        [_playPauseButton addTarget:self action:@selector(playPauseButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_playPauseButton];
        
        _backwardButton = [[TGModernButton alloc] init];
        _backwardButton.exclusiveTouch = true;
        [_backwardButton setImage:TGPresentation.current.images.videoPlayerBackwardIcon forState:UIControlStateNormal];
        _backwardButton.modernHighlight = true;
        [_backwardButton addTarget:self action:@selector(backwardButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_backwardButton];
        
        _forwardButton = [[TGModernButton alloc] init];
        _forwardButton.exclusiveTouch = true;
        [_forwardButton setImage:TGPresentation.current.images.videoPlayerForwardIcon forState:UIControlStateNormal];
        _forwardButton.modernHighlight = true;
        [_forwardButton addTarget:self action:@selector(forwardButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_forwardButton];
    }
    return self;
}

- (void)setDuration:(NSTimeInterval)duration
{
    _duration = duration;
    
    bool controlsHidden = duration < 45.0;
    _backwardButton.hidden = controlsHidden;
    _forwardButton.hidden = controlsHidden;
}

- (void)setIsPlaying:(bool)isPlaying
{
    _isPlaying = isPlaying;
    
    UIImage *image = isPlaying ? TGPresentation.current.images.videoPlayerPauseIcon : TGPresentation.current.images.videoPlayerPlayIcon;
    [_playPauseButton setImage:image forState:UIControlStateNormal];
}

- (void)playPauseButtonPressed
{
    if (_isPlaying)
    {
        if (_pausePressed)
            _pausePressed();
    }
    else
    {
        if (_playPressed)
            _playPressed();
    }
}

- (void)backwardButtonPressed
{
    if (_backwardPressed != nil)
        _backwardPressed();
}

- (void)forwardButtonPressed
{
    if (_forwardPressed != nil)
        _forwardPressed();
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *view = [super hitTest:point withEvent:event];
    if (view == _playPauseButton || view == _backwardButton || view == _forwardButton)
        return view;
    
    return nil;
}

- (void)layoutSubviews
{
    CGSize buttonSize = {60.0f, 44.0f};
    
    _playPauseButton.frame = (CGRect){{CGFloor((self.frame.size.width - buttonSize.width) / 2.0f), CGFloor((self.frame.size.height - buttonSize.height) / 2.0f)}, buttonSize};
    
    _backwardButton.frame = (CGRect){{CGRectGetMinX(_playPauseButton.frame) - buttonSize.width - 3.0f, CGFloor((self.frame.size.height - buttonSize.height) / 2.0f)}, buttonSize};
    _forwardButton.frame = (CGRect){{CGRectGetMaxX(_playPauseButton.frame) + 3.0f, CGFloor((self.frame.size.height - buttonSize.height) / 2.0f)}, buttonSize};
}

@end
