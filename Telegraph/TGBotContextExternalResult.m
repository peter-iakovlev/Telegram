#import "TGBotContextExternalResult.h"
#import "TGWebDocument+Telegraph.h"

@implementation TGBotContextExternalResult

- (instancetype)initWithQueryId:(int64_t)queryId resultId:(NSString *)resultId sendMessage:(id)sendMessage url:(NSString *)url displayUrl:(NSString *)displayUrl type:(NSString *)type title:(NSString *)title pageDescription:(NSString *)pageDescription thumb:(TGWebDocument *)thumb content:(TGWebDocument *)content {
    self = [super initWithQueryId:(int64_t)queryId resultId:resultId type:type sendMessage:sendMessage];
    if (self != nil) {
        _url = url;
        _displayUrl = displayUrl;
        _title = title;
        _pageDescription = pageDescription;
        _thumb = thumb;
        _content = content;
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
                           thumb:[aDecoder decodeObjectForKey:@"thumb"]
                         content:[aDecoder decodeObjectForKey:@"content"]];
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
    [aCoder encodeObject:self.thumb forKey:@"thumb"];
    [aCoder encodeObject:self.content forKey:@"content"];
}

- (NSString *)thumbUrl
{
    if (_thumb.noProxy) {
        return _thumb.url;
    }
    else {
        return [_thumb.reference toString];
    }
}

- (NSString *)originalUrl
{
    if (_content.noProxy) {
        return _content.url;
    }
    else {
        return [_content.reference toString];
    }
}

- (CGSize)size
{
    CGSize size = CGSizeZero;
    for (id attribute in _content.attributes)
    {
        if ([attribute isKindOfClass:[TGDocumentAttributeImageSize class]])
            size = ((TGDocumentAttributeImageSize *)attribute).size;
        else if ([attribute isKindOfClass:[TGDocumentAttributeVideo class]])
            size = ((TGDocumentAttributeVideo *)attribute).size;
    }
    return size;
}

- (int32_t)duration
{
    int32_t duration = 0;
    for (id attribute in _content.attributes)
    {
        if ([attribute isKindOfClass:[TGDocumentAttributeAudio class]])
            duration = ((TGDocumentAttributeAudio *)attribute).duration;
        else if ([attribute isKindOfClass:[TGDocumentAttributeVideo class]])
            duration = ((TGDocumentAttributeVideo *)attribute).duration;
    }
    return duration;
}

@end
