#import "TGImageDownloadActor.h"

#import "TGAppDelegate.h"

#import "ActionStage.h"
#import "SGraphObjectNode.h"
#import "TGRemoteImageView.h"

#import "TGImageUtils.h"
#import "TGStringUtils.h"

#import "TGTelegraph.h"
#import "TGTelegraphProtocols.h"

#import "TGFileDownloadActor.h"

#import "TGGenericModernConversationCompanion.h"

#import "TGDownloadManager.h"

#import "TGDatabase.h"

#import "TGInterfaceAssets.h"

#import "TGImageManager.h"

#import "TGImagePickerController.h"

#import "TGPeerIdAdapter.h"

#import "TGTelegramNetworking.h"

static NSMutableDictionary *urlRewrites()
{
    static NSMutableDictionary *dict = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        dict = [[NSMutableDictionary alloc] init];
    });
    return dict;
}

static NSMutableDictionary *serverAssetData()
{
    static NSMutableDictionary *dict = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        dict = [[NSMutableDictionary alloc] init];
    });
    return dict;
}

typedef void (^TGRemoteImageDownloadCompletionBlock)(NSData *data);

@interface TGImageDownloadActor ()
{
    bool _updateMediaAccessTimeOnRelease;
    int32_t _messageId;
    int64_t _imageId;
}

@property (nonatomic, copy) TGRemoteImageDownloadCompletionBlock downloadCompletionBlock;

@property (nonatomic) float progress;
@property (nonatomic) bool requestedActors;

@end

@implementation TGImageDownloadActor

@synthesize actionHandle = _actionHandle;

@synthesize downloadCompletionBlock = _downloadCompletionBlock;

@synthesize progress = _progress;
@synthesize requestedActors = _requestedActors;

+ (NSString *)genericPath
{
    return @"/img/@";
}

+ (void)addUrlRewrite:(NSString *)currentUrl newUrl:(NSString *)newUrl
{
    [urlRewrites() setObject:newUrl forKey:currentUrl];
}

+ (NSString *)possiblyRewrittenUrl:(NSString *)url
{
    NSString *newUrl = [urlRewrites() objectForKey:url];
    if (newUrl != nil)
        return newUrl;
    return url;
}

+ (NSDictionary *)serverMediaDataForAssetUrl:(NSString *)assetUrl
{
    if (assetUrl.length == 0)
        return nil;
    
    id object = [serverAssetData() objectForKey:assetUrl];
    if ([object isKindOfClass:[NSNull class]])
        return nil;
    
    if ([object isKindOfClass:[NSDictionary class]])
        return object;
    
    TGMediaAttachment *attachment = [TGDatabaseInstance() loadServerAssetData:assetUrl];
    if (attachment == nil)
    {
        [serverAssetData() setObject:[NSNull null] forKey:assetUrl];
        return nil;
    }
    
    NSDictionary *dict = nil;
    
    if (attachment.type == TGImageMediaAttachmentType)
    {
        TGImageMediaAttachment *imageAttachment = (TGImageMediaAttachment *)attachment;
        imageAttachment.caption = nil;
        dict = [[NSDictionary alloc] initWithObjectsAndKeys:[[NSNumber alloc] initWithLongLong:imageAttachment.imageId], @"imageId", [[NSNumber alloc] initWithLongLong:imageAttachment.accessHash], @"accessHash", imageAttachment, @"imageAttachment", nil];
        [serverAssetData() setObject:dict forKey:assetUrl];
        return dict;
    }
    else if (attachment.type == TGVideoMediaAttachmentType)
    {
        TGVideoMediaAttachment *videoAttachment = (TGVideoMediaAttachment *)attachment;
        videoAttachment.caption = nil;
        dict = [[NSDictionary alloc] initWithObjectsAndKeys:videoAttachment, @"videoAttachment", nil];
        [serverAssetData() setObject:dict forKey:assetUrl];
        return dict;
    }
    
    return nil;
}

+ (void)addServerMediaSataForAssetUrl:(NSString *)assetUrl attachment:(TGMediaAttachment *)attachment
{
    if (assetUrl.length == 0 || attachment == nil)
        return;
    
    [TGDatabaseInstance() storeServerAssetData:assetUrl attachment:attachment];
    
    if (attachment.type == TGImageMediaAttachmentType)
    {
        TGImageMediaAttachment *imageAttachment = (TGImageMediaAttachment *)attachment;
        NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:[[NSNumber alloc] initWithLongLong:imageAttachment.imageId], @"imageId", [[NSNumber alloc] initWithLongLong:imageAttachment.accessHash], @"accessHash", imageAttachment, @"imageAttachment", nil];
        [serverAssetData() setObject:dict forKey:assetUrl];
    }
    else if (attachment.type == TGVideoMediaAttachmentType)
    {
        TGVideoMediaAttachment *videoAttachment = (TGVideoMediaAttachment *)attachment;
        NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:videoAttachment, @"videoAttachment", nil];
        [serverAssetData() setObject:dict forKey:assetUrl];
    }
}

+ (NSOperationQueue *)operationQueue
{
    static NSOperationQueue *queue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        queue = [[NSOperationQueue alloc] init];
        [queue setMaxConcurrentOperationCount:(cpuCoreCount() > 1 ? 3 : 2)];
    });
    return queue;
}

- (id)initWithPath:(NSString *)path
{
    self = [super initWithPath:path];
    if (self != nil)
    {   
        _actionHandle = [[ASHandle alloc] initWithDelegate:self releaseOnMainThread:false];
    }
    return self;
}

- (void)prepare:(NSDictionary *)options
{
    if (options != nil)
    {
        int contentHints = [[options objectForKey:@"contentHints"] intValue];
        if (contentHints & TGRemoteImageContentHintLargeFile)
        {
            if ([[self.path substringFromIndex:6] hasPrefix:@"download:"])
                self.requestQueueName = @"imageDownload";
        }
    }
}

- (void)dealloc
{
    [_actionHandle reset];
    if (_requestedActors)
        [ActionStageInstance() removeWatcher:self];
}

static inline double imageProcessingPriority()
{
    return !TGIsRetina() ? 0.12 : (cpuCoreCount() > 1 ? 0.4 : 0.1);
}

- (void)execute:(NSDictionary *)options
{
    static CFAbsoluteTime lastCompletionTime = 0;
    static bool delayFastCompletion = false;
    /*static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        delayFastCompletion = cpuCoreCount() < 2;
    });*/
    const CFTimeInterval fastDelayThresold = 0.018;
    const CFTimeInterval minimalThreshold = 0.008;
    
    bool allowThumbnailCache = false;
    bool allowMemoryCache = true;
    
    int contentHints = 0;
    id userProperties = nil;
    
    bool forceMemoryCache = false;
    
    TGCache *cache = nil;
    if (options != nil)
    {
        NSNumber *cancelTimeout = [options objectForKey:@"cancelTimeout"];
        if (cancelTimeout != nil)
            self.cancelTimeout = [cancelTimeout intValue];
        cache = [options objectForKey:@"cache"];
        
        contentHints = [[options objectForKey:@"contentHints"] intValue];
        
        NSNumber *nAllowThumbnailCache = [options objectForKey:@"allowThumbnailCache"];
        if (nAllowThumbnailCache != nil)
            allowThumbnailCache = [nAllowThumbnailCache boolValue];
        
        NSNumber *nUseCache = [options objectForKey:@"useCache"];
        if (nUseCache != nil)
            allowMemoryCache = [nUseCache boolValue];
        
        userProperties = [options objectForKey:@"userProperties"];
        
        forceMemoryCache = [options objectForKey:@"forceMemoryCache"];
    }
    
    if (!allowMemoryCache)
        TGLog(@"Memory cache disabled for %@", self.path);
    if (cache == nil)
        cache = [TGRemoteImageView sharedCache];
    
    NSString *path = self.path;
    
    NSString *actualPath = self.path;
    if ([actualPath hasPrefix:@"/img/(download:"])
        actualPath = [actualPath stringByReplacingOccurrencesOfString:@"/img/(download:" withString:@"/img/("];
    
    NSString *url = nil;
    TGImageProcessor processor = nil;
    NSString *processorName = nil;
    if ([actualPath hasPrefix:@"/img/({filter:"])
    {
        NSRange range = [actualPath rangeOfString:@"}"];
        if (range.location == NSNotFound)
        {
            [ActionStageInstance() nodeRetrieveFailed:self.path];
            return;
        }
        processorName = [actualPath substringWithRange:NSMakeRange(14, range.location - 14)];
        processor = [TGRemoteImageView imageProcessorForName:processorName];
        url = [actualPath substringWithRange:NSMakeRange(range.location + 1, actualPath.length - range.location - 1 - 1)];
    }
    else
        url = [actualPath substringWithRange:NSMakeRange(6, actualPath.length - 6 - 1)];
    
    NSString *rewrittenUrl = [TGImageDownloadActor possiblyRewrittenUrl:url];
    url = rewrittenUrl;
    
    NSString *storeUrl = url;
    if (processor != nil)
        storeUrl = [[NSString alloc] initWithFormat:@"{filter:%@}%@", processorName, url];
    
    bool cacheFiltered = [processorName hasSuffix:@"+bake"];
    
    if ([url hasPrefix:@"asset-original:"] || [url hasPrefix:@"asset-thumbnail:"])
    {
        NSString *assetUrl = [url substringFromIndex:[url rangeOfString:@":"].location + 1];
        [TGImagePickerController loadAssetWithUrl:[[NSURL alloc] initWithString:assetUrl] completion:^(ALAsset *asset)
        {
            UIImage *image = nil;
            if (asset != nil)
            {
                if ([url hasPrefix:@"asset-original:"])
                {
                    UIImage *rawImage = [[UIImage alloc] initWithCGImage:asset.defaultRepresentation.fullScreenImage];
                    if (processor != nil)
                        image = processor(rawImage);
                    else
                        image = [rawImage preloadedImage];
                    
                    if (image != nil && allowMemoryCache && (!TG_CACHE_INPLACE || forceMemoryCache))
                        [cache cacheImage:image withData:nil url:storeUrl availability:TGCacheMemory];
                }
                else
                {
                    image = [[UIImage alloc] initWithCGImage:asset.aspectRatioThumbnail];
                }
            }
            
            if (image != nil)
                [ActionStageInstance() nodeRetrieved:path node:[[SGraphObjectNode alloc] initWithObject:image]];
            else
                [ActionStageInstance() nodeRetrieveFailed:path];
        }];
        
        return;
    }
    
    UIImage *imageManagerImage = [[TGImageManager instance] loadImageSyncWithUri:url canWait:true decode:processor == nil acceptPartialData:false asyncTaskId:NULL progress:nil partialCompletion:nil completion:nil];
    if (imageManagerImage != nil)
    {
        UIImage *image = processor != nil ? processor(imageManagerImage) : imageManagerImage;
        
        if (image != nil && allowMemoryCache && (!TG_CACHE_INPLACE || forceMemoryCache))
            [cache cacheImage:image withData:nil url:storeUrl availability:TGCacheMemory];
        
        if (image != nil)
            [ActionStageInstance() nodeRetrieved:path node:[[SGraphObjectNode alloc] initWithObject:image]];
        else
            [ActionStageInstance() nodeRetrieveFailed:path];
    }
    
    if ([url hasPrefix:@"dialogListPlaceholder:"])
    {
        int64_t conversationId = [[url substringFromIndex:@"dialogListPlaceholder:".length] longLongValue];
        
        UIImage *image = conversationId < 0 ? [[TGInterfaceAssets instance] groupAvatarPlaceholder:conversationId] : [[TGInterfaceAssets instance] avatarPlaceholder:(int)conversationId];
        
        if (image != nil && allowMemoryCache && (!TG_CACHE_INPLACE || forceMemoryCache))
            [cache cacheImage:image withData:nil url:storeUrl availability:TGCacheMemory];
        
        if (image != nil)
            [ActionStageInstance() nodeRetrieved:path node:[[SGraphObjectNode alloc] initWithObject:image]];
        else
            [ActionStageInstance() nodeRetrieveFailed:path];
    }
    
    NSString *url1 = url;
    NSString *url2 = nil;
    if (cacheFiltered)
    {
        url1 = storeUrl;
        url2 = url;
    }
    
    [cache diskCacheContains:url1 orUrl:url2 completion:^(bool firstInDiskCache, bool secondInDiskCache)
    {
        [ActionStageInstance() dispatchOnStageQueue:^
        {
            if (firstInDiskCache || secondInDiskCache)
            {
                NSBlockOperation *operation = [[NSBlockOperation alloc] init];
                
                __weak NSOperation *blockOperation = operation;
                [operation addExecutionBlock:^
                {
                    @autoreleasepool
                    {
                        NSOperation *strongBlockOperation = blockOperation;
                        if (strongBlockOperation.isCancelled)
                            return;
                        strongBlockOperation = nil;
                        
                        NSString *cachedUrl = (firstInDiskCache ? url1 : url2);
                        
                        UIImage *cachedImage = nil;//[cache cachedImage:storeUrl availability:TGCacheMemory];
                        bool imageFromDisc = false;
                        if (cachedImage == nil)
                        {
                            cachedImage = [cache cachedImage:cachedUrl availability:TGCacheDisk];
                            imageFromDisc = true;
                        }
                        
                        strongBlockOperation = blockOperation;
                        if (strongBlockOperation.isCancelled)
                            return;
                        strongBlockOperation = nil;
                        
                        if (cachedImage != nil)
                        {
                            if (cacheFiltered && cachedImage != nil && processor != nil && firstInDiskCache)
                            {
                                [cachedImage tgPreload];
                            }
                            else
                            {
                                UIImage *originalImage = cachedImage;
                                if (processor != nil)
                                {
                                    cachedImage = processor(cachedImage);
                                    
                                    if (cacheFiltered && !firstInDiskCache)
                                    {
                                        NSData *filteredData = UIImageJPEGRepresentation(cachedImage, 0.5f);
                                        [cache cacheImage:nil withData:filteredData url:storeUrl availability:TGCacheDisk];
                                    }
                                    
                                    if (cachedImage == originalImage && imageFromDisc)
                                        cachedImage = [cachedImage preloadedImage];
                                }
                                else if (imageFromDisc)
                                    cachedImage = [cachedImage preloadedImage];
                            }
                            
                            strongBlockOperation = blockOperation;
                            if (strongBlockOperation.isCancelled)
                                return;
                            strongBlockOperation = nil;
                            
                            if (imageFromDisc)
                            {
                                if (allowMemoryCache && (!TG_CACHE_INPLACE || forceMemoryCache))
                                    [cache cacheImage:cachedImage withData:nil url:storeUrl availability:TGCacheMemory];
                                
                                if (allowThumbnailCache)
                                    [cache cacheThumbnail:cachedImage url:storeUrl];
                            }
                            
                            strongBlockOperation = blockOperation;
                            if (strongBlockOperation.isCancelled)
                                return;
                            strongBlockOperation = nil;
                            
                            [ActionStageInstance() dispatchOnStageQueue:^
                            {
                                if (delayFastCompletion && cachedImage.size.width * cachedImage.size.height > 200 * 200)
                                {
                                    CFAbsoluteTime currentTime = CFAbsoluteTimeGetCurrent();
                                    CFAbsoluteTime threshold = cachedImage.size.width * cachedImage.size.height <= 200 * 200 ? minimalThreshold : fastDelayThresold;
                                    if (currentTime - lastCompletionTime < threshold)
                                    {
                                        CFTimeInterval delay = threshold - (currentTime - lastCompletionTime);
                                        //TGLog(@"Delay image operation for %f ms", delay * 1000.0);
                                        lastCompletionTime = currentTime;
                                        usleep((int32_t)(delay * 1000 * 1000));
                                    }
                                    else
                                        lastCompletionTime = currentTime;
                                }
                                
                                [ActionStageInstance() nodeRetrieved:path node:[[SGraphObjectNode alloc] initWithObject:cachedImage]];
                            }];
                            
                            return;
                        }
                        else
                        {
                            [cache removeFromDiskCache:cachedUrl];
                            [ActionStageInstance() nodeRetrieveFailed:path];
                        }
                    }
                }];
                operation.threadPriority = imageProcessingPriority();
                self.cancelToken = operation;
                [[TGImageDownloadActor operationQueue] addOperation:operation];
            }
            else
            {
                if ([url1 hasPrefix:@"video-thumbnail-"])
                {
                    [ActionStageInstance() nodeRetrieveFailed:path];
                    return;
                }
                
                if ([self.path hasPrefix:@"/img/(download:"])
                {
                    NSBlockOperation *processingOperation = [[NSBlockOperation alloc] init];
                    self.cancelToken = processingOperation;
                    self.downloadCompletionBlock = ^(NSData *imageData)
                    {
                        if (imageData != nil)
                        {
                            __weak NSOperation *weakBlockOperation = processingOperation;
                            [processingOperation addExecutionBlock:^
                            {
                                @autoreleasepool
                                {
                                    NSOperation *blockOperation = weakBlockOperation;
                                    if (blockOperation.isCancelled)
                                        return;
                                    
                                    UIImage *image = nil;
                                    NSData *data = nil;
                                    
                                    image = [[UIImage alloc] initWithData:imageData];
                                    data = imageData;
                                    
                                    if (image == nil || data == nil)
                                        [ActionStageInstance() actionFailed:path reason:-1];
                                    else
                                    {
                                        UIImage *imageForThumbnail = nil;
                                        
                                        TGImageInfo *imageInfo = [userProperties objectForKey:@"imageInfo"];
                                        if (imageInfo != nil)
                                            imageForThumbnail = image;
                                        
                                        if (image != nil)
                                        {
                                            [cache cacheImage:nil withData:data url:url availability:TGCacheDisk];
                                            
                                            if (processor != nil)
                                            {   
                                                UIImage *originalImage = image;
                                                image = processor(image);
                                                if (image == originalImage)
                                                    image = [image preloadedImage];
                                                
                                                if (allowMemoryCache && (!TG_CACHE_INPLACE || forceMemoryCache))
                                                    [cache cacheImage:image withData:nil url:storeUrl availability:TGCacheMemory];
                                                
                                                if (allowThumbnailCache)
                                                    [cache cacheThumbnail:image url:storeUrl];
                                            }
                                            else
                                            {
                                                image = [image preloadedImage];
                                                
                                                if (allowMemoryCache && (!TG_CACHE_INPLACE || forceMemoryCache))
                                                    [cache cacheImage:image withData:nil url:storeUrl availability:TGCacheMemory];
                                                
                                                if (allowThumbnailCache)
                                                    [cache cacheThumbnail:image url:storeUrl];
                                            }
                                            
                                            if (delayFastCompletion)
                                            {
                                                CFAbsoluteTime currentTime = CFAbsoluteTimeGetCurrent();
                                                CFAbsoluteTime threshold = image.size.width * image.size.height <= 180 * 180 ? minimalThreshold : fastDelayThresold;
                                                if (currentTime - lastCompletionTime < threshold)
                                                {
                                                    CFTimeInterval delay = threshold - (currentTime - lastCompletionTime);
                                                    TGLog(@"Delay image operation for %f ms", delay * 1000.0);
                                                    lastCompletionTime = currentTime;
                                                    usleep((int32_t)(delay * 1000 * 1000));
                                                }
                                                else
                                                    lastCompletionTime = currentTime;
                                            }
                                            
                                            [ActionStageInstance() dispatchOnStageQueue:^
                                            {
                                                [ActionStageInstance() nodeRetrieved:path node:[[SGraphObjectNode alloc] initWithObject:image]];
                                                
                                                if (imageInfo != nil && imageForThumbnail != nil && ![url hasPrefix:@"upload"])
                                                {
                                                    CGSize thumbnailSize = CGSizeZero;
                                                    NSString *thumbnailUrl = [imageInfo closestImageUrlWithSize:CGSizeMake(90, 90) resultingSize:&thumbnailSize];
                                                    if (thumbnailUrl != nil)
                                                    {
                                                        thumbnailSize = TGFitSize(CGSizeMake(imageForThumbnail.size.width * imageForThumbnail.scale, imageForThumbnail.size.height * imageForThumbnail.scale), [TGGenericModernConversationCompanion preferredInlineThumbnailSize]);
                                                        
                                                        UIImage *thumbnailImage = TGScaleImageToPixelSize(imageForThumbnail, thumbnailSize);
                                                        if (thumbnailImage != nil)
                                                        {
                                                            NSData *thumbnailData = UIImageJPEGRepresentation(thumbnailImage, 0.85f);
                                                            if (thumbnailData != nil)
                                                            {
                                                                [cache removeFromMemoryCache:thumbnailUrl matchEnd:true];
                                                                
                                                                //TGLog(@"url: %@", url);
                                                                //TGLog(@"thumbnail url: %@", thumbnailUrl);
                                                                
                                                                [cache cacheImage:nil withData:thumbnailData url:thumbnailUrl availability:TGCacheDisk];
                                                                
                                                                TGFileDownloadActor *fileActor = (TGFileDownloadActor *)[ActionStageInstance() executingActorWithPath:[[NSString alloc] initWithFormat:@"/tg/file/(%@)", thumbnailUrl]];
                                                                if (fileActor != nil)
                                                                {
                                                                    [fileActor completeWithData:thumbnailData];
                                                                }
                                                                else
                                                                {
                                                                    TGDispatchAfter(0.08, [ActionStageInstance() globalStageDispatchQueue], ^
                                                                    {
                                                                        [ActionStageInstance() dispatchResource:[[NSString alloc] initWithFormat:@"/as/media/imageThumbnailUpdated"] resource:thumbnailUrl];
                                                                    });
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                                
                                                if ([[userProperties objectForKey:@"storeAsAsset"] boolValue] && TGAppDelegateInstance.autosavePhotos)
                                                {
                                                    bool shouldSave = true;
                                                    
                                                    if (![userProperties[@"forceSave"] boolValue])
                                                    {
                                                        int mid = [userProperties[@"messageId"] intValue];
                                                        int64_t conversationId = [userProperties[@"conversationId"] longLongValue];
                                                        if (mid != 0 && conversationId != 0)
                                                        {
                                                            int minAutosaveMid = [TGDatabaseInstance() minAutosaveMessageIdForConversation:conversationId];
                                                            //if (mid < minAutosaveMid)
                                                            //    shouldSave = false;
                                                        }
                                                        
                                                        if (TGPeerIdIsChannel(conversationId)) {
                                                            shouldSave = false;
                                                        }
                                                    }
                                                    
                                                    if (shouldSave)
                                                    {
                                                        [ActionStageInstance() requestActor:[[NSString alloc] initWithFormat:@"/tg/checkImageStored/(%lu)", (unsigned long)[url hash]] options:[[NSDictionary alloc] initWithObjectsAndKeys:url, @"url", nil] watcher:TGTelegraphInstance];
                                                    }
                                                }
                                            }];
                                        }
                                        else
                                        {
                                            [ActionStageInstance() nodeRetrieveFailed:path];
                                        }
                                    }
                                }
                            }];
                            
                            processingOperation.threadPriority = imageProcessingPriority();
                            [[TGImageDownloadActor operationQueue] addOperation:processingOperation];
                        }
                        else
                        {
                            [ActionStageInstance() nodeRetrieveFailed:path];
                        }
                    };
                    
                    if (contentHints & TGRemoteImageContentHintLargeFile && userProperties != nil && [[userProperties objectForKey:@"messageId"] intValue] != 0 && [userProperties objectForKey:@"mediaId"] != nil)
                    {
                        int64_t conversationId = [userProperties[@"conversationId"] longLongValue];
                        int32_t messageId = [[userProperties objectForKey:@"messageId"] intValue];
                        [[TGDownloadManager instance] enqueueItem:self.path messageId:[[userProperties objectForKey:@"messageId"] intValue] itemId:[userProperties objectForKey:@"mediaId"] groupId:conversationId itemClass:TGDownloadItemClassImage];
                        
                        _updateMediaAccessTimeOnRelease = true;
                        _messageId = messageId;
                        TGMediaId *mediaId = [userProperties objectForKey:@"mediaId"];
                        _imageId = mediaId.itemId;
                    }
                    
                    _requestedActors = true;
                    [ActionStageInstance() requestActor:[NSString stringWithFormat:@"/tg/file/(%@)", url] options:[NSDictionary dictionaryWithObjectsAndKeys:url, @"url", @(TGNetworkMediaTypeTagImage), @"mediaTypeTag", nil] watcher:self];
                }
                else
                {
                    if (![url hasPrefix:@"upload"])
                        [ActionStageInstance() dispatchMessageToWatchers:self.path messageType:@"progress" message:[[NSNumber alloc] initWithFloat:0.0f]];
                    
                    _requestedActors = true;
                    [ActionStageInstance() requestActor:[self.path stringByReplacingOccurrencesOfString:@"/img/(" withString:@"/img/(download:"] options:options flags:([[userProperties objectForKey:@"changePriority"] boolValue] ? TGActorRequestChangePriority : 0) watcher:self];
                }
            }
        }];
    }];
}

- (void)actorReportedProgress:(NSString *)path progress:(float)progress
{
    if ([path hasPrefix:@"/tg/file/"])
    {
        _progress = progress;
        [ActionStageInstance() dispatchMessageToWatchers:self.path messageType:@"progress" message:[[NSNumber alloc] initWithFloat:_progress]];
    }
    else if ([path hasPrefix:@"/img/"])
    {
        _progress = progress;
        [ActionStageInstance() dispatchMessageToWatchers:self.path messageType:@"progress" message:[[NSNumber alloc] initWithFloat:_progress]];
    }
}

- (void)actorMessageReceived:(NSString *)path messageType:(NSString *)messageType message:(id)message
{
    if ([path hasPrefix:@"/img/"])
    {
        if ([messageType isEqualToString:@"progress"])
        {
            _progress = [message floatValue];
            
            [ActionStageInstance() dispatchMessageToWatchers:self.path messageType:messageType message:message];
        }
    }
}

- (void)watcherJoined:(ASHandle *)watcherHandle options:(NSDictionary *)options waitingInActorQueue:(bool)waitingInActorQueue
{
    [watcherHandle receiveActorMessage:self.path messageType:@"progress" message:[[NSNumber alloc] initWithFloat:_progress]];
    
    [super watcherJoined:watcherHandle options:options waitingInActorQueue:waitingInActorQueue];
}

- (void)actorCompleted:(int)resultCode path:(NSString *)path result:(id)result
{
    if ([path hasPrefix:@"/tg/file/"])
    {
        if (resultCode == ASStatusSuccess)
        {
            if (self.downloadCompletionBlock)
                self.downloadCompletionBlock(((SGraphObjectNode *)result).object);
        }
        else
        {
            [ActionStageInstance() nodeRetrieveFailed:self.path];
            self.downloadCompletionBlock = nil;
        }
    }
    else if ([path hasPrefix:@"/img/"])
    {
        if (resultCode == ASStatusSuccess)
        {
            [ActionStageInstance() actionCompleted:self.path result:result];
        }
        else
        {
            [ActionStageInstance() nodeRetrieveFailed:self.path];
        }
    }
}

- (void)cancel
{
    if (self.cancelToken != nil)
    {
        if ([self.cancelToken isKindOfClass:[NSOperation class]])
            [((NSOperation *)self.cancelToken) cancel];
        else
            [TGTelegraphInstance cancelRequestByToken:self.cancelToken];
        
        self.cancelToken = nil;
        self.downloadCompletionBlock = nil;
    }
    
    [ActionStageInstance() removeWatcher:self];
    
    [super cancel];
}

@end
