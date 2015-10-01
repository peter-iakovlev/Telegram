#import "TGDropboxHelper.h"

#import "TGDropboxItem.h"

NSString *const TGDropboxFilesReceivedNotification = @"TGDropboxFilesReceivedNotification";

NSString *const TGDropboxProtocol = @"dbapi-3";
NSString *const TGDropboxApiVersion = @"1";
NSString *const TGDropboxAppKey = @"pa9wtoz9l514anx";

@implementation TGDropboxHelper

+ (void)openExternalPicker
{
    NSString *baseURL = [NSString stringWithFormat:@"%@://%@/chooser", TGDropboxProtocol, TGDropboxApiVersion];
    
    NSURL *externalURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@?k=%@&linkType=direct", baseURL, TGDropboxAppKey]];
    [[UIApplication sharedApplication] openURL:externalURL];
}

+ (void)handleOpenURL:(NSURL *)url
{
    NSArray *components = url.path.pathComponents;
    NSString *methodName = components.count > 1 ? components[1] : nil;
    if ([methodName isEqual:@"chooser"])
    {
        NSDictionary *params = [self _dictionaryFromQueryString:url.query];
        NSArray *files = [self _parseFilesJson:params[@"files"]];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:TGDropboxFilesReceivedNotification object:files];
    }
}

+ (NSArray *)_parseFilesJson:(NSString *)filesJson
{
    if (filesJson.length > 0)
    {
        NSArray *filesJsonDict = [NSJSONSerialization JSONObjectWithData:[filesJson dataUsingEncoding:NSUTF8StringEncoding]
                                                                 options:0
                                                                   error:nil];
        
        NSMutableArray *results = [NSMutableArray arrayWithCapacity:filesJsonDict.count];
        for (NSDictionary *dictionary in filesJsonDict)
        {
            TGDropboxItem *item = [TGDropboxItem dropboxItemWithDictionary:dictionary];
            [results addObject:item];
        }
        return results;
    }

    return nil;
}

+ (NSDictionary *)_dictionaryFromQueryString:(NSString*)queryString
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    for (NSString *pair in [queryString componentsSeparatedByString:@"&"])
    {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        if ([kv count] == 2)
            params[kv[0]] = [kv[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    return params;
}

+ (NSString *)dropboxURLScheme
{
    return [NSString stringWithFormat:@"db-%@", TGDropboxAppKey];
}

+ (bool)isDropboxInstalled
{
    return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@://", TGDropboxProtocol]]];
}

@end
