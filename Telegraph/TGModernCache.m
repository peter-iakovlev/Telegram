#import "TGModernCache.h"

#import "ATQueue.h"

#import "PSLMDBKeyValueStore.h"

#import "TGStringUtils.h"

typedef enum {
    TGModernCacheKeyspaceGlobalProperties = 1,
    TGModernCacheKeyspaceLastUsageByPath = 2,
    TGModernCacheKeyspacePathAndSizeByLastUsage = 3
} TGModernCacheKeyspace;

typedef enum {
    TGModernCacheGlobalPropertySize = 1
} TGModernCacheGlobalProperty;

@interface TGModernCache ()
{
    NSString *_path;
    ATQueue *_queue;
    NSUInteger _maxSize;
    PSLMDBKeyValueStore *_keyValueStore;
}

@end

@implementation TGModernCache

- (instancetype)initWithPath:(NSString *)path size:(NSUInteger)size
{
    self = [super init];
    if (self != nil)
    {
        _path = path;
        [[NSFileManager defaultManager] createDirectoryAtPath:[_path stringByAppendingPathComponent:@"store"] withIntermediateDirectories:true attributes:nil error:nil];
        _maxSize = size;
        _queue = [[ATQueue alloc] init];
        _keyValueStore = [PSLMDBKeyValueStore storeWithPath:[_path stringByAppendingPathComponent:@"meta"] size:1 * 1024 * 1024];
    }
    return self;
}

- (void)dealloc
{
    PSLMDBKeyValueStore *keyValueStore = _keyValueStore;
    [_queue dispatch:^
    {
        [keyValueStore close];
    }];
}

- (NSUInteger)_getCurrentSize:(id<PSKeyValueReader>)reader
{
    NSMutableData *keyData = [[NSMutableData alloc] init];
    int8_t keyspace = TGModernCacheKeyspaceGlobalProperties;
    [keyData appendBytes:&keyspace length:1];
    int32_t property = TGModernCacheGlobalPropertySize;
    [keyData appendBytes:&property length:4];
    PSData key = {.data = (void *)keyData.bytes, .length = keyData.length};
    
    PSData value;
    if ([reader readValueForRawKey:&key value:&value])
    {
        if (value.length == 4)
        {
            int32_t currentSize = 0;
            memcpy(&currentSize, value.data, 4);
            return (NSUInteger)currentSize;
        }
    }
    
    return 0;
}

- (void)setCurrentSize:(id<PSKeyValueWriter>)writer size:(NSUInteger)size
{
    NSMutableData *keyData = [[NSMutableData alloc] init];
    int8_t keyspace = TGModernCacheKeyspaceGlobalProperties;
    [keyData appendBytes:&keyspace length:1];
    int32_t property = TGModernCacheGlobalPropertySize;
    [keyData appendBytes:&property length:4];
    PSData key = {.data = (void *)keyData.bytes, .length = keyData.length};
    
    int32_t sizeValue = (int32_t)size;
    
    [writer writeValueForRawKey:key.data keyLength:key.length value:(void *)&sizeValue valueLength:4];
}

- (NSString *)_filePathForKey:(NSData *)key
{
    return [[_path stringByAppendingPathComponent:@"store"] stringByAppendingPathComponent:[TGStringUtils stringByEncodingInBase64:key]];
}

- (void)_evictValuesOfTotalSize:(NSUInteger)totalSize removedSize:(NSUInteger *)removedSize readerWriter:(id<PSKeyValueReader,PSKeyValueWriter>)readerWriter
{
    NSMutableData *lowerBound = [[NSMutableData alloc] init];
    int8_t keyspace = TGModernCacheKeyspacePathAndSizeByLastUsage;
    [lowerBound appendBytes:&keyspace length:1];
    PSData lowerBoundKey = {.data = (void *)lowerBound.bytes, .length = lowerBound.length};

    NSMutableData *upperBound = [[NSMutableData alloc] init];
    int8_t afterKeyspace = keyspace + 1;
    [upperBound appendBytes:&afterKeyspace length:1];
    PSData upperBoundKey = {.data = (void *)upperBound.bytes, .length = upperBound.length};

    NSMutableArray *keysToRemove = [[NSMutableArray alloc] init];
    __block NSInteger remainingSize = (NSInteger)totalSize;
    __block NSUInteger blockRemovedSize = 0;

    NSMutableArray *filePathsToRemove = [[NSMutableArray alloc] init];

    [readerWriter enumerateKeysAndValuesBetweenLowerBoundKey:&lowerBoundKey upperBoundKey:&upperBoundKey options:PSKeyValueReaderEnumerationUpperBoundExclusive withBlock:^(PSConstData *key, PSConstData *value, __unused bool *stop)
    {
        [keysToRemove addObject:[[NSData alloc] initWithBytes:key->data length:key->length]];
        
        int32_t size = 0;
        memcpy(&size, value->data, 4);
        
        remainingSize -= (NSInteger)size;
        blockRemovedSize += (NSUInteger)size;
        
        NSData *originalKey = [[NSData alloc] initWithBytes:value->data + 4 length:value->length - 4];
        NSString *filePath = [self _filePathForKey:originalKey];
        
        NSMutableData *primaryKeyData = [[NSMutableData alloc] init];
        int8_t keyspace = TGModernCacheKeyspaceLastUsageByPath;
        [primaryKeyData appendBytes:&keyspace length:1];
        [primaryKeyData appendData:originalKey];
        [keysToRemove addObject:primaryKeyData];
        
        [filePathsToRemove addObject:filePath];
        
        if (stop && remainingSize <= 0)
            *stop = true;
    }];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    for (NSString *filePath in filePathsToRemove)
    {
        [fileManager removeItemAtPath:filePath error:nil];
    }

    for (NSData *keyData in keysToRemove)
    {
        PSData key = {.data = (void *)keyData.bytes, .length = keyData.length};
        [readerWriter deleteValueForRawKey:&key];
    }
    
    if (removedSize)
        *removedSize = blockRemovedSize;
}

- (void)_updateLastAccessDateForKey:(NSData *)key size:(NSUInteger)size readerWriter:(id<PSKeyValueReader,PSKeyValueWriter>)readerWriter
{
    NSMutableData *keyData = [[NSMutableData alloc] init];
    int8_t keyspace = TGModernCacheKeyspaceLastUsageByPath;
    [keyData appendBytes:&keyspace length:1];
    [keyData appendData:key];
    PSData k = {.data = (void *)keyData.bytes, .length = keyData.length};
    PSData value;
    if ([readerWriter readValueForRawKey:&k value:&value])
    {
        int32_t lastUsage = 0;
        memcpy(&lastUsage, value.data, 4);
        
        [readerWriter deleteValueForRawKey:&k];
        
        NSMutableData *indexData = [[NSMutableData alloc] init];
        keyspace = TGModernCacheKeyspacePathAndSizeByLastUsage;
        [indexData appendBytes:&keyspace length:1];
        [indexData appendBytes:&lastUsage length:4];
        [indexData appendData:key];
        
        PSData indexKey = {.data = (void *)indexData.bytes, .length = indexData.length};
        [readerWriter deleteValueForRawKey:&indexKey];
    }
    
    int32_t lastAccessDate = (int32_t)CFAbsoluteTimeGetCurrent();
    lastAccessDate = CFSwapInt32(lastAccessDate);
    
    [readerWriter writeValueForRawKey:k.data keyLength:k.length value:(void *)&lastAccessDate valueLength:4];
    
    NSMutableData *indexKey = [[NSMutableData alloc] init];
    keyspace = TGModernCacheKeyspacePathAndSizeByLastUsage;
    [indexKey appendBytes:&keyspace length:1];
    [indexKey appendBytes:&lastAccessDate length:4];
    [indexKey appendData:key];
    
    NSMutableData *indexValue = [[NSMutableData alloc] init];
    int32_t sizeValue = (int32_t)size;
    [indexValue appendBytes:&sizeValue length:4];
    [indexValue appendData:key];
    
    [readerWriter writeValueForRawKey:indexKey.bytes keyLength:indexKey.length value:indexValue.bytes valueLength:indexValue.length];
}

- (void)setValue:(NSData *)value forKey:(NSData *)key
{
    [_queue dispatch:^
    {
        [value writeToFile:[self _filePathForKey:key] atomically:false];
        
        [_keyValueStore readWriteInTransaction:^(id<PSKeyValueReader,PSKeyValueWriter> readerWriter)
        {
            NSUInteger currentSize = [self _getCurrentSize:readerWriter];
            if (currentSize + value.length > _maxSize)
            {
                NSUInteger removedSize = 0;
                [self _evictValuesOfTotalSize:value.length removedSize:&removedSize readerWriter:readerWriter];
                currentSize -= removedSize;
            }
            [self setCurrentSize:readerWriter size:currentSize + value.length];

            [self _updateLastAccessDateForKey:key size:value.length readerWriter:readerWriter];
        }];
    }];
}

- (void)getValueForKey:(NSData *)key completion:(void (^)(NSData *))completion
{
    [_queue dispatch:^
    {
        NSData *data = [[NSData alloc] initWithContentsOfFile:[self _filePathForKey:key]];
        if (data != nil)
        {
            [_keyValueStore readWriteInTransaction:^(id<PSKeyValueReader,PSKeyValueWriter> readerWriter)
            {
                NSMutableData *keyData = [[NSMutableData alloc] init];
                int8_t keyspace = TGModernCacheKeyspaceLastUsageByPath;
                [keyData appendBytes:&keyspace length:1];
                [keyData appendData:key];
                PSData k = {.data = (void *)keyData.bytes, .length = keyData.length};
                if ([readerWriter readValueForRawKey:&k value:NULL])
                {
                    [self _updateLastAccessDateForKey:key size:data.length readerWriter:readerWriter];
                }
            }];
        }
        
        if (completion)
            completion(data);
    }];
}

- (NSData *)getValueForKey:(NSData *)key
{
    __block NSData *result = nil;
    [_queue dispatch:^
    {
        [self getValueForKey:key completion:^(NSData *data)
        {
            result = data;
        }];
    } synchronous:true];
    
    return result;
}

- (bool)containsValueForKey:(NSData *)key
{
    return [[NSFileManager defaultManager] fileExistsAtPath:[self _filePathForKey:key]];
}

@end
