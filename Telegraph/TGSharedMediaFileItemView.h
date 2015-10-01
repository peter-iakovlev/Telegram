#import "TGSharedMediaItemView.h"

@class TGDocumentMediaAttachment;
@class TGSharedMediaAvailabilityState;

@interface TGSharedMediaFileItemView : TGSharedMediaItemView

- (void)setDocumentMediaAttachment:(TGDocumentMediaAttachment *)documentMediaAttachment date:(int)date lastInSection:(bool)lastInSection availabilityState:(TGSharedMediaAvailabilityState *)availabilityState thumbnailColors:(NSArray *)thumbnailColors;
- (void)setAvailabilityState:(TGSharedMediaAvailabilityState *)availabilityState animated:(bool)animated;

@end
