#import "TGVideoPreviewController.h"

#import "TGVideoConverter.h"

#import "TGProgressWindow.h"

#import <AVFoundation/AVFoundation.h>

#import <pop/POP.h>

#import "TGObserverProxy.h"
#import "TGModernButton.h"

#import "TGFont.h"

#import "TGHacks.h"

#import "TGVideoPreviewView.h"
#import "TGActionSheet.h"
#import "TGMessageImageViewOverlayView.h"

#import "TGImageBlur.h"
#import "TGImageUtils.h"

#import "TGVibrantActionSheet.h"

#import "TGImageDownloadActor.h"

#import <AssetsLibrary/AssetsLibrary.h>
#import <CommonCrypto/CommonDigest.h>

@interface TGVideoPreviewController ()
{
    NSURL *_assetUrl;
    UIImage *_thumbnail;
    NSTimeInterval _duration;
    bool _enableServerAssetCache;
    
    UIImageView *_thumbnailView;
    
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
}

@end

@implementation TGVideoPreviewController

- (instancetype)initWithAssetUrl:(NSURL *)assetUrl thumbnail:(UIImage *)thumbnail duration:(NSTimeInterval)duration enableServerAssetCache:(bool)enableServerAssetCache
{
    self = [super init];
    if (self != nil)
    {
        _assetUrl = assetUrl;
        _thumbnail = thumbnail;
        _duration = duration;
        _enableServerAssetCache = enableServerAssetCache;
        
        self.navigationBarShouldBeHidden = true;
        
        [self setTitleText:TGLocalized(@"Message.Video")];
        
        [self setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"MediaPicker.Send") style:UIBarButtonItemStyleDone target:self action:@selector(sendPressed)]];
    }
    return self;
}

- (void)dealloc
{
    TGDispatchOnMainThread(^
    {
        if (_playerLayer != nil)
        {
            [_playerLayer removeFromSuperlayer];
            [_playerLayer.player pause];
        }
    });
}

- (BOOL)shouldAutorotate
{
    return [super shouldAutorotate] && _converter == nil && _snapshotDimmingView == nil;
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
    
    self.view.backgroundColor = [UIColor blackColor];
    
    _thumbnailView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    _thumbnailView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _thumbnailView.contentMode = UIViewContentModeScaleAspectFit;
    _thumbnailView.image = _thumbnail;
    [self.view addSubview:_thumbnailView];
    
    _panelView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, self.view.frame.size.height - 72.0f, self.view.frame.size.width, 72.0f)];
    _panelView.backgroundColor = UIColorRGBA(0x000000, 0.6f);
    _panelView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:_panelView];
    
    _cancelButton = [[TGModernButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 100.0f, 72.0f)];
    _cancelButton.exclusiveTouch = true;
    _cancelButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
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
        _player = [[AVPlayer alloc] initWithURL:_assetUrl];
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
        TGDispatchAfter(0.2, dispatch_get_main_queue(), ^
        {
            _playerLayer.opacity = 1.0f;
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
    
    [UIView animateWithDuration:0.3 animations:^
    {
        [TGHacks setApplicationStatusBarAlpha:1.0f];
    }];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)cancelPressed
{
    [self.navigationController popViewControllerAnimated:true];
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
        completion(_cachedVideoAssetIdForHD);
    else if (!highDefinition && _cachedVideoAssetIdForSD != nil)
        completion(_cachedVideoAssetIdForSD);
    else
    {
        CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
        __block __volatile bool enableInteraction = true;
        
        self.view.userInteractionEnabled = false;
        TGDispatchAfter(2.0, dispatch_get_main_queue(), ^
        {
            if (enableInteraction)
            {
                enableInteraction = false;
                self.view.userInteractionEnabled = true;
            }
        });
        
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        [library assetForURL:_assetUrl resultBlock:^(ALAsset *asset)
        {
            TGDispatchOnMainThread(^
            {
                if (enableInteraction)
                {
                    enableInteraction = false;
                    self.view.userInteractionEnabled = true;
                }
                
                ALAssetRepresentation *representation = asset.defaultRepresentation;
                NSUInteger size = (NSUInteger)representation.size;
                const NSUInteger bufSize = 1024;
                const NSUInteger numberOfBuffersToRead = 32;
                uint8_t buf[bufSize];
                
                CC_MD5_CTX md5;
                CC_MD5_Init(&md5);
                
                CC_MD5_Update(&md5, &size, sizeof(size));
                const char *SDString = "SD";
                const char *HDString = "HD";
                if (highDefinition)
                    CC_MD5_Update(&md5, HDString, strlen(HDString));
                else
                    CC_MD5_Update(&md5, SDString, strlen(SDString));
                
                for (NSUInteger i = 0; (i < size) && (i < bufSize * numberOfBuffersToRead); i += bufSize)
                {
                    NSUInteger returnedBytes = [representation getBytes:buf fromOffset:i length:bufSize error:nil];
                    CC_MD5_Update(&md5, buf, returnedBytes);
                }
                
                for (NSUInteger i = size - MIN(size, bufSize * numberOfBuffersToRead); i < size; i += bufSize)
                {
                    NSUInteger returnedBytes = [representation getBytes:buf fromOffset:i length:bufSize error:nil];
                    CC_MD5_Update(&md5, buf, returnedBytes);
                }
                
                unsigned char md5Buffer[16];
                CC_MD5_Final(md5Buffer, &md5);
                NSString *hash = [[NSString alloc] initWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x", md5Buffer[0], md5Buffer[1], md5Buffer[2], md5Buffer[3], md5Buffer[4], md5Buffer[5], md5Buffer[6], md5Buffer[7], md5Buffer[8], md5Buffer[9], md5Buffer[10], md5Buffer[11], md5Buffer[12], md5Buffer[13], md5Buffer[14], md5Buffer[15]];
                
                TGLog(@"Computed video hash in %f ms", (CFAbsoluteTimeGetCurrent() - startTime) * 1000.0);
                
                if (highDefinition)
                    _cachedVideoAssetIdForHD = hash;
                else
                    _cachedVideoAssetIdForSD = hash;
                
                if (completion != nil)
                    completion(hash);
            });
        } failureBlock:^(__unused NSError *error)
        {
            TGDispatchOnMainThread(^
            {
                if (enableInteraction)
                {
                    enableInteraction = false;
                    self.view.userInteractionEnabled = true;
                }
                
                if (completion != nil)
                    completion(nil);
            });
        }];
    }
}

- (void)sendPressed
{
    if (_converter != nil)
        return;
    
    _isPlaying = false;
    [_player pause];
    [_playPauseButton setImage:[self playImage] forState:UIControlStateNormal];
    
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
    
    NSUInteger sizeSD = (NSUInteger)(_duration * 1024 * 1024 / 10);
    //NSUInteger sizeHD = (NSUInteger)(_duration * 1024 * 1024 / 5.4);
    
    [self commitSend:false expectedFielSize:sizeSD];
    
    /*__weak TGVideoPreviewController *weakSelf = self;
    [[[TGVibrantActionSheet alloc] initWithTitle:TGLocalized(@"VideoPreview.QualityOptionTitle") actions:@[
                                                                                                           [[TGVibrantActionSheetAction alloc] initWithTitle:[[NSString alloc] initWithFormat:TGLocalized(@"VideoPreview.OptionSD"), [self formatFileSize:sizeSD]] action:@"sendSD"],
                                                                                                           [[TGVibrantActionSheetAction alloc] initWithTitle:[[NSString alloc] initWithFormat:TGLocalized(@"VideoPreview.OptionHD"), [self formatFileSize:sizeHD]] action:@"sendHD"],
                                                                                                           [[TGVibrantActionSheetAction alloc] initWithTitle:TGLocalized(@"Common.Cancel") action:@"cancel"]
                                                                                                           ] actionActivated:^(NSString *action)
    {
        __strong TGVideoPreviewController *strongSelf = weakSelf;
        if ([action isEqualToString:@"sendSD"])
            [strongSelf commitSend:false expectedFielSize:sizeSD];
        else if ([action isEqualToString:@"sendHD"])
            [strongSelf commitSend:true expectedFielSize:sizeHD];
        else if ([action isEqualToString:@"cancel"])
            [strongSelf progressCancelPressed];
    }] showInView:self.view];*/
}

- (void)commitSend:(bool)highDefinition expectedFielSize:(NSUInteger)expectedFileSize
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
        _converter = [[TGVideoConverter alloc] initWithAssetUrl:_assetUrl liveUpload:enableLiveUpload && _liveUpload && expectedFileSize < 20 * 1024 * 1024 highDefinition:highDefinition];
        [_converter convertWithCompletion:^(NSString *tempFilePath, CGSize dimensions, NSTimeInterval duration, TGLiveUploadActorData *liveUploadData)
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
        convertBlock();
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
            _videoPicked(highDefinition ? _cachedVideoAssetIdForHD : _cachedVideoAssetIdForSD, tempFilePath, dimensions, duration, _thumbnail, liveUploadData);
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

@end
