#import "TGBridgeSignalManager.h"

#import <libkern/OSAtomic.h>

@interface TGBridgeSignalManager()
{
    OSSpinLock _lock;
    NSMutableDictionary *_disposables;
}
@end

@implementation TGBridgeSignalManager

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        _disposables = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)dealloc
{
    NSArray *disposables = nil;
    OSSpinLockLock(&_lock);
    disposables = [_disposables allValues];
    OSSpinLockUnlock(&_lock);
    
    for (id<SDisposable> disposable in disposables)
    {
        [disposable dispose];
    }
}

- (bool)startSignalForKey:(NSString *)key producer:(SSignal *(^)())producer
{
    if (key == nil)
        return false;
    
    bool produce = false;
    OSSpinLockLock(&_lock);
    if (_disposables[key] == nil)
    {
        _disposables[key] = [[SMetaDisposable alloc] init];
        produce = true;
    }
    OSSpinLockUnlock(&_lock);
    
    if (produce)
    {
        __weak TGBridgeSignalManager *weakSelf = self;
        id<SDisposable> disposable = [producer() startWithNext:nil error:^(__unused id error)
        {
            __strong TGBridgeSignalManager *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                OSSpinLockLock(&strongSelf->_lock);
                [strongSelf->_disposables removeObjectForKey:key];
                OSSpinLockUnlock(&strongSelf->_lock);
            }
        } completed:^
        {
            __strong TGBridgeSignalManager *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                OSSpinLockLock(&strongSelf->_lock);
                [strongSelf->_disposables removeObjectForKey:key];
                OSSpinLockUnlock(&strongSelf->_lock);
            }
        }];
        
        OSSpinLockLock(&_lock);
        [(SMetaDisposable *)_disposables[key] setDisposable:disposable];
        OSSpinLockUnlock(&_lock);
    }
    
    return produce;
}

- (void)haltSignalForKey:(NSString *)key
{
    if (key == nil)
        return;

    OSSpinLockLock(&_lock);
    if (_disposables[key] != nil)
    {
        [_disposables[key] dispose];
        [_disposables removeObjectForKey:key];
    }
    OSSpinLockUnlock(&_lock);
}

- (void)haltAllSignals
{
    OSSpinLockLock(&_lock);
    for (NSObject <SDisposable> *disposable in _disposables.allValues)
        [disposable dispose];
    [_disposables removeAllObjects];
    OSSpinLockUnlock(&_lock);
}

@end
