/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGModernGalleryVideoItemView.h"

#import <AVFoundation/AVFoundation.h>

#import "TGImageUtils.h"
#import "TGRemoteImageView.h"

#import "TGModernGalleryVideoItem.h"
#import "TGVideoMediaAttachment.h"

#import "TGVideoDownloadActor.h"

#import "TGModernGalleryVideoScrubbingInterfaceView.h"
#import "TGModernGalleryRotationGestureRecognizer.h"
#import "TGModernGalleryVideoFooterView.h"

#import "TGDoubleTapGestureRecognizer.h"

#import "TGTimerTarget.h"
#import "TGObserverProxy.h"

#import <pop/POP.h>

@interface TGModernGalleryVideoItemView () <TGDoubleTapGestureRecognizerDelegate>
{
    UIView *_containerView;
    UIView *_contentView;
    UIView *_playerView;
    AVPlayerLayer *_playerLayer;
    CGFloat _playerLayerRotation;
    NSUInteger _currentLoopCount;
    
    UIButton *_playButton;
    
    TGModernGalleryVideoScrubbingInterfaceView *_scrubbingInterfaceView;
    TGModernGalleryVideoFooterView *_footerView;
    
    NSTimer *_positionTimer;
    NSTimer *_videoFlickerTimer;
    
    TGObserverProxy *_didPlayToEndObserver;
    
    NSTimeInterval _duration;
}

@property (nonatomic) bool isPlaying;

@end

@implementation TGModernGalleryVideoItemView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        _containerView = [[UIView alloc] initWithFrame:(CGRect){CGPointZero, frame.size}];
        [self addSubview:_containerView];
        
        TGDoubleTapGestureRecognizer *recognizer = [[TGDoubleTapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapGesture:)];
        recognizer.consumeSingleTap = true;
        [_contentView addGestureRecognizer:recognizer];
        
        _contentView = [[UIView alloc] init];
        [_containerView addSubview:_contentView];
        
        _imageView = [[TGRemoteImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleToFill;
        _imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [_contentView addSubview:_imageView];
        
        _playerView = [[UIView alloc] init];
        [_contentView addSubview:_playerView];
        
        _playButton = [[UIButton alloc] init];
        [_playButton setImage:[UIImage imageNamed:@"PlayButtonBig.png"] forState:UIControlStateNormal];
        [_playButton sizeToFit];
        
        _playButton.frame = (CGRect){{CGFloor((frame.size.width - _playButton.frame.size.width) / 2.0f), CGFloor((frame.size.width - _playButton.frame.size.height) / 2.0f)}, _playButton.frame.size};
        _playButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        [_playButton addTarget:self action:@selector(playPressed) forControlEvents:UIControlEventTouchUpInside];
        [_contentView addSubview:_playButton];
        
        _scrubbingInterfaceView = [[TGModernGalleryVideoScrubbingInterfaceView alloc] init];
        
        _footerView = [[TGModernGalleryVideoFooterView alloc] init];
        __weak TGModernGalleryVideoItemView *weakSelf = self;
        _footerView.playPressed = ^
        {
            __strong TGModernGalleryVideoItemView *strongSelf = weakSelf;
            [strongSelf playPressed];
        };
        _footerView.pausePressed = ^
        {
            __strong TGModernGalleryVideoItemView *strongSelf = weakSelf;
            [strongSelf pausePressed];
        };
        
        TGModernGalleryRotationGestureRecognizer *rotationRecognizer = [[TGModernGalleryRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotationGesture:)];
        [_contentView addGestureRecognizer:rotationRecognizer];
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    CGAffineTransform transform = _containerView.transform;
    _containerView.transform = CGAffineTransformIdentity;
    _containerView.frame = (CGRect){CGPointZero, frame.size};
    _containerView.transform = transform;
}

- (void)prepareForRecycle
{
    [super prepareForRecycle];
    
    [self cleanupCurrentPlayer];
    
    _currentLoopCount = 0;
    
    [_imageView cancelLoading];
    _imageView.hidden = false;
    
    [_videoFlickerTimer invalidate];
    _videoFlickerTimer = nil;
    
    _playerLayer.opacity = 1.0f;
    
    [_positionTimer invalidate];
    _positionTimer = nil;
    
    _playerLayerRotation = 0.0f;
    _containerView.transform = CGAffineTransformMakeRotation(0.0f);
    
    self.isPlaying = false;
    
    [self defaultFooterView].hidden = false;
    [self footerView].hidden = true;
}

- (void)cleanupCurrentPlayer
{
    if (_player != nil)
    {
        _didPlayToEndObserver = nil;
        
        [_player pause];
        _player = nil;
    }
    
    if (_playerLayer != nil)
    {
        [_playerLayer removeFromSuperlayer];
        _playerLayer = nil;
    }
    
    _videoDimenstions = CGSizeZero;
    
    [_imageView loadImage:nil];
}

- (void)addPlayerObserver
{
    if (_player != nil)
    {
    }
}

- (void)removePlayerObserver
{
    if (_player != nil)
    {
    }
}

- (void)setItem:(TGModernGalleryVideoItem *)item synchronously:(bool)synchronously
{
    [super setItem:item synchronously:synchronously];
    
    [self cleanupCurrentPlayer];
    
    [self defaultFooterView].hidden = false;
    [self footerView].hidden = true;
    
    [_scrubbingInterfaceView setDuration:item.videoMedia.duration currentTime:0.0 isPlaying:false animated:false];
    
    NSString *videoPath = [TGVideoDownloadActor localPathForVideoUrl:[item.videoMedia.videoInfo urlWithQuality:0 actualQuality:NULL actualSize:NULL]];
    
    if (videoPath != nil && item.videoMedia.dimensions.width > FLT_EPSILON && item.videoMedia.dimensions.height > FLT_EPSILON)
    {
        _videoDimenstions = item.videoMedia.dimensions;
        _duration = item.videoMedia.duration;
        
        NSString *previewUri = nil;
        if (item.videoMedia.videoId != 0)
            previewUri = [[NSString alloc] initWithFormat:@"video-thumbnail-remote%llx.jpg", item.videoMedia.videoId];
        else if (item.videoMedia.localVideoId != 0)
            previewUri = [[NSString alloc] initWithFormat:@"video-thumbnail-local%llx.jpg", item.videoMedia.localVideoId];
        
        UIImage *loadedImage = nil;
        if (synchronously)
            loadedImage = [[TGRemoteImageView sharedCache] cachedImage:previewUri availability:TGCacheDisk];
        
        if (loadedImage != nil)
            [_imageView loadImage:loadedImage];
        else
            [_imageView loadImage:previewUri filter:nil placeholder:nil];
        
        [self layoutSubviews];
    }
}

- (void)playPressed
{
    if (_player == nil)
    {
        TGModernGalleryVideoItem *item = (TGModernGalleryVideoItem *)self.item;
        
        NSString *videoPath = [TGVideoDownloadActor localPathForVideoUrl:[item.videoMedia.videoInfo urlWithQuality:0 actualQuality:NULL actualSize:NULL]];
        
        if (videoPath != nil && item.videoMedia.dimensions.width > FLT_EPSILON && item.videoMedia.dimensions.height > FLT_EPSILON)
        {
            _videoDimenstions = item.videoMedia.dimensions;
            
            NSString *previewUri = nil;
            if (item.videoMedia.videoId != 0)
                previewUri = [[NSString alloc] initWithFormat:@"video-thumbnail-remote%llx.jpg", item.videoMedia.videoId];
            else if (item.videoMedia.localVideoId != 0)
                previewUri = [[NSString alloc] initWithFormat:@"video-thumbnail-local%llx.jpg", item.videoMedia.localVideoId];
            
            [_imageView loadImage:previewUri filter:nil placeholder:nil];
            
            _player = [[AVPlayer alloc] initWithURL:[NSURL fileURLWithPath:videoPath]];
            _player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
            
            _didPlayToEndObserver = [[TGObserverProxy alloc] initWithTarget:self targetSelector:@selector(playerItemDidPlayToEndTime:) name:AVPlayerItemDidPlayToEndTimeNotification object:[_player currentItem]];
            
            _playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
            _playerLayer.videoGravity = AVLayerVideoGravityResize;
            [_playerView.layer addSublayer:_playerLayer];
            
            _playerLayer.opacity = 0.0f;
            _videoFlickerTimer = [TGTimerTarget scheduledMainThreadTimerWithTarget:self action:@selector(videoFlickerTimerEvent) interval:0.1 repeat:false];
            
            self.isPlaying = true;
            [_player play];
            
            _positionTimer = [TGTimerTarget scheduledMainThreadTimerWithTarget:self action:@selector(positionTimerEvent) interval:0.25 repeat:true];
            
            [CATransaction begin];
            [CATransaction setDisableActions:true];
            [self layoutSubviews];
            [CATransaction commit];
            
            [self defaultFooterView].hidden = true;
            [self footerView].hidden = false;
        }
    }
    else
    {
        self.isPlaying = true;
        [_player play];
        
        _positionTimer = [TGTimerTarget scheduledMainThreadTimerWithTarget:self action:@selector(positionTimerEvent) interval:0.25 repeat:true];
    }
}

- (void)pausePressed
{
    self.isPlaying = false;
    [_player pause];
    
    [_positionTimer invalidate];
    _positionTimer = nil;
    
    [self updatePosition:false forceZero:false];
    
    _playButton.hidden = true;
}

- (void)playerItemDidPlayToEndTime:(NSNotification *)notification
{
    _currentLoopCount++;
    
    if ([self shouldLoopVideo:_currentLoopCount])
    {
        AVPlayerItem *p = [notification object];
        [p seekToTime:kCMTimeZero];
    }
    else
    {
        [_player pause];
        
        AVPlayerItem *p = [notification object];
        [p seekToTime:kCMTimeZero];
        
        [_positionTimer invalidate];
        _positionTimer = nil;
        
        self.isPlaying = false;
        [self updatePosition:false forceZero:true];
    }
}

- (bool)shouldLoopVideo:(NSUInteger)__unused currentLoopCount
{
    return false;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (_videoDimenstions.width > FLT_EPSILON && _videoDimenstions.height > FLT_EPSILON)
    {
        CGSize fittedSize = TGFitSize(TGFillSize(_videoDimenstions, self.bounds.size), self.bounds.size);
        
        CGFloat normalizedRotation = CGFloor(_playerLayerRotation / (CGFloat)M_PI) * (CGFloat)M_PI;
        
        if (ABS(_playerLayerRotation - normalizedRotation) > FLT_EPSILON)
        {
            fittedSize = TGFitSize(TGFillSize(_videoDimenstions, CGSizeMake(self.bounds.size.height, self.bounds.size.width)), CGSizeMake(self.bounds.size.height, self.bounds.size.width));
        }
        
        CGRect playerFrame = CGRectMake(CGFloor((self.bounds.size.width - fittedSize.width) / 2.0f), CGFloor((self.bounds.size.height - fittedSize.height) / 2.0f), fittedSize.width, fittedSize.height);
        CGRect playerBounds = (CGRect){CGPointZero, playerFrame.size};
        
        if (![_contentView pop_animationForKey:@"transitionInSpring"] && ![_contentView pop_animationForKey:@"transitionOutSpring"] && !CGRectEqualToRect(_contentView.frame, playerFrame))
        {
            _contentView.frame = playerFrame;
        }
        
        if (!CGRectEqualToRect(_playerView.frame, playerBounds))
        {
            _playerView.frame = playerBounds;
            [CATransaction begin];
            [CATransaction setAnimationDuration:0.3];
            [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
            _playerLayer.frame = (CGRect){CGPointZero, playerBounds.size};
            [CATransaction commit];
            
            _imageView.frame = playerBounds;
        }
    }
    
    _playButton.frame = (CGRect){{CGFloor((_contentView.frame.size.width - _playButton.frame.size.width) / 2.0f), CGFloor((_contentView.frame.size.height - _playButton.frame.size.height) / 2.0f)}, _playButton.frame.size};
}

- (UIView *)headerView
{
    return _scrubbingInterfaceView;
}

- (UIView *)footerView
{
    return _footerView;
}

- (void)rotationGesture:(UIRotationGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateChanged)
    {
        _containerView.transform = CGAffineTransformMakeRotation(_playerLayerRotation + [recognizer rotation]);
    }
    else if (recognizer.state == UIGestureRecognizerStateRecognized)
    {
        CGFloat tempAngle = _playerLayerRotation + [recognizer rotation];
        CGFloat angle = CGFloor(tempAngle / (CGFloat)M_2_PI) * (CGFloat)M_2_PI;
        
        _playerLayerRotation = CGFloor((angle + (CGFloat)M_PI_4) / (CGFloat)M_PI_2) * (CGFloat)M_PI_2;
        
        [UIView animateWithDuration:0.3 animations:^
        {
            _containerView.transform = CGAffineTransformMakeRotation(_playerLayerRotation);
            [self layoutSubviews];
        }];
    }
    else if (recognizer.state == UIGestureRecognizerStateFailed)
    {
        [UIView animateWithDuration:0.3 animations:^
        {
            _containerView.transform = CGAffineTransformMakeRotation(_playerLayerRotation);
            [self layoutSubviews];
        }];
    }
}

- (void)setIsPlaying:(bool)isPlaying
{
    _isPlaying = isPlaying;
    
    _playButton.hidden = _isPlaying;
    _footerView.isPlaying = _isPlaying;
}

- (void)videoFlickerTimerEvent
{
    [_videoFlickerTimer invalidate];
    _videoFlickerTimer = nil;
    
    _playerLayer.opacity = 1.0f;
}

- (void)positionTimerEvent
{
    [self updatePosition:true forceZero:false];
}

- (void)updatePosition:(bool)animated forceZero:(bool)forceZero
{
    [_scrubbingInterfaceView setDuration:_duration currentTime:forceZero ? 0.0 : CMTimeGetSeconds(_player.currentItem.currentTime) isPlaying:_isPlaying animated:animated];
}

- (void)doubleTapGesture:(TGDoubleTapGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateRecognized)
    {
        if (recognizer.doubleTapped)
        {
        }
        else
        {
            id<TGModernGalleryItemViewDelegate> delegate = self.delegate;
            if ([delegate respondsToSelector:@selector(itemViewDidRequestInterfaceShowHide:)])
                [delegate itemViewDidRequestInterfaceShowHide:self];
        }
    }
}

- (UIView *)transitionView
{
    return _contentView;
}

@end
