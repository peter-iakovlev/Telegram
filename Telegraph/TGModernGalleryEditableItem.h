#import "TGModernGalleryItem.h"

@protocol TGEditablePhotoItem;

@protocol TGModernGalleryEditableItem <TGModernGalleryItem>

- (id<TGEditablePhotoItem>)editableMediaItem;
- (NSString *)uniqueId;

@end
