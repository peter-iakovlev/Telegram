#import "TGBotContextExternalResult.h"

@implementation TGBotContextExternalResult

- (instancetype)initWithQueryId:(int64_t)queryId resultId:(NSString *)resultId sendMessage:(id)sendMessage url:(NSString *)url displayUrl:(NSString *)displayUrl type:(NSString *)type title:(NSString *)title pageDescription:(NSString *)pageDescription thumbUrl:(NSString *)thumbUrl originalUrl:(NSString *)originalUrl contentType:(NSString *)contentType size:(CGSize)size duration:(int32_t)duration {
    self = [super initWithQueryId:(int64_t)queryId resultId:resultId type:type sendMessage:sendMessage];
    if (self != nil) {
        _url = url;
        _displayUrl = displayUrl;
        _title = title;
        _pageDescription = pageDescription;
        _thumbUrl = thumbUrl;
        _originalUrl = originalUrl;
        _contentType = contentType;
        _size = size;
        _duration = duration;
    }
    return self;
}


- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    return [self initWithQueryId:[aDecoder decodeInt64ForKey:@"queryId"]
                        resultId:[aDecoder decodeObjectForKey:@"resultId"]
                     sendMessage:[aDecoder decodeObjectForKey:@"sendMessage"]
                             url:[aDecoder decodeObjectForKey:@"url"]
                      displayUrl:[aDecoder decodeObjectForKey:@"displayUrl"]
                            type:[aDecoder decodeObjectForKey:@"type"]
                           title:[aDecoder decodeObjectForKey:@"title"]
                 pageDescription:[aDecoder decodeObjectForKey:@"pageDescription"]
                        thumbUrl:[aDecoder decodeObjectForKey:@"thumbUrl"]
                     originalUrl:[aDecoder decodeObjectForKey:@"originalUrl"]
                     contentType:[aDecoder decodeObjectForKey:@"contentType"]
                            size:[aDecoder decodeCGSizeForKey:@"size"]
                        duration:[aDecoder decodeInt32ForKey:@"duration"]];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeInt64:self.queryId forKey:@"queryId"];
    [aCoder encodeObject:self.resultId forKey:@"resultId"];
    [aCoder encodeObject:self.sendMessage forKey:@"sendMessage"];
    [aCoder encodeObject:self.url forKey:@"url"];
    [aCoder encodeObject:self.displayUrl forKey:@"displayUrl"];
    [aCoder encodeObject:self.type forKey:@"type"];
    [aCoder encodeObject:self.title forKey:@"title"];
    [aCoder encodeObject:self.pageDescription forKey:@"pageDescription"];
    [aCoder encodeObject:self.thumbUrl forKey:@"thumbUrl"];
    [aCoder encodeObject:self.originalUrl forKey:@"originalUrl"];
    [aCoder encodeObject:self.contentType forKey:@"contentType"];
    [aCoder encodeCGSize:self.size forKey:@"size"];
    [aCoder encodeInt32:self.duration forKey:@"duration"];
}

@end
