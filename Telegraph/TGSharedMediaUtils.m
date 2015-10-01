#import "TGSharedMediaUtils.h"

#import "TGMediaStoreContext.h"

@implementation TGSharedMediaUtils

+ (TGMemoryImageCache *)sharedMediaMemoryImageCache
{
    static TGMemoryImageCache *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        float factor = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad ? 3.0f : 1.0f;
        instance = [[TGMemoryImageCache alloc] initWithSoftMemoryLimit:(NSUInteger)(2 * 1024 * 1024 * factor) hardMemoryLimit:(NSUInteger)(3 * 1024 * 1024 * factor)];
    });
    return instance;
}

+ (EMInMemoryImageCache *)inMemoryImageCache
{
    static EMInMemoryImageCache *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        float factor = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad ? 3.0f : 1.0f;
        instance = [[EMInMemoryImageCache alloc] initWithMaxResidentSize:(NSUInteger)(4 * 1024 * 1024 * factor)];
    });
    return instance;
}

+ (SThreadPool *)sharedMediaImageProcessingThreadPool
{
    static SThreadPool *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        instance = [[SThreadPool alloc] init];
    });
    return instance;
}

+ (TGModernCache *)sharedMediaTemporaryPersistentCache
{
    return [[TGMediaStoreContext instance] temporaryFilesCache];
}

@end
