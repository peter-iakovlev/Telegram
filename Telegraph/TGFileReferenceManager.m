#import "TGFileReferenceManager.h"
#import <LegacyComponents/TGMediaOriginInfo.h>
#import "TGDownloadMessagesSignal.h"

@interface TGFileReferenceManager ()
{
    SQueue *_queue;
    NSMutableDictionary<NSString *, SVariable *> *_processedOriginInfos;
}
@end

@implementation TGFileReferenceManager

- (instancetype)init {
    self = [super init];
    if (self != nil) {
        _queue = [[SQueue alloc] init];
        _processedOriginInfos = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (SSignal *)updatedOriginInfo:(TGMediaOriginInfo *)originInfo
{
    if (originInfo == nil)
        return [SSignal fail:nil];
    
    return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
    {
        NSString *key = originInfo.key;
        SMetaDisposable *disposable = [[SMetaDisposable alloc] init];
        [_queue dispatch:^
        {
            SVariable *info = _processedOriginInfos[key];
            if (info == nil)
            {
                info = [[SVariable alloc] init];
                [info set:[TGDownloadMessagesSignal remoteOriginInfo:originInfo]];
                _processedOriginInfos[key] = info;
            }
            
            [disposable setDisposable:[info.signal startWithNext:^(id next)
            {
                [subscriber putNext:next];
                [subscriber putCompletion];
            }]];
        }];
        return disposable;
    }];
}

@end
