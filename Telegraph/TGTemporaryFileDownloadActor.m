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
    
    self.cancelToken = [TGTelegraphInstance doRequestRawHttp:_url maxRetryCount:0 acceptCodes:@[@200] httpAuth:_httpAuth expectedFileSize:_size != nil ? _size.integerValue : -1 actor:self];
}

- (void)httpRequestSuccess:(NSString *)__unused url response:(NSData *)response
{
    if (_cache)
        [_cache setValue:response forKey:[_url dataUsingEncoding:NSUTF8StringEncoding]];
    if (_path.length != 0)
        [response writeToFile:_path atomically:false];
    
    [ActionStageInstance() actionCompleted:self.path result:response];
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
