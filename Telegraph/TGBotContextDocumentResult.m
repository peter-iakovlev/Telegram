#import "TGBotContextDocumentResult.h"

@implementation TGBotContextDocumentResult

- (instancetype)initWithQueryId:(int64_t)queryId resultId:(NSString *)resultId type:(NSString *)type document:(TGDocumentMediaAttachment *)document sendMessage:(id)sendMessage {
    self = [super initWithQueryId:queryId resultId:resultId type:type sendMessage:sendMessage];
    if (self != nil) {
        _document = document;
    }
    return self;
}

@end
