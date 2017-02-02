#import "TGWidgetUser.h"

NSString *const TGWidgetUserIdentifierKey = @"identifier";
NSString *const TGWidgetUserFirstNameKey = @"firstName";
NSString *const TGWidgetUserLastNameKey = @"lastName";
NSString *const TGWidgetUserAvatarPathKey = @"avatarPath";

@implementation TGWidgetUser

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self != nil)
    {
        _identifier = [aDecoder decodeInt32ForKey:TGWidgetUserIdentifierKey];
        _firstName = [aDecoder decodeObjectForKey:TGWidgetUserFirstNameKey];
        _lastName = [aDecoder decodeObjectForKey:TGWidgetUserLastNameKey];
        _avatarPath = [aDecoder decodeObjectForKey:TGWidgetUserAvatarPathKey];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInt32:self.identifier forKey:TGWidgetUserIdentifierKey];
    [aCoder encodeObject:self.firstName forKey:TGWidgetUserFirstNameKey];
    [aCoder encodeObject:self.lastName forKey:TGWidgetUserLastNameKey];
    [aCoder encodeObject:self.avatarPath forKey:TGWidgetUserAvatarPathKey];
}

- (NSString *)initials
{
    return [TGWidgetUser initialsForFirstName:self.firstName lastName:self.lastName];
}

static bool isEmojiCharacter(NSString *singleChar)
{
    const unichar high = [singleChar characterAtIndex:0];
    
    if (0xd800 <= high && high <= 0xdbff && singleChar.length >= 2)
    {
        const unichar low = [singleChar characterAtIndex:1];
        const int codepoint = ((high - 0xd800) * 0x400) + (low - 0xdc00) + 0x10000;
        
        return (0x1d000 <= codepoint && codepoint <= 0x1f77f);
    }
    
    return (0x2100 <= high && high <= 0x27bf);
}

+ (NSString *)_cleanedUpString:(NSString *)string
{
    NSMutableString *__block buffer = [NSMutableString stringWithCapacity:string.length];
    
    [string enumerateSubstringsInRange:NSMakeRange(0, string.length)
                               options:NSStringEnumerationByComposedCharacterSequences
                            usingBlock: ^(NSString* substring, __unused NSRange substringRange, __unused NSRange enclosingRange, __unused BOOL* stop)
    {
        [buffer appendString:isEmojiCharacter(substring) ? @"" : substring];
    }];
    
    return buffer;
}

+ (NSString *)initialsForFirstName:(NSString *)firstName lastName:(NSString *)lastName
{
    NSString *initials = @"";
    
    NSString *cleanFirstName = [self _cleanedUpString:firstName];
    NSString *cleanLastName = [self _cleanedUpString:lastName];
    
    if (cleanFirstName.length != 0 && cleanLastName.length != 0)
        initials = [[NSString alloc] initWithFormat:@"%@\u200B%@", [cleanFirstName substringToIndex:1], [cleanLastName substringToIndex:1]];
    else if (cleanFirstName.length != 0)
        initials = [cleanFirstName substringToIndex:1];
    else if (cleanLastName.length != 0)
        initials = [cleanLastName substringToIndex:1];
    
    return [initials uppercaseString];
}

@end
