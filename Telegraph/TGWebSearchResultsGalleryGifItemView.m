#import "TGWebSearchResultsGalleryGifItemView.h"

#import "TGWebSearchResultsGalleryGifItem.h"

#import "TGImageView.h"
#import "TGModernAnimatedImagePlayer.h"
#import "TGImageUtils.h"
#import "TGStringUtils.h"

#import "ActionStage.h"

#import "TGMessageImageViewOverlayView.h"

#import "TGModernButton.h"

#import "ATQueue.h"

#import "TGMediaStoreContext.h"

#import "TGModernGalleryTransitionView.h"

#import "TGTelegramNetworking.h"

@interface TGImageView (TransitionView) <TGModernGalleryTransitionView>

@end

@implementation TGImageView (TransitionView)

- (UIImage *)transitionImage
{
    if (self.frame.size.width < FLT_EPSILON || self.frame.size.height < FLT_EPSILON || self.image.size.width < FLT_EPSILON || self.image.size.height < FLT_EPSILON)
    {
        return self.image;
    }
    else
    {
        CGFloat frameAspect = self.frame.size.width / self.frame.size.height;
        CGFloat imageAspect = self.image.size.width / self.image.size.height;
        if (ABS(frameAspect - imageAspect) < 0.01f)
            return self.image;
        
        UIGraphicsBeginImageContextWithOptions(self.frame.size, true, 0.0f);
        CGSize imageSize = TGFillSizeF(TGFitSizeF(self.image.size, self.bounds.size), self.bounds.size);
        
        [self.image drawInRect:CGRectMake((self.bounds.size.width - imageSize.width) / 2.0f, (self.bounds.size.height - imageSize.height) / 2.0f, imageSize.width, imageSize.height) blendMode:kCGBlendModeCopy alpha:1.0f];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return image;
    }
}

@end

@interface TGWebSearchResultsGalleryGifItemView () <ASWatcher>
{
    UIView *_containerView;
    TGImageView *_imageView;
    TGModernAnimatedImagePlayer *_player;
    
    CGSize _imageSize;
    
    TGMessageImageViewOverlayView *_overlayView;
    
    NSString *_downloadPath;
    bool _downloaded;
    bool _isCurrent;
    NSData *_data;
}

@property (nonatomic, strong) ASHandle *actionHandle;

@end

@implementation TGWebSearchResultsGalleryGifItemView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        _actionHandle = [[ASHandle alloc] initWithDelegate:self releaseOnMainThread:true];
        
        _containerView = [[UIView alloc] init];
        [self addSubview:_containerView];
        _imageView = [[TGImageView alloc] init];
        _imageView.userInteractionEnabled = true;
        [_containerView addSubview:_imageView];
        
        _overlayView = [[TGMessageImageViewOverlayView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 50.0f, 50.0f)];
        [_imageView addSubview:_overlayView];
        
        self.clipsToBounds = true;
    }
    return self;
}

- (void)dealloc
{
    [_actionHandle reset];
    if (_downloadPath != nil)
        [ActionStageInstance() removeWatcher:self fromPath:_downloadPath];
}

- (void)prepareForRecycle
{
    [_imageView reset];
    [_player stop];
    _player = nil;
    
    if (_downloadPath != nil)
    {
        [ActionStageInstance() removeWatcher:self fromPath:_downloadPath];
        _downloadPath = nil;
    }
    
    _downloaded = false;
    _data = nil;
}

- (void)overlayButtonPressed
{
    if (!_downloaded && _downloadPath == nil)
        [self _download];
}

- (void)setItem:(TGWebSearchResultsGalleryGifItem *)item synchronously:(bool)synchronously
{
    [super setItem:item synchronously:synchronously];
    
    _imageSize = TGFitSize(item.webSearchResult.gifSize, CGSizeMake(400, 400));
    NSString *uri = [[NSString alloc] initWithFormat:@"web-search-thumbnail://?url=%@&width=%d&height=%d", [TGStringUtils stringByEscapingForURL:item.webSearchResult.previewUrl], (int)_imageSize.width, (int)_imageSize.height];
    
    CGSize fittedSize = TGFitSize(_imageSize, self.frame.size);
    
    _containerView.frame = CGRectMake(CGFloor((_containerView.superview.frame.size.width - fittedSize.width) / 2.0f), CGFloor((_containerView.superview.frame.size.height - fittedSize.height) / 2.0f), fittedSize.width, fittedSize.height);
    CGRect imageFrame = CGRectMake(CGFloor((_imageView.superview.frame.size.width - fittedSize.width) / 2.0f), CGFloor((_imageView.superview.frame.size.height - fittedSize.height) / 2.0f), fittedSize.width, fittedSize.height);
    if (!CGRectEqualToRect(imageFrame, _imageView.frame))
        _imageView.frame = imageFrame;
    
    _overlayView.frame = CGRectMake(CGFloor((_imageView.frame.size.width - _overlayView.frame.size.width) / 2.0f), CGFloor((_imageView.frame.size.height - _overlayView.frame.size.height) / 2.0f), _overlayView.frame.size.height, _overlayView.frame.size.height);
    
    [_imageView loadUri:uri withOptions:@{}];
    
    _overlayView.hidden = true;
    
    TGWebSearchResultsGalleryGifItem *checkingItem = item;
    __weak TGWebSearchResultsGalleryGifItemView *weakSelf = self;
    [[[TGMediaStoreContext instance] temporaryFilesCache] getValueForKey:[item.webSearchResult.gifUrl dataUsingEncoding:NSUTF8StringEncoding] completion:^(NSData *data)
    {
        TGDispatchOnMainThread(^
        {
            __strong TGWebSearchResultsGalleryGifItemView *strongSelf = weakSelf;
            if ([strongSelf.item isEqual:checkingItem])
            {
                if (data != nil)
                {
                    strongSelf->_data = data;
                    
                    strongSelf->_downloaded = true;
                    strongSelf->_overlayView.hidden = true;
                    if (_isCurrent)
                        [strongSelf _playWithData:data];
                }
                else
                {
                    _downloaded = false;
                    strongSelf->_overlayView.hidden = false;
                    [strongSelf->_overlayView setProgress:0.0f cancelEnabled:false animated:true];
                }
            }
        });
    }];
}

- (void)_download
{
    [_overlayView setProgress:0.0f cancelEnabled:false animated:true];
    
    TGWebSearchResultsGalleryGifItem *item = (TGWebSearchResultsGalleryGifItem *)self.item;
    _downloadPath = [[NSString alloc] initWithFormat:@"/temporaryDownload/(%@)", [TGStringUtils stringByEscapingForActorURL:item.webSearchResult.gifUrl]];
    [ActionStageInstance() requestActor:_downloadPath options:@{@"url": item.webSearchResult.gifUrl, @"cache": [[TGMediaStoreContext instance] temporaryFilesCache], @"mediaTypeTag": @(TGNetworkMediaTypeTagImage)} flags:0 watcher:self];
}

- (void)_playWithData:(NSData *)data
{
    _player = [[TGModernAnimatedImagePlayer alloc] initWithSize:_imageSize data:data];
    __weak TGWebSearchResultsGalleryGifItemView *weakSelf = self;
    _player.frameReady = ^(UIImage *image)
    {
        __strong TGWebSearchResultsGalleryGifItemView *strongSelf = weakSelf;
        if (strongSelf != nil)
            [strongSelf->_imageView loadUri:@"embedded-image://" withOptions:@{TGImageViewOptionEmbeddedImage: image}];
    };
    [_player play];
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    CGSize fittedSize = TGFitSize(_imageSize, self.frame.size);
    
    _containerView.frame = CGRectMake(CGFloor((_containerView.superview.frame.size.width - fittedSize.width) / 2.0f), CGFloor((_containerView.superview.frame.size.height - fittedSize.height) / 2.0f), fittedSize.width, fittedSize.height);
    CGRect imageFrame = CGRectMake(CGFloor((_imageView.superview.frame.size.width - fittedSize.width) / 2.0f), CGFloor((_imageView.superview.frame.size.height - fittedSize.height) / 2.0f), fittedSize.width, fittedSize.height);
    if (!CGRectEqualToRect(imageFrame, _imageView.frame))
        _imageView.frame = imageFrame;
    
    _overlayView.frame = CGRectMake(CGFloor((_imageView.frame.size.width - _overlayView.frame.size.width) / 2.0f), CGFloor((_imageView.frame.size.height - _overlayView.frame.size.height) / 2.0f), _overlayView.frame.size.height, _overlayView.frame.size.height);
}

- (UIView *)transitionView
{
    return _imageView;
}

- (CGRect)transitionViewContentRect
{
    return _imageView.bounds;
}

- (void)setIsCurrent:(bool)isCurrent
{
    if (isCurrent)
    {
        if (_downloaded)
        {
            if (_player != nil)
                [_player play];
            else if (_data != nil)
                [self _playWithData:_data];
        }
        else if (_downloadPath == nil)
        {
            [self _download];
        }
    }
    else
    {
        [_player pause];
        
        if (_downloadPath != nil)
        {
            [ActionStageInstance() removeWatcher:self fromPath:_downloadPath];
            _downloadPath = nil;
            
            [_overlayView setProgress:0.0f cancelEnabled:false animated:true];
        }
    }
}


- (void)actorMessageReceived:(NSString *)path messageType:(NSString *)messageType message:(id)message
{
    if ([messageType isEqualToString:@"progress"])
    {
        TGDispatchOnMainThread(^
        {
            if ([path isEqualToString:_downloadPath])
            {
                [_overlayView setProgress:[message floatValue] cancelEnabled:false animated:true];
            }
        });
    }
}

- (void)actorCompleted:(int)status path:(NSString *)path result:(id)result
{
    TGDispatchOnMainThread(^
    {
        if ([path isEqualToString:_downloadPath])
        {
            _downloadPath = nil;
            
            if (status == ASStatusSuccess)
            {
                _downloaded = true;
                _data = result;
                _overlayView.hidden = true;
                [self _playWithData:result];
            }
            else
            {
                [_overlayView setDownload];
            }
        }
    });
}

@end
