#import "TGSharedMediaCacheSignals.h"

#import "TGDatabase.h"

@implementation TGSharedMediaCacheSignals

+ (SSignal *)cachedMediaForPeerId:(int64_t)peerId itemType:(TGSharedMediaCacheItemType)itemType important:(bool)important
{
    return [[SSignal alloc] initWithGenerator:^(SSubscriber *subscriber)
    {
        __block bool isCancelled = false;
        
        [TGDatabaseInstance() cachedMediaForPeerId:peerId itemType:itemType limit:128 important:important completion:^(NSArray *messages, __unused bool indexDownloaded)
        {
            [subscriber putNext:messages];
            
            [TGDatabaseInstance() cachedMediaForPeerId:peerId itemType:itemType limit:0 important:important completion:^(NSArray *messages, bool indexDownloaded)
            {
                [subscriber putNext:@(indexDownloaded)];
                [subscriber putNext:messages];
                [subscriber putCompletion];
            } buildIndex:false isCancelled:nil];
        } buildIndex:peerId <= INT_MIN isCancelled:^bool
        {
            return isCancelled;
        }];
        
        return [[SBlockDisposable alloc] initWithBlock:^
        {
            isCancelled = true;
        }];
    }];
}

@end
