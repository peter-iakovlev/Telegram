#import "TGGiphySearchResultItem.h"

@implementation TGGiphySearchResultItem

- (instancetype)initWithGifId:(NSString *)gifId gifUrl:(NSString *)gifUrl gifSize:(CGSize)gifSize gifFileSize:(NSUInteger)gifFileSize previewUrl:(NSString *)previewUrl previewSize:(CGSize)previewSize
{
    self = [super init];
    if (self != nil)
    {
        _gifId = gifId;
        _gifUrl = gifUrl;
        _gifSize = gifSize;
        _gifFileSize = gifFileSize;
        _previewUrl = previewUrl;
        _previewSize = previewSize;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    return [self initWithGifId:[aDecoder decodeObjectForKey:@"gifId"] gifUrl:[aDecoder decodeObjectForKey:@"gifUrl"] gifSize:[aDecoder decodeCGSizeForKey:@"gifSize"] gifFileSize:[aDecoder decodeIntegerForKey:@"gifFileSize"] previewUrl:[aDecoder decodeObjectForKey:@"previewUrl"] previewSize:[aDecoder decodeCGSizeForKey:@"previewSize"]];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_gifId == nil ? @"" : _gifId forKey:@"gifId"];
    [aCoder encodeObject:_gifUrl == nil ? @"" : _gifUrl forKey:@"gifUrl"];
    [aCoder encodeCGSize:_gifSize forKey:@"gifSize"];
    [aCoder encodeInteger:_gifFileSize forKey:@"gifFileSize"];
    [aCoder encodeObject:_previewUrl == nil ? @"" : _previewUrl forKey:@"previewUrl"];
    [aCoder encodeCGSize:_previewSize forKey:@"previewSize"];
}

- (BOOL)isEqual:(id)object
{
    return [object isKindOfClass:[TGGiphySearchResultItem class]] && TGStringCompare(_gifId, ((TGGiphySearchResultItem *)object)->_gifId);
}

@end
