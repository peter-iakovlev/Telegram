#import "TGNotificationMediaPreviewView.h"
#import "TGMessage.h"

#import "TGImageUtils.h"
#import "TGStringUtils.h"
#import "TGFont.h"

#import "TGImageView.h"
#import "TGImageMessageViewModel.h"
#import "TGVideoMessageViewModel.h"
#import "TGRemoteImageView.h"

const int32_t TGNotificationMediaCornerRadius = 5;

@interface TGNotificationMediaPreviewView ()
{
    UIView *_wrapperView;
    TGImageView *_imageView;
    UIView *_textWrapperView;
    
    TGMediaAttachment *_attachment;
    bool _mediaIsAvailable;
    CGSize _displaySize;
    NSString *_imageUri;
    bool _loaded;
    NSString *_legacyThumbnailCacheUri;
    bool _hasCaption;
    bool _hasDuration;
    bool _round;
    
    UIImageView *_durationBackground;
    UILabel *_durationLabel;
}
@end

@implementation TGNotificationMediaPreviewView

- (instancetype)initWithMessage:(TGMessage *)message conversation:(TGConversation *)conversation attachment:(TGMediaAttachment *)attachment peers:(NSDictionary *)peers
{
    self = [super initWithMessage:message conversation:conversation peers:peers];
    if (self != nil)
    {
        _attachment = attachment;
     
        self.userInteractionEnabled = false;
        
        _wrapperView = [[UIView alloc] initWithFrame:self.bounds];
        _wrapperView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        if (iosMajorVersion() >= 7)
            _wrapperView.layer.allowsGroupOpacity = true;
        [self addSubview:_wrapperView];
        
        _imageView = [[TGImageView alloc] initWithFrame:CGRectZero];
        _imageView.alpha = 0.0f;
        _imageView.contentMode = UIViewContentModeScaleToFill;
        [_wrapperView addSubview:_imageView];
        
        CGSize imageSize = CGSizeZero;
        TGImageInfo *imageInfo = nil;
        
        switch (attachment.type)
        {
            case TGImageMediaAttachmentType:
            {
                TGImageMediaAttachment *imageMedia = (TGImageMediaAttachment *)attachment;
                
                NSString *text = TGLocalized(@"Message.Photo");
                if (imageMedia.caption.length > 0)
                {
                    _hasCaption = true;
                    text = imageMedia.caption;
                }
                
                [self setIcon:[UIImage imageNamed:@"MediaPhoto"] text:text];
                
                imageInfo = imageMedia.imageInfo;
                
                CGSize largestSize = CGSizeZero;
                NSString *legacyCacheUrl = [imageMedia.imageInfo closestImageUrlWithSize:CGSizeMake(1136, 1136) resultingSize:&largestSize pickLargest:true];
                NSString *legacyThumbnailCacheUrl = [imageMedia.imageInfo closestImageUrlWithSize:CGSizeZero resultingSize:NULL];
                
                int64_t localImageId = 0;
                if (imageMedia.imageId == 0 && legacyCacheUrl.length != 0)
                {
                    localImageId = murMurHash32(legacyCacheUrl);
                }
                
                if (legacyCacheUrl != nil && (imageMedia.imageId != 0 || localImageId != 0))
                {
                    imageInfo = [[TGImageInfo alloc] init];
                    
                    NSMutableString *previewUri = [[NSMutableString alloc] initWithString:@"photo-thumbnail://?"];
                    if (imageMedia.imageId != 0)
                        [previewUri appendFormat:@"id=%" PRId64 "", imageMedia.imageId];
                    else
                        [previewUri appendFormat:@"local-id=%" PRId64 "", localImageId];
                    
                    CGSize thumbnailSize = CGSizeZero;
                    CGSize renderSize = CGSizeZero;
                    [TGImageMessageViewModel calculateImageSizesForImageSize:largestSize thumbnailSize:&thumbnailSize renderSize:&renderSize squareAspect:message.messageLifetime > 0 && message.messageLifetime <= 60 && message.layer >= 17];
                    imageSize = thumbnailSize;
                    
                    [previewUri appendFormat:@"&width=%d&height=%d&renderWidth=%d&renderHeight=%d", (int)thumbnailSize.width, (int)thumbnailSize.height, (int)renderSize.width, (int)renderSize.height];
                    
                    NSString *legacyFilePath = nil;
                    if ([legacyCacheUrl hasPrefix:@"file://"])
                        legacyFilePath = [legacyCacheUrl substringFromIndex:@"file://".length];
                    else
                        legacyFilePath = [[TGRemoteImageView sharedCache] pathForCachedData:legacyCacheUrl];
                    
                    if (legacyFilePath != nil)
                        [previewUri appendFormat:@"&legacy-file-path=%@", legacyFilePath];
                    
                    if (message.messageLifetime > 0 && message.messageLifetime <= 60)
                        [previewUri appendString:@"&secret=1"];
                    
                    if (legacyThumbnailCacheUrl != nil)
                        [previewUri appendFormat:@"&legacy-thumbnail-cache-url=%@", [TGStringUtils stringByEscapingForURL:legacyThumbnailCacheUrl]];
                    
                    [previewUri appendFormat:@"&flat=1&cornerRadius=%" PRId32 "", TGNotificationMediaCornerRadius];
                    [imageInfo addImageWithSize:renderSize url:previewUri];
                    
                    NSMutableString *imageUri = [[imageInfo imageUrlForLargestSize:NULL] mutableCopy];
                    _imageUri = imageUri;
                }
            }
                break;
                
            case TGVideoMediaAttachmentType:
            {
                TGVideoMediaAttachment *video = (TGVideoMediaAttachment *)attachment;
                NSString *text = video.roundMessage ? TGLocalized(@"Message.VideoMessage") : TGLocalized(@"Message.Video");
                if (video.caption.length > 0)
                {
                    _hasCaption = true;
                    text = video.caption;
                }
                
                [self setIcon:[UIImage imageNamed:@"MediaVideo"] text:text];
                
                imageInfo = video.thumbnailInfo;
                
                NSString *legacyVideoFilePath = [TGVideoMessageViewModel filePathForVideoId:video.videoId != 0 ? video.videoId : video.localVideoId local:video.videoId == 0];
                NSString *legacyThumbnailCacheUri = [imageInfo closestImageUrlWithSize:CGSizeZero resultingSize:NULL];
                
                if (video.videoId != 0 || video.localVideoId != 0)
                {
                    imageInfo = [[TGImageInfo alloc] init];
                    
                    NSMutableString *previewUri = [[NSMutableString alloc] initWithString:@"video-thumbnail://?"];
                    if (video.videoId != 0)
                        [previewUri appendFormat:@"id=%" PRId64 "", video.videoId];
                    else
                        [previewUri appendFormat:@"local-id=%" PRId64 "", video.localVideoId];
                    
                    CGSize thumbnailSize = CGSizeZero;
                    CGSize renderSize = CGSizeZero;
                    [TGImageMessageViewModel calculateImageSizesForImageSize:video.dimensions thumbnailSize:&thumbnailSize renderSize:&renderSize squareAspect:message.messageLifetime > 0 && message.messageLifetime <= 60 && message.layer >= 17];
                    imageSize = thumbnailSize;
                    
                    [previewUri appendFormat:@"&width=%d&height=%d&renderWidth=%d&renderHeight=%d", (int)thumbnailSize.width, (int)thumbnailSize.height, (int)renderSize.width, (int)renderSize.height];
                    
                    [previewUri appendFormat:@"&legacy-video-file-path=%@", legacyVideoFilePath];
                    if (legacyThumbnailCacheUri != nil)
                        [previewUri appendFormat:@"&legacy-thumbnail-cache-url=%@", legacyThumbnailCacheUri];
                    
                    if (message.messageLifetime > 0 && message.messageLifetime <= 60)
                        [previewUri appendString:@"&secret=1"];
                    
                    [previewUri appendFormat:@"&flat=1&cornerRadius=%d", !video.roundMessage ? TGNotificationMediaCornerRadius : (int)imageSize.width / 2];
                    [imageInfo addImageWithSize:renderSize url:previewUri];
                    
                    NSMutableString *imageUri = [[imageInfo imageUrlForLargestSize:NULL] mutableCopy];
                    _imageUri = imageUri;
                }
                
                static UIImage *backgroundImage = nil;
                static dispatch_once_t onceToken;
                dispatch_once(&onceToken, ^
                {
                    UIGraphicsBeginImageContextWithOptions(CGSizeMake(17, 17), false, 0.0f);
                    CGContextRef context = UIGraphicsGetCurrentContext();
                    CGContextSetFillColorWithColor(context, UIColorRGBA(0x000000, 0.4f).CGColor);
                    
                    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 17, 17) cornerRadius:8];
                    [path fill];
                    
                    backgroundImage = [UIGraphicsGetImageFromCurrentImageContext() resizableImageWithCapInsets:UIEdgeInsetsMake(8, 8, 8, 8)];
                    UIGraphicsEndImageContext();
                });
                
                if (!video.roundMessage)
                {
                    _durationBackground = [[UIImageView alloc] initWithImage:backgroundImage];
                    _durationBackground.alpha = 0.0f;
                    [_wrapperView addSubview:_durationBackground];

                    int minutes = video.duration / 60;
                    int seconds = video.duration % 60;
                    
                    _durationLabel = [[UILabel alloc] init];
                    _durationLabel.backgroundColor = [UIColor clearColor];
                    _durationLabel.font = TGSystemFontOfSize(11.0f);
                    _durationLabel.text = [[NSString alloc] initWithFormat:@"%d:%02d", minutes, seconds];
                    _durationLabel.textAlignment = NSTextAlignmentCenter;
                    _durationLabel.textColor = [UIColor whiteColor];
                    [_durationBackground addSubview:_durationLabel];
                    
                    [_durationLabel sizeToFit];
                    _durationBackground.frame = CGRectMake(0, 0, MAX(35, ceil(_durationLabel.frame.size.width) + 12), 18);
                    _durationLabel.frame = CGRectMake(0, (_durationBackground.frame.size.height - ceil(_durationLabel.frame.size.height)) / 2, _durationBackground.frame.size.width, ceil(_durationLabel.frame.size.height));
                }
            }
                break;
                
            case TGLocationMediaAttachmentType:
            {
                TGLocationMediaAttachment *locationAttachment = (TGLocationMediaAttachment *)attachment;
                
                [self setIcon:[UIImage imageNamed:@"MediaLocation"] text:TGLocalized(@"Message.Location")];
                
                imageSize = CGSizeMake(240, 128);
                _imageUri = [NSString stringWithFormat:@"map-thumbnail://?latitude=%f&longitude=%f&width=%d&height=%d&flat=1&cornerRadius=%" PRId32 "", locationAttachment.latitude, locationAttachment.longitude, (int)imageSize.width, (int)imageSize.height, TGNotificationMediaCornerRadius];
            }
                break;
                
            default:
                break;
        }
        
        NSString *imageUri = [imageInfo imageUrlForLargestSize:NULL];
        if ([imageUri hasPrefix:@"photo-thumbnail://?"])
        {
            NSDictionary *dict = [TGStringUtils argumentDictionaryInUrlString:[imageUri substringFromIndex:@"photo-thumbnail://?".length]];
            _legacyThumbnailCacheUri = dict[@"legacy-thumbnail-cache-url"];
        }
        else if ([imageUri hasPrefix:@"video-thumbnail://?"])
        {
            NSDictionary *dict = [TGStringUtils argumentDictionaryInUrlString:[imageUri substringFromIndex:@"video-thumbnail://?".length]];
            _legacyThumbnailCacheUri = dict[@"legacy-thumbnail-cache-url"];
        }
        else if ([imageUri hasPrefix:@"animation-thumbnail://?"])
        {
            NSDictionary *dict = [TGStringUtils argumentDictionaryInUrlString:[imageUri substringFromIndex:@"animation-thumbnail://?".length]];
            _legacyThumbnailCacheUri = dict[@"legacy-thumbnail-cache-url"];
        }
        
        if (_hasCaption)
        {
            _textWrapperView = [[UIView alloc] initWithFrame:CGRectZero];
            _textWrapperView.backgroundColor = [UIColor clearColor];
            _textWrapperView.clipsToBounds = true;
            [self addSubview:_textWrapperView];
            
            [_textWrapperView addSubview:_textLabel];
        }
        
        CGSize displaySize = [self displaySizeForSize:imageSize];
        _displaySize = displaySize;
    }
    return self;
}

- (void)imageDataInvalidated:(NSString *)imageUrl
{
    if (![_legacyThumbnailCacheUri isEqualToString:imageUrl])
        return;
    
    [_imageView loadUri:_imageUri withOptions:@
    {
        TGImageViewOptionKeepCurrentImageAsPlaceholder: @true,
        TGImageViewOptionSynchronous: @false
    }];
}

- (void)setExpandProgress:(CGFloat)progress
{
    _expandProgress = progress;
    
    if (progress > FLT_EPSILON && !_loaded)
    {
        _loaded = true;
        [_imageView loadUri:_imageUri withOptions:@{}];
        
        if (!_mediaIsAvailable && _attachment.type == TGImageMediaAttachmentType)
            self.requestMedia(_attachment, _conversationId, _messageId);
    }
    
    _wrapperView.alpha = progress * progress;
    [self _updateExpandProgress:progress hideText:!_hasCaption];
    
    if (_durationBackground != nil)
        _durationBackground.alpha = progress * progress * progress;
    
    [self setNeedsLayout];
}

- (CGFloat)expandedHeightForContainerSize:(CGSize)containerSize
{
    [super expandedHeightForContainerSize:containerSize];
    
    CGFloat captionHeight = _hasCaption ? _textHeight + 4.0f : 0.0f;
    
    return _headerHeight + _displaySize.height + captionHeight + 35.0f;
}

- (CGSize)displaySizeForSize:(CGSize)size
{
    CGFloat maxHeight = 180;
    
    int screenSize = (int)TGScreenSize().height;
    if (screenSize < 568)
        maxHeight = 100;
    
    if (_hasCaption)
        maxHeight -= 30;
    
    return TGFitSize(size, CGSizeMake(256, maxHeight));
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat progress = _expandProgress;
    _imageView.frame = CGRectMake(TGNotificationPreviewContentInset.left, _textLabel.frame.origin.y + 3, _displaySize.width * progress, _displaySize.height * progress);
    
    CGFloat offset = progress * 6;
    _durationBackground.frame = CGRectMake(_imageView.frame.origin.x + offset, _imageView.frame.origin.y + offset, _durationBackground.frame.size.width, _durationBackground.frame.size.height);
    
    if (_hasCaption)
    {
        _textEndPos += _displaySize.height + 7.0f;
        
        CGRect textWrapperFrame = _textLabel.frame;
        textWrapperFrame.origin.y = _textStartPos + (_textEndPos - _textStartPos) * progress;
        textWrapperFrame.size.height = _collapsedTextHeight + (_textHeight - _collapsedTextHeight) * progress;
        
        CGRect textLabelFrame = _textLabel.frame;
        textLabelFrame.origin = CGPointZero;
        textLabelFrame.size.height = progress > FLT_EPSILON ? _textHeight : textLabelFrame.size.height;
        
        _textWrapperView.frame = textWrapperFrame;
        _textLabel.frame = textLabelFrame;
    }
}

@end
