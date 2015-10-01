#import "TGGalleryPhotoActor.h"

#import "ASWatcher.h"
#import "ActionStage.h"

#import "TGMessage.h"
#import "TGRemoteImageView.h"

@interface TGGalleryPhotoActor () <ASWatcher>
{
    float _progressValue;
}

@property (nonatomic, strong) ASHandle *actionHandle;
@property (nonatomic, copy) void (^completion)(bool);
@property (nonatomic, copy) void (^progress)(float);

@end

@implementation TGGalleryPhotoActor

+ (void)load
{
    [ASActor registerActorClass:self];
}

+ (NSString *)genericPath
{
    return @"/galleryPhoto/@";
}

- (instancetype)initWithPath:(NSString *)path
{
    self = [super initWithPath:path];
    if (self != nil)
    {
        _actionHandle = [[ASHandle alloc] initWithDelegate:self];
    }
    return self;
}

- (void)dealloc
{
    [_actionHandle reset];
    [ActionStageInstance() removeWatcher:self];
}

- (void)execute:(NSDictionary *)options
{
    _completion = [options[@"completion"] copy];
    _progress = [options[@"progress"] copy];
    
    int messageId = [options[@"messageId"] intValue];
    id mediaId = [[TGMediaId alloc] initWithType: [options[@"isVideo"] boolValue] ? 1 : 2 itemId:[options[@"mediaId"] longLongValue]];
    int64_t conversationId = [options[@"conversationId"] longLongValue];
    NSString *uri = options[@"uri"];
    
    TGImageInfo *imageInfo = [[TGImageInfo alloc] init];
    [imageInfo addImageWithSize:CGSizeMake(90, 90) url:options[@"legacy-thumbnail-cache-url"]];
    
    NSDictionary *userProperties = @{
        @"messageId": @(messageId),
        @"mediaId": mediaId,
        @"conversationId": @(conversationId),
        @"imageInfo": imageInfo
    };
    
    [ActionStageInstance() requestActor:[[NSString alloc] initWithFormat:@"/img/(download:%@)", uri] options:@{@"userProperties": userProperties, @"contentHints": @(TGRemoteImageContentHintLargeFile)} flags:0 watcher:self];
}

- (void)watcherJoined:(ASHandle *)watcherHandle options:(NSDictionary *)options waitingInActorQueue:(bool)waitingInActorQueue
{
    [super watcherJoined:watcherHandle options:options waitingInActorQueue:waitingInActorQueue];
    
    [watcherHandle receiveActorMessage:self.path messageType:@"progress" message:@(_progressValue)];
}

- (void)actorCompleted:(int)status path:(NSString *)path result:(id)__unused result
{
    if ([path hasPrefix:@"/img/"])
    {
        if (_completion)
            _completion(status == ASStatusSuccess);
        
        [ActionStageInstance() actionCompleted:self.path result:nil];
    }
}

- (void)actorMessageReceived:(NSString *)path messageType:(NSString *)messageType message:(id)message
{
    if ([path hasPrefix:@"/img/"])
    {
        if ([messageType isEqualToString:@"progress"])
        {
            _progressValue = [message floatValue];
            
            if (_progress)
                _progress([message floatValue]);
        }
    }
}

@end
