#import "TGVideoMessagePIPView.h"

#import "TGImageUtils.h"

#import "TGImageInfo.h"
#import "TGVideoMediaAttachment.h"

#import "TGMusicPlayer.h"

#import "TGImageView.h"
#import "TGVideoMessageViewModel.h"
#import "TGModernGalleryVideoView.h"
#import "TGRoundMessageRingView.h"

@interface TGVideoMessagePIPView ()
{
    UIImageView *_shadowView;
    UIView *_wrapperView;
    TGImageView *_imageView;
    TGModernGalleryVideoView *_videoView;
    TGRoundMessageRingView *_ringView;
    
    TGMusicPlayerItem *_item;
}
@end

@implementation TGVideoMessagePIPView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        _shadowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"VideoMessagePIPShadow"]];
        [self addSubview:_shadowView];
        
        _wrapperView = [[UIView alloc] initWithFrame:self.bounds];
        _wrapperView.backgroundColor = [UIColor whiteColor];
        _wrapperView.clipsToBounds = true;
        _wrapperView.layer.cornerRadius = frame.size.width / 2.0f;
        _wrapperView.userInteractionEnabled = false;
        [self addSubview:_wrapperView];
        
        _imageView = [[TGImageView alloc] initWithFrame:self.bounds];
        [_wrapperView addSubview:_imageView];
        
        _ringView = [[TGRoundMessageRingView alloc] initWithFrame:self.bounds];
        [self addSubview:_ringView];
        
        UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        [self addGestureRecognizer:gestureRecognizer];
    }
    return self;
}

- (void)handleTap:(UITapGestureRecognizer *)__unused gestureRecognizer
{
    if (self.onTap != nil)
        self.onTap();
}

- (void)setItem:(TGMusicPlayerItem *)item
{
    if (_item == item)
        return;
    
    _item = item;
    
    if (item != nil && [item.media isKindOfClass:[TGVideoMediaAttachment class]])
    {
        TGVideoMediaAttachment *video = (TGVideoMediaAttachment *)item.media;
        
        TGImageInfo *imageInfo = video.thumbnailInfo;
        TGImageInfo *previewImageInfo = imageInfo;
        
        NSString *legacyVideoFilePath = [TGVideoMessageViewModel filePathForVideoId:video.videoId != 0 ? video.videoId : video.localVideoId local:video.videoId == 0];
        NSString *legacyThumbnailCacheUri = [imageInfo closestImageUrlWithSize:CGSizeZero resultingSize:NULL];
        
        CGSize roundSize = CGSizeMake(123.0f, 123.0f);
        
        CGSize renderSize = CGSizeZero;
        [imageInfo imageUrlForLargestSize:&renderSize];
        renderSize = TGScaleToFill(renderSize, roundSize);
        
        if (video.videoId != 0 || video.localVideoId != 0)
        {
            previewImageInfo = [[TGImageInfo alloc] init];
            
            NSMutableString *previewUri = [[NSMutableString alloc] initWithString:@"video-thumbnail://?"];
            if (video.videoId != 0)
                [previewUri appendFormat:@"id=%" PRId64 "", video.videoId];
            else
                [previewUri appendFormat:@"local-id=%" PRId64 "", video.localVideoId];
            
            [previewUri appendFormat:@"&width=%d&height=%d&renderWidth=%d&renderHeight=%d", (int)roundSize.width, (int)roundSize.height, (int)renderSize.width, (int)renderSize.height];
            
            [previewUri appendFormat:@"&legacy-video-file-path=%@", legacyVideoFilePath];
            if (legacyThumbnailCacheUri != nil)
                [previewUri appendFormat:@"&legacy-thumbnail-cache-url=%@", legacyThumbnailCacheUri];
        

            [previewUri appendString:@"&flat=1&cornerRadius=61&inset=4"];
            
            [previewImageInfo addImageWithSize:renderSize url:previewUri];
        }

        NSString *imageUri = [previewImageInfo imageUrlForLargestSize:NULL];
        [_imageView loadUri:imageUri withOptions:nil];
    }
}

- (void)setVideoView:(TGModernGalleryVideoView *)videoView
{
    if (_videoView != nil)
    {
        [_videoView removeFromSuperview];
        _videoView = nil;
    }
    
    _videoView = videoView;
    _videoView.frame = CGRectInset(self.bounds, -2.0f, -2.0f);
    [_wrapperView addSubview:_videoView];
}

- (void)setStatus:(TGMusicPlayerStatus *)status
{
    [_ringView setStatus:status];
}

- (void)layoutSubviews
{
    _wrapperView.frame = self.bounds;
    _shadowView.frame = CGRectMake(-3.0f, -2.0f, 129.0f, 129.0f);
    if (_videoView.superview == _wrapperView)
        _videoView.frame = CGRectInset(self.bounds, -2.0f, -2.0f);
    _ringView.frame = self.bounds;
}

@end
