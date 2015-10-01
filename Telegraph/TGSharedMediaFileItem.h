#import "TGSharedMediaItem.h"

@class TGDocumentMediaAttachment;

@interface TGSharedMediaFileItem : NSObject <TGSharedMediaItem>

@property (nonatomic, strong, readonly) TGDocumentMediaAttachment *documentMediaAttachment;

- (instancetype)initWithMessage:(TGMessage *)message messageId:(int32_t)messageId date:(NSTimeInterval)date incoming:(bool)incoming documentMediaAttachment:(TGDocumentMediaAttachment *)documentMediaAttachment;

@end
