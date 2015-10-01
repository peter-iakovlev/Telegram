#import "TGFileDownloadActor.h"

#import "TGTelegraph.h"

#import "TGTelegramNetworking.h"
#import "TGNetworkWorker.h"
#import <MTProtoKit/MTRequestMessageService.h>
#import <MTProtoKit/MTRequest.h>

#import "ActionStage.h"
#import "SGraphObjectNode.h"

#import "TGImageInfo+Telegraph.h"

#import "TGStringUtils.h"

#import <MTProtoKit/MTEncryption.h>

#import "TGAppDelegate.h"

@interface TGFileDownloadActor () <TGRawHttpActor>
{
    NSData *_encryptionKey;
    NSData *_encryptionIv;
    
    int _finalFileSize;
    
    id _workerToken;
}

@property (nonatomic, strong) TGNetworkWorkerGuard *worker;
@property (nonatomic) bool alreadyCompleted;

@end

@implementation TGFileDownloadActor

+ (NSString *)genericPath
{
    return @"/tg/file/@";
}

- (void)dealloc
{
    if (_workerToken != nil)
    {
        [[TGTelegramNetworking instance] cancelDownloadWorkerRequestByToken:_workerToken];
        _workerToken = nil;
    }
    
    [_worker releaseWorker];
}

- (void)prepare:(NSDictionary *)options
{
    NSString *queueName = [options objectForKey:@"queueName"];
    if ([queueName isKindOfClass:[NSString class]])
        self.requestQueueName = queueName;
}

- (void)execute:(NSDictionary *)options
{
    NSString *url = [options objectForKey:@"url"];
    
    if ([url hasPrefix:@"upload/"])
    {
        NSString *localFileUrl = [url substringFromIndex:7];
        NSString *imagePath = [[[TGAppDelegate documentsPath] stringByAppendingPathComponent:@"upload"] stringByAppendingPathComponent:localFileUrl];
        
        NSData *data = [[NSData alloc] initWithContentsOfFile:imagePath];
        
        if (data == nil)
            [ActionStageInstance() nodeRetrieveFailed:self.path];
        else
            [ActionStageInstance() nodeRetrieved:self.path node:[[SGraphObjectNode alloc] initWithObject:data]];
        
        return;
    }
    else if ([url hasPrefix:@"file://"])
    {
        NSData *data = [[NSData alloc] initWithContentsOfFile:[url substringFromIndex:@"file://".length]];
        
        if (data == nil)
            [ActionStageInstance() nodeRetrieveFailed:self.path];
        else
            [ActionStageInstance() nodeRetrieved:self.path node:[[SGraphObjectNode alloc] initWithObject:data]];
        
        return;
    }
    else if ([url hasPrefix:@"http://"] || [url hasPrefix:@"https://"])
    {
        [ActionStageInstance() nodeRetrieveProgress:self.path progress:0.001f];
        self.cancelToken = [TGTelegraphInstance doRequestRawHttp:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] maxRetryCount:3 acceptCodes:nil actor:self];
        return;
    }
    else if ([url hasPrefix:@"mt-encrypted-file://?"])
    {
        NSDictionary *args = [TGStringUtils argumentDictionaryInUrlString:[url substringFromIndex:@"mt-encrypted-file://?".length]];
        
        if (args[@"dc"] == nil || args[@"id"] == nil || args[@"accessHash"] == nil || args[@"key"] == nil)
        {
            [ActionStageInstance() actionFailed:self.path reason:-1];
            return;
        }
        else
        {
            int dcId = [args[@"dc"] intValue];
            int64_t fileId = [args[@"id"] longLongValue];
            int64_t accessHash = [args[@"accessHash"] longLongValue];
            
            NSData *key = [args[@"key"] dataByDecodingHexString];
            
            int64_t size = [args[@"size"] intValue];
            
            _finalFileSize = [args[@"decryptedSize"] intValue];
            
            if (key.length != 64)
            {
                TGLog(@"***** Invalid file key length");
                [ActionStageInstance() actionFailed:self.path reason:-1];
            }
            else
            {
                _encryptionKey = [key subdataWithRange:NSMakeRange(0, 32)];
                _encryptionIv = [key subdataWithRange:NSMakeRange(32, 32)];
                
                TLInputFileLocation$inputEncryptedFileLocation *location = [[TLInputFileLocation$inputEncryptedFileLocation alloc] init];
                location.n_id = fileId;
                location.access_hash = accessHash;
                
                [ActionStageInstance() nodeRetrieveProgress:self.path progress:0.001f];
                
#if TGUseModernNetworking
                
                __weak TGFileDownloadActor *weakSelf = self;
                _workerToken = [[TGTelegramNetworking instance] requestDownloadWorkerForDatacenterId:dcId completion:^(TGNetworkWorkerGuard *worker)
                {
                    __strong TGFileDownloadActor *strongSelf = weakSelf;
                    if (strongSelf != nil)
                    {
                        strongSelf.worker = worker;
                        
                        TLRPCupload_getFile$upload_getFile *getFile = [[TLRPCupload_getFile$upload_getFile alloc] init];
                        getFile.offset = 0;
                        getFile.limit = 1 * 1024 * 1024;
                        getFile.location = location;
                        
                        MTRequest *request = [[MTRequest alloc] init];
                        request.body = getFile;
                        
                        [request setCompleted:^(TLupload_File *response, __unused NSTimeInterval timestamp, id error)
                        {
                            [ActionStageInstance() dispatchOnStageQueue:^
                            {
                                __strong TGFileDownloadActor *strongSelf = weakSelf;
                                
                                if (error == nil)
                                    [strongSelf filePartDownloadSuccess:location offset:0 length:(int)size data:response.bytes];
                                else
                                    [strongSelf filePartDownloadFailed:location offset:0 length:(int)size];
                            }];
                        }];
                        
                        [request setProgressUpdated:^(float progress, NSUInteger packetLength)
                        {
                            [ActionStageInstance() dispatchOnStageQueue:^
                            {
                                __strong TGFileDownloadActor *strongSelf = weakSelf;
                                [strongSelf filePartDownloadProgress:location offset:0 length:(int)size packetLength:(int)packetLength progress:progress];
                            }];
                        }];
                        
                        strongSelf.cancelToken = request.internalId;
                        
                        [worker.strongWorker addRequest:request];
                    }
                }];
                
#else
                self.cancelToken = [TGTelegraphInstance doDownloadFilePart:dcId location:location offset:0 length:size actor:self];
#endif
            }
        }
        
        return;
    }
    
    int64_t volumeId = 0;
    int fileId = 0;
    int64_t secret = 0;
    int datacenterId = 0;
    
    if (extractFileUrlComponents(url, &datacenterId, &volumeId, &fileId, &secret) && datacenterId != 0)
    {
        [ActionStageInstance() nodeRetrieveProgress:self.path progress:0.001f];
#if TGUseModernNetworking
        __weak TGFileDownloadActor *weakSelf = self;
        _workerToken = [[TGTelegramNetworking instance] requestDownloadWorkerForDatacenterId:datacenterId completion:^(TGNetworkWorkerGuard *worker)
        {
            __strong TGFileDownloadActor *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                strongSelf.worker = worker;
                
                TLRPCupload_getFile$upload_getFile *getFile = [[TLRPCupload_getFile$upload_getFile alloc] init];
                
                TLInputFileLocation$inputFileLocation *location = [[TLInputFileLocation$inputFileLocation alloc] init];
                location.volume_id = volumeId;
                location.local_id = fileId;
                location.secret = secret;
                
                getFile.location = location;
                
                MTRequest *request = [[MTRequest alloc] init];
                request.body = getFile;
                
                [request setCompleted:^(TLupload_File *response, __unused NSTimeInterval timestamp, id error)
                {
                    [ActionStageInstance() dispatchOnStageQueue:^
                    {
                        __strong TGFileDownloadActor *strongSelf = weakSelf;
                        
                        if (error == nil)
                            [strongSelf fileDownloadSuccess:volumeId fileId:fileId secret:secret data:response.bytes];
                        else
                            [strongSelf fileDownloadFailed:volumeId fileId:fileId secret:secret];
                    }];
                }];
                
                [request setProgressUpdated:^(float progress, __unused NSUInteger packetLength)
                {
                    [ActionStageInstance() dispatchOnStageQueue:^
                    {
                        __strong TGFileDownloadActor *strongSelf = weakSelf;
                        [strongSelf fileDownloadProgress:volumeId fileId:fileId secret:secret progress:progress];
                    }];
                }];
                
                strongSelf.cancelToken = request.internalId;
                
                [worker.strongWorker addRequest:request];
            }
        }];
#else
        self.cancelToken = [TGTelegraphInstance doDownloadFile:datacenterId volumeId:volumeId fileId:fileId secret:secret actor:self];
#endif
    }
    else
    {
        [ActionStageInstance() nodeRetrieveFailed:self.path];
    }
}

- (void)completeWithData:(NSData *)data
{
    if (self.cancelToken != nil)
    {
        [TGTelegraphInstance cancelRequestByToken:self.cancelToken];
        self.cancelToken = nil;
    }
    
    _alreadyCompleted = true;
    
    [ActionStageInstance() nodeRetrieved:self.path node:[[SGraphObjectNode alloc] initWithObject:data]];
}

- (void)fileDownloadSuccess:(int64_t)__unused volumeId fileId:(int)__unused fileId secret:(int64_t)__unused secret data:(NSData *)data
{
    if (_alreadyCompleted)
        return;
    
    [ActionStageInstance() nodeRetrieved:self.path node:[[SGraphObjectNode alloc] initWithObject:data]];
}

- (void)fileDownloadFailed:(int64_t)__unused volumeId fileId:(int)__unused fileId secret:(int64_t)__unused secret
{
    if (_alreadyCompleted)
        return;
    
    [ActionStageInstance() nodeRetrieveFailed:self.path];
}

- (void)fileDownloadProgress:(int64_t)__unused volumeId fileId:(int)__unused fileId secret:(int64_t)__unused secret progress:(float)progress
{
    if (_alreadyCompleted)
        return;
    
    [ActionStageInstance() nodeRetrieveProgress:self.path progress:MAX(0.001f, progress)];
}

- (void)httpRequestSuccess:(NSString *)__unused url response:(NSData *)response
{
    if (_alreadyCompleted)
        return;
    
    [ActionStageInstance() nodeRetrieved:self.path node:[[SGraphObjectNode alloc] initWithObject:response]];
}

- (void)httpRequestProgress:(NSString *)__unused url progress:(float)progress
{
    if (_alreadyCompleted)
        return;
    
    [ActionStageInstance() nodeRetrieveProgress:self.path progress:MAX(0.001f, progress)];
}

- (void)httpRequestFailed:(NSString *)__unused url
{
    if (_alreadyCompleted)
        return;
    
    [ActionStageInstance() nodeRetrieveFailed:self.path];
}

- (void)filePartDownloadProgress:(TLInputFileLocation *)__unused location offset:(int)__unused offset length:(int)__unused length packetLength:(int)__unused packetLength progress:(float)progress
{
    if (_alreadyCompleted)
        return;
    
    [ActionStageInstance() nodeRetrieveProgress:self.path progress:MAX(0.001f, progress)];
}

- (void)filePartDownloadSuccess:(TLInputFileLocation *)__unused location offset:(int)__unused offset length:(int)__unused length data:(NSData *)data
{
    if (_alreadyCompleted)
        return;
    
    NSMutableData *decryptedData = [[NSMutableData alloc] initWithData:data];
    MTAesDecryptInplace(decryptedData, _encryptionKey, _encryptionIv);
    
    if (_finalFileSize != 0)
        [decryptedData setLength:_finalFileSize];
    
    [ActionStageInstance() nodeRetrieved:self.path node:[[SGraphObjectNode alloc] initWithObject:decryptedData]];
}

- (void)filePartDownloadFailed:(TLInputFileLocation *)__unused location offset:(int)__unused offset length:(int)__unused length
{
    if (_alreadyCompleted)
        return;
    
    [ActionStageInstance() actionFailed:self.path reason:-1];
}

- (void)cancel
{
    if (_workerToken != nil)
    {
        [[TGTelegramNetworking instance] cancelDownloadWorkerRequestByToken:_workerToken];
        _workerToken = nil;
    }
    
    if (self.cancelToken != nil)
        [_worker.strongWorker cancelRequestById:self.cancelToken];
    
    [_worker releaseWorker];
    
    [super cancel];
}

@end
