#import "TGModernGalleryItem.h"

@protocol TGModernGallerySelectableItem <TGModernGalleryItem>

@property (nonatomic, copy) void(^itemSelected)(id<TGModernGallerySelectableItem> item);

- (NSString *)uniqueId;

@end
