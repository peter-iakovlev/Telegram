#import "TGBotContextResultSendMessageAuto.h"

@implementation TGBotContextResultSendMessageAuto

- (instancetype)initWithCaption:(NSString *)caption {
    self = [super init];
    if (self != nil) {
        _caption = caption;
    }
    return self;
}

@end
