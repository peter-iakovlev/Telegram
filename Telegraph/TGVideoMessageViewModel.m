#import "TGVideoMessageViewModel.h"

#import "TGVideoMediaAttachment.h"

#import "TGTelegraphConversationMessageAssetsSource.h"

#import "TGImageUtils.h"

#import "TGMessage.h"

#import "TGModernImageViewModel.h"
#import "TGMessageImageViewModel.h"
#import "TGModernRemoteImageViewModel.h"
#import "TGModernFlatteningViewModel.h"
#import "TGModernLabelViewModel.h"
#import "TGModernTextViewModel.h"

#import "TGModernRemoteImageView.h"
#import "TGModernRemoteImageViewModel.h"
#import "TGModernColorViewModel.h"
#import "TGInstantPreviewTouchAreaModel.h"
#import "TGModernButtonViewModel.h"

#import "TGReusableLabel.h"

#import "TGMessageImageView.h"

@interface TGVideoMessageViewModel ()
{
    TGVideoMediaAttachment *_video;
    int _videoSize;
    
    bool _progressVisible;
    
    CGPoint _boundOffset;
    
    int _messageLifetime;
    
    TGModernImageViewModel *_overlayIconModel;
    TGModernImageViewModel *_overlayIconMaskLeftModel;
    TGModernImageViewModel *_overlayIconMaskRightModel;
    TGModernColorViewModel *_overlayIconMaskTopModel;
    TGModernColorViewModel *_overlayIconMaskBottomModel;
    
    TGInstantPreviewTouchAreaModel *_touchAreaModel;
}

@end

@implementation TGVideoMessageViewModel

- (NSString *)filePathForVideoId:(int64_t)videoId local:(bool)local
{
    static NSString *videosDirectory = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true) objectAtIndex:0];
        videosDirectory = [documentsDirectory stringByAppendingPathComponent:@"video"];
        if (![[NSFileManager defaultManager] fileExistsAtPath:videosDirectory])
            [[NSFileManager defaultManager] createDirectoryAtPath:videosDirectory withIntermediateDirectories:true attributes:nil error:nil];
    });
    
    return [videosDirectory stringByAppendingPathComponent:[[NSString alloc] initWithFormat:@"%@%" PRIx64 ".mov", local ? @"local" : @"remote", videoId]];
}

- (instancetype)initWithMessage:(TGMessage *)message imageInfo:(TGImageInfo *)imageInfo video:(TGVideoMediaAttachment *)video author:(TGUser *)author context:(TGModernViewContext *)context
{
    TGImageInfo *previewImageInfo = imageInfo;
    
    NSString *legacyVideoFilePath = [self filePathForVideoId:video.videoId != 0 ? video.videoId : video.localVideoId local:video.videoId == 0];
    NSString *legacyThumbnailCacheUri = [imageInfo closestImageUrlWithSize:CGSizeZero resultingSize:NULL];
    
    if (video.videoId != 0 || video.localVideoId != 0)
    {
        previewImageInfo = [[TGImageInfo alloc] init];
        
        NSMutableString *previewUri = [[NSMutableString alloc] initWithString:@"video-thumbnail://?"];
        if (video.videoId != 0)
            [previewUri appendFormat:@"id=%" PRId64 "", video.videoId];
        else
            [previewUri appendFormat:@"local-id=%" PRId64 "", video.localVideoId];
        
        CGSize thumbnailSize = CGSizeZero;
        CGSize renderSize = CGSizeZero;
        [TGImageMessageViewModel calculateImageSizesForImageSize:video.dimensions thumbnailSize:&thumbnailSize renderSize:&renderSize];
        
        [previewUri appendFormat:@"&width=%d&height=%d&renderWidth=%d&renderHeight=%d", (int)thumbnailSize.width, (int)thumbnailSize.height, (int)renderSize.width, (int)renderSize.height];
        
        [previewUri appendFormat:@"&legacy-video-file-path=%@", legacyVideoFilePath];
        if (legacyThumbnailCacheUri != nil)
            [previewUri appendFormat:@"&legacy-thumbnail-cache-url=%@", legacyThumbnailCacheUri];
        
        [previewImageInfo addImageWithSize:renderSize url:previewUri];
    }
    
    self = [super initWithMessage:message imageInfo:previewImageInfo author:author context:context];
    if (self != nil)
    {
        static UIImage *dateBackgroundImage = nil;
        static UIImage *videoIconImage = nil;
        static TGTelegraphConversationMessageAssetsSource *assetsSource = nil;
        
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^
        {
            dateBackgroundImage = [[UIImage imageNamed:@"ModernMessageImageDateBackground.png"] stretchableImageWithLeftCapWidth:9 topCapHeight:9];
            videoIconImage = [UIImage imageNamed:@"ModernMessageVideoIcon.png"];
            
            assetsSource = [TGTelegraphConversationMessageAssetsSource instance];
        });
        
        _video = video;
        [_video.videoInfo urlWithQuality:0 actualQuality:NULL actualSize:&_videoSize];
        
        _messageLifetime = message.messageLifetime;
        
        if (_messageLifetime != 0)
        {
            static const CGFloat dimAlpha = 0.2f;
            
            static UIImage *overlayIconImage = nil;
            static UIImage *overlayIconMaskLeftImage = nil;
            static UIImage *overlayIconMaskRightImage = nil;
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^
            {
                overlayIconImage = [UIImage imageNamed:@"ModernMessageSecretPhotoOverlayIcon.png"];
                
                {
                    UIGraphicsBeginImageContextWithOptions(CGSizeMake(14.0f, 28.0f), false, 0.0f);
                    CGContextRef context = UIGraphicsGetCurrentContext();
                    
                    CGContextSetFillColorWithColor(context, UIColorRGBA(0x000000, dimAlpha).CGColor);
                    CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, 28.0f, 28.0f));
                    
                    overlayIconMaskLeftImage = [UIGraphicsGetImageFromCurrentImageContext() stretchableImageWithLeftCapWidth:27 topCapHeight:14];
                    UIGraphicsEndImageContext();
                }
                
                {
                    UIGraphicsBeginImageContextWithOptions(CGSizeMake(14.0f, 28.0f), false, 0.0f);
                    CGContextRef context = UIGraphicsGetCurrentContext();
                    
                    CGContextSetFillColorWithColor(context, UIColorRGBA(0x000000, dimAlpha).CGColor);
                    CGContextFillEllipseInRect(context, CGRectMake(-14.0f, 0.0f, 28.0f, 28.0f));
                    
                    overlayIconMaskRightImage = [UIGraphicsGetImageFromCurrentImageContext() stretchableImageWithLeftCapWidth:1 topCapHeight:14];
                    UIGraphicsEndImageContext();
                }
            });
            _overlayIconModel = [[TGModernImageViewModel alloc] initWithImage:overlayIconImage];
            _overlayIconModel.skipDrawInContext = true;
            _overlayIconModel.viewUserInteractionDisabled = true;
            [_overlayIconModel sizeToFit];
            [self insertSubmodel:_overlayIconModel aboveSubmodel:self.imageModel];
            
            _overlayIconMaskLeftModel = [[TGModernImageViewModel alloc] initWithImage:overlayIconMaskLeftImage];
            _overlayIconMaskLeftModel.skipDrawInContext = true;
            _overlayIconMaskLeftModel.viewUserInteractionDisabled = true;
            [self insertSubmodel:_overlayIconMaskLeftModel aboveSubmodel:self.imageModel];
            
            _overlayIconMaskRightModel = [[TGModernImageViewModel alloc] initWithImage:overlayIconMaskRightImage];
            _overlayIconMaskRightModel.skipDrawInContext = true;
            _overlayIconMaskRightModel.viewUserInteractionDisabled = true;
            [self insertSubmodel:_overlayIconMaskRightModel aboveSubmodel:self.imageModel];
            
            UIColor *dimColor = UIColorRGBA(0x000000, dimAlpha);
            _overlayIconMaskTopModel = [[TGModernColorViewModel alloc] initWithColor:dimColor];
            _overlayIconMaskTopModel.skipDrawInContext = true;
            _overlayIconMaskTopModel.viewUserInteractionDisabled = true;
            [self insertSubmodel:_overlayIconMaskTopModel aboveSubmodel:self.imageModel];
            _overlayIconMaskBottomModel = [[TGModernColorViewModel alloc] initWithColor:dimColor];
            _overlayIconMaskBottomModel.skipDrawInContext = true;
            _overlayIconMaskBottomModel.viewUserInteractionDisabled = true;
            [self insertSubmodel:_overlayIconMaskBottomModel aboveSubmodel:self.imageModel];
            
            if (message.outgoing)
            {
            }
            else
            {
                _touchAreaModel = [[TGInstantPreviewTouchAreaModel alloc] init];
                _touchAreaModel.notificationHandle = context.companionHandle;
                _touchAreaModel.touchesBeganAction = @"openMediaRequested";
                _touchAreaModel.touchesBeganOptions = @{@"mid": @(message.mid)};
                _touchAreaModel.touchesCompletedAction = @"closeMediaRequested";
                _touchAreaModel.touchesCompletedOptions = @{@"mid": @(message.mid)};
                [self addSubmodel:_touchAreaModel];
            }
        }
        
        int minutes = video.duration / 60;
        int seconds = video.duration % 60;
        
        [self.imageModel setAdditionalDataString:[[NSString alloc] initWithFormat:@"%d:%02d", minutes, seconds]];
    }
    return self;
}

- (void)updateMessage:(TGMessage *)message viewStorage:(TGModernViewStorage *)viewStorage
{
    [super updateMessage:message viewStorage:viewStorage];
    
    TGVideoMediaAttachment *video = nil;
    
    
    if (video != nil)
    {
        TGImageInfo *previewImageInfo = video.thumbnailInfo;
        
        NSString *legacyVideoFilePath = [self filePathForVideoId:video.videoId != 0 ? video.videoId : video.localVideoId local:video.videoId == 0];
        NSString *legacyThumbnailCacheUri = [video.thumbnailInfo closestImageUrlWithSize:CGSizeZero resultingSize:NULL];
        
        if (video.videoId != 0 || video.localVideoId != 0)
        {
            previewImageInfo = [[TGImageInfo alloc] init];
            
            NSMutableString *previewUri = [[NSMutableString alloc] initWithString:@"video-thumbnail://?"];
            if (video.videoId != 0)
                [previewUri appendFormat:@"id=%" PRId64 "", video.videoId];
            else
                [previewUri appendFormat:@"local-id=%" PRId64 "", video.localVideoId];
            
            CGSize thumbnailSize = CGSizeZero;
            CGSize renderSize = CGSizeZero;
            [TGImageMessageViewModel calculateImageSizesForImageSize:video.dimensions thumbnailSize:&thumbnailSize renderSize:&renderSize];
            
            [previewUri appendFormat:@"&width=%d&height=%d&renderWidth=%d&renderHeight=%d", (int)thumbnailSize.width, (int)thumbnailSize.height, (int)renderSize.width, (int)renderSize.height];
            
            [previewUri appendFormat:@"&legacy-video-file-path=%@", legacyVideoFilePath];
            if (legacyThumbnailCacheUri != nil)
                [previewUri appendFormat:@"&legacy-thumbnail-cache-url=%@", legacyThumbnailCacheUri];
            
            [previewImageInfo addImageWithSize:renderSize url:previewUri];
        }
        
        [self updateImageInfo:previewImageInfo];
    }
}

- (void)updateMediaAvailability:(bool)mediaIsAvailable viewStorage:(TGModernViewStorage *)__unused viewStorage
{
    _touchAreaModel.touchesBeganAction = mediaIsAvailable ? @"openMediaRequested" : @"mediaDownloadRequested";
    
    [super updateMediaAvailability:mediaIsAvailable viewStorage:viewStorage];
}

- (void)updateProgress:(bool)progressVisible progress:(float)progress viewStorage:(TGModernViewStorage *)viewStorage
{
    _progressVisible = progressVisible;
    
    NSString *labelText = nil;
    
    if (progressVisible)
    {
        if (_videoSize < 1024 * 1024)
        {
            labelText = [[NSString alloc] initWithFormat:TGLocalizedStatic(@"Conversation.DownloadProgressKilobytes"), (int)(_videoSize * progress / 1024), (int)(_videoSize / 1024)];
        }
        else
        {
            labelText = [[NSString alloc] initWithFormat:TGLocalizedStatic(@"Conversation.DownloadProgressMegabytes"), (float)_videoSize * progress / (1024 * 1024), (float)_videoSize / (1024 * 1024)];
        }
    }
    else
    {
        int minutes = _video.duration / 60;
        int seconds = _video.duration % 60;
        labelText = [[NSString alloc] initWithFormat:@"%d:%02d", minutes, seconds];
    }
    
    [self.imageModel setAdditionalDataString:labelText];
    
    [super updateProgress:progressVisible progress:progress viewStorage:viewStorage];
}

- (NSString *)filterForMessage:(TGMessage *)message imageSize:(CGSize)imageSize sourceSize:(CGSize)sourceSize
{
    if (message.messageLifetime == 0)
        return [super filterForMessage:message imageSize:imageSize sourceSize:sourceSize];
    
    return [[NSString alloc] initWithFormat:@"%@:%dx%d,%dx%d", @"secretAttachmentImageOutgoing", (int)imageSize.width, (int)imageSize.height, (int)sourceSize.width, (int)sourceSize.height];
}

- (CGSize)minimumImageSizeForMessage:(TGMessage *)message
{
    if (message.messageLifetime == 0)
        return [super minimumImageSizeForMessage:message];
    
    return CGSizeMake(120, 120);
}

- (bool)instantPreviewGesture
{
    return _messageLifetime != 0;
}

- (void)bindSpecialViewsToContainer:(UIView *)container viewStorage:(TGModernViewStorage *)viewStorage atItemPosition:(CGPoint)itemPosition
{
    _boundOffset = itemPosition;
    
    [super bindSpecialViewsToContainer:container viewStorage:viewStorage atItemPosition:itemPosition];
    
    [_overlayIconModel bindViewToContainer:container viewStorage:viewStorage];
    [_overlayIconModel boundView].frame = CGRectOffset([_overlayIconModel boundView].frame, itemPosition.x, itemPosition.y);
    
    [_overlayIconMaskLeftModel bindViewToContainer:container viewStorage:viewStorage];
    [_overlayIconMaskLeftModel boundView].frame = CGRectOffset([_overlayIconMaskLeftModel boundView].frame, itemPosition.x, itemPosition.y);
    
    [_overlayIconMaskRightModel bindViewToContainer:container viewStorage:viewStorage];
    [_overlayIconMaskRightModel boundView].frame = CGRectOffset([_overlayIconMaskRightModel boundView].frame, itemPosition.x, itemPosition.y);
    
    [_overlayIconMaskTopModel bindViewToContainer:container viewStorage:viewStorage];
    [_overlayIconMaskTopModel boundView].frame = CGRectOffset([_overlayIconMaskTopModel boundView].frame, itemPosition.x, itemPosition.y);
    
    [_overlayIconMaskBottomModel bindViewToContainer:container viewStorage:viewStorage];
    [_overlayIconMaskBottomModel boundView].frame = CGRectOffset([_overlayIconMaskBottomModel boundView].frame, itemPosition.x, itemPosition.y);
}

- (void)bindViewToContainer:(UIView *)container viewStorage:(TGModernViewStorage *)viewStorage
{
    _boundOffset = CGPointZero;
    
    [super bindViewToContainer:container viewStorage:viewStorage];
}

- (void)layoutForContainerSize:(CGSize)containerSize
{
    [super layoutForContainerSize:containerSize];
    
    if (_overlayIconModel != nil)
    {
        CGRect imageFrame = self.imageModel.frame;
        
        _touchAreaModel.frame = imageFrame;
        
        CGRect iconFrame = _overlayIconModel.frame;
        iconFrame = CGRectMake(imageFrame.origin.x + CGFloor((imageFrame.size.width - _overlayIconModel.frame.size.width) / 2.0f), imageFrame.origin.y + CGFloor((imageFrame.size.height - _overlayIconModel.frame.size.height) / 2.0f), iconFrame.size.width, iconFrame.size.height);
        _overlayIconModel.frame = iconFrame;
        
        _overlayIconMaskLeftModel.frame = CGRectMake(imageFrame.origin.x + 2.0f, imageFrame.origin.y + 2.0f, iconFrame.origin.x - imageFrame.origin.x - 2.0f, imageFrame.size.height - 4.0f);
        _overlayIconMaskRightModel.frame = CGRectMake(iconFrame.origin.x + iconFrame.size.width, imageFrame.origin.y + 2.0f, imageFrame.origin.x + imageFrame.size.width - 2.0f - iconFrame.origin.x - iconFrame.size.width, imageFrame.size.height - 4.0f);
        
        _overlayIconMaskTopModel.frame = CGRectMake(iconFrame.origin.x, imageFrame.origin.y + 2.0f, iconFrame.size.width, iconFrame.origin.y - imageFrame.origin.y - 2.0f);
        _overlayIconMaskBottomModel.frame = CGRectMake(iconFrame.origin.x, iconFrame.origin.y + iconFrame.size.height, iconFrame.size.width, imageFrame.origin.y + imageFrame.size.height - 2.0f - iconFrame.origin.y - iconFrame.size.height);
    }
}

- (int)defaultOverlayActionType
{
    return TGMessageImageViewOverlayPlay;
}

@end
