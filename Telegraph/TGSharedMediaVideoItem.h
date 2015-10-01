#import "TGSharedMediaItem.h"

@class TGVideoMediaAttachment;

@interface TGSharedMediaVideoItem : NSObject <TGSharedMediaItem>

@property (nonatomic, strong, readonly) TGVideoMediaAttachment *videoMediaAttachment;

- (instancetype)initWithMessage:(TGMessage *)message messageId:(int32_t)messageId date:(NSTimeInterval)date incoming:(bool)incoming videoMediaAttachment:(TGVideoMediaAttachment *)videoMediaAttachment;

@end
