#import "TGMediaStoreContext.h"

#import "ATQueue.h"
#import "TGMemoryImageCache.h"

#import <pthread.h>

#import "TGAppDelegate.h"

@interface TGMediaStoreContext ()
{
    NSMutableDictionary *_mediaImageAverageColorCache;
    TGMemoryImageCache *_mediaImageCache;
    TGMemoryImageCache *_mediaReducedImageCache;
    
    pthread_rwlock_t _mediaImageAverageColorCacheLock;
    pthread_rwlock_t _mediaImageCacheLock;
    pthread_rwlock_t _mediaReducedImageCacheLock;
    
    ATQueue *_mediaReducedImageGenerationQueue;
    
    TGModernCache *_temporaryFilesCache;
}

@end

@implementation TGMediaStoreContext

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        _mediaImageAverageColorCache = [[NSMutableDictionary alloc] init];
        
        float factor = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad ? 3.0f : 1.0f;
        _mediaImageCache = [[TGMemoryImageCache alloc] initWithSoftMemoryLimit:(NSUInteger)(2 * 1024 * 1024 * factor) hardMemoryLimit:(NSUInteger)(3 * 1024 * 1024 * factor)];
        _mediaReducedImageCache = [[TGMemoryImageCache alloc] initWithSoftMemoryLimit:(NSUInteger)(1.5 * 1024 * 1024 * factor) hardMemoryLimit:(NSUInteger)(2.5 * 1024 * 1024 * factor)];
        
        pthread_rwlock_init(&_mediaImageAverageColorCacheLock, NULL);
        pthread_rwlock_init(&_mediaImageCacheLock, NULL);
        pthread_rwlock_init(&_mediaReducedImageCacheLock, NULL);
        
        NSString *tempCachePath = [[TGAppDelegate documentsPath] stringByAppendingPathComponent:@"tempcache_v1"];
        _temporaryFilesCache = [[TGModernCache alloc] initWithPath:tempCachePath size:16 * 1024 * 1024];
        
        _mediaReducedImageGenerationQueue = [[ATQueue alloc] init];
    }
    return self;
}

- (TGModernCache *)temporaryFilesCache
{
    return _temporaryFilesCache;
}

+ (TGMediaStoreContext *)instance
{
    static TGMediaStoreContext *singleton = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        singleton = [[TGMediaStoreContext alloc] init];
    });
    return singleton;
}

- (NSNumber *)mediaImageAverageColor:(NSString *)key
{
    if (key == nil)
        return nil;
    
    NSNumber *result = nil;
    pthread_rwlock_rdlock(&_mediaImageAverageColorCacheLock);
    result = _mediaImageAverageColorCache[key];
    pthread_rwlock_unlock(&_mediaImageAverageColorCacheLock);
    
    return result;
}

- (void)setMediaImageAverageColorForKey:(NSString *)key averageColor:(NSNumber *)averageColor
{
    if (key == nil)
        return;
    
    pthread_rwlock_wrlock(&_mediaImageAverageColorCacheLock);
    _mediaImageAverageColorCache[key] = averageColor;
    pthread_rwlock_unlock(&_mediaImageAverageColorCacheLock);
}

- (UIImage *)mediaReducedImage:(NSString *)key attributes:(__autoreleasing NSDictionary **)attributes
{
    if (key == nil)
        return nil;
    
    UIImage *result = nil;
    NSDictionary *tempAttributes = nil;
    
    pthread_rwlock_rdlock(&_mediaReducedImageCacheLock);
    result = [_mediaReducedImageCache imageForKey:key attributes:&tempAttributes];
    pthread_rwlock_unlock(&_mediaReducedImageCacheLock);
    
    if (attributes != NULL)
        *attributes = tempAttributes;
    
    return result;
}

- (void)setMediaReducedImageForKey:(NSString *)key reducedImage:(UIImage *)reducedImage attributes:(NSDictionary *)attributes
{
    if (key == nil || reducedImage == nil)
        return;
    
    pthread_rwlock_wrlock(&_mediaReducedImageCacheLock);
    [_mediaReducedImageCache setImage:reducedImage forKey:key attributes:attributes];
    pthread_rwlock_unlock(&_mediaReducedImageCacheLock);
}

- (UIImage *)mediaImage:(NSString *)key attributes:(__autoreleasing NSDictionary **)attributes
{
    if (key == nil)
        return nil;
    
    UIImage *result = nil;
    NSDictionary *tempAttributes = nil;
    
    pthread_rwlock_rdlock(&_mediaImageCacheLock);
    result = [_mediaImageCache imageForKey:key attributes:&tempAttributes];
    pthread_rwlock_unlock(&_mediaImageCacheLock);
    
    if (attributes != NULL)
        *attributes = tempAttributes;
    
    return result;
}

- (void)setMediaImageForKey:(NSString *)key image:(UIImage *)image attributes:(NSDictionary *)attributes
{
    if (key == nil || image == nil)
        return;
    
    pthread_rwlock_wrlock(&_mediaImageCacheLock);
    [_mediaImageCache setImage:image forKey:key attributes:attributes];
    pthread_rwlock_unlock(&_mediaImageCacheLock);
}

- (void)inMediaReducedImageCacheGenerationQueue:(dispatch_block_t)block
{
    [_mediaReducedImageGenerationQueue dispatch:block];
}

@end
