#import "TGBotContextResultSendMessageGeo.h"

@implementation TGBotContextResultSendMessageGeo

- (instancetype)initWithLocation:(TGLocationMediaAttachment *)location replyMarkup:(TGBotReplyMarkup *)replyMarkup {
    self = [super init];
    if (self != nil) {
        _location = location;
        _replyMarkup = replyMarkup;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    return [self initWithLocation:[aDecoder decodeObjectForKey:@"location"] replyMarkup:[aDecoder decodeObjectForKey:@"replyMarkup"]];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_location forKey:@"location"];
    [aCoder encodeObject:_replyMarkup forKey:@"replyMarkup"];
}

@end
