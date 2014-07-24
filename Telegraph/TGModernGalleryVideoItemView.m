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
#import "TGModernGalleryVideoView.h"
#import "TGModernGalleryVideoContentView.h"

#import "TGDoubleTapGestureRecognizer.h"

#import "TGTimerTarget.h"
#import "TGObserverProxy.h"

#import <pop/POP.h>

@interface TGModernGalleryVideoItemView () <TGDoubleTapGestureRecognizerDelegate>
{
    UIView *_containerView;
    TGModernGalleryVideoContentView *_contentView;
    UIView *_playerView;
    TGModernGalleryVideoView *_videoView;
    
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

- (UIImage *)playButtonImage
{
    static UIImage *image = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        const CGFloat diameter = 50.0f;
        
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(diameter, diameter), false, 0.0f);
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        const CGFloat width = 20.0f;
        const CGFloat height = width + 4.0f;
        const CGFloat offset = 3.0f;
        
        CGContextSetBlendMode(context, kCGBlendModeCopy);
        
        CGContextSetFillColorWithColor(context, UIColorRGBA(0xffffffff, 1.0f).CGColor);
        CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, diameter, diameter));
        
        CGContextBeginPath(context);
        CGContextMoveToPoint(context, offset + CGFloor((diameter - width) / 2.0f), CGFloor((diameter - height) / 2.0f));
        CGContextAddLineToPoint(context, offset + CGFloor((diameter - width) / 2.0f) + width, CGFloor(diameter / 2.0f));
        CGContextAddLineToPoint(context, offset + CGFloor((diameter - width) / 2.0f), CGFloor((diameter + height) / 2.0f));
        CGContextClosePath(context);
        CGContextSetFillColorWithColor(context, UIColorRGBA(0x727272, 1.0f).CGColor);
        CGContextFillPath(context);
        
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
        _containerView = [[TGModernGalleryVideoContentView alloc] initWithFrame:(CGRect){CGPointZero, frame.size}];
        [self addSubview:_containerView];
        
        TGDoubleTapGestureRecognizer *recognizer = [[TGDoubleTapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapGesture:)];
        recognizer.consumeSingleTap = true;
        recognizer.avoidControls = true;
        [self addGestureRecognizer:recognizer];
        
        _contentView = [[TGModernGalleryVideoContentView alloc] init];
        [_containerView addSubview:_contentView];
        
        _imageView = [[TGRemoteImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleToFill;
        _imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [_contentView addSubview:_imageView];
        
        _playerView = [[UIView alloc] init];
        _playerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [_contentView addSubview:_playerView];
        
        _playButton = [[UIButton alloc] init];
        [_playButton setImage:[self playButtonImage] forState:UIControlStateNormal];
        [_playButton sizeToFit];
        
        [_playButton addTarget:self action:@selector(playPressed) forControlEvents:UIControlEventTouchUpInside];
        
        _contentView.button = _playButton;
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
        rotationRecognizer.cancelsTouchesInView = false;
        [self addGestureRecognizer:rotationRecognizer];
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
    
    [_videoFlickerTimer invalidate];
    _videoFlickerTimer = nil;
    
    _videoView.alpha = 1.0f;
    
    [_positionTimer invalidate];
    _positionTimer = nil;
    
    _playerLayerRotation = 0.0f;
    _containerView.transform = CGAffineTransformIdentity;
    _playButton.transform = CGAffineTransformIdentity;
    
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
    
    if (_videoView != nil)
    {
        [_videoView removeFromSuperview];
        _videoView = nil;
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
            
            _videoView = [[TGModernGalleryVideoView alloc] initWithFrame:_playerView.bounds playerLayer:[AVPlayerLayer playerLayerWithPlayer:_player]];
            _videoView.frame = _playerView.bounds;
            _videoView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            _videoView.playerLayer.videoGravity = AVLayerVideoGravityResize;
            _videoView.playerLayer.opaque = false;
            _videoView.playerLayer.backgroundColor = nil;
            [_playerView addSubview:_videoView];
            
            _videoView.alpha = 0.0f;
            _videoFlickerTimer = [TGTimerTarget scheduledMainThreadTimerWithTarget:self action:@selector(videoFlickerTimerEvent) interval:0.1 repeat:false];
            
            self.isPlaying = true;
            [_player play];
            
            _positionTimer = [TGTimerTarget scheduledMainThreadTimerWithTarget:self action:@selector(positionTimerEvent) interval:0.25 repeat:true];
            [self positionTimerEvent];
            
            [self layoutSubviews];
            
            [self defaultFooterView].hidden = true;
            [self footerView].hidden = false;
        }
    }
    else
    {
        self.isPlaying = true;
        [_player play];
        
        _positionTimer = [TGTimerTarget scheduledMainThreadTimerWithTarget:self action:@selector(positionTimerEvent) interval:0.25 repeat:true];
        [self positionTimerEvent];
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
        
        //if (![_contentView pop_animationForKey:@"transitionInSpring"] && ![_contentView pop_animationForKey:@"transitionOutSpring"] && !CGRectEqualToRect(_contentView.frame, playerFrame))
        {
            _contentView.frame = playerFrame;
        }
        
        if (!CGRectEqualToRect(_imageView.frame, playerBounds))
        {
            _playerView.frame = playerBounds;
            _videoView.frame = (CGRect){CGPointZero, playerBounds.size};
            _imageView.frame = playerBounds;
        }
    }
    
    //_playButton.frame = (CGRect){{CGFloor((self.frame.size.width - _playButton.frame.size.width) / 2.0f), CGFloor((self.frame.size.height - _playButton.frame.size.height) / 2.0f)}, _playButton.frame.size};
}

- (UIView *)headerView
{
    return _scrubbingInterfaceView;
}

- (UIView *)footerView
{
    return _footerView;
}

- (CGFloat)normalizeAngle:(CGFloat)angle
{
    return angle;
    
    /*CGFloat n = (int)(angle / (CGFloat)M_2_PI);
    if (angle < 0)
        angle += n * M_2_PI;
    else
        angle -= n * M_2_PI;
    return angle;*/
}

- (void)rotationGesture:(UIRotationGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateChanged)
    {
        _containerView.transform = CGAffineTransformMakeRotation([self normalizeAngle:_playerLayerRotation + [recognizer rotation]]);
        _playButton.transform = CGAffineTransformMakeRotation(-[self normalizeAngle:_playerLayerRotation + [recognizer rotation]]);
    }
    else if (recognizer.state == UIGestureRecognizerStateRecognized)
    {
        CGFloat tempAngle = [self normalizeAngle:_playerLayerRotation + [recognizer rotation]];
        CGFloat angle = CGFloor(tempAngle / (CGFloat)M_2_PI) * (CGFloat)M_2_PI;
        
        _playerLayerRotation = CGFloor((angle + (CGFloat)M_PI_4) / (CGFloat)M_PI_2) * (CGFloat)M_PI_2;
        
        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^
        {
            _containerView.transform = CGAffineTransformMakeRotation(_playerLayerRotation);
            _playButton.transform = CGAffineTransformMakeRotation(-_playerLayerRotation);
            [self layoutSubviews];
        } completion:nil];
    }
    else if (recognizer.state == UIGestureRecognizerStateFailed)
    {
        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^
        {
            _containerView.transform = CGAffineTransformMakeRotation(_playerLayerRotation);
            _playButton.transform = CGAffineTransformMakeRotation(-_playerLayerRotation);
            [self layoutSubviews];
        } completion:nil];
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
    
    _videoView.alpha = 1.0f;
}

- (void)positionTimerEvent
{
    [self updatePosition:true forceZero:false];
}

- (void)updatePosition:(bool)animated forceZero:(bool)forceZero
{
    NSTimeInterval duration = _duration;
    NSTimeInterval actualDuration = CMTimeGetSeconds(_player.currentItem.duration);
    if (actualDuration > 0.1f)
        duration = actualDuration;
    [_scrubbingInterfaceView setDuration:duration currentTime:forceZero ? 0.0 : CMTimeGetSeconds(_player.currentItem.currentTime) isPlaying:_isPlaying animated:animated];
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
