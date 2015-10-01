#import "TGSharedMediaThumbnailItemView.h"

@class TGImageMediaAttachment;

@interface TGSharedMediaImageItemView : TGSharedMediaThumbnailItemView

- (void)setImageMediaAttachment:(TGImageMediaAttachment *)imageMediaAttachment messageId:(int32_t)messageId peerId:(int64_t)peerId;

@end
