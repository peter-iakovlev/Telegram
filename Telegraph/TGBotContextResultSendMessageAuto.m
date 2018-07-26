#import "TGBotContextResultSendMessageAuto.h"

@implementation TGBotContextResultSendMessageAuto

- (instancetype)initWithText:(NSString *)text entities:(NSArray *)entities replyMarkup:(TGBotReplyMarkup *)replyMarkup {
    self = [super init];
    if (self != nil) {
        _text = text;
        _entities = entities;
        _replyMarkup = replyMarkup;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    return [self initWithText:[aDecoder decodeObjectForKey:@"caption"] entities:[aDecoder decodeObjectForKey:@"entities"] replyMarkup:[aDecoder decodeObjectForKey:@"replyMarkup"]];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_text forKey:@"caption"];
    [aCoder encodeObject:_entities forKey:@"entities"];
    [aCoder encodeObject:_replyMarkup forKey:@"replyMarkup"];
}

@end
