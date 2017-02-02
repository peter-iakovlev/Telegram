#import "TGBotContextResultSendMessageAuto.h"

@implementation TGBotContextResultSendMessageAuto

- (instancetype)initWithCaption:(NSString *)caption replyMarkup:(TGBotReplyMarkup *)replyMarkup {
    self = [super init];
    if (self != nil) {
        _caption = caption;
        _replyMarkup = replyMarkup;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    return [self initWithCaption:[aDecoder decodeObjectForKey:@"caption"] replyMarkup:[aDecoder decodeObjectForKey:@"replyMarkup"]];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_caption forKey:@"caption"];
    [aCoder encodeObject:_replyMarkup forKey:@"replyMarkup"];
}

@end
