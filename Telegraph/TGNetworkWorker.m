//
//  TGDownloadWorker.m
//  Telegraph
//
//  Created by Peter on 14/02/14.
//
//

#import "TGNetworkWorker.h"

#import "ASQueue.h"
#import "ActionStage.h"

#import "TGTelegraph.h"

#import "TGTimer.h"

#import <MTProtoKit/MTContext.h>
#import <MTProtoKit/MTProto.h>
#import <MTProtoKit/MTRequestMessageService.h>
#import <MTProtoKit/MtProtoKit.h>

#import "TGTelegramNetworking.h"

static int workerCount = 0;

@interface TGNetworkWorker () <MTRequestMessageServiceDelegate>
{
    MTContext *_context;
    MTProto *_mtProto;
    MTRequestMessageService *_requestService;
    
    TGTimer *_timeoutTimer;

    bool _isReadyToBeRemoved;
    bool _isBusy;
}

@end

@implementation TGNetworkWorker

- (instancetype)initWithContext:(MTContext *)context datacenterId:(NSInteger)datacenterId masterDatacenterId:(NSInteger)masterDatacenterId isCdn:(bool)isCdn
{
    self = [super init];
    if (self != nil)
    {
        _isCdn = isCdn;
        workerCount++;
        TGLog(@"[TGNetworkWorker#%x/%d start (%d)]", (int)self, (int)datacenterId, workerCount);
        
        _context = context;
        _datacenterId = datacenterId;
        
        _mtProto = [[MTProto alloc] initWithContext:_context datacenterId:_datacenterId usageCalculationInfo:[[TGTelegramNetworking instance] mediaUsageInfoForType:TGNetworkMediaTypeTagGeneric]];
        _mtProto.cdn = isCdn;
        if (!isCdn) {
            _mtProto.requiredAuthToken = @(TGTelegraphInstance.clientUserId);
            _mtProto.authTokenMasterDatacenterId = masterDatacenterId;
        }
        
        _requestService = [[MTRequestMessageService alloc] initWithContext:_context];
        _requestService.delegate = self;
        [_mtProto addMessageService:_requestService];
        
        [self startTimer];
    }
    return self;
}

- (void)dealloc
{
    workerCount--;
    TGLog(@"[TGNetworkWorker#%x stop (%d)]", (int)self, workerCount);
    
    if (_timeoutTimer != nil)
    {
        [_timeoutTimer invalidate];
        _timeoutTimer = nil;
    }
    
    [_mtProto stop];
    _requestService.delegate = nil;
}

- (void)setUsageCalculationInfo:(MTNetworkUsageCalculationInfo *)usageCalculationInfo {
    _usageCalculationInfo = usageCalculationInfo;
    [_mtProto setUsageCalculationInfo:usageCalculationInfo];
}

- (void)startTimer
{
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        [self clearTimer];
        
        __weak TGNetworkWorker *weakSelf = self;
        _timeoutTimer = [[TGTimer alloc] initWithTimeout:30 repeat:false completion:^
        {
            __strong TGNetworkWorker *strongSelf = weakSelf;
            [strongSelf timerTimeout];
        } queue:[ActionStageInstance() globalStageDispatchQueue]];
        [_timeoutTimer start];
    }];
}

- (void)clearTimer
{
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        if (_timeoutTimer != nil)
        {
            [_timeoutTimer invalidate];
            _timeoutTimer = nil;
        }
    }];
}

- (void)timerTimeout
{
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        _isReadyToBeRemoved = true;
        
        id<TGNetworkWorkerDelegate> delegate = _delegate;
        if ([delegate respondsToSelector:@selector(networkWorkerReadyToBeRemoved:)])
            [delegate networkWorkerReadyToBeRemoved:self];
    }];
}

- (bool)isBusy
{
    return _isBusy;
}

- (void)setIsBusy:(bool)isBusy
{
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        if (_isBusy != isBusy)
        {
            _isBusy = isBusy;
            if (isBusy)
                [self clearTimer];
            else
                [self startTimer];
            
            if (!_isBusy)
            {
                id<TGNetworkWorkerDelegate> delegate = _delegate;
                if ([delegate respondsToSelector:@selector(networkWorkerDidBecomeAvailable:)])
                    [delegate networkWorkerDidBecomeAvailable:self];
            }
        }
    }];
}

- (void)updateReadyToBeRemoved
{
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        if (_isReadyToBeRemoved)
        {
            id<TGNetworkWorkerDelegate> delegate = _delegate;
            if ([delegate respondsToSelector:@selector(networkWorkerReadyToBeRemoved:)])
                [delegate networkWorkerReadyToBeRemoved:self];
        }
    }];
}

- (void)addRequest:(MTRequest *)request
{
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        [_requestService addRequest:request];
    }];
}

- (void)cancelRequestById:(id)requestId
{
    [_requestService removeRequestByInternalId:requestId askForReconnectionOnDrop:true];
}

- (void)cancelRequestByIdSoft:(id)requestId
{
    [_requestService removeRequestByInternalId:requestId askForReconnectionOnDrop:false];
}

- (void)ensureConnection
{
    [_mtProto requestTransportTransaction];
}

- (void)requestMessageServiceDidCompleteAllRequests:(MTRequestMessageService *)__unused requestMessageService
{
}

- (void)requestMessageServiceAuthorizationRequired:(MTRequestMessageService *)__unused requestMessageService
{
    [_context updateAuthTokenForDatacenterWithId:_datacenterId authToken:nil];
    [_context authTokenForDatacenterWithIdRequired:_datacenterId authToken:_mtProto.requiredAuthToken masterDatacenterId:_mtProto.authTokenMasterDatacenterId];
}

@end

@implementation TGNetworkWorkerGuard

- (instancetype)initWithWorker:(TGNetworkWorker *)worker
{
    self = [super init];
    if (self != nil)
    {
        _worker = worker;
    }
    return self;
}

- (void)dealloc
{
    [self releaseWorker];
}

- (TGNetworkWorker *)strongWorker
{
    return _worker;
}

- (void)releaseWorker
{
    TGNetworkWorker *worker = _worker;
    _worker = nil;
    [worker setIsBusy:false];
    worker = nil;
}

@end
