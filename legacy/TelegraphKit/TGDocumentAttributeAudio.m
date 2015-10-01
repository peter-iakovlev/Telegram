#import "TGDocumentAttributeAudio.h"

#import "PSKeyValueCoder.h"

@implementation TGDocumentAttributeAudio

- (instancetype)initWithTitle:(NSString *)title performer:(NSString *)performer duration:(int32_t)duration
{
    self = [super init];
    if (self != nil)
    {
        _title = title;
        _performer = performer;
        _duration = duration;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    return [self initWithTitle:[aDecoder decodeObjectForKey:@"title"] performer:[aDecoder decodeObjectForKey:@"performer"] duration:[aDecoder decodeInt32ForKey:@"duration"]];
}

- (instancetype)initWithKeyValueCoder:(PSKeyValueCoder *)coder
{
    return [self initWithTitle:[coder decodeStringForCKey:"title"] performer:[coder decodeStringForCKey:"performer"] duration:[coder decodeInt32ForCKey:"duration"]];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_title forKey:@"title"];
    [aCoder encodeObject:_performer forKey:@"performer"];
    [aCoder encodeInt32:_duration forKey:@"duration"];
}

- (void)encodeWithKeyValueCoder:(PSKeyValueCoder *)coder
{
    [coder encodeString:_title forCKey:"title"];
    [coder encodeString:_performer forCKey:"performer"];
    [coder encodeInt32:_duration forCKey:"duration"];
}

- (BOOL)isEqual:(id)object
{
    return [object isKindOfClass:[TGDocumentAttributeAudio class]] && TGStringCompare(((TGDocumentAttributeAudio *)object)->_title, _title) && TGStringCompare(((TGDocumentAttributeAudio *)object)->_performer, _performer) && ((TGDocumentAttributeAudio *)object)->_duration == _duration;
}

@end
