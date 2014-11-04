#import "TGWebSearchInternalImageResult.h"

#import "TGImageInfo.h"

@implementation TGWebSearchInternalImageResult

- (instancetype)initWithImageId:(int64_t)imageId accessHash:(int64_t)accessHash imageInfo:(TGImageInfo *)imageInfo
{
    self = [super init];
    if (self != nil)
    {
        _imageId = imageId;
        _accessHash = accessHash;
        _imageInfo = imageInfo;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    return [self initWithImageId:[aDecoder decodeInt64ForKey:@"imageId"] accessHash:[aDecoder decodeInt64ForKey:@"accessHash"] imageInfo:[aDecoder decodeObjectForKey:@"imageInfo"]];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInt64:_imageId forKey:@"imageId"];
    [aCoder encodeInt64:_accessHash forKey:@"accessHash"];
    [aCoder encodeObject:_imageInfo forKey:@"imageInfo"];
}

- (BOOL)isEqual:(id)object
{
    return [object isKindOfClass:[TGWebSearchInternalImageResult class]] && _imageId == ((TGWebSearchInternalImageResult *)object)->_imageId && _accessHash == ((TGWebSearchInternalImageResult *)object)->_accessHash && TGObjectCompare(_imageInfo, ((TGWebSearchInternalImageResult *)object)->_imageInfo);
}

@end
