#import "TGMemoryCache.h"

#import <libkern/OSAtomic.h>

@interface TGMemoryCache ()
{
    OSSpinLock _lock;
    NSMutableDictionary *_dict;
}

@end

@implementation TGMemoryCache

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        _dict = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)setValue:(id)value forKey:(NSString *)key
{
    if (key != nil)
    {
        OSSpinLockLock(&_lock);
        if (value == nil)
            [_dict removeObjectForKey:key];
        else
            _dict[key] = value;
        OSSpinLockUnlock(&_lock);
    }
}

- (id)valueForKey:(NSString *)key
{
    if (key != nil)
    {
        OSSpinLockLock(&_lock);
        id value = _dict[key];
        OSSpinLockUnlock(&_lock);
        return value;
    }
    return nil;
}

@end
