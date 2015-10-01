#import "TGMediaPickerGalleryItem.h"
#import "TGModernGallerySelectableItem.h"
#import "TGModernGalleryEditableItem.h"
#import <AVFoundation/AVFoundation.h>

@protocol TGMediaEditAdjustments;

@interface TGMediaPickerGalleryVideoItem : TGMediaPickerGalleryItem <TGModernGallerySelectableItem, TGModernGalleryEditableItem>

@property (nonatomic, readonly) AVURLAsset *avAsset;
@property (nonatomic, readonly) CGSize dimensions;
@property (nonatomic, readonly) NSTimeInterval duration;

@property (nonatomic, copy) void (^updateAdjustments)(id<TGEditablePhotoItem> editableMediaItem, id<TGMediaEditAdjustments> adjustments);
@property (nonatomic, copy) void (^updateThumbnail)(id<TGEditablePhotoItem> editableMediaItem, UIImage *screenImage, UIImage *thumbnailImage);

- (instancetype)initWithFileURL:(NSURL *)fileURL dimensions:(CGSize)dimensions duration:(NSTimeInterval)duration;

@end
