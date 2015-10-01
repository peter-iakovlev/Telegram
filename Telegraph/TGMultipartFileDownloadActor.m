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
    
@interface TGFilePartInfo : NSObject

@property (nonatomic, strong) id token;
@property (nonatomic) NSTimeInterval startTime;
@property (nonatomic) int partLength;
@property (nonatomic) int downloadedLength;
@property (nonatomic) NSData *downloadedData;

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
        
#if TGUseModernNetworking
        __weak TGMultipartFileDownloadActor *weakSelf = self;
        _worker1Token = [[TGTelegramNetworking instance] requestDownloadWorkerForDatacenterId:_datacenterId completion:^(TGNetworkWorkerGuard *worker)
        {
            __strong TGMultipartFileDownloadActor *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                [strongSelf downloadFilePartsWithWorker:worker];
            }
        }];
        
        _worker2Token = [[TGTelegramNetworking instance] requestDownloadWorkerForDatacenterId:_datacenterId completion:^(TGNetworkWorkerGuard *worker)
        {
            __strong TGMultipartFileDownloadActor *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                [strongSelf assignAdditionalWorker:worker];
            }
        }];
#else
        [self downloadFilePartsWithWorker:nil];
#endif
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
            if (partInfo.downloadedData == nil)
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
                partInfo.partLength = partLength;
                _downloadingParts[@(nextDownloadOffset)] = partInfo;
                
                activeDownloadingParts++;
            }
            else
            {
                TGFilePartRequestInfo *explicitPartRequest = [_explicitDownloadParts firstObject];
                [requestList addObject:explicitPartRequest];
                
                TGFilePartInfo *partInfo = [[TGFilePartInfo alloc] init];
                partInfo.partLength = explicitPartRequest.length;
                _downloadingParts[@(explicitPartRequest.offset)] = partInfo;
                activeDownloadingParts++;
                
                [_explicitDownloadParts removeObjectAtIndex:0];
            }
        }
        
        for (TGFilePartRequestInfo *requestInfo in requestList)
        {
#if TGUseModernNetworking
            MTRequest *request = [[MTRequest alloc] init];
            
            TLRPCupload_getFile$upload_getFile *getFile = [[TLRPCupload_getFile$upload_getFile alloc] init];
            
            TLInputFileLocation *location = _fileLocation;
            getFile.location = location;
            getFile.offset = requestInfo.offset;
            getFile.limit = requestInfo.length;
            request.body = getFile;
            
            __weak TGMultipartFileDownloadActor *weakSelf = self;
            [request setCompleted:^(TLupload_File *result, __unused NSTimeInterval timestamp, id error)
            {
                [ActionStageInstance() dispatchOnStageQueue:^
                {
                    __strong TGMultipartFileDownloadActor *strongSelf = weakSelf;
                    
                    if (error == nil)
                        [strongSelf filePartDownloadSuccess:location offset:requestInfo.offset length:requestInfo.length data:result.bytes];
                    else
                        [strongSelf filePartDownloadFailed:location offset:requestInfo.offset length:requestInfo.length];
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
#else
            id token = [TGTelegraphInstance doDownloadFilePart:_datacenterId location:_fileLocation offset:requestInfo.offset length:requestInfo.length actor:(id<TGFileDownloadActor>)self];
#endif
            ((TGFilePartInfo *)_downloadingParts[@(requestInfo.offset)]).token = token;
        }
    }
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
