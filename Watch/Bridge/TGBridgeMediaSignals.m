#import "TGBridgeMediaSignals.h"
#import "TGBridgeMediaSubscription.h"
#import "TGBridgeImageMediaAttachment.h"
#import "TGBridgeVideoMediaAttachment.h"
#import "TGBridgeDocumentMediaAttachment.h"
#import "TGBridgeResponse.h"
#import "TGBridgeClient.h"
#import "TGFileCache.h"

#import "TGImageUtils.h"
#import "TGGeometry.h"

#import "TGExtensionDelegate.h"
#import <libkern/OSAtomic.h>

@interface TGBridgeMediaManager : NSObject
{
    NSMutableArray *_pendingUrls;
    OSSpinLock _pendingUrlsLock;
}
@end

@implementation TGBridgeMediaManager

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        _pendingUrls = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)addUrl:(NSString *)url
{
    OSSpinLockLock(&_pendingUrlsLock);
    [_pendingUrls addObject:url];
    OSSpinLockUnlock(&_pendingUrlsLock);
}

- (void)removeUrl:(NSString *)url
{
    OSSpinLockLock(&_pendingUrlsLock);
    [_pendingUrls removeObject:url];
    OSSpinLockUnlock(&_pendingUrlsLock);
}

- (bool)hasUrl:(NSString *)url
{
    OSSpinLockLock(&_pendingUrlsLock);
    bool contains = [_pendingUrls containsObject:url];
    OSSpinLockUnlock(&_pendingUrlsLock);
    
    return contains;
}

@end


@implementation TGBridgeMediaSignals

+ (SSignal *)previewWithImageAttachment:(TGBridgeImageMediaAttachment *)imageAttachment size:(CGSize)size
{
    NSString *imageUrl = [imageAttachment.imageInfo closestImageUrlWithSize:CGSizeMake(320.0f, 320.0f) resultingSize:NULL];
    TGBridgeSubscription *subscription = [[TGBridgeMediaPhotoThumbnailSubscription alloc] initWithImageAttachment:imageAttachment size:size];
    
    return [self _requestImageWithUrl:imageUrl subscription:subscription];
}

+ (SSignal *)previewWithVideoAttachment:(TGBridgeVideoMediaAttachment *)videoAttachment size:(CGSize)size
{
    NSString *imageUrl = [videoAttachment.thumbnailImageInfo closestImageUrlWithSize:CGSizeMake(320.0f, 320.0f) resultingSize:NULL];
    TGBridgeSubscription *subscription = [[TGBridgeMediaVideoThumbnailSubscription alloc] initWithVideoAttachment:videoAttachment size:size];
    
    return [self _requestImageWithUrl:imageUrl subscription:subscription];
}

+ (SSignal *)avatarWithUrl:(NSString *)url type:(TGBridgeMediaAvatarType)type
{
    NSString *imageUrl = [NSString stringWithFormat:@"%@_%lu", url, (unsigned long)type];
    TGBridgeSubscription *subscription = [[TGBridgeMediaAvatarSubscription alloc] initWithUrl:url type:type];
    
    return [self _requestImageWithUrl:imageUrl subscription:subscription];
}

const CGSize TGMediaStickerSmallSize = { 19, 19 };
const CGSize TGMediaStickerNormalSize38 = { 72, 72 };
const CGSize TGMediaStickerNormalSize42 = { 84, 84 };

+ (CGSize)_imageSizeForStickerType:(TGMediaStickerImageType)avatarType
{
    switch (avatarType)
    {
        case TGMediaStickerImageTypeList:
            return TGMediaStickerSmallSize;
            
        case TGMediaStickerImageTypeNormal:
        case TGMediaStickerImageTypeInput:
        {
            CGSize screenSize = [[WKInterfaceDevice currentDevice] screenBounds].size;
            if (screenSize.width > 150)
                return TGMediaStickerNormalSize42;
            else
                return TGMediaStickerNormalSize38;
        }
            
        default:
            break;
    }
    
    return TGMediaStickerNormalSize38;
}

+ (SSignal *)stickerWithDocumentAttachment:(TGBridgeDocumentMediaAttachment *)documentAttachment type:(TGMediaStickerImageType)type
{
    CGSize imageSize = [self _imageSizeForStickerType:type];
    NSString *imageUrl = [NSString stringWithFormat:@"sticker-%lld-%dx%d", documentAttachment.documentId, (int)imageSize.width, (int)imageSize.height];
    TGBridgeSubscription *subscription = [[TGBridgeMediaStickerSubscription alloc] initWithDocumentId:documentAttachment.documentId accessHash:documentAttachment.accessHash datacenterId:documentAttachment.datacenterId legacyThumbnailUri:documentAttachment.legacyThumbnailUri size:imageSize];
    
    return [self _requestImageWithUrl:imageUrl subscription:subscription];
}

+ (id(^)(NSData *))_imageUnserializeBlock
{
    return ^id(NSData *data)
    {
        return data;
    };
}

+ (SSignal *)_requestImageWithUrl:(NSString *)url subscription:(TGBridgeSubscription *)subscription
{
    SSignal *remoteSignal = [[[[[TGBridgeClient instance] requestSignalWithSubscription:subscription] onStart:^
    {
        if (![[self mediaManager] hasUrl:url])
            [[self mediaManager] addUrl:url];
    }] onDispose:^
    {
        [[self mediaManager] removeUrl:url];
    }] mapToSignal:^SSignal *(id next)
    {
        return [[self _downloadedFileWithUrl:url] onNext:^(id next)
        {
            [[self mediaManager] removeUrl:url];
        }];
    }];
    
    return [[self _cachedOrPendingWithUrl:url] catch:^SSignal *(id error)
    {
        return remoteSignal;
    }];
}

+ (SSignal *)_loadCachedWithUrl:(NSString *)url memoryOnly:(bool)memoryOnly unserializeBlock:(UIImage *(^)(NSData *))unserializeBlock
{
    return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
    {
        [[TGExtensionDelegate instance].imageCache fetchDataForKey:url memoryOnly:memoryOnly synchronous:false unserializeBlock:unserializeBlock completion:^(id image)
        {
            if (image != nil)
            {
                [subscriber putNext:image];
                [subscriber putCompletion];
            }
            else
            {
                [subscriber putError:nil];
            }
        }];
        
        return nil;
    }];
}

+ (SSignal *)_downloadedFileWithUrl:(NSString *)url
{
    return [[self _loadCachedWithUrl:url memoryOnly:true unserializeBlock:nil] catch:^SSignal *(id error)
    {
        return [[[[TGBridgeClient instance] fileSignalForKey:url] take:1] map:^NSData *(NSURL *url)
        {
            return [NSData dataWithContentsOfURL:url];
        }];
    }];
}

+ (SSignal *)_cachedOrPendingWithUrl:(NSString *)url
{
    return [[self _loadCachedWithUrl:url memoryOnly:false unserializeBlock:[self _imageUnserializeBlock]] catch:^SSignal *(id error)
    {
        if ([[self mediaManager] hasUrl:url])
            return [self _downloadedFileWithUrl:url];
        
        return [SSignal fail:nil];
    }];
}

+ (TGBridgeMediaManager *)mediaManager
{
    static dispatch_once_t onceToken;
    static TGBridgeMediaManager *manager;
    dispatch_once(&onceToken, ^
    {
        manager = [[TGBridgeMediaManager alloc] init];
    });
    return manager;
}

@end
