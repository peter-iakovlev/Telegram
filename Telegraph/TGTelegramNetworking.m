/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGTelegramNetworking.h"

#import "TGAppDelegate.h"

#if !TGUseModernNetworking
#import "TGSession.h"
#endif

#import "ActionStage.h"
#import "SGraphObjectNode.h"

#import "TGTelegraph.h"

#import <MTProtoKit/MTLogging.h>
#import <MTProtoKit/MTKeychain.h>
#import <MTProtoKit/MTContext.h>
#import <MTProtoKit/MTApiEnvironment.h>
#import <MTProtoKit/MTDatacenterAddressSet.h>
#import <MTProtoKit/MTDatacenterAddress.h>
#import <MTProtoKit/MTTransportScheme.h>
#import <MTProtoKit/MTProto.h>
#import <MTProtoKit/MTRequestMessageService.h>
#import <MTProtoKit/MTRequest.h>
#import <MTProtoKit/MTRequestErrorContext.h>
#import "TGUpdateMessageService.h"

#import <MTProtoKit/MTInternalId.h>
#import "TGNetworkWorker.h"

#import "TGTLSerialization.h"
#import "TGKeychainImport.h"

static const int TGMaxWorkerCount = 4;

MTInternalIdClass(TGDownloadWorker)

@interface TGTelegramNetworking () <ASWatcher, MTProtoDelegate, MTRequestMessageServiceDelegate, TGNetworkWorkerDelegate>
{
    bool _isTestingEnvironment;
    MTKeychain *_settingsKeychain;
    MTKeychain *_keychain;
    MTContext *_context;
    MTProto *_mtProto;
    MTRequestMessageService *_requestService;
    TGUpdateMessageService *_updateService;
    NSInteger _masterDatacenterId;
    
    bool _isNetworkAvailable;
    bool _isConnected;
    bool _isUpdatingConnectionContext;
    bool _isPerformingServiceTasks;
    
    bool _isPerformingGetDifference;
    
    int _dispatchNetworkStateToken;
    
    int _completeWakeUpToken;
    
    NSMutableDictionary *_workersByDatacenterId;
    NSMutableDictionary *_awaitingWorkerTokensByDatacenterId;
    
    NSMutableArray *_currentWakeUpCompletions;
}

@property (nonatomic, strong) ASHandle *actionHandle;

@end

@implementation TGTelegramNetworking

static void TGTelegramLoggingFunction(NSString *format, va_list args)
{
    TGLogv(format, args);
}

+ (TGTelegramNetworking *)instance
{
    static TGTelegramNetworking *singleton = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        MTLogSetLoggingFunction(&TGTelegramLoggingFunction);
        
        singleton = [[TGTelegramNetworking alloc] init];
    });
    return singleton;
}

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        _actionHandle = [[ASHandle alloc] initWithDelegate:self];
        [ActionStageInstance() watchForPath:@"/tg/service/synchronizationstate" watcher:self];
        
        _currentWakeUpCompletions = [[NSMutableArray alloc] init];
        
        _settingsKeychain = [MTKeychain keychainWithName:@"Telegram-Settings"];
        NSString *environmentId = [_settingsKeychain objectForKey:@"environmentId" group:@"environment"];
        _isTestingEnvironment = environmentId != nil && [environmentId isEqualToString:@"testing"];
        
        NSString *keychainName = _isTestingEnvironment ? @"Telegram-Testing" : @"Telegram";
        _keychain = [MTKeychain keychainWithName:keychainName];
        
#if TGUseModernNetworking
        if (![[_keychain objectForKey:@"importedLegacyKeychain" group:@"meta"] boolValue])
        {
            [TGKeychainImport importKeychain:_keychain clientUserId:TGTelegraphInstance.clientUserId];
            [_keychain setObject:@(true) forKey:@"importedLegacyKeychain" group:@"meta"];
        }
#endif
        
        MTApiEnvironment *apiEnvironment = [[MTApiEnvironment alloc] init];
        NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
        
        if ([bundleIdentifier isEqualToString:@"org.telegram.TelegramEnterprise"])
            apiEnvironment.apiId = 16352;
        else if ([bundleIdentifier isEqualToString:@"org.telegram.TelegramHD"])
            apiEnvironment.apiId = 7;
        else
            apiEnvironment.apiId = 1;
        
        _context = [[MTContext alloc] initWithSerialization:[[TGTLSerialization alloc] init] apiEnvironment:apiEnvironment];
        
        _workersByDatacenterId = [[NSMutableDictionary alloc] init];
        _awaitingWorkerTokensByDatacenterId = [[NSMutableDictionary alloc] init];
        
        if (_isTestingEnvironment)
        {
            [_context setSeedAddressSetForDatacenterWithId:1 seedAddressSet:[[MTDatacenterAddressSet alloc] initWithAddressList:@[
                [[MTDatacenterAddress alloc] initWithIp:@"173.240.5.253" port:443]
            ]]];
        }
        else
        {
            [_context performBatchUpdates:^
            {
                [_context setSeedAddressSetForDatacenterWithId:1 seedAddressSet:[[MTDatacenterAddressSet alloc] initWithAddressList:@[
                    [[MTDatacenterAddress alloc] initWithIp:@"173.240.5.1" port:443]
                ]]];
                
                [_context setSeedAddressSetForDatacenterWithId:2 seedAddressSet:[[MTDatacenterAddressSet alloc] initWithAddressList:@[
                    [[MTDatacenterAddress alloc] initWithIp:@"149.154.167.50" port:443]
                ]]];
                
                [_context setSeedAddressSetForDatacenterWithId:3 seedAddressSet:[[MTDatacenterAddressSet alloc] initWithAddressList:@[
                    [[MTDatacenterAddress alloc] initWithIp:@"174.140.142.6" port:443]
                ]]];

                [_context setSeedAddressSetForDatacenterWithId:4 seedAddressSet:[[MTDatacenterAddressSet alloc] initWithAddressList:@[
                    [[MTDatacenterAddress alloc] initWithIp:@"31.210.235.12" port:443]
                ]]];

                [_context setSeedAddressSetForDatacenterWithId:5 seedAddressSet:[[MTDatacenterAddressSet alloc] initWithAddressList:@[
                    [[MTDatacenterAddress alloc] initWithIp:@"116.51.22.2" port:443]
                ]]];
            }];
        }
        
        _context.keychain = _keychain;
        
#if TARGET_IPHONE_SIMULATOR
        /*[_context updateAddressSetForDatacenterWithId:2 addressSet:[[MTDatacenterAddressSet alloc] initWithAddressList:@[
            [[MTDatacenterAddress alloc] initWithIp:@"173.2.14.88" port:443]
        ]]];*/
#endif
        
        NSNumber *nDefaultDatacenterId = [_keychain objectForKey:@"defaultDatacenterId" group:@"persistent"];
        [self resetMainMtProto:nDefaultDatacenterId == nil ? 1 : [nDefaultDatacenterId integerValue]];
        
        [ActionStageInstance() requestActor:@"/tg/datacenterWatchdog" options:nil flags:0 watcher:self];
        
#if TARGET_IPHONE_SIMULATOR
        //[_context beginTransportSchemeDiscoveryForDatacenterId:3];
#endif
        
#if TARGET_IPHONE_SIMULATOR && false
        MTRequest *getSchemeRequest = [[MTRequest alloc] init];
        getSchemeRequest.body = [[TLRPChelp_getScheme$help_getScheme alloc] init];
        [getSchemeRequest setCompleted:^(TLScheme$scheme *result, __unused NSTimeInterval timestamp, __unused id error)
        {
            TGLog(@"%@", result.scheme_raw);
        }];
        [_requestService addRequest:getSchemeRequest];
#endif
    }
    return self;
}

- (MTContext *)context
{
    return _context;
}

- (MTProto *)mtProto
{
    return _mtProto;
}

- (void)resetMainMtProto:(NSInteger)datacenterId
{
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        if (self->_requestService != nil)
        {
            _requestService.delegate = nil;
            [_mtProto removeMessageService:_requestService];
            _requestService = nil;
        }
        
        if (_updateService != nil)
        {
            [_mtProto removeMessageService:_updateService];
            _updateService = nil;
        }
        
        if (_mtProto != nil)
        {
            _mtProto.delegate = nil;
            [_mtProto stop];
        }
        
        _masterDatacenterId = datacenterId;
        
        _mtProto = [[MTProto alloc] initWithContext:_context datacenterId:datacenterId];
        _mtProto.delegate = self;
        _isNetworkAvailable = true;
        _isConnected = true;
        [self dispatchNetworkState];
        
        _requestService = [[MTRequestMessageService alloc] initWithContext:_context];
        _requestService.delegate = self;
        [_mtProto addMessageService:_requestService];
        
        _updateService = [[TGUpdateMessageService alloc] init];
        [_mtProto addMessageService:_updateService];
        
        [_context authInfoForDatacenterWithIdRequired:_mtProto.datacenterId];
    }];
}

- (NSTimeInterval)globalTime
{
#if TGUseModernNetworking
    return [_context globalTime];
#else
    return (int)(CFAbsoluteTimeGetCurrent() + kCFAbsoluteTimeIntervalSince1970) + [[TGSession instance] timeDifference];
#endif
}

- (NSTimeInterval)timeOffset
{
#if TGUseModernNetworking
    return [_context globalTimeOffsetFromUTC];
#else
    return [[TGSession instance] timeOffsetFromUTC];
#endif
}

- (NSTimeInterval)approximateRemoteTime
{
#if TGUseModernNetworking
    return [_context globalTime];
#else
    return [[NSDate date] timeIntervalSince1970] + [[TGSession instance] timeOffsetFromUTC] - [[NSTimeZone localTimeZone] secondsFromGMT];
#endif
}

- (void)loadCredentials
{
#if TGUseModernNetworking
#else
    [[TGSession instance] loadSession];
#endif
}

- (void)start
{
#if TGUseModernNetworking
#else
    [[TGSession instance] takeOff];
#endif
}

- (void)pause
{
#if TGUseModernNetworking
    [_mtProto pause];
#else
    [[TGSession instance] suspendNetwork];
#endif
}

- (void)resume
{
#if TGUseModernNetworking
    [_mtProto resume];
#else
    [[TGSession instance] resumeNetwork];
#endif
}

- (void)moveToDatacenterId:(NSInteger)datacenterId
{
#if TGUseModernNetworking
    if (datacenterId != _mtProto.datacenterId)
    {
        _masterDatacenterId = datacenterId;
        [_keychain setObject:@(_masterDatacenterId) forKey:@"defaultDatacenterId" group:@"persistent"];
        [self resetMainMtProto:datacenterId];
    }
#endif
}

- (void)restartWithCleanCredentials
{
#if TGUseModernNetworking
    if (_requestService != nil)
    {
        _requestService.delegate = nil;
        [_mtProto removeMessageService:_requestService];
    }
    
    _requestService = [[MTRequestMessageService alloc] initWithContext:_context];
    _requestService.delegate = self;
    [_mtProto addMessageService:_requestService];
    
    TGTelegraphInstance.clientUserId = 0;
    TGTelegraphInstance.clientIsActivated = false;
    [TGAppDelegateInstance saveSettings];
    
    [_context removeAllAuthTokens];
    
    [TGKeychainImport clearLegacyKeychain];
#else
    [[TGSession instance] clearSessionAndTakeOff];
#endif
}

- (void)clearExportedTokens
{
    NSInteger masterDatacenterId = _mtProto.datacenterId;
    [_context performBatchUpdates:^
    {
        for (NSNumber *nDatacenterId in [_context knownDatacenterIds])
        {
            if ([nDatacenterId integerValue] != masterDatacenterId)
                [_context updateAuthTokenForDatacenterWithId:[nDatacenterId integerValue] authToken:nil];
        }
    }];
}

- (void)mergeDatacenterAddress:(NSInteger)datacenterId address:(MTDatacenterAddress *)address
{
#if TGUseModernNetworking
    [_context performBatchUpdates:^
    {
        [_context addAddressForDatacenterWithId:datacenterId address:address];
        
        MTTransportScheme *scheme = [_context transportSchemeForDatacenterWithid:datacenterId];
        if (![scheme.address isEqualToAddress:address])
        {
            scheme = [[MTTransportScheme alloc] initWithTransportClass:scheme.transportClass address:address];
            [_context updateTransportSchemeForDatacenterWithId:datacenterId transportScheme:scheme];
        }
    }];
#else
    TGDatacenterContext *datacenter = datacenter = [[TGDatacenterContext alloc] init];
    datacenter.datacenterId = datacenterId;
    
    int64_t authSessionId = [[TGSession instance] generateSessionId];
    int64_t authUploadSessionId = [[TGSession instance] generateSessionId];
    int64_t authDownloadSessionId = [[TGSession instance] generateSessionId];
    
    datacenter.authSessionId = authSessionId;
    datacenter.authDownloadSessionId = authDownloadSessionId;
    datacenter.authUploadSessionId = authUploadSessionId;
    
    NSMutableArray *addressSet = datacenter.addressSet == nil ? [[NSMutableArray alloc] init] : [[NSMutableArray alloc] initWithArray:datacenter.addressSet];
    [addressSet addObject:[[NSDictionary alloc] initWithObjectsAndKeys:address.ip, @"address", [[NSNumber alloc] initWithInt:address.port], @"port", nil]];
    datacenter.addressSet = addressSet;
    
    [[TGSession instance] mergeDatacenterData:@[datacenter]];
#endif
}

- (void)performDeferredServiceTasks
{
#if TGUseModernNetworking
#else
    [ActionStageInstance() requestActor:[[NSString alloc] initWithFormat:@"/tg/network/requestFutureSalts/(%d)", [[TGSession instance] datacenterWithId:TG_DEFAULT_DATACENTER_ID].datacenterId] options:nil flags:0 watcher:[TGSession instance]];
#endif
}

- (NSInteger)masterDatacenterId
{
    return _masterDatacenterId;
}

- (id)requestDownloadWorkerForDatacenterId:(NSInteger)datacenterId completion:(void (^)(TGNetworkWorkerGuard *))completion
{
    id token = [[MTInternalId(TGDownloadWorker) alloc] init];
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        NSMutableArray *awaitingWorkerTokenList = _awaitingWorkerTokensByDatacenterId[@(datacenterId)];
        if (awaitingWorkerTokenList == nil)
        {
            awaitingWorkerTokenList = [[NSMutableArray alloc] init];
            _awaitingWorkerTokensByDatacenterId[@(datacenterId)] = awaitingWorkerTokenList;
        }
        
        [awaitingWorkerTokenList addObject:@[token, [completion copy]]];
        
        [self _processWorkerQueue];
    }];
    return token;
}

- (void)_processWorkerQueue
{
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        [_awaitingWorkerTokensByDatacenterId enumerateKeysAndObjectsUsingBlock:^(__unused NSNumber *nDatacenterId, NSMutableArray *list, __unused BOOL *stop)
        {
            if (list.count != 0)
            {
                NSMutableArray *workerList = _workersByDatacenterId[nDatacenterId];
                if (workerList == nil)
                {
                    workerList = [[NSMutableArray alloc] init];
                    _workersByDatacenterId[nDatacenterId] = workerList;
                }
                
                TGNetworkWorker *selectedWorker = nil;
                for (TGNetworkWorker *worker in workerList)
                {
                    if (!worker.isBusy)
                    {
                        selectedWorker = worker;
                        break;
                    }
                }
                
                if (selectedWorker == nil && workerList.count < TGMaxWorkerCount)
                {
                    TGNetworkWorker *worker = [[TGNetworkWorker alloc] initWithContext:_context datacenterId:[nDatacenterId integerValue] masterDatacenterId:_masterDatacenterId];
                    worker.delegate = self;
                    [workerList addObject:worker];
                    
                    selectedWorker = worker;
                }
                
                if (selectedWorker != nil)
                {
                    NSArray *desc = list[0];
                    [list removeObjectAtIndex:0];
                    
                    [selectedWorker setIsBusy:true];
                    TGNetworkWorkerGuard *guard = [[TGNetworkWorkerGuard alloc] initWithWorker:selectedWorker];
                    ((void (^)(TGNetworkWorkerGuard *))desc[1])(guard);
                }
            }
        }];
    }];
}

- (void)cancelDownloadWorkerRequestByToken:(id)token
{
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        [_awaitingWorkerTokensByDatacenterId enumerateKeysAndObjectsUsingBlock:^(__unused NSNumber *nDatacenterId, NSMutableArray *list, __unused BOOL *stop)
        {
            NSInteger index = -1;
            for (NSArray *desc in list)
            {
                index++;
                if ([desc[0] isEqual:token])
                {
                    [list removeObjectAtIndex:(NSUInteger)index];
                    
                    break;
                }
            }
        }];
    }];
}

- (void)networkWorkerDidBecomeAvailable:(TGNetworkWorker *)__unused networkWorker
{
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        [self _processWorkerQueue];
    }];
}

- (void)networkWorkerReadyToBeRemoved:(TGNetworkWorker *)networkWorker
{
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        [_workersByDatacenterId enumerateKeysAndObjectsUsingBlock:^(__unused NSNumber *nDatacenterId, NSMutableArray *workers, __unused BOOL *stop)
        {
            NSInteger index = -1;
            for (TGNetworkWorker *worker in workers)
            {
                index++;
                
                if (worker == networkWorker)
                {
                    [workers removeObjectAtIndex:(NSUInteger)index];
                    
                    break;
                }
            }
        }];
    }];
}

- (void)updatePts:(int)pts date:(int)date seq:(int)seq
{
#if TGUseModernNetworking
    [_updateService updatePts:pts date:date seq:seq];
#else
    [[TGSession instance] _updatePts:pts date:date seq:seq];
#endif
}

- (void)switchBackends
{
#if TGUseModernNetworking
    if (_isTestingEnvironment)
        [_settingsKeychain setObject:@"production" forKey:@"environmentId" group:@"environment"];
    else
        [_settingsKeychain setObject:@"testing" forKey:@"environmentId" group:@"environment"];
    
    [TGTelegraphInstance willSwitchBackends];
    exit(0);
#else
    [[TGSession instance] switchBackends];
#endif
}

- (void)addRequest:(MTRequest *)request
{
    [_requestService addRequest:request];
}

- (NSObject *)performRpc:(TLMetaRpc *)rpc completionBlock:(void (^)(id<TLObject> response, int64_t responseTime, TLError *error))completionBlock progressBlock:(void (^)(int length, float progress))progressBlock requiresCompletion:(bool)requiresCompletion requestClass:(int)requestClass
{
    return [self performRpc:rpc completionBlock:completionBlock progressBlock:progressBlock requiresCompletion:requiresCompletion requestClass:requestClass datacenterId:INT_MAX];
}

- (NSObject *)performRpc:(TLMetaRpc *)rpc completionBlock:(void (^)(id<TLObject> response, int64_t responseTime, TLError *error))completionBlock progressBlock:(void (^)(int length, float progress))progressBlock requiresCompletion:(bool)requiresCompletion requestClass:(int)requestClass datacenterId:(int)datacenterId
{
    return [self performRpc:rpc completionBlock:completionBlock progressBlock:progressBlock quickAckBlock:nil requiresCompletion:requiresCompletion requestClass:requestClass datacenterId:datacenterId];
}

- (NSObject *)performRpc:(TLMetaRpc *)rpc completionBlock:(void (^)(id<TLObject> response, int64_t responseTime, TLError *error))completionBlock progressBlock:(void (^)(int length, float progress))progressBlock quickAckBlock:(void (^)())quickAckBlock requiresCompletion:(bool)requiresCompletion requestClass:(int)requestClass datacenterId:(int)datacenterId
{
#if TGUseModernNetworking
    if (datacenterId != INT_MAX && datacenterId != 1)
        return nil;
    
    MTRequest *request = [[MTRequest alloc] init];
    request.body = rpc;
    [request setCompleted:^(id result, NSTimeInterval timestamp, id error)
    {
        [ActionStageInstance() dispatchOnStageQueue:^
        {
            if (completionBlock != nil)
                completionBlock(result, (int64_t)(timestamp * 4294967296.0), error);
        }];
    }];
    
    if (quickAckBlock != nil)
        [request setAcknowledgementReceived:quickAckBlock];
    
    static NSArray *sequentialMessageClasses = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        sequentialMessageClasses = @[
            [TLRPCmessages_sendMessage class],
            [TLRPCmessages_sendMedia class],
            [TLRPCmessages_forwardMessage class],
            [TLRPCmessages_sendEncrypted class],
            [TLRPCmessages_sendEncryptedFile class]
        ];
    });
    
    for (Class sequentialClass in sequentialMessageClasses)
    {
        if ([rpc isKindOfClass:sequentialClass])
        {
            [request setShouldDependOnRequest:^bool (MTRequest *anotherRequest)
            {
                for (Class sequentialClass in sequentialMessageClasses)
                {
                    if ([anotherRequest.body isKindOfClass:sequentialClass])
                        return true;
                }
                
                return false;
            }];
            
            break;
        }
    }
    
    if ([request.body isKindOfClass:[TLRPCmessages_sendMessage class]] || [request.body isKindOfClass:[TLRPCmessages_forwardMessage class]] || [request.body isKindOfClass:[TLRPCmessages_sendEncrypted class]])
        request.hasHighPriority = true;
    
    [request setShouldContinueExecutionWithErrorContext:^bool(__unused MTRequestErrorContext *errorContext)
    {
        if (requestClass & 256/*TGRequestClassFailOnServerErrors*/)
            return errorContext.internalServerErrorCount < 5;
        return true;
    }];
    
    [_requestService addRequest:request];
    return request.internalId;
#else
    return [[TGSession instance] performRpc:rpc completionBlock:completionBlock progressBlock:progressBlock quickAckBlock:quickAckBlock requiresCompletion:requiresCompletion requestClass:requestClass datacenterId:datacenterId];
#endif
}

- (void)cancelRpc:(id)token
{
#if TGUseModernNetworking
    [_requestService removeRequestByInternalId:token];
#else
    [[TGSession instance] cancelRpc:token notifyServer:true];
#endif
}

- (bool)isNetworkAvailable
{
#if TGUseModernNetworking
    return _isNetworkAvailable;
#else
    return ![[TGSession instance] isOffline];
#endif
}

- (bool)isConnecting
{
#if TGUseModernNetworking
    return !_isConnected;
#else
    return [[TGSession instance] isConnecting];
#endif
}

- (bool)isUpdating
{
#if TGUseModernNetworking
    return _isUpdatingConnectionContext || _isPerformingServiceTasks;
#else
    return [[TGSession instance] isWaitingForFirstData];
#endif
}

- (void)wakeUpWithCompletion:(void (^)())completion
{
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        TGLog(@"[TGTelegramNetworking waking up]");
        
        /*if (_currentWakeUpCompletion != nil)
        {
            TGLog(@"[TGTelegramNetworking waking up]");
            _currentWakeUpCompletion();
            _currentWakeUpCompletion = nil;
        }*/
        
        [_currentWakeUpCompletions addObject:[completion copy]];
        
        _completeWakeUpToken++;
        int token = _completeWakeUpToken;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
        {
            if (token == _completeWakeUpToken)
            {
                if ([self _isReadyToBeSuspended])
                    [self completeWakeUpIfAny:@"2s match"];
            }
        });
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(15.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
        {
            if (token == _completeWakeUpToken)
            {
                [self completeWakeUpIfAny:@"10s timeout"];
            }
        });
    }];
}

- (void)completeWakeUpIfAny:(NSString *)reason
{
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        if (_currentWakeUpCompletions.count != 0)
        {
            _completeWakeUpToken++;
            
            TGLog(@"[TGTelegramNetworking completed wake up: %@ (%d)]", reason, _currentWakeUpCompletions.count);
            
            for (dispatch_block_t block in _currentWakeUpCompletions)
            {
                block();
            }
            
            [_currentWakeUpCompletions removeAllObjects];
        }
    }];
}

- (void)requestMessageServiceAuthorizationRequired:(MTRequestMessageService *)__unused requestMessageService
{
    [_mtProto resetSessionInfo];
    
    [_context removeAllAuthTokens];
    
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        [ActionStageInstance() requestActor:[NSString stringWithFormat:@"/tg/auth/logout/(%d)", TGTelegraphInstance.clientUserId] options:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:true] forKey:@"force"] watcher:TGTelegraphInstance];
    }];
}

- (void)mtProtoNetworkAvailabilityChanged:(MTProto *)__unused mtProto isNetworkAvailable:(bool)isNetworkAvailable
{
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        _isNetworkAvailable = isNetworkAvailable;
        [self dispatchNetworkState];
    }];
}

- (void)mtProtoConnectionStateChanged:(MTProto *)__unused mtProto isConnected:(bool)isConnected
{
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        _isConnected = isConnected;
        [self dispatchNetworkState];
    }];
}

- (void)mtProtoConnectionContextUpdateStateChanged:(MTProto *)__unused mtProto isUpdatingConnectionContext:(bool)isUpdatingConnectionContext
{
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        _isUpdatingConnectionContext = isUpdatingConnectionContext;
        [self dispatchNetworkState];
    }];
}

- (void)mtProtoServiceTasksStateChanged:(MTProto *)__unused mtProto isPerformingServiceTasks:(bool)isPerformingServiceTasks
{
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        _isPerformingServiceTasks = isPerformingServiceTasks;
        [self dispatchNetworkState];
    }];
}

- (bool)_isReadyToBeSuspended
{
    int state = [ActionStageInstance() requestActorStateNow:@"/tg/service/updatestate"] ? 1 : 0;
    if (_isUpdatingConnectionContext || _isPerformingServiceTasks)
        state |= 1;
    if (!_isConnected)
        state |= 2;
    if (!_isNetworkAvailable)
        state |= 4;
    
    return state == 0;
}

- (void)dispatchNetworkState
{
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        _dispatchNetworkStateToken++;
        int token = _dispatchNetworkStateToken;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.08 * NSEC_PER_SEC)), [ActionStageInstance() globalStageDispatchQueue], ^
        {
            if (token != _dispatchNetworkStateToken)
                return;
            
            TGLog(@"[TGTelegramNetworking state: %d %d %d %d]", (int)_isUpdatingConnectionContext, (int)_isPerformingServiceTasks, (int)_isConnected, (int)_isNetworkAvailable);
            
            int state = [ActionStageInstance() requestActorStateNow:@"/tg/service/updatestate"] ? 1 : 0;
            if (_isUpdatingConnectionContext || _isPerformingServiceTasks)
                state |= 1;
            if (!_isConnected)
                state |= 2;
            if (!_isNetworkAvailable)
                state |= 4;
            
            [ActionStageInstance() dispatchResource:@"/tg/service/synchronizationstate" resource:[[SGraphObjectNode alloc] initWithObject:[NSNumber numberWithInt:state]]];
        });
        
        int wakeupToken = _completeWakeUpToken;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
        {
            if (wakeupToken == _completeWakeUpToken)
            {
                if ([self _isReadyToBeSuspended])
                    [self completeWakeUpIfAny:@"state 1 match"];
            }
        });
    }];
}

- (void)actionStageResourceDispatched:(NSString *)path resource:(id)resource arguments:(id)__unused arguments
{
    if ([path isEqualToString:@"/tg/service/synchronizationstate"])
    {
        int state = [((SGraphObjectNode *)resource).object intValue];
        if (state == 0 && _isConnected && !_isUpdatingConnectionContext && !_isPerformingServiceTasks && _isNetworkAvailable)
            [self completeWakeUpIfAny:@"state 2 match"];
    }
}

@end
