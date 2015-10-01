#import "TGMediaEditingContext.h"

#import "ATQueue.h"

#import "TGPhotoEditorUtils.h"

#import "TGModernCache.h"
#import "TGMemoryImageCache.h"

#import "TGAppDelegate.h"

@interface TGModernCache (Private)

- (void)cleanup;

@end

@interface TGMediaEditingContext ()
{
    NSString *_contextId;
    
    NSMutableDictionary *_captions;
    NSMutableDictionary *_adjustments;
 
    ATQueue *_queue;
    
    TGMemoryImageCache *_imageCache;
    TGMemoryImageCache *_thumbnailImageCache;
    
    TGMemoryImageCache *_originalImageCache;
    TGMemoryImageCache *_originalThumbnailImageCache;
    
    TGModernCache *_diskCache;
}
@end

@implementation TGMediaEditingContext

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        _contextId = [NSString stringWithFormat:@"%ld", lrand48()];
        _queue = [[ATQueue alloc] init];

        _captions = [[NSMutableDictionary alloc] init];
        _adjustments = [[NSMutableDictionary alloc] init];
        
        _imageCache = [[TGMemoryImageCache alloc] initWithSoftMemoryLimit:[[self class] imageSoftMemoryLimit]
                                                          hardMemoryLimit:[[self class] imageHardMemoryLimit]];
        _thumbnailImageCache = [[TGMemoryImageCache alloc] initWithSoftMemoryLimit:[[self class] thumbnailImageSoftMemoryLimit]
                                                                   hardMemoryLimit:[[self class] thumbnailImageHardMemoryLimit]];
        
        _originalImageCache = [[TGMemoryImageCache alloc] initWithSoftMemoryLimit:[[self class] originalImageSoftMemoryLimit]
                                                                  hardMemoryLimit:[[self class] originalImageHardMemoryLimit]];
        _originalThumbnailImageCache = [[TGMemoryImageCache alloc] initWithSoftMemoryLimit:[[self class] thumbnailImageSoftMemoryLimit]
                                                                           hardMemoryLimit:[[self class] thumbnailImageHardMemoryLimit]];
        
        NSString *diskCachePath = [[TGAppDelegate documentsPath] stringByAppendingPathComponent:[[self class] diskCachePath]];
        _diskCache = [[TGModernCache alloc] initWithPath:diskCachePath size:[[self class] diskMemoryLimit]];
    }
    return self;
}

- (void)dealloc
{
    [self cleanup];
}

- (void)cleanup
{
    [_diskCache cleanup];
}

#pragma mark - Caption

- (NSString *)captionForItemId:(NSString *)itemId
{
    itemId = [self _contextualIdForItemId:itemId];
    if (itemId == nil)
        return nil;
    
    __block NSString *caption = nil;
    
    [_queue dispatch:^
    {
        caption = _captions[itemId];
    } synchronous:true];
    
    return caption;
}

- (void)setCaption:(NSString *)caption forItemId:(NSString *)itemId synchronous:(bool)synchronous
{
    itemId = [self _contextualIdForItemId:itemId];
    
    if (itemId == nil)
        return;

    [_queue dispatch:^
    {
        if (caption.length > 0)
            _captions[itemId] = caption;
        else
            [_captions removeObjectForKey:itemId];
    } synchronous:synchronous];
}

#pragma mark - Adjustments

- (id<TGMediaEditAdjustments>)adjustmentsForItemId:(NSString *)itemId
{
    itemId = [self _contextualIdForItemId:itemId];
    
    if (itemId == nil)
        return nil;
    
    __block id<TGMediaEditAdjustments> adjustments = nil;
    
    [_queue dispatch:^
    {
        adjustments = _adjustments[itemId];
    } synchronous:true];
    
    return adjustments;
}

- (void)setAdjustments:(id<TGMediaEditAdjustments>)adjustments forItemId:(NSString *)itemId synchronous:(bool)synchronous
{
    itemId = [self _contextualIdForItemId:itemId];
    
    if (itemId == nil)
        return;
    
    [_queue dispatch:^
    {
        if (adjustments != nil)
            _adjustments[itemId] = adjustments;
        else
            [_adjustments removeObjectForKey:itemId];
    } synchronous:synchronous];
}

#pragma mark - Images

- (UIImage *)imageForItemId:(NSString *)itemId
{
    itemId = [self _contextualIdForItemId:itemId];
    
    if (itemId == nil)
        return nil;
    
    __block UIImage *result = nil;
    
    [_queue dispatch:^
    {
        result = [_imageCache imageForKey:itemId attributes:NULL];
        if (result == nil)
        {
            NSString *imageUri = [[self class] _imageUriForItemId:itemId];
            NSData *imageData = [_diskCache getValueForKey:[imageUri dataUsingEncoding:NSUTF8StringEncoding]];
            if (imageData != nil)
            {
                result = [UIImage imageWithData:imageData];
                
                [_imageCache setImage:result forKey:itemId attributes:NULL];
            }
        }
    } synchronous:true];
    
    return result;
}

- (UIImage *)thumbnailImageForItemId:(NSString *)itemId
{
    itemId = [self _contextualIdForItemId:itemId];
    
    if (itemId == nil)
        return nil;
    
    __block UIImage *result = nil;
    
    [_queue dispatch:^
    {
        result = [_thumbnailImageCache imageForKey:itemId attributes:NULL];
        if (result == nil)
        {
            NSString *thumbnailImageUri = [[self class] _thumbnailImageUriForItemId:itemId];
            NSData *imageData = [_diskCache getValueForKey:[thumbnailImageUri dataUsingEncoding:NSUTF8StringEncoding]];
            if (imageData != nil)
            {
                result = [UIImage imageWithData:imageData];
                
                [_thumbnailImageCache setImage:result forKey:itemId attributes:NULL];
            }
        }
    } synchronous:true];
    
    return result;
}

- (void)setImage:(UIImage *)image thumbnailImage:(UIImage *)thumbnailImage forItemId:(NSString *)itemId synchronous:(bool)synchronous
{
    itemId = [self _contextualIdForItemId:itemId];
    
    if (itemId == nil || (image == nil && thumbnailImage == nil))
        return;
    
    [_queue dispatch:^
    {
        if (image != nil)
        {
            NSString *imageUri = [[self class] _imageUriForItemId:itemId];
            [_imageCache setImage:image forKey:itemId attributes:NULL];
            NSData *imageData = UIImageJPEGRepresentation(image, 0.95f);
            [_diskCache setValue:imageData forKey:[imageUri dataUsingEncoding:NSUTF8StringEncoding]];
        }
        
        if (thumbnailImage != nil)
        {
            NSString *thumbnailImageUri = [[self class] _thumbnailImageUriForItemId:itemId];
            [_thumbnailImageCache setImage:thumbnailImage forKey:itemId attributes:NULL];
            NSData *imageData = UIImageJPEGRepresentation(thumbnailImage, 0.87f);
            [_diskCache setValue:imageData forKey:[thumbnailImageUri dataUsingEncoding:NSUTF8StringEncoding]];
        }
    } synchronous:synchronous];
}

#pragma mark - Original Images

- (void)requestOriginalImageForItemId:(NSString *)itemId completion:(void (^)(UIImage *))completion
{
    itemId = [self _contextualIdForItemId:itemId];
    
    if (itemId == nil)
    {
        if (completion != nil)
            completion(nil);
        return;
    }
    
    __block UIImage *result = [_originalImageCache imageForKey:itemId attributes:NULL];
    if (result != nil)
    {
        if (completion != nil)
            completion(result);
    }
    else
    {
        [_queue dispatch:^
        {
            NSString *originalImageUri = [[self class] _originalImageUriForItemId:itemId];
            NSData *imageData = [_diskCache getValueForKey:[originalImageUri dataUsingEncoding:NSUTF8StringEncoding]];
            if (imageData != nil)
            {
                result = [UIImage imageWithData:imageData];
                
                [_originalImageCache setImage:result forKey:itemId attributes:NULL];
            }
            
            if (completion != nil)
                completion(result);
        }];
    }
}

- (void)requestOriginalThumbnailImageForItemId:(NSString *)itemId completion:(void (^)(UIImage *))completion
{
    itemId = [self _contextualIdForItemId:itemId];
    
    if (itemId == nil)
    {
        if (completion != nil)
            completion(nil);
        return;
    }
    
    __block UIImage *result = [_originalThumbnailImageCache imageForKey:itemId attributes:NULL];
    if (result != nil)
    {
        if (completion != nil)
            completion(result);
    }
    else
    {
        [_queue dispatch:^
        {
            NSString *originalThumbnailImageUri = [[self class] _originalThumbnailImageUriForItemId:itemId];
            NSData *imageData = [_diskCache getValueForKey:[originalThumbnailImageUri dataUsingEncoding:NSUTF8StringEncoding]];
            if (imageData != nil)
            {
                result = [UIImage imageWithData:imageData];
                
                [_originalThumbnailImageCache setImage:result forKey:itemId attributes:NULL];
            }
            
            if (completion != nil)
                completion(result);
        }];
    }
}

- (void)setOriginalImage:(UIImage *)image forItemId:(NSString *)itemId synchronous:(bool)synchronous
{
    itemId = [self _contextualIdForItemId:itemId];
    
    if (itemId == nil || image == nil)
        return;
    
    if ([_originalImageCache imageForKey:itemId attributes:NULL] != nil)
        return;
    
    [_queue dispatch:^
    {
        if (image != nil)
        {
            NSString *originalImageUri = [[self class] _originalImageUriForItemId:itemId];
            NSData *existingImageData = [_diskCache getValueForKey:[originalImageUri dataUsingEncoding:NSUTF8StringEncoding]];
            if (existingImageData.length > 0)
                return;
            
            [_originalImageCache setImage:image forKey:itemId attributes:NULL];
            NSData *imageData = UIImageJPEGRepresentation(image, 0.95f);
            [_diskCache setValue:imageData forKey:[originalImageUri dataUsingEncoding:NSUTF8StringEncoding]];
            
            CGFloat thumbnailImageSide = TGPhotoThumbnailSizeForCurrentScreen().width;
            CGSize targetSize = TGScaleToSize(image.size, CGSizeMake(thumbnailImageSide, thumbnailImageSide));
            
            UIGraphicsBeginImageContextWithOptions(targetSize, true, 0.0f);
            [image drawInRect:CGRectMake(0, 0, targetSize.width, targetSize.height)];
            UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            [_originalThumbnailImageCache setImage:image forKey:itemId attributes:NULL];
            NSString *originalThumbnailImageUri = [[self class] _originalThumbnailImageUriForItemId:itemId];
            NSData *thumbnailImageData = UIImageJPEGRepresentation(image, 0.87f);
            [_diskCache setValue:thumbnailImageData forKey:[originalThumbnailImageUri dataUsingEncoding:NSUTF8StringEncoding]];
        }
    } synchronous:synchronous];
}

+ (NSString *)_originalImageUriForItemId:(NSString *)itemId
{
    return [NSString stringWithFormat:@"photo-editor-original://%@", itemId];
}

+ (NSString *)_originalThumbnailImageUriForItemId:(NSString *)itemId
{
    return [NSString stringWithFormat:@"photo-editor-original-thumb://%@", itemId];
}

#pragma mark - URI

- (NSString *)_contextualIdForItemId:(NSString *)itemId
{
    if (itemId == nil)
        return nil;
    
    return [NSString stringWithFormat:@"%@_%@", _contextId, itemId];
}

+ (NSString *)_imageUriForItemId:(NSString *)itemId
{
    return [NSString stringWithFormat:@"%@://%@", [self imageUriScheme], itemId];
}

+ (NSString *)_thumbnailImageUriForItemId:(NSString *)itemId
{
    return [NSString stringWithFormat:@"%@://%@", [self thumbnailImageUriScheme], itemId];
}

#pragma mark - Constants

+ (NSString *)imageUriScheme
{
    return @"photo-editor";
}

+ (NSString *)thumbnailImageUriScheme
{
    return @"photo-editor-thumb";
}

+ (NSString *)diskCachePath
{
    return @"photoeditorcache_v1";
}

+ (NSUInteger)diskMemoryLimit
{
    return 64 * 1024 * 1024;
}

+ (NSUInteger)imageSoftMemoryLimit
{
    return 13 * 1024 * 1024;
}

+ (NSUInteger)imageHardMemoryLimit
{
    return 15 * 1024 * 1024;
}

+ (NSUInteger)originalImageSoftMemoryLimit
{
    return 12 * 1024 * 1024;
}

+ (NSUInteger)originalImageHardMemoryLimit
{
    return 14 * 1024 * 1024;
}

+ (NSUInteger)thumbnailImageSoftMemoryLimit
{
    return 2 * 1024 * 1024;
}

+ (NSUInteger)thumbnailImageHardMemoryLimit
{
    return 3 * 1024 * 1024;
}

@end
