#import "TGInstagramMessageViewModel.h"

#import "TGImageInfo.h"
#import "TGMessageImageViewModel.h"
#import "TGImageUtils.h"
#import "TGMessage.h"

#import "TGMessageImageView.h"
#import "TGImageManager.h"

#import "ActionStage.h"

#import "TGInstagramDataContentProperty.h"

#import "TGModernImageViewModel.h"

@interface TGInstagramMessageViewModel () <ASWatcher>
{
    NSString *_shortcode;
    NSString *_link;
    NSString *_originalText;
    
    TGInstagramDataContentProperty *_instagramData;
    
    bool _didRequestInfo;
}

@property (nonatomic, strong) ASHandle *actionHandle;

@end

@implementation TGInstagramMessageViewModel

- (CGFloat)maxSide
{
    return TGIsPad() ? 200.0f : 200.0f;
}

- (instancetype)initWithShortcode:(NSString *)shortcode message:(TGMessage *)message author:(TGUser *)author context:(TGModernViewContext *)context
{
    TGImageInfo *imageInfo = [[TGImageInfo alloc] init];
    
    CGFloat maxSide = [self maxSide];
    CGSize size = CGSizeMake(maxSide, maxSide);
    
    TGInstagramDataContentProperty *instagramData = message.contentProperties[@"instagram"];
    
    if (instagramData != nil)
    {
        [imageInfo addImageWithSize:size url:[[NSString alloc] initWithFormat:@"instagram-preview://?url=%@&width=%d&height=%d", instagramData.imageUrl, (int)size.width, (int)size.height]];
    }
    else
    {
        [imageInfo addImageWithSize:size url:[[NSString alloc] initWithFormat:@"instagram-preview://?empty=1&width=%d&height=%d", (int)size.width, (int)size.height]];
    }
    
    self = [super initWithMessage:message imageInfo:imageInfo author:author context:context];
    if (self != nil)
    {
        _actionHandle = [[ASHandle alloc] initWithDelegate:self];
        
        _shortcode = shortcode;
        _mediaIsAvailable = true;
        self.imageModel.frame = CGRectMake(0, 0, size.width, size.height);
        
        _originalText = message.text;
        _link = message.text;
        if ([_link hasPrefix:@"http://"])
            _link = [_link substringFromIndex:@"http://".length];
        else if ([_link hasPrefix:@"https://"])
            _link = [_link substringFromIndex:@"https://".length];
        
        _instagramData = instagramData;
        [self _updateInstagramData];
        
        [self.imageModel setAdditionalDataString:[self defaultAdditionalDataString]];
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
    if (_instagramData.mediaId != nil)
    {
        NSURL *clientUrl = [[NSURL alloc] initWithString:[[NSString alloc] initWithFormat:@"instagram://media?id=%@", _instagramData.mediaId]];
        if ([[UIApplication sharedApplication] canOpenURL:clientUrl])
        {
            [[UIApplication sharedApplication] openURL:clientUrl];
            return;
        }
    }
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[[NSString alloc] initWithFormat:@"%@", _originalText]]];
}

- (int)defaultOverlayActionType
{
    return TGMessageImageViewOverlayNone;
}

- (NSString *)defaultAdditionalDataString
{
    return _link;
}

- (void)_updateInstagramData
{
    if (_instagramData != nil)
    {
        CGFloat maxSide = [self maxSide];
        CGSize size = CGSizeMake(maxSide, maxSide);
        
        self.imageModel.uri = [[NSString alloc] initWithFormat:@"instagram-preview://?url=%@&width=%d&height=%d", _instagramData.imageUrl, (int)size.width, (int)size.height];
    }
}

- (void)bindViewToContainer:(UIView *)container viewStorage:(TGModernViewStorage *)viewStorage
{
    [super bindViewToContainer:container viewStorage:viewStorage];
    
    if (_instagramData == nil && _shortcode != nil)
    {
        _didRequestInfo = true;
        [ActionStageInstance() requestActor:[[NSString alloc] initWithFormat:@"/instagram/contentProperties/(%@)", _shortcode] options:@{@"shortcode": _shortcode, @"messageId": @(_mid)} flags:0 watcher:self];
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
    if ([path isEqualToString:[[NSString alloc] initWithFormat:@"/instagram/contentProperties/(%@)", _shortcode]])
    {
        TGDispatchOnMainThread(^
        {
            if (status == ASStatusSuccess)
            {
                _instagramData = result[@"instagram"];
                
                [self _updateInstagramData];
            }
        });
    }
}

@end
