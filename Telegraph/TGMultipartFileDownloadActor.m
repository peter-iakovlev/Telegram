/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGMultipartFileDownloadActor.h"

#import "TL/TLMetaScheme.h"

#import "ActionStage.h"

#import "TGTelegraph.h"

#import "TGTelegramNetworking.h"
#import "TGNetworkWorker.h"

#import <MTProtoKit/MTEncryption.h>
#import <MTProtoKit/MTRequest.h>

#import "TGCdnFileData.h"
    
@interface TGFilePartInfo : NSObject

@property (nonatomic, strong) id token;
@property (nonatomic) NSTimeInterval startTime;
@property (nonatomic) int partOffset;
@property (nonatomic) int partLength;
@property (nonatomic) int downloadedLength;
@property (nonatomic) NSData *downloadedData;
@property (nonatomic) bool restart;

@end

@implementation TGFilePartInfo

@end

@interface TGMultipartFileDownloadActor ()
{
    TLInputFileLocation *_fileLocation;
    int _datacenterId;
    int _size;
    NSMutableArray *_storeFilePaths;
    NSString *_tempStoreFilePath;
    
    NSString *_contextStoreFilePath;
    
    NSMutableDictionary *_downloadingParts;
    NSMutableArray *_explicitDownloadParts;
    NSOutputStream *_fileStream;
    NSOutputStream *_encryptionContextStream;
    int _currentEncryptionContextStreamCount;
    
    NSDictionary<NSNumber *, NSData *> *_cdnFilePartHashes;
    
    NSData *_encryptionKey;
    NSData *_encryptionIv;
    NSMutableData *_runningEncryptionIv;
    int _decryptedSize;
    
    int _downloadedFileSize;
    
    bool _reportedProgress;
    int _lastReportedProgress;
    
    NSTimeInterval _averageDownloadSpeed;
    int _takenTimeSamples;
    
    float _progress;
    
    id _worker1Token;
    id _worker2Token;
    TGNetworkWorkerGuard *_worker1;
    TGNetworkWorkerGuard *_worker2;
    
    int _nextWorker;
    
    bool _completeWithData;
    
    TGCdnFileData *_cdnFileData;
    TGNetworkMediaTypeTag _mediaTypeTag;
    
    SMetaDisposable *_reuploadDisposable;
    bool _isReuploading;
    
    SMetaDisposable *_partHashesDisposable;
}

@end

@interface TGFilePartRequestInfo : NSObject

@property (nonatomic) int offset;
@property (nonatomic) int length;

@end

@implementation TGFilePartRequestInfo

@end

@implementation TGMultipartFileDownloadActor

+ (NSString *)genericPath
{
    return @"/tg/multipart-file/@";
}

- (instancetype)initWithPath:(NSString *)path
{
    self = [super initWithPath:path];
    if (self != nil)
    {
        _downloadingParts = [[NSMutableDictionary alloc] init];
        _explicitDownloadParts = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc
{
    if (_worker1Token != nil)
    {
        [[TGTelegramNetworking instance] cancelDownloadWorkerRequestByToken:_worker1Token];
        _worker1Token = nil;
    }
    
    if (_worker2Token != nil)
    {
        [[TGTelegramNetworking instance] cancelDownloadWorkerRequestByToken:_worker2Token];
        _worker2Token = nil;
    }
    
    [_worker1 releaseWorker];
    [_worker2 releaseWorker];
    
    if (_fileStream != nil)
    {
        [_fileStream close];
        _fileStream = nil;
    }
    
    if (_encryptionContextStream != nil)
    {
        [_encryptionContextStream close];
        _encryptionContextStream = nil;
    }
    
    [_reuploadDisposable dispose];
    [_partHashesDisposable dispose];
}

- (void)storeCurrentIv
{
    if (_contextStoreFilePath != nil)
    {
        [_runningEncryptionIv writeToFile:_contextStoreFilePath atomically:false];
    }
}

- (void)execute:(NSDictionary *)options
{
    _storeFilePaths = [[NSMutableArray alloc] init];
    
    _fileLocation = options[@"fileLocation"];
    _size = [options[@"encryptedSize"] intValue];
    _decryptedSize = [options[@"decryptedSize"] intValue];
    if (options[@"storeFilePath"] != nil)
        [_storeFilePaths addObject:options[@"storeFilePath"]];
    _datacenterId = [options[@"datacenterId"] intValue];
    _completeWithData = [options[@"completeWithData"] boolValue];
    
    if (options[@"encryptionArgs"][@"key"] != nil)
    {
        _encryptionKey = options[@"encryptionArgs"][@"key"];
        _encryptionIv = options[@"encryptionArgs"][@"iv"];
        _runningEncryptionIv = _encryptionIv.length == 0 ? nil : [[NSMutableData alloc] initWithData:_encryptionIv];
    }
    
    if (_fileLocation != nil && _storeFilePaths.count != 0)
    {
        _tempStoreFilePath = options[@"tempStoreFilePath"];
        if (_tempStoreFilePath == nil)
            _tempStoreFilePath = [_storeFilePaths[0] stringByAppendingString:@".parts"];
        
        NSFileManager *fileManager = [ActionStageInstance() globalFileManager];
        
        NSError *error = nil;
        NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:_tempStoreFilePath error:&error];
        int fileSize = [[fileAttributes objectForKey:NSFileSize] intValue];
        
        if (fileAttributes == nil || (fileSize % 1024 != 0 && fileSize != _decryptedSize && _decryptedSize != 0))
        {
            if (fileAttributes != nil)
            {
                TGLog(@"Invalid partial file length %d, restarting", fileSize);
                fileSize = 0;
                [self cancelRequests];
            }
            [fileManager createFileAtPath:_tempStoreFilePath contents:[NSData data] attributes:nil];
        }
        
        _downloadedFileSize = fileSize;
        
        if (_runningEncryptionIv != nil)
        {
            _contextStoreFilePath = [_tempStoreFilePath stringByAppendingString:@".info"];
            NSData *previousData = [[NSData alloc] initWithContentsOfFile:_contextStoreFilePath];
            if (previousData != nil && previousData.length >= _runningEncryptionIv.length)
                _runningEncryptionIv = [[NSMutableData alloc] initWithData:[previousData subdataWithRange:NSMakeRange(previousData.length - _runningEncryptionIv.length, _runningEncryptionIv.length)]];
            
            _currentEncryptionContextStreamCount = (int)(previousData.length / _runningEncryptionIv.length);
            _encryptionContextStream = [NSOutputStream outputStreamToFileAtPath:_contextStoreFilePath append:true];
            [_encryptionContextStream open];
        }
        
        _fileStream = [[NSOutputStream alloc] initToFileAtPath:_tempStoreFilePath append:true];
        [_fileStream open];
        
        TGNetworkMediaTypeTag mediaTypeTag = (TGNetworkMediaTypeTag)([options[@"mediaTypeTag"] intValue]);
        _mediaTypeTag = mediaTypeTag;
        __weak TGMultipartFileDownloadActor *weakSelf = self;
        _worker1Token = [[TGTelegramNetworking instance] requestDownloadWorkerForDatacenterId:_datacenterId type:mediaTypeTag completion:^(TGNetworkWorkerGuard *worker)
        {
            __strong TGMultipartFileDownloadActor *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                [strongSelf downloadFilePartsWithWorker:worker];
            }
        }];
        
        _worker2Token = [[TGTelegramNetworking instance] requestDownloadWorkerForDatacenterId:_datacenterId type:mediaTypeTag completion:^(TGNetworkWorkerGuard *worker)
        {
            __strong TGMultipartFileDownloadActor *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                [strongSelf assignAdditionalWorker:worker];
            }
        }];
    }
    else
    {
        [ActionStageInstance() actionFailed:self.path reason:-1];
    }
}

- (void)watcherJoined:(ASHandle *)watcherHandle options:(NSDictionary *)options waitingInActorQueue:(bool)waitingInActorQueue
{
    [super watcherJoined:watcherHandle options:options waitingInActorQueue:waitingInActorQueue];
    
    if (options[@"storeFilePath"] != nil && ![_storeFilePaths containsObject:options[@"storeFilePath"]])
        [_storeFilePaths addObject:options[@"storeFilePath"]];
}

- (int)preferredPartSize
{
    return 128 * 1024;
}

- (void)recordTimeSample:(int)length startTime:(NSTimeInterval)startTime
{
    NSTimeInterval downloadTime = CFAbsoluteTimeGetCurrent() - startTime;
    float downloadSpeed = ((float)length) / ((float)downloadTime);
    
    _takenTimeSamples++;
    _averageDownloadSpeed = (_averageDownloadSpeed + downloadSpeed) / 2.0f;
    
#ifdef DEBUG
    TGLog(@"Average speed: %f kbytes/s", _averageDownloadSpeed / 1024.0f);
#endif
}

- (void)downloadFilePartsWithWorker:(TGNetworkWorkerGuard *)worker
{
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        _worker1 = worker;
        
        [self downloadFileParts];
    }];
}

- (void)assignAdditionalWorker:(TGNetworkWorkerGuard *)worker
{
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        _worker2 = worker;
        
        [self downloadFileParts];
    }];
}

- (void)downloadFileParts
{
    if (_worker1 == nil) {
        return;
    }
    
    if (_size != 0 && _downloadedFileSize >= _size)
    {
        if (_fileStream != nil)
        {
            [_fileStream close];
            _fileStream = nil;
        }
        
        if (_encryptionContextStream != nil)
        {
            [_encryptionContextStream close];
            _encryptionContextStream = nil;
        }
        
        if (_contextStoreFilePath != nil)
            [[NSFileManager defaultManager] removeItemAtPath:_contextStoreFilePath error:nil];
        
        for (NSString *storeFilePath in _storeFilePaths)
        {
            [[ActionStageInstance() globalFileManager] copyItemAtPath:_tempStoreFilePath toPath:storeFilePath error:NULL];
        }
        [[ActionStageInstance() globalFileManager] removeItemAtPath:_tempStoreFilePath error:NULL];

        [ActionStageInstance() actionCompleted:self.path result:_completeWithData ? [[NSData alloc] initWithContentsOfFile:_storeFilePaths[0]] : nil];
    }
    else
    {
        if (!_reportedProgress)
        {
            _reportedProgress = true;
            
            [self reportProgress:true];
        }
        
        NSMutableArray *requestList = [[NSMutableArray alloc] init];
        
        __block int activeDownloadingParts = 0;
        
        [_downloadingParts enumerateKeysAndObjectsUsingBlock:^(__unused NSNumber *offset, TGFilePartInfo *partInfo, __unused BOOL *stop)
        {
            if (partInfo.downloadedData == nil && !partInfo.restart)
                activeDownloadingParts++;
        }];
        
        int partSize = [self preferredPartSize];
        
        while (activeDownloadingParts < (_size != 0 ? 4 : 1))
        {
            if (_explicitDownloadParts.count == 0)
            {
                __block int nextDownloadOffset = _downloadedFileSize;
                
                [_downloadingParts enumerateKeysAndObjectsUsingBlock:^(NSNumber *offset, TGFilePartInfo *partInfo, __unused BOOL *stop)
                {
                    if ([offset intValue] + partInfo.partLength > nextDownloadOffset)
                        nextDownloadOffset = [offset intValue] + partInfo.partLength;
                    if (partInfo.restart) {
                        partInfo.restart = false;
                        
                        TGFilePartRequestInfo *requestInfo = [[TGFilePartRequestInfo alloc] init];
                        requestInfo.offset = partInfo.partOffset;
                        requestInfo.length = partInfo.partLength;
                        [requestList addObject:requestInfo];
                    }
                }];
                
                if (_size != 0 && nextDownloadOffset >= _size)
                    break;
                
                int partLength = 0;
                if (_size == 0)
                    partLength = partSize;
                else
                    partLength = MIN(partSize, _size - _downloadedFileSize);
                
                TGFilePartRequestInfo *requestInfo = [[TGFilePartRequestInfo alloc] init];
                requestInfo.offset = nextDownloadOffset;
                requestInfo.length = partLength;
                [requestList addObject:requestInfo];
                
                TGFilePartInfo *partInfo = [[TGFilePartInfo alloc] init];
                partInfo.partOffset = nextDownloadOffset;
                partInfo.partLength = partLength;
                _downloadingParts[@(nextDownloadOffset)] = partInfo;
                
                activeDownloadingParts++;
            }
            else
            {
                TGFilePartRequestInfo *explicitPartRequest = [_explicitDownloadParts firstObject];
                [requestList addObject:explicitPartRequest];
                
                TGFilePartInfo *partInfo = [[TGFilePartInfo alloc] init];
                partInfo.partOffset = explicitPartRequest.offset;
                partInfo.partLength = explicitPartRequest.length;
                _downloadingParts[@(explicitPartRequest.offset)] = partInfo;
                activeDownloadingParts++;
                
                [_explicitDownloadParts removeObjectAtIndex:0];
            }
        }
        
        for (TGFilePartRequestInfo *requestInfo in requestList)
        {
            MTRequest *request = [[MTRequest alloc] init];
            
            int32_t updatedLimit = requestInfo.length;
            while (updatedLimit % 4096 != 0 || 1048576 % updatedLimit != 0) {
                updatedLimit++;
            }
            
            TLInputFileLocation *location = _fileLocation;
            
            if (_cdnFileData != nil) {
                TLRPCupload_getCdnFile$upload_getCdnFile *getFile = [[TLRPCupload_getCdnFile$upload_getCdnFile alloc] init];
                
                getFile.file_token = _cdnFileData.token;
                getFile.offset = requestInfo.offset;
                
                getFile.limit = updatedLimit;
                request.body = getFile;
            } else {
                TLRPCupload_getFile$upload_getFile *getFile = [[TLRPCupload_getFile$upload_getFile alloc] init];
                
                getFile.location = location;
                getFile.offset = requestInfo.offset;
                
                getFile.limit = updatedLimit;
                request.body = getFile;
            }
            
            __weak TGMultipartFileDownloadActor *weakSelf = self;
            [request setCompleted:^(TLupload_File *result, __unused NSTimeInterval timestamp, id error)
            {
                [ActionStageInstance() dispatchOnStageQueue:^
                {
                    __strong TGMultipartFileDownloadActor *strongSelf = weakSelf;
                    
                    if (strongSelf != nil) {
                        if (error == nil) {
                            if ([result isKindOfClass:[TLupload_File$upload_file class]]) {
                                [strongSelf filePartDownloadSuccess:location offset:requestInfo.offset length:requestInfo.length data:((TLupload_File$upload_file *)result).bytes];
                            } else if ([result isKindOfClass:[TLupload_File$upload_fileCdnRedirect class]]) {
                                ((TGFilePartInfo *)strongSelf->_downloadingParts[@(requestInfo.offset)]).restart = true;
                                TLupload_File$upload_fileCdnRedirect *redirect = (TLupload_File$upload_fileCdnRedirect *)result;
                                
                                NSMutableDictionary *hashDict = [[NSMutableDictionary alloc] init];
                                for (TLCdnFileHash$cdnFileHash *nHash in redirect.cdn_file_hashes) {
                                    hashDict[@(nHash.offset)] = nHash.n_hash;
                                }
                                
                                [strongSelf switchToCdnWithFileData:[[TGCdnFileData alloc] initWithCdnId:redirect.dc_id token:redirect.file_token encryptionKey:redirect.encryption_key encryptionIv:redirect.encryption_iv] partHashes:hashDict];
                            } else if ([result isKindOfClass:[TLupload_CdnFile$upload_cdnFile class]]) {
                                TGCdnFileData *fileData = strongSelf->_cdnFileData;
                                NSData *bytes = ((TLupload_CdnFile$upload_cdnFile *)result).bytes;
                                NSMutableData *encryptionIv = [[NSMutableData alloc] initWithData:fileData.encryptionIv];
                                int32_t ivOffset = requestInfo.offset / 16;
                                ivOffset = NSSwapInt(ivOffset);
                                memcpy(encryptionIv.mutableBytes + encryptionIv.length - 4, &ivOffset, 4);
                                NSData *data = nil;
                                if (bytes.length != 0) {
                                    data = MTAesCtrDecrypt(bytes, fileData.encryptionKey, encryptionIv);
                                } else {
                                    data = [NSData data];
                                }
                                [strongSelf filePartDownloadSuccess:location offset:requestInfo.offset length:requestInfo.length data:data];
                            } else if ([result isKindOfClass:[TLupload_CdnFile$upload_cdnFileReuploadNeeded class]]) {
                                ((TGFilePartInfo *)strongSelf->_downloadingParts[@(requestInfo.offset)]).restart = true;
                                TLupload_CdnFile$upload_cdnFileReuploadNeeded *reupload = (TLupload_CdnFile$upload_cdnFileReuploadNeeded *)result;
                                [strongSelf reuploadToCdn:reupload.request_token];
                            }
                        }
                        else
                            [strongSelf filePartDownloadFailed:location offset:requestInfo.offset length:requestInfo.length];
                    }
                }];
            }];
            
            [request setProgressUpdated:^(float progress, NSUInteger packetLength)
            {
                [ActionStageInstance() dispatchOnStageQueue:^
                {
                    __strong TGMultipartFileDownloadActor *strongSelf = weakSelf;
                    
                    [strongSelf filePartDownloadProgress:location offset:requestInfo.offset length:requestInfo.length packetLength:(int)packetLength progress:progress];
                }];
            }];
            
            TGNetworkWorkerGuard *worker = _worker1;
            if (_worker2 != nil)
            {
                _nextWorker++;
                if (_nextWorker % 2 == 0)
                    worker = _worker2;
            }
            
            id token = request.internalId;
            [worker.strongWorker addRequest:request];

            ((TGFilePartInfo *)_downloadingParts[@(requestInfo.offset)]).token = token;
        }
    }
}

- (void)switchToCdnWithFileData:(TGCdnFileData *)fileData partHashes:(NSDictionary *)partHashes {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    if (partHashes != nil) {
        [dict addEntriesFromDictionary:partHashes];
    }
    int32_t maxOffset = 0;
    for (NSNumber *nOffset in dict.keyEnumerator) {
        maxOffset = MAX(maxOffset, [nOffset intValue] + 128 * 1024);
    }
    if (maxOffset < _size) {
        if (_partHashesDisposable == nil) {
            _partHashesDisposable = [[SMetaDisposable alloc] init];
        }
        __weak TGMultipartFileDownloadActor *weakSelf = self;
        
        [_partHashesDisposable setDisposable:[[[[TGTelegramNetworking instance] downloadWorkerForDatacenterId:_datacenterId type:TGNetworkMediaTypeTagGeneric] mapToSignal:^SSignal *(TGNetworkWorkerGuard *worker) {
            TLRPCupload_getCdnFileHashes$upload_getCdnFileHashes *getCdnFileHashes = [[TLRPCupload_getCdnFileHashes$upload_getCdnFileHashes alloc] init];
            getCdnFileHashes.file_token = fileData.token;
            getCdnFileHashes.offset = maxOffset;
            return [[TGTelegramNetworking instance] requestSignal:getCdnFileHashes worker:worker];
        }] startWithNext:^(NSArray *hashes) {
            [ActionStageInstance() dispatchOnStageQueue:^{
                __strong TGMultipartFileDownloadActor *strongSelf = weakSelf;
                if (strongSelf != nil) {
                    for (TLCdnFileHash$cdnFileHash *nHash in hashes) {
                        dict[@(nHash.offset)] = nHash.n_hash;
                    }
                    
                    int32_t maxOffset = 0;
                    for (NSNumber *nOffset in dict.keyEnumerator) {
                        maxOffset = MAX(maxOffset, [nOffset intValue] + 128 * 1024);
                    }
                    
                    if (maxOffset < strongSelf->_size) {
                        [strongSelf switchToCdnWithFileData:fileData partHashes:dict];
                    } else {
                        strongSelf->_cdnFilePartHashes = dict;
                        [strongSelf switchToCdn:fileData];
                    }
                }
            }];
        } error:nil completed:nil]];
    } else {
        _cdnFilePartHashes = dict;
        [self switchToCdn:fileData];
    }
}
    
- (void)switchToCdn:(TGCdnFileData *)fileData {
    if (_cdnFileData != nil) {
        return;
    }
    
    _cdnFileData = fileData;
    
    _worker1 = nil;
    _worker2 = nil;
    
    __weak TGMultipartFileDownloadActor *weakSelf = self;
    _worker1Token = [[TGTelegramNetworking instance] requestDownloadWorkerForDatacenterId:fileData.cdnId type:_mediaTypeTag isCdn:true completion:^(TGNetworkWorkerGuard *worker)
    {
        __strong TGMultipartFileDownloadActor *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            [strongSelf downloadFilePartsWithWorker:worker];
        }
    }];
    
    _worker2Token = [[TGTelegramNetworking instance] requestDownloadWorkerForDatacenterId:fileData.cdnId type:_mediaTypeTag isCdn:true completion:^(TGNetworkWorkerGuard *worker)
    {
        __strong TGMultipartFileDownloadActor *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            [strongSelf assignAdditionalWorker:worker];
        }
    }];
}
    
- (void)reuploadToCdn:(NSData *)requestToken {
    if (_isReuploading) {
        return;
    }
    _isReuploading = true;
    if (_reuploadDisposable == nil) {
        _reuploadDisposable = [[SMetaDisposable alloc] init];
    }
    NSData *fileToken = _cdnFileData.token;
    __weak TGMultipartFileDownloadActor *weakSelf = self;
    [_reuploadDisposable setDisposable:[[[[TGTelegramNetworking instance] downloadWorkerForDatacenterId:_datacenterId type:TGNetworkMediaTypeTagGeneric] mapToSignal:^SSignal *(TGNetworkWorkerGuard *worker) {
        TLRPCupload_reuploadCdnFile$upload_reuploadCdnFile *reupload = [[TLRPCupload_reuploadCdnFile$upload_reuploadCdnFile alloc] init];
        reupload.file_token = fileToken;
        reupload.request_token = requestToken;
        return [[TGTelegramNetworking instance] requestSignal:reupload worker:worker];
    }] startWithNext:^(__unused id next) {
        [ActionStageInstance() dispatchOnStageQueue:^{
            __strong TGMultipartFileDownloadActor *strongSelf = weakSelf;
            if (strongSelf != nil) {
                strongSelf->_isReuploading = false;
                [strongSelf downloadFileParts];
            }
        }];
    } error:nil completed:nil]];
}

- (void)filePartDownloadProgress:(TLInputFileLocation *)__unused location offset:(int)offset length:(int)__unused length packetLength:(int)packetLength progress:(float)progress
{
    TGFilePartInfo *partInfo = _downloadingParts[@(offset)];
    if (partInfo != nil)
    {
        partInfo.downloadedLength = (int)(progress * packetLength);
    }
    
    [self reportProgress:false];
}

- (void)reportProgress:(bool)force
{
    if (_size == 0)
        return;
    
    __block int readyFileSize = _downloadedFileSize;
    
    [_downloadingParts enumerateKeysAndObjectsUsingBlock:^(__unused NSNumber *nOffset, TGFilePartInfo *partInfo, __unused BOOL *stop)
    {
        readyFileSize += partInfo.downloadedLength;
    }];
    
    if (force || (_lastReportedProgress < readyFileSize && (_lastReportedProgress / 16 * 1024 != readyFileSize / 16 * 1024 || readyFileSize == _size)))
    {
        _lastReportedProgress = readyFileSize;
        
        _progress = MIN(1.0f, MAX(0.001f, ((float)readyFileSize) / ((float)_size)));
        
        [ActionStageInstance() dispatchMessageToWatchers:self.path messageType:@"progress" message:[[NSNumber alloc] initWithFloat:_progress]];
    }
}

- (void)filePartDownloadSuccess:(TLInputFileLocation *)__unused location offset:(int)offset length:(int)length data:(NSData *)data
{
    if (self.cancelled)
        return;
    
    if (_size == 0 && (int)data.length < length)
        _size = _downloadedFileSize + (int)data.length;
    
    TGFilePartInfo *partInfo = _downloadingParts[@(offset)];
    if (partInfo != nil)
    {
        partInfo.token = nil;
        partInfo.downloadedLength = length;
        
        [self recordTimeSample:length startTime:partInfo.startTime];
    }
    
    int fileSize = _downloadedFileSize;
    
    if (partInfo != nil)
    {
        partInfo.downloadedData = data;
        
        int nextWriteOffset = fileSize;
        
        NSMutableArray *sortedDownloadingParts = [[NSMutableArray alloc] init];
        for (NSNumber *nOffset in _downloadingParts)
        {
            [sortedDownloadingParts addObject:nOffset];
        }
        
        [sortedDownloadingParts sortUsingComparator:^NSComparisonResult(NSNumber *number1, NSNumber *number2)
        {
            return [number1 compare:number2];
        }];
        
        while (true)
        {
            bool hadCommit = false;
            
            for (NSNumber *nOffset in sortedDownloadingParts)
            {
                if ([nOffset intValue] == nextWriteOffset)
                {
                    TGFilePartInfo *listPartInfo = _downloadingParts[nOffset];
                    if (listPartInfo.downloadedData == nil)
                        break;
                    
                    hadCommit = true;
                    
                    NSData *dataToWrite = listPartInfo.downloadedData;
                    
                    if (_encryptionKey != nil && _runningEncryptionIv != nil)
                    {
                        NSMutableData *decryptedData = [[NSMutableData alloc] initWithData:dataToWrite];
                        if (decryptedData.length % 16 == 0)
                            MTAesDecryptInplaceAndModifyIv(decryptedData, _encryptionKey, _runningEncryptionIv);
                        else
                            TGLog(@"**** Error: encrypted data length % 16 != 0");
                        dataToWrite = decryptedData;
                        
                        if (_decryptedSize != 0 && _decryptedSize >= _downloadedFileSize && _downloadedFileSize + (int)decryptedData.length > _decryptedSize)
                        {
                            [decryptedData setLength:_decryptedSize - _downloadedFileSize];
                        }
                        
                        if (_currentEncryptionContextStreamCount >= 32)
                        {
                            _currentEncryptionContextStreamCount = 0;
                            [_encryptionContextStream close];
                            
                            _encryptionContextStream = [NSOutputStream outputStreamToFileAtPath:_contextStoreFilePath append:true];
                            [_encryptionContextStream open];
                        }
                        else
                            _currentEncryptionContextStreamCount++;
                        
                        [_encryptionContextStream writeData:_runningEncryptionIv];
                    }
                    
                    if (_cdnFilePartHashes != nil) {
                        int32_t basePartOffset = [nOffset intValue];
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
                    
                    [_fileStream writeData:dataToWrite];
                    
                    _downloadedFileSize += listPartInfo.downloadedData.length;
                    nextWriteOffset += listPartInfo.downloadedData.length;
                    
                    if (_size != 0 && (int)listPartInfo.downloadedData.length < listPartInfo.partLength && _downloadedFileSize + (int)listPartInfo.downloadedData.length < _size)
                    {
                        int dataGapLength = listPartInfo.partLength - (int)listPartInfo.downloadedData.length;
                        TGLog(@"Data gap found: %d bytes", dataGapLength);
                        
                        TGFilePartRequestInfo *gapInfo = [[TGFilePartRequestInfo alloc] init];
                        gapInfo.offset = nextWriteOffset;
                        gapInfo.length = dataGapLength;
                        [_explicitDownloadParts addObject:gapInfo];
                    }
                    
                    [_downloadingParts removeObjectForKey:nOffset];
                }
            }
            
            if (!hadCommit)
                break;
        }
        
        [self reportProgress:false];
        
        if (!self.cancelled)
            [self downloadFileParts];
    }
    else
    {
        [ActionStageInstance() actionFailed:self.path reason:-1];
    }
}

- (void)filePartDownloadFailed:(TLInputFileLocation *)__unused location offset:(int)offset length:(int)__unused length
{
    TGFilePartInfo *partInfo = _downloadingParts[@(offset)];
    if (partInfo != nil)
        [_downloadingParts removeObjectForKey:@(offset)];
    
    self.cancelled = true;
    
    [self cancelRequests];
    [ActionStageInstance() actionFailed:self.path reason:-1];
}

- (void)cancelRequests
{
    if (_worker1Token != nil)
    {
        [[TGTelegramNetworking instance] cancelDownloadWorkerRequestByToken:_worker1Token];
        _worker1Token = nil;
    }
    
    if (_worker2Token != nil)
    {
        [[TGTelegramNetworking instance] cancelDownloadWorkerRequestByToken:_worker2Token];
        _worker2Token = nil;
    }
    
    [_downloadingParts enumerateKeysAndObjectsUsingBlock:^(__unused NSNumber *nOffset, TGFilePartInfo *partInfo, __unused BOOL *stop)
    {
        if (partInfo.token != nil)
        {
            [TGTelegraphInstance cancelRequestByToken:partInfo.token];
            [_worker1.strongWorker cancelRequestById:partInfo.token];
            [_worker2.strongWorker cancelRequestById:partInfo.token];
        }
    }];
    
    [_worker1 releaseWorker];
    [_worker2 releaseWorker];

    [_downloadingParts removeAllObjects];
}

- (void)cancel
{
    [self cancelRequests];
    
    [super cancel];
}

@end
