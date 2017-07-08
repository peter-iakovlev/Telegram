#import "TGModernSendMessageActor.h"

#import "TL/TLMetaScheme.h"

#import "ActionStage.h"
#import "TGTimer.h"

#import "TGPreparedMessage.h"
#import "TGPreparedLocalImageMessage.h"
#import "TGPreparedLocalVideoMessage.h"
#import "TGPreparedLocalDocumentMessage.h"

#import "TGUpdateStateRequestBuilder.h"

#import "TGNetworkWorker.h"

#import "TGLiveUploadActor.h"

#import "TGTelegraph.h"

#import "TGAppDelegate.h"

@interface TGModernSendMessageActor ()
{
    TGTimer *_timeoutTimer;
    NSTimeInterval _timeout;
    
    bool _notifiedUploadsStarted;
    
    NSMutableDictionary *_uploadingActorPathToFileUrl;
    NSMutableDictionary *_uploadingProgressActorPaths;
    NSMutableDictionary *_completedUploads;
    
    id _activityHolder;
}

@end

@implementation TGModernSendMessageActor

- (instancetype)initWithPath:(NSString *)path
{
    self = [super initWithPath:path];
    if (self != nil)
    {
        _actionHandle = [[ASHandle alloc] initWithDelegate:self releaseOnMainThread:false];
        _uploadingActorPathToFileUrl = [[NSMutableDictionary alloc] init];
        _uploadingProgressActorPaths = [[NSMutableDictionary alloc] init];
        _completedUploads = [[NSMutableDictionary alloc] init];
        _uploadProgress = -1.0f;
        _sendActivity = true;
        _disposables = [[SDisposableSet alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [self clearFailTimeout];
    
    [_actionHandle reset];
    [ActionStageInstance() removeWatcher:self];
    
    [_disposables dispose];
}

- (void)prepare:(NSDictionary *)options
{
    if ([options[@"preparedMessage"] isKindOfClass:[TGPreparedMessage class]])
        _preparedMessage = options[@"preparedMessage"];
    
    [super prepare:options];
}

- (void)execute:(NSDictionary *)__unused options
{
    if (_preparedMessage == nil)
        [self _fail];
    else
        [self _commitSend];
}

+ (NSTimeInterval)defaultTimeoutInterval
{
#if TARGET_IPHONE_SIMULATOR
    //return 5.0;
#endif
    return 5.0 * 60.0;
}

- (void)setupFailTimeout:(NSTimeInterval)timeout
{
    [self clearFailTimeout];
    
    _timeout = timeout;
    if (_timeout > DBL_EPSILON)
    {
        ASHandle *actionHandle = _actionHandle;
        _timeoutTimer = [[TGTimer alloc] initWithTimeout:_timeout repeat:false completion:^
        {
            [actionHandle requestAction:@"failTimeoutTimerEvent" options:nil];
        } queue:[ActionStageInstance() globalStageDispatchQueue]];
        [_timeoutTimer start];
    }
}

- (void)restartFailTimeoutIfRunning
{
    if (_timeout > DBL_EPSILON)
        [_timeoutTimer resetTimeout:_timeout];
}

- (void)clearFailTimeout
{
    if (_timeoutTimer != nil)
    {
        [_timeoutTimer invalidate];
        _timeoutTimer = nil;
    }
}

- (NSString *)pathForLocalImagePath:(NSString *)path
{
    if ([path hasPrefix:@"upload/"])
    {
        NSString *localFileUrl = [path substringFromIndex:7];
        NSString *imagePath = [[[TGAppDelegate documentsPath] stringByAppendingPathComponent:@"upload"] stringByAppendingPathComponent:localFileUrl];
        
        return imagePath;
    }
    else if ([path hasPrefix:@"file://"])
        return [path substringFromIndex:@"file://".length];
    
    return path;
}

- (int64_t)peerId
{
    return 0;
}

- (bool)_encryptUploads
{
    return false;
}

- (void)_commitSend
{
    [self _fail];
}

- (void)_cancelUploads
{
    [_uploadingActorPathToFileUrl enumerateKeysAndObjectsUsingBlock:^(NSString *actorPath, __unused NSString *fileUrl, __unused BOOL *stop)
    {
        [ActionStageInstance() removeWatcher:self fromPath:actorPath];
    }];
}

- (void)_fail
{
    [self clearFailTimeout];
    [self _cancelUploads];
    
    NSString *path = self.path;
    int64_t peerId = [self peerId];
    
    [ActionStageInstance() actionFailed:self.path reason:-1];
    
    [TGUpdateStateRequestBuilder processDelayedMessagesInConversation:peerId completedPath:path];
}

- (void)_success:(id)result
{
    [self clearFailTimeout];
    
    NSString *path = self.path;
    int64_t peerId = [self peerId];
    
    [ActionStageInstance() actionCompleted:self.path result:result];
    
    [TGUpdateStateRequestBuilder processDelayedMessagesInConversation:peerId completedPath:path];
}

- (void)cancel
{
    [self _fail];
    
    [_disposables dispose];
    
    [super cancel];
}

#pragma mark -

- (int64_t)conversationIdForActivity
{
    return 0;
}

- (int64_t)accessHashForActivity {
    return 0;
}

- (NSString *)activityType
{
    if (_sendActivity) {
        if ([_preparedMessage isKindOfClass:[TGPreparedLocalImageMessage class]])
            return @"uploadingPhoto";
        else if ([_preparedMessage isKindOfClass:[TGPreparedLocalVideoMessage class]])
            return @"uploadingVideo";
        else if ([_preparedMessage isKindOfClass:[TGPreparedLocalDocumentMessage class]]) {
            for (id attribute in ((TGPreparedLocalDocumentMessage *)_preparedMessage).attributes) {
                if ([attribute isKindOfClass:[TGDocumentAttributeAudio class]]) {
                    if (((TGDocumentAttributeAudio *)attribute).isVoice) {
                        return nil;
                    }
                }
            }
            return @"uploadingDocument";
        }
    }
    
    return nil;
}

- (void)uploadFilesWithExtensions:(NSArray *)filePathsAndExtensions mediaTypeTag:(TGNetworkMediaTypeTag)mediaTypeTag
{
    if (filePathsAndExtensions.count == 0)
        return;
    
    if (_activityHolder == nil && [self conversationIdForActivity] != 0 && [self activityType] != nil)
    {
        _activityHolder = [[TGTelegraphInstance activityManagerForConversationId:[self conversationIdForActivity] accessHash:[self accessHashForActivity]] addActivityWithType:[self activityType] priority:2];
    }
    
    _notifiedUploadsStarted = false;
    
    NSString *queueName = @"sendMessageUploads";
    
    static int actionId = 0;
    
    int dataIndex = 0;
    
    NSMutableArray *requests = [[NSMutableArray alloc] init];
    
    for (NSArray *itemDesc in filePathsAndExtensions)
    {
#ifdef DEBUG
        NSAssert(itemDesc.count >= 2, @"Path should contain extension info");
#endif
        
        NSString *fileUrl = nil;
        if ([itemDesc[0] isKindOfClass:[NSData class]])
        {
            fileUrl = [[NSString alloc] initWithFormat:@"embedded-data://%d", dataIndex++];
        }
        else
            fileUrl = itemDesc[0];
        
        NSString *actorPath = [[NSString alloc] initWithFormat:@"/tg/upload/(sendMessage%d)", actionId++];
        _uploadingActorPathToFileUrl[actorPath] = fileUrl;
        
        if (itemDesc.count >= 3)
            _uploadingProgressActorPaths[actorPath] = itemDesc[2];
        
        NSMutableDictionary *options = [[NSMutableDictionary alloc] initWithDictionary:@{
            @"explicitQueueName": queueName,
            @"encrypt": @([self _encryptUploads]),
            @"ext": itemDesc[1]
        }];
        
        if ([itemDesc[0] isKindOfClass:[NSData class]])
            options[@"data"] = itemDesc[0];
        else
            options[@"file"] = [self pathForLocalImagePath:itemDesc[0]];
        
        options[@"inbandUploadLimit"] = @(2 * 1024);
        
        if (itemDesc.count >= 4)
            options[@"liveData"] = itemDesc[3];
        
        options[@"mediaTypeTag"] = @(mediaTypeTag);
        
        [requests addObject:@{@"actorPath":actorPath, @"options":options }];
    }
    
    for (NSDictionary *request in requests)
        [ActionStageInstance() requestActor:request[@"actorPath"] options:request[@"options"] watcher:self];
    
    [self beginUploadProgress];
}

- (void)beginUploadProgress
{
    if (_uploadProgress < 0.0f) // it may already be set by a file upload actor
    {
        _uploadProgress = 0.0f;
        
        [ActionStageInstance() dispatchMessageToWatchers:self.path messageType:@"messageProgress" message:@{@"mid": @(_preparedMessage.mid), @"progress": @(_uploadProgress)}];
    }
}

- (void)uploadsStarted
{
}

- (void)uploadProgressChanged
{
}

- (void)uploadsCompleted:(NSDictionary *)__unused filePathToUploadedFile
{
}

#pragma mark -

- (void)actionStageActionRequested:(NSString *)action options:(id)__unused options
{
    if ([action isEqualToString:@"failTimeoutTimerEvent"])
    {
        [self clearFailTimeout];
        
        [self cancel];
    }
}

- (void)updatePreDownloadsProgress:(float)preDownloadsProgress
{
    if (_uploadProgressContainsPreDownloads)
    {
        _uploadProgress = preDownloadsProgress / 2.0f;
        
        [ActionStageInstance() dispatchMessageToWatchers:self.path messageType:@"messageProgress" message:@{@"mid": @(_preparedMessage.mid), @"progress": @(_uploadProgress)}];
    }
}

- (void)actorReportedProgress:(NSString *)path progress:(float)progress
{
    if ([_uploadingProgressActorPaths[path] boolValue])
    {
        if (_uploadProgressContainsPreDownloads)
            _uploadProgress = 0.5f + progress / 2.0f;
        else
            _uploadProgress = progress;
        
        if (!_notifiedUploadsStarted)
        {
            _notifiedUploadsStarted = true;
            [self uploadsStarted];
        }
        else
            [self uploadProgressChanged];
        
        [ActionStageInstance() dispatchMessageToWatchers:self.path messageType:@"messageProgress" message:@{@"mid": @(_preparedMessage.mid), @"progress": @(_uploadProgress)}];
    }
}

- (void)actorCompleted:(int)status path:(NSString *)path result:(id)result
{
    if (_uploadingActorPathToFileUrl[path] != nil)
    {
        NSString *filePath = _uploadingActorPathToFileUrl[path];
        [_uploadingActorPathToFileUrl removeObjectForKey:path];
        
        if (status == ASStatusSuccess)
        {
            _completedUploads[filePath] = result;
            
            if (_uploadingActorPathToFileUrl.count == 0)
                [self uploadsCompleted:_completedUploads];
        }
        else
        {
            [self _fail];
        }
    }
}

- (void)acquireMediaUploadActivityHolderForPreparedMessage:(TGPreparedMessage *)__unused preparedMessage
{
}

@end

SSignalQueue *videoDownloadQueue() {
    static SSignalQueue *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[SSignalQueue alloc] init];
    });
    return instance;
}
