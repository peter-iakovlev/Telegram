#import "TGModernMediaListThumbnailItemView.h"
#import "TGModernGalleryEditableItemView.h"

@interface TGWebSearchImageItemView : TGModernMediaListThumbnailItemView <TGModernGalleryEditableItemView>

- (void)updateItemHiddenAnimated:(bool)animated;
- (void)updateItemSelected;
- (void)updateIsEditing;

@end
