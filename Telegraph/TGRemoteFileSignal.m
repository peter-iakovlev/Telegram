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

+ (SSignal *)partsForLocation:(TLInputFileLocation *)location datacenterId:(NSInteger)datacenterId size:(NSUInteger)size
{
    TLRPCupload_getFile$upload_getFile *getFile = [[TLRPCupload_getFile$upload_getFile alloc] init];
    getFile.location = location;
    getFile.offset = 0;
    getFile.limit = (int32_t)size;
    
    return [[[TGTelegramNetworking instance] downloadWorkerForDatacenterId:datacenterId] mapToSignal:^SSignal *(TGNetworkWorkerGuard *worker)
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

+ (SSignal *)dataForLocation:(TLInputFileLocation *)location datacenterId:(NSInteger)datacenterId size:(NSUInteger)size reportProgress:(bool)reportProgress
{
    return [[[self partsForLocation:location datacenterId:datacenterId size:size] map:^id(id next)
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

@end
