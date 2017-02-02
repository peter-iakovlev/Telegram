#import "TGBotContextResultSendMessageText.h"

@implementation TGBotContextResultSendMessageText

- (instancetype)initWithMessage:(NSString *)message entities:(NSArray *)entities noWebpage:(bool)noWebpage replyMarkup:(TGBotReplyMarkup *)replyMarkup {
    self = [super init];
    if (self != nil) {
        _message = message;
        _entities = entities;
        _noWebpage = noWebpage;
        _replyMarkup = replyMarkup;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    return [self initWithMessage:[aDecoder decodeObjectForKey:@"message"] entities:[aDecoder decodeObjectForKey:@"entities"] noWebpage:[aDecoder decodeBoolForKey:@"noWebpage"] replyMarkup:[aDecoder decodeObjectForKey:@"replyMarkup"]];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_message forKey:@"message"];
    [aCoder encodeObject:_entities forKey:@"entities"];
    [aCoder encodeBool:_noWebpage forKey:@"noWebpage"];
    [aCoder encodeObject:_replyMarkup forKey:@"replyMarkup"];
}

@end
