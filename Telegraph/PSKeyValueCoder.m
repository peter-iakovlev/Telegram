#import "PSKeyValueCoder.h"

#import <pthread.h>

pthread_rwlock_t classNameCacheLock = PTHREAD_RWLOCK_INITIALIZER;

NSMutableDictionary *classNameCache()
{
    static NSMutableDictionary *dict = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        dict = [[NSMutableDictionary alloc] init];
    });
    
    return dict;
}

@implementation PSKeyValueCoder

+ (Class<PSCoding>)classForName:(NSString *)name
{
    if (name == nil)
        return nil;
    
    Class<PSCoding> result = nil;
    
    pthread_rwlock_rdlock(&classNameCacheLock);
    result = [classNameCache() objectForKey:name];
    pthread_rwlock_unlock(&classNameCacheLock);
    
    if (result == nil)
    {
        result = NSClassFromString(name);
        if (result != nil)
        {
            pthread_rwlock_wrlock(&classNameCacheLock);
            classNameCache()[name] = result;
            pthread_rwlock_unlock(&classNameCacheLock);
        }
    }
    
    return result;
}

- (void)encodeString:(NSString *)__unused string forKey:(NSString *)__unused key
{
}

- (void)encodeInt32:(int32_t)__unused number forKey:(NSString *)__unused key
{
}

- (void)encodeInt64:(int64_t)__unused number forKey:(NSString *)__unused key
{
}

- (void)encodeObject:(id<PSCoding>)__unused object forKey:(NSString *)__unused key
{
}

- (NSString *)decodeStringForKey:(NSString *)__unused key
{
    return nil;
}

- (int32_t)decodeInt32ForKey:(NSString *)__unused key
{
    return 0;
}

- (int64_t)decodeInt64ForKey:(NSString *)__unused key
{
    return 0;
}

- (id<PSCoding>)decodeObjectForKey:(NSString *)__unused key
{
    return nil;
}

@end
