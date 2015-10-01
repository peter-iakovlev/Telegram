#import "TGModernMediaListItem.h"

@protocol TGEditablePhotoItem;

@protocol TGModernMediaListEditableItem <TGModernMediaListItem>

- (id<TGEditablePhotoItem>)editableMediaItem;
- (NSString *)uniqueId;

@end
