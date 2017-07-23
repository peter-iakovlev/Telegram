#import "TGVideoDownloadActor.h"

#import "ActionStage.h"

#import "TGTelegraph.h"

#import "TGVideoMediaAttachment.h"

#import "TGCache.h"
#import "TGImageUtils.h"
#import "TGStringUtils.h"

#import "TGRemoteImageView.h"

#import "TGFileDownloadActor.h"

#import <MTProtoKit/MTEncryption.h>
#import <MTProtoKit/MTRequest.h>

#import "TGTelegramNetworking.h"
#import "TGNetworkWorker.h"

#import "TGDownloadManager.h"

#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>

#import <CommonCrypto/CommonDigest.h>

#include <map>

#import "TGAppDelegate.h"

#import "TGCdnFileData.h"

static NSMutableDictionary *rewriteDict()
{
    static NSMutableDictionary *dict = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        dict = [[NSMutableDictionary alloc] init];
    });
    return dict;
}

class TGVideoPartData
{
public:
    id token;
    NSTimeInterval startTime;
    int partOffset;
    int partLength;
    int downloadedLength;
    NSData *downloadedData;
    bool restart;
    
public:
    TGVideoPartData()
    {
        token = nil;
        startTime = CFAbsoluteTimeGetCurrent();
        downloadedLength = 0;
        partOffset = 0;
        partLength = 0;
        downloadedData = nil;
        restart = false;
    }
    
    TGVideoPartData(TGVideoPartData const &other)
    {
        if (this != &other)
        {
            token = other.token;
            startTime = other.startTime;
            partOffset = other.partOffset;
            partLength = other.partLength;
            downloadedLength = other.downloadedLength;
            downloadedData = other.downloadedData;
            restart = other.restart;
        }
    }
    
    TGVideoPartData & operator= (TGVideoPartData const &other)
    {
        if (this != &other)
        {
            token = other.token;
            startTime = other.startTime;
            partOffset = other.partOffset;
            partLength = other.partLength;
            downloadedLength = other.downloadedLength;
            downloadedData = other.downloadedData;
            restart = other.restart;
        }
        return *this;
    }
    
    ~TGVideoPartData()
    {
        token = nil;
        downloadedData = nil;
    }
};

@interface TGVideoDownloadActor ()
{
    std::map<int, TGVideoPartData> _downloadingParts;
    
    std::vector<std::pair<int, int> > _explicitDownloadParts;
    
    NSData *_encryptionKey;
    NSData *_encryptionIv;
    NSMutableData *_runningEncryptionIv;
    int32_t _finalSize;
    
    id _worker1Token;
    id _worker2Token;
    TGNetworkWorkerGuard *_worker1;
    TGNetworkWorkerGuard *_worker2;
    
    int _nextWorker;
    
    TGCdnFileData *_cdnFileData;
    
    SMetaDisposable *_reuploadDisposable;
    bool _isReuploading;
    
    NSDictionary<NSNumber *, NSData *> *_cdnFilePartHashes;
    SMetaDisposable *_partHashesDisposable;
}

@property (nonatomic, strong) NSString *storeFilePath;
@property (nonatomic, strong) NSString *tempStoreFilePath;
@property (nonatomic, strong) NSString *thumbnailFilePath;

@property (nonatomic, strong) NSOutputStream *fileStream;

@property (nonatomic) int64_t videoId;
@property (nonatomic) int64_t accessHash;
@property (nonatomic) int datacenterId;
@property (nonatomic) int videoFileLength;

@property (nonatomic, strong) TGVideoMediaAttachment *videoAttachment;

@property (nonatomic) int downloadedFileSize;

@property (nonatomic) bool reportedProgress;
@property (nonatomic) int lastReportedProgress;

@property (nonatomic) NSTimeInterval averageDownloadSpeed;
@property (nonatomic) int takenTimeSamples;

@property (nonatomic) float progress;

@property (nonatomic, strong) NSDictionary *additionalOptions;

@end

@implementation TGVideoDownloadActor

+ (NSString *)genericPath
{
    return @"/as/media/video/@";
}

+ (void)rewriteLocalFilePath:(NSString *)localFilePath remoteUrl:(NSString *)remoteUrl
{
    if (localFilePath != nil && remoteUrl != nil)
        [rewriteDict() setObject:remoteUrl forKey:localFilePath];
}

+ (NSString *)rewrittenUrlForLocalPath:(NSString *)localFilePath
{
    if (localFilePath == nil)
        return nil;
    
    return [rewriteDict() objectForKey:localFilePath];
}

+ (bool)isVideoDownloaded:(NSFileManager *)fileManager url:(NSString *)url
{
    if ([url hasPrefix:@"local-video:"])
        return true;
    
    static NSString *videosPath = nil;
    if (videosPath == nil)
    {
        videosPath = [[TGAppDelegate documentsPath] stringByAppendingPathComponent:@"video"];
    }
    
    if ([url hasPrefix:@"video"])
    {
        NSArray *urlComponents = [url componentsSeparatedByString:@":"];
        if (urlComponents.count != 5)
            return false;
        else
        {
            int64_t videoId = [[urlComponents objectAtIndex:1] longLongValue];
            NSString *storeFilePath = [videosPath stringByAppendingPathComponent:[[NSString alloc] initWithFormat:@"remote%llx.mov", videoId]];
            if ([fileManager fileExistsAtPath:storeFilePath])
                return true;
        }
    }
    else if ([url hasPrefix:@"mt-encrypted-file://"])
    {
        NSDictionary *args = [TGStringUtils argumentDictionaryInUrlString:[url substringFromIndex:@"mt-encrypted-file://?".length]];
        
        if (args[@"id"] != nil)
        {
            int64_t videoId = [args[@"id"] longLongValue];
            NSString *storeFilePath = [videosPath stringByAppendingPathComponent:[[NSString alloc] initWithFormat:@"remote%llx.mov", videoId]];
            if ([fileManager fileExistsAtPath:storeFilePath])
                return true;
        }
    }
    
    return false;
}

+ (NSString *)localPathForVideoUrl:(NSString *)url
{
    static NSString *videosPath = nil;
    if (videosPath == nil)
    {
        videosPath = [[TGAppDelegate documentsPath] stringByAppendingPathComponent:@"video"];
    }
    
    if ([url hasPrefix:@"video"])
    {
        NSArray *urlComponents = [url componentsSeparatedByString:@":"];
        if (urlComponents.count != 5)
            return nil;
        else
        {
            int64_t videoId = [[urlComponents objectAtIndex:1] longLongValue];
            NSString *storeFilePath = [videosPath stringByAppendingPathComponent:[[NSString alloc] initWithFormat:@"remote%llx.mov", videoId]];
            return storeFilePath;
        }
    }
    else if ([url hasPrefix:@"local-video:"])
    {
        NSString *videoFileName = [url substringFromIndex:@"local-video:".length];
        NSString *storeFilePath = [videosPath stringByAppendingPathComponent:videoFileName];
        return storeFilePath;
    }
    else if ([url hasPrefix:@"mt-encrypted-file://"])
    {
        NSDictionary *args = [TGStringUtils argumentDictionaryInUrlString:[url substringFromIndex:@"mt-encrypted-file://?".length]];
        
        if (args[@"id"] != nil)
        {
            int64_t videoId = [args[@"id"] longLongValue];
            NSString *storeFilePath = [videosPath stringByAppendingPathComponent:[[NSString alloc] initWithFormat:@"remote%llx.mov", videoId]];
            return storeFilePath;
        }
    }
    
    return nil;
}

- (id)initWithPath:(NSString *)path
{
    self = [super initWithPath:path];
    if (self != nil)
    {
        _actionHandle = [[ASHandle alloc] initWithDelegate:self];
        
        if ([path hasSuffix:@"+download)"])
        {
            self.requestQueueName = @"videoDownload";
        }
    }
    return self;
}

- (void)dealloc
{
    [_actionHandle reset];
    [ActionStageInstance() removeWatcher:self];
    
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
    
    [_partHashesDisposable dispose];
}

- (void)prepare:(NSDictionary *)options
{
    [super prepare:options];
}

- (void)execute:(NSDictionary *)options
{
    bool cachedOnly = false;
    
    _videoAttachment = [options objectForKey:@"videoAttachment"];
    _additionalOptions = options[@"additionalOptions"];
    
    NSString *videoUrl = [self.path substringWithRange:NSMakeRange(17, self.path.length - 1 - 17)];
    if ([videoUrl hasPrefix:@"cached:"])
    {
        cachedOnly = true;
        videoUrl = [videoUrl substringFromIndex:@"cached:".length];
    }
    
    NSFileManager *fileManager = [ActionStageInstance() globalFileManager];
    
    static NSString *videosPath = nil;
    if (videosPath == nil)
    {
        videosPath = [[TGAppDelegate documentsPath] stringByAppendingPathComponent:@"video"];
        if (![fileManager fileExistsAtPath:videosPath])
        {
            NSError *error = nil;
            [fileManager createDirectoryAtPath:videosPath withIntermediateDirectories:true attributes:nil error:&error];
            if (error != nil)
            {
                TGLog(@"%@", error);
                
                [ActionStageInstance() actionFailed:self.path reason:-1];
                return;
            }
        }
    }
    
    if ([videoUrl hasPrefix:@"local-video:"])
    {
        NSString *rewrittenUrl = [TGVideoDownloadActor rewrittenUrlForLocalPath:videoUrl];
        if (rewrittenUrl != nil)
            videoUrl = rewrittenUrl;
    }
    
    if ([videoUrl hasPrefix:@"video:"] || [videoUrl hasPrefix:@"mt-encrypted-file://"])
    {
        NSMutableDictionary *videoArgs = [[NSMutableDictionary alloc] init];
        
        if ([videoUrl hasPrefix:@"mt-encrypted-file://"])
        {
            NSString *parseUrl = videoUrl;
            if ([videoUrl hasSuffix:@"+download"])
                parseUrl = [videoUrl substringToIndex:videoUrl.length - @"+download".length];
            
            NSDictionary *args = [TGStringUtils argumentDictionaryInUrlString:[parseUrl substringFromIndex:@"mt-encrypted-file://?".length]];

            if (args[@"id"] != nil)
                videoArgs[@"videoId"] = args[@"id"];
            if (args[@"accessHash"] != nil)
                videoArgs[@"accessHash"] = args[@"accessHash"];
            if (args[@"dc"] != nil)
                videoArgs[@"datacenterId"] = args[@"dc"];
            if (args[@"size"] != nil)
                videoArgs[@"videoFileLength"] = args[@"size"];
            
            NSData *key = [args[@"key"] dataByDecodingHexString];
            
            _finalSize = [args[@"decryptedSize"] intValue];
            
            if (key.length != 64)
            {
                TGLog(@"***** Invalid file key length");
                [videoArgs removeAllObjects];
            }
            else
            {
                _encryptionKey = [key subdataWithRange:NSMakeRange(0, 32)];
                _encryptionIv = [key subdataWithRange:NSMakeRange(32, 32)];
                _runningEncryptionIv = [[NSMutableData alloc] initWithData:_encryptionIv];
                
                unsigned char digest[CC_MD5_DIGEST_LENGTH];
                CC_MD5(key.bytes, 32 + 32, digest);
                
                int32_t digestHigh = 0;
                int32_t digestLow = 0;
                memcpy(&digestHigh, digest, 4);
                memcpy(&digestLow, digest + 4, 4);
                
                int32_t key_fingerprint = digestHigh ^ digestLow;
                if (args[@"fingerprint"] != nil && [args[@"fingerprint"] intValue] != key_fingerprint)
                {
                    TGLog(@"***** Invalid file key fingerprint");
                    [videoArgs removeAllObjects];
                }
            }
        }
        else
        {
            NSArray *urlComponents = [videoUrl componentsSeparatedByString:@":"];
            if (urlComponents.count >= 5)
            {
                videoArgs[@"videoId"] = [urlComponents objectAtIndex:1];
                videoArgs[@"accessHash"] = [urlComponents objectAtIndex:2];
                videoArgs[@"datacenterId"] = [urlComponents objectAtIndex:3];
                videoArgs[@"videoFileLength"] = [urlComponents objectAtIndex:4];
            }
        }
        
        if (videoArgs[@"videoId"] == nil || videoArgs[@"accessHash"] == nil || videoArgs[@"datacenterId"] == nil || videoArgs[@"videoFileLength"] == nil)
        {
            [ActionStageInstance() actionFailed:self.path reason:-1];
        }
        else
        {
            _videoId = [videoArgs[@"videoId"] longLongValue];
            _accessHash = [videoArgs[@"accessHash"] longLongValue];
            _datacenterId = [videoArgs[@"datacenterId"] intValue];
            _videoFileLength = [videoArgs[@"videoFileLength"] intValue];
            
            if (_videoFileLength == 0)
            {
                [ActionStageInstance() actionFailed:self.path reason:-1];
            }
            else
            {
                _storeFilePath = [videosPath stringByAppendingPathComponent:[[NSString alloc] initWithFormat:@"remote%llx.mov", _videoId]];
                _tempStoreFilePath = [videosPath stringByAppendingPathComponent:[[NSString alloc] initWithFormat:@"remote%llx.part", _videoId]];
                _thumbnailFilePath = [[NSString alloc] initWithFormat:@"video-thumbnail-remote%llx.jpg", _videoId];
                
                if ([fileManager fileExistsAtPath:_storeFilePath])
                {
                    [ActionStageInstance() actionCompleted:self.path result:[[NSDictionary alloc] initWithObjectsAndKeys:_storeFilePath, @"filePath", nil]];
                }
                else if (!cachedOnly)
                {
                    if ([self.path hasSuffix:@"+download)"])
                    {
                        NSFileManager *fileManager = [ActionStageInstance() globalFileManager];
                        
                        NSError *error = nil;
                        NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:_tempStoreFilePath error:&error];
                        int fileSize = [[fileAttributes objectForKey:NSFileSize] intValue];
                        
                        if (fileAttributes == nil || fileSize % 1024 != 0)
                        {
                            if (fileAttributes != nil)
                            {
                                TGLog(@"Invalid partial file length %d, restarting", fileSize);
                                fileSize = 0;
                                [self cancelRequests];
                            }
                            [fileManager createFileAtPath:_tempStoreFilePath contents:[NSData data] attributes:nil];
                        }
                        
                        if ([videoUrl hasPrefix:@"mt-encrypted-file://"] && self.videoAttachment.roundMessage)
                        {
                            [fileManager removeItemAtPath:_tempStoreFilePath error:&error];
                            [fileManager createFileAtPath:_tempStoreFilePath contents:[NSData data] attributes:nil];
                            fileSize = 0;
                        }
                        
                        _downloadedFileSize = fileSize;
                        
                        _fileStream = [[NSOutputStream alloc] initToFileAtPath:_tempStoreFilePath append:true];
                        [_fileStream open];
                        
#if TGUseModernNetworking
                        __weak TGVideoDownloadActor *weakSelf = self;
                        _worker1Token = [[TGTelegramNetworking instance] requestDownloadWorkerForDatacenterId:_datacenterId type:TGNetworkMediaTypeTagVideo completion:^(TGNetworkWorkerGuard *worker)
                        {
                            __strong TGVideoDownloadActor *strongSelf = weakSelf;
                            if (strongSelf != nil)
                            {
                                [strongSelf downloadFilePartsWithWorker:worker];
                            }
                        }];
                        
                        _worker2Token = [[TGTelegramNetworking instance] requestDownloadWorkerForDatacenterId:_datacenterId type:TGNetworkMediaTypeTagVideo completion:^(TGNetworkWorkerGuard *worker)
                        {
                            __strong TGVideoDownloadActor *strongSelf = weakSelf;
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
                        if (_additionalOptions[@"peerId"] != nil && _additionalOptions[@"messageId"] != nil)
                        {
                            [[TGDownloadManager instance] enqueueItem:self.path messageId:[_additionalOptions[@"messageId"] intValue] itemId:[[TGMediaId alloc] initWithType:1 itemId:_videoId] groupId:[_additionalOptions[@"peerId"] longLongValue] itemClass:TGDownloadItemClassVideo];
                        }
                        
                        [ActionStageInstance() dispatchMessageToWatchers:self.path messageType:@"willDownloadVideo" message:[[NSDictionary alloc] initWithObjectsAndKeys:[[TGMediaId alloc] initWithType:1 itemId:_videoId], @"mediaId", nil]];
                        [ActionStageInstance() requestActor:[[NSString alloc] initWithFormat:@"%@+download)", [self.path substringToIndex:self.path.length - 1]] options:options watcher:self];
                    }
                }
                else
                {
                    [ActionStageInstance() actionFailed:self.path reason:-1];
                }
            }
        }
    }
    else if ([videoUrl hasPrefix:@"local-video:"])
    {
        NSString *filePath = [videosPath stringByAppendingPathComponent:[[NSString alloc] initWithFormat:@"%@", [videoUrl substringFromIndex:@"local-video:".length]]];
        [ActionStageInstance() actionCompleted:self.path result:[[NSDictionary alloc] initWithObjectsAndKeys:filePath, @"filePath", nil]];
    }
    else
    {
        [ActionStageInstance() actionFailed:self.path reason:-1];
    }
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
    
    TGLog(@"Average speed: %f kbytes/s", _averageDownloadSpeed / 1024.0f);
}

- (void)printParts
{
    for (std::map<int, TGVideoPartData>::iterator it = _downloadingParts.begin(); it != _downloadingParts.end(); it++)
    {
        TGLog(@"part %d — %d (%f — %f) data %d // %d", it->first, it->first + it->second.partLength, ((float)it->first) / ((float)_videoFileLength), ((float)(it->first + it->second.partLength)) / ((float)_videoFileLength), it->second.downloadedData.length, _videoFileLength);
    }
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
    if (_downloadedFileSize >= _videoFileLength)
    {
        if (_fileStream != nil)
        {
            [_fileStream close];
            _fileStream = nil;
        }
        
        NSError *error = nil;
        [[ActionStageInstance() globalFileManager] moveItemAtPath:_tempStoreFilePath toPath:_storeFilePath error:&error];
        if (error != nil)
        {
            [ActionStageInstance() actionFailed:self.path reason:-1];
        }
        else
        {
            if (_videoAttachment.roundMessage && _encryptionKey != nil)
            {
                NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
                [result setObject:_storeFilePath forKey:@"filePath"];

                [ActionStageInstance() actionCompleted:self.path result:result];
            }
            else
            {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                {
                    TGLog(@"Generating video preview");
                    
                    AVAsset *asset = [AVAsset assetWithURL:[NSURL fileURLWithPath:_storeFilePath]];
                    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
                    imageGenerator.maximumSize = CGSizeMake(800, 800);
                    imageGenerator.appliesPreferredTrackTransform = true;
                    NSError *imageError = nil;
                    CGImageRef imageRef = [imageGenerator copyCGImageAtTime:CMTimeMake(0, asset.duration.timescale) actualTime:NULL error:&imageError];
                    
                    UIImage *image = [[UIImage alloc] initWithCGImage:imageRef];
                    UIImage *thumbnailImage = nil;
                    
                    if (imageRef != nil)
                    {
                        if (_videoAttachment != nil)
                        {
                            NSString *thumbnailUrl = [_videoAttachment.thumbnailInfo closestImageUrlWithSize:CGSizeMake(90, 90) resultingSize:NULL];
                            thumbnailImage = TGScaleImageToPixelSize(image, TGFitSize(CGSizeMake(image.size.width * image.scale, image.size.height * image.scale), CGSizeMake(200, 200)));
                            NSData *thumbnailData = UIImageJPEGRepresentation(thumbnailImage, 0.85f);
                            
                            if (thumbnailData != nil)
                            {
                                [[TGRemoteImageView sharedCache] removeFromMemoryCache:thumbnailUrl matchEnd:true];
                                [[TGRemoteImageView sharedCache] cacheImage:nil withData:thumbnailData url:thumbnailUrl availability:TGCacheDisk];
                                
                                [ActionStageInstance() dispatchOnStageQueue:^
                                {
                                    TGFileDownloadActor *fileActor = (TGFileDownloadActor *)[ActionStageInstance() executingActorWithPath:[[NSString alloc] initWithFormat:@"/tg/file/(%@)", thumbnailUrl]];
                                    if (fileActor != nil)
                                    {
                                        [fileActor completeWithData:thumbnailData];
                                    }
                                    else
                                    {
                                        [ActionStageInstance() dispatchResource:[[NSString alloc] initWithFormat:@"/as/media/imageThumbnailUpdated"] resource:thumbnailUrl];
                                    }
                                }];
                            }
                        }
                        
                        [[TGRemoteImageView sharedCache] cacheImage:nil withData:UIImageJPEGRepresentation(image, 0.87f) url:_thumbnailFilePath availability:TGCacheDisk];
                        
                        if (imageRef != NULL)
                            CGImageRelease(imageRef);
                    }
                    
                    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
                    [result setObject:_storeFilePath forKey:@"filePath"];
                    if (imageRef != nil)
                        [result setObject:_thumbnailFilePath forKey:@"thumbnailPath"];
                    
                    if (image != nil)
                        [ActionStageInstance() dispatchResource:@"/as/media/previewReady" resource:[[NSDictionary alloc] initWithObjectsAndKeys:[[NSNumber alloc] initWithLongLong:_videoId], @"videoId", image, @"image", nil]];
                    
                    TGLog(@"Generated video preview");
                    
                    [ActionStageInstance() actionCompleted:self.path result:result];
                });
            }
        }
    }
    else
    {
        if (_worker1 == nil || _isReuploading) {
            return;
        }
        
        if (!_reportedProgress)
        {
            _reportedProgress = true;
            
            [self reportProgress:true];
        }
        
        std::vector<std::pair<int, int> > requestList;
        
        int activeDownloadingParts = 0;
        
        for (std::map<int, TGVideoPartData>::iterator it = _downloadingParts.begin(); it != _downloadingParts.end(); it++)
        {
            if (it->second.downloadedData == nil && !it->second.restart)
                activeDownloadingParts++;
        }
        
        int partSize = [self preferredPartSize];
        
        while (activeDownloadingParts < 4)
        {
            if (_explicitDownloadParts.empty())
            {
                int nextDownloadOffset = _downloadedFileSize;
                
                for (std::map<int, TGVideoPartData>::iterator it = _downloadingParts.begin(); it != _downloadingParts.end(); it++)
                {
                    if (it->first + it->second.partLength > nextDownloadOffset)
                        nextDownloadOffset = it->first + it->second.partLength;
                    
                    if (it->second.restart) {
                        it->second.restart = false;
                        
                        requestList.push_back(std::pair<int, int>(it->second.partOffset, it->second.partLength));
                    }
                }
                
                if (nextDownloadOffset >= _videoFileLength)
                    break;
                
                int partLength = MIN(partSize, _videoFileLength - _downloadedFileSize);
                
                requestList.push_back(std::pair<int, int>(nextDownloadOffset, partLength));
                TGVideoPartData videoPartData;
                videoPartData.partOffset = nextDownloadOffset;
                videoPartData.partLength = partLength;
                _downloadingParts[nextDownloadOffset] = videoPartData;
                activeDownloadingParts++;
            }
            else
            {
                std::vector<std::pair<int, int> >::iterator it = _explicitDownloadParts.begin();
                
                requestList.push_back(std::pair<int, int>(it->first, it->second));
                TGVideoPartData videoPartData;
                videoPartData.partOffset = it->first;
                videoPartData.partLength = it->second;
                _downloadingParts[it->first] = videoPartData;
                activeDownloadingParts++;
                
                _explicitDownloadParts.erase(it);
            }
        }
        
        for (std::vector<std::pair<int, int> >::iterator it = requestList.begin(); it != requestList.end(); it++)
        {
            MTRequest *request = [[MTRequest alloc] init];
            
            int offset = it->first;
            int length = it->second;
            
            int32_t updatedLimit = length;
            while (updatedLimit % 4096 != 0 || 1048576 % updatedLimit != 0) {
                updatedLimit++;
            }
            
            id location = nil;
            if (_encryptionKey != nil)
            {
                location = [[TLInputFileLocation$inputEncryptedFileLocation alloc] init];
                ((TLInputFileLocation$inputEncryptedFileLocation *)location).n_id = _videoId;
                ((TLInputFileLocation$inputEncryptedFileLocation *)location).access_hash = _accessHash;
            }
            else
            {
                location = [[TLInputFileLocation$inputDocumentFileLocation alloc] init];
                ((TLInputFileLocation$inputDocumentFileLocation *)location).n_id = _videoId;
                ((TLInputFileLocation$inputDocumentFileLocation *)location).access_hash = _accessHash;
            }
            
            if (_cdnFileData != nil) {
                TLRPCupload_getCdnFile$upload_getCdnFile *getFile = [[TLRPCupload_getCdnFile$upload_getCdnFile alloc] init];
                
                getFile.file_token = _cdnFileData.token;
                getFile.offset = offset;
                
                getFile.limit = updatedLimit;
                request.body = getFile;
            } else {
                TLRPCupload_getFile$upload_getFile *getFile = [[TLRPCupload_getFile$upload_getFile alloc] init];
                
                getFile.location = location;
                getFile.offset = offset;
                
                getFile.limit = updatedLimit;
                request.body = getFile;
            }
            
            __weak TGVideoDownloadActor *weakSelf = self;
            [request setCompleted:^(TLupload_File *result, __unused NSTimeInterval timestamp, id error)
            {
                [ActionStageInstance() dispatchOnStageQueue:^
                {
                    __strong TGVideoDownloadActor *strongSelf = weakSelf;
                    
                    if (error == nil) {
                        if ([result isKindOfClass:[TLupload_File$upload_file class]]) {
                            [strongSelf filePartDownloadSuccess:location offset:offset length:length data:((TLupload_File$upload_file *)result).bytes];
                        } else if ([result isKindOfClass:[TLupload_File$upload_fileCdnRedirect class]]) {
                            auto it = strongSelf->_downloadingParts.find(offset);
                            if (it != strongSelf->_downloadingParts.end()) {
                                it->second.restart = true;
                            }
                            
                            TLupload_File$upload_fileCdnRedirect *redirect = (TLupload_File$upload_fileCdnRedirect *)result;
                            [strongSelf switchToCdn:[[TGCdnFileData alloc] initWithCdnId:redirect.dc_id token:redirect.file_token encryptionKey:redirect.encryption_key encryptionIv:redirect.encryption_iv]];
                        } else if ([result isKindOfClass:[TLupload_CdnFile$upload_cdnFile class]]) {
                            TGCdnFileData *fileData = strongSelf->_cdnFileData;
                            NSData *bytes = ((TLupload_CdnFile$upload_cdnFile *)result).bytes;
                            NSMutableData *encryptionIv = [[NSMutableData alloc] initWithData:fileData.encryptionIv];
                            int32_t ivOffset = offset / 16;
                            ivOffset = NSSwapInt(ivOffset);
                            memcpy(((uint8_t *)encryptionIv.mutableBytes) + encryptionIv.length - 4, &ivOffset, 4);
                            NSData *data = MTAesCtrDecrypt(bytes, fileData.encryptionKey, encryptionIv);
                            [strongSelf filePartDownloadSuccess:location offset:offset length:length data:data];
                        } else if ([result isKindOfClass:[TLupload_CdnFile$upload_cdnFileReuploadNeeded class]]) {
                            auto it = strongSelf->_downloadingParts.find(offset);
                            if (it != strongSelf->_downloadingParts.end()) {
                                it->second.restart = true;
                            }
                            
                            TLupload_CdnFile$upload_cdnFileReuploadNeeded *reupload = (TLupload_CdnFile$upload_cdnFileReuploadNeeded *)result;
                            [strongSelf reuploadToCdn:reupload.request_token];
                        }
                    }
                    else
                        [strongSelf filePartDownloadFailed:location offset:offset length:length];
                }];
            }];
            
            [request setProgressUpdated:^(float progress, NSUInteger packetLength)
            {
                [ActionStageInstance() dispatchOnStageQueue:^
                {
                    __strong TGVideoDownloadActor *strongSelf = weakSelf;
                    
                    [strongSelf filePartDownloadProgress:location offset:offset length:length packetLength:(int)packetLength progress:progress];
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
            
            _downloadingParts[it->first].token = token;
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
    if (maxOffset < _videoFileLength) {
        if (_partHashesDisposable == nil) {
            _partHashesDisposable = [[SMetaDisposable alloc] init];
        }
        __weak TGVideoDownloadActor *weakSelf = self;
        
        [_partHashesDisposable setDisposable:[[[[TGTelegramNetworking instance] downloadWorkerForDatacenterId:_datacenterId type:TGNetworkMediaTypeTagGeneric] mapToSignal:^SSignal *(TGNetworkWorkerGuard *worker) {
            TLRPCupload_getCdnFileHashes$upload_getCdnFileHashes *getCdnFileHashes = [[TLRPCupload_getCdnFileHashes$upload_getCdnFileHashes alloc] init];
            getCdnFileHashes.file_token = fileData.token;
            getCdnFileHashes.offset = maxOffset;
            return [[TGTelegramNetworking instance] requestSignal:getCdnFileHashes worker:worker];
        }] startWithNext:^(NSArray *hashes) {
            [ActionStageInstance() dispatchOnStageQueue:^{
                __strong TGVideoDownloadActor *strongSelf = weakSelf;
                if (strongSelf != nil) {
                    for (TLCdnFileHash$cdnFileHash *nHash in hashes) {
                        dict[@(nHash.offset)] = nHash.n_hash;
                    }
                    
                    int32_t maxOffset = 0;
                    for (NSNumber *nOffset in dict.keyEnumerator) {
                        maxOffset = MAX(maxOffset, [nOffset intValue] + 128 * 1024);
                    }
                    
                    if (maxOffset < strongSelf->_videoFileLength) {
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
    
    __weak TGVideoDownloadActor *weakSelf = self;
    _worker1Token = [[TGTelegramNetworking instance] requestDownloadWorkerForDatacenterId:fileData.cdnId type:TGNetworkMediaTypeTagVideo isCdn:true completion:^(TGNetworkWorkerGuard *worker)
    {
        __strong TGVideoDownloadActor *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            [strongSelf downloadFilePartsWithWorker:worker];
        }
    }];
    
    _worker2Token = [[TGTelegramNetworking instance] requestDownloadWorkerForDatacenterId:fileData.cdnId type:TGNetworkMediaTypeTagVideo isCdn:true completion:^(TGNetworkWorkerGuard *worker)
    {
        __strong TGVideoDownloadActor *strongSelf = weakSelf;
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
    __weak TGVideoDownloadActor *weakSelf = self;
    [_reuploadDisposable setDisposable:[[[[TGTelegramNetworking instance] downloadWorkerForDatacenterId:_datacenterId type:TGNetworkMediaTypeTagGeneric] mapToSignal:^SSignal *(TGNetworkWorkerGuard *worker) {
        TLRPCupload_reuploadCdnFile$upload_reuploadCdnFile *reupload = [[TLRPCupload_reuploadCdnFile$upload_reuploadCdnFile alloc] init];
        reupload.file_token = fileToken;
        reupload.request_token = requestToken;
        return [[TGTelegramNetworking instance] requestSignal:reupload worker:worker];
    }] startWithNext:^(__unused id next) {
        [ActionStageInstance() dispatchOnStageQueue:^{
            __strong TGVideoDownloadActor *strongSelf = weakSelf;
            if (strongSelf != nil) {
                strongSelf->_isReuploading = false;
                [strongSelf downloadFileParts];
            }
        }];
    } error:nil completed:nil]];
}

- (void)videoPartDownloadProgress:(int)offset packetLength:(int)packetLength progress:(float)progress
{
    std::map<int, TGVideoPartData>::iterator partIt = _downloadingParts.find(offset);
    if (partIt != _downloadingParts.end())
    {
        partIt->second.downloadedLength = (int)(progress * packetLength);
        //TGLog(@"Part %d: %d / %d", offset, progress * packetLength, packetLength);
    }
    
    [self reportProgress:false];
}

- (void)filePartDownloadProgress:(TLInputFileLocation *)__unused location offset:(int)offset length:(int)__unused length packetLength:(int)packetLength progress:(float)progress
{
    [self videoPartDownloadProgress:offset packetLength:packetLength progress:progress];
}

- (void)reportProgress:(bool)force
{
    int readyFileSize = _downloadedFileSize;
    
    for (std::map<int, TGVideoPartData>::iterator it = _downloadingParts.begin(); it != _downloadingParts.end(); it++)
    {
        readyFileSize += it->second.downloadedLength;
    }
    
    if (force || (_lastReportedProgress < readyFileSize && (_lastReportedProgress / 16 * 1024 != readyFileSize / 16 * 1024 || readyFileSize == _videoFileLength)))
    {   
        _lastReportedProgress = readyFileSize;
        
        _progress = MIN(1.0f, MAX(0.001f, ((float)readyFileSize) / ((float)_videoFileLength)));
        
        //TGLog(@"Progress: %f (%d / %d)", _progress, readyFileSize, _videoFileLength);
        
        /*for (std::map<int, TGVideoPartData>::iterator it = _downloadingParts.begin(); it != _downloadingParts.end(); it++)
        {
            TGLog(@"    part %d: %d / %d", it->first, it->second.downloadedLength, it->second.partLength);
        }*/
        
        [ActionStageInstance() dispatchMessageToWatchers:self.path messageType:@"progress" message:[[NSNumber alloc] initWithFloat:_progress]];
    }
}

- (void)filePartDownloadSuccess:(TLInputFileLocation *)__unused location offset:(int)offset length:(int)length data:(NSData *)data
{
    [self videoPartDownloadSuccess:offset length:length data:data];
}

- (void)videoPartDownloadSuccess:(int)offset length:(int)length data:(NSData *)data
{
    if (self.cancelled)
        return;
    
    std::map<int, TGVideoPartData>::iterator partIt = _downloadingParts.find(offset);
    if (partIt != _downloadingParts.end())
    {
        partIt->second.token = nil;
        partIt->second.downloadedLength = length;
        
        [self recordTimeSample:length startTime:partIt->second.startTime];
    }
    
    int fileSize = _downloadedFileSize;
    
    if (partIt != _downloadingParts.end())
    {
        partIt->second.downloadedData = data;
        
        int nextWriteOffset = fileSize;
        
        //TGLog(@"Looking for %d to commit", nextWriteOffset);
        
        std::vector<int> sortedDownloadingParts;
        for (std::map<int, TGVideoPartData>::iterator it = _downloadingParts.begin(); it != _downloadingParts.end(); it++)
        {
            sortedDownloadingParts.push_back(it->first);
        }
        
        std::sort(sortedDownloadingParts.begin(), sortedDownloadingParts.end());
        
        std::vector<std::pair<int, int> > dataGapsToFill;
        
        while (true)
        {
            bool hadCommit = false;
            
            for (std::vector<int>::iterator it = sortedDownloadingParts.begin(); it != sortedDownloadingParts.end(); it++)
            {
                if (*it == nextWriteOffset)
                {
                    std::map<int, TGVideoPartData>::iterator listPartIt = _downloadingParts.find(*it);
                    if (listPartIt->second.downloadedData == nil)
                        break;
                    
                    //TGLog(@"Commit %d: %d bytes", nextWriteOffset, listPartIt->second.downloadedData.length);
                    
                    hadCommit = true;
                    
                    NSData *dataToWrite = listPartIt->second.downloadedData;
                    
                    if (_encryptionKey != nil && _runningEncryptionIv != nil)
                    {
                        NSMutableData *decryptedData = [[NSMutableData alloc] initWithData:dataToWrite];
                        MTAesDecryptInplaceAndModifyIv(decryptedData, _encryptionKey, _runningEncryptionIv);
                        dataToWrite = decryptedData;
                        
                        if (_finalSize != 0 && _finalSize >= _downloadedFileSize && _downloadedFileSize + (int)decryptedData.length > _finalSize)
                        {
                            [decryptedData setLength:_finalSize - _downloadedFileSize];
                        }
                    }
                    
                    if (_cdnFilePartHashes != nil) {
                        int32_t basePartOffset = *it;
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
                                localHash = MTSha256([[NSData alloc] initWithBytesNoCopy:(uint8_t *)dataToWrite.bytes + localOffset length:(int32_t)dataToWrite.length - localOffset freeWhenDone:false]);
                            } else {
                                localHash = MTSha256([[NSData alloc] initWithBytesNoCopy:(uint8_t *)dataToWrite.bytes + localOffset length:128 * 1024 freeWhenDone:false]);
                            }
                            if (![localHash isEqual:hashData]) {
                                TGLog(@"File CDN part hash mismatch at %d", partOffset);
                                [ActionStageInstance() actionFailed:self.path reason:-1];
                                return;
                            }
                        }
                    }
                    
                    [_fileStream writeData:dataToWrite];
                    
                    _downloadedFileSize += listPartIt->second.downloadedData.length;
                    nextWriteOffset += listPartIt->second.downloadedData.length;
                    
                    if ((int)listPartIt->second.downloadedData.length < listPartIt->second.partLength && _downloadedFileSize + (int)listPartIt->second.downloadedData.length < _videoFileLength)
                    {
                        int dataGapLength = listPartIt->second.partLength - (int)listPartIt->second.downloadedData.length;
                        TGLog(@"Data gap found: %d bytes", dataGapLength);
                        
                        _explicitDownloadParts.push_back(std::pair<int, int>(nextWriteOffset, dataGapLength));
                    }
                    
                    _downloadingParts.erase(*it);
                }
            }
            
            if (!hadCommit)
                break;
        }
        
        //[self printParts];
        [self reportProgress:false];
        
        if (!self.cancelled)
            [self downloadFileParts];
    }
    else
    {
        [ActionStageInstance() actionFailed:self.path reason:-1];
    }
}

- (void)filePartDownloadFailed:(TLInputFileLocation *)__unused location offset:(int)offset length:(int)length
{
    [self videoPartDownloadFailed:offset length:length];
}

- (void)videoPartDownloadFailed:(int)offset length:(int)__unused length
{
    std::map<int, TGVideoPartData>::iterator it = _downloadingParts.find(offset);
    if (it != _downloadingParts.end())
        _downloadingParts.erase(it);
    
    self.cancelled = true;
    
    [self cancelRequests];
    [ActionStageInstance() actionFailed:self.path reason:-1];
}

- (void)cancelRequests
{
    for (std::map<int, TGVideoPartData>::iterator it = _downloadingParts.begin(); it != _downloadingParts.end(); it++)
    {
        if (it->second.token != nil)
        {
            [TGTelegraphInstance cancelRequestByToken:it->second.token];
            [_worker1.strongWorker cancelRequestById:it->second.token];
            [_worker2.strongWorker cancelRequestById:it->second.token];
        }
    }
    _downloadingParts.clear();
    
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
}

- (void)cancel
{
    [ActionStageInstance() removeWatcher:self];
    
    [self cancelRequests];
    
    [super cancel];
}

#pragma mark -

- (void)watcherJoined:(ASHandle *)watcherHandle options:(NSDictionary *)options waitingInActorQueue:(bool)waitingInActorQueue
{
    [watcherHandle receiveActorMessage:self.path messageType:@"progress" message:[[NSNumber alloc] initWithFloat:_progress]];
    
    [super watcherJoined:watcherHandle options:options waitingInActorQueue:waitingInActorQueue];
}

- (void)actorCompleted:(int)status path:(NSString *)path result:(id)result
{
    if ([path hasPrefix:@"/as/media/video/"])
    {
        if (status == ASStatusSuccess)
            [ActionStageInstance() actionCompleted:self.path result:result];
        else
            [ActionStageInstance() actionFailed:self.path reason:status];
    }
}

- (void)actorMessageReceived:(NSString *)path messageType:(NSString *)messageType message:(id)message
{
    if ([path hasPrefix:@"/as/media/video/"])
    {
        if ([messageType isEqualToString:@"progress"])
        {
            _progress = [message floatValue];
            [ActionStageInstance() dispatchMessageToWatchers:self.path messageType:@"progress" message:[[NSNumber alloc] initWithFloat:_progress]];
        }
    }
}

@end
