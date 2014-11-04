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

@interface TGMediaPreviewTask () <ASWatcher>
{
    volatile bool _idCancelled;
    
    TGWorkerPool *_workerPool;
    TGWorkerTask *_workerTask;
    NSString *_uri;
    NSString *_targetFilePath;
}

@property (nonatomic, strong) ASHandle *actionHandle;
@property (nonatomic, copy) void (^completion)(bool);
@property (nonatomic, copy) void (^completionWithData)(NSData *);
@property (nonatomic, copy) void (^progress)(float);

@end

@implementation TGMediaPreviewTask

- (void)executeWithWorkerTask:(TGWorkerTask *)workerTask workerPool:(TGWorkerPool *)workerPool
{
    _workerTask = workerTask;
    _workerPool = workerPool;
    
    [_workerPool addTask:_workerTask];
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
        [ActionStageInstance() requestActor:[[NSString alloc] initWithFormat:@"/temporaryDownload/(%@)", uri] options:@{@"url": uri, @"path": targetFilePath == nil ? @"" : targetFilePath, @"cache": [[TGMediaStoreContext instance] temporaryFilesCache]} flags:0 watcher:self];
    }
    else
    {
        [ActionStageInstance() requestActor:[[NSString alloc] initWithFormat:@"/img/(download:%@)", uri] options:@{} flags:0 watcher:self];
    }
}

- (void)executeTempDownloadWithTargetFilePath:(NSString *)targetFilePath uri:(NSString *)uri progress:(void (^)(float))progress completionWithData:(void (^)(NSData *))completionWithData workerTask:(TGWorkerTask *)workerTask
{
    _actionHandle = [[ASHandle alloc] initWithDelegate:self];
    _targetFilePath = targetFilePath;
    _uri = uri;
    _completionWithData = completionWithData;
    _workerTask = workerTask;
    _progress = progress;
    
    [ActionStageInstance() requestActor:[[NSString alloc] initWithFormat:@"/temporaryDownload/(%@)", uri] options:@{@"url": uri} flags:0 watcher:self];
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
    
    if (_actionHandle != nil)
        [ActionStageInstance() removeWatcherByHandle:_actionHandle];
}

- (void)actorCompleted:(int)status path:(NSString *)__unused path result:(id)result
{
    if (_completion != nil)
        _completion(status == ASStatusSuccess);
    if (_completionWithData != nil)
        _completionWithData(status == ASStatusSuccess ? result : nil);
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
