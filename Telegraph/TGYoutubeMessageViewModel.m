#import "TGYoutubeMessageViewModel.h"

#import "TGImageInfo.h"
#import "TGMessageImageViewModel.h"
#import "TGImageUtils.h"

#import "TGMessageImageView.h"
#import "TGImageManager.h"

@interface TGYoutubeMessageViewModel ()
{
    NSString *_videoId;
    NSString *_videoTitle;
}

@end

@implementation TGYoutubeMessageViewModel

- (instancetype)initWithVideoId:(NSString *)videoId message:(TGMessage *)message author:(TGUser *)author context:(TGModernViewContext *)context
{
    TGImageInfo *imageInfo = [[TGImageInfo alloc] init];
    
    CGFloat maxSide = TGIsPad() ? 312.0f : 246.0f;
    CGSize size = CGSizeMake(maxSide, CGFloor(maxSide * 9.0f / 16.0f));
    
    [imageInfo addImageWithSize:size url:[[NSString alloc] initWithFormat:@"youtube-preview://?videoId=%@&width=%d&height=%d", videoId, (int)size.width, (int)size.height]];
    
    self = [super initWithMessage:message imageInfo:imageInfo author:author context:context];
    if (self != nil)
    {
        _videoId = videoId;
        _mediaIsAvailable = true;
        self.imageModel.frame = CGRectMake(0, 0, size.width, size.height);
        
        [self.imageModel setAdditionalDataString:[self defaultAdditionalDataString]];
    }
    return self;
}

- (void)activateMedia
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[[NSString alloc] initWithFormat:@"http://youtu.be/%@", _videoId]]];
}

- (int)defaultOverlayActionType
{
    return TGMessageImageViewOverlayPlay;
}

- (NSString *)defaultAdditionalDataString
{
    return [[NSString alloc] initWithFormat:@"http://youtu.be/%@", _videoId];
}

@end
