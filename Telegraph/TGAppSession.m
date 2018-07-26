#import "TGAppSession.h"

@implementation TGAppSession

- (instancetype)initWithSessionHash:(int64_t)sessionHash bot:(TGUser *)bot domain:(NSString *)domain browser:(NSString *)browser platform:(NSString *)platform dateCreated:(int32_t)dateCreated dateActive:(int32_t)dateActive ip:(NSString *)ip country:(NSString *)country region:(NSString *)region
{
    self = [super init];
    if (self != nil)
    {
        _sessionHash = sessionHash;
        _bot = bot;
        _domain = domain;
        _browser = browser;
        _platform = platform;
        _dateCreated = dateCreated;
        _dateActive = dateActive;
        _ip = ip;
        _country = country;
        _region = region;
    }
    return self;
}

@end
