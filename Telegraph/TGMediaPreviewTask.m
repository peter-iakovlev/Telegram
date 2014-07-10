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
    _actionHandle = [[ASHandle alloc] initWithDelegate:self];
    _targetFilePath = targetFilePath;
    _uri = uri;
    _completion = completion;
    _workerTask = workerTask;
    
    [ActionStageInstance() requestActor:[[NSString alloc] initWithFormat:@"/img/(download:%@)", uri] options:@{} flags:0 watcher:self];
    return;
    
    if (_uri.length != 0 && _targetFilePath.length != 0)
    {
        id inputFileLocation = nil;

        int datacenterId = 0;
        int64_t volumeId = 0;
        int localId = 0;
        int64_t secret = 0;
        if (extractFileUrlComponents(_uri, &datacenterId, &volumeId, &localId, &secret))
        {
            TLInputFileLocation$inputFileLocation *concreteLocation = [[TLInputFileLocation$inputFileLocation alloc] init];
            concreteLocation.volume_id = volumeId;
            concreteLocation.local_id = localId;
            concreteLocation.secret = secret;
            
            inputFileLocation = concreteLocation;
        }

        if (inputFileLocation != nil)
        {
            [ActionStageInstance() requestActor:[[NSString alloc] initWithFormat:@"/tg/multipart-file/(%@)", _uri] options:@{
                @"fileLocation": inputFileLocation,
                @"storeFilePath": _targetFilePath,
                @"datacenterId": @(datacenterId)
            } watcher:self];
        }
    }
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

- (void)actorCompleted:(int)status path:(NSString *)__unused path result:(id)__unused result
{
    if (_completion != nil)
        _completion(status == ASStatusSuccess);
}

@end
