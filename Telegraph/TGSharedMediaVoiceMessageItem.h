#import "TGSharedMediaItem.h"

@class TGMessage;
@class TGDocumentMediaAttachment;

@interface TGSharedMediaVoiceMessageItem : NSObject <TGSharedMediaItem>

@property (nonatomic, strong, readonly) TGDocumentMediaAttachment *documentMediaAttachment;

- (instancetype)initWithMessage:(TGMessage *)message messageId:(int32_t)messageId date:(NSTimeInterval)date incoming:(bool)incoming documentMediaAttachment:(TGDocumentMediaAttachment *)documentMediaAttachment;

@end
