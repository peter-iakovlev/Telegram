#import "EMInMemoryImageCache.h"

#import <pthread.h>

#import "EMImageData.h"

@interface EMInMemoryResidentImage : NSObject

@property (nonatomic, strong, readonly) id<NSCopying> key;
@property (nonatomic, strong, readonly) UIImage *image;
@property (nonatomic) NSUInteger accessIndex;

@end

@implementation EMInMemoryResidentImage

- (instancetype)initWithKey:(id<NSCopying>)key image:(UIImage *)image accessIndex:(NSUInteger)accessIndex
{
    self = [super init];
    if (self != nil)
    {
        _key = key;
        _image = image;
        _accessIndex = accessIndex;
    }
    return self;
}

@end

@interface EMInMemoryImageCache ()
{
    pthread_mutex_t _lock;
    
    NSMutableDictionary *_dict;
    NSMutableDictionary *_residentImages;

    NSUInteger _maxResidentSize;
    NSUInteger _residentImagesTotalSize;
    NSUInteger _nextAccessIndex;
}

@end

@implementation EMInMemoryImageCache

- (instancetype)init
{
    return [self initWithMaxResidentSize:1 * 1024 * 1024];
}

- (instancetype)initWithMaxResidentSize:(NSUInteger)maxResidentSize
{
    self = [super init];
    if (self != nil)
    {
        pthread_mutex_init(&_lock, NULL);
        _dict = [[NSMutableDictionary alloc] init];
        _residentImages = [[NSMutableDictionary alloc] init];
        _maxResidentSize = maxResidentSize;
        _nextAccessIndex = 1;
    }
    return self;
}

- (void)setImageDataWithSize:(CGSize)size generator:(void (^)(uint8_t *memory, NSUInteger bytesPerRow))generator forKey:(id<NSCopying>)key
{
    if (key != nil)
    {
        UIImage *image = nil;
        EMImageData *imageData = [[EMImageData alloc] initWithSize:size generator:generator image:&image];
        
        pthread_mutex_lock(&_lock);
        _dict[key] = imageData;
        [self _addResidentImage:image forKey:key];
        pthread_mutex_unlock(&_lock);
    }
}

- (void)_addResidentImage:(UIImage *)image forKey:(id<NSCopying>)key
{
    NSUInteger imageSize = (NSUInteger)(image.size.width * image.size.height * image.scale * 4);
    if (_residentImagesTotalSize + imageSize > _maxResidentSize)
    {
        NSInteger sizeToRemove = ((NSInteger)_residentImagesTotalSize) - (((NSInteger)_maxResidentSize) - ((NSInteger)imageSize));
        
        NSArray *sortedImages = [[_residentImages allValues] sortedArrayUsingComparator:^NSComparisonResult(EMInMemoryResidentImage *image1, EMInMemoryResidentImage *image2)
        {
            if (image1.accessIndex < image2.accessIndex)
                return NSOrderedDescending;
            else if (image1.accessIndex > image2.accessIndex)
                return NSOrderedAscending;
            return NSOrderedSame;
        }];
        
        NSMutableArray *removedKeys = [[NSMutableArray alloc] init];
        NSInteger removedSize = 0;
        for (NSInteger i = ((NSInteger)sortedImages.count) - 1; i >= 0 && removedSize < sizeToRemove; i--)
        {
            EMInMemoryResidentImage *currentImage = sortedImages[i];
            NSInteger currentImageSize = (NSInteger)(currentImage.image.size.width * currentImage.image.size.height * currentImage.image.scale * 4);
            removedSize += currentImageSize;
            [removedKeys addObject:currentImage.key];
        }
        
        [_residentImages removeObjectsForKeys:removedKeys];
        _residentImagesTotalSize = MAX(0, ((NSInteger)_residentImagesTotalSize) - removedSize);
    }
    
    _residentImagesTotalSize += imageSize;
    _residentImages[key] = [[EMInMemoryResidentImage alloc] initWithKey:key image:image accessIndex:_nextAccessIndex++];
}

- (UIImage *)imageForKey:(id<NSCopying>)key
{
    if (key == nil)
        return nil;
    
    UIImage *image = nil;
    pthread_mutex_lock(&_lock);
    EMInMemoryResidentImage *residentImage = _residentImages[key];
    if (residentImage != nil)
    {
        EMInMemoryResidentImage *residentImage = _residentImages[key];
        residentImage.accessIndex = _nextAccessIndex++;
        image = residentImage.image;
    }
    else
    {
        EMImageData *imageData = _dict[key];
        if (imageData != nil)
        {
            image = [imageData image];
            if (image == nil)
                [_dict removeObjectForKey:key];
            else
                [self _addResidentImage:image forKey:key];
        }
    }
    pthread_mutex_unlock(&_lock);
    
    return image;
}

- (void)_debugPrintStats
{
    pthread_mutex_lock(&_lock);
    __block NSUInteger residentSize = 0;
    [_residentImages enumerateKeysAndObjectsUsingBlock:^(__unused id key, EMInMemoryResidentImage *image, __unused BOOL *stop)
    {
        residentSize += (NSUInteger)(image.image.size.width * image.image.size.height * 4);
    }];
    __block NSUInteger cachedSize = 0;
    [_dict enumerateKeysAndObjectsUsingBlock:^(__unused id key, EMImageData *imageData, __unused BOOL *stop)
    {
        if (![imageData isDiscarded])
            cachedSize += (NSUInteger)(imageData.size.width * imageData.size.height * 4);
    }];
    NSLog(@"(EMInMemoryImageCache residentSize: %.02fMB, cachedSize: %.02fMB)", residentSize / (1024.0f * 1024.0f), cachedSize / (1024.0f * 1024.0f));
    pthread_mutex_unlock(&_lock);
}

@end
