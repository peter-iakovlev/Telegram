#import "TGExternalImageSearchResult.h"

@implementation TGExternalImageSearchResult

- (instancetype)initWithUrl:(NSString *)url originalUrl:(NSString *)originalUrl thumbnailUrl:(NSString *)thumbnailUrl title:(NSString *)title size:(CGSize)size {
    self = [super init];
    if (self != nil) {
        _url = url;
        _originalUrl = originalUrl;
        _thumbnailUrl = thumbnailUrl;
        _title = title;
        _size = size;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    return [self initWithUrl:[aDecoder decodeObjectForKey:@"url"] originalUrl:[aDecoder decodeObjectForKey:@"originalUrl"] thumbnailUrl:[aDecoder decodeObjectForKey:@"thumbnailUrl"] title:[aDecoder decodeObjectForKey:@"title"] size:[aDecoder decodeCGSizeForKey:@"size"]];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_url forKey:@"url"];
    [aCoder encodeObject:_originalUrl forKey:@"originalUrl"];
    [aCoder encodeObject:_thumbnailUrl forKey:@"thumbnailUrl"];
    [aCoder encodeObject:_title forKey:@"title"];
    [aCoder encodeCGSize:_size forKey:@"size"];
}

- (BOOL)isEqual:(id)object
{
    return [object isKindOfClass:[TGExternalImageSearchResult class]] && TGStringCompare(_url, ((TGExternalImageSearchResult *)object)->_url);
}

- (NSUInteger)hash {
    return [_url hash];
}

@end
