#import "TGICloudFileDownloadActor.h"

#import "TGFileUtils.h"
#import "TGTimerTarget.h"

#import "ActionStage.h"

const NSTimeInterval TGICloudFileDownloadProgressTimerInterval = 1.0f;

@interface TGICloudFileDownloadRequest : NSObject
{
    bool _addedProgressObserver;
    bool _discardedMetadataQuery;
}

@property (nonatomic, copy) void(^progressBlock)(CGFloat progress);
@property (nonatomic, copy) void(^completionBlock)(bool succeed);

@property (nonatomic, readonly) NSFileCoordinator *fileCoordinator;
@property (nonatomic, readonly) NSMetadataQuery *metadataQuery;

@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) NSURL *path;
@property (nonatomic, assign) bool downloaded;
@property (nonatomic, assign) bool cancelled;

- (void)cancel;
- (void)dispose;

+ (TGICloudFileDownloadRequest *)downloadFileAtUrl:(NSURL *)url path:(NSURL *)path progressBlock:(void (^)(CGFloat progress))progressBlock completionBlock:(void (^)(bool succeed))completionBlock;

@end

@implementation TGICloudFileDownloadRequest

+ (TGICloudFileDownloadRequest *)downloadFileAtUrl:(NSURL *)url path:(NSURL *)path progressBlock:(void (^)(CGFloat progress))progressBlock completionBlock:(void (^)(bool succeed))completionBlock
{
    TGICloudFileDownloadRequest *request = [[TGICloudFileDownloadRequest alloc] init];
    request.url = url;
    request.path = path;
    
    request.progressBlock = progressBlock;
    request.completionBlock = completionBlock;
    
    [request start];
    
    return request;
}

- (void)start
{
    NSError *error;
    NSDictionary *fileAttributes = [self.url resourceValuesForKeys:@[ NSURLUbiquitousItemDownloadingStatusKey ] error:&error];
    
    bool isRemoteFile = false;
    bool isCurrent = true;
    
    if (fileAttributes != nil)
    {
        NSString *downloadingStatusAttribute = fileAttributes[NSURLUbiquitousItemDownloadingStatusKey];
        
        if (downloadingStatusAttribute != nil)
        {
            isRemoteFile = true;
            if (![downloadingStatusAttribute isEqualToString:NSURLUbiquitousItemDownloadingStatusCurrent])
                isCurrent = false;
        }
    }
    
    bool succeed = [self.url startAccessingSecurityScopedResource];
    if (!succeed)
    {
        TGLog(@"Cloud ERROR: failed to start accessing security scoped resource: %@", self.url);
        if (self.completionBlock != nil)
            self.completionBlock(false);
        return;
    }
    
    void (^downloadCompletionBlock)(NSURL *) = ^(NSURL *url)
    {
        if (self.progressBlock != nil)
            self.progressBlock(1.0f);
        
        self.downloaded = true;
        
        [[NSFileManager defaultManager] createDirectoryAtPath:[self.path.path stringByDeletingLastPathComponent] withIntermediateDirectories:true attributes:nil error:nil];
        
        TGLog(@"Cloud INFO: actual cloud file is available at %@", url);
        
        NSError *fileCopyError;
        if (![[NSFileManager defaultManager] copyItemAtURL:url toURL:self.path error:&fileCopyError])
        {
            TGLog(@"Cloud ERROR: failed to copy security scoped resource from %@ to %@ with error: %@", url, self.path, fileCopyError);
            if (self.completionBlock != nil)
                self.completionBlock(false);
            return;
        }
        
        [url stopAccessingSecurityScopedResource];
        
        if (self.completionBlock != nil)
            self.completionBlock(true);
    };
    
    if (!isRemoteFile || isCurrent)
    {
        TGLog(@"Cloud INFO: file is not from iCloud or is current");
        downloadCompletionBlock(self.url);
    }
    else
    {
        TGLog(@"Cloud INFO: starting coordinated access to file");
        
        __weak TGICloudFileDownloadRequest *weakSelf = self;
        _fileCoordinator = [[NSFileCoordinator alloc] initWithFilePresenter:nil];
        NSFileAccessIntent *fileAccessIntent = [NSFileAccessIntent readingIntentWithURL:self.url options:NSFileCoordinatorReadingWithoutChanges];
        [_fileCoordinator coordinateAccessWithIntents:@[fileAccessIntent]
                                               queue:[TGICloudFileDownloadRequest
                                                      fileCoordinatorOperationQueue] byAccessor:^(NSError *error)
        {
            __strong TGICloudFileDownloadRequest *strongSelf = weakSelf;
            @synchronized (self)
            {
                if (strongSelf->_metadataQuery != nil)
                {
                    strongSelf->_discardedMetadataQuery = true;
                    if (strongSelf->_addedProgressObserver)
                        [strongSelf->_metadataQuery removeObserver:self forKeyPath:@"results"];
                    if (strongSelf->_metadataQuery.started)
                        [strongSelf->_metadataQuery stopQuery];
                    strongSelf->_metadataQuery = nil;
                }
            }
            
            if (error != nil)
            {
                TGLog(@"Cloud ERROR: failed to download file with error: %@", error);
                if (self.completionBlock != nil)
                    self.completionBlock(false);
                return;
            }
            
            TGLog(@"Cloud INFO: cloud file download completed for %@", fileAccessIntent.URL);
            downloadCompletionBlock(fileAccessIntent.URL);
        }];
        
        if (self.progressBlock != nil)
        {
            NSString *fileName = self.url.lastPathComponent;
            _metadataQuery = [[NSMetadataQuery alloc] init];
            [_metadataQuery setSearchScopes:@[ NSMetadataQueryAccessibleUbiquitousExternalDocumentsScope ]];
            [_metadataQuery setPredicate:[NSPredicate predicateWithFormat:@"%K == %@", NSMetadataItemFSNameKey, fileName]];
            [_metadataQuery setValueListAttributes:@[NSMetadataUbiquitousItemPercentDownloadedKey]];
            
            dispatch_async(dispatch_get_main_queue(), ^
            {
                @synchronized (self)
                {
                    if (!_discardedMetadataQuery)
                    {
                        [_metadataQuery startQuery];
                        [_metadataQuery addObserver:self forKeyPath:@"results" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
                        _addedProgressObserver = true;
                    }
                }
            });
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)__unused object change:(NSDictionary *)change context:(void *)__unused context
{
    if ([keyPath isEqualToString:@"results"])
    {
        NSUInteger changeKind = [[change objectForKey:NSKeyValueChangeKindKey] unsignedIntegerValue];
        if (changeKind == NSKeyValueChangeReplacement)
        {
            NSArray *changedItems = [change objectForKey:NSKeyValueChangeNewKey];
            for (NSMetadataItem *item in changedItems)
            {
                NSNumber *percentDownloaded = [item valueForAttribute:NSMetadataUbiquitousItemPercentDownloadedKey];
                if (percentDownloaded != nil)
                {
                    CGFloat progress = [percentDownloaded floatValue] / 100.0f;
                    if (self.progressBlock != nil)
                        self.progressBlock(progress);
                }
            }
        }
    }
}

- (void)cancel
{
    self.cancelled = true;
    [self.metadataQuery stopQuery];
    [self.fileCoordinator cancel];
    [self dispose];
}

- (void)dispose
{
    self.url = nil;
    self.path = nil;
    self.progressBlock = nil;
    self.completionBlock = nil;
    _fileCoordinator = nil;
    _metadataQuery = nil;
}

+ (NSOperationQueue *)fileCoordinatorOperationQueue
{
    static NSOperationQueue *fileCoordinatorOperationQueue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        fileCoordinatorOperationQueue = [[NSOperationQueue alloc] init];
    });
    
    return fileCoordinatorOperationQueue;
}

@end

@interface TGICloudFileDownloadActor ()
{
    NSURL *_url;
    NSString *_path;
}
@end

@implementation TGICloudFileDownloadActor

+ (NSString *)genericPath
{
    return @"/iCloudDownload/@";
}

- (void)prepare:(NSDictionary *)options
{
    [super prepare:options];
    
    if (options[@"queue"] != nil)
        self.requestQueueName = options[@"queue"];
}

- (void)execute:(NSDictionary *)options
{
    _url = options[@"url"];
    _path = options[@"path"];
    
    __weak TGICloudFileDownloadActor *weakSelf = self;
    self.cancelToken = [TGICloudFileDownloadRequest downloadFileAtUrl:_url path:[NSURL fileURLWithPath:_path] progressBlock:^(CGFloat progress)
    {
        __strong TGICloudFileDownloadActor *strongSelf = weakSelf;
        [ActionStageInstance() dispatchMessageToWatchers:strongSelf.path messageType:@"progress" message:@(progress)];
    } completionBlock:^(bool succeed)
    {
        __strong TGICloudFileDownloadActor *strongSelf = weakSelf;
        if (succeed)
            [ActionStageInstance() actionCompleted:strongSelf.path result:nil];
        else
            [ActionStageInstance() actionFailed:strongSelf.path reason:-1];
    }];
}

@end
