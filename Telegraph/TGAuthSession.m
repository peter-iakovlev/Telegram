#import "TGAuthSession.h"

@implementation TGAuthSession

- (instancetype)initWithSessionHash:(int64_t)sessionHash flags:(int32_t)flags deviceModel:(NSString *)deviceModel platform:(NSString *)platform systemVersion:(NSString *)systemVersion apiId:(int32_t)apiId appName:(NSString *)appName appVersion:(NSString *)appVersion dateCreated:(int32_t)dateCreated dateActive:(int32_t)dateActive ip:(NSString *)ip country:(NSString *)country region:(NSString *)region
{
    self = [super init];
    if (self != nil)
    {
        _sessionHash = sessionHash;
        _flags = flags;
        _deviceModel = deviceModel;
        _platform = platform;
        _systemVersion = systemVersion;
        _apiId = apiId;
        _appName = appName;
        _appVersion = appVersion;
        _dateCreated = dateCreated;
        _dateActive = dateActive;
        _ip = ip;
        _country = country;
        _region = region;
    }
    return self;
}

@end
