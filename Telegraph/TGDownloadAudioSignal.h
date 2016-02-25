#import <SSignalKit/SSignalKit.h>

@class TGMediaAttachment;
@class TGDocumentMediaAttachment;

@interface TGDownloadAudioSignal : NSObject

+ (SSignal *)downloadAudioWithAttachment:(TGMediaAttachment *)audioAttachment conversationId:(int64_t)cid messageId:(int32_t)mid;

+ (NSString *)pathForDocumentMediaAttachment:(TGDocumentMediaAttachment *)documentMedia;

@end
