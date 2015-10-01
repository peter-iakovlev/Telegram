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
#import "TGImageView.h"

#import "TGModernGalleryVideoItem.h"
#import "TGVideoMediaAttachment.h"

#import "TGVideoDownloadActor.h"

#import "TGModernGalleryVideoScrubbingInterfaceView.h"
#import "TGModernGalleryRotationGestureRecognizer.h"
#import "TGModernGalleryVideoFooterView.h"
#import "TGModernGalleryVideoView.h"
#import "TGModernGalleryVideoContentView.h"
#import "TGModernGalleryDefaultFooterView.h"

#import "TGDoubleTapGestureRecognizer.h"

#import "TGTimerTarget.h"
#import "TGObserverProxy.h"

#import "TGModernButton.h"
#import "TGMessageImageViewOverlayView.h"

#import <pop/POP.h>

#import "ActionStage.h"

#import "TGDownloadManager.h"
#import "TGMessage.h"

#import "TGGenericPeerMediaGalleryVideoItem.h"

#import "TGAudioSessionManager.h"

@interface TGModernGalleryVideoItemView () <TGDoubleTapGestureRecognizerDelegate, ASWatcher>
{
    UIView *_containerView;
    TGModernGalleryVideoContentView *_contentView;
    UIView *_playerView;
    TGModernGalleryVideoView *_videoView;
    
    CGFloat _playerLayerRotation;
    NSUInteger _currentLoopCount;
    
    TGModernButton *_actionButton;
    TGMessageImageViewOverlayView *_progressView;
    
    bool _mediaAvailable;
    bool _downloading;
    int32_t _transactionId;
    
    TGModernGalleryVideoScrubbingInterfaceView *_scrubbingInterfaceView;
    TGModernGalleryVideoFooterView *_footerView;
    
    NSTimer *_positionTimer;
    NSTimer *_videoFlickerTimer;
    
    TGObserverProxy *_didPlayToEndObserver;
    
    NSTimeInterval _duration;
    
    SMetaDisposable *_currentAudioSession;
}

@property (nonatomic, strong) ASHandle *actionHandle;

@property (nonatomic) bool isPlaying;
@property (nonatomic) bool isScrubbing;

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
        _actionHandle = [[ASHandle alloc] initWithDelegate:self releaseOnMainThread:true];
        _currentAudioSession = [[SMetaDisposable alloc] init];
        
        _containerView = [[TGModernGalleryVideoContentView alloc] initWithFrame:(CGRect){CGPointZero, frame.size}];
        [self addSubview:_containerView];
        
        TGDoubleTapGestureRecognizer *recognizer = [[TGDoubleTapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapGesture:)];
        recognizer.consumeSingleTap = true;
        recognizer.avoidControls = true;
        [self addGestureRecognizer:recognizer];
        
        _contentView = [[TGModernGalleryVideoContentView alloc] init];
        [_containerView addSubview:_contentView];
        
        _imageView = [[TGImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleToFill;
        [_contentView addSubview:_imageView];
        
        _playerView = [[UIView alloc] init];
        [_contentView addSubview:_playerView];
        
        _actionButton = [[TGModernButton alloc] initWithFrame:(CGRect){CGPointZero, {50.0f, 50.0f}}];
        _actionButton.modernHighlight = true; 
        
        CGFloat circleDiameter = 50.0f;
        static UIImage *highlightImage = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^
        {
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(circleDiameter, circleDiameter), false, 0.0f);
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextSetFillColorWithColor(context, UIColorRGBA(0x000000, 0.4f).CGColor);
            CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, circleDiameter, circleDiameter));
            highlightImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        });
        
        _actionButton.highlightImage = highlightImage;
        
        _progressView = [[TGMessageImageViewOverlayView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 50.0f, 50.0f)];
        _progressView.userInteractionEnabled = false;
        [_actionButton addSubview:_progressView];
        
        [_actionButton addTarget:self action:@selector(playPressed) forControlEvents:UIControlEventTouchUpInside];
        
        _contentView.button = _actionButton;
        [_contentView addSubview:_actionButton];
        
        _scrubbingInterfaceView = [[TGModernGalleryVideoScrubbingInterfaceView alloc] init];
        __weak TGModernGalleryVideoItemView *weakSelf = self;
        _scrubbingInterfaceView.scrubbingBegan = ^
        {
            __strong TGModernGalleryVideoItemView *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                [strongSelf pausePressed];
                [strongSelf setIsScrubbing:true];
            }
        };
        _scrubbingInterfaceView.scrubbingChanged = ^(CGFloat position)
        {
            __strong TGModernGalleryVideoItemView *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                NSTimeInterval positionSeconds = CMTimeGetSeconds(strongSelf.player.currentItem.duration) * position;
                [strongSelf.player.currentItem seekToTime:CMTimeMake((int64_t)(positionSeconds * 1000.0), 1000.0)];
            }
        };
        _scrubbingInterfaceView.scrubbingCancelled = ^
        {
            __strong TGModernGalleryVideoItemView *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                [strongSelf setIsScrubbing:false];
                [strongSelf play];
            }
        };
        _scrubbingInterfaceView.scrubbingFinished = ^(CGFloat position)
        {
            __strong TGModernGalleryVideoItemView *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                NSTimeInterval positionSeconds = CMTimeGetSeconds(strongSelf.player.currentItem.duration) * position;
                [strongSelf.player.currentItem seekToTime:CMTimeMake((int64_t)(positionSeconds * 1000.0), 1000.0)];
                
                [strongSelf setIsScrubbing:false];
                [strongSelf play];
            }
        };
        
        _footerView = [[TGModernGalleryVideoFooterView alloc] init];
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

- (void)dealloc
{
    [self stopPlayer];
    
    [_actionHandle reset];
    [ActionStageInstance() removeWatcher:self];
    [_currentAudioSession dispose];
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    CGAffineTransform transform = _containerView.transform;
    _containerView.transform = CGAffineTransformIdentity;
    _containerView.frame = (CGRect){CGPointZero, frame.size};
    _containerView.transform = transform;
    
    _contentView.frame = (CGRect){CGPointZero, frame.size};
}

- (void)prepareForRecycle
{
    [super prepareForRecycle];
    
    [ActionStageInstance() removeWatcher:self];
    
    [self cleanupCurrentPlayer];
    
    _currentLoopCount = 0;
    
    [_imageView reset];
    
    [_videoFlickerTimer invalidate];
    _videoFlickerTimer = nil;
    
    _videoView.alpha = 1.0f;
    
    [_positionTimer invalidate];
    _positionTimer = nil;
    
    _playerLayerRotation = 0.0f;
    _containerView.transform = CGAffineTransformIdentity;
    _actionButton.transform = CGAffineTransformIdentity;
    
    self.isPlaying = false;
    
    [self footerView].hidden = true;
}

- (void)cleanupCurrentPlayer
{
    [self stopPlayer];
    
    _videoDimenstions = CGSizeZero;
    
    [_imageView reset];
}

- (void)stopPlayer
{
    if (_player != nil)
    {
        _didPlayToEndObserver = nil;
        
        [_player replaceCurrentItemWithPlayerItem:nil];
        //[_player pause];
        _player = nil;
    }
    
    if (_videoView != nil)
    {
        [_videoView removeFromSuperview];
        _videoView = nil;
    }
    
    [_currentAudioSession setDisposable:nil];
    
    [_positionTimer invalidate];
    _positionTimer = nil;
    
    self.isPlaying = false;
    [self updatePosition:false forceZero:true];
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

- (void)_joinDownload
{
    if (((TGModernGalleryVideoItem *)self.item).videoMedia == nil)
        return;
    
    TGVideoMediaAttachment *videoAttachment = ((TGModernGalleryVideoItem *)self.item).videoMedia;
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        NSString *url = [videoAttachment.videoInfo urlWithQuality:1 actualQuality:NULL actualSize:NULL];
        NSString *path = [[NSString alloc] initWithFormat:@"/as/media/video/(%@)", url];
        if ([ActionStageInstance() requestActorStateNow:path])
        {
            TGDispatchOnMainThread(^
            {
                _downloading = true;
                [self setProgressVisible:true value:0.0f animated:false];
            });
            
            [ActionStageInstance() requestActor:path options:nil watcher:self];
        }
    }];
}

- (void)_cancelDownload
{
    [ActionStageInstance() removeWatcher:self];
    
    TGVideoMediaAttachment *videoAttachment = ((TGModernGalleryVideoItem *)self.item).videoMedia;
    
    id itemId = [[TGMediaId alloc] initWithType:1 itemId:videoAttachment.videoId];
    [[TGDownloadManager instance] cancelItem:itemId];
    
    TGDispatchOnMainThread(^
    {
        _downloading = false;
        [self setProgressVisible:false value:0.0f animated:false];
    });
}

- (void)_requestDownload
{
    TGVideoMediaAttachment *videoAttachment = ((TGModernGalleryVideoItem *)self.item).videoMedia;
    NSString *url = [videoAttachment.videoInfo urlWithQuality:1 actualQuality:NULL actualSize:NULL];
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    dict[@"videoAttachment"] = videoAttachment;
    if (((TGModernGalleryVideoItem *)self.item).videoDownloadArguments != nil)
        dict[@"additionalOptions"] = ((TGModernGalleryVideoItem *)self.item).videoDownloadArguments;
    
    [ActionStageInstance() requestActor:[[NSString alloc] initWithFormat:@"/as/media/video/(%@)", url] options:dict watcher:self];
    
    TGDispatchOnMainThread(^
    {
        _downloading = true;
        [self setProgressVisible:true value:0.0f animated:false];
    });
}

- (void)setItem:(TGModernGalleryVideoItem *)item synchronously:(bool)synchronously
{
    _transactionId++;
    
    [super setItem:item synchronously:synchronously];
    
    [self cleanupCurrentPlayer];
    
    [self footerView].hidden = true;
    
    [_scrubbingInterfaceView setDuration:item.videoMedia.duration currentTime:0.0 isPlaying:false isPlayable:false animated:false];
    
    NSString *videoPath = [TGVideoDownloadActor localPathForVideoUrl:[item.videoMedia.videoInfo urlWithQuality:0 actualQuality:NULL actualSize:NULL]];
    
    if (videoPath != nil && item.videoMedia.dimensions.width > FLT_EPSILON && item.videoMedia.dimensions.height > FLT_EPSILON)
    {
        _videoDimenstions = item.videoMedia.dimensions;
        _duration = item.videoMedia.duration;
        
        [_imageView loadUri:item.previewUri withOptions:@{TGImageViewOptionSynchronous: @(synchronously)}];
        
        int32_t transactionId = _transactionId;
        __weak TGModernGalleryVideoItemView *weakSelf = self;
        dispatch_block_t checkMediaAvailability = ^
        {
            __strong TGModernGalleryVideoItemView *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                if ([[NSFileManager defaultManager] fileExistsAtPath:videoPath isDirectory:NULL])
                {
                    TGDispatchOnMainThread(^
                    {
                        if (strongSelf->_transactionId == transactionId)
                            [strongSelf setMediaAvailable:true];
                    });
                }
                else
                {
                    TGDispatchOnMainThread(^
                    {
                        if (strongSelf->_transactionId == transactionId)
                        {
                            [strongSelf setMediaAvailable:false];
                            [strongSelf _joinDownload];
                        }
                    });
                }
            }
        };
        
        if (synchronously)
            checkMediaAvailability();
        else
            [ActionStageInstance() dispatchOnStageQueue:checkMediaAvailability];
        
        [self layoutSubviews];
    }
}

- (void)setMediaAvailable:(bool)mediaAvailable
{
    _mediaAvailable = mediaAvailable;
    
    if (_mediaAvailable)
        [_progressView setPlay];
    else
        [_progressView setDownload];
}

- (void)play
{
    [self playPressed];
}

- (void)_willPlay
{
}

- (void)hidePlayButton
{
    _actionButton.hidden = true;
}

- (void)playPressed
{
    if (_mediaAvailable)
    {
        [self _willPlay];
        
        if (_player == nil)
        {
            TGModernGalleryVideoItem *item = (TGModernGalleryVideoItem *)self.item;
            
            NSString *videoPath = [TGVideoDownloadActor localPathForVideoUrl:[item.videoMedia.videoInfo urlWithQuality:0 actualQuality:NULL actualSize:NULL]];
            
            if (videoPath != nil && item.videoMedia.dimensions.width > FLT_EPSILON && item.videoMedia.dimensions.height > FLT_EPSILON)
            {
                _videoDimenstions = item.videoMedia.dimensions;
                
                __weak TGModernGalleryVideoItemView *weakSelf = self;
                [_currentAudioSession setDisposable:[[TGAudioSessionManager instance] requestSessionWithType:TGAudioSessionTypePlayVideo interrupted:^
                {
                    TGDispatchOnMainThread(^
                    {
                        __strong TGModernGalleryVideoItemView *strongSelf = weakSelf;
                        if (strongSelf != nil)
                            [strongSelf pausePressed];
                    });
                }]];
                [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
                
                _player = [[AVPlayer alloc] initWithURL:[NSURL fileURLWithPath:videoPath]];
                _player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
                
                _didPlayToEndObserver = [[TGObserverProxy alloc] initWithTarget:self targetSelector:@selector(playerItemDidPlayToEndTime:) name:AVPlayerItemDidPlayToEndTimeNotification object:[_player currentItem]];
                                
                _videoView = [[TGModernGalleryVideoView alloc] initWithFrame:_playerView.bounds player:_player];
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
                
                [self footerView].hidden = false;
                [self setDefaultFooterHidden:true];
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
    else if (_downloading)
        [self _cancelDownload];
    else
        [self _requestDownload];
}

- (void)setDefaultFooterHidden:(bool)hidden
{
    if ([[self defaultFooterView] respondsToSelector:@selector(setContentHidden:)])
        [[self defaultFooterView] setContentHidden:hidden];
    else
        [self defaultFooterView].hidden = hidden;
}

- (void)pausePressed
{
    self.isPlaying = false;
    [_player pause];
    
    [_positionTimer invalidate];
    _positionTimer = nil;
    
    [self updatePosition:false forceZero:false];
    
    _actionButton.hidden = true;
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
        CGRect playerBounds = playerFrame;
        
        if (!CGRectEqualToRect(_imageView.frame, playerBounds))
        {
            _playerView.frame = playerBounds;
            _videoView.frame = (CGRect){CGPointZero, playerBounds.size};
            _imageView.frame = playerBounds;
        }
    }
    else
    {
        CGSize fittedSize = CGSizeMake(128.0f, 128.0f);
        
        CGRect playerFrame = CGRectMake(CGFloor((self.bounds.size.width - fittedSize.width) / 2.0f), CGFloor((self.bounds.size.height - fittedSize.height) / 2.0f), fittedSize.width, fittedSize.height);
        CGRect playerBounds = playerFrame;
        
        if (!CGRectEqualToRect(_imageView.frame, playerBounds))
        {
            _playerView.frame = playerBounds;
            _videoView.frame = (CGRect){CGPointZero, playerBounds.size};
            _imageView.frame = playerBounds;
        }
    }
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
        _actionButton.transform = CGAffineTransformMakeRotation(-[self normalizeAngle:_playerLayerRotation + [recognizer rotation]]);
    }
    else if (recognizer.state == UIGestureRecognizerStateRecognized)
    {
        CGFloat tempAngle = [self normalizeAngle:_playerLayerRotation + [recognizer rotation]];
        CGFloat angle = CGFloor(tempAngle / (CGFloat)M_2_PI) * (CGFloat)M_2_PI;
        
        _playerLayerRotation = CGFloor((angle + (CGFloat)M_PI_4) / (CGFloat)M_PI_2) * (CGFloat)M_PI_2;
        
        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^
        {
            _containerView.transform = CGAffineTransformMakeRotation(_playerLayerRotation);
            _actionButton.transform = CGAffineTransformMakeRotation(-_playerLayerRotation);
            [self layoutSubviews];
        } completion:nil];
    }
    else if (recognizer.state == UIGestureRecognizerStateFailed)
    {
        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^
        {
            _containerView.transform = CGAffineTransformMakeRotation(_playerLayerRotation);
            _actionButton.transform = CGAffineTransformMakeRotation(-_playerLayerRotation);
            [self layoutSubviews];
        } completion:nil];
    }
}

- (void)setIsPlaying:(bool)isPlaying
{
    _isPlaying = isPlaying;
    
    _actionButton.hidden = _isPlaying || _isScrubbing;
    _footerView.isPlaying = _isPlaying;
}

- (void)setIsScrubbing:(bool)isScrubbing
{
    _isScrubbing = isScrubbing;
    
    _actionButton.hidden = _isPlaying || _isScrubbing;
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
    [_scrubbingInterfaceView setDuration:duration currentTime:forceZero ? 0.0 : CMTimeGetSeconds(_player.currentItem.currentTime) isPlaying:_isPlaying isPlayable:_player != nil animated:animated];
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

- (CGRect)transitionViewContentRect
{
    return [_contentView convertRect:_playerView.bounds fromView:_playerView];
}

- (void)setFocused:(bool)isFocused
{
    if (!isFocused)
    {
        [self footerView].hidden = true;
        [self setDefaultFooterHidden:false];
    }
}

- (void)setIsVisible:(bool)isVisible
{
    [super setIsVisible:isVisible];
    
    if (!isVisible && _player != nil)
        [self stopPlayer];
}

- (void)setProgressVisible:(bool)progressVisible value:(float)value animated:(bool)animated
{
    if (progressVisible)
        [_progressView setProgress:value cancelEnabled:true animated:animated];
    else if (_mediaAvailable)
        [_progressView setPlay];
    else
        [_progressView setDownload];
}

- (void)actorMessageReceived:(NSString *)path messageType:(NSString *)messageType message:(id)message
{
    if ([path hasPrefix:@"/as/media/video/"])
    {
        if ([messageType isEqualToString:@"progress"])
        {
            float progress = [message floatValue];
            TGDispatchOnMainThread(^
            {
                [self setProgressVisible:true value:progress animated:true];
            });
        }
    }
}

- (void)actorCompleted:(int)status path:(NSString *)path result:(id)__unused result
{
    if ([path hasPrefix:@"/as/media/video/"])
    {
        dispatch_async(dispatch_get_main_queue(), ^
        {
            if (status == ASStatusSuccess)
            {
                _downloading = false;
                _mediaAvailable = true;
                
                [self setProgressVisible:false value:1.0f animated:false];
                
                [_imageView loadUri:((TGModernGalleryVideoItem *)self.item).previewUri withOptions:@{TGImageViewOptionKeepCurrentImageAsPlaceholder: @true}];
            }
        });
    }
}

@end
