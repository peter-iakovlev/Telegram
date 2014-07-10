/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGWorkerPool.h"

#import "TGWorker.h"
#import "TGWorkerTask.h"

#import "NSObject+TGLock.h"

@interface TGWorkerPool ()
{
    NSMutableArray *_taskList;
    TG_SYNCHRONIZED_DEFINE(_taskList);
}

@end

@implementation TGWorkerPool

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        _taskList = [[NSMutableArray alloc] init];
        TG_SYNCHRONIZED_INIT(_taskList);
    }
    return self;
}

+ (ASQueue *)processingQueue
{
    static ASQueue *queue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        queue = [[ASQueue alloc] initWithName:"org.telegram.workerPoolQueue"];
    });
    return queue;
}

- (void)addTask:(TGWorkerTask *)task
{
    TG_SYNCHRONIZED_BEGIN(_taskList);
    if (![_taskList containsObject:task])
        [_taskList addObject:task];
    TG_SYNCHRONIZED_END(_taskList);
    
    __weak TGWorkerTask *weakTask = task;
    
    [[TGWorkerPool processingQueue] dispatchOnQueue:^
    {
        bool executeTask = false;
        __strong TGWorkerTask *strongTask = weakTask;
        TG_SYNCHRONIZED_BEGIN(_taskList);
        if (strongTask != nil && [_taskList containsObject:strongTask])
        {
            executeTask = true;
            [_taskList removeObject:strongTask];
        }
        TG_SYNCHRONIZED_END(_taskList);
        
        if (executeTask)
            [strongTask execute];
    }];
}

- (void)removeTask:(TGWorkerTask *)task
{
    TG_SYNCHRONIZED_BEGIN(_taskList);
    [_taskList removeObject:task];
    TG_SYNCHRONIZED_END(_taskList);
}

@end
