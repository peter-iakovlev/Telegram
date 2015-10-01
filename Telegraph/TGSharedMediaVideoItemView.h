#import "TGSharedMediaThumbnailItemView.h"

@class TGVideoMediaAttachment;

@interface TGSharedMediaVideoItemView : TGSharedMediaThumbnailItemView

- (void)setVideoMediaAttachment:(TGVideoMediaAttachment *)videoMediaAttachment messageId:(int32_t)messageId peerId:(int64_t)peerId;

@end
