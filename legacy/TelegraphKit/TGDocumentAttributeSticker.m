#import "TGDocumentAttributeSticker.h"

#import "PSKeyValueCoder.h"

@implementation TGDocumentAttributeSticker

- (instancetype)initWithAlt:(NSString *)alt packReference:(id<TGStickerPackReference>)packReference
{
    self = [super init];
    if (self != nil)
    {
        _alt = alt;
        _packReference = packReference;
    }
    return self;
}

- (instancetype)initWithKeyValueCoder:(PSKeyValueCoder *)coder
{
    return [self initWithAlt:[coder decodeStringForCKey:"alt"] packReference:(id<TGStickerPackReference>)[coder decodeObjectForCKey:"packReference"]];
}

- (void)encodeWithKeyValueCoder:(PSKeyValueCoder *)coder
{
    [coder encodeString:_alt forCKey:"alt"];
    [coder encodeObject:_packReference forCKey:"packReference"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    return [self initWithAlt:[aDecoder decodeObjectForKey:@"alt"] packReference:[aDecoder decodeObjectForKey:@"packReference"]];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    if (_alt != nil)
        [aCoder encodeObject:_alt forKey:@"alt"];
    if (_packReference != nil)
        [aCoder encodeObject:_packReference forKey:@"packReference"];
}

- (BOOL)isEqual:(id)object
{
    return [object isKindOfClass:[TGDocumentAttributeSticker class]];
}

@end
