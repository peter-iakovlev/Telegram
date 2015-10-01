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

#import "TGAppDelegate.h"

@interface TGVideoMessageViewModel ()
{
    TGVideoMediaAttachment *_video;
    int _videoSize;
    
    bool _progressVisible;
    
    CGPoint _boundOffset;
}

@end

@implementation TGVideoMessageViewModel

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

- (instancetype)initWithMessage:(TGMessage *)message imageInfo:(TGImageInfo *)imageInfo video:(TGVideoMediaAttachment *)video authorPeer:(id)authorPeer context:(TGModernViewContext *)context replyHeader:(TGMessage *)replyHeader replyAuthor:(id)replyAuthor
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
        [TGImageMessageViewModel calculateImageSizesForImageSize:video.dimensions thumbnailSize:&thumbnailSize renderSize:&renderSize squareAspect:message.messageLifetime > 0 && message.messageLifetime <= 60 && message.layer >= 17];
        
        [previewUri appendFormat:@"&width=%d&height=%d&renderWidth=%d&renderHeight=%d", (int)thumbnailSize.width, (int)thumbnailSize.height, (int)renderSize.width, (int)renderSize.height];
        
        [previewUri appendFormat:@"&legacy-video-file-path=%@", legacyVideoFilePath];
        if (legacyThumbnailCacheUri != nil)
            [previewUri appendFormat:@"&legacy-thumbnail-cache-url=%@", legacyThumbnailCacheUri];
        
        if (message.messageLifetime > 0 && message.messageLifetime <= 60 && message.layer >= 17)
            [previewUri appendString:@"&secret=1"];
        
        [previewImageInfo addImageWithSize:renderSize url:previewUri];
    }
    
    self = [super initWithMessage:message imageInfo:previewImageInfo authorPeer:authorPeer context:context forwardPeer:nil forwardMessageId:0 replyHeader:replyHeader replyAuthor:replyAuthor caption:video.caption textCheckingResults:video.textCheckingResults];
    if (self != nil)
    {
        _video = video;
        [_video.videoInfo urlWithQuality:0 actualQuality:NULL actualSize:&_videoSize];
        
        if (message.messageLifetime > 0 && message.messageLifetime <= 60 && message.layer >= 17)
        {
            self.isSecret = true;
            
            [self enableInstantPreview];
        }
        
        int minutes = video.duration / 60;
        int seconds = video.duration % 60;
        
        if (self.isSecret)
            [self.imageModel setAdditionalDataString:[self defaultAdditionalDataString]];
        else
            [self.imageModel setAdditionalDataString:[[NSString alloc] initWithFormat:@"%d:%02d", minutes, seconds]];
    }
    return self;
}

- (void)updateMessage:(TGMessage *)message viewStorage:(TGModernViewStorage *)viewStorage sizeUpdated:(bool *)sizeUpdated
{
    [super updateMessage:message viewStorage:viewStorage sizeUpdated:sizeUpdated];
    
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
            [TGImageMessageViewModel calculateImageSizesForImageSize:video.dimensions thumbnailSize:&thumbnailSize renderSize:&renderSize squareAspect:message.messageLifetime > 0 && message.messageLifetime <= 60 && message.layer >= 17];
            
            [previewUri appendFormat:@"&width=%d&height=%d&renderWidth=%d&renderHeight=%d", (int)thumbnailSize.width, (int)thumbnailSize.height, (int)renderSize.width, (int)renderSize.height];
            
            [previewUri appendFormat:@"&legacy-video-file-path=%@", legacyVideoFilePath];
            if (legacyThumbnailCacheUri != nil)
                [previewUri appendFormat:@"&legacy-thumbnail-cache-url=%@", legacyThumbnailCacheUri];
            
            if (message.messageLifetime > 0 && message.messageLifetime <= 60 && message.layer >= 17)
                [previewUri appendString:@"&secret=1"];
            
            [previewImageInfo addImageWithSize:renderSize url:previewUri];
        }
        
        [self updateImageInfo:previewImageInfo];
    }
}

- (void)updateMediaAvailability:(bool)mediaIsAvailable viewStorage:(TGModernViewStorage *)__unused viewStorage
{
    //_touchAreaModel.touchesBeganAction = mediaIsAvailable ? @"openMediaRequested" : @"mediaDownloadRequested";
    
    [super updateMediaAvailability:mediaIsAvailable viewStorage:viewStorage];
}

- (void)updateProgress:(bool)progressVisible progress:(float)progress viewStorage:(TGModernViewStorage *)viewStorage animated:(bool)animated
{
    [super updateProgress:progressVisible progress:progress viewStorage:viewStorage animated:animated];
    
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
        if (self.isSecret)
            labelText = [self defaultAdditionalDataString];
        else
        {
            int minutes = _video.duration / 60;
            int seconds = _video.duration % 60;
            labelText = [[NSString alloc] initWithFormat:@"%d:%02d", minutes, seconds];
        }
    }
    
    [self.imageModel setAdditionalDataString:labelText];
}

- (bool)instantPreviewGesture
{
    return false;
}

- (void)bindSpecialViewsToContainer:(UIView *)container viewStorage:(TGModernViewStorage *)viewStorage atItemPosition:(CGPoint)itemPosition
{
    _boundOffset = itemPosition;
    
    [super bindSpecialViewsToContainer:container viewStorage:viewStorage atItemPosition:itemPosition];
}

- (void)bindViewToContainer:(UIView *)container viewStorage:(TGModernViewStorage *)viewStorage
{
    _boundOffset = CGPointZero;
    
    [super bindViewToContainer:container viewStorage:viewStorage];
}

- (void)layoutForContainerSize:(CGSize)containerSize
{
    [super layoutForContainerSize:containerSize];
}

- (int)defaultOverlayActionType
{
    if (self.isSecret)
        return [super defaultOverlayActionType];
    
    return TGMessageImageViewOverlayPlay;
}

@end
