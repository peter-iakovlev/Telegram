#import "TGMediaEditingContext.h"

#import "UIImage+TG.h"
#import "TGStringUtils.h"
#import "TGPhotoEditorUtils.h"
#import "PGPhotoEditorValues.h"
#import "TGVideoEditAdjustments.h"

#import "TGModernCache.h"
#import "TGMemoryImageCache.h"

#import "TGAppDelegate.h"

@interface TGMediaImageUpdate : NSObject

@property (nonatomic, readonly, strong) id<TGMediaEditableItem> item;
@property (nonatomic, readonly, strong) id representation;

+ (instancetype)imageUpdateWithItem:(id<TGMediaEditableItem>)item representation:(id)representation;

@end


@interface TGMediaAdjustmentsUpdate : NSObject

@property (nonatomic, readonly, strong) id<TGMediaEditableItem> item;
@property (nonatomic, readonly, strong) id<TGMediaEditAdjustments> adjustments;

+ (instancetype)adjustmentsUpdateWithItem:(id<TGMediaEditableItem>)item adjustments:(id<TGMediaEditAdjustments>)adjustments;

@end


@interface TGMediaCaptionUpdate : NSObject

@property (nonatomic, readonly, strong) id<TGMediaEditableItem> item;
@property (nonatomic, readonly, strong) NSString *caption;

+ (instancetype)captionUpdateWithItem:(id<TGMediaEditableItem>)item caption:(NSString *)caption;

@end


@interface TGModernCache (Private)

- (void)cleanup;

@end

@interface TGMediaEditingContext ()
{
    NSString *_contextId;
    
    NSMutableDictionary *_captions;
    NSMutableDictionary *_adjustments;
 
    SQueue *_queue;
    
    NSMutableDictionary *_temporaryRepCache;
    
    TGMemoryImageCache *_imageCache;
    TGMemoryImageCache *_thumbnailImageCache;
    
    TGMemoryImageCache *_originalImageCache;
    TGMemoryImageCache *_originalThumbnailImageCache;
    
    TGModernCache *_diskCache;
    NSURL *_fullSizeResultsUrl;
    
    SPipe *_representationPipe;
    SPipe *_thumbnailImagePipe;
    SPipe *_adjustmentsPipe;
    SPipe *_captionPipe;
    SPipe *_fullSizePipe;
    SPipe *_cropPipe;
}
@end

@implementation TGMediaEditingContext

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        _contextId = [NSString stringWithFormat:@"%ld", lrand48()];
        _queue = [[SQueue alloc] init];

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
        
        _fullSizeResultsUrl = [NSURL fileURLWithPath:[[TGAppDelegate documentsPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"photoeditorresults/%@", _contextId]]];
        [[NSFileManager defaultManager] createDirectoryAtPath:_fullSizeResultsUrl.path withIntermediateDirectories:true attributes:nil error:nil];
        
        _temporaryRepCache = [[NSMutableDictionary alloc] init];
        
        _representationPipe = [[SPipe alloc] init];
        _thumbnailImagePipe = [[SPipe alloc] init];
        _adjustmentsPipe = [[SPipe alloc] init];
        _captionPipe = [[SPipe alloc] init];
        _fullSizePipe = [[SPipe alloc] init];
        _cropPipe = [[SPipe alloc] init];
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
    
    [[NSFileManager defaultManager] removeItemAtPath:_fullSizeResultsUrl.path error:nil];
}

#pragma mark -

- (SSignal *)imageSignalForItem:(NSObject<TGMediaEditableItem> *)item
{
    return [self imageSignalForItem:item withUpdates:true];
}

- (SSignal *)imageSignalForItem:(NSObject<TGMediaEditableItem> *)item withUpdates:(bool)withUpdates
{
    NSString *itemId = [self _contextualIdForItemId:item.uniqueIdentifier];
    if (itemId == nil)
        return [SSignal fail:nil];
    
    SSignal *updateSignal = [[_representationPipe.signalProducer() filter:^bool(TGMediaImageUpdate *update)
    {
        return [update.item.uniqueIdentifier isEqualToString:item.uniqueIdentifier];
    }] map:^id(TGMediaImageUpdate *update)
    {
        return update.representation;
    }];
    
    if ([self _adjustmentsForItemId:itemId] == nil)
    {
        SSignal *signal = [SSignal single:nil];
        if (withUpdates)
            signal = [signal then:updateSignal];
        return signal;
    }
    
    NSString *imageUri = [TGMediaEditingContext _imageUriForItemId:itemId];
    SSignal *signal = [[self _imageSignalForItemId:itemId imageCache:_imageCache imageDiskUri:imageUri synchronous:false] catch:^SSignal *(__unused id error)
    {
        id temporaryRep = [_temporaryRepCache objectForKey:itemId];
        SSignal *signal = [SSignal single:temporaryRep];
        if (withUpdates)
            signal = [signal then:updateSignal];
        return signal;
    }];
    if (withUpdates)
        signal = [signal then:updateSignal];
    return signal;
}

- (SSignal *)thumbnailImageSignalForItem:(id<TGMediaEditableItem>)item
{
    return [self thumbnailImageSignalForItem:item withUpdates:true synchronous:false];
}

- (SSignal *)thumbnailImageSignalForItem:(id<TGMediaEditableItem>)item withUpdates:(bool)withUpdates synchronous:(bool)synchronous
{
    NSString *itemId = [self _contextualIdForItemId:item.uniqueIdentifier];
    if (itemId == nil)
        return [SSignal fail:nil];
    
    SSignal *updateSignal = [[_thumbnailImagePipe.signalProducer() filter:^bool(TGMediaImageUpdate *update)
    {
        return [update.item.uniqueIdentifier isEqualToString:item.uniqueIdentifier];
    }] map:^id(TGMediaImageUpdate *update)
    {
        return update.representation;
    }];
    
    if ([self _adjustmentsForItemId:itemId] == nil)
    {
        SSignal *signal = [SSignal single:nil];
        if (withUpdates)
            signal = [signal then:updateSignal];
        return signal;
    }
    
    NSString *imageUri = [TGMediaEditingContext _thumbnailImageUriForItemId:itemId];
    SSignal *signal = [[self _imageSignalForItemId:itemId imageCache:_thumbnailImageCache imageDiskUri:imageUri synchronous:synchronous] catch:^SSignal *(__unused id error)
    {
        SSignal *signal = [SSignal single:nil];
        if (withUpdates)
            signal = [signal then:updateSignal];
        return signal;
    }];
    if (withUpdates)
        signal = [signal then:updateSignal];
    return signal;
}

- (SSignal *)fastImageSignalForItem:(NSObject<TGMediaEditableItem> *)item withUpdates:(bool)withUpdates
{
    return [[self thumbnailImageSignalForItem:item withUpdates:false synchronous:true] then:[self imageSignalForItem:item withUpdates:withUpdates]];
}

- (SSignal *)_imageSignalForItemId:(NSString *)itemId imageCache:(TGMemoryImageCache *)imageCache imageDiskUri:(NSString *)imageDiskUri synchronous:(bool)synchronous
{
    if (itemId == nil)
        return [SSignal fail:nil];
    
    SSignal *signal = [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
    {
        UIImage *result = [imageCache imageForKey:itemId attributes:NULL];
        if (result == nil)
        {
            NSData *imageData = [_diskCache getValueForKey:[imageDiskUri dataUsingEncoding:NSUTF8StringEncoding]];
            if (imageData != nil)
            {
                result = [UIImage imageWithData:imageData];
                [imageCache setImage:result forKey:itemId attributes:NULL];
            }
        }
        
        if (result != nil)
        {
            [subscriber putNext:result];
            [subscriber putCompletion];
        }
        else
        {
            [subscriber putError:nil];
        }
        
        return nil;
    }];
    
    return synchronous ? signal : [signal startOn:_queue];
}

#pragma mark - Caption

- (NSString *)captionForItem:(id<TGMediaEditableItem>)item
{
    NSString *itemId = [self _contextualIdForItemId:item.uniqueIdentifier];
    if (itemId == nil)
        return nil;
    
    return _captions[itemId];
}

- (void)setCaption:(NSString *)caption forItem:(id<TGMediaEditableItem>)item
{
    NSString *itemId = [self _contextualIdForItemId:item.uniqueIdentifier];
    if (itemId == nil)
        return;
    
    if (caption.length > 0)
        _captions[itemId] = caption;
    else
        [_captions removeObjectForKey:itemId];
    
    _captionPipe.sink([TGMediaCaptionUpdate captionUpdateWithItem:item caption:caption]);
}

- (SSignal *)captionSignalForItem:(NSObject<TGMediaEditableItem> *)item
{
    SSignal *signal = [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
    {
        NSString *caption = [self captionForItem:item];
        [subscriber putNext:caption];
        [subscriber putCompletion];
        
        return nil;
    }];
    
    SSignal *updateSignal = [[_captionPipe.signalProducer() filter:^bool(TGMediaCaptionUpdate *update)
    {
        return [update.item.uniqueIdentifier isEqualToString:item.uniqueIdentifier];
    }] map:^NSString *(TGMediaCaptionUpdate *update)
    {
        return update.caption;
    }];
    
    return [signal then:updateSignal];
}

#pragma mark -

- (id<TGMediaEditAdjustments>)adjustmentsForItem:(id<TGMediaEditableItem>)item
{
    NSString *itemId = [self _contextualIdForItemId:item.uniqueIdentifier];
    if (itemId == nil)
        return nil;
    
    return [self _adjustmentsForItemId:itemId];
}

- (id<TGMediaEditAdjustments>)_adjustmentsForItemId:(NSString *)itemId
{
    if (itemId == nil)
        return nil;
    
    return _adjustments[itemId];
}

- (void)setAdjustments:(id<TGMediaEditAdjustments>)adjustments forItem:(id<TGMediaEditableItem>)item
{
    NSString *itemId = [self _contextualIdForItemId:item.uniqueIdentifier];
    if (itemId == nil)
        return;
    
    id<TGMediaEditAdjustments> previousAdjustments = _adjustments[itemId];
    
    if (adjustments != nil)
        _adjustments[itemId] = adjustments;
    else
        [_adjustments removeObjectForKey:itemId];
    
    _adjustmentsPipe.sink([TGMediaAdjustmentsUpdate adjustmentsUpdateWithItem:item adjustments:adjustments]);
    
    bool cropChanged = false;
    
    if ([adjustments isKindOfClass:[PGPhotoEditorValues class]])
    {
        if (![previousAdjustments cropAppliedForAvatar:false] && [adjustments cropAppliedForAvatar:false])
            cropChanged = true;
        else if ([previousAdjustments cropAppliedForAvatar:false] && ![adjustments cropAppliedForAvatar:false])
            cropChanged = true;
        else if ([previousAdjustments cropAppliedForAvatar:false] && [adjustments cropAppliedForAvatar:false] && ![previousAdjustments isCropEqualWith:adjustments])
            cropChanged = true;
    }
    else if ([adjustments isKindOfClass:[TGVideoEditAdjustments class]])
    {
        TGVideoEditAdjustments *previousVideoAdjustments = (TGVideoEditAdjustments *)previousAdjustments;
        TGVideoEditAdjustments *videoAdjustments = (TGVideoEditAdjustments *)adjustments;
        
        if (![previousVideoAdjustments cropOrRotationAppliedForAvatar:false] && [videoAdjustments cropOrRotationAppliedForAvatar:false])
            cropChanged = true;
        else if ([previousVideoAdjustments cropOrRotationAppliedForAvatar:false] && ![videoAdjustments cropOrRotationAppliedForAvatar:false])
            cropChanged = true;
        else if ([previousVideoAdjustments cropOrRotationAppliedForAvatar:false] && [videoAdjustments cropOrRotationAppliedForAvatar:false] && ![previousVideoAdjustments isCropAndRotationEqualWith:videoAdjustments])
            cropChanged = true;
    }
    
    if (cropChanged)
        _cropPipe.sink(@true);
}

- (SSignal *)adjustmentsSignalForItem:(NSObject<TGMediaEditableItem> *)item
{
    SSignal *signal = [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
    {
        id<TGMediaEditAdjustments> adjustments = [self adjustmentsForItem:item];
        [subscriber putNext:adjustments];
        [subscriber putCompletion];
        
        return nil;
    }];
    
    SSignal *updateSignal = [[_adjustmentsPipe.signalProducer() filter:^bool(TGMediaAdjustmentsUpdate *update)
    {
        return [update.item.uniqueIdentifier isEqualToString:item.uniqueIdentifier];
    }] map:^id<TGMediaEditAdjustments>(TGMediaAdjustmentsUpdate *update)
    {
        return update.adjustments;
    }];
    
    return [signal then:updateSignal];
}

- (SSignal *)cropAdjustmentsUpdatedSignal
{
    return _cropPipe.signalProducer();
}

#pragma mark -

- (void)setImage:(UIImage *)image thumbnailImage:(UIImage *)thumbnailImage forItem:(id<TGMediaEditableItem>)item synchronous:(bool)synchronous
{
    NSString *itemId = [self _contextualIdForItemId:item.uniqueIdentifier];
    
    if (itemId == nil)
        return;
    
    void (^block)(void) = ^
    {
        [_temporaryRepCache removeObjectForKey:itemId];
        
        NSString *imageUri = [[self class] _imageUriForItemId:itemId];
        [_imageCache setImage:image forKey:itemId attributes:NULL];
        if (image != nil)
        {
            NSData *imageData = UIImageJPEGRepresentation(image, 0.95f);
            [_diskCache setValue:imageData forKey:[imageUri dataUsingEncoding:NSUTF8StringEncoding]];
        }
        _representationPipe.sink([TGMediaImageUpdate imageUpdateWithItem:item representation:image]);
    
        NSString *thumbnailImageUri = [[self class] _thumbnailImageUriForItemId:itemId];
        [_thumbnailImageCache setImage:thumbnailImage forKey:itemId attributes:NULL];
        if (thumbnailImage != nil)
        {
            NSData *imageData = UIImageJPEGRepresentation(thumbnailImage, 0.87f);
            [_diskCache setValue:imageData forKey:[thumbnailImageUri dataUsingEncoding:NSUTF8StringEncoding]];
        }
//        _thumbnailImagePipe.sink([TGMediaImageUpdate imageUpdateWithItem:item representation:thumbnailImage]);
    };
    
    if (synchronous)
        [_queue dispatchSync:block];
    else
        [_queue dispatch:block];
}

- (void)setFullSizeImage:(UIImage *)image forItem:(id<TGMediaEditableItem>)item
{
    NSString *itemId = [self _contextualIdForItemId:item.uniqueIdentifier];
    
    if (itemId == nil)
        return;
    
    NSData *imageData = UIImageJPEGRepresentation(image, 0.7f);
    NSURL *url = [_fullSizeResultsUrl URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg", [TGStringUtils md5:itemId]]];
    NSError *error;
    bool succeed = [imageData writeToURL:url options:NSDataWritingAtomic error:&error];
    if (succeed)
        _fullSizePipe.sink(itemId);
}

- (NSURL *)_fullSizeImageUrlForItem:(id<TGMediaEditableItem>)item
{
    NSString *itemId = [self _contextualIdForItemId:item.uniqueIdentifier];
    
    if (itemId == nil)
        return nil;
    
    NSURL *url = [_fullSizeResultsUrl URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg", [TGStringUtils md5:itemId]]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:url.path])
        return url;
    
    return nil;
}

- (SSignal *)fullSizeImageUrlForItem:(id<TGMediaEditableItem>)item
{
    NSString *itemId = [self _contextualIdForItemId:item.uniqueIdentifier];
    id<TGMediaEditAdjustments> adjustments = [self adjustmentsForItem:item];
    
    if (![adjustments isKindOfClass:[PGPhotoEditorValues class]])
        return [SSignal complete];
    
    PGPhotoEditorValues *editorValues = (PGPhotoEditorValues *)adjustments;
    if (![editorValues toolsApplied])
        return [SSignal complete];
    
    NSURL *url = [self _fullSizeImageUrlForItem:item];
    if (url != nil)
        return [SSignal single:url];
    
    return [[[_fullSizePipe.signalProducer() filter:^bool(NSString *identifier)
    {
        return [identifier isEqualToString:itemId];
    }] mapToSignal:^SSignal *(__unused id next)
    {
        NSURL *url = [self _fullSizeImageUrlForItem:item];
        if (url != nil)
            return [SSignal single:url];
        else
            return [SSignal complete];
    }] timeout:5.0 onQueue:_queue orSignal:[SSignal complete]];
}

- (void)setTemporaryRep:(id)rep forItem:(id<TGMediaEditableItem>)item
{
    NSString *itemId = [self _contextualIdForItemId:item.uniqueIdentifier];
    
    if (itemId == nil)
        return;
    
    UIImage *thumbnailImage = nil;
    if ([rep isKindOfClass:[UIImage class]])
    {
        UIImage *image = (UIImage *)rep;
        image.degraded = true;
        image.edited = true;
        
        CGSize fillSize = TGPhotoThumbnailSizeForCurrentScreen();
        fillSize.width = CGCeil(fillSize.width);
        fillSize.height = CGCeil(fillSize.height);
        
        CGSize size = TGScaleToFillSize(image.size, fillSize);
        
        UIGraphicsBeginImageContextWithOptions(size, true, 0.0f);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetInterpolationQuality(context, kCGInterpolationMedium);
        
        [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
        
        thumbnailImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    [_queue dispatchSync:^
    {
        if (rep != nil)
            [_temporaryRepCache setObject:rep forKey:itemId];
        else
            [_temporaryRepCache removeObjectForKey:itemId];
        
        _representationPipe.sink([TGMediaImageUpdate imageUpdateWithItem:item representation:rep]);
        
        if (thumbnailImage != nil)
        {
            [_thumbnailImageCache setImage:thumbnailImage forKey:itemId attributes:NULL];
            _thumbnailImagePipe.sink([TGMediaImageUpdate imageUpdateWithItem:item representation:thumbnailImage]);
        }
    }];
}

#pragma mark - Original Images

- (void)requestOriginalImageForItem:(id<TGMediaEditableItem>)item completion:(void (^)(UIImage *))completion
{
    NSString *itemId = [self _contextualIdForItemId:item.uniqueIdentifier];
    
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

- (void)requestOriginalThumbnailImageForItem:(id<TGMediaEditableItem>)item completion:(void (^)(UIImage *))completion
{
    NSString *itemId = [self _contextualIdForItemId:item.uniqueIdentifier];
    
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

- (void)setOriginalImage:(UIImage *)image forItem:(id<TGMediaEditableItem>)item synchronous:(bool)synchronous
{
    NSString *itemId = [self _contextualIdForItemId:item.uniqueIdentifier];
    
    if (itemId == nil || image == nil)
        return;
    
    if ([_originalImageCache imageForKey:itemId attributes:NULL] != nil)
        return;
    
    void (^block)(void) = ^
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
    };
    
    if (synchronous)
        [_queue dispatchSync:block];
    else
        [_queue dispatch:block];
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


@implementation TGMediaImageUpdate

+ (instancetype)imageUpdateWithItem:(id<TGMediaEditableItem>)item representation:(id)representation
{
    TGMediaImageUpdate *update = [[TGMediaImageUpdate alloc] init];
    update->_item = item;
    update->_representation = representation;
    return update;
}

@end


@implementation TGMediaAdjustmentsUpdate

+ (instancetype)adjustmentsUpdateWithItem:(id<TGMediaEditableItem>)item adjustments:(id<TGMediaEditAdjustments>)adjustments
{
    TGMediaAdjustmentsUpdate *update = [[TGMediaAdjustmentsUpdate alloc] init];
    update->_item = item;
    update->_adjustments = adjustments;
    return update;
}

@end

@implementation TGMediaCaptionUpdate

+ (instancetype)captionUpdateWithItem:(id<TGMediaEditableItem>)item caption:(NSString *)caption
{
    TGMediaCaptionUpdate *update = [[TGMediaCaptionUpdate alloc] init];
    update->_item = item;
    update->_caption = caption;
    return update;
}

@end
