#import "TGSharedMediaItem.h"

@class TGImageMediaAttachment;

@interface TGSharedMediaImageItem : NSObject <TGSharedMediaItem>

@property (nonatomic, strong, readonly) TGImageMediaAttachment *imageMediaAttachment;

- (instancetype)initWithMessage:(TGMessage *)message messageId:(int32_t)messageId date:(NSTimeInterval)date incoming:(bool)incoming imageMediaAttachment:(TGImageMediaAttachment *)imageMediaAttachment;

@end
