#import "TGBotContextMediaResult.h"

@implementation TGBotContextMediaResult

- (instancetype)initWithQueryId:(int64_t)queryId resultId:(NSString *)resultId type:(NSString *)type photo:(TGImageMediaAttachment *)photo document:(TGDocumentMediaAttachment *)document title:(NSString *)title resultDescription:(NSString *)resultDescription sendMessage:(id)sendMessage {
    self = [super initWithQueryId:queryId resultId:resultId type:type sendMessage:sendMessage];
    if (self != nil) {
        _photo = photo;
        _document = document;
        _title = title;
        _resultDescription = resultDescription;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    return [self initWithQueryId:[aDecoder decodeInt64ForKey:@"queryId"]
                        resultId:[aDecoder decodeObjectForKey:@"resultId"]
                            type:[aDecoder decodeObjectForKey:@"type"]
                           photo:[aDecoder decodeObjectForKey:@"photo"]
                        document:[aDecoder decodeObjectForKey:@"document"]
                           title:[aDecoder decodeObjectForKey:@"title"]
                 resultDescription:[aDecoder decodeObjectForKey:@"resultDescription"]
                     sendMessage:[aDecoder decodeObjectForKey:@"sendMessage"]];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeInt64:self.queryId forKey:@"queryId"];
    [aCoder encodeObject:self.resultId forKey:@"resultId"];
    [aCoder encodeObject:self.type forKey:@"type"];
    [aCoder encodeObject:self.photo forKey:@"photo"];
    [aCoder encodeObject:self.document forKey:@"document"];
    [aCoder encodeObject:self.title forKey:@"title"];
    [aCoder encodeObject:self.resultDescription forKey:@"resultDescription"];
    [aCoder encodeObject:self.sendMessage forKey:@"sendMessage"];
}

@end
