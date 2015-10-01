#import "TGBridgeBotInfo.h"

NSString *const TGBridgeBotInfoVersionKey = @"version";
NSString *const TGBridgeBotInfoUserIdKey = @"userId";
NSString *const TGBridgeBotInfoShortDescriptionKey = @"shortDescription";
NSString *const TGBridgeBotInfoBotDescriptionKey = @"botDescription";
NSString *const TGBridgeBotInfoCommandListKey = @"commandList";

@implementation TGBridgeBotInfo

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self != nil)
    {
        _version = [aDecoder decodeInt32ForKey:TGBridgeBotInfoVersionKey];
        _userId = [aDecoder decodeInt32ForKey:TGBridgeBotInfoUserIdKey];
        _shortDescription = [aDecoder decodeObjectForKey:TGBridgeBotInfoShortDescriptionKey];
        _botDescription = [aDecoder decodeObjectForKey:TGBridgeBotInfoBotDescriptionKey];
        _commandList = [aDecoder decodeObjectForKey:TGBridgeBotInfoCommandListKey];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInt32:self.version forKey:TGBridgeBotInfoVersionKey];
    [aCoder encodeInt32:self.userId forKey:TGBridgeBotInfoUserIdKey];
    [aCoder encodeObject:self.shortDescription forKey:TGBridgeBotInfoShortDescriptionKey];
    [aCoder encodeObject:self.botDescription forKey:TGBridgeBotInfoBotDescriptionKey];
    [aCoder encodeObject:self.commandList forKey:TGBridgeBotInfoCommandListKey];
}

@end
