#import "TGFileUploadActor.h"

#import "TGTelegraph.h"
#import "TGTelegraphProtocols.h"

#import "TGTelegramNetworking.h"
#import "TGNetworkWorker.h"
#import <MTProtoKit/MTRequest.h>

#import "ActionStage.h"
#import "SGraphObjectNode.h"

#import "TGLiveUploadActor.h"

#import "TL/TLMetaScheme.h"

#import <Security/Security.h>
#import <CommonCrypto/CommonCrypto.h>

#import <MTProtoKit/MTEncryption.h>

#import <vector>

#define PHOTO_PART_SIZE 8 * 1024
#define VIDEO_PART_SIZE 64 * 1024

struct FilePart
{
    int index;
    int length;
    bool uploading;
    
    FilePart(int index_, int length_) :
        index(index_), length(length_), uploading(false)
    {
    }
};

@interface TGFileUploadActor () <TGFileUploadActor, ASWatcher>
{
    std::vector<FilePart> _partsToUpload;
    
    bool _isEncrypted;
    NSData *_encryptionKey;
    NSData *_encryptionIv;
    NSMutableData *_encryptionRunningIv;
    int64_t _encryptionKeyFingerprint;
    NSData *_thumbnail;
    
    int _thumbnailWidth;
    int _thumbnailHeight;
    int _width;
    int _height;
    int _fileSize;
    
    bool _uploadInband;
    bool _useBigFileParts;
    
    CC_MD5_CTX _md5;
    
    id _workerToken;
    TGNetworkWorkerGuard *_worker;
}

@property (nonatomic, strong) ASHandle *actionHandle;

@property (nonatomic, strong) NSInputStream *is;

@property (nonatomic) int64_t fileId;
@property (nonatomic) int partCount;

@property (nonatomic, strong) NSString *fileExtension;

@property (nonatomic, strong) NSMutableArray *cancelTokenList;

@end

@implementation TGFileUploadActor

+ (NSString *)genericPath
{
    return @"/tg/upload/@";
}

- (id)initWithPath:(NSString *)path
{
    self = [super initWithPath:path];
    if (self != nil)
    {
        _actionHandle = [[ASHandle alloc] initWithDelegate:self];
        
        _cancelTokenList = [[NSMutableArray alloc] init];
        
        CC_MD5_Init(&_md5);
    }
    return self;
}

- (void)dealloc
{
    [_actionHandle reset];
    [ActionStageInstance() removeWatcher:self];
    
    [_is close];
    
    if (_workerToken != nil)
    {
        [[TGTelegramNetworking instance] cancelDownloadWorkerRequestByToken:_workerToken];
        _workerToken = nil;
    }
    
    if (_worker != nil)
    {
        [_worker releaseWorker];
        _worker = nil;
    }
}

- (void)prepare:(NSDictionary *)options
{
    if (options[@"explicitQueueName"] != nil)
        self.requestQueueName = options[@"explicitQueueName"];
    
    [super prepare:options];
}

- (void)execute:(NSDictionary *)options
{
    _isEncrypted = [options[@"encrypt"] boolValue];
    _thumbnail = options[@"thumbnail"];
    
    _thumbnailWidth = [options[@"thumbnailWidth"] intValue];
    _thumbnailHeight = [options[@"thumbnailHeight"] intValue];
    _width = [options[@"width"] intValue];
    _height = [options[@"height"] intValue];
    _fileSize = [options[@"fileSize"] intValue];
    
    __unused int result = SecRandomCopyBytes(kSecRandomDefault, 8, (uint8_t *)&_fileId);
    
    if (_isEncrypted)
    {
        uint8_t rawKey[32];
        result = SecRandomCopyBytes(kSecRandomDefault, 32, rawKey);
        _encryptionKey = [[NSData alloc] initWithBytes:rawKey length:32];
        uint8_t rawIv[32];
        result = SecRandomCopyBytes(kSecRandomDefault, 32, rawIv);
        _encryptionIv = [[NSData alloc] initWithBytes:rawIv length:32];
        _encryptionRunningIv = [[NSMutableData alloc] initWithData:_encryptionIv];
    }
    
    _fileExtension = [options objectForKey:@"ext"];
    if (_fileExtension == nil)
        _fileExtension = @"jpg";
    
    if (options[@"liveData"] != nil)
    {
        TGLiveUploadActorData *liveData = options[@"liveData"];
        TGLiveUploadActor *actor = (TGLiveUploadActor *)[ActionStageInstance() executingActorWithPath:liveData.path];
        if (actor != nil)
        {
            [ActionStageInstance() requestActor:liveData.path options:nil flags:0 watcher:self];
            [ActionStageInstance() removeWatcher:(id<ASWatcher>)liveData];
            
            [ActionStageInstance() nodeRetrieveProgress:self.path progress:[actor progress]];
            [actor completeWhenReady];
        }
        else
            [ActionStageInstance() actionFailed:self.path reason:-1];
    }
    else if ([options objectForKey:@"data"] != nil)
    {
        NSData *data = [options objectForKey:@"data"];
        if (data == nil || data.length == 0)
        {
            [ActionStageInstance() nodeRetrieveFailed:self.path];
        }
        else
        {
            _fileSize = (int)data.length;
            
            int partSize = PHOTO_PART_SIZE;
            
            if (_fileSize >= 10 * 1024 * 1024)
            {
                _useBigFileParts = true;
                partSize = _fileSize / 3000;
                while ((1024 * 1024) % partSize != 0)
                {
                    partSize++;
                }
                
                partSize = MAX(partSize, VIDEO_PART_SIZE);
            }
            
            int length = (int)data.length;
            int index = -1;
            for (int i = 0; i < length; i += partSize)
            {
                index++;
                int blockSize = MIN(partSize, length - i);
                _partsToUpload.push_back(FilePart(index, blockSize));
            }
            
            _partCount = (int)_partsToUpload.size();
            
            TGLog(@"Uploading %d kbytes (%d parts)", length / 1024, _partCount);
            
            _is = [[NSInputStream alloc] initWithData:data];
            [_is open];
            
#if TGUseModernNetworking
            TGNetworkMediaTypeTag mediaTypeTag = (TGNetworkMediaTypeTag)[options[@"mediaTypeTag"] intValue];
            __weak TGFileUploadActor *weakSelf = self;
            _workerToken = [[TGTelegramNetworking instance] requestDownloadWorkerForDatacenterId:[[TGTelegramNetworking instance] masterDatacenterId] type:mediaTypeTag completion:^(TGNetworkWorkerGuard *worker)
            {
                [ActionStageInstance() dispatchOnStageQueue:^
                {
                    __strong TGFileUploadActor *strongSelf = weakSelf;
                    [strongSelf beginWithWorker:worker];
                }];
            }];
#else
            [self beginWithWorker:nil];
#endif
        }
    }
    else if ([options objectForKey:@"file"] != nil)
    {
        NSString *fileName = [options objectForKey:@"file"];
        
        static NSFileManager *fileManager = [[NSFileManager alloc] init];
        NSDictionary *attributes = [fileManager attributesOfItemAtPath:fileName error:nil];
        int fileSize = [[attributes objectForKey:NSFileSize] intValue];
        
        _fileSize = fileSize;
        
        if (_fileSize > 512 * 1024 * 3000)
        {
            [ActionStageInstance() actionFailed:self.path reason:-1];
            
            return;
        }
        
        if (attributes == nil || fileSize == 0)
        {
            [ActionStageInstance() nodeRetrieveFailed:self.path];
        }
        else
        {
            int partSize = VIDEO_PART_SIZE;

            if (_fileSize >= 10 * 1024 * 1024)
            {
                _useBigFileParts = true;
                partSize = _fileSize / 3000;
                while ((1024 * 1024) % partSize != 0)
                {
                    partSize++;
                }
                
                partSize = MAX(partSize, VIDEO_PART_SIZE);
            }
            
            int length = fileSize;
            int index = -1;
            for (int i = 0; i < length; )
            {
                index++;
                int blockSize = MIN(partSize, length - i);
                _partsToUpload.push_back(FilePart(index, blockSize));
                
                i += partSize;
            }
            
            _partCount = (int)_partsToUpload.size();
            
            _is = [[NSInputStream alloc] initWithFileAtPath:fileName];
            [_is open];
            
            uint8_t *buffer = (uint8_t *)malloc(partSize);
            
            free(buffer);
            
            NSUInteger bytesToUpload = 0;
            for (auto it = _partsToUpload.begin(); it != _partsToUpload.end(); it++)
            {
                bytesToUpload += (NSUInteger)it->length;
            }
            
            if (options[@"inbandUploadLimit"] != nil && bytesToUpload <= [options[@"inbandUploadLimit"] unsignedIntegerValue])
                _uploadInband = true;
            
            TGLog(@"Uploading %d (%d) bytes (%d parts by %d kb%s)", length, (int)(bytesToUpload), _partCount, partSize, _uploadInband ? ", inband" : "");
            
            if (_is.streamStatus != NSStreamStatusOpen)
                [ActionStageInstance() nodeRetrieveFailed:self.path];
            else
            {
#if TGUseModernNetworking
                if (_uploadInband)
                    [self beginWithWorker:nil];
                else
                {
                    TGNetworkMediaTypeTag mediaTypeTag = (TGNetworkMediaTypeTag)([options[@"mediaTypeTag"] intValue]);
                    __weak TGFileUploadActor *weakSelf = self;
                    _workerToken = [[TGTelegramNetworking instance] requestDownloadWorkerForDatacenterId:[[TGTelegramNetworking instance] masterDatacenterId] type:mediaTypeTag completion:^(TGNetworkWorkerGuard *worker)
                    {
                        __strong TGFileUploadActor *strongSelf = weakSelf;
                        [strongSelf beginWithWorker:worker];
                    }];
                }
#else
                [self beginWithWorker:nil];
#endif
            }
        }
    }
    else
    {
        [ActionStageInstance() nodeRetrieveFailed:self.path];
    }
}

- (void)beginWithWorker:(TGNetworkWorkerGuard *)worker
{
    _worker = worker;
    
    [self sendAnyPart];
}

- (void)sendAnyPart
{
    if (self.cancelled)
        return;
    
    if (_partsToUpload.empty())
    {
        if (_isEncrypted)
        {
            NSString *hash = nil;
            unsigned char md5Buffer[16];
            CC_MD5_Final(md5Buffer, &_md5);
            hash = [[NSString alloc] initWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x", md5Buffer[0], md5Buffer[1], md5Buffer[2], md5Buffer[3], md5Buffer[4], md5Buffer[5], md5Buffer[6], md5Buffer[7], md5Buffer[8], md5Buffer[9], md5Buffer[10], md5Buffer[11], md5Buffer[12], md5Buffer[13], md5Buffer[14], md5Buffer[15]];
            
            uint8_t keyPlusIv[32 + 32];
            [_encryptionKey getBytes:keyPlusIv range:NSMakeRange(0, 32)];
            [_encryptionIv getBytes:keyPlusIv + 32 range:NSMakeRange(0, 32)];
            
            unsigned char digest[CC_MD5_DIGEST_LENGTH];
            CC_MD5(keyPlusIv, 32 + 32, digest);
            
            int32_t digestHigh = 0;
            int32_t digestLow = 0;
            memcpy(&digestHigh, digest, 4);
            memcpy(&digestLow, digest + 4, 4);
            
            int32_t keyFingerprint = digestHigh ^ digestLow;
            
            id inputFile = nil;
            
            if (_useBigFileParts)
            {
                TLInputEncryptedFile$inputEncryptedFileBigUploaded *inputEncryptedFileBig = [[TLInputEncryptedFile$inputEncryptedFileBigUploaded alloc] init];
                inputEncryptedFileBig.n_id = _fileId;
                inputEncryptedFileBig.parts = _partCount;
                inputEncryptedFileBig.key_fingerprint = keyFingerprint;
                
                inputFile = inputEncryptedFileBig;
            }
            else
            {
                TLInputEncryptedFile$inputEncryptedFileUploaded *inputEncryptedFile = [[TLInputEncryptedFile$inputEncryptedFileUploaded alloc] init];
                inputEncryptedFile.parts = _partCount;
                inputEncryptedFile.md5_checksum = hash;
                inputEncryptedFile.n_id = _fileId;
                inputEncryptedFile.key_fingerprint = keyFingerprint;
                
                inputFile = inputEncryptedFile;
            }
            
            [ActionStageInstance() nodeRetrieveProgress:self.path progress:1.0f];
            [ActionStageInstance() actionCompleted:self.path result:@{
                @"file": inputFile,
                @"key": _encryptionKey,
                @"iv": _encryptionIv,
                @"thumbnail": _thumbnail == nil ? [NSData data] : _thumbnail,
                @"thumbnailWidth": @(_thumbnailWidth),
                @"thumbnailHeight": @(_thumbnailHeight),
                @"width": @(_width),
                @"height": @(_height),
                @"fileSize": @(_fileSize)
             }];
        }
        else
        {
            NSString *hash = nil;
            unsigned char md5Buffer[16];
            CC_MD5_Final(md5Buffer, &_md5);
            hash = [[NSString alloc] initWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x", md5Buffer[0], md5Buffer[1], md5Buffer[2], md5Buffer[3], md5Buffer[4], md5Buffer[5], md5Buffer[6], md5Buffer[7], md5Buffer[8], md5Buffer[9], md5Buffer[10], md5Buffer[11], md5Buffer[12], md5Buffer[13], md5Buffer[14], md5Buffer[15]];
            
            id inputFile = nil;
            
            if (_useBigFileParts)
            {
                TLInputFile$inputFileBig *inputFileBig = [[TLInputFile$inputFileBig alloc] init];
                
                inputFileBig.parts = _partCount;
                inputFileBig.n_id = _fileId;
                inputFileBig.name = [[NSString alloc] initWithFormat:@"file.%@", _fileExtension];
                
                inputFile = inputFileBig;
            }
            else
            {
                TLInputFile$inputFile *inputFileSmall = [[TLInputFile$inputFile alloc] init];
                inputFileSmall.parts = _partCount;
                inputFileSmall.md5_checksum = hash;
                inputFileSmall.n_id = _fileId;
                inputFileSmall.name = [[NSString alloc] initWithFormat:@"file.%@", _fileExtension];
                
                inputFile = inputFileSmall;
            }
            
            [ActionStageInstance() nodeRetrieveProgress:self.path progress:1.0f];
            [ActionStageInstance() actionCompleted:self.path result:@{@"file": inputFile}];
        }
    }
    else
    {
        float progress = 0.0f;
        if (_partCount != 0)
            progress = MIN(1.0f, (_partCount - _partsToUpload.size()) / (float)_partCount);
        progress = MAX(0.001f, progress);
        
        [ActionStageInstance() nodeRetrieveProgress:self.path progress:progress];
        
        int concurrentUploads = 16;
        
        for (std::vector<FilePart>::iterator it = _partsToUpload.begin(); it != _partsToUpload.end(); it++)
        {
            if (it->uploading)
            {
                concurrentUploads--;
                if (concurrentUploads == 0)
                    break;
            }
        }
        
        for (int i = 0; i < concurrentUploads; i++)
        {
            for (std::vector<FilePart>::iterator it = _partsToUpload.begin(); it != _partsToUpload.end(); it++)
            {
                if (!it->uploading)
                {
                    NSData *partData = [_is readData:it->length];
                    
                    if (_isEncrypted)
                    {
                        NSMutableData *tmpData = [[NSMutableData alloc] initWithData:partData];
                                                  
                        if (tmpData.length % 16 != 0)
                        {
                            while (tmpData.length % 16 != 0)
                            {
                                uint8_t zero = 0;
                                [tmpData appendBytes:&zero length:1];
                            }
                        }
                    
                        MTAesEncryptInplaceAndModifyIv(tmpData, _encryptionKey, _encryptionRunningIv);
                        partData = tmpData;
                    }
                    
                    CC_MD5_Update(&_md5, [partData bytes], (CC_LONG)[partData length]);
                    
                    it->uploading = true;
                    id token = nil;
                    
#if TGUseModernNetworking
                    MTRequest *request = [[MTRequest alloc] init];
                    
                    if (_useBigFileParts)
                    {
                        TLRPCupload_saveBigFilePart$upload_saveBigFilePart *saveBigFilePart = [[TLRPCupload_saveBigFilePart$upload_saveBigFilePart alloc] init];
                        saveBigFilePart.file_id = _fileId;
                        saveBigFilePart.file_part = it->index;
                        saveBigFilePart.file_total_parts = _partCount;
                        saveBigFilePart.bytes = partData;
                        request.body = saveBigFilePart;
                    }
                    else
                    {
                        TLRPCupload_saveFilePart$upload_saveFilePart *saveFilePart = [[TLRPCupload_saveFilePart$upload_saveFilePart alloc] init];
                        saveFilePart.file_id = _fileId;
                        saveFilePart.file_part = it->index;
                        saveFilePart.bytes = partData;
                        request.body = saveFilePart;
                    }
                    
                    int partId = it->index;
                    
                    __weak TGFileUploadActor *weakSelf = self;
                    [request setCompleted:^(__unused id result, __unused NSTimeInterval, id error)
                    {
                        [ActionStageInstance() dispatchOnStageQueue:^
                        {
                            __strong TGFileUploadActor *strongSelf = weakSelf;
                            if (error == nil)
                                [strongSelf filePartUploadSuccess:partId];
                            else
                                [strongSelf filePartUploadFailed:partId];
                        }];
                    }];
                    
                    token = request.internalId;
                    
                    if (_uploadInband)
                        [[TGTelegramNetworking instance] addRequest:request];
                    else
                    {
                        [_worker.strongWorker addRequest:request];
                    }
#else
                    if (_useBigFileParts)
                        token = [TGTelegraphInstance doUploadBigFilePart:_fileId partId:it->index data:partData totalParts:_partCount actor:self];
                    else
                        token = [TGTelegraphInstance doUploadFilePart:_fileId partId:it->index data:partData actor:self];
#endif
                    
                    if (token != nil)
                        [_cancelTokenList addObject:token];
                    break;
                }
            }
        }
    }
}

- (void)filePartUploadSuccess:(int)partId
{
    for (std::vector<FilePart>::iterator it = _partsToUpload.begin(); it != _partsToUpload.end(); it++)
    {
        if (it->index == partId)
        {
            _partsToUpload.erase(it);
            break;
        }
    }
    
    [self sendAnyPart];
}

- (void)filePartUploadFailed:(int)__unused partId
{
    [ActionStageInstance() nodeRetrieveFailed:self.path];
}

- (void)cancel
{
    for (id token in _cancelTokenList)
    {
        [TGTelegraphInstance cancelRequestByToken:token];
        [_worker.strongWorker cancelRequestById:token];
    }
    
    _cancelTokenList = nil;
    
    if (_workerToken != nil)
    {
        [[TGTelegramNetworking instance] cancelDownloadWorkerRequestByToken:_workerToken];
        _workerToken = nil;
    }
    
    if (_worker != nil)
    {
        [_worker releaseWorker];
        _worker = nil;
    }
    
    [super cancel];
}

- (void)actorCompleted:(int)status path:(NSString *)path result:(id)result
{
    if ([path hasPrefix:@"/tg/liveUpload/"])
    {
        if (status == ASStatusSuccess)
        {
            id inputFile = nil;
            
            if (_isEncrypted)
            {
                if (_useBigFileParts)
                {
                    TLInputEncryptedFile$inputEncryptedFileBigUploaded *inputEncryptedFileBig = [[TLInputEncryptedFile$inputEncryptedFileBigUploaded alloc] init];
                    inputEncryptedFileBig.n_id = [result[@"fileId"] longLongValue];
                    inputEncryptedFileBig.parts = [result[@"partCount"] intValue];
                    inputEncryptedFileBig.key_fingerprint = [result[@"aesKeyFingerprint"] intValue];
                    
                    inputFile = inputEncryptedFileBig;
                }
                else
                {
                    TLInputEncryptedFile$inputEncryptedFileUploaded *inputEncryptedFile = [[TLInputEncryptedFile$inputEncryptedFileUploaded alloc] init];
                    inputEncryptedFile.parts = [result[@"partCount"] intValue];
                    //inputEncryptedFile.md5_checksum = result[@"md5"] == nil ? @"" : result[@"md5"];
                    inputEncryptedFile.n_id = [result[@"fileId"] longLongValue];
                    inputEncryptedFile.key_fingerprint = [result[@"aesKeyFingerprint"] intValue];
                    
                    inputFile = inputEncryptedFile;
                }
            }
            else
            {
                if (_useBigFileParts)
                {
                    TLInputFile$inputFileBig *inputFileBig = [[TLInputFile$inputFileBig alloc] init];
                    
                    inputFileBig.parts = [result[@"partCount"] intValue];
                    inputFileBig.n_id = [result[@"fileId"] longLongValue];
                    inputFileBig.name = [[NSString alloc] initWithFormat:@"file.%@", _fileExtension];
                    
                    inputFile = inputFileBig;
                }
                else
                {
                    TLInputFile$inputFile *inputFileSmall = [[TLInputFile$inputFile alloc] init];
                    inputFileSmall.parts = [result[@"partCount"] intValue];
                    inputFileSmall.md5_checksum = result[@"md5"] == nil ? @"" : result[@"md5"];
                    inputFileSmall.n_id = [result[@"fileId"] longLongValue];
                    inputFileSmall.name = [[NSString alloc] initWithFormat:@"file.%@", _fileExtension];
                    
                    inputFile = inputFileSmall;
                }
            }
            
            [ActionStageInstance() nodeRetrieveProgress:self.path progress:1.0f];
            
            NSMutableDictionary *selfResult = [[NSMutableDictionary alloc] init];
            
            selfResult[@"file"] = inputFile;
            if (result[@"fileSize"] != nil)
                selfResult[@"fileSize"] = result[@"fileSize"];
            if (result[@"aesKey"] != nil)
                selfResult[@"key"] = result[@"aesKey"];
            if (result[@"aesIv"] != nil)
                selfResult[@"iv"] = result[@"aesIv"];
            
            [ActionStageInstance() actionCompleted:self.path result:selfResult];
        }
        else
            [ActionStageInstance() actionFailed:self.path reason:-1];
    }
}

- (void)actorMessageReceived:(NSString *)path messageType:(NSString *)messageType message:(id)message
{
    if ([path hasPrefix:@"/tg/liveUpload/"])
    {
        if ([messageType isEqualToString:@"progress"])
        {
            [ActionStageInstance() nodeRetrieveProgress:self.path progress:[(NSNumber *)message floatValue]];
        }
    }
}

@end
