#import "TGYoutubeMessageViewModel.h"

#import "TGImageInfo.h"
#import "TGMessageImageViewModel.h"
#import "TGImageUtils.h"
#import "TGMessage.h"

#import "TGMessageImageView.h"
#import "TGImageManager.h"

#import "ActionStage.h"

#import "TGYoutubeDataContentProperty.h"

#import "TGModernImageViewModel.h"

#import "TGViewController.h"

@interface TGYoutubeMessageViewModel () <ASWatcher>
{
    NSString *_videoId;
    NSString *_videoTitle;
    NSString *_videoUrl;
    
    TGYoutubeDataContentProperty *_youtubeData;
    
    bool _didRequestInfo;
}

@property (nonatomic, strong) ASHandle *actionHandle;

@end

@implementation TGYoutubeMessageViewModel

- (instancetype)initWithVideoId:(NSString *)videoId message:(TGMessage *)message author:(TGUser *)author context:(TGModernViewContext *)context
{
    TGImageInfo *imageInfo = [[TGImageInfo alloc] init];
    
    CGFloat maxSide = TGIsPad() ? 312.0f : ([TGViewController hasLargeScreen] ? 294.0f : 256.0f);
    CGSize size = CGSizeMake(maxSide, CGFloor(maxSide * 9.0f / 16.0f));
    
    [imageInfo addImageWithSize:size url:[[NSString alloc] initWithFormat:@"youtube-preview://?videoId=%@&width=%d&height=%d", videoId, (int)size.width, (int)size.height]];
    
    self = [super initWithMessage:message imageInfo:imageInfo author:author context:context];
    if (self != nil)
    {
        _actionHandle = [[ASHandle alloc] initWithDelegate:self];
        
        _videoId = videoId;
        _mediaIsAvailable = true;
        self.imageModel.frame = CGRectMake(0, 0, size.width, size.height);
        
        _videoUrl = message.text;
        if ([_videoUrl hasPrefix:@"http://"])
            _videoUrl = [_videoUrl substringFromIndex:@"http://".length];
        else if ([_videoUrl hasPrefix:@"https://"])
            _videoUrl = [_videoUrl substringFromIndex:@"https://".length];
        
        _youtubeData = message.contentProperties[@"youtube"];
        [self _updateYoutubeData:false];
    }
    return self;
}

- (void)dealloc
{
    if (_didRequestInfo)
    {
        [_actionHandle reset];
        [ActionStageInstance() removeWatcher:self];
    }
}

- (void)activateMedia
{
    NSURL *clientUrl = [[NSURL alloc] initWithString:[[NSString alloc] initWithFormat:@"youtube://watch?v=%@", _videoId]];
    if ([[UIApplication sharedApplication] canOpenURL:clientUrl])
    {
        [[UIApplication sharedApplication] openURL:clientUrl];
        return;
    }
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[[NSString alloc] initWithFormat:@"http://youtu.be/%@", _videoId]]];
}

- (int)defaultOverlayActionType
{
    return TGMessageImageViewOverlayNone;
}

- (NSString *)defaultAdditionalDataString
{
    if (_youtubeData != nil)
    {
        int hours = _youtubeData.duration / (60 * 60);
        int minutes = _youtubeData.duration % (60 * 60) / 60;
        int seconds = _youtubeData.duration % 60;
        
        if (hours != 0)
            return [[NSString alloc] initWithFormat:@"%d:%02d:%02d", hours, minutes, seconds];
        else
            return [[NSString alloc] initWithFormat:@"%d:%02d", minutes, seconds];
    }
    
    return nil;
}

- (void)_updateYoutubeData:(bool)animated
{
    [self.imageModel setAdditionalDataString:self.defaultAdditionalDataString animated:animated];
    if (_youtubeData != nil)
    {
        [self.imageModel setDetailStrings:@[_youtubeData.title == nil ? @"" : _youtubeData.title, _videoUrl == nil ? @"" : _videoUrl] animated:animated];
    }
    else
        [self.imageModel setDetailStrings:@[]];
}

- (void)bindViewToContainer:(UIView *)container viewStorage:(TGModernViewStorage *)viewStorage
{
    [super bindViewToContainer:container viewStorage:viewStorage];
    
    if (_youtubeData == nil && _videoId != nil)
    {
        _didRequestInfo = true;
        [ActionStageInstance() requestActor:[[NSString alloc] initWithFormat:@"/youtube/contentProperties/(%@)", _videoId] options:@{@"videoId": _videoId, @"messageId": @(_mid)} flags:0 watcher:self];
    }
}

- (void)unbindView:(TGModernViewStorage *)viewStorage
{
    [super unbindView:viewStorage];
    
    if (_didRequestInfo)
        [ActionStageInstance() removeWatcher:self];
}

- (void)layoutForContainerSize:(CGSize)containerSize
{
    [super layoutForContainerSize:containerSize];
}

- (void)actorCompleted:(int)status path:(NSString *)path result:(id)result
{
    if ([path isEqualToString:[[NSString alloc] initWithFormat:@"/youtube/contentProperties/(%@)", _videoId]])
    {
        TGDispatchOnMainThread(^
        {
            if (status == ASStatusSuccess)
            {
                _youtubeData = result[@"youtube"];
                [self _updateYoutubeData:true];
            }
        });
    }
}

@end
