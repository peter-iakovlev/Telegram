#import "TGStickerPack.h"

#import "PSKeyValueCoder.h"

@implementation TGStickerPack

- (instancetype)initWithPackReference:(id<TGStickerPackReference>)packReference title:(NSString *)title stickerAssociations:(NSArray *)stickerAssociations documents:(NSArray *)documents packHash:(int32_t)packHash
{
    self = [super init];
    if (self != nil)
    {
        _packReference = packReference;
        _title = title;
        _stickerAssociations = stickerAssociations;
        _documents = documents;
        _packHash = packHash;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    return [self initWithPackReference:[aDecoder decodeObjectForKey:@"packReference"] title:[aDecoder decodeObjectForKey:@"title"] stickerAssociations:[aDecoder decodeObjectForKey:@"stickerAssociations"] documents:[aDecoder decodeObjectForKey:@"documents"] packHash:[aDecoder decodeInt32ForKey:@"packHash"]];
}

- (instancetype)initWithKeyValueCoder:(PSKeyValueCoder *)coder
{
    return [self initWithPackReference:(id<TGStickerPackReference>)[coder decodeObjectForCKey:"r"] title:[coder decodeStringForCKey:"t"] stickerAssociations:[coder decodeArrayForCKey:"a"] documents:[coder decodeArrayForCKey:"d"] packHash:[coder decodeInt32ForCKey:"ph"]];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_packReference forKey:@"packReference"];
    [aCoder encodeObject:_title forKey:@"title"];
    [aCoder encodeObject:_stickerAssociations forKey:@"stickerAssociations"];
    [aCoder encodeObject:_documents forKey:@"documents"];
    [aCoder encodeInt32:_packHash forKey:@"packHash"];
}

- (void)encodeWithKeyValueCoder:(PSKeyValueCoder *)coder
{
    [coder encodeObject:_packReference forKey:@"r"];
    [coder encodeString:_title forCKey:"t"];
    [coder encodeArray:_stickerAssociations forCKey:"a"];
    [coder encodeArray:_documents forCKey:"d"];
    [coder encodeInt32:_packHash forCKey:"ph"];
}

- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:[TGStickerPack class]])
        return false;
    
    TGStickerPack *other = object;
    
    if (![other->_packReference isEqual:_packReference])
        return false;
    
    if (![other->_stickerAssociations isEqual:_stickerAssociations])
        return false;
    
    if (![other->_documents isEqual:_documents])
        return false;
    
    if (other->_packHash != _packHash)
        return false;
    
    return true;
}

@end
