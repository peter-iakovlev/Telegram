/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGLiveUploadActor.h"

#import "ActionStage.h"

#import "TGTelegramNetworking.h"
#import "TGNetworkWorker.h"

#import <MTProtoKit/MTRequest.h>
#import "TL/TLMetaScheme.h"

#import <CommonCrypto/CommonDigest.h>

#import <MTProtoKit/MTEncryption.h>

#import "TGDataItem.h"

@interface TGLiveUploadActorData () <ASWatcher>

@property (nonatomic, strong) ASHandle *actionHandle;

@end

@implementation TGLiveUploadActorData

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        _actionHandle = [[ASHandle alloc] initWithDelegate:self];
    }
    return self;
}

- (void)dealloc
{
    [ActionStageInstance() removeWatcher:self];
}

@end

@interface TGLiveUploadPart ()

@property (nonatomic, strong) id cancelToken;

@end

@implementation TGLiveUploadPart

@end

@interface TGLiveUploadActor ()
{
    TGDataItem *_fileItem;
    bool _encryptFile;
    
    int64_t _fileId;
    NSUInteger _availableSize;
    
    id _workerToken;
    TGNetworkWorkerGuard *_worker;
    
    NSMutableArray *_doneParts;
    NSMutableArray *_uploadingParts;
    
    bool _lateHeaderMode;
    NSData *(^_dataProvider)(NSUInteger offset, NSUInteger length);
    NSData *_unfinishedHeaderData;
    
    bool _liveMode;
    bool _canComplete;
    
    NSData *_aesKey;
    NSData *_aesIv;
    NSMutableData *_aesRunningIv;
    int32_t _keyFingerprint;
}

@end

@implementation TGLiveUploadActor

+ (void)load
{
    [ASActor registerActorClass:self];
}

- (void)dealloc
{
}

+ (NSString *)genericPath
{
    return @"/tg/liveUpload/@";
}

- (instancetype)initWithPath:(NSString *)path
{
    self = [super initWithPath:path];
    if (self != nil)
    {
        _doneParts = [[NSMutableArray alloc] init];
        _uploadingParts = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)_unlinkFileIfNeeded
{
}

- (void)_complete:(id)result
{
    [self _unlinkFileIfNeeded];
    
    [ActionStageInstance() actionCompleted:self.path result:result];
}

- (void)_fail
{
    [self _unlinkFileIfNeeded];
    
    [ActionStageInstance() actionFailed:self.path reason:-1];
}

- (void)execute:(NSDictionary *)options
{
    arc4random_buf(&_fileId, 8);
    
    _fileItem = options[@"fileItem"];
    if (_fileItem == nil && options[@"filePath"] != nil)
        _fileItem = [[TGDataItem alloc] initWithFilePath:options[@"filePath"]];
    
    _encryptFile = [options[@"encryptFile"] boolValue];
    _lateHeaderMode = [options[@"lateHeader"] boolValue];
    _dataProvider = [options[@"dataProvider"] copy];
    
    _liveMode = true;
    
    if (_fileItem == nil)
        [self _fail];
    else
    {
        if (_encryptFile)
        {
            uint8_t rawKey[32];
            __unused int result = SecRandomCopyBytes(kSecRandomDefault, 32, rawKey);
            _aesKey = [[NSData alloc] initWithBytes:rawKey length:32];
            uint8_t rawIv[32];
            result = SecRandomCopyBytes(kSecRandomDefault, 32, rawIv);
            _aesIv = [[NSData alloc] initWithBytes:rawIv length:32];
            _aesRunningIv = [[NSMutableData alloc] initWithData:_aesIv];
            
            uint8_t keyPlusIv[32 + 32];
            [_aesKey getBytes:keyPlusIv range:NSMakeRange(0, 32)];
            [_aesIv getBytes:keyPlusIv + 32 range:NSMakeRange(0, 32)];
            
            unsigned char digest[CC_MD5_DIGEST_LENGTH];
            CC_MD5(keyPlusIv, 32 + 32, digest);
            
            int32_t digestHigh = 0;
            int32_t digestLow = 0;
            memcpy(&digestHigh, digest, 4);
            memcpy(&digestLow, digest + 4, 4);
            
            _keyFingerprint = digestHigh ^ digestLow;
        }
        
        TGNetworkMediaTypeTag mediaTypeTag = (TGNetworkMediaTypeTag)([options[@"mediaTypeTag"] intValue]);
        
        __weak TGLiveUploadActor *weakSelf = self;
        _workerToken = [[TGTelegramNetworking instance] requestDownloadWorkerForDatacenterId:[TGTelegramNetworking instance].masterDatacenterId type:mediaTypeTag completion:^(TGNetworkWorkerGuard *worker)
        {
            [ActionStageInstance() dispatchOnStageQueue:^
            {
                __strong TGLiveUploadActor *strongSelf = weakSelf;
                [strongSelf _beginWithWorker:worker];
            }];
        }];
    }
}

- (void)_beginWithWorker:(TGNetworkWorkerGuard *)worker
{
    _worker = worker;
    
    [_worker.strongWorker ensureConnection];
    
    [self _dequeuePartIfAny];
}

- (void)updateSize:(NSUInteger)availableSize
{
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        if (availableSize > _availableSize)
            _availableSize = availableSize;
        
        [self _dequeuePartIfAny];
    }];
}

- (NSUInteger)doneSize
{
    NSUInteger value = 0;
    
    for (TGLiveUploadPart *part in _doneParts)
    {
        value += part.length;
    }
    
    return value;
}

- (void)_dequeuePartIfAny
{
    if (!_liveMode && [self doneSize] >= _availableSize)
    {
        if (_canComplete)
        {
            NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
            
            result[@"fileId"] = @(_fileId);
            result[@"partCount"] = @(_doneParts.count);
            result[@"fileSize"] = @(_availableSize);
            
            if (_encryptFile && _aesKey != nil &&_aesIv != nil)
            {
                result[@"aesKey"] = _aesKey;
                result[@"aesIv"] = _aesIv;
                result[@"aesKeyFingerprint"] = @(_keyFingerprint);
            }
            
            if (_fileItem != nil)
            {
                CC_MD5_CTX ctx;
                CC_MD5_Init(&ctx);
                NSUInteger bufferSize = 4 * 1024;
                for (NSUInteger i = 0; i < _availableSize; i += bufferSize)
                {
                    NSUInteger currentBufferSize = MIN(bufferSize, _availableSize - i);
                    NSData *data = [_fileItem readDataAtOffset:i length:currentBufferSize];
                    CC_MD5_Update(&ctx, data.bytes, (CC_LONG)data.length);
                }
                unsigned char md5Buffer[16];
                CC_MD5_Final(md5Buffer, &ctx);
                NSString *hash = [[NSString alloc] initWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x", md5Buffer[0], md5Buffer[1], md5Buffer[2], md5Buffer[3], md5Buffer[4], md5Buffer[5], md5Buffer[6], md5Buffer[7], md5Buffer[8], md5Buffer[9], md5Buffer[10], md5Buffer[11], md5Buffer[12], md5Buffer[13], md5Buffer[14], md5Buffer[15]];
                result[@"md5"] = hash;
            }
            
            [self _complete:result];
        }
    }
    else
    {
        NSInteger availableUploadSlots = MAX(0, (_liveMode ? (_lateHeaderMode ? 8 : 2) : 8) - (NSInteger)_uploadingParts.count);

        for (NSInteger slotIndex = 0; slotIndex < availableUploadSlots; slotIndex++)
        {
            NSUInteger processedSize = 0;
            for (TGLiveUploadPart *part in _uploadingParts)
            {
                processedSize = MAX(processedSize, part.offset + part.length);
            }
            for (TGLiveUploadPart *part in _doneParts)
            {
                processedSize = MAX(processedSize, part.offset + part.length);
            }
            
            NSUInteger nextPartSize = 16 * 1024;
            NSInteger minPartSize = 1024;
            
            bool takePart = false;
            if (_liveMode)
            {
                if (processedSize + minPartSize <= _availableSize)
                {
                    NSInteger calculatedPartSize = _availableSize - processedSize;
                    
                    if (_encryptFile)
                    {
                        while (calculatedPartSize % 16 != 0)
                        {
                            calculatedPartSize--;
                        }
                    }
                    
                    if (calculatedPartSize > 0)
                        takePart = true;
                }
            }
            else
            {
                if (processedSize < _availableSize || _unfinishedHeaderData != nil)
                    takePart = true;
            }
            
            if (takePart)
            {
                NSInteger currentPartSize = 0;
                NSData *partData = nil;
                bool isHeader = false;
                
                if (_unfinishedHeaderData != nil)
                {
                    partData = _unfinishedHeaderData;
                    _unfinishedHeaderData = nil;
                    currentPartSize = partData.length;
                    isHeader = true;
                }
                else
                {
                    currentPartSize = MIN((NSInteger)nextPartSize, MAX(0, (NSInteger)_availableSize - (NSInteger)processedSize));
                    
                    if (_encryptFile)
                    {
                        if (_liveMode || processedSize + currentPartSize < _availableSize)
                        {
                            while (currentPartSize % 16 != 0)
                            {
                                currentPartSize--;
                            }
                        }
                    }
                    
                    if (_dataProvider != nil)
                        partData = _dataProvider(processedSize, currentPartSize);
                    else
                        partData = [_fileItem readDataAtOffset:processedSize length:currentPartSize];
                }
                
                if (partData.length == (NSUInteger)currentPartSize)
                {
                    NSData *alignedPartData = partData;
                    if (_encryptFile)
                    {
                        NSMutableData *tempData = [[NSMutableData alloc] initWithData:partData];
                        
                        while (tempData.length == 0 || (NSInteger)tempData.length % 16 != 0)
                        {
                            uint8_t zero = 0;
                            [tempData appendBytes:&zero length:1];
                        }
                        
                        MTAesEncryptInplaceAndModifyIv(tempData, _aesKey, _aesRunningIv);
                        
                        alignedPartData = tempData;
                    }
                    
                    MTRequest *request = [[MTRequest alloc] init];
                    
                    TLRPCupload_saveFilePart$upload_saveFilePart *saveFilePart = [[TLRPCupload_saveFilePart$upload_saveFilePart alloc] init];
                    saveFilePart.file_id = _fileId;
                    saveFilePart.file_part = (int32_t)(isHeader ? 0 : ((_lateHeaderMode ? 1 : 0) + _doneParts.count + _uploadingParts.count));
                    saveFilePart.bytes = alignedPartData;
                    request.body = saveFilePart;
                    
                    int32_t partIndex = saveFilePart.file_part;
                    
                    TGLiveUploadPart *part = [[TGLiveUploadPart alloc] init];
                    part.partIndex = partIndex;
                    part.offset = isHeader ? 0 : processedSize;
                    part.length = currentPartSize;
                    part.cancelToken = request.internalId;
                    [_uploadingParts addObject:part];
                    
                    TGLog(@"[TGLiveUploadActor#%p uploading part at %d (%d bytes)]", self, partIndex, (int)currentPartSize);
                    
                    __weak TGLiveUploadActor *weakSelf = self;
                    [request setCompleted:^(__unused id result, __unused NSTimeInterval timestamp, id error)
                    {
                        [ActionStageInstance() dispatchOnStageQueue:^
                        {
                            __strong TGLiveUploadActor *strongSelf = weakSelf;
                            if (error == nil)
                                [strongSelf partUploadSuccess:partIndex];
                            else
                                [strongSelf partUploadFailed];
                        }];
                    }];
                    
                    [_worker.strongWorker addRequest:request];
                }
                else
                {
                    [self _fail];
                    
                    return;
                }
            }
        }
    }
}

- (void)partUploadSuccess:(int32_t)partIndex
{
    TGLog(@"[TGLiveUploadActor#%p finished part at %d]", self, (int)partIndex);
    
    NSInteger index = -1;
    for (TGLiveUploadPart *part in _uploadingParts)
    {
        index++;
        if (part.partIndex == partIndex)
        {
            [_doneParts addObject:part];
            [_uploadingParts removeObjectAtIndex:(NSUInteger)index];
            
            break;
        }
    }
    
    if (!_liveMode)
        [self notifyAboutProgress];
    
    [self _dequeuePartIfAny];
}

- (void)notifyAboutProgress
{
    [ActionStageInstance() dispatchMessageToWatchers:self.path messageType:@"progress" message:@([self progress])];
}

- (void)partUploadFailed
{
    [self _fail];
}

- (TGLiveUploadActorData *)finishRestOfFile:(NSUInteger)finalSize
{
    NSUInteger alignedFinalSize = finalSize;
    
    if (_encryptFile)
    {
        while (alignedFinalSize % 16 != 0)
        {
            alignedFinalSize++;
        }
    }
    
    TGLiveUploadActorData *data = [[TGLiveUploadActorData alloc] init];
    [ActionStageInstance() requestActor:self.path options:nil flags:-1 watcher:data];
    data.path = self.path;
    
    _liveMode = false;
    
    _availableSize = finalSize;
    
    [self _dequeuePartIfAny];
    
    return data;
}

- (TGLiveUploadActorData *)finishRestOfFileWithHeader:(NSData *)header finalSize:(NSUInteger)finalSize
{
    TGLiveUploadActorData *data = [[TGLiveUploadActorData alloc] init];
    [ActionStageInstance() requestActor:self.path options:nil flags:-1 watcher:data];
    data.path = self.path;
    
    _liveMode = false;
    _lateHeaderMode = false;
    
    _availableSize = finalSize;
    _unfinishedHeaderData = header;
    
    for (TGLiveUploadPart *part in _uploadingParts)
    {
        part.offset += header.length;
    }
    
    for (TGLiveUploadPart *part in _doneParts)
    {
        part.offset += header.length;
    }
    
    _dataProvider = nil;
    
    [self _dequeuePartIfAny];
    
    return data;
}

- (void)completeWhenReady
{
    _canComplete = true;
    
    [self _dequeuePartIfAny];
}

- (float)progress
{
    if (_availableSize > 0)
        return MAX(0.0f, MIN(1.0f, [self doneSize] / (float)_availableSize));
    
    return 0.0f;
}

- (void)cancel
{
    for (TGLiveUploadPart *part in _uploadingParts)
    {
        [_worker.strongWorker cancelRequestByIdSoft:part.cancelToken];
    }
    [_uploadingParts removeAllObjects];
    
    [super cancel];
}

@end
