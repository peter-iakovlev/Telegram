#import "TGVideoPreviewController.h"

#import <objc/runtime.h>

#import "TGVideoConverter.h"

#import "TGProgressWindow.h"

#import <AVFoundation/AVFoundation.h>

#import <pop/POP.h>

#import "TGMediaPickerAsset.h"
#import "TGAssetImageView.h"
#import "TGAssetImageManager.h"

#import "TGObserverProxy.h"
#import "TGModernButton.h"

#import "TGFont.h"

#import "TGHacks.h"

#import "TGVideoPreviewView.h"
#import "TGActionSheet.h"
#import "TGMessageImageViewOverlayView.h"

#import "TGImageBlur.h"
#import "TGImageUtils.h"

#import "TGFullscreenContainerView.h"

#import "TGVibrantActionSheet.h"

#import "TGImageDownloadActor.h"

#import <AssetsLibrary/AssetsLibrary.h>
#import <CommonCrypto/CommonDigest.h>

#import "TGAudioSessionManager.h"

@interface TGVideoPreviewController ()
{
    NSURL *_assetUrl;
    AVURLAsset *_urlAsset;
    UIImage *_thumbnailImage;
    bool _enableServerAssetCache;
    
    CGAffineTransform _videoTransform;
    TGAssetImageView *_thumbnailView;
    
    UIView *_panelView;
    TGModernButton *_cancelButton;
    TGModernButton *_sendButton;
    TGModernButton *_playPauseButton;
    
    AVPlayer *_player;
    AVPlayerLayer *_playerLayer;
    TGVideoPreviewView *_playerView;
    
    UIView *_progressContainer;
    TGModernButton *_progressButton;
    TGMessageImageViewOverlayView *_progressView;
    
    TGVideoConverter *_converter;
    float _progress;
    
    bool _isPlaying;
    
    TGObserverProxy *_pauseProxy;
    
    UIView *_snapshotView;
    UIView *_snapshotDimmingView;
    
    NSString *_cachedVideoAssetIdForHD;
    NSString *_cachedVideoAssetIdForSD;
    
    SMetaDisposable *_currentAudioSession;
}

@end

@implementation TGVideoPreviewController

- (instancetype)initWithAsset:(TGMediaPickerAsset *)asset enableServerAssetCache:(bool)enableServerAssetCache
{
    self = [super init];
    if (self != nil)
    {
        _currentAudioSession = [[SMetaDisposable alloc] init];
        
        _asset = asset;
        _enableServerAssetCache = enableServerAssetCache;
        
        self.navigationBarShouldBeHidden = true;
        
        [self setTitleText:TGLocalized(@"Message.Video")];
        
        [self setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"MediaPicker.Send") style:UIBarButtonItemStyleDone target:self action:@selector(sendPressed)]];
    }
    return self;
}

- (instancetype)initWithItemAtURL:(NSURL *)url thumbnailImage:(UIImage *)thumbnailImage videoTransform:(CGAffineTransform)videoTransform enableServerAssetCached:(bool)enableServerAssetCache
{
    self = [super init];
    if (self != nil)
    {
        _currentAudioSession = [[SMetaDisposable alloc] init];
        
        _assetUrl = url;
        _thumbnailImage = thumbnailImage;
        _videoTransform = videoTransform;
        _enableServerAssetCache = enableServerAssetCache;
        
        self.navigationBarShouldBeHidden = true;
    }
    return self;
}

- (void)dealloc
{
    AVPlayerLayer *playerLayer = _playerLayer;
    [_currentAudioSession dispose];
    
    TGDispatchOnMainThread(^
    {
        if (playerLayer != nil)
        {
            [playerLayer removeFromSuperlayer];
            [playerLayer.player pause];
        }
    });
}

- (BOOL)shouldAutorotate
{
    return [super shouldAutorotate] && _converter == nil && _snapshotDimmingView == nil;
}

- (void)transitionInAnimated:(bool)animated completion:(void (^)(void))completion
{
    if (animated)
    {
        self.view.alpha = 0.0f;
        
        [UIView animateWithDuration:0.3f delay:0.1f options:UIViewAnimationOptionCurveLinear animations:^
        {
            self.view.alpha = 1.0f;
        } completion:^(__unused BOOL finished)
        {
            if (completion != nil)
                completion();
        }];
    }
}

- (void)transitionOutAnimated:(bool)animated
{
    if (animated)
    {
        [UIView animateWithDuration:0.3f delay:0.1f options:UIViewAnimationOptionCurveLinear animations:^
        {
            self.view.alpha = 0.0f;
        } completion:^(__unused BOOL finished)
        {
            [self dismiss];
        }];
    }
    else
    {
        [self dismiss];
    }
}

- (UIImage *)playImage
{
    static UIImage *image = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(23.0f, 23.0f), false, 0.0f);
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGContextBeginPath(context);
        
        CGContextMoveToPoint(context, 3.0f, 0.0f);
        CGContextAddLineToPoint(context, 23.5f, 11.25f);
        CGContextAddLineToPoint(context, 3.0f, 22.5f);
        CGContextClosePath(context);
        
        CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
        CGContextFillPath(context);
        
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    });
    
    return image;
}

- (UIImage *)pauseImage
{
    static UIImage *image = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(21.0f, 23.0f), false, 0.0f);
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGFloat width = 4.0f;
        CGFloat spacing = 6.0f;
        
        CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
        CGContextFillRect(context, CGRectMake(CGFloor((21.0f - spacing - width * 2.0f) / 2.0f), 0.0f, width, 22.5f));
        CGContextFillRect(context, CGRectMake(CGFloor((21.0f - spacing - width * 2.0f) / 2.0f) + width + spacing, 0.0f, width, 22.5f));
        
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    });
    
    return image;
}

- (void)loadView
{
    [super loadView];
    
    if (_assetUrl != nil)
        object_setClass(self.view, [TGFullscreenContainerView class]);
    
    self.view.backgroundColor = [UIColor blackColor];
    
    _thumbnailView = [[TGAssetImageView alloc] init];
    _thumbnailView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    if (_assetUrl != nil)
        _thumbnailView.transform = CGAffineTransformRotate(_videoTransform, (CGFloat)-M_PI_2);
    _thumbnailView.frame = self.view.bounds;
    _thumbnailView.contentMode = UIViewContentModeScaleAspectFit;
    if (_thumbnailImage != nil)
        [_thumbnailView loadWithImage:_thumbnailImage];
    else if (_asset != nil)
        [_thumbnailView loadWithAsset:_asset imageType:TGAssetImageTypeAspectRatioThumbnail size:CGSizeMake(138, 138)];
    [self.view addSubview:_thumbnailView];
    
    _panelView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, self.view.frame.size.height - 72.0f, self.view.frame.size.width, 72.0f)];
    _panelView.backgroundColor = UIColorRGBA(0x000000, 0.6f);
    _panelView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:_panelView];
    
    _cancelButton = [[TGModernButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 100.0f, 72.0f)];
    _cancelButton.exclusiveTouch = true;
    _cancelButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    if (_assetUrl != nil)
        [_cancelButton setTitle:TGLocalized(@"Camera.Retake") forState:UIControlStateNormal];
    else
        [_cancelButton setTitle:TGLocalized(@"Common.Cancel") forState:UIControlStateNormal];
    [_cancelButton setTitleColor:[UIColor whiteColor]];
    _cancelButton.titleLabel.font = TGSystemFontOfSize(18.0f);
    [_cancelButton addTarget:self action:@selector(cancelPressed) forControlEvents:UIControlEventTouchUpInside];
    [_cancelButton setContentEdgeInsets:UIEdgeInsetsMake(0.0f, 20.0f, 0.0f, 0.0f)];
    [_panelView addSubview:_cancelButton];
    
    _sendButton = [[TGModernButton alloc] initWithFrame:CGRectMake(_panelView.frame.size.width - 100.0f, 0.0f, 100.0f, 72.0f)];
    _sendButton.exclusiveTouch = true;
    _sendButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [_sendButton setTitle:TGLocalized(@"MediaPicker.Send") forState:UIControlStateNormal];
    [_sendButton setTitleColor:[UIColor whiteColor]];
    _sendButton.titleLabel.font = TGSystemFontOfSize(18.0f);
    _sendButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [_sendButton addTarget:self action:@selector(sendPressed) forControlEvents:UIControlEventTouchUpInside];
    [_sendButton setContentEdgeInsets:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 20.0f)];
    [_panelView addSubview:_sendButton];
    
    _playPauseButton = [[TGModernButton alloc] initWithFrame:CGRectMake(CGFloor((_panelView.frame.size.width - 100.0f) / 2.0f), 0.0f, 100.0f, 72.0f)];
    _playPauseButton.exclusiveTouch = true;
    [_playPauseButton setImage:[self playImage] forState:UIControlStateNormal];
    _playPauseButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [_playPauseButton addTarget:self action:@selector(playPausePressed) forControlEvents:UIControlEventTouchUpInside];
    [_panelView addSubview:_playPauseButton];
    
    _progressContainer = [[UIView alloc] initWithFrame:self.view.bounds];
    _progressContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_progressContainer];
    
    CGFloat diameter = 50.0f;
    
    _progressButton = [[TGModernButton alloc] initWithFrame:CGRectMake(CGFloor((_progressContainer.frame.size.width - diameter) / 2.0f), CGFloor((_progressContainer.frame.size.height - diameter) / 2.0f), diameter, diameter)];
    _progressButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    _progressButton.exclusiveTouch = true;
    _progressButton.modernHighlight = true;
    [_progressButton addTarget:self action:@selector(progressCancelPressed) forControlEvents:UIControlEventTouchUpInside];
    [_progressContainer addSubview:_progressButton];
    
    static UIImage *highlightImage = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(diameter, diameter), false, 0.0f);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, UIColorRGBA(0x000000, 0.4f).CGColor);
        CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, diameter, diameter));
        highlightImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    });
    
    _progressButton.highlightImage = highlightImage;
    
    _progressView = [[TGMessageImageViewOverlayView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, diameter, diameter)];
    _progressView.userInteractionEnabled = false;
    
    [_progressButton addSubview:_progressView];
    
    _progressContainer.alpha = 0.0f;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [UIView animateWithDuration:0.3 animations:^
    {
        [TGHacks setApplicationStatusBarAlpha:0.0f];
    }];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (_playerLayer == nil)
    {
        if (_asset != nil)
        {
            _player = [[AVPlayer alloc] initWithPlayerItem:[TGAssetImageManager playerItemForVideoAsset:_asset]];
        }
        else if (_assetUrl != nil)
        {
            _urlAsset = [AVURLAsset URLAssetWithURL:_assetUrl options:nil];
            _player = [[AVPlayer alloc] initWithPlayerItem:[AVPlayerItem playerItemWithAsset:_urlAsset]];
        }
        
        _player.actionAtItemEnd = AVPlayerActionAtItemEndPause;
        _pauseProxy = [[TGObserverProxy alloc] initWithTarget:self targetSelector:@selector(playerItemDidPlayToEndTime:) name:AVPlayerItemDidPlayToEndTimeNotification object:[_player currentItem]];
        
        _playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
        _playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
        _playerLayer.frame = self.view.bounds;
        
        _playerView = [[TGVideoPreviewView alloc] initWithFrame:self.view.bounds];
        [_playerView.layer addSublayer:_playerLayer];
        _playerView.videoLayer = _playerLayer;
        _playerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.view insertSubview:_playerView aboveSubview:_thumbnailView];
        
        _isPlaying = false;
        [_playPauseButton setImage:[self playImage] forState:UIControlStateNormal];

        _playerLayer.opacity = 0.0f;
        TGDispatchAfter(0.25f, dispatch_get_main_queue(), ^
        {
            _playerLayer.opacity = 1.0f;
        });
        
        TGDispatchAfter(1.0f, dispatch_get_main_queue(), ^
        {
            _thumbnailView.hidden = true;
        });
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [_playerLayer.player pause];
    
    if (_converter != nil)
    {
        [_converter cancel];
        _converter = nil;
    }
    
    if (!self.fromCamera)
    {
        [UIView animateWithDuration:0.3 animations:^
        {
            [TGHacks setApplicationStatusBarAlpha:1.0f];
        }];
    }
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)cancelPressed
{
    if (self.dismissBlock != nil)
        self.dismissBlock(true);
}

- (NSString *)formatFileSize:(NSUInteger)fileSize
{
    if (fileSize < 1024 * 1024)
        return [[NSString alloc] initWithFormat:TGLocalized(@"Conversation.Kilobytes"), (int)fileSize / 1024];
    
    return [[NSString alloc] initWithFormat:TGLocalized(@"Conversation.Megabytes"), fileSize / (1024.0 * 1024.0)];
}

- (void)computeVideoAssetId:(void (^)(NSString *))completion highDefinition:(bool)highDefinition
{
    if (highDefinition && _cachedVideoAssetIdForHD != nil)
    {
        completion(_cachedVideoAssetIdForHD);
    }
    else if (!highDefinition && _cachedVideoAssetIdForSD != nil)
    {
        completion(_cachedVideoAssetIdForSD);
    }
    else
    {
        CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
        NSString *(^readAssetWithURL)(NSURL *, NSData *) = ^NSString *(NSURL *url, NSData *timingData)
        {
            if (url == nil)
                return nil;
            
            NSError *error;
            NSData *fileData = [NSData dataWithContentsOfURL:url
                                                     options:NSDataReadingMappedIfSafe
                                                       error:&error];
            if (error != nil)
                return nil;
            
            return [self hashForVideoWithSize:fileData.length
                               highDefinition:highDefinition
                                   timingData:timingData
                                dataReadBlock:^(uint8_t *buffer, NSUInteger offset, NSUInteger length)
            {
                [fileData getBytes:buffer range:NSMakeRange(offset, length)];
            }];
        };
        
        NSString *hash = nil;
        if (_urlAsset != nil)
        {
            hash = readAssetWithURL(_urlAsset.URL, nil);
        }
        else if (_asset.backingAsset != nil)
        {
            AVAsset *asset = _player.currentItem.asset;
            if ([asset isKindOfClass:[AVURLAsset class]])
            {
                AVURLAsset *urlAsset = (AVURLAsset *)_player.currentItem.asset;
                
                hash = readAssetWithURL(urlAsset.URL, nil);
            }
            else if ([asset isKindOfClass:[AVComposition class]])
            {
                AVComposition *composition = (AVComposition *)asset;
                AVCompositionTrack *videoTrack = nil;
                for (AVCompositionTrack *track in composition.tracks)
                {
                    if ([track.mediaType isEqualToString:AVMediaTypeVideo])
                    {
                        videoTrack = track;
                        break;
                    }
                }
                
                if (videoTrack != nil)
                {
                    AVCompositionTrackSegment *firstSegment = videoTrack.segments.firstObject;
                    
                    NSMutableData *timingData = [[NSMutableData alloc] init];
                    for (AVCompositionTrackSegment *segment in videoTrack.segments)
                    {
                        CMTimeRange targetRange = segment.timeMapping.target;
                        CMTimeValue startTime = targetRange.start.value / targetRange.start.timescale;
                        CMTimeValue duration = targetRange.duration.value / targetRange.duration.timescale;
                        [timingData appendBytes:&startTime length:sizeof(startTime)];
                        [timingData appendBytes:&duration length:sizeof(duration)];
                    }
                    
                    hash = readAssetWithURL(firstSegment.sourceURL, timingData);
                }
            }
        }
        else if (_asset.backingLegacyAsset != nil)
        {
            ALAsset *asset = _asset.backingLegacyAsset;
            ALAssetRepresentation *representation = asset.defaultRepresentation;
            
            hash = [self hashForVideoWithSize:(NSUInteger)representation.size
                               highDefinition:highDefinition
                                   timingData:nil
                                dataReadBlock:^(uint8_t *buffer, NSUInteger offset, NSUInteger length)
            {
                [representation getBytes:buffer fromOffset:offset length:length error:nil];
            }];
        }
        
        if (hash != nil)
        {
            TGLog(@"Computed video hash in %f ms", (CFAbsoluteTimeGetCurrent() - startTime) * 1000.0);
            
            if (highDefinition)
                _cachedVideoAssetIdForHD = hash;
            else
                _cachedVideoAssetIdForSD = hash;
            
            if (completion != nil)
                completion(hash);
        }
        else {
            if (completion != nil)
                completion(nil);
        }
    }
}

- (NSString *)hashForVideoWithSize:(NSUInteger)size highDefinition:(BOOL)highDefinition timingData:(NSData *)timingData dataReadBlock:(void (^)(uint8_t *buffer, NSUInteger offset, NSUInteger length))dataReadBlock
{
    const NSUInteger bufSize = 1024;
    const NSUInteger numberOfBuffersToRead = 32;
    uint8_t buf[bufSize];
    
    CC_MD5_CTX md5;
    CC_MD5_Init(&md5);
    
    CC_MD5_Update(&md5, &size, sizeof(size));
    const char *SDString = "SD";
    const char *HDString = "HD";
    if (highDefinition)
        CC_MD5_Update(&md5, HDString, (CC_LONG)strlen(HDString));
    else
        CC_MD5_Update(&md5, SDString, (CC_LONG)strlen(SDString));
    
    if (timingData != nil)
        CC_MD5_Update(&md5, timingData.bytes, (CC_LONG)timingData.length);
    
    for (NSUInteger i = 0; (i < size) && (i < bufSize * numberOfBuffersToRead); i += bufSize)
    {
        dataReadBlock(buf, i, bufSize);
        CC_MD5_Update(&md5, buf, bufSize);
    }
    
    for (NSUInteger i = size - MIN(size, bufSize * numberOfBuffersToRead); i < size; i += bufSize)
    {
        dataReadBlock(buf, i, bufSize);
        CC_MD5_Update(&md5, buf, bufSize);
    }
    
    unsigned char md5Buffer[16];
    CC_MD5_Final(md5Buffer, &md5);
    NSString *hash = [[NSString alloc] initWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x", md5Buffer[0], md5Buffer[1], md5Buffer[2], md5Buffer[3], md5Buffer[4], md5Buffer[5], md5Buffer[6], md5Buffer[7], md5Buffer[8], md5Buffer[9], md5Buffer[10], md5Buffer[11], md5Buffer[12], md5Buffer[13], md5Buffer[14], md5Buffer[15]];

    return hash;
}

- (void)sendPressed
{
    _isPlaying = false;
    [_player pause];
    [_playPauseButton setImage:[self playImage] forState:UIControlStateNormal];

    if (self.fromCamera)
    {
        void (^sendBlock)(void) = ^
        {
            AVAssetTrack *track = [[_urlAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
            
            CGSize trackNaturalSize = track.naturalSize;
            CGSize naturalSize = CGRectApplyAffineTransform(CGRectMake(0, 0, trackNaturalSize.width, trackNaturalSize.height), track.preferredTransform).size;
            
            NSTimeInterval duration = CMTimeGetSeconds(_urlAsset.duration);
            
            if (self.videoPicked != nil)
                self.videoPicked(_cachedVideoAssetIdForSD, _assetUrl.path, naturalSize, duration, _thumbnailView.image, nil);
        };
        
        if (_enableServerAssetCache)
        {
            [self computeVideoAssetId:^(NSString *videoAssetId)
            {
                if ([TGImageDownloadActor serverMediaDataForAssetUrl:videoAssetId] != nil)
                {
                    if (_videoPicked != nil)
                        _videoPicked(videoAssetId, nil, CGSizeZero, 0.0, nil, nil);
                }
                else
                {
                    sendBlock();
                }
            } highDefinition:false];
        }
        else
        {
            sendBlock();
        }
    }
    else
    {
        [self convertAndSend];
    }
}

- (void)convertAndSend
{
    if (_converter != nil)
        return;
    
    UIImage *image = nil;
    
    [_snapshotView removeFromSuperview];
    [_snapshotDimmingView removeFromSuperview];
    
    _snapshotView = [[UIImageView alloc] initWithImage:image];
    _snapshotView.contentMode = UIViewContentModeScaleAspectFit;
    _snapshotView.frame = _playerView.frame;
    [self.view insertSubview:_snapshotView aboveSubview:_playerView];
    
    _snapshotDimmingView = [[UIView alloc] initWithFrame:self.view.bounds];
    _snapshotDimmingView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _snapshotDimmingView.backgroundColor = UIColorRGBA(0x000000, 0.7f);
    [self.view insertSubview:_snapshotDimmingView aboveSubview:_snapshotView];
    
    [_progressView setProgress:0.0f animated:false];
    
    _snapshotView.alpha = 0.0f;
    _snapshotDimmingView.alpha = 0.0f;
    [UIView animateWithDuration:0.2 delay:0.0 options:[TGViewController preferredAnimationCurve] << 16 animations:^
     {
         _snapshotView.alpha = 1.0f;
         _snapshotDimmingView.alpha = 1.0f;
         
         _panelView.frame = CGRectMake(0.0f, self.view.frame.size.height, self.view.frame.size.width, _panelView.frame.size.height);
     } completion:nil];
    
    NSUInteger sizeSD = (NSUInteger)(_asset.videoDuration * 1024 * 1024 / 10);
    
    [self commitSend:false expectedFileSize:sizeSD];
}

- (void)commitSend:(bool)highDefinition expectedFileSize:(NSUInteger)expectedFileSize
{
    [_playerLayer.player pause];
    
    dispatch_block_t convertBlock = ^
    {
        [UIView animateWithDuration:0.2 delay:0.0 options:[TGViewController preferredAnimationCurve] << 16 animations:^
        {
            _progressContainer.alpha = 1.0f;
        } completion:nil];
        
        bool enableLiveUpload = false;
    #ifdef INTERNAL_RELEASE
        enableLiveUpload = true;
    #endif
        
        __weak TGVideoPreviewController *weakSelf = self;
        _converter = [[TGVideoConverter alloc] initForConvertationWithAsset:_asset liveUpload:enableLiveUpload && _liveUpload && expectedFileSize < 20 * 1024 * 1024 highDefinition:highDefinition];
        [_converter processWithCompletion:^(NSString *tempFilePath, CGSize dimensions, NSTimeInterval duration, __unused UIImage *previewImage, TGLiveUploadActorData *liveUploadData)
        {
            if (tempFilePath != nil)
            {
                __strong TGVideoPreviewController *strongSelf = weakSelf;
                [strongSelf videoConversionCompleted:tempFilePath dimensions:dimensions duration:duration liveUploadData:liveUploadData highDefinition:highDefinition];
            }
        } progress:^(float progress)
        {
            TGDispatchOnMainThread(^
            {
                __strong TGVideoPreviewController *strongSelf = weakSelf;
                [strongSelf updateProgress:progress];
            });
        }];
    };
    
    if (_enableServerAssetCache)
    {
        [self computeVideoAssetId:^(NSString *videoAssetId)
        {
            if ([TGImageDownloadActor serverMediaDataForAssetUrl:videoAssetId] != nil)
            {
                if (_videoPicked != nil)
                    _videoPicked(videoAssetId, nil, CGSizeZero, 0.0, nil, nil);
            }
            else
                convertBlock();
        } highDefinition:highDefinition];
    }
    else
    {
        convertBlock();
    }
}

- (void)updateProgress:(float)progress
{
    _progress = progress;
    [_progressView setProgress:progress animated:true];
}

- (void)videoConversionCompleted:(NSString *)tempFilePath dimensions:(CGSize)dimensions duration:(NSTimeInterval)duration liveUploadData:(TGLiveUploadActorData *)liveUploadData highDefinition:(bool)highDefinition
{
    TGDispatchOnMainThread(^
    {
        _converter = nil;
   
        if (_videoPicked != nil)
            _videoPicked(highDefinition ? _cachedVideoAssetIdForHD : _cachedVideoAssetIdForSD, tempFilePath, dimensions, duration, _thumbnailView.image, liveUploadData);
    });
}

- (void)playPausePressed
{
    if (_isPlaying)
    {
        _isPlaying = false;
        [_player pause];
        [_playPauseButton setImage:[self playImage] forState:UIControlStateNormal];
    }
    else
    {
        __weak TGVideoPreviewController *weakSelf = self;
        [_currentAudioSession setDisposable:[[TGAudioSessionManager instance] requestSessionWithType:TGAudioSessionTypePlayVideo interrupted:^
        {
            TGDispatchOnMainThread(^
            {
                __strong TGVideoPreviewController *strongSelf = weakSelf;
                if (strongSelf != nil)
                    [strongSelf->_player pause];
            });
        }]];
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
        
        _isPlaying = true;
        [_player play];
        [_playPauseButton setImage:[self pauseImage] forState:UIControlStateNormal];
    }
}

- (void)playerItemDidPlayToEndTime:(NSNotification *)notification
{
    AVPlayerItem *item = [notification object];
    [item seekToTime:kCMTimeZero];
    
    _isPlaying = false;
    [_player pause];
    [_playPauseButton setImage:[self playImage] forState:UIControlStateNormal];
}

- (void)progressCancelPressed
{
    if (_converter != nil)
    {
        [_converter cancel];
        _converter = nil;
    }
    
    UIView *snapshotView = _snapshotView;
    _snapshotView = nil;
    UIView *snapshotDimmingView = _snapshotDimmingView;
    _snapshotDimmingView = nil;
    [UIView animateWithDuration:0.3 delay:0.0 options:[TGViewController preferredAnimationCurve] << 16 animations:^
    {
        snapshotView.alpha = 0.0f;
        snapshotDimmingView.alpha = 0.0f;
        _progressContainer.alpha = 0.0f;
        
        _panelView.frame = CGRectMake(0.0f, self.view.frame.size.height - _panelView.frame.size.height, self.view.frame.size.width, _panelView.frame.size.height);
    } completion:^(__unused BOOL finished)
    {
        [snapshotView removeFromSuperview];
        [snapshotDimmingView removeFromSuperview];
    }];
}

- (void)dismissAnimated:(bool)animated
{
    [self progressCancelPressed];
    
    if (self.dismissBlock != nil)
        self.dismissBlock(animated);
}

@end
