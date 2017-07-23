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

#import "TGCdnFileData.h"

@interface TGFileDownloadActor () <TGRawHttpActor>
{
    NSData *_encryptionKey;
    NSData *_encryptionIv;
    
    int _finalFileSize;
    
    id _workerToken;
    
    SMetaDisposable *_disposable;
    
    NSDictionary *_cdnFilePartHashes;
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
    [_disposable dispose];
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
                
                TGNetworkMediaTypeTag mediaTypeTag = (TGNetworkMediaTypeTag)[options[@"mediaTypeTag"] intValue];
                __weak TGFileDownloadActor *weakSelf = self;
                _workerToken = [[TGTelegramNetworking instance] requestDownloadWorkerForDatacenterId:dcId type:mediaTypeTag completion:^(TGNetworkWorkerGuard *worker)
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
                                
                                if (error == nil && [response isKindOfClass:[TLupload_File$upload_file class]])
                                    [strongSelf filePartDownloadSuccess:location offset:0 length:(int)size data:((TLupload_File$upload_file *)response).bytes];
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

        TGNetworkMediaTypeTag mediaTypeTag = (TGNetworkMediaTypeTag)[options[@"mediaTypeTag"] intValue];
        __weak TGFileDownloadActor *weakSelf = self;
        _workerToken = [[TGTelegramNetworking instance] requestDownloadWorkerForDatacenterId:datacenterId type:mediaTypeTag completion:^(TGNetworkWorkerGuard *worker)
        {
            __strong TGFileDownloadActor *strongSelf = weakSelf;
            if (strongSelf != nil) {
                [strongSelf proceedWithWorker:worker type:mediaTypeTag fileData:nil datacenterId:datacenterId volumeId:volumeId fileId:fileId secret:secret];
            }
        }];
    }
    else
    {
        [ActionStageInstance() nodeRetrieveFailed:self.path];
    }
}
    
- (void)proceedWithWorker:(TGNetworkWorkerGuard *)worker type:(TGNetworkMediaTypeTag)mediaTypeTag fileData:(TGCdnFileData *)fileData datacenterId:(NSInteger)datacenterId volumeId:(int64_t)volumeId fileId:(int32_t)fileId secret:(int64_t)secret {
    self.worker = worker;
    
    id requestData = nil;
    if (fileData != nil) {
        TLRPCupload_getCdnFile$upload_getCdnFile *getCdnFile = [[TLRPCupload_getCdnFile$upload_getCdnFile alloc] init];
        getCdnFile.file_token = fileData.token;
        getCdnFile.offset = 0;
        getCdnFile.limit = 1 * 1024 * 1024;
        requestData = getCdnFile;
    } else {
        TLRPCupload_getFile$upload_getFile *getFile = [[TLRPCupload_getFile$upload_getFile alloc] init];
        
        TLInputFileLocation$inputFileLocation *location = [[TLInputFileLocation$inputFileLocation alloc] init];
        location.volume_id = volumeId;
        location.local_id = fileId;
        location.secret = secret;
        
        getFile.location = location;
        getFile.limit = 1 * 1024 * 1024;
        
        requestData = getFile;
    }
    
    MTRequest *request = [[MTRequest alloc] init];
    request.body = requestData;
    
    __weak TGFileDownloadActor *weakSelf = self;
    [request setCompleted:^(TLupload_File *response, __unused NSTimeInterval timestamp, id error) {
        [ActionStageInstance() dispatchOnStageQueue:^ {
            __strong TGFileDownloadActor *strongSelf = weakSelf;
            
            if (error == nil) {
                if (fileData == nil) {
                    if ([response isKindOfClass:[TLupload_File$upload_file class]]) {
                        [strongSelf fileDownloadSuccess:volumeId fileId:fileId secret:secret data:((TLupload_File$upload_file *)response).bytes];
                    } else if ([response isKindOfClass:[TLupload_File$upload_fileCdnRedirect class]]) {
                        TLupload_File$upload_fileCdnRedirect *redirect = (TLupload_File$upload_fileCdnRedirect *)response;
                        
                        NSMutableDictionary *hashDict = [[NSMutableDictionary alloc] init];
                        for (TLCdnFileHash$cdnFileHash *nHash in redirect.cdn_file_hashes) {
                            hashDict[@(nHash.offset)] = nHash.n_hash;
                        }
                        
                        [strongSelf switchToCdn:redirect.dc_id fileData:[[TGCdnFileData alloc] initWithCdnId:redirect.dc_id token:redirect.file_token encryptionKey:redirect.encryption_key encryptionIv:redirect.encryption_iv] type:mediaTypeTag datacenterId:datacenterId volumeId:volumeId fileId:fileId secret:secret partHashes:hashDict];
                    } else {
                        [strongSelf fileDownloadFailed:volumeId fileId:fileId secret:secret];
                    }
                } else {
                    if ([response isKindOfClass:[TLupload_CdnFile$upload_cdnFile class]]) {
                        NSData *bytes = ((TLupload_CdnFile$upload_cdnFile *)response).bytes;
                        NSMutableData *encryptionIv = [[NSMutableData alloc] initWithData:fileData.encryptionIv];
                        int32_t offset = 0 / 8;
                        NSSwapInt(offset);
                        memcpy(encryptionIv.mutableBytes + encryptionIv.length - 4, &offset, 4);
                        NSData *data = MTAesCtrDecrypt(bytes, fileData.encryptionKey, encryptionIv);
                        [strongSelf fileDownloadSuccess:volumeId fileId:fileId secret:secret data:data];
                    } else if ([response isKindOfClass:[TLupload_CdnFile$upload_cdnFileReuploadNeeded class]]) {
                        TLupload_CdnFile$upload_cdnFileReuploadNeeded *reupload = (TLupload_CdnFile$upload_cdnFileReuploadNeeded *)response;
                        [strongSelf reuploadCdnFile:(fileData.cdnId) fileData:fileData requestToken:reupload.request_token type:mediaTypeTag datacenterId:datacenterId volumeId:volumeId fileId:fileId secret:secret];
                    } else {
                        [strongSelf fileDownloadFailed:volumeId fileId:fileId secret:secret];
                    }
                }
            }
            else {
                [strongSelf fileDownloadFailed:volumeId fileId:fileId secret:secret];
            }
        }];
    }];
    
    [request setProgressUpdated:^(float progress, __unused NSUInteger packetLength) {
        [ActionStageInstance() dispatchOnStageQueue:^ {
            __strong TGFileDownloadActor *strongSelf = weakSelf;
            [strongSelf fileDownloadProgress:volumeId fileId:fileId secret:secret progress:progress];
        }];
    }];
    
    self.cancelToken = request.internalId;
    
    [worker.strongWorker addRequest:request];
}
    
- (void)switchToCdn:(int32_t)cdnId fileData:(TGCdnFileData *)fileData type:(TGNetworkMediaTypeTag)mediaTypeTag datacenterId:(NSInteger)datacenterId volumeId:(int64_t)volumeId fileId:(int32_t)fileId secret:(int64_t)secret partHashes:(NSDictionary *)partHashes {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    if (partHashes != nil) {
        [dict addEntriesFromDictionary:partHashes];
    }
    int32_t maxOffset = 0;
    for (NSNumber *nOffset in dict.keyEnumerator) {
        maxOffset = MAX(maxOffset, [nOffset intValue] + 128 * 1024);
    }
    _cdnFilePartHashes = dict;
    
    [[TGTelegramNetworking instance] cancelDownloadWorkerRequestByToken:_workerToken];
    _workerToken = nil;
    
    __weak TGFileDownloadActor *weakSelf = self;
    _workerToken = [[TGTelegramNetworking instance] requestDownloadWorkerForDatacenterId:cdnId type:mediaTypeTag isCdn:true completion:^(TGNetworkWorkerGuard *worker) {
        __strong TGFileDownloadActor *strongSelf = weakSelf;
        if (strongSelf != nil) {
            [strongSelf proceedWithWorker:worker type:mediaTypeTag fileData:fileData datacenterId:datacenterId volumeId:volumeId fileId:fileId secret:secret];
        }
    }];
}
    
- (void)reuploadCdnFile:(int32_t)cdnId fileData:(TGCdnFileData *)fileData requestToken:(NSData *)requestToken type:(TGNetworkMediaTypeTag)mediaTypeTag datacenterId:(NSInteger)datacenterId volumeId:(int64_t)volumeId fileId:(int32_t)fileId secret:(int64_t)secret {
    __weak TGFileDownloadActor *weakSelf = self;
    _workerToken = [[TGTelegramNetworking instance] requestDownloadWorkerForDatacenterId:datacenterId type:mediaTypeTag completion:^(TGNetworkWorkerGuard *worker)
    {
        __strong TGFileDownloadActor *strongSelf = weakSelf;
        if (strongSelf != nil) {
            MTRequest *request = [[MTRequest alloc] init];
            TLRPCupload_reuploadCdnFile$upload_reuploadCdnFile *requestData = [[TLRPCupload_reuploadCdnFile$upload_reuploadCdnFile alloc] init];
            requestData.file_token = fileData.token;
            requestData.request_token = requestToken;
            request.body = requestData;
            
            [request setCompleted:^(__unused id response, __unused NSTimeInterval timestamp, id error) {
                [ActionStageInstance() dispatchOnStageQueue:^{
                    __strong TGFileDownloadActor *strongSelf = weakSelf;
                    if (strongSelf != nil) {
                        if (error == nil) {
                            [strongSelf switchToCdn:cdnId fileData:fileData type:mediaTypeTag datacenterId:datacenterId volumeId:volumeId fileId:fileId secret:secret partHashes:strongSelf->_cdnFilePartHashes];
                        } else {
                            [strongSelf fileDownloadFailed:volumeId fileId:fileId secret:secret];
                        }
                    }
                }];
            }];
            
            strongSelf.cancelToken = request.internalId;
            
            [worker.strongWorker addRequest:request];
        }
    }];
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
    
    NSData *decryptedData = data;
    if (_encryptionKey.length != 0) {
        decryptedData = MTAesDecrypt(data, _encryptionKey, _encryptionIv);
    }
    
    NSMutableData *finalData = [[NSMutableData alloc] initWithData:decryptedData];
    if (_finalFileSize != 0)
        [finalData setLength:_finalFileSize];
    
    if (_cdnFilePartHashes != nil) {
        NSData *dataToWrite = finalData;
        int32_t basePartOffset = 0;
        for (int32_t localOffset = 0; localOffset < (int32_t)dataToWrite.length; localOffset += 128 * 1024) {
            int32_t partOffset = basePartOffset + localOffset;
            NSData *hashData = _cdnFilePartHashes[@(partOffset)];
            if (hashData == nil) {
                TGLog(@"File CDN part hash missing at %d", partOffset);
                [ActionStageInstance() actionFailed:self.path reason:-1];
                return;
            }
            NSData *localHash = nil;
            if (partOffset + 128 * 1024 > (int32_t)dataToWrite.length) {
                localHash = MTSha256([[NSData alloc] initWithBytesNoCopy:(void *)dataToWrite.bytes + localOffset length:(int32_t)dataToWrite.length - localOffset freeWhenDone:false]);
            } else {
                localHash = MTSha256([[NSData alloc] initWithBytesNoCopy:(void *)dataToWrite.bytes + localOffset length:128 * 1024 freeWhenDone:false]);
            }
            if (![localHash isEqual:hashData]) {
                TGLog(@"File CDN part hash mismatch at %d", partOffset);
                [ActionStageInstance() actionFailed:self.path reason:-1];
                return;
            }
        }
    }
    
    [ActionStageInstance() nodeRetrieved:self.path node:[[SGraphObjectNode alloc] initWithObject:finalData]];
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
    
    [_disposable dispose];
    
    [super cancel];
}

@end
