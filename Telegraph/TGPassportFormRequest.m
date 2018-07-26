#import "TGPassportFormRequest.h"

@implementation TGPassportFormRequest

- (instancetype)initWithBotId:(int32_t)botId scope:(NSString *)scope publicKey:(NSString *)publicKey bundleId:(NSString *)bundleId callbackUrl:(NSString *)callbackUrl payload:(NSString *)payload
{
    self = [super init];
    if (self != nil)
    {
        _botId = botId;
        _publicKey = publicKey;
        _bundleId = bundleId;
        _callbackUrl = callbackUrl;
        
        _scope = scope;
        NSArray *scopeComponents = [scope componentsSeparatedByString:@","];
        NSMutableArray *finalScope = [[NSMutableArray alloc] init];
        for (NSString *component in scopeComponents)
        {
            NSString *trimmedComponent = [component stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            [finalScope addObject:trimmedComponent];
        }
        _scopeValues = finalScope;
        
        _payload = payload;
    }
    return self;
}

- (NSString *)origin
{
    if (_callbackUrl.length == 0)
        return nil;
    
    NSURL *url = [NSURL URLWithString:_callbackUrl];
    NSString *host = url.host;
    NSString *scheme = url.scheme;
    if (scheme.length == 0)
        scheme = @"https";
    return [NSString stringWithFormat:@"%@://%@", scheme, host];
}

@end
