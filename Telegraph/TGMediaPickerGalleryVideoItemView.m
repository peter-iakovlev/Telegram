#import "TGMediaPickerGalleryVideoItemView.h"

#import <AVFoundation/AVFoundation.h>

#import "ATQueue.h"

#import "TGImageUtils.h"
#import "TGPhotoEditorUtils.h"
#import "TGObserverProxy.h"
#import "TGTimerTarget.h"
#import "TGStringUtils.h"

#import <pop/POP.h>
#import "TGPhotoEditorInterfaceAssets.h"

#import "TGMediaPickerGalleryItem.h"
#import "TGMediaPickerGalleryVideoItem.h"

#import "TGAssetImageManager.h"
#import "TGAssetImageView.h"

#import "TGEditablePhotoItem.h"
#import "TGVideoEditAdjustments.h"

#import "TGModernButton.h"
#import "TGMessageImageViewOverlayView.h"
#import "TGMediaPickerGalleryVideoScrubber.h"
#import "TGPhotoEditorAnimation.h"

#import "TGModernGalleryVideoView.h"
#import "TGModernGalleryVideoContentView.h"

#import "TGAudioSessionManager.h"

@interface TGMediaPickerGalleryVideoItemView() <TGMediaPickerGalleryVideoScrubberDataSource, TGMediaPickerGalleryVideoScrubberDelegate>
{
    UIView *_containerView;
    TGModernGalleryVideoContentView *_contentView;
    UIView *_playerWrapperView;
    UIView *_playerView;
    UIView *_playerContainerView;
    UIView *_curtainView;
    
    UITapGestureRecognizer *_tapGestureRecognizer;
    
    TGModernButton *_actionButton;
    TGMessageImageViewOverlayView *_progressView;
    
    UIView *_headerView;
    UIView *_scrubberPanelView;
    TGMediaPickerGalleryVideoScrubber *_scrubberView;
    bool _wasPlayingBeforeScrubbing;
    bool _appeared;
    bool _scrubbingPanelPresented;
    
    UILabel *_fileInfoLabel;
    
    TGModernGalleryVideoView *_videoView;
    
    NSTimer *_positionTimer;
    TGObserverProxy *_didPlayToEndObserver;
    
    TGAssetThumbnailsRequestCancelToken *_thumbnailsCancelToken;
    
    CGSize _videoDimensions;
    NSTimeInterval _videoDuration;
    
    NSUInteger _attributesRequestToken;
    volatile NSInteger _attributesVersion;
    
    UIImage *_lastRenderedScreenImage;
    
    SMetaDisposable *_currentAudioSession;
}
@end

@implementation TGMediaPickerGalleryVideoItemView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        _currentAudioSession = [[SMetaDisposable alloc] init];
        
        _containerView = [[UIView alloc] initWithFrame:self.bounds];
        _containerView.clipsToBounds = true;
        [self addSubview:_containerView];
        
        _contentView = [[TGModernGalleryVideoContentView alloc] init];
        [_containerView addSubview:_contentView];
        
        _playerWrapperView = [[UIView alloc] init];
        [_contentView addSubview:_playerWrapperView];
        
        _playerView = [[UIView alloc] init];
        _playerView.clipsToBounds = true;
        [_playerWrapperView addSubview:_playerView];
        
        _playerContainerView = [[UIView alloc] init];
        [_playerView addSubview:_playerContainerView];
        
        _imageView = [[TGAssetImageView alloc] init];
        [_playerContainerView addSubview:_imageView];
        
        _curtainView = [[UIView alloc] init];
        _curtainView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _curtainView.backgroundColor = [UIColor blackColor];
        _curtainView.hidden = true;
        [_contentView addSubview:_curtainView];
        
        _actionButton = [[TGModernButton alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
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
        
        _progressView = [[TGMessageImageViewOverlayView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        _progressView.userInteractionEnabled = false;
        [_progressView setPlay];
        [_actionButton addSubview:_progressView];
        
        [_actionButton addTarget:self action:@selector(playPressed) forControlEvents:UIControlEventTouchUpInside];
        
        _contentView.button = _actionButton;
        [_contentView addSubview:_actionButton];
        
        _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 44)];
        _headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        _scrubberPanelView = [[UIView alloc] initWithFrame:CGRectMake(0, -64, _headerView.frame.size.width, 64)];
        _scrubberPanelView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _scrubberPanelView.backgroundColor = [TGPhotoEditorInterfaceAssets toolbarTransparentBackgroundColor];
        _scrubberPanelView.hidden = true;
        [_headerView addSubview:_scrubberPanelView];
        
        _scrubberView = [[TGMediaPickerGalleryVideoScrubber alloc] initWithFrame:_scrubberPanelView.bounds];
        _scrubberView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _scrubberView.dataSource = self;
        _scrubberView.delegate = self;
        [_scrubberPanelView addSubview:_scrubberView];
        
        _fileInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 4, _scrubberPanelView.frame.size.width, 15)];
        _fileInfoLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _fileInfoLabel.backgroundColor = [UIColor clearColor];
        _fileInfoLabel.font = TGSystemFontOfSize(13.0f);
        _fileInfoLabel.textAlignment = NSTextAlignmentCenter;
        _fileInfoLabel.textColor = [UIColor whiteColor];
        
        _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap)];
        [_contentView addGestureRecognizer:_tapGestureRecognizer];
    }
    return self;
}

- (void)dealloc
{
    [self stopPlayer];
}

- (void)prepareForRecycle
{
    [super prepareForRecycle];
    
    [self _playerCleanup];
    
    self.isPlaying = false;
    
    _appeared = false;
    [self hideScrubbingPanelAnimated:false];
    
    [_positionTimer invalidate];
    _positionTimer = nil;
    
    _lastRenderedScreenImage = nil;
}

+ (NSString *)_stringForDimensions:(CGSize)dimensions
{
    CGFloat longSide = MIN(dimensions.width, dimensions.height);
    if (longSide == 1080)
        return @"1080p";
    else if (longSide == 720)
        return @"720p";
    else if (longSide == 480)
        return @"480p";
    else if (longSide == 360)
        return @"360p";
    else if (longSide == 240)
        return @"240p";
    else if (longSide == 144)
        return @"144p";
    
    return [NSString stringWithFormat:@"%dx%d", (int)dimensions.width, (int)dimensions.height];
}

- (void)setItem:(TGMediaPickerGalleryVideoItem *)item synchronously:(bool)synchronously
{
    bool itemChanged = ![item isEqual:self.item];
    
    [super setItem:item synchronously:synchronously];
    
    if (itemChanged)
        [self _playerCleanup];
    
    _videoDimensions = item.dimensions;
    _videoDuration = item.duration;
    
    _scrubberView.allowsTrimming = (!item.asFile && ((item.asset != nil && !(item.asset.subtypes & TGMediaPickerAssetSubtypeVideoHighFrameRate || item.asset.subtypes & TGMediaPickerAssetSubtypeVideoTimelapse)) || item.avAsset != nil) && _videoDuration >= 3.0f);
    
    id<TGEditablePhotoItem> editableMediaItem = [item editableMediaItem];
    TGVideoEditAdjustments *adjustments = nil;
    if (editableMediaItem.fetchEditorValues != nil)
        adjustments = editableMediaItem.fetchEditorValues(editableMediaItem);

    if (adjustments != nil && fabs(adjustments.trimEndValue - adjustments.trimStartValue) > DBL_EPSILON)
    {
        _scrubberView.trimStartValue = adjustments.trimStartValue;
        _scrubberView.trimEndValue = adjustments.trimEndValue;
        _scrubberView.value = adjustments.trimStartValue;
        [_scrubberView setTrimApplied:(adjustments.trimStartValue > 0 || adjustments.trimEndValue < _videoDuration)];
    }
    else
    {
        _scrubberView.trimStartValue = 0;
        _scrubberView.trimEndValue = _videoDuration;
        [_scrubberView setTrimApplied:false];
    }
    
    if (item.immediateThumbnailImage != nil)
        _imageView.image = item.immediateThumbnailImage;
    
    if (adjustments != nil && adjustments.trimStartValue > FLT_EPSILON)
    {
        UIImage *image = editableMediaItem.fetchScreenImage(editableMediaItem);
        [_imageView loadWithImage:image];
    }
    else if (item.asset != nil)
    {
        if (_imageView.image == nil)
            [_imageView loadWithAsset:item.asset imageType:TGAssetImageTypeAspectRatioThumbnail size:CGSizeZero];
        
        [_imageView loadWithAsset:item.asset imageType:TGAssetImageTypeScreen size:CGSizeMake(1280, 1280) completionBlock:nil];
    }
    
    [self _layoutPlayerView];
    
    if (item.asFile)
    {
        _fileInfoLabel.text = nil;
        
        if (_attributesRequestToken != 0)
        {
            [TGAssetImageManager cancelRequestWithToken:_attributesRequestToken];
            _attributesRequestToken = 0;
        }

        _attributesVersion++;
        NSInteger version = _attributesVersion;

        __weak TGMediaPickerGalleryVideoItemView *weakSelf = self;
        _attributesRequestToken = [TGAssetImageManager requestFileAttributesForAsset:item.asset completion:^(NSString *fileName, __unused NSString *dataUTI, CGSize dimensions, NSUInteger fileSize)
        {
            __strong TGMediaPickerGalleryVideoItemView *strongSelf = weakSelf;
            if (strongSelf == nil)
                return;

            if (version == strongSelf->_attributesVersion)
            {
                NSString *extension = [fileName.pathExtension uppercaseString];
                strongSelf->_fileInfoLabel.text = [[NSString alloc] initWithFormat:@"%@ • %@ • %@", extension, [TGStringUtils stringForFileSize:fileSize precision:2], [TGMediaPickerGalleryVideoItemView _stringForDimensions:dimensions]];
                strongSelf->_attributesRequestToken = 0;
            }
        }];
    }
}

- (void)setIsCurrent:(bool)isCurrent
{
    if (isCurrent)
    {
        if (!_scrubbingPanelPresented && _thumbnailsCancelToken == nil)
        {
            [_scrubberView reloadData];
            if (!_appeared)
                [_scrubberView resetToStart];
            _appeared = true;
        }
    }
    else
    {
        
    }
}

- (void)presentScrubbingPanelAfterReload:(bool)afterReload
{
    if (afterReload)
        [_scrubberView reloadData];
    else
        [self presentScrubbingPanel];
}

- (void)presentScrubbingPanel
{
    if (_scrubbingPanelPresented)
        return;
    
    _scrubbingPanelPresented = true;
    
    _scrubberPanelView.hidden = false;
    [_scrubberPanelView setNeedsLayout];
    [_scrubberPanelView layoutIfNeeded];
    [_scrubberView layoutSubviews];
    
    [UIView animateWithDuration:0.3f delay:0.0f options:(7 << 16) animations:^
    {
        _scrubberPanelView.frame = CGRectMake(_scrubberPanelView.frame.origin.x, 0, _scrubberPanelView.frame.size.width, _scrubberPanelView.frame.size.height);
    } completion:nil];
}

- (void)hideScrubbingPanelAnimated:(bool)animated
{
    if (!_scrubbingPanelPresented)
        [_scrubberView ignoreThumbnails];
    
    _scrubbingPanelPresented = false;
    
    if (animated)
    {
        [UIView animateWithDuration:0.3f delay:0.0f options:(7 << 16) animations:^
        {
            _scrubberPanelView.frame = CGRectMake(_scrubberPanelView.frame.origin.x, -64, _scrubberPanelView.frame.size.width, _scrubberPanelView.frame.size.height);
        } completion:^(BOOL finished)
        {
            if (finished)
                _scrubberPanelView.hidden = true;
        }];
    }
    else
    {
        _scrubberPanelView.frame = CGRectMake(_scrubberPanelView.frame.origin.x, -64, _scrubberPanelView.frame.size.width, _scrubberPanelView.frame.size.height);
        _scrubberPanelView.hidden = true;
    }
}

- (void)setFrame:(CGRect)frame
{
    bool frameChanged = !CGRectEqualToRect(frame, self.frame);
    
    [super setFrame:frame];
    
    if (_appeared && frameChanged)
    {
        [_scrubberView resetThumbnails];
        
        [self hideScrubbingPanelAnimated:false];
        [_scrubberPanelView setNeedsLayout];
        [_scrubberPanelView layoutIfNeeded];
        
        dispatch_async(dispatch_get_main_queue(), ^
        {
            [_scrubberView reloadThumbnails];
            [_scrubberPanelView layoutSubviews];
        });
    }
    
    if (_containerView == nil)
        return;
    
    _containerView.frame = self.bounds;
    
    [self _layoutPlayerView];
    
    _contentView.frame = (CGRect){CGPointZero, frame.size};
}

- (void)_layoutPlayerView
{
    id<TGEditablePhotoItem> editableMediaItem = [self _editableMediaItem];
    
    [_playerView pop_removeAllAnimations];
    
    TGVideoEditAdjustments *adjustments = (editableMediaItem != nil) ? editableMediaItem.fetchEditorValues(editableMediaItem) : nil;
    
    CGSize videoFrameSize = _videoDimensions;
    CGRect cropRect = CGRectMake(0, 0, videoFrameSize.width, videoFrameSize.height);
    UIImageOrientation orientation = UIImageOrientationUp;
    if (adjustments != nil)
    {
        videoFrameSize = adjustments.cropRect.size;
        cropRect = adjustments.cropRect;
        orientation = adjustments.cropOrientation;
    }
    
    [self _layoutPlayerViewWithCropRect:cropRect videoFrameSize:videoFrameSize orientation:orientation];
}

- (void)_layoutPlayerViewWithCropRect:(CGRect)cropRect videoFrameSize:(CGSize)videoFrameSize orientation:(UIImageOrientation)orientation
{
    CGFloat rotation = TGRotationForOrientation(orientation);
    _playerView.transform = CGAffineTransformMakeRotation(rotation);
    
    if (orientation == UIImageOrientationLeft || orientation == UIImageOrientationRight)
        videoFrameSize = CGSizeMake(videoFrameSize.height, videoFrameSize.width);
    
    if (!CGSizeEqualToSize(videoFrameSize, CGSizeZero))
    {
        CGSize fittedSize = TGScaleToSize(videoFrameSize, self.frame.size);
        _playerWrapperView.frame = CGRectMake((_containerView.frame.size.width - fittedSize.width) / 2, (_containerView.frame.size.height - fittedSize.height) / 2, fittedSize.width, fittedSize.height);
        _playerView.frame = _playerWrapperView.bounds;
        _playerContainerView.frame = _playerView.bounds;
        
        CGFloat ratio = fittedSize.width / videoFrameSize.width;
        _imageView.frame = CGRectMake(-cropRect.origin.x * ratio, -cropRect.origin.y * ratio, _videoDimensions.width * ratio, _videoDimensions.height * ratio);
        _videoView.frame = _imageView.frame;
    }
}

- (void)singleTap
{
    [self togglePlayback];
}

- (void)setIsVisible:(bool)isVisible
{
    [super setIsVisible:isVisible];
    
    if (!isVisible && _player != nil)
        [self stopPlayer];
}

- (UIView *)headerView
{
    return _headerView;
}

- (UIView *)footerView
{
    if (((TGMediaPickerGalleryItem *)self.item).asFile)
        return _fileInfoLabel;
    
    return nil;
}

- (UIView *)transitionView
{
    return _containerView;
}

- (CGRect)transitionViewContentRect
{
    return [_imageView convertRect:_imageView.bounds toView:[self transitionView]];
}

- (UIImage *)screenImage
{
    if (_videoView != nil)
    {
        UIImage *image = nil;
        
        UIGraphicsBeginImageContextWithOptions(_videoView.bounds.size, true, [UIScreen mainScreen].scale);

        if (_lastRenderedScreenImage != nil)
            return _lastRenderedScreenImage;
        
        AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:_player.currentItem.asset];
        generator.appliesPreferredTrackTransform = true;
        generator.maximumSize = TGFitSize(_videoDimensions, CGSizeMake(1280.0f, 1280.0f));
        generator.requestedTimeToleranceAfter = kCMTimeZero;
        generator.requestedTimeToleranceBefore = kCMTimeZero;
        CGImageRef imageRef = [generator copyCGImageAtTime:_player.currentTime actualTime:nil error:NULL];
        image = [UIImage imageWithCGImage:imageRef];
        CGImageRelease(imageRef);

        return image;
    }
    else
    {
        return _imageView.image;
    }
}

- (UIImage *)transitionImage
{
    UIGraphicsBeginImageContextWithOptions(_playerWrapperView.bounds.size, true, 0.0f);

    _lastRenderedScreenImage = nil;
    
    if (_videoView == nil || CMTimeCompare(_player.currentTime, kCMTimeZero) == 0)
    {
        [_playerWrapperView.layer renderInContext:UIGraphicsGetCurrentContext()];
    }
    else
    {
        AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:_player.currentItem.asset];
        generator.appliesPreferredTrackTransform = true;
        generator.maximumSize = TGFitSize(_videoDimensions, CGSizeMake(1280.0f, 1280.0f));
        generator.requestedTimeToleranceAfter = kCMTimeZero;
        generator.requestedTimeToleranceBefore = kCMTimeZero;
        CGImageRef imageRef = [generator copyCGImageAtTime:_player.currentTime actualTime:nil error:NULL];
        
        _lastRenderedScreenImage = [UIImage imageWithCGImage:imageRef];
        CGImageRelease(imageRef);
        
        id<TGEditablePhotoItem> editableMediaItem = [self _editableMediaItem];
        TGVideoEditAdjustments *adjustments = editableMediaItem.fetchEditorValues(editableMediaItem);
        
        CGSize originalSize = _videoDimensions;
        CGRect cropRect = CGRectMake(0, 0, _videoDimensions.width, _videoDimensions.height);
        UIImageOrientation cropOrientation = UIImageOrientationUp;
        if (adjustments != nil)
        {
            cropRect = adjustments.cropRect;
            cropOrientation = adjustments.cropOrientation;
        }
        
        CGContextConcatCTM(UIGraphicsGetCurrentContext(), TGVideoCropTransformForOrientation(cropOrientation, _playerWrapperView.bounds.size, false));

        CGFloat ratio = TGOrientationIsSideward(cropOrientation, NULL) ? _playerWrapperView.bounds.size.width / cropRect.size.height : _playerWrapperView.bounds.size.width / cropRect.size.width;

        [_lastRenderedScreenImage drawInRect:CGRectMake(-cropRect.origin.x * ratio, -cropRect.origin.y * ratio, originalSize.width * ratio, originalSize.height * ratio)];
    }

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (CGRect)editorTransitionViewRect
{
    return [_playerWrapperView convertRect:_playerWrapperView.bounds toView:self];
}

- (void)setHiddenAsBeingEdited:(bool)hidden
{
    _curtainView.hidden = !hidden;
}

#pragma mark - Player

- (void)setPlayButtonHidden:(bool)hidden animated:(bool)animated
{
    if (animated)
    {
        _actionButton.hidden = false;
        [UIView animateWithDuration:0.15f animations:^
        {
            _actionButton.alpha = hidden ? 0.0f : 1.0f;
        } completion:^(BOOL finished)
        {
            if (finished)
                _actionButton.hidden = hidden;
        }];
    }
    else
    {
        _actionButton.alpha = hidden ? 0.0f : 1.0f;
        _actionButton.hidden = hidden;
    }
}

- (void)setIsPlaying:(bool)isPlaying
{
    _isPlaying = isPlaying;
    
    if (isPlaying)
        [self setPlayButtonHidden:true animated:true];
}

- (void)_playerCleanup
{
    [self stopPlayer];
    
    _videoDimensions = CGSizeZero;
    
    [_imageView reset];
    [self setPlayButtonHidden:false animated:false];
}

- (void)stopPlayer
{
    if (_player != nil)
    {
        _didPlayToEndObserver = nil;
        
        [_player removeObserver:self forKeyPath:@"rate" context:nil];
        
        [_player pause];
        _player = nil;
    }
    
    if (_videoView != nil)
    {
        [_videoView removeFromSuperview];
        _videoView = nil;
    }
    
    [_currentAudioSession setDisposable:nil];
    
    self.isPlaying = false;
    [_scrubberView setIsPlaying:false];
    [_scrubberView resetToStart];
    
    [_positionTimer invalidate];
    _positionTimer = nil;
}

- (void)preparePlayer
{
    __weak TGMediaPickerGalleryVideoItemView *weakSelf = self;
    [_currentAudioSession setDisposable:[[TGAudioSessionManager instance] requestSessionWithType:TGAudioSessionTypePlayVideo interrupted:^
    {
        TGDispatchOnMainThread(^
        {
            __strong TGMediaPickerGalleryVideoItemView *strongSelf = weakSelf;
            if (strongSelf != nil)
                [strongSelf pausePressed];
        });
    }]];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    TGMediaPickerGalleryVideoItem *item = (TGMediaPickerGalleryVideoItem *)self.item;
    
    AVPlayerItem *playerItem = nil;
    if (item.asset != nil)
        playerItem = [TGAssetImageManager playerItemForVideoAsset:item.asset];
    else if (item.avAsset != nil)
        playerItem = [AVPlayerItem playerItemWithAsset:item.avAsset];
    
    _player = [AVPlayer playerWithPlayerItem:playerItem];
    _player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    [_player addObserver:self forKeyPath:@"rate" options:NSKeyValueObservingOptionNew context:nil];
    
    _didPlayToEndObserver = [[TGObserverProxy alloc] initWithTarget:self targetSelector:@selector(playerItemDidPlayToEndTime:) name:AVPlayerItemDidPlayToEndTimeNotification object:[_player currentItem]];
    
    _videoView = [[TGModernGalleryVideoView alloc] initWithFrame:_playerView.bounds player:_player];
    _videoView.frame = _imageView.frame;
    _videoView.playerLayer.videoGravity = AVLayerVideoGravityResize;
    _videoView.playerLayer.opaque = false;
    _videoView.playerLayer.backgroundColor = nil;
    [_playerContainerView addSubview:_videoView];
    
    [self _seekToPosition:_scrubberView.value manual:false];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)__unused change context:(void *)__unused context
{
    if (object == _player && [keyPath isEqualToString:@"rate"])
    {
        if (_player.rate > FLT_EPSILON)
            [_scrubberView setIsPlaying:true];
        else
            [_scrubberView setIsPlaying:false];
    }
}

- (void)playPressed
{
    [self play];
}

- (void)play
{
    if (_player == nil)
    {
        [self preparePlayer];
        
        self.isPlaying = true;
        [_player play];
        
        _positionTimer = [TGTimerTarget scheduledMainThreadTimerWithTarget:self action:@selector(positionTimerEvent) interval:0.25 repeat:true];
        [self positionTimerEvent];
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
    [self setPlayButtonHidden:false animated:true];
    [self stop];
}

- (void)stop
{
    self.isPlaying = false;
    [_player pause];
    
    [_positionTimer invalidate];
    _positionTimer = nil;
}

- (void)togglePlayback
{
    if (self.isPlaying)
        [self pausePressed];
    else
        [self playPressed];
}

- (void)playerItemDidPlayToEndTime:(NSNotification *)__unused notification
{
    self.isPlaying = false;
    [_player pause];
    
    [self _seekToPosition:_scrubberView.trimStartValue manual:false];
    [_scrubberView resetToStart];
    
    [self setPlayButtonHidden:false animated:true];
    
    [_positionTimer invalidate];
    _positionTimer = nil;
}

- (void)positionTimerEvent
{
    [self updatePositionAndForceStartTime:false];
}

- (void)updatePositionAndForceStartTime:(bool)forceStartTime
{
    NSTimeInterval value = forceStartTime ? _scrubberView.trimStartValue : CMTimeGetSeconds(_player.currentItem.currentTime);
    [_scrubberView setValue:value];
}

- (void)_seekToPosition:(NSTimeInterval)position manual:(bool)__unused manual
{
    CMTime targetTime = CMTimeMakeWithSeconds(position, NSEC_PER_SEC);
    [self.player.currentItem seekToTime:targetTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}

#pragma mark - Video Scrubber Data Source & Delegate

#pragma mark Scrubbing

- (NSTimeInterval)videoScrubberDuration:(TGMediaPickerGalleryVideoScrubber *)__unused videoScrubber
{
    return _videoDuration;
}

- (CGFloat)videoScrubberThumbnailAspectRatio:(TGMediaPickerGalleryVideoScrubber *)__unused videoScrubber
{
    if (CGSizeEqualToSize(_videoDimensions, CGSizeZero))
        return 1.0f;
    
    return _videoDimensions.width / _videoDimensions.height;
}

- (void)videoScrubberDidBeginScrubbing:(TGMediaPickerGalleryVideoScrubber *)__unused videoScrubber
{
    if (_player == nil)
        [self preparePlayer];
    else
        _wasPlayingBeforeScrubbing = self.isPlaying;
    
    [self pausePressed];
}

- (void)videoScrubberDidEndScrubbing:(TGMediaPickerGalleryVideoScrubber *)__unused videoScrubber
{
    if (_wasPlayingBeforeScrubbing)
        [self play];
}

- (void)videoScrubber:(TGMediaPickerGalleryVideoScrubber *)__unused videoScrubber valueDidChange:(NSTimeInterval)position
{
    [self _seekToPosition:position manual:true];
}

#pragma mark Trimming

- (bool)hasTrimming
{
    return _scrubberView.hasTrimming;
}

- (CMTimeRange)trimRange
{
    return CMTimeRangeMake(CMTimeMakeWithSeconds(_scrubberView.trimStartValue , NSEC_PER_SEC), CMTimeMakeWithSeconds((_scrubberView.trimEndValue - _scrubberView.trimStartValue), NSEC_PER_SEC));
}

- (void)videoScrubberDidBeginEditing:(TGMediaPickerGalleryVideoScrubber *)__unused videoScrubber
{
    if (_player == nil)
        [self preparePlayer];
    
    [self pausePressed];
}

- (void)videoScrubberDidEndEditing:(TGMediaPickerGalleryVideoScrubber *)videoScrubber
{
    _player.currentItem.forwardPlaybackEndTime = CMTimeMakeWithSeconds(videoScrubber.trimEndValue, NSEC_PER_SEC);
    
    [self updateEditAdjusments];
}

- (void)videoScrubber:(TGMediaPickerGalleryVideoScrubber *)__unused videoScrubber editingStartValueDidChange:(NSTimeInterval)startValue
{
    [self _seekToPosition:startValue manual:true];
}

- (void)videoScrubber:(TGMediaPickerGalleryVideoScrubber *)__unused videoScrubber editingEndValueDidChange:(NSTimeInterval)endValue
{
    [self _seekToPosition:endValue manual:true];
}

#pragma mark - Edit Adjustments

- (id<TGEditablePhotoItem>)_editableMediaItem
{
    return ((TGMediaPickerGalleryVideoItem *)self.item).editableMediaItem;
}

- (void)rotate
{
    id<TGEditablePhotoItem> editableMediaItem = [self _editableMediaItem];
    TGVideoEditAdjustments *adjustments = editableMediaItem.fetchEditorValues(editableMediaItem);
    
    UIImageOrientation orientation = TGNextCCWOrientationForOrientation(adjustments.cropOrientation);
    CGSize videoFrameSize = _videoDimensions;
    CGRect cropRect = CGRectMake(0, 0, videoFrameSize.width, videoFrameSize.height);
    if (adjustments != nil)
    {
        videoFrameSize = adjustments.cropRect.size;
        cropRect = adjustments.cropRect;
    }
    
    CGFloat currentRotation = [[_playerView.layer valueForKeyPath:@"transform.rotation.z"] floatValue];
    CGFloat targetRotation = TGRotationForOrientation(orientation);
    if (fabs(currentRotation - targetRotation) > M_PI)
        targetRotation = -2 * (CGFloat)M_PI + targetRotation;
    
    CGSize containerSize = self.frame.size;
    CGFloat contentScale = [[_playerContainerView.layer valueForKeyPath:@"transform.scale.x"] floatValue];
    CGSize viewSize = _playerContainerView.bounds.size;
    if (ABS(contentScale - 1.0f) > FLT_EPSILON)
        viewSize = CGSizeMake(viewSize.width / contentScale, viewSize.height / contentScale);
    
    if (orientation == UIImageOrientationLeft || orientation == UIImageOrientationRight)
        containerSize = CGSizeMake(containerSize.height, containerSize.width);
    
    CGSize fittedSize = TGScaleToSize(videoFrameSize, containerSize);
    CGFloat sourceScale = [[_playerView.layer valueForKeyPath:@"transform.scale.x"] floatValue];
    CGFloat targetScale = fittedSize.width / viewSize.width;
    
    POPSpringAnimation *scaleAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewScaleXY];
    scaleAnimation.fromValue = [NSValue valueWithCGSize:CGSizeMake(sourceScale, sourceScale)];
    scaleAnimation.toValue = [NSValue valueWithCGSize:CGSizeMake(targetScale, targetScale)];
    scaleAnimation.springSpeed = 7;
    scaleAnimation.springBounciness = 1;
    [_playerView pop_addAnimation:scaleAnimation forKey:@"scale"];
    
    POPSpringAnimation *rotationAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerRotation];
    rotationAnimation.fromValue = @(currentRotation);
    rotationAnimation.toValue = @(targetRotation);
    rotationAnimation.springSpeed = 7;
    rotationAnimation.springBounciness = 1;
    [_playerView.layer pop_addAnimation:rotationAnimation forKey:@"rotation"];
    
    TGVideoEditAdjustments *updatedAdjustments = [TGVideoEditAdjustments editAdjustmentsWithOriginalSize:_videoDimensions cropRect:cropRect cropOrientation:orientation cropLockedAspectRatio:adjustments.cropLockedAspectRatio trimStartValue:_scrubberView.trimStartValue trimEndValue:_scrubberView.trimEndValue];
    
    [TGPhotoEditorAnimation performBlock:^(bool allFinished)
    {
        if (allFinished)
            [self _layoutPlayerViewWithCropRect:cropRect videoFrameSize:videoFrameSize orientation:orientation];
    } whenCompletedAllAnimations:@[ scaleAnimation, rotationAnimation ]];
    
    TGMediaPickerGalleryVideoItem *videoItem = (TGMediaPickerGalleryVideoItem *)self.item;
    if (videoItem.updateAdjustments != nil)
        videoItem.updateAdjustments(videoItem.editableMediaItem, updatedAdjustments);
    
    [_scrubberView reloadDataAndReset:false];
}

- (void)updateEditAdjusments
{
    TGMediaPickerGalleryVideoItem *videoItem = (TGMediaPickerGalleryVideoItem *)self.item;
    id<TGEditablePhotoItem> editableMediaItem = videoItem.editableMediaItem;
    if (editableMediaItem.fetchEditorValues != nil)
    {
        TGVideoEditAdjustments *adjustments = editableMediaItem.fetchEditorValues(editableMediaItem);
        
        if (adjustments == nil || fabs(_scrubberView.trimStartValue - adjustments.trimStartValue) > DBL_EPSILON || fabs(_scrubberView.trimEndValue - adjustments.trimEndValue) > DBL_EPSILON)
        {
            if (fabs(_scrubberView.trimStartValue - adjustments.trimStartValue) > DBL_EPSILON)
            {
                [[ATQueue concurrentDefaultQueue] dispatch:^
                {
                    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:_player.currentItem.asset];
                    generator.appliesPreferredTrackTransform = true;
                    generator.maximumSize = TGFitSize(_videoDimensions, CGSizeMake(1280.0f, 1280.0f));
                    generator.requestedTimeToleranceAfter = kCMTimeZero;
                    generator.requestedTimeToleranceBefore = kCMTimeZero;
                    CGImageRef imageRef = [generator copyCGImageAtTime:_player.currentTime actualTime:nil error:NULL];
                    UIImage *image = [UIImage imageWithCGImage:imageRef];
                    CGImageRelease(imageRef);
                    
                    CGSize thumbnailSize = TGPhotoThumbnailSizeForCurrentScreen();
                    thumbnailSize.width = CGCeil(thumbnailSize.width);
                    thumbnailSize.height = CGCeil(thumbnailSize.height);
                    
                    CGSize fillSize = TGScaleToFillSize(_videoDimensions, thumbnailSize);
                
                    UIImage *thumbnailImage = nil;
                    
                    UIGraphicsBeginImageContextWithOptions(fillSize, true, 0.0f);
                    CGContextRef context = UIGraphicsGetCurrentContext();
                    CGContextSetInterpolationQuality(context, kCGInterpolationMedium);
                    
                    [image drawInRect:CGRectMake(0, 0, fillSize.width, fillSize.height)];
                    
                    thumbnailImage = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                
                    if (videoItem.updateThumbnail != nil)
                        videoItem.updateThumbnail(editableMediaItem, image, thumbnailImage);
                }];
            }
            else if (_scrubberView.trimStartValue < DBL_EPSILON)
            {
                if (videoItem.updateThumbnail != nil)
                    videoItem.updateThumbnail(editableMediaItem, nil, nil);
            }
            
            CGRect cropRect = (adjustments != nil) ? adjustments.cropRect : CGRectMake(0, 0, _videoDimensions.width, _videoDimensions.height);
            UIImageOrientation cropOrientation = (adjustments != nil) ? adjustments.cropOrientation : UIImageOrientationUp;
            CGFloat cropLockedAspectRatio = (adjustments != nil) ? adjustments.cropLockedAspectRatio : 0.0f;
            
            TGVideoEditAdjustments *updatedAdjustments = [TGVideoEditAdjustments editAdjustmentsWithOriginalSize:_videoDimensions cropRect:cropRect cropOrientation:cropOrientation cropLockedAspectRatio:cropLockedAspectRatio trimStartValue:_scrubberView.trimStartValue trimEndValue:_scrubberView.trimEndValue];
            
            if (videoItem.updateAdjustments != nil)
                videoItem.updateAdjustments(videoItem.editableMediaItem, updatedAdjustments);
        }
    }
}

#pragma mark Thumbnails

- (NSArray *)videoScrubber:(TGMediaPickerGalleryVideoScrubber *)videoScrubber evenlySpacedTimestamps:(NSInteger)count startingAt:(NSTimeInterval)startTimestamp endingAt:(NSTimeInterval)endTimestamp
{
    if (endTimestamp < startTimestamp)
        return nil;
    
    if (count == 0)
        return nil;

    NSTimeInterval duration = [self videoScrubberDuration:videoScrubber];
    if (endTimestamp > duration)
        endTimestamp = duration;
    
    NSTimeInterval interval = (endTimestamp - startTimestamp) / count;
    
    NSMutableArray *timestamps = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < count; i++)
        [timestamps addObject:@(startTimestamp + i * interval)];
    
    return timestamps;
}

- (void)videoScrubber:(TGMediaPickerGalleryVideoScrubber *)videoScrubber requestThumbnailImagesForTimestamps:(NSArray *)timestamps size:(CGSize)size isSummaryThumbnails:(bool)isSummaryThumbnails
{
    if (timestamps.count == 0)
        return;
    
    TGMediaPickerGalleryVideoItem *videoItem = (TGMediaPickerGalleryVideoItem *)self.item;
    
    void(^completionBlock)(NSArray *, bool) = ^(NSArray *images, bool cancelled)
    {
        if (cancelled)
            return;
        
        TGDispatchOnMainThread(^
        {
            [images enumerateObjectsUsingBlock:^(UIImage *image, NSUInteger index, __unused BOOL *stop)
            {
                if (index < timestamps.count)
                    [videoScrubber setThumbnailImage:image forTimestamp:[timestamps[index] doubleValue] isSummaryThubmnail:isSummaryThumbnails];
            }];
        });
    };
    
    if (videoItem.asset != nil)
        _thumbnailsCancelToken = [TGAssetImageManager requestVideoThumbnailsForAsset:videoItem.asset size:size timestamps:timestamps completion:completionBlock];
    else if (videoItem.avAsset != nil)
        _thumbnailsCancelToken = [TGAssetImageManager requestVideoThumbnailsForAVAsset:videoItem.avAsset size:size timestamps:timestamps completion:completionBlock];
}

- (void)videoScrubberDidFinishRequestingThumbnails:(TGMediaPickerGalleryVideoScrubber *)__unused videoScrubber
{
    _thumbnailsCancelToken = nil;
    
    [self presentScrubbingPanel];
}

- (void)videoScrubberDidCancelRequestingThumbnails:(TGMediaPickerGalleryVideoScrubber *)__unused videoScrubber
{
    _thumbnailsCancelToken.cancelled = true;
    _thumbnailsCancelToken = nil;
}

- (CGSize)videoScrubberOriginalSize:(TGMediaPickerGalleryVideoScrubber *)__unused videoScrubber cropRect:(CGRect *)cropRect cropOrientation:(UIImageOrientation *)cropOrientation
{
    id<TGEditablePhotoItem> editableMediaItem = [self _editableMediaItem];
    TGVideoEditAdjustments *adjustments = nil;
    if (editableMediaItem.fetchEditorValues != nil)
        adjustments = editableMediaItem.fetchEditorValues(editableMediaItem);
    
    if (cropRect != NULL)
        *cropRect = (adjustments != nil) ? adjustments.cropRect : CGRectMake(0, 0, _videoDimensions.width, _videoDimensions.height);
    
    if (cropOrientation != NULL)
        *cropOrientation = (adjustments != nil) ? adjustments.cropOrientation : UIImageOrientationUp;
    
    return _videoDimensions;
}

@end
