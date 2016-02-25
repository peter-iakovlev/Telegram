#import "TGTemporaryFileDownloadActor.h"

#import "TGModernCache.h"

#import "TGTelegraph.h"
#import "ActionStage.h"

@interface TGTemporaryFileDownloadActor () <TGRawHttpActor>
{
    TGModernCache *_cache;
    NSString *_url;
    NSString *_path;
    NSNumber *_size;
    NSString *_httpAuth;
    bool _returnPath;
}

@end

@implementation TGTemporaryFileDownloadActor

+ (void)load
{
    [ASActor registerActorClass:self];
}

+ (NSString *)genericPath
{
    return @"/temporaryDownload/@";
}

- (void)prepare:(NSDictionary *)options
{
    [super prepare:options];
    
    if (options[@"queue"] != nil)
        self.requestQueueName = options[@"queue"];
}

- (void)execute:(NSDictionary *)options
{
    _cache = options[@"cache"];
    _url = options[@"url"];
    _path = options[@"path"];
    _size = options[@"size"];
    _httpAuth = options[@"httpAuth"];
    _returnPath = [options[@"returnPath"] boolValue];
    
    self.cancelToken = [TGTelegraphInstance doRequestRawHttp:_url maxRetryCount:0 acceptCodes:@[@200] httpAuth:_httpAuth expectedFileSize:_size != nil ? _size.integerValue : -1 actor:self];
}

- (void)httpRequestSuccess:(NSString *)__unused url response:(NSData *)response
{
    if (_cache)
        [_cache setValue:response forKey:[_url dataUsingEncoding:NSUTF8StringEncoding]];
    if (_path.length != 0)
        [response writeToFile:_path atomically:true];
    
    if (_returnPath) {
        if (_path.length != 0) {
            [ActionStageInstance() actionCompleted:self.path result:_path];
        } else if (_cache != nil) {
            [_cache getValuePathForKey:[_url dataUsingEncoding:NSUTF8StringEncoding] completion:^(NSString *path) {
                [ActionStageInstance() actionCompleted:self.path result:path];
            }];
        } else {
            [ActionStageInstance() actionFailed:self.path reason:-1];
        }
    } else {
        [ActionStageInstance() actionCompleted:self.path result:response];
    }
}

- (void)httpRequestFailed:(NSString *)__unused url
{
    [ActionStageInstance() actionFailed:self.path reason:-1];
}

- (void)httpRequestProgress:(NSString *)__unused url progress:(float)progress
{
    [ActionStageInstance() dispatchMessageToWatchers:self.path messageType:@"progress" message:@(progress)];
}

@end
