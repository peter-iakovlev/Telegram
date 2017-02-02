#import "TGBotContextResultSendMessageContact.h"

@implementation TGBotContextResultSendMessageContact

- (instancetype)initWithContact:(TGContactMediaAttachment *)contact replyMarkup:(TGBotReplyMarkup *)replyMarkup {
    self = [super init];
    if (self != nil) {
        _contact = contact;
        _replyMarkup = replyMarkup;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    return [self initWithContact:[aDecoder decodeObjectForKey:@"contact"] replyMarkup:[aDecoder decodeObjectForKey:@"replyMarkup"]];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_contact forKey:@"contact"];
    [aCoder encodeObject:_replyMarkup forKey:@"replyMarkup"];
}

@end
