#import "TGBotContextResultSendMessageText.h"

@implementation TGBotContextResultSendMessageText

- (instancetype)initWithMessage:(NSString *)message entities:(NSArray *)entities noWebpage:(bool)noWebpage {
    self = [super init];
    if (self != nil) {
        _message = message;
        _entities = entities;
        _noWebpage = noWebpage;
    }
    return self;
}

@end
