#import "TGApplicationFeatureDescription.h"

@implementation TGApplicationFeatureDescription

- (instancetype)initWithIdentifier:(NSString *)identifier enabled:(bool)enabled disabledMessage:(NSString *)disabledMessage
{
    self = [super init];
    if (self != nil)
    {
        _identifier = identifier;
        _enabled = enabled;
        _disabledMessage = disabledMessage;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    return [self initWithIdentifier:[aDecoder decodeObjectForKey:@"identifier"] enabled:[aDecoder decodeBoolForKey:@"enabled"] disabledMessage:[aDecoder decodeObjectForKey:@"disabledMessage"]];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_identifier forKey:@"identifier"];
    [aCoder encodeBool:_enabled forKey:@"enabled"];
    [aCoder encodeObject:_disabledMessage forKey:@"disabledMessage"];
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(TGApplicationFeatureDescription %@ enabled: %@ disabledMessage: %@)", _identifier, _enabled ? @"true" : @"false", _disabledMessage];
}

@end
