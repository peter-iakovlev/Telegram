#import "TGSharedFileSignals.h"

#import "TGImageInfo+Telegraph.h"
#import "TGDocumentMediaAttachment.h"

#import "TGMemoryImageCache.h"
#import "TGImageUtils.h"
#import "TGImageBlur.h"

#import "TGListThumbnailSignals.h"
#import "TGSharedMediaSignals.h"

#import "TGAppDelegate.h"

#import <AVFoundation/AVFoundation.h>

#import "ActionStage.h"

#import "TGPreparedLocalDocumentMessage.h"

#import "TGVideoMediaAttachment.h"

@interface TGDownloadDocumentHelper : NSObject <ASWatcher> {
    void (^_completion)(id);
    void (^_error)();
    void (^_progress)(float);
    bool _path;
    TGDocumentMediaAttachment *_document;
}

@property (nonatomic, strong) ASHandle *actionHandle;

@end

@implementation TGDownloadDocumentHelper

- (instancetype)initWithDocument:(TGDocumentMediaAttachment *)document priority:(bool)priority path:(bool)path completion:(void (^)(id))completion error:(void (^)())error progress:(void (^)(float))progress {
    self = [super init];
    if (self != nil) {
        _completion = [completion copy];
        _error = [error copy];
        _progress = [progress copy];
        _path = path;
        _document = document;
        
        _actionHandle = [[ASHandle alloc] initWithDelegate:self];
        
        if (document.documentId != 0) {
            NSString *filePath = [[TGPreparedLocalDocumentMessage localDocumentDirectoryForDocumentId:document.documentId version:document.version] stringByAppendingPathComponent:[document safeFileName]];
            bool download = false;
            if (path) {
                if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
                    completion(filePath);
                } else {
                    download = true;
                }
            } else {
                NSData *data = [NSData dataWithContentsOfFile:filePath options:NSDataReadingMappedIfSafe error:nil];
                if (data != nil) {
                    completion(data);
                } else {
                    download = true;
                }
            }
            
            if (download) {
                NSString *path = [NSString stringWithFormat:@"/tg/media/document/(%d:%" PRId64 ":%@)", document.datacenterId, document.documentId, document.documentUri.length != 0 ? document.documentUri : @""];
                [ActionStageInstance() requestActor:path options:@{@"documentAttachment": document} flags:priority ? TGActorRequestChangePriority : 0 watcher:self];
            }
        } else {
            error();
        }
    }
    return self;
}

- (void)dealloc {
    [_actionHandle reset];
    [ActionStageInstance() removeWatcher:self];
}

- (void)actorMessageReceived:(NSString *)__unused path messageType:(NSString *)messageType message:(id)message {
    if ([messageType isEqualToString:@"progress"]) {
        _progress([message floatValue]);
    }
}

- (void)actorCompleted:(int)status path:(NSString *)__unused path result:(id)__unused result {
    if (status == ASStatusSuccess) {
        NSString *filePath = [[TGPreparedLocalDocumentMessage localDocumentDirectoryForDocumentId:_document.documentId version:_document.version] stringByAppendingPathComponent:_document.safeFileName];
        if (_path) {
            if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
                _completion(filePath);
            } else {
                _error();
            }
        } else {
            NSData *data = [NSData dataWithContentsOfFile:filePath options:NSDataReadingMappedIfSafe error:nil];
            if (data != nil) {
                _completion(data);
            } else {
                _error();
            }
        }
    }
}

@end

@interface TGDownloadVideoHelper : NSObject <ASWatcher> {
    void (^_completion)(id);
    void (^_error)();
    void (^_progress)(float);
    bool _path;
    TGVideoMediaAttachment *_video;
}

@property (nonatomic, strong) ASHandle *actionHandle;

@end

@implementation TGDownloadVideoHelper

- (NSString *)filePathForRemoteVideoId:(int64_t)remoteVideoId {
    NSString *documentsDirectory = [TGAppDelegate documentsPath];
    NSString *videosDirectory = [documentsDirectory stringByAppendingPathComponent:@"video"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:videosDirectory])
        [[NSFileManager defaultManager] createDirectoryAtPath:videosDirectory withIntermediateDirectories:true attributes:nil error:nil];
    
    return [videosDirectory stringByAppendingPathComponent:[[NSString alloc] initWithFormat:@"remote%llx.mov", remoteVideoId]];
}

- (instancetype)initWithVideo:(TGVideoMediaAttachment *)video priority:(bool)priority path:(bool)path completion:(void (^)(id))completion error:(void (^)())error progress:(void (^)(float))progress {
    self = [super init];
    if (self != nil) {
        _completion = [completion copy];
        _error = [error copy];
        _progress = [progress copy];
        _path = path;
        _video = video;
        
        _actionHandle = [[ASHandle alloc] initWithDelegate:self];
        
        if (video.videoId != 0) {
            
            NSString *filePath = [self filePathForRemoteVideoId:video.videoId];
            bool download = false;
            if (path) {
                if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
                    completion(filePath);
                } else {
                    download = true;
                }
            } else {
                NSData *data = [NSData dataWithContentsOfFile:filePath options:NSDataReadingMappedIfSafe error:nil];
                if (data != nil) {
                    completion(data);
                } else {
                    download = true;
                }
            }
            
            if (download) {
                NSString *url = [video.videoInfo urlWithQuality:1 actualQuality:NULL actualSize:NULL];
                
                NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
                dict[@"videoAttachment"] = video;
                
                [ActionStageInstance() requestActor:[[NSString alloc] initWithFormat:@"/as/media/video/(%@)", url] options:dict watcher:self];
            }
        } else {
            error();
        }
    }
    return self;
}

- (void)dealloc {
    [_actionHandle reset];
    [ActionStageInstance() removeWatcher:self];
}

- (void)actorMessageReceived:(NSString *)__unused path messageType:(NSString *)messageType message:(id)message {
    if ([messageType isEqualToString:@"progress"]) {
        _progress([message floatValue]);
    }
}

- (void)actorCompleted:(int)status path:(NSString *)__unused path result:(id)__unused result {
    if (status == ASStatusSuccess) {
        NSString *filePath = [self filePathForRemoteVideoId:_video.videoId];
        if (_path) {
            if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
                _completion(filePath);
            } else {
                _error();
            }
        } else {
            NSData *data = [NSData dataWithContentsOfFile:filePath options:NSDataReadingMappedIfSafe error:nil];
            if (data != nil) {
                _completion(data);
            } else {
                _error();
            }
        }
    }
}

@end

@implementation TGSharedFileSignals

+ (NSString *)pathForFileDirectory:(TGDocumentMediaAttachment *)documentAttachment
{
    static NSString *filesDirectory = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        filesDirectory = [[TGAppDelegate documentsPath] stringByAppendingPathComponent:@"files"];
    });
    
    NSString *fileDirectoryName = nil;
    if (documentAttachment.documentId != 0)
        fileDirectoryName = [[NSString alloc] initWithFormat:@"%" PRIx64 "", documentAttachment.documentId];
    else
        fileDirectoryName = [[NSString alloc] initWithFormat:@"local%" PRIx64 "", documentAttachment.localDocumentId];
    return [filesDirectory stringByAppendingPathComponent:fileDirectoryName];
}

+ (UIImage *)_localCachedImageForFileThumbnail:(TGDocumentMediaAttachment *)documentAttachment ofSize:(CGSize)size renderSize:(CGSize)renderSize lowQuality:(bool)lowQuality
{
    NSString *photoDirectoryPath = [self pathForFileDirectory:documentAttachment];
    NSString *cachedSizePath = [photoDirectoryPath stringByAppendingPathComponent:[[NSString alloc] initWithFormat:@"thumbnail-%dx%d-%dx%d%@.jpg", (int)size.width, (int)size.height, (int)renderSize.width, (int)renderSize.height, lowQuality ? @"-low" : @""]];
    UIImage *cachedSizeImage = [[UIImage alloc] initWithContentsOfFile:cachedSizePath];
    return cachedSizeImage;
}

+ (SSignal *)localCachedImageForFileThumbnail:(TGDocumentMediaAttachment *)documentAttachment ofSize:(CGSize)size renderSize:(CGSize)renderSize lowQuality:(bool)lowQuality
{
    return [[SSignal alloc] initWithGenerator:^id<SDisposable> (SSubscriber *subscriber)
    {
        UIImage *cachedSizeImage = [self _localCachedImageForFileThumbnail:documentAttachment ofSize:size renderSize:renderSize lowQuality:lowQuality];
        if (cachedSizeImage != nil)
        {
            [subscriber putNext:cachedSizeImage];
            [subscriber putCompletion];
        }
        else
            [subscriber putError:nil];
        
        return nil;
    }];
}

+ (SSignal *)localImageForLowQualityFileThumbnail:(TGDocumentMediaAttachment *)imageAttachment
{
    return [[SSignal alloc] initWithGenerator:^id<SDisposable> (SSubscriber *subscriber)
    {
        NSString *fileDirectoryPath = [self pathForFileDirectory:imageAttachment];
        
        NSString *genericThumbnailPath = [fileDirectoryPath stringByAppendingPathComponent:@"thumbnail"];
        UIImage *genericThumbnailImage = [[UIImage alloc] initWithContentsOfFile:genericThumbnailPath];
        if (genericThumbnailImage != nil)
        {
            [subscriber putNext:genericThumbnailImage];
            [subscriber putCompletion];
        }
        else
            [subscriber putError:nil];
        
        return nil;
    }];
}

+ (SSignal *)localImageForFullSizeFile:(TGDocumentMediaAttachment *)documentAttachment
{
    return [[SSignal alloc] initWithGenerator:^id<SDisposable> (SSubscriber *subscriber)
    {
        NSString *fileDirectoryPath = [self pathForFileDirectory:documentAttachment];
        
        NSString *fullImagePath = [fileDirectoryPath stringByAppendingPathComponent:[documentAttachment safeFileName]];
        UIImage *fullImage = [[UIImage alloc] initWithContentsOfFile:fullImagePath];
        if (fullImage != nil && fullImage.size.width * fullImage.size.height < 4096 * 4096)
        {
            [subscriber putNext:fullImage];
            [subscriber putCompletion];
        }
        else {
            if ([documentAttachment.mimeType isEqualToString:@"video/mp4"]) {
                NSString *videoPath = [fileDirectoryPath stringByAppendingPathComponent:documentAttachment.safeFileName];
                if ([videoPath pathExtension].length == 0) {
                    [[NSFileManager defaultManager] createSymbolicLinkAtPath:[videoPath stringByAppendingPathExtension:@"mov"] withDestinationPath:[videoPath lastPathComponent] error:nil];
                    videoPath = [videoPath stringByAppendingPathExtension:@"mov"];
                }
                
                AVAsset *asset = [AVAsset assetWithURL:[NSURL fileURLWithPath:videoPath]];
                
                AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
                imageGenerator.maximumSize = CGSizeMake(800, 800);
                imageGenerator.appliesPreferredTrackTransform = true;
                NSError *imageError = nil;
                CGImageRef imageRef = [imageGenerator copyCGImageAtTime:CMTimeMake(0, asset.duration.timescale) actualTime:NULL error:&imageError];
                UIImage *image = [[UIImage alloc] initWithCGImage:imageRef];
                if (imageRef != NULL) {
                    CGImageRelease(imageRef);
                }
                
                if (image != nil) {
                    [subscriber putNext:image];
                    [subscriber putCompletion];
                    return nil;
                }
            }
            
            [subscriber putError:nil];
        }
        
        return nil;
    }];
}

+ (SSignal *)squareFileThumbnail:(TGDocumentMediaAttachment *)documentAttachment ofSize:(CGSize)size threadPool:(SThreadPool *)threadPool memoryCache:(TGMemoryImageCache *)memoryCache pixelProcessingBlock:(void (^)(void *, int, int, int))pixelProcessingBlock
{
    CGSize imageSize = CGSizeZero;
    NSString *thumbnailUrl = [documentAttachment.thumbnailInfo imageUrlForLargestSize:&imageSize];
    
    for (id attribute in documentAttachment.attributes)
    {
        if ([attribute isKindOfClass:[TGDocumentAttributeImageSize class]])
        {
            imageSize = ((TGDocumentAttributeImageSize *)attribute).size;
            break;
        }
        else if ([attribute isKindOfClass:[TGDocumentAttributeVideo class]]) {
            imageSize = ((TGDocumentAttributeVideo *)attribute).size;
            break;
        }
    }
    CGSize renderSize = TGScaleToFill(imageSize, size);
    
    NSString *photoDirectoryPath = [self pathForFileDirectory:documentAttachment];
    NSString *cachedSizeLowPath = [photoDirectoryPath stringByAppendingPathComponent:[[NSString alloc] initWithFormat:@"thumbnail-%dx%d-%dx%d%@.jpg", (int)size.width, (int)size.height, (int)renderSize.width, (int)renderSize.height, @"-low"]];
    NSString *cachedSizePath = [photoDirectoryPath stringByAppendingPathComponent:[[NSString alloc] initWithFormat:@"thumbnail-%dx%d-%dx%d%@.jpg", (int)size.width, (int)size.height, (int)renderSize.width, (int)renderSize.height, @""]];
    
    __block bool lowQuality = false;
    __block bool alreadyBlurred = false;
    __block bool cacheResult = false;
    
    UIImage *cachedImage = [memoryCache imageForKey:cachedSizePath attributes:NULL];
    if (cachedImage != nil)
        return [SSignal single:cachedImage];
    
    cachedImage = [memoryCache imageForKey:cachedSizeLowPath attributes:NULL];
    if (cachedImage != nil)
    {
        SSignal *fetchFullSizeImageInBackground = [[[self localImageForFullSizeFile:documentAttachment]
                                                    catch:^SSignal *(__unused id error)
        {
            return [SSignal complete];
        }] startOnThreadPool:threadPool];

        return [[SSignal single:cachedImage] then:[[fetchFullSizeImageInBackground mapToSignal:^SSignal *(UIImage *image)
        {
            cacheResult = true;
            CGSize optimizedSize = size;
            return [[TGListThumbnailSignals signalForListThumbnail:optimizedSize image:image blurImage:false pixelProcessingBlock:pixelProcessingBlock calculateAverageColor:false] filter:^bool (id next)
            {
                return [next isKindOfClass:[UIImage class]];
            }];
        }] map:^UIImage *(UIImage *image)
        {
            if (cacheResult) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                {
                    NSString *fileDirectoryPath = [self pathForFileDirectory:documentAttachment];
                    NSString *cachedSizePath = [fileDirectoryPath stringByAppendingPathComponent:[[NSString alloc] initWithFormat:@"thumbnail-%dx%d-%dx%d%@.jpg", (int)size.width, (int)size.height, (int)renderSize.width, (int)renderSize.height, lowQuality ? @"-low" : @""]];
                    [UIImageJPEGRepresentation(image, 0.8f) writeToFile:cachedSizePath atomically:true];
                });
            }
            
            [memoryCache setImage:image forKey:cachedSizePath attributes:nil];
            return image;
        }]];
    }
    
    bool averageColorCalculated = false;
    uint32_t averageColor = 0;
    averageColorCalculated = [memoryCache averageColorForKey:cachedSizePath color:&averageColor];
    
    SSignal *signal = [[[[[[[[self localCachedImageForFileThumbnail:documentAttachment ofSize:size renderSize:renderSize lowQuality:false] catch:^SSignal *(__unused id error)
    {
        cacheResult = true;
        return [self localImageForFullSizeFile:documentAttachment];
    }] catch:^SSignal *(__unused id error)
    {
        lowQuality = true;
        return [[self localCachedImageForFileThumbnail:documentAttachment ofSize:size renderSize:renderSize lowQuality:true] map:^id (UIImage *image)
        {
            alreadyBlurred = true;
            lowQuality = true;
            cacheResult = false;
            return image;
        }];
    }] catch:^SSignal *(__unused id error)
    {
        return [self localImageForLowQualityFileThumbnail:documentAttachment];
    }] catch:^SSignal *(__unused id error)
    {
        NSInteger datacenterId = 0;
        TLInputFileLocation *location = [TGSharedMediaSignals inputFileLocationForImageUrl:thumbnailUrl datacenterId:&datacenterId];
        if (location == nil)
            return [SSignal fail:nil];
        else
        {
            return [[TGSharedMediaSignals memoizedDataSignalForRemoteLocation:location datacenterId:datacenterId reportProgress:false mediaTypeTag:TGNetworkMediaTypeTagImage] mapToSignal:^SSignal *(NSData *data)
            {
                NSString *photoDirectoryPath = [self pathForFileDirectory:documentAttachment];
                NSString *genericThumbnailPath = [photoDirectoryPath stringByAppendingPathComponent:@"thumbnail"];
                [[NSFileManager defaultManager] createDirectoryAtPath:photoDirectoryPath withIntermediateDirectories:true attributes:nil error:nil];
                [data writeToFile:genericThumbnailPath atomically:true];

                UIImage *image = [[UIImage alloc] initWithData:data];
                if (image != nil)
                    return [SSignal single:image];
                else
                    return [SSignal fail:nil];
            }];
        }
    }] mapToSignal:^SSignal *(UIImage *image)
    {
        CGSize optimizedSize = size;
        if (lowQuality && pixelProcessingBlock == nil)
            optimizedSize = TGFitSize(size, CGSizeMake(25.0f, 25.0f));
        return [[TGListThumbnailSignals signalForListThumbnail:optimizedSize image:image blurImage:lowQuality && !alreadyBlurred pixelProcessingBlock:pixelProcessingBlock calculateAverageColor:!averageColorCalculated] filter:^bool(id next)
        {
            if ([next isKindOfClass:[UIImage class]])
                return true;
            else
                [memoryCache setAverageColor:(uint32_t)[next unsignedIntValue] forKey:cachedSizePath];
            
            return false;
        }];
    }] map:^id (UIImage *image)
    {
        if (cacheResult)
        {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
            {
                NSString *fileDirectoryPath = [self pathForFileDirectory:documentAttachment];
                NSString *cachedSizePath = [fileDirectoryPath stringByAppendingPathComponent:[[NSString alloc] initWithFormat:@"thumbnail-%dx%d-%dx%d%@.jpg", (int)size.width, (int)size.height, (int)renderSize.width, (int)renderSize.height, lowQuality ? @"-low" : @""]];
                [UIImageJPEGRepresentation(image, 0.8f) writeToFile:cachedSizePath atomically:true];
            });
        }
        [memoryCache setImage:image forKey:lowQuality ? cachedSizeLowPath : cachedSizePath attributes:nil];
        return image;
    }] startOnThreadPool:threadPool];
    
    if (averageColorCalculated)
        return [[SSignal single:TGAverageColorImage(UIColorRGB(averageColor))] then:signal];
    
    return signal;
}

+ (SSignal *)documentData:(TGDocumentMediaAttachment *)document priority:(bool)priority {
    return [SSignal defer:^SSignal *{
        SPipe *progressPipe = [[SPipe alloc] init];
        
        return [SSignal single:@[[[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber) {
            TGDownloadDocumentHelper *helper = [[TGDownloadDocumentHelper alloc] initWithDocument:document priority:priority path:false completion:^(NSData *data) {
                [subscriber putNext:data];
                [subscriber putCompletion];
            } error:^{
                [subscriber putError:nil];
            } progress:^(float progress) {
                progressPipe.sink(@(progress));
            }];
            
            return [[SBlockDisposable alloc] initWithBlock:^{
                [helper description]; // keep reference
            }];
        }], progressPipe.signalProducer()]];
    }];
}

+ (SSignal *)videoData:(TGVideoMediaAttachment *)video priority:(bool)priority {
    return [SSignal defer:^SSignal *{
        SPipe *progressPipe = [[SPipe alloc] init];
        
        return [SSignal single:@[[[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber) {
            TGDownloadVideoHelper *helper = [[TGDownloadVideoHelper alloc] initWithVideo:video priority:priority path:false completion:^(NSData *data) {
                [subscriber putNext:data];
                [subscriber putCompletion];
            } error:^{
                [subscriber putError:nil];
            } progress:^(float progress) {
                progressPipe.sink(@(progress));
            }];
            
            return [[SBlockDisposable alloc] initWithBlock:^{
                [helper description]; // keep reference
            }];
        }], progressPipe.signalProducer()]];
    }];
}

+ (SSignal *)documentPath:(TGDocumentMediaAttachment *)document priority:(bool)priority {
    return [SSignal defer:^SSignal *{
        SPipe *progressPipe = [[SPipe alloc] init];
        
        return [SSignal single:@[[[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber) {
            TGDownloadDocumentHelper *helper = [[TGDownloadDocumentHelper alloc] initWithDocument:document priority:priority path:true completion:^(NSString *path) {
                [subscriber putNext:path];
                [subscriber putCompletion];
            } error:^{
                [subscriber putError:nil];
            } progress:^(float progress) {
                progressPipe.sink(@(progress));
            }];
            
            return [[SBlockDisposable alloc] initWithBlock:^{
                [helper description]; // keep reference
            }];
        }], progressPipe.signalProducer()]];
    }];
}

@end
