#import "TGBotContextResult.h"

@implementation TGBotContextResult

- (instancetype)initWithQueryId:(int64_t)queryId resultId:(NSString *)resultId type:(NSString *)type sendMessage:(id)sendMessage {
    self = [super init];
    if (self != nil) {
        _queryId = queryId;
        _resultId = resultId;
        _type = type;
        _sendMessage = sendMessage;
    }
    return self;
}

@end
