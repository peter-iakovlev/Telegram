#import "TGBridgeContext.h"
#import "TGBridgeCommon.h"

NSString *const TGBridgeContextAuthorized = @"authorized";
NSString *const TGBridgeContextUserId = @"userId";
NSString *const TGBridgeContextPasscodeEnabled = @"passcodeEnanled";
NSString *const TGBridgeContextPasscodeEncrypted = @"passcodeEncrypted";
NSString *const TGBridgeContextStartupData = @"startupData";

NSString *const TGBridgeContextStartupDataVersion = @"startupDataVersion";

@implementation TGBridgeContext

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self != nil)
    {
        _authorized = [dictionary[TGBridgeContextAuthorized] boolValue];
        _userId = [dictionary[TGBridgeContextUserId] int32Value];
        _passcodeEnabled = [dictionary[TGBridgeContextPasscodeEnabled] boolValue];
        _passcodeEncrypted = [dictionary[TGBridgeContextPasscodeEncrypted] boolValue];
        if (dictionary[TGBridgeContextStartupData] != nil)
            _startupData = [NSKeyedUnarchiver unarchiveObjectWithData:dictionary[TGBridgeContextStartupData]];
    }
    return self;
}

- (void)setStartupData:(NSDictionary *)startupData version:(int32_t)version
{
    if (startupData != nil)
    {
        NSMutableDictionary *dict = [startupData mutableCopy];
        dict[TGBridgeContextStartupDataVersion] = @(version);
        _startupData = dict;
        
        return;
    }
    
    _startupData = startupData;
}

- (NSInteger)startupDataVersion
{
    if (_startupData == nil)
        return 0;
    
    return [_startupData[TGBridgeContextStartupDataVersion] integerValue];
}

- (NSDictionary *)encodeWithStartupData:(bool)withStartupData
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    dictionary[TGBridgeContextAuthorized] = @(self.authorized);
    dictionary[TGBridgeContextUserId] = @(self.userId);
    dictionary[TGBridgeContextPasscodeEnabled] = @(self.passcodeEnabled);
    dictionary[TGBridgeContextPasscodeEncrypted] = @(self.passcodeEncrypted);
    
    if (withStartupData && self.startupData != nil)
        dictionary[TGBridgeContextStartupData] = [NSKeyedArchiver archivedDataWithRootObject:self.startupData];
    
    return dictionary;
}

- (BOOL)isEqual:(id)object
{
    if (object == self)
        return true;
    
    if (!object || ![object isKindOfClass:[self class]])
        return false;
    
    TGBridgeContext *context = (TGBridgeContext *)object;
    if (context.authorized != self.authorized)
        return false;
    if (context.userId != self.userId)
        return false;
    if (context.passcodeEnabled != self.passcodeEnabled)
        return false;
    if (context.passcodeEncrypted != self.passcodeEncrypted)
        return false;
    
    return true;
}

+ (int32_t)versionWithCurrentDate
{
    return (int32_t)[NSDate date].timeIntervalSinceReferenceDate;
}

@end
