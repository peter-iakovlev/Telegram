#import "TGBotContextResult.h"

#import "TGDocumentMediaAttachment.h"

@interface TGBotContextDocumentResult : TGBotContextResult

@property (nonatomic, strong, readonly) TGDocumentMediaAttachment *document;

- (instancetype)initWithQueryId:(int64_t)queryId resultId:(NSString *)resultId type:(NSString *)type document:(TGDocumentMediaAttachment *)document sendMessage:(id)sendMessage;

@end
