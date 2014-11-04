#import "TGBingSearchResultItem.h"

@implementation TGBingSearchResultItem

- (instancetype)initWithImageUrl:(NSString *)imageUrl imageSize:(CGSize)imageSize previewUrl:(NSString *)previewUrl previewSize:(CGSize)previewSize
{
    self = [super init];
    if (self != nil)
    {
        _imageUrl = imageUrl;
        _imageSize = imageSize;
        _previewUrl = previewUrl;
        _previewSize = previewSize;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    return [self initWithImageUrl:[aDecoder decodeObjectForKey:@"imageUrl"] imageSize:[aDecoder decodeCGSizeForKey:@"imageSize"] previewUrl:[aDecoder decodeObjectForKey:@"previewUrl"] previewSize:[aDecoder decodeCGSizeForKey:@"previewSize"]];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_imageUrl == nil ? @"" : _imageUrl forKey:@"imageUrl"];
    [aCoder encodeCGSize:_imageSize forKey:@"imageSize"];
    [aCoder encodeObject:_previewUrl == nil ? @"" : _previewUrl forKey:@"previewUrl"];
    [aCoder encodeCGSize:_previewSize forKey:@"previewSize"];
}

- (BOOL)isEqual:(id)object
{
    return [object isKindOfClass:[TGBingSearchResultItem class]] && TGStringCompare(_imageUrl, ((TGBingSearchResultItem *)object)->_imageUrl) && TGStringCompare(_previewUrl, ((TGBingSearchResultItem *)object)->_previewUrl);
}

@end
