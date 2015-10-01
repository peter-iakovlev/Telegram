#import "TGSharedMediaVideoItemView.h"

#import "TGVideoMediaAttachment.h"
#import "TGImageUtils.h"

#import "TGImageView.h"
#import "TGSharedMediaImageViewQueue.h"

#import "TGFont.h"
#import "TGImageUtils.h"

#import "TGAppDelegate.h"

@interface TGSharedMediaVideoItemView ()
{
    TGImageView *_imageView;
    NSString *_imageUri;
    NSString *_legacyThumbnailUrl;
    UIImageView *_durationBackgroundView;
    UILabel *_durationLabel;
}

@end

@implementation TGSharedMediaVideoItemView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        static UIImage *durationBackgroundImage = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^
        {
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(18.0f, 18.0f), false, 0.0f);
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextSetFillColorWithColor(context, [UIColor colorWithWhite:0.0f alpha:0.3f].CGColor);
            CGContextFillRect(context, CGRectMake(0.0f, 0.0f, 18.0f, 18.0f));
            UIImage *iconImage = [UIImage imageNamed:@"SharedMediaVideoThumbnailPlay.png"];
            [iconImage drawAtPoint:CGPointMake(6.0f, 5.0f)];
            durationBackgroundImage = [UIGraphicsGetImageFromCurrentImageContext() stretchableImageWithLeftCapWidth:17 topCapHeight:0];
            UIGraphicsEndImageContext();
        });
        
        _durationBackgroundView = [[UIImageView alloc] initWithImage:durationBackgroundImage];
        _durationBackgroundView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.4f];
        [self.contentView insertSubview:_durationBackgroundView atIndex:0];
        
        _durationLabel = [[UILabel alloc] init];
        _durationLabel.backgroundColor = [UIColor clearColor];
        _durationLabel.textColor = [UIColor whiteColor];
        _durationLabel.font = TGSystemFontOfSize(10.0f + TGRetinaPixel);
        [self.contentView insertSubview:_durationLabel aboveSubview:_durationBackgroundView];
    }
    return self;
}

- (void)prepareForReuse
{
    [self.imageViewQueue enqueueImageView:_imageView forUri:nil];
    [_imageView removeFromSuperview];
    _imageView = nil;
    _imageUri = nil;
}

- (void)enqueueImageViewWithUri
{
    [self.imageViewQueue enqueueImageView:_imageView forUri:_imageUri];
    [_imageView removeFromSuperview];
    _imageView = nil;
    _imageUri = nil;
}

- (UIView *)transitionView
{
    return _imageView;
}

- (void)updateItemHidden
{
    _imageView.hidden = self.isItemHidden(self.item);
    _durationBackgroundView.hidden = _imageView.hidden;
    _durationLabel.hidden = _imageView.hidden;
}

- (void)imageThumbnailUpdated:(NSString *)thumbnaiUri
{
    if ([thumbnaiUri isEqualToString:_legacyThumbnailUrl])
    {
        [_imageView loadUri:_imageUri withOptions:@{TGImageViewOptionKeepCurrentImageAsPlaceholder: @true}];
    }
}

- (NSString *)filePathForVideoId:(int64_t)videoId local:(bool)local
{
    static NSString *videosDirectory = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        NSString *documentsDirectory = [TGAppDelegate documentsPath];
        videosDirectory = [documentsDirectory stringByAppendingPathComponent:@"video"];
        if (![[NSFileManager defaultManager] fileExistsAtPath:videosDirectory])
            [[NSFileManager defaultManager] createDirectoryAtPath:videosDirectory withIntermediateDirectories:true attributes:nil error:nil];
    });
    
    return [videosDirectory stringByAppendingPathComponent:[[NSString alloc] initWithFormat:@"%@%" PRIx64 ".mov", local ? @"local" : @"remote", videoId]];
}

- (void)setVideoMediaAttachment:(TGVideoMediaAttachment *)videoMediaAttachment messageId:(int32_t)messageId peerId:(int64_t)peerId
{
    NSMutableString *previewUri = nil;
    
    NSString *legacyVideoFilePath = [self filePathForVideoId:videoMediaAttachment.videoId != 0 ? videoMediaAttachment.videoId : videoMediaAttachment.localVideoId local:videoMediaAttachment.videoId == 0];
    NSString *legacyThumbnailCacheUri = [videoMediaAttachment.thumbnailInfo closestImageUrlWithSize:CGSizeZero resultingSize:NULL];
    _legacyThumbnailUrl = legacyThumbnailCacheUri;
    
    if (videoMediaAttachment.videoId != 0 || videoMediaAttachment.localVideoId != 0)
    {
        previewUri = [[NSMutableString alloc] initWithString:@"media-gallery-video-preview://?"];
        if (videoMediaAttachment.videoId != 0)
            [previewUri appendFormat:@"id=%" PRId64 "", videoMediaAttachment.videoId];
        else
            [previewUri appendFormat:@"local-id=%" PRId64 "", videoMediaAttachment.localVideoId];
        
        CGSize renderSize = CGSizeMake(50.0f, 50.0f);
        CGSize size = TGFillSize(TGFitSize(videoMediaAttachment.dimensions, renderSize), renderSize);
        
        [previewUri appendFormat:@"&width=%d&height=%d&renderWidth=%d&renderHeight=%d", (int)renderSize.width, (int)renderSize.height, (int)size.width, (int)size.height];
        
        [previewUri appendFormat:@"&legacy-video-file-path=%@", legacyVideoFilePath];
        if (legacyThumbnailCacheUri != nil)
            [previewUri appendFormat:@"&legacy-thumbnail-cache-url=%@", legacyThumbnailCacheUri];
        
        [previewUri appendFormat:@"&messageId=%" PRId32 "", (int32_t)messageId];
        [previewUri appendFormat:@"&conversationId=%" PRId64 "", (int64_t)peerId];
    }
    
    _imageUri = previewUri;
    
    _imageView = [self.imageViewQueue dequeueImageViewForUri:_imageUri];
    [self.contentView insertSubview:_imageView atIndex:0];
    _imageView.frame = self.bounds;
    
    _durationLabel.text = [[NSString alloc] initWithFormat:@"%d:%02d", ((int)videoMediaAttachment.duration) / 60, ((int)videoMediaAttachment.duration) % 60];
    [_durationLabel sizeToFit];
    
    [self updateItemHidden];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _imageView.frame = self.bounds;
    
    CGFloat backgroundWidth = _durationLabel.frame.size.width + 18.0f + 4.0f;
    _durationBackgroundView.frame = CGRectMake(self.bounds.size.width - 5.0f - backgroundWidth, self.bounds.size.height - 5.0f - _durationBackgroundView.frame.size.height, backgroundWidth, _durationBackgroundView.frame.size.height);
    _durationLabel.frame = (CGRect){{_durationBackgroundView.frame.origin.x + 18.0f, _durationBackgroundView.frame.origin.y + 3.0f}, _durationLabel.frame.size};
}

@end
