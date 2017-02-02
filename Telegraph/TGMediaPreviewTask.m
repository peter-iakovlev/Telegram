/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGMediaPreviewTask.h"

#import "ActionStage.h"
#import "ASWatcher.h"

#import "TGWorkerPool.h"
#import "TGWorkerTask.h"

#import "TGStringUtils.h"
#import "TGImageInfo+Telegraph.h"

#import "TL/TLMetaScheme.h"

#import "TGMediaStoreContext.h"

#import "TGMapSnapshotterActor.h"
#import "TGMessage.h"

#import <SSignalKit/SSignalKit.h>

#import "TGTelegramNetworking.h"

@interface TGMediaPreviewTask () <ASWatcher>
{
    volatile bool _idCancelled;
    
    TGWorkerPool *_workerPool;
    TGWorkerTask *_workerTask;
    SThreadPoolTask *_task;
    NSString *_uri;
    NSString *_targetFilePath;
}

@property (nonatomic, strong) ASHandle *actionHandle;
@property (nonatomic, copy) void (^completion)(bool);
@property (nonatomic, copy) void (^completionWithData)(NSData *);
@property (nonatomic, copy) void (^completionWithImage)(UIImage *);
@property (nonatomic, copy) void (^progress)(float);

@end

@implementation TGMediaPreviewTask

- (void)executeWithWorkerTask:(TGWorkerTask *)workerTask workerPool:(TGWorkerPool *)workerPool
{
    _workerTask = workerTask;
    _workerPool = workerPool;
    
    [_workerPool addTask:_workerTask];
}

- (void)executeWithWorkerTask:(TGWorkerTask *)workerTask threadPool:(SThreadPool *)threadPool
{
    _task = [[SThreadPoolTask alloc] initWithBlock:^(bool (^cancelled)()) {
        if (!cancelled())
            [workerTask execute];
    }];
    [threadPool addTask:_task];
}

- (void)executeWithTargetFilePath:(NSString *)targetFilePath uri:(NSString *)uri completion:(void (^)(bool))completion workerTask:(TGWorkerTask *)workerTask
{
    [self executeWithTargetFilePath:targetFilePath uri:uri progress:nil completion:completion workerTask:workerTask];
}

- (void)executeWithTargetFilePath:(NSString *)targetFilePath uri:(NSString *)uri progress:(void (^)(float))progress completion:(void (^)(bool))completion workerTask:(TGWorkerTask *)workerTask
{
    _actionHandle = [[ASHandle alloc] initWithDelegate:self];
    _targetFilePath = targetFilePath;
    _uri = uri;
    _completion = completion;
    _workerTask = workerTask;
    _progress = progress;
    
    if ([uri hasPrefix:@"http://"] || [uri hasPrefix:@"https://"])
    {
        [ActionStageInstance() requestActor:[[NSString alloc] initWithFormat:@"/temporaryDownload/(%@)", [TGStringUtils stringByEscapingForActorURL:uri]] options:@{@"url": uri, @"path": targetFilePath == nil ? @"" : targetFilePath, @"cache": [[TGMediaStoreContext instance] temporaryFilesCache], @"mediaTypeTag": @(TGNetworkMediaTypeTagImage)} flags:0 watcher:self];
    }
    else
    {
        [ActionStageInstance() requestActor:[[NSString alloc] initWithFormat:@"/img/(download:%@)", [TGStringUtils stringByEscapingForActorURL:uri]] options:@{} flags:0 watcher:self];
    }
}

- (void)executeWithTargetFilePath:(NSString *)targetFilePath document:(TGDocumentMediaAttachment *)document progress:(void (^)(float))progress completion:(void (^)(bool))completion workerTask:(TGWorkerTask *)workerTask
{
    _actionHandle = [[ASHandle alloc] initWithDelegate:self];
    _targetFilePath = targetFilePath;
    _completion = completion;
    _workerTask = workerTask;
    _progress = progress;
    
    [ActionStageInstance() requestActor:[NSString stringWithFormat:@"/tg/media/document/(%d:%" PRId64 ":%@)", document.datacenterId, document.documentId, document.documentUri.length != 0 ? document.documentUri : @""] options:[[NSDictionary alloc] initWithObjectsAndKeys:document, @"documentAttachment", nil] flags:0 watcher:self];
}

- (void)executeTempDownloadWithTargetFilePath:(NSString *)targetFilePath uri:(NSString *)uri progress:(void (^)(float))progress completionWithData:(void (^)(NSData *))completionWithData workerTask:(TGWorkerTask *)workerTask
{
    _actionHandle = [[ASHandle alloc] initWithDelegate:self];
    _targetFilePath = targetFilePath;
    _uri = uri;
    _completionWithData = completionWithData;
    _workerTask = workerTask;
    _progress = progress;
    
    [ActionStageInstance() requestActor:[[NSString alloc] initWithFormat:@"/temporaryDownload/(%@)", [TGStringUtils stringByEscapingForActorURL:uri]] options:@{@"url": uri, @"mediaTypeTag": @(TGNetworkMediaTypeTagImage)} flags:0 watcher:self];
}

- (void)executeMultipartWithImageUri:(NSString *)imageUri targetFilePath:(NSString *)targetFilePath progress:(void (^)(float))progress completion:(void (^)(bool))completion
{
    _actionHandle = [[ASHandle alloc] initWithDelegate:self];
    
    int datacenterId = 0;
    int64_t volumeId = 0;
    int localId = 0;
    int64_t secret = 0;
    if (extractFileUrlComponents(imageUri, &datacenterId, &volumeId, &localId, &secret))
    {
        _progress = progress;
        _completion = completion;
        
        TLInputFileLocation$inputFileLocation *fileLocation = [[TLInputFileLocation$inputFileLocation alloc] init];
        fileLocation.volume_id = volumeId;
        fileLocation.local_id = (int32_t)localId;
        fileLocation.secret = secret;
        
        [ActionStageInstance() requestActor:[[NSString alloc] initWithFormat:@"/tg/multipart-file/(image:%" PRId64 ":%d:%d)", volumeId, localId, datacenterId] options:@{
            @"fileLocation": fileLocation,
            @"storeFilePath": targetFilePath,
            @"datacenterId": @(datacenterId),
            @"encryptionArgs": @{},
            @"mediaTypeTag": @(TGNetworkMediaTypeTagImage)
        } watcher:self];
    }
    else if (completion)
    {
        completion(false);
    }
}

- (void)executeWithMapSnapshotOptions:(TGMapSnapshotOptions *)snapshotOptions completionWithImage:(void (^)(UIImage *image))completionWithImage workerTask:(TGWorkerTask *)workerTask
{
    _actionHandle = [[ASHandle alloc] initWithDelegate:self];
    _completionWithImage = completionWithImage;
    _workerTask = workerTask;
    
    [ActionStageInstance() requestActor:[[NSString alloc] initWithFormat:@"/mapSnapshot/(%@)", [snapshotOptions uniqueIdentifier]] options:@{ @"options":snapshotOptions, @"cache": [[TGMediaStoreContext instance] temporaryFilesCache] } watcher:self];
}

- (void)dealloc
{
    if (_actionHandle != nil)
    {
        [_actionHandle reset];
        [ActionStageInstance() removeWatcherByHandle:_actionHandle];
    }
}

- (void)cancel
{
    _idCancelled = true;
    
    [_workerTask cancel];
    [_workerPool removeTask:_workerTask];
    
    [_task cancel];
    
    if (_actionHandle != nil)
        [ActionStageInstance() removeWatcherByHandle:_actionHandle];
}

- (void)actorCompleted:(int)status path:(NSString *)__unused path result:(id)result
{
    if (_completion != nil)
        _completion(status == ASStatusSuccess);
    if (_completionWithData != nil)
        _completionWithData(status == ASStatusSuccess ? result : nil);
    if (_completionWithImage != nil)
        _completionWithImage(status == ASStatusSuccess ? result : nil);
}

- (void)actorMessageReceived:(NSString *)__unused path messageType:(NSString *)messageType message:(id)message
{
    if ([messageType isEqualToString:@"progress"])
    {
        if (_progress)
            _progress([message floatValue]);
    }
}

@end
