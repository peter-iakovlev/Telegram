#import "TGRemoteFileSignal.h"

#import "TGTelegramNetworking.h"
#import "TGNetworkWorker.h"

#import "MultipartFetch.h"
#import "TelegramMediaResources.h"

#import "MediaBoxContexts.h"

@implementation TGRemoteFileDataEvent

- (instancetype)initWithData:(NSData *)data
{
    self = [super init];
    if (self != nil)
    {
        _data = data;
    }
    return self;
}

@end

@implementation TGRemoteFileProgressEvent

- (instancetype)initWithProgress:(CGFloat)progress
{
    self = [super init];
    if (self != nil)
    {
        _progress = progress;
    }
    return self;
}

@end

@implementation TGRemoteFileSignal

+ (SSignal *)partsForLocation:(TLInputFileLocation *)location datacenterId:(NSInteger)datacenterId size:(NSUInteger)size mediaTypeTag:(TGNetworkMediaTypeTag)mediaTypeTag
{
    TLRPCupload_getFile$upload_getFile *getFile = [[TLRPCupload_getFile$upload_getFile alloc] init];
    getFile.location = location;
    getFile.offset = 0;
    
    int32_t updatedLimit = (int32_t)size;
    if (updatedLimit == 0) {
        updatedLimit = 1 * 1024 * 1024;
    }
    while (updatedLimit % 4096 != 0 || 1048576 % updatedLimit != 0) {
        updatedLimit++;
    }
    
    getFile.limit = updatedLimit;
    
    return [[[TGTelegramNetworking instance] downloadWorkerForDatacenterId:datacenterId type:mediaTypeTag] mapToSignal:^SSignal *(TGNetworkWorkerGuard *worker)
    {
        return [[[TGTelegramNetworking instance] requestSignal:getFile worker:worker] map:^id (id next)
        {
            if ([next isKindOfClass:[TLupload_File class]])
            {
                TLupload_File *part = next;
                if ([part isKindOfClass:[TLupload_File$upload_file class]]) {
                    return [[TGRemoteFileDataEvent alloc] initWithData:((TLupload_File$upload_file *)part).bytes];
                } else {
                    return [[TGRemoteFileDataEvent alloc] initWithData:[NSData data]];
                }
            }
            else
                return [[TGRemoteFileProgressEvent alloc] initWithProgress:[next floatValue]];
        }];
    }];
}

+ (SSignal *)partsForWebLocation:(TLInputWebFileLocation *)location datacenterId:(NSInteger)datacenterId size:(NSUInteger)size mediaTypeTag:(TGNetworkMediaTypeTag)mediaTypeTag
{
    TLRPCupload_getWebFile$upload_getWebFile *getFile = [[TLRPCupload_getWebFile$upload_getWebFile alloc] init];
    getFile.location = location;
    getFile.offset = 0;
    getFile.limit = size == 0 ? (1024 * 1024) : (int32_t)size;
    
    return [[[TGTelegramNetworking instance] downloadWorkerForDatacenterId:datacenterId type:mediaTypeTag] mapToSignal:^SSignal *(TGNetworkWorkerGuard *worker)
    {
        return [[[TGTelegramNetworking instance] requestSignal:getFile worker:worker] map:^id (id next)
        {
            if ([next isKindOfClass:[TLupload_WebFile class]])
            {
                TLupload_WebFile *part = next;
                return [[TGRemoteFileDataEvent alloc] initWithData:part.bytes];
            }
            else
                return [[TGRemoteFileProgressEvent alloc] initWithProgress:[next floatValue]];
        }];
}];
}

+ (SSignal *)multipartDownload:(TLInputFileLocation *)location datacenterId:(NSInteger)datacenterId size:(NSUInteger)size mediaTypeTag:(TGNetworkMediaTypeTag)mediaTypeTag
{
    id resource = nil;
    if ([location isKindOfClass:[TLInputFileLocation$inputFileLocation class]]) {
        TLInputFileLocation$inputFileLocation *concreteLocation = (TLInputFileLocation$inputFileLocation *)location;
        resource = [[CloudFileMediaResource alloc] initWithDatacenterId:(int32_t)datacenterId volumeId:concreteLocation.volume_id localId:concreteLocation.local_id secret:concreteLocation.secret size:size == 0 ? nil : @(size) legacyCacheUrl:nil legacyCachePath:nil mediaType:@(mediaTypeTag)];
    } else if ([location isKindOfClass:[TLInputFileLocation$inputDocumentFileLocation class]]) {
        TLInputFileLocation$inputDocumentFileLocation *concreteLocation = (TLInputFileLocation$inputDocumentFileLocation *)location;
        resource = [[CloudDocumentMediaResource alloc] initWithDatacenterId:(int32_t)datacenterId fileId:concreteLocation.n_id accessHash:concreteLocation.access_hash size:size == 0 ? nil : @(size) mediaType:@(mediaTypeTag)];
    }
    
    if (resource != nil) {
        return [multipartFetch(resource, size == 0 ? nil : @(size), NSMakeRange(0, INT32_MAX), mediaTypeTag) map:^id(MediaResourceDataFetchResult *next) {
            return [[TGRemoteFileDataEvent alloc] initWithData:next.data];
        }];
    }
    
    NSUInteger partSize = 0;
    if (size >= 2 * 1024 * 1024)
        partSize = 512 * 1024;
    else
        partSize = 16 * 1024;
    
    NSUInteger numberOfParts = size / partSize + (size % partSize == 0 ? 0 : 1);
    
    SSignal *downloadSignal = [[[TGTelegramNetworking instance] downloadWorkerForDatacenterId:datacenterId type:mediaTypeTag] mapToSignal:^SSignal *(TGNetworkWorkerGuard *worker) {
        SSignal *parts = [SSignal complete];
        for (NSUInteger index = 0; index < numberOfParts; index++) {
            TLRPCupload_getFile$upload_getFile *getFile = [[TLRPCupload_getFile$upload_getFile alloc] init];
            getFile.location = location;
            getFile.offset = (int32_t)(index * partSize);
            
            int32_t updatedLimit = (int32_t)partSize;
            while (updatedLimit % 4096 != 0 || 1048576 % updatedLimit != 0) {
                updatedLimit++;
            }
            getFile.limit = updatedLimit;
            
            SSignal *part = [[[TGTelegramNetworking instance] requestSignal:getFile worker:worker] map:^id (id next) {
                if ([next isKindOfClass:[TLupload_File class]]) {
                    TLupload_File *part = next;
                    if ([part isKindOfClass:[TLupload_File$upload_file class]]) {
                        return [[TGRemoteFileDataEvent alloc] initWithData:((TLupload_File$upload_file *)part).bytes];
                    } else {
                        return [[TGRemoteFileDataEvent alloc] initWithData:[NSData data]];
                    }
                } else {
                    float baseProgress = (float)(index * partSize) / (float)size;
                    float partProgress = ([next floatValue] * partSize) / size;
                    return [[TGRemoteFileProgressEvent alloc] initWithProgress:MIN(1.0f, baseProgress + partProgress)];
                }
            }];
            
            parts = [parts then:part];
        }
        
        return parts;
    }];
    
    return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber) {
        SAtomic *data = [[SAtomic alloc] initWithValue:[[NSMutableData alloc] init]];
        return [downloadSignal startWithNext:^(id next) {
            if ([next isKindOfClass:[TGRemoteFileProgressEvent class]]) {
                [subscriber putNext:@(((TGRemoteFileProgressEvent *)next).progress)];
            } else if ([next isKindOfClass:[TGRemoteFileDataEvent class]]) {
                [data modify:^id(NSMutableData *data) {
                    [data appendData:((TGRemoteFileDataEvent *)next).data];
                    return data;
                }];
            }
        } error:^(id error) {
            [subscriber putError:error];
        } completed:^{
            NSData *result = [data with:^id(NSData *data) {
                return data;
            }];
            [subscriber putNext:result];
            [subscriber putCompletion];
        }];
    }];
}

+ (SSignal *)multipartWebDownload:(TLInputWebFileLocation *)location datacenterId:(NSInteger)datacenterId size:(NSUInteger)size mediaTypeTag:(TGNetworkMediaTypeTag)mediaTypeTag
{
    NSUInteger partSize = 0;
    if (size >= 2 * 1024 * 1024)
        partSize = 512 * 1024;
    else
        partSize = 12 * 1024;
    
    NSUInteger numberOfParts = size / partSize + (size % partSize == 0 ? 0 : 1);
    
    SSignal *downloadSignal = [[[TGTelegramNetworking instance] downloadWorkerForDatacenterId:datacenterId type:mediaTypeTag] mapToSignal:^SSignal *(TGNetworkWorkerGuard *worker) {
        SSignal *parts = [SSignal complete];
        for (NSUInteger index = 0; index < numberOfParts; index++) {
            TLRPCupload_getWebFile$upload_getWebFile *getFile = [[TLRPCupload_getWebFile$upload_getWebFile alloc] init];
            getFile.location = location;
            getFile.offset = (int32_t)(index * partSize);
            getFile.limit = (int32_t)partSize;
            
            SSignal *part = [[[TGTelegramNetworking instance] requestSignal:getFile worker:worker] map:^id (id next) {
                if ([next isKindOfClass:[TLupload_WebFile class]]) {
                    TLupload_WebFile *part = next;
                    return [[TGRemoteFileDataEvent alloc] initWithData:part.bytes];
                } else {
                    float baseProgress = (float)(index * partSize) / (float)size;
                    float partProgress = ([next floatValue] * partSize) / size;
                    return [[TGRemoteFileProgressEvent alloc] initWithProgress:MIN(1.0f, baseProgress + partProgress)];
                }
            }];
            
            parts = [parts then:part];
        }
        
        return parts;
    }];
    
    return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber) {
        SAtomic *data = [[SAtomic alloc] initWithValue:[[NSMutableData alloc] init]];
        return [downloadSignal startWithNext:^(id next) {
            if ([next isKindOfClass:[TGRemoteFileProgressEvent class]]) {
                [subscriber putNext:@(((TGRemoteFileProgressEvent *)next).progress)];
            } else if ([next isKindOfClass:[TGRemoteFileDataEvent class]]) {
                [data modify:^id(NSMutableData *data) {
                    [data appendData:((TGRemoteFileDataEvent *)next).data];
                    return data;
                }];
            }
        } error:^(id error) {
            [subscriber putError:error];
        } completed:^{
            NSData *result = [data with:^id(NSData *data) {
                return data;
            }];
            [subscriber putNext:result];
            [subscriber putCompletion];
        }];
    }];
}

+ (SSignal *)dataForLocation:(TLInputFileLocation *)location datacenterId:(NSInteger)datacenterId size:(NSUInteger)size reportProgress:(bool)reportProgress mediaTypeTag:(TGNetworkMediaTypeTag)mediaTypeTag
{
    if (true || size >= 1 * 1024 * 1024) {
        return [[[self multipartDownload:location datacenterId:datacenterId size:size mediaTypeTag:mediaTypeTag] filter:^bool(id next) {
            if (!reportProgress) {
                return ![next respondsToSelector:@selector(floatValue)];
            } else {
                return true;
            }
        }] reduceLeft:[[NSMutableData alloc] init] with:^id(NSMutableData *current, id event) {
            if ([event isKindOfClass:[TGRemoteFileDataEvent class]] && ((TGRemoteFileDataEvent *)event).data != nil) {
                [current appendData:((TGRemoteFileDataEvent *)event).data];
            }
            return current;
        }];
    } else {
        return [[[self partsForLocation:location datacenterId:datacenterId size:size mediaTypeTag:mediaTypeTag] map:^id(id next)
        {
            if ([next isKindOfClass:[TGRemoteFileDataEvent class]])
                return [next data];
            else if (reportProgress && [next isKindOfClass:[TGRemoteFileProgressEvent class]])
                return @([(TGRemoteFileProgressEvent *)next progress]);
            
            return nil;
        }] filter:^bool(id value)
        {
            return value != nil;
        }];
    }
}

+ (SSignal *)dataForWebLocation:(TLInputWebFileLocation *)location datacenterId:(NSInteger)datacenterId size:(NSUInteger)size reportProgress:(bool)reportProgress mediaTypeTag:(TGNetworkMediaTypeTag)mediaTypeTag {
    if (size >= 1 * 1024 * 1024) {
        return [[self multipartWebDownload:location datacenterId:datacenterId size:size mediaTypeTag:mediaTypeTag] filter:^bool(id next) {
            if (!reportProgress) {
                return ![next respondsToSelector:@selector(floatValue)];
            } else {
                return true;
            }
        }];
    } else {
        return [[[self partsForWebLocation:location datacenterId:datacenterId size:size mediaTypeTag:mediaTypeTag] map:^id(id next)
        {
            if ([next isKindOfClass:[TGRemoteFileDataEvent class]])
                return [next data];
            else if (reportProgress && [next isKindOfClass:[TGRemoteFileProgressEvent class]])
                return @([(TGRemoteFileProgressEvent *)next progress]);
            
            return nil;
        }] filter:^bool(id value)
        {
            return value != nil;
        }];
    }
}

@end
