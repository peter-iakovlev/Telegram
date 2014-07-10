/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGDatacenterWatchdogActor.h"

#import "ActionStage.h"

#import <MTProtoKit/MTContext.h>
#import <MTProtoKit/MTProto.h>
#import <MTProtoKit/MTTimer.h>
#import <MTProtoKit/MTRequestMessageService.h>
#import <MTProtoKit/MTRequest.h>
#import <MTProtoKit/MTDatacenterAddressSet.h>
#import <MTProtoKit/MTDatacenterAddress.h>

#import "TGTelegramNetworking.h"

#import "TL/TLMetaScheme.h"

@interface TGDatacenterWatchdogActor ()
{
    MTTimer *_startupTimer;
    MTTimer *_addOneMoreDatacenterTimer;
    
    NSMutableDictionary *_mtProtoByDatacenterId;
    NSMutableDictionary *_requestServiceByDatacenterId;
}

@end

@implementation TGDatacenterWatchdogActor

+ (void)load
{
    [ASActor registerActorClass:self];
}

+ (NSString *)genericPath
{
    return @"/tg/datacenterWatchdog";
}

- (instancetype)initWithPath:(NSString *)path
{
    self = [super initWithPath:path];
    if (self != nil)
    {
        _mtProtoByDatacenterId = [[NSMutableDictionary alloc] init];
        _requestServiceByDatacenterId = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [_startupTimer invalidate];
    _startupTimer = nil;
    
    [_addOneMoreDatacenterTimer invalidate];
    _addOneMoreDatacenterTimer = nil;
    
    NSDictionary *mtProtoByDatacenterId = [[NSDictionary alloc] initWithDictionary:_mtProtoByDatacenterId];
    _mtProtoByDatacenterId = nil;
    
    NSDictionary *requestServiceByDatacenterId = [[NSDictionary alloc] initWithDictionary:_requestServiceByDatacenterId];
    _requestServiceByDatacenterId = nil;
    
    [mtProtoByDatacenterId enumerateKeysAndObjectsUsingBlock:^(NSNumber *nDatacenterId, MTProto *mtProto, __unused BOOL *stop)
    {
        [mtProto removeMessageService:requestServiceByDatacenterId[nDatacenterId]];
        [mtProto stop];
    }];
}

- (void)execute:(NSDictionary *)__unused options
{
    __weak TGDatacenterWatchdogActor *weakSelf = self;
    _startupTimer = [[MTTimer alloc] initWithTimeout:8.0 repeat:false completion:^
    {
        __strong TGDatacenterWatchdogActor *strongSelf = weakSelf;
        [strongSelf begin];
    } queue:[ActionStageInstance() globalStageDispatchQueue]];
    [_startupTimer start];
}

- (void)begin
{
    MTContext *context = [[TGTelegramNetworking instance] context];
    if (context == nil)
        [ActionStageInstance() actionFailed:self.path reason:-1];
    else
    {
        [self addOneMoreDatacenter];
        
        __weak TGDatacenterWatchdogActor *weakSelf = self;
        _addOneMoreDatacenterTimer = [[MTTimer alloc] initWithTimeout:10.0 repeat:true completion:^
        {
            __strong TGDatacenterWatchdogActor *strongSelf = weakSelf;
            [strongSelf addOneMoreDatacenter];
        } queue:[ActionStageInstance() globalStageDispatchQueue]];
        [_addOneMoreDatacenterTimer start];
    }
}

- (void)addOneMoreDatacenter
{
    MTContext *context = [[TGTelegramNetworking instance] context];
    
    for (NSNumber *nDatacenterId in [context knownDatacenterIds])
    {
        if (_mtProtoByDatacenterId[nDatacenterId] == nil)
        {
            [self requestNetworkConfigFromDatacenter:[nDatacenterId integerValue]];
            
            break;
        }
    }
}

- (void)requestNetworkConfigFromDatacenter:(NSInteger)datacenterId
{
    TGLog(@"[TGDatacenterWatchdogActor#%p requesting network config from %d]", self, (int)datacenterId);
    
    MTContext *context = [[TGTelegramNetworking instance] context];
    
    MTProto *mtProto = [[MTProto alloc] initWithContext:context datacenterId:datacenterId];
    MTRequestMessageService *requestService = [[MTRequestMessageService alloc] initWithContext:context];
    [mtProto addMessageService:requestService];
    
    _mtProtoByDatacenterId[@(datacenterId)] = mtProto;
    _requestServiceByDatacenterId[@(datacenterId)] = requestService;
    
    MTRequest *request = [[MTRequest alloc] init];
    
    request.body = [[TLRPChelp_getConfig$help_getConfig alloc] init];
    
    __weak TGDatacenterWatchdogActor *weakSelf = self;
    [request setCompleted:^(TLConfig *result, __unused NSTimeInterval timestamp, id error)
    {
        [ActionStageInstance() dispatchOnStageQueue:^
        {
            __strong TGDatacenterWatchdogActor *strongSelf = weakSelf;
            if (error == nil)
            {
                [strongSelf processConfig:result fromDatacenterId:datacenterId];
            }
        }];
    }];
    
    [requestService addRequest:request];
}

- (void)processConfig:(TLConfig *)config fromDatacenterId:(NSInteger)datacenterId
{
    MTContext *context = [[TGTelegramNetworking instance] context];
    
    [context performBatchUpdates:^
    {
        NSMutableDictionary *addressListByDatacenterId = [[NSMutableDictionary alloc] init];
        
        for (TLDcOption *dcOption in config.dc_options)
        {
            MTDatacenterAddress *configAddress = [[MTDatacenterAddress alloc] initWithIp:dcOption.ip_address port:(uint16_t)dcOption.port];
            
            NSMutableArray *array = addressListByDatacenterId[@(dcOption.n_id)];
            if (array == nil)
            {
                array = [[NSMutableArray alloc] init];
                addressListByDatacenterId[@(dcOption.n_id)] = array;
            }
            
            if (![array containsObject:configAddress])
                [array addObject:configAddress];
        }
        
        [addressListByDatacenterId enumerateKeysAndObjectsUsingBlock:^(NSNumber *nDatacenterId, NSArray *addressList, __unused BOOL *stop)
        {
            MTDatacenterAddressSet *addressSet = [[MTDatacenterAddressSet alloc] initWithAddressList:addressList];

            MTDatacenterAddressSet *currentAddressSet = [context addressSetForDatacenterWithId:[nDatacenterId integerValue]];
            
            if (currentAddressSet == nil || ![addressSet isEqual:currentAddressSet])
            {
                TGLog(@"[TGDatacenterWatchdogActor#%p updating datacenter %d address set to %@]", self, [nDatacenterId intValue], addressSet);
                [context updateAddressSetForDatacenterWithId:[nDatacenterId integerValue] addressSet:addressSet];
            }
        }];
        
        [ActionStageInstance() dispatchOnStageQueue:^
        {
            TGLog(@"[TGDatacenterWatchdogActor#%p processed %d datacenter addresses from datacenter %d]", self, (int)config.dc_options.count, (int)datacenterId);
            
            [ActionStageInstance() actionCompleted:self.path result:nil];
        }];
    }];
}

@end
