#import "TGInternalGifSearchResult.h"

@implementation TGInternalGifSearchResult

- (instancetype)initWithUrl:(NSString *)url document:(TGDocumentMediaAttachment *)document photo:(TGImageMediaAttachment *)photo {
    self = [super init];
    if (self != nil) {
        _url = url;
        _document = document;
        _photo = photo;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    return [self initWithUrl:[aDecoder decodeObjectForKey:@"url"] document:[aDecoder decodeObjectForKey:@"document"] photo:[aDecoder decodeObjectForKey:@"photo"]];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_url forKey:@"url"];
    [aCoder encodeObject:_document forKey:@"document"];
    [aCoder encodeObject:_photo forKey:@"photo"];
}

- (BOOL)isEqual:(id)object
{
    return [object isKindOfClass:[TGInternalGifSearchResult class]] && TGStringCompare(_url, ((TGInternalGifSearchResult *)object)->_url);
}

- (NSUInteger)hash {
    return [_url hash];
}

@end
