#import "TGTemporaryFileDownloadActor.h"

#import <LegacyComponents/TGModernCache.h>

#import "TGTelegraph.h"
#import <LegacyComponents/ActionStage.h>

#import "TGRemoteFileSignal.h"
#import "TGSharedMediaSignals.h"

@interface TGTemporaryFileDownloadActor () <TGRawHttpActor>
{
    TGModernCache *_cache;
    NSString *_url;
    NSString *_path;
    NSNumber *_size;
    NSDictionary *_httpHeaders;
    bool _returnPath;
    id<SDisposable> _downloadDisposable;
}

@end

@implementation TGTemporaryFileDownloadActor

+ (void)load
{
    [ASActor registerActorClass:self];
}

- (void)dealloc {
    [_downloadDisposable dispose];
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
    _httpHeaders = options[@"httpHeaders"];
    _returnPath = [options[@"returnPath"] boolValue];
    
    if (_url.length != 0)
    {
        if ([_url hasPrefix:@"webdoc"])
        {
            int32_t webFileDatacenterId = 0;
            NSData *data = [TGDatabaseInstance() customProperty:@"webFileDatacenterId"];
            if (data.length == 4)
                [data getBytes:&webFileDatacenterId length:4];
            
            __weak TGTemporaryFileDownloadActor *weakSelf = self;
            TGNetworkMediaTypeTag mediaTypeTag = (TGNetworkMediaTypeTag)([options[@"mediaTypeTag"] intValue]);
            NSInteger datacenterId = 0;
            TLInputWebFileLocation *webLocation = [TGSharedMediaSignals inputWebFileLocationForImageUrl:_url datacenterId:&datacenterId];
            if (datacenterId == -1)
                datacenterId = webFileDatacenterId;
            _downloadDisposable = [[TGRemoteFileSignal dataForWebLocation:webLocation datacenterId:datacenterId size:[options[@"size"] intValue] reportProgress:true mediaTypeTag:mediaTypeTag] startWithNext:^(id next) {
                __strong TGTemporaryFileDownloadActor *strongSelf = weakSelf;
                if (strongSelf != nil) {
                    if ([next respondsToSelector:@selector(floatValue)]) {
                        [ActionStageInstance() dispatchMessageToWatchers:strongSelf.path messageType:@"progress" message:next];
                    } else {
                        if (strongSelf->_cache)
                            [strongSelf->_cache setValue:next forKey:[strongSelf->_url dataUsingEncoding:NSUTF8StringEncoding]];
                        if (strongSelf->_path.length != 0)
                            [next writeToFile:strongSelf->_path atomically:true];
                        
                        if (strongSelf->_returnPath) {
                            if (strongSelf->_path.length != 0) {
                                [ActionStageInstance() actionCompleted:strongSelf.path result:strongSelf->_path];
                            } else if (strongSelf->_cache != nil) {
                                [strongSelf->_cache getValuePathForKey:[strongSelf->_url dataUsingEncoding:NSUTF8StringEncoding] completion:^(NSString *path) {
                                    [ActionStageInstance() actionCompleted:strongSelf.path result:path];
                                }];
                            } else {
                                [ActionStageInstance() actionFailed:strongSelf.path reason:-1];
                            }
                        } else {
                            [ActionStageInstance() actionCompleted:strongSelf.path result:next];
                        }
                    }
                }
            } error:^(__unused id error) {
                __strong TGTemporaryFileDownloadActor *strongSelf = weakSelf;
                if (strongSelf != nil) {
                    [ActionStageInstance() actionFailed:strongSelf.path reason:-1];
                }
            } completed:^{
                
            }];
        }
        else
        {
            self.cancelToken = [TGTelegraphInstance doRequestRawHttp:_url maxRetryCount:0 acceptCodes:@[@200] httpHeaders:_httpHeaders expectedFileSize:_size != nil ? _size.integerValue : -1 actor:self];
        }
    }
    else if (_cache != nil && options[@"cacheKey"] != nil && options[@"inputLocation"] != nil && options[@"datacenterId"] != nil && options[@"size"] != nil)
    {
        __weak TGTemporaryFileDownloadActor *weakSelf = self;
        TGNetworkMediaTypeTag mediaTypeTag = (TGNetworkMediaTypeTag)([options[@"mediaTypeTag"] intValue]);
        _downloadDisposable = [[TGRemoteFileSignal dataForLocation:options[@"inputLocation"] datacenterId:[options[@"datacenterId"] integerValue] size:[options[@"size"] intValue] reportProgress:true mediaTypeTag:mediaTypeTag] startWithNext:^(id next) {
            __strong TGTemporaryFileDownloadActor *strongSelf = weakSelf;
            if (strongSelf != nil) {
                if ([next respondsToSelector:@selector(floatValue)]) {
                    [ActionStageInstance() dispatchMessageToWatchers:strongSelf.path messageType:@"progress" message:next];
                } else {
                    if (strongSelf->_cache) {
                        [strongSelf->_cache setValue:next forKey:options[@"cacheKey"]];
                    }
                    if (strongSelf->_returnPath) {
                        [strongSelf->_cache getValuePathForKey:options[@"cacheKey"] completion:^(NSString *path) {
                            [ActionStageInstance() actionCompleted:strongSelf.path result:path];
                        }];
                    } else {
                        [ActionStageInstance() actionCompleted:strongSelf.path result:next];
                    }
                }
            }
        } error:^(__unused id error) {
            __strong TGTemporaryFileDownloadActor *strongSelf = weakSelf;
            if (strongSelf != nil) {
                [ActionStageInstance() actionFailed:strongSelf.path reason:-1];
            }
        } completed:^{
            
        }];
    } else {
        [ActionStageInstance() actionFailed:self.path reason:-1];
    }
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
