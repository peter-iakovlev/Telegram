#import "TGWebSearchInternalGifResult.h"

@implementation TGWebSearchInternalGifResult

- (instancetype)initWithDocumentId:(int64_t)documentId accessHash:(int64_t)accessHash size:(int32_t)size fileName:(NSString *)fileName mimeType:(NSString *)mimeType thumbnailInfo:(TGImageInfo *)thumbnailInfo
{
    self = [super init];
    if (self != nil)
    {
        _documentId = documentId;
        _accessHash = accessHash;
        _size = size;
        _fileName = fileName;
        _mimeType = mimeType;
        _thumbnailInfo = thumbnailInfo;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    return [self initWithDocumentId:[aDecoder decodeInt64ForKey:@"documentId"] accessHash:[aDecoder decodeInt64ForKey:@"accessHash"] size:[aDecoder decodeInt32ForKey:@"size"] fileName:[aDecoder decodeObjectForKey:@"fileName"] mimeType:[aDecoder decodeObjectForKey:@"mimeType"] thumbnailInfo:[aDecoder decodeObjectForKey:@"thumbnailInfo"]];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInt64:_documentId forKey:@"documentId"];
    [aCoder encodeInt64:_accessHash forKey:@"accessHash"];
    [aCoder encodeInt32:_size forKey:@"size"];
    [aCoder encodeObject:_fileName == nil ? @"" : _fileName forKey:@"fileName"];
    [aCoder encodeObject:_mimeType == nil ? @"" : _mimeType forKey:@"mimeType"];
    if (_thumbnailInfo != nil)
        [aCoder encodeObject:_thumbnailInfo forKey:@"thumbnailInfo"];
}

- (BOOL)isEqual:(id)object
{
    return [object isKindOfClass:[TGWebSearchInternalGifResult class]] && _documentId == ((TGWebSearchInternalGifResult *)object)->_documentId && _accessHash == ((TGWebSearchInternalGifResult *)object)->_accessHash && _size == ((TGWebSearchInternalGifResult *)object)->_size && TGStringCompare(_fileName, ((TGWebSearchInternalGifResult *)object)->_fileName) && TGStringCompare(_mimeType, ((TGWebSearchInternalGifResult *)object)->_mimeType);
}

@end
