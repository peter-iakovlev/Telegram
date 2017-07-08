#import "TGModernConversationAudioPreviewInputPanel.h"

#import "TGImageUtils.h"
#import "TGModernButton.h"
#import "TGFont.h"

#import "TGAudioWaveformSignal.h"
#import "TGAudioWaveformView.h"

#import "TGDataItem.h"

#import "TGModernConversationAudioPlayer.h"

#import "TGTimerTarget.h"

#import "TGModernConversationAssociatedInputPanel.h"

@interface TGModernConversationAudioPreviewInputPanel () <TGModernConversationAudioPlayerDelegate> {
    TGDataItem *_dataItem;
    NSTimeInterval _duration;
    TGLiveUploadActorData *_liveUploadActorData;
    TGAudioWaveform *_waveform;
    void (^_cancel)();
    void (^_send)(TGDataItem *, NSTimeInterval, TGLiveUploadActorData *, TGAudioWaveform *);
    
    TGModernButton *_deleteButton;
    TGModernButton *_sendButton;
    UIButton *_waveformButton;
    
    UIImageView *_waveformBackgroundView;
    UILabel *_durationLabel;
    TGAudioWaveformView *_waveformView;
    UIView *_clippingView;
    UIImageView *_playPauseIcon;
    
    CGFloat _audioPosition;
    
    CALayer *_stripeLayer;
    CGFloat _sendButtonWidth;
    
    id<SDisposable> _waveformDisposable;
    
    TGModernConversationAudioPlayer *_player;
    
    bool _playing;
    NSTimer *_timer;
    int _durationLabelSeconds;
    bool _playPauseIconState;
    
    TGModernConversationAssociatedInputPanel *_firstExtendedPanel;
    TGModernConversationAssociatedInputPanel *_secondExtendedPanel;
    TGModernConversationAssociatedInputPanel *_currentExtendedPanel;
}

@end

@implementation TGModernConversationAudioPreviewInputPanel

- (CGFloat)baseHeight
{
    static CGFloat value = 0.0f;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^ {
        value = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? 45.0f : 56.0f;
    });
    
    return value;
}

- (UIFont *)sendButtonFont
{
    return TGMediumSystemFontOfSize(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? 14.5 : 15.5);
}

- (CGPoint)sendButtonOffset
{
    static CGPoint offset;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
            offset = CGPointZero;
        else
            offset = CGPointMake(-11.0f, -6.0f);
    });
    
    return offset;
}

- (UIImage *)playImage {
    static UIImage *image = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        image = [UIImage imageNamed:@"TempAudioPreviewPlay.png"];
    });
    return image;
}

- (UIImage *)pauseImage {
    static UIImage *image = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        image = [UIImage imageNamed:@"TempAudioPreviewPause.png"];
    });
    return image;
}

- (instancetype)initWithDataItem:(TGDataItem *)dataItem duration:(NSTimeInterval)duration liveUploadActorData:(TGLiveUploadActorData *)liveUploadActorData waveform:(TGAudioWaveform *)waveform cancel:(void (^)())cancel send:(void (^)(TGDataItem *, NSTimeInterval, TGLiveUploadActorData *, TGAudioWaveform *))send
{
    self = [super initWithFrame:CGRectMake(0.0f, 0.0f, 0.0f, [self baseHeight])];
    if (self)
    {
        _dataItem = dataItem;
        _duration = duration;
        _liveUploadActorData = liveUploadActorData;
        _cancel = [cancel copy];
        _send = [send copy];
        _waveform = waveform;
        
        self.backgroundColor = UIColorRGB(0xf7f7f7);
        
        _stripeLayer = [[CALayer alloc] init];
        _stripeLayer.backgroundColor = UIColorRGB(0xb2b2b2).CGColor;
        [self.layer addSublayer:_stripeLayer];
        
        UIImage *deleteImage = [UIImage imageNamed:@"ModernConversationActionDelete.png"];
        
        _deleteButton = [[TGModernButton alloc] init];
        [_deleteButton setImage:deleteImage forState:UIControlStateNormal];
        _deleteButton.adjustsImageWhenDisabled = false;
        _deleteButton.adjustsImageWhenHighlighted = false;
        [_deleteButton addTarget:self action:@selector(deleteButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_deleteButton];
        
        TGModernButton *sendButton = [[TGModernButton alloc] initWithFrame:CGRectZero];
        sendButton.modernHighlight = true;
        _sendButton = sendButton;
        _sendButton.exclusiveTouch = true;
        [_sendButton setImage:[UIImage imageNamed:@"ModernConversationSend"] forState:UIControlStateNormal];
        _sendButton.adjustsImageWhenHighlighted = false;
        [_sendButton addTarget:self action:@selector(sendButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_sendButton];
        
        _sendButtonWidth = 45.0f;
        
        _waveformBackgroundView = [[UIImageView alloc] init];
        {
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(33.0f, 33.0f), false, 0.0f);
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextSetFillColorWithColor(context, TGAccentColor().CGColor);
            CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, 33.0f, 33.0f));
            _waveformBackgroundView.image = [UIGraphicsGetImageFromCurrentImageContext() stretchableImageWithLeftCapWidth:16 topCapHeight:16];
            UIGraphicsEndImageContext();
        }
        [self addSubview:_waveformBackgroundView];
        
        _durationLabel = [[UILabel alloc] init];
        _durationLabel.backgroundColor = TGAccentColor();
        _durationLabel.textColor = [UIColor whiteColor];
        _durationLabel.font = TGSystemFontOfSize(11.5f);
        _durationLabel.text = @"0:42";
        _durationLabel.textAlignment = NSTextAlignmentRight;
        int intDuration = (int)duration;
        _durationLabelSeconds = intDuration;
        _durationLabel.text = [[NSString alloc] initWithFormat:@"%d:%02d", (int)intDuration / 60, (int)intDuration % 60];
        [_durationLabel sizeToFit];
        _durationLabel.frame = CGRectMake(0.0f, 0.0f, _durationLabel.frame.size.width + 20.0f, _durationLabel.frame.size.height);
        [self addSubview:_durationLabel];
        
        _waveformView = [[TGAudioWaveformView alloc] init];
        [_waveformView setForegroundColor:[UIColor whiteColor] backgroundColor:UIColorRGB(0x9cd6ff)];
        _waveformView.peakHeight = 14.0f;
        [self addSubview:_waveformView];
        
        _playPauseIcon = [[UIImageView alloc] init];
        _playPauseIcon.image = [self playImage];
        [self addSubview:_playPauseIcon];
        
        if (waveform != nil) {
            [_waveformView setWaveform:waveform];
        } else {
            __weak TGModernConversationAudioPreviewInputPanel *weakSelf = self;
            _waveformDisposable = [[[TGAudioWaveformSignal audioWaveformForFileAtPath:[dataItem path] duration:duration] deliverOn:[SQueue mainQueue]] startWithNext:^(TGAudioWaveform *next) {
                __strong TGModernConversationAudioPreviewInputPanel *strongSelf = weakSelf;
                if (strongSelf != nil) {
                    [strongSelf->_waveformView setWaveform:next];
                }
            }];
        }
        
        _waveformButton = [[UIButton alloc] init];
        [_waveformButton addTarget:self action:@selector(buttonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_waveformButton];
        
        _audioPosition = 1.0f;
    }
    return self;
}

- (void)dealloc {
    [_waveformDisposable dispose];
    [_timer invalidate];
    [_player stop];
}

- (void)adjustForSize:(CGSize)size keyboardHeight:(CGFloat)keyboardHeight duration:(NSTimeInterval)duration animationCurve:(int)animationCurve contentAreaHeight:(CGFloat)contentAreaHeight
{
    [self _adjustForSize:size keyboardHeight:keyboardHeight duration:duration animationCurve:animationCurve contentAreaHeight:contentAreaHeight];
}

- (void)_adjustForSize:(CGSize)size keyboardHeight:(CGFloat)keyboardHeight duration:(NSTimeInterval)duration animationCurve:(int)animationCurve contentAreaHeight:(CGFloat)__unused contentAreaHeight
{
    dispatch_block_t block = ^
    {
        CGSize messageAreaSize = size;
        
        self.frame = CGRectMake(0, messageAreaSize.height - keyboardHeight - [self baseHeight] - [self extendedPanelHeight], messageAreaSize.width, [self baseHeight] + [self extendedPanelHeight]);
        [self layoutSubviews];
    };
    
    if (duration > DBL_EPSILON)
        [UIView animateWithDuration:duration delay:0 options:animationCurve << 16 animations:block completion:nil];
    else
        block();
}

- (void)changeToSize:(CGSize)size keyboardHeight:(CGFloat)keyboardHeight duration:(NSTimeInterval)duration contentAreaHeight:(CGFloat)contentAreaHeight
{
    [self _adjustForSize:size keyboardHeight:keyboardHeight duration:duration animationCurve:0 contentAreaHeight:contentAreaHeight];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect frame = self.frame;
    
    _stripeLayer.frame = CGRectMake(0.0f, -TGRetinaPixel, self.frame.size.width, TGRetinaPixel);
    
    bool displayPanels = [self shouldDisplayPanels];
    
    CGFloat verticalOffset = 0.0f;
    if (_currentExtendedPanel != nil)
    {
        _currentExtendedPanel.frame = CGRectMake(0.0f, 0.0f, frame.size.width, displayPanels ? [_currentExtendedPanel preferredHeight] : 0.0f);
        verticalOffset = _currentExtendedPanel.frame.size.height;
    }
    
    CGPoint sendButtonOffset = [self sendButtonOffset];
    _sendButton.frame = CGRectMake(self.frame.size.width - _sendButtonWidth + sendButtonOffset.x * 2.0f, self.frame.size.height - [self baseHeight], _sendButtonWidth - sendButtonOffset.x * 2.0f, [self baseHeight] - 1.0f);
    
    _deleteButton.transform = CGAffineTransformIdentity;
    _deleteButton.frame = CGRectMake(-3.0f, 0.0f + verticalOffset, 52.0f, [self baseHeight]);
    _deleteButton.transform = CGAffineTransformMakeScale(0.88f, 0.88f);
    
    _playPauseIcon.frame = CGRectMake(52.5f, 12.5f + verticalOffset, 19.0f, 19.0f);
    
    _waveformBackgroundView.frame = CGRectMake(45.0f, 6.0f - TGScreenPixel + verticalOffset, self.frame.size.width - 45.0f - _sendButtonWidth - 2.0f, [self baseHeight] - (7.0f - TGScreenPixel) - 5.0f);
    
    _waveformButton.frame = CGRectMake(45.0f, 0.0f + verticalOffset, self.frame.size.width - 45.0f - _sendButtonWidth - 2.0f, [self baseHeight]);
    
    _waveformView.frame = CGRectMake(45.0f + 35.0f, 9.0f + verticalOffset, self.frame.size.width - 45.0f - 35.0f - _sendButtonWidth - 2.0f - 0.0f - _durationLabel.frame.size.width, [self baseHeight] - 9.0f - 8.0f - 7.5f);
    CGRect waveformBounds = _waveformView.bounds;
    _waveformView.backgroundView.frame = waveformBounds;
    _waveformView.foregroundView.frame = waveformBounds;
    waveformBounds.size.width *= _audioPosition;
    _waveformView.foregroundClippingView.frame = waveformBounds;
    
    _durationLabel.frame = CGRectMake(CGRectGetMaxX(_waveformBackgroundView.frame) - 10.0f - _durationLabel.frame.size.width, 15.0f + verticalOffset, _durationLabel.frame.size.width, _durationLabel.frame.size.height);
}

#pragma mark -

- (void)deleteButtonPressed {
    if (_cancel) {
        _cancel();
    }
}

- (void)sendButtonPressed {
    if (_send) {
        _send(_dataItem, _duration, _liveUploadActorData, _waveform);
    }
}

- (void)buttonPressed {
    if (_player == nil) {
        if (_playbackDidBegin) {
            _playbackDidBegin();
        }
        _player = [[TGModernConversationAudioPlayer alloc] initWithFilePath:[_dataItem path] music:false controlAudioSession:true];
        _playing = true;
        _timer = [TGTimerTarget scheduledMainThreadTimerWithTarget:self action:@selector(updateAudioPosition) interval:2.0f / 60.0f repeat:true runLoopModes:NSRunLoopCommonModes];
        _player.delegate = self;
        [_player play];
        [self updateAudioPosition];
        
        if (!_playPauseIconState) {
            _playPauseIconState = true;
            _playPauseIcon.image = [self pauseImage];
        }
    } else if (_playing) {
        _playing = false;
        [_player pause];
        [self updateAudioPosition];
        [_timer invalidate];
        
        if (_playPauseIconState) {
            _playPauseIconState = false;
            _playPauseIcon.image = [self playImage];
        }
    } else {
        if (_playbackDidBegin) {
            _playbackDidBegin();
        }
        _playing = true;
        _timer = [TGTimerTarget scheduledMainThreadTimerWithTarget:self action:@selector(updateAudioPosition) interval:2.0f / 60.0f repeat:true runLoopModes:NSRunLoopCommonModes];
        [self updateAudioPosition];
        [_player play:(float)_audioPosition];
        
        if (!_playPauseIconState) {
            _playPauseIconState = true;
            _playPauseIcon.image = [self pauseImage];
        }
    }
}

- (void)audioPlayerDidFinish {
    _player = nil;
    [_timer invalidate];
    _timer = nil;
    _audioPosition = 1.0f;
    
    int playbackSeconds = (int)(_audioPosition * _duration);
    if (playbackSeconds != _durationLabelSeconds) {
        _durationLabelSeconds = playbackSeconds;
        _durationLabel.text = [[NSString alloc] initWithFormat:@"%d:%02d", (int)playbackSeconds / 60, (int)playbackSeconds % 60];
    }
    
    CGRect waveformBounds = _waveformView.bounds;
    waveformBounds.size.width *= _audioPosition;
    _waveformView.foregroundClippingView.frame = waveformBounds;
    
    _playPauseIconState = false;
    _playPauseIcon.image = [self playImage];
}

- (void)updateAudioPosition {
    if (_player == nil) {
        _audioPosition = 1.0f;
    } else {
        _audioPosition = [_player playbackPosition];
        int playbackSeconds = (int)(_audioPosition * _duration);
        if (playbackSeconds != _durationLabelSeconds) {
            _durationLabelSeconds = playbackSeconds;
            _durationLabel.text = [[NSString alloc] initWithFormat:@"%d:%02d", (int)playbackSeconds / 60, (int)playbackSeconds % 60];
        }
        
        CGRect waveformBounds = _waveformView.bounds;
        waveformBounds.size.width *= _audioPosition;
        _waveformView.foregroundClippingView.frame = waveformBounds;
    }
}

- (void)stop {
    [_player stop];
    _player = nil;
    
    [_timer invalidate];
    _timer = nil;
    _audioPosition = 1.0f;
    
    int playbackSeconds = (int)(_audioPosition * _duration);
    if (playbackSeconds != _durationLabelSeconds) {
        _durationLabelSeconds = playbackSeconds;
        _durationLabel.text = [[NSString alloc] initWithFormat:@"%d:%02d", (int)playbackSeconds / 60, (int)playbackSeconds % 60];
    }
    
    CGRect waveformBounds = _waveformView.bounds;
    waveformBounds.size.width *= _audioPosition;
    _waveformView.foregroundClippingView.frame = waveformBounds;
    
    _playPauseIconState = false;
    _playPauseIcon.image = [self playImage];
}

- (bool)shouldDisplayPanels
{
    return true;
}

- (CGFloat)extendedPanelHeight
{
    return [self shouldDisplayPanels] ? [_currentExtendedPanel preferredHeight] : 0.0f;
}

- (void)setPrimaryExtendedPanel:(TGModernConversationAssociatedInputPanel *)extendedPanel animated:(bool)animated
{
    [self setPrimaryExtendedPanel:extendedPanel animated:animated skipHeightAnimation:false];
}

- (void)setPrimaryExtendedPanel:(TGModernConversationAssociatedInputPanel *)extendedPanel animated:(bool)animated skipHeightAnimation:(bool)skipHeightAnimation
{
    _firstExtendedPanel = extendedPanel;
    if (_secondExtendedPanel == nil)
    {
        [self _setCurrentExtendedPanel:extendedPanel animated:animated skipHeightAnimation:skipHeightAnimation];
    }
}

- (void)setSecondaryExtendedPanel:(TGModernConversationAssociatedInputPanel *)extendedPanel animated:(bool)animated
{
    [self setSecondaryExtendedPanel:extendedPanel animated:animated skipHeightAnimation:false];
}

- (void)setSecondaryExtendedPanel:(TGModernConversationAssociatedInputPanel *)extendedPanel animated:(bool)animated skipHeightAnimation:(bool)skipHeightAnimation
{
    _secondExtendedPanel = extendedPanel;
    if (_secondExtendedPanel == nil)
    {
        if (_firstExtendedPanel != nil)
        {
            [self _setCurrentExtendedPanel:_firstExtendedPanel animated:animated skipHeightAnimation:skipHeightAnimation];
        }
        else
        {
            [self _setCurrentExtendedPanel:nil animated:animated skipHeightAnimation:skipHeightAnimation];
        }
    }
    else
        [self _setCurrentExtendedPanel:extendedPanel animated:animated skipHeightAnimation:skipHeightAnimation];
}

- (UIEdgeInsets)inputFieldInsets
{
    static UIEdgeInsets insets;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
                  {
                      if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
                          insets = UIEdgeInsetsMake(9.0f, 41.0f, 8.0f, 0.0f);
                      else
                          insets = UIEdgeInsetsMake(TGIsRetina() ? 12.0f : 12.0f, 58.0f, 12.0f, 21.0f);
                  });
    
    return insets;
}

- (void)_setCurrentExtendedPanel:(TGModernConversationAssociatedInputPanel *)currentExtendedPanel animated:(bool)animated skipHeightAnimation:(bool)skipHeightAnimation
{
    if (_currentExtendedPanel != currentExtendedPanel)
    {
        bool displayPanels = [self shouldDisplayPanels];
        
        if (animated)
        {
            UIView *previousExtendedPanel = _currentExtendedPanel;
            _currentExtendedPanel = currentExtendedPanel;
            
            if (_currentExtendedPanel != nil)
            {
                [_currentExtendedPanel setSendAreaWidth:_sendButtonWidth attachmentAreaWidth:[self inputFieldInsets].left];
                _currentExtendedPanel.frame = CGRectMake(0.0f, 0.0f, self.frame.size.width, displayPanels ? [_currentExtendedPanel preferredHeight] : 0.0f);
                
                if (previousExtendedPanel != nil)
                    [self insertSubview:_currentExtendedPanel aboveSubview:previousExtendedPanel];
                else
                    [self insertSubview:_currentExtendedPanel atIndex:0];
            }
            
            _currentExtendedPanel.alpha = 0.0f;
            [UIView animateWithDuration:0.2 delay:0 options:0 animations:^
             {
                 previousExtendedPanel.alpha = 0.0f;
                 _currentExtendedPanel.alpha = 1.0f;
             } completion:^(__unused BOOL finished)
             {
                 [previousExtendedPanel removeFromSuperview];
             }];
            
            if (!skipHeightAnimation)
            {
                CGFloat inputContainerHeight = [self baseHeight];
                
                id<TGModernConversationInputPanelDelegate> delegate = (id<TGModernConversationInputPanelDelegate>)self.delegate;
                if ([delegate respondsToSelector:@selector(inputPanelWillChangeHeight:height:duration:animationCurve:)])
                {
                    [delegate inputPanelWillChangeHeight:self height:inputContainerHeight duration:0.2 animationCurve:0];
                }
            }
        }
        else
        {
            UIView *previousPrimaryExtendedPanel = _currentExtendedPanel;
            _currentExtendedPanel = currentExtendedPanel;
            
            if (_currentExtendedPanel != nil)
            {
                [_currentExtendedPanel setSendAreaWidth:_sendButtonWidth attachmentAreaWidth:[self inputFieldInsets].left];
                _currentExtendedPanel.frame = CGRectMake(0.0f, 0.0f, self.frame.size.width, displayPanels ? [_currentExtendedPanel preferredHeight] : 0.0f);
                if (previousPrimaryExtendedPanel != nil)
                    [self insertSubview:_currentExtendedPanel aboveSubview:previousPrimaryExtendedPanel];
                else
                    [self insertSubview:_currentExtendedPanel atIndex:0];
            }
            
            [previousPrimaryExtendedPanel removeFromSuperview];
            
            if (!skipHeightAnimation)
            {
                CGFloat inputContainerHeight = [self baseHeight];
                
                id<TGModernConversationInputPanelDelegate> delegate = (id<TGModernConversationInputPanelDelegate>)self.delegate;
                if ([delegate respondsToSelector:@selector(inputPanelWillChangeHeight:height:duration:animationCurve:)])
                {
                    [delegate inputPanelWillChangeHeight:self height:inputContainerHeight duration:0.0 animationCurve:0];
                }
            }
        }
    }
}

- (TGModernConversationAssociatedInputPanel *)primaryExtendedPanel
{
    return _firstExtendedPanel;
}

- (TGModernConversationAssociatedInputPanel *)secondaryExtendedPanel
{
    return _secondExtendedPanel;
}

@end
