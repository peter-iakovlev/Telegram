#import "TGSharedMediaThumbnailItemView.h"

@class TGDocumentMediaAttachment;
@class TGSharedMediaAvailabilityState;

@interface TGSharedMediaFileThumbnailItemView : TGSharedMediaThumbnailItemView

- (void)setDocumentMediaAttachment:(TGDocumentMediaAttachment *)documentMediaAttachment availabilityState:(TGSharedMediaAvailabilityState *)availabilityState thumbnailColors:(NSArray *)thumbnailColors;
- (void)setAvailabilityState:(TGSharedMediaAvailabilityState *)availabilityState animated:(bool)animated;

@end
