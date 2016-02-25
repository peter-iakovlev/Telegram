#import "TGBotContextImageResult.h"

@implementation TGBotContextImageResult

- (instancetype)initWithQueryId:(int64_t)queryId resultId:(NSString *)resultId type:(NSString *)type image:(TGImageMediaAttachment *)image sendMessage:(id)sendMessage {
    self = [super initWithQueryId:(int64_t)queryId resultId:resultId type:type sendMessage:sendMessage];
    if (self != nil) {
        _image = image;
    }
    return self;
}

@end
