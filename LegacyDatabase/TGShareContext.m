#import "TGShareContext.h"

#import <MTProtoKitDynamic/MTRequest.h>

#import <LegacyDatabase/LegacyDatabase.h>

@interface TGShareContext ()
{
    NSLock *_datacenterPoolsLock;
    NSMutableDictionary *_datacenterPools;
}

@end

@implementation TGShareContext

- (instancetype)initWithContainerUrl:(NSURL *)containerUrl mtContext:(MTContext *)mtContext mtProto:(MTProto *)mtProto mtRequestService:(MTRequestMessageService *)mtRequestService clientUserId:(int32_t)clientUserId legacyDatabase:(TGLegacyDatabase *)legacyDatabase
{
    self = [super init];
    if (self != nil)
    {
        _containerUrl = containerUrl;
        
        _clientUserId = clientUserId;
        
        _mtContext = mtContext;
        _mtProto = mtProto;
        _mtRequestService = mtRequestService;
        
        _legacyDatabase = legacyDatabase;
        
        _datacenterPoolsLock = [[NSLock alloc] init];
        _datacenterPools = [[NSMutableDictionary alloc] init];
        
        NSString *persistentCachePath = [[containerUrl URLByAppendingPathComponent:@"temp-cache"] path];
        
        float factor = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad ? 3.0f : 1.0f;
        _persistentCache = [[TGModernCache alloc] initWithPath:persistentCachePath size:8 * 1024 * 1024];
        _memoryImageCache = [[TGMemoryImageCache alloc] initWithSoftMemoryLimit:(NSUInteger)(2 * 1024 * 1024 * factor) hardMemoryLimit:(NSUInteger)(3 * 1024 * 1024 * factor)];
        _memoryCache = [[TGMemoryCache alloc] init];
        _sharedThreadPool = [[SThreadPool alloc] initWithThreadCount:4 threadPriority:0.2];
    }
    return self;
}

- (void)dealloc
{
    [_mtProto stop];
}

- (SSignal *)function:(Api70_FunctionContext *)functionContext
{
    __weak TGShareContext *weakSelf = self;
    return [[SSignal alloc] initWithGenerator:^id<SDisposable> (SSubscriber *subscriber)
    {
        __strong TGShareContext *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            MTRequest *request = [[MTRequest alloc] init];

            [request setPayload:functionContext.payload metadata:functionContext.metadata responseParser:functionContext.responseParser];
            
            [request setCompleted:^(id result, __unused NSTimeInterval timestamp, MTRpcError *error)
            {
                if (error == nil)
                {
                    [subscriber putNext:result];
                    [subscriber putCompletion];
                }
                else
                    [subscriber putError:error];
            }];
            
            //request.dependsOnPasswordEntry = (requestClass & TGRequestClassIgnorePasswordEntryRequired) == 0;
            
            [request setShouldContinueExecutionWithErrorContext:^bool(MTRequestErrorContext *errorContext)
            {
                return false;
            }];
            
            [strongSelf->_mtRequestService addRequest:request];
            id requestToken = request.internalId;
            
            return [[SBlockDisposable alloc] initWithBlock:^
            {
                __strong TGShareContext *strongSelf = weakSelf;
                [strongSelf.mtRequestService removeRequestByInternalId:requestToken];
            }];
        }
        else
        {
            [subscriber putError:nil];
            return nil;
        }
    }];
}

- (SSignal *)pooledConnectionContextForDatacenter:(NSInteger)datacenterId
{
    __weak TGShareContext *weakSelf = self;
    return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
    {
        __strong TGShareContext *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            [strongSelf->_datacenterPoolsLock lock];
            TGPoolWithTimeout *pool = strongSelf->_datacenterPools[@(datacenterId)];
            if (pool == nil)
            {
                pool = [[TGPoolWithTimeout alloc] initWithTimeout:30.0 maxObjects:4];
                strongSelf->_datacenterPools[@(datacenterId)] = pool;
            }
            [strongSelf->_datacenterPoolsLock unlock];
            
            TGDatacenterConnectionContext *datacenterConnectionContext = [pool takeObject];
            if (datacenterConnectionContext == nil)
            {
                MTProto *mtProto = [[MTProto alloc] initWithContext:strongSelf->_mtContext datacenterId:datacenterId usageCalculationInfo:nil];
                if (datacenterId != strongSelf->_mtProto.datacenterId)
                {
                    mtProto.requiredAuthToken = @(1);
                    mtProto.authTokenMasterDatacenterId = strongSelf->_mtProto.datacenterId;
                }
                
                MTRequestMessageService *mtRequestService = [[MTRequestMessageService alloc] initWithContext:strongSelf->_mtContext];
                [mtProto addMessageService:mtRequestService];
                
                datacenterConnectionContext = [[TGDatacenterConnectionContext alloc] initWithDatacenterId:datacenterId mtContext:strongSelf->_mtContext mtProto:mtProto mtRequestService:mtRequestService];
            }
            
            [subscriber putNext:datacenterConnectionContext];
            [subscriber putCompletion];
        }
        else
            [subscriber putError:nil];
        return nil;
    }];
}

- (void)returnPooledDatacenterConnectionContext:(TGDatacenterConnectionContext *)datacenterConnectionContext datacenterId:(NSInteger)datacenterId
{
    [_datacenterPoolsLock lock];
    TGPoolWithTimeout *pool = _datacenterPools[@(datacenterId)];
    if (pool != nil)
        [pool addObject:datacenterConnectionContext];
    [_datacenterPoolsLock unlock];
}

- (SSignal *)datacenter:(NSInteger)datacenterId function:(Api70_FunctionContext *)functionContext
{
    __weak TGShareContext *weakSelf = self;
    return [[self pooledConnectionContextForDatacenter:datacenterId] mapToSignal:^SSignal *(TGDatacenterConnectionContext *datacenterConnectionContext)
    {
        return [[datacenterConnectionContext function:functionContext] onDispose:^
        {
            __strong TGShareContext *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                [strongSelf returnPooledDatacenterConnectionContext:datacenterConnectionContext datacenterId:datacenterId];
            }
        }];
    }];
}

- (SSignal *)connectionContextForDatacenter:(NSInteger)datacenterId
{
    __weak TGShareContext *weakSelf = self;
    return [[self pooledConnectionContextForDatacenter:datacenterId] map:^id(TGDatacenterConnectionContext *context)
    {
        return [[TGPooledDatacenterConnectionContext alloc] initWithDatacenterConnectionContext:context returnContext:^(TGDatacenterConnectionContext *context)
        {
            __strong TGShareContext *strongSelf = weakSelf;
            [strongSelf returnPooledDatacenterConnectionContext:context datacenterId:datacenterId];
        }];
    }];
}

@end
