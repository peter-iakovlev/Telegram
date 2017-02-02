#import "MediaBox.h"

#import <sys/stat.h>

#import "MediaResource.h"
#import "MediaBoxContexts.h"

static int32_t fileSize(NSString *path) {
    struct stat value;
    if (stat(path.UTF8String, &value) == 0) {
        return (int32_t)value.st_size;
    } else {
        return 0;
    }
}

@interface MediaBox () {
    NSString * _Nonnull _basePath;
    
    SQueue * _Nonnull _statusQueue;
    SQueue * _Nonnull _concurrentQueue;
    SQueue * _Nonnull _dataQueue;
    SQueue * _Nonnull _cacheQueue;
    
    NSMutableDictionary<id<MediaResourceId>, ResourceStatusContext *> * _Nonnull _statusContexts;
    NSMutableDictionary<id<MediaResourceId>, ResourceDataContext *> * _Nonnull _dataContexts;
    
    SVariable * _Nonnull _wrappedFetchResource;
}

@end

@implementation MediaBox

- (_Nonnull instancetype)initWithBasePath:(NSString * _Nonnull)basePath {
    self = [super init];
    if (self != nil) {
        TGLog(@"MediaBox path %@", basePath);
        _basePath = basePath;
        _statusQueue = [[SQueue alloc] init];
        _concurrentQueue = [SQueue concurrentDefaultQueue];
        _dataQueue = [[SQueue alloc] init];
        _cacheQueue = [[SQueue alloc] init];
        _statusContexts = [[NSMutableDictionary alloc] init];
        _dataContexts = [[NSMutableDictionary alloc] init];
        _wrappedFetchResource = [[SVariable alloc] init];
        
        [[NSFileManager defaultManager] createDirectoryAtPath:_basePath withIntermediateDirectories:true attributes:nil error:nil];
        [[NSFileManager defaultManager] createDirectoryAtPath:[_basePath stringByAppendingPathComponent:@"cache"] withIntermediateDirectories:true attributes:nil error:nil];
        
        
    }
    return self;
}

- (SSignal *)wrappedFetchResource:(id<MediaResource>)resource range:(NSRange)range {
    return [[[_wrappedFetchResource signal] take:1] mapToSignal:^SSignal *(SSignal *(^fetch)(id<MediaResource>, NSRange)) {
        return fetch(resource, range);
    }];
}

- (void)setFetchResource:(SSignal *(^)(id<MediaResource>, NSRange))fetchResource {
    [_wrappedFetchResource set:[SSignal single:[fetchResource copy]]];
}

- (NSString * _Nonnull)fileNameForId:(id<MediaResourceId>)resourceId {
    return [resourceId uniqueId];
}

- (ResourceStorePaths * _Nonnull)storePathsForId:(id<MediaResourceId>)resourceId {
    return [[ResourceStorePaths alloc] initWithPartial:[[_basePath stringByAppendingPathComponent:[self fileNameForId:resourceId]] stringByAppendingString:@"_partial"] complete:[_basePath stringByAppendingPathComponent:[self fileNameForId:resourceId]]];
}

- (SSignal *)resourceStatus:(id<MediaResource>)resource {
    return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber) {
        SMetaDisposable *disposable = [[SMetaDisposable alloc] init];
        
        [self->_concurrentQueue dispatch:^{
            id<MediaResourceId> resourceId = [resource resourceId];
            ResourceStorePaths *paths = [self storePathsForId:resourceId];
            if (fileSize(paths.complete) != 0) {
                [subscriber putNext:[[MediaResourceStatus alloc] initWithStatus:MediaResourceStatusLocal progress:1.0]];
                [subscriber putCompletion];
            } else {
                [self->_statusQueue dispatch:^{
                    ResourceStatusContext *statusContext = nil;
                    
                    ResourceStatusContext *currentStatusContext = self->_statusContexts[resourceId];
                    if (currentStatusContext != nil) {
                        statusContext = currentStatusContext;
                    } else {
                        statusContext = [[ResourceStatusContext alloc] init];
                        self->_statusContexts[resourceId] = statusContext;
                    }
                    
                    void (^subscriberItem)(MediaResourceStatus *) = ^(MediaResourceStatus *status) {
                        [subscriber putNext:status];
                        if (status.status == MediaResourceStatusLocal) {
                            [subscriber putCompletion];
                        }
                    };
                    NSInteger index = [statusContext.subscribers addItem:[subscriberItem copy]];
                    
                    if (statusContext.status != nil) {
                        [subscriber putNext:statusContext.status];
                    } else {
                        [self->_dataQueue dispatch:^{
                            MediaResourceStatus *status = nil;
                            int32_t currentSize = fileSize(paths.complete);
                            if (currentSize != 0) {
                                status = [[MediaResourceStatus alloc] initWithStatus:MediaResourceStatusLocal progress:1.0f];
                            } else {
                                bool fetchingData = false;
                                ResourceDataContext *dataContext = self->_dataContexts[resourceId];
                                if (dataContext != nil && dataContext.fetchDisposable != nil) {
                                    fetchingData = true;
                                }
                                
                                if (fetchingData) {
                                    float progress = 0.0f;
                                    if ([resource size] != nil) {
                                        int32_t resourceSize = [[resource size] intValue];
                                        if (resourceSize != 0) {
                                            progress = ((float)currentSize) / ((float)resourceSize);
                                        }
                                    }
                                    status = [[MediaResourceStatus alloc] initWithStatus:MediaResourceStatusFetching progress:progress];
                                } else {
                                    status = [[MediaResourceStatus alloc] initWithStatus:MediaResourceStatusRemote progress:0.0f];
                                }
                            }
                            
                            [self->_statusQueue dispatch:^{
                                ResourceStatusContext *statusContext = self->_statusContexts[resourceId];
                                if (statusContext != nil && statusContext.status == nil) {
                                    statusContext.status = status;
                                    for (void (^subscriberItem)(MediaResourceStatus *) in [statusContext.subscribers copyItems]) {
                                        subscriberItem(status);
                                    }
                                }
                            }];
                        }];
                    }
                    
                    [disposable setDisposable:[[SBlockDisposable alloc] initWithBlock:^{
                        [self->_statusQueue dispatch:^{
                            ResourceStatusContext *statusContext = self->_statusContexts[resourceId];
                            if (statusContext != nil) {
                                [statusContext.subscribers removeItem:index];
                                if ([statusContext.subscribers isEmpty]) {
                                    [self->_statusContexts removeObjectForKey:resourceId];
                                }
                            }
                        }];
                    }]];
                }];
            }
        }];
        
        return disposable;
    }];
}

- (SSignal *)resourceData:(id<MediaResource> _Nonnull)resource pathExtension:(NSString * _Nullable)pathExtension {
    return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber) {
        SMetaDisposable *disposable = [[SMetaDisposable alloc] init];
        
        [self->_concurrentQueue dispatch:^{
            id<MediaResourceId> resourceId = [resource resourceId];
            ResourceStorePaths *paths = [self storePathsForId:resourceId];
            int32_t completeSize = fileSize(paths.complete);
            if (completeSize != 0) {
                if (pathExtension != nil) {
                    NSString *symlinkPath = [paths.complete stringByAppendingFormat:@".%@", pathExtension];
                    [[NSFileManager defaultManager] createSymbolicLinkAtPath:symlinkPath withDestinationPath:[paths.complete lastPathComponent] error:nil];
                    [subscriber putNext:[[ResourceData alloc] initWithPath:symlinkPath size:completeSize complete:true]];
                    [subscriber putCompletion];
                } else {
                    [subscriber putNext:[[ResourceData alloc] initWithPath:paths.complete size:completeSize complete:true]];
                    [subscriber putCompletion];
                }
            } else {
                [self->_dataQueue dispatch:^{
                    ResourceDataContext *currentContext = self->_dataContexts[resourceId];
                    int32_t completeSize = 0;
                    if (currentContext != nil && currentContext.data.complete) {
                        if (pathExtension != nil) {
                            NSString *symlinkPath = [paths.complete stringByAppendingFormat:@".%@", pathExtension];
                            [[NSFileManager defaultManager] createSymbolicLinkAtPath:symlinkPath withDestinationPath:[paths.complete lastPathComponent] error:nil];
                            [subscriber putNext:[[ResourceData alloc] initWithPath:symlinkPath size:currentContext.data.size complete:true]];
                            [subscriber putCompletion];
                        } else {
                            [subscriber putNext:currentContext.data];
                            [subscriber putCompletion];
                        }
                    } else if ((completeSize = fileSize(paths.complete)) != 0) {
                        if (pathExtension != nil) {
                            NSString *symlinkPath = [paths.complete stringByAppendingFormat:@".%@", pathExtension];
                            [[NSFileManager defaultManager] createSymbolicLinkAtPath:symlinkPath withDestinationPath:[paths.complete lastPathComponent] error:nil];
                            [subscriber putNext:[[ResourceData alloc] initWithPath:symlinkPath size:completeSize complete:true]];
                            [subscriber putCompletion];
                        } else {
                            [subscriber putNext:[[ResourceData alloc] initWithPath:paths.complete size:completeSize complete:true]];
                            [subscriber putCompletion];
                        }
                    } else {
                        ResourceDataContext *dataContext = nil;
                        if (currentContext != nil) {
                            dataContext = currentContext;
                        } else {
                            int32_t partialSize = fileSize(paths.partial);
                            dataContext = [[ResourceDataContext alloc] initWithData:[[ResourceData alloc] initWithPath:paths.partial size:partialSize complete:false]];
                            self->_dataContexts[resourceId] = dataContext;
                        }
                        
                        void (^subscriberItem)(ResourceData *) = ^(ResourceData *data) {
                            if (pathExtension != nil) {
                                NSString *symlinkPath = [paths.complete stringByAppendingFormat:@".%@", pathExtension];
                                [[NSFileManager defaultManager] createSymbolicLinkAtPath:symlinkPath withDestinationPath:[paths.complete lastPathComponent] error:nil];
                                [subscriber putNext:[[ResourceData alloc] initWithPath:symlinkPath size:data.size complete:true]];
                                [subscriber putCompletion];
                            } else {
                                [subscriber putNext:data];
                                [subscriber putCompletion];
                            }
                        };
                        
                        NSInteger index = [dataContext.completeDataSubscribers addItem:[subscriberItem copy]];
                        [subscriber putNext:[[ResourceData alloc] initWithPath:paths.partial size:0 complete:false]];
                        
                        [disposable setDisposable:[[SBlockDisposable alloc] initWithBlock:^{
                            [self->_dataQueue dispatch:^{
                                ResourceDataContext *dataContext = self->_dataContexts[resourceId];
                                if (dataContext != nil) {
                                    [dataContext.completeDataSubscribers removeItem:index];
                                    if (dataContext.completeDataSubscribers.isEmpty && dataContext.fetchSubscribers.isEmpty) {
                                        [self->_dataContexts removeObjectForKey:resourceId];
                                    }
                                }
                            }];
                        }]];
                    }
                }];
            }
        }];
        
        return disposable;
    }];
}

- (SSignal *)fetchedResource:(id<MediaResource>)resource {
    return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber) {
        SMetaDisposable *disposable = [[SMetaDisposable alloc] init];
        
        [self->_dataQueue dispatch:^{
            id<MediaResourceId> resourceId = [resource resourceId];
            ResourceStorePaths *paths = [self storePathsForId:resourceId];
            
            if (fileSize(paths.complete) != 0) {
                [subscriber putCompletion];
            } else {
                int32_t currentSize = fileSize(paths.partial);
                ResourceDataContext *dataContext = self->_dataContexts[resourceId];
                if (dataContext == nil) {
                    dataContext = [[ResourceDataContext alloc] initWithData:[[ResourceData alloc] initWithPath:paths.partial size:currentSize complete:false]];
                    self->_dataContexts[resourceId] = dataContext;
                }
                
                NSInteger index = [dataContext.fetchSubscribers addItem:@(1)];
                
                if (dataContext.fetchDisposable == nil) {
                    float progress = 0.0f;
                    if ([resource size] != nil) {
                        int32_t resourceSize = [[resource size] intValue];
                        if (resourceSize != 0) {
                            progress = ((float)currentSize) / ((float)resourceSize);
                        }
                    }
                    MediaResourceStatus *status = [[MediaResourceStatus alloc] initWithStatus:MediaResourceStatusFetching progress:progress];
                    [self->_statusQueue dispatch:^{
                        ResourceStatusContext *statusContext = self->_statusContexts[resourceId];
                        if (statusContext != nil) {
                            statusContext.status = status;
                            for (void (^statusSubscriber)(MediaResourceStatus *) in [statusContext.subscribers copyItems]) {
                                statusSubscriber(status);
                            }
                        }
                    }];
                    
                    __block int32_t offset = currentSize;
                    __block NSNumber *fd = nil;
                    SQueue *dataQueue = self->_dataQueue;
                    
                    SSignal *signal = [[self wrappedFetchResource:resource range:NSMakeRange(currentSize, INT32_MAX)] onDispose:^{
                        [dataQueue dispatch:^{
                            if (fd != nil) {
                                close([fd intValue]);
                            }
                        }];
                    }];
                    
                    dataContext.fetchDisposable = [signal startWithNext:^(MediaResourceDataFetchResult *result) {
                        [self->_dataQueue dispatch:^{
                            if (fd == nil) {
                                int32_t handle = open(paths.partial.UTF8String, O_WRONLY | O_CREAT | O_APPEND, S_IRUSR | S_IWUSR);
                                if (handle >= 0) {
                                    fd = @(handle);
                                }
                            }
                            
                            if (fd != nil) {
                                if (result.data.length != 0) {
                                    ssize_t writeResult = write([fd intValue], result.data.bytes, result.data.length);
                                    if (writeResult != (ssize_t)result.data.length) {
                                        TGLog(@"write error %d", (int)errno);
                                    }
                                }
                                
                                offset += (int32_t)result.data.length;
                                int32_t updatedSize = offset;
                                
                                ResourceData *updatedData = nil;
                                if (result.complete) {
                                    __unused int linkResult = link(paths.partial.UTF8String, paths.complete.UTF8String);
                                    updatedData = [[ResourceData alloc] initWithPath:paths.complete size:updatedSize complete:true];
                                } else {
                                    updatedData = [[ResourceData alloc] initWithPath:paths.partial size:updatedSize complete:false];
                                }
                                
                                dataContext.data = updatedData;
                                
                                if (updatedData.complete) {
                                    for (void (^dataSubscriber)(ResourceData *) in [dataContext.completeDataSubscribers copyItems]) {
                                        dataSubscriber(updatedData);
                                    }
                                }
                                
                                MediaResourceStatus *status = nil;
                                if (updatedData.complete) {
                                    status = [[MediaResourceStatus alloc] initWithStatus:MediaResourceStatusLocal progress:1.0f];
                                } else {
                                    float progress = 0.0f;
                                    if ([resource size] != nil) {
                                        int32_t resourceSize = [[resource size] intValue];
                                        if (resourceSize != 0) {
                                            progress = ((float)updatedSize) / ((float)resourceSize);
                                        }
                                    }
                                    status = [[MediaResourceStatus alloc] initWithStatus:MediaResourceStatusFetching progress:progress];
                                }
                                
                                [self->_statusQueue dispatch:^{
                                    ResourceStatusContext *statusContext = self->_statusContexts[resourceId];
                                    if (statusContext != nil) {
                                        for (void (^statusSubscriber)(MediaResourceStatus *) in [statusContext.subscribers copyItems]) {
                                            statusSubscriber(status);
                                        }
                                    }
                                }];
                            }
                        }];
                    }];
                }
                
                [disposable setDisposable:[[SBlockDisposable alloc] initWithBlock:^{
                    [self->_dataQueue dispatch:^{
                        ResourceDataContext *dataContext = self->_dataContexts[resourceId];
                        if (dataContext != nil) {
                            [dataContext.fetchSubscribers removeItem:index];
                            
                            if ([dataContext.fetchSubscribers isEmpty]) {
                                [dataContext.fetchDisposable dispose];
                                dataContext.fetchDisposable = nil;
                                
                                MediaResourceStatus *status = nil;
                                if (dataContext.data.complete) {
                                    status = [[MediaResourceStatus alloc] initWithStatus:MediaResourceStatusLocal progress:1.0f];
                                } else {
                                    status = [[MediaResourceStatus alloc] initWithStatus:MediaResourceStatusRemote progress:0.0f];
                                }
                                
                                [self->_statusQueue dispatch:^{
                                    ResourceStatusContext *statusContext = self->_statusContexts[resourceId];
                                    if (statusContext != nil && ![statusContext.status isEqual:status]) {
                                        statusContext.status = status;
                                        for (void (^statusSubscriber)(MediaResourceStatus *) in [statusContext.subscribers copyItems]) {
                                            statusSubscriber(status);
                                        }
                                    }
                                }];
                            }
                            
                            if ([dataContext.completeDataSubscribers isEmpty] && [dataContext.fetchSubscribers isEmpty]) {
                                [self->_dataContexts removeObjectForKey:resourceId];
                            }
                        }
                    }];
                }]];
            }
        }];
        
        return disposable;
    }];
}

- (void)cancelInteractiveResourceFetch:(id<MediaResource>)resource {
    [self->_dataQueue dispatch:^{
        id<MediaResourceId> resourceId = [resource resourceId];
        ResourceDataContext *dataContext = self->_dataContexts[resourceId];
        if (dataContext != nil && dataContext.fetchDisposable != nil) {
            [dataContext.fetchDisposable dispose];
            dataContext.fetchDisposable = nil;
            
            MediaResourceStatus *status = nil;
            if (dataContext.data.complete) {
                status = [[MediaResourceStatus alloc] initWithStatus:MediaResourceStatusLocal progress:1.0f];
            } else {
                status = [[MediaResourceStatus alloc] initWithStatus:MediaResourceStatusRemote progress:0.0f];
            }
            
            [self->_statusQueue dispatch:^{
                ResourceStatusContext *statusContext = self->_statusContexts[resourceId];
                if (statusContext != nil && ![statusContext.status isEqual:status]) {
                    statusContext.status = status;
                    for (void (^statusSubscriber)(MediaResourceStatus *) in [statusContext.subscribers copyItems]) {
                        statusSubscriber(status);
                    }
                }
            }];
        }
    }];
}

@end
