#import "TGRemoteFileSignal.h"

#import "TGTelegramNetworking.h"
#import "TGNetworkWorker.h"

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
    getFile.limit = (int32_t)size;
    
    return [[[TGTelegramNetworking instance] downloadWorkerForDatacenterId:datacenterId type:mediaTypeTag] mapToSignal:^SSignal *(TGNetworkWorkerGuard *worker)
    {
        return [[[TGTelegramNetworking instance] requestSignal:getFile worker:worker] map:^id (id next)
        {
            if ([next isKindOfClass:[TLupload_File class]])
            {
                TLupload_File *part = next;
                return [[TGRemoteFileDataEvent alloc] initWithData:part.bytes];
            }
            else
                return [[TGRemoteFileProgressEvent alloc] initWithProgress:[next floatValue]];
        }];
    }];
}

+ (SSignal *)multipartDownload:(TLInputFileLocation *)location datacenterId:(NSInteger)datacenterId size:(NSUInteger)size mediaTypeTag:(TGNetworkMediaTypeTag)mediaTypeTag
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
            TLRPCupload_getFile$upload_getFile *getFile = [[TLRPCupload_getFile$upload_getFile alloc] init];
            getFile.location = location;
            getFile.offset = (int32_t)(index * partSize);
            getFile.limit = (int32_t)partSize;
            
            SSignal *part = [[[TGTelegramNetworking instance] requestSignal:getFile worker:worker] map:^id (id next) {
                if ([next isKindOfClass:[TLupload_File class]]) {
                    TLupload_File *part = next;
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
    if (size >= 1 * 1024 * 1024) {
        return [[self multipartDownload:location datacenterId:datacenterId size:size mediaTypeTag:mediaTypeTag] filter:^bool(id next) {
            if (!reportProgress) {
                return ![next respondsToSelector:@selector(floatValue)];
            } else {
                return true;
            }
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

@end
