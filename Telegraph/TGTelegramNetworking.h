/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <Foundation/Foundation.h>

#import <SSignalKit/SSignalKit.h>

typedef enum {
    TGRequestClassGeneric = 1,
    TGRequestClassDownloadMedia = 2,
    TGRequestClassUploadMedia = 4,
    TGRequestClassEnableUnauthorized = 8,
    TGRequestClassEnableMerging = 16,
    TGRequestClassHidesActivityIndicator = 64,
    TGRequestClassLargeMedia = 128,
    TGRequestClassFailOnServerErrors = 256,
    TGRequestClassFailOnFloodErrors = 512,
    TGRequestClassPassthroughPasswordNeeded = 1024,
    TGRequestClassIgnorePasswordEntryRequired = 2048
} TGRequestClass;

#define TG_DEFAULT_DATACENTER_ID INT_MAX

#define TGUseModernNetworking true//defined(DEBUG)

#import <MTProtoKit/MTRequest.h>

@class MTContext;
@class MTProto;
@class MTRequest;
@class TLMetaRpc;
@class TLError;
@class MTDatacenterAddress;
@class TGNetworkWorker;
@class TGNetworkWorkerGuard;
@protocol TLObject;

@interface TGTelegramNetworking : NSObject

+ (TGTelegramNetworking *)instance;

- (SMulticastSignalManager *)genericTasksSignalManager;

- (void)updatePts:(int)pts ptsCount:(int)ptsCount seq:(int)seq;
- (void)addUpdates:(id)updates;

- (MTContext *)context;
- (MTProto *)mtProto;

- (void)removeCredentialsForExtensions;
- (void)exportCredentialsForExtensions;

- (NSTimeInterval)globalTime;
- (NSTimeInterval)timeOffset;
- (NSTimeInterval)approximateRemoteTime;

- (void)loadCredentials;
- (void)start;
- (void)pause;
- (void)resume;

- (void)moveToDatacenterId:(NSInteger)datacenterId;
- (void)restartWithCleanCredentials;

- (void)clearExportedTokens;
- (void)mergeDatacenterAddress:(NSInteger)datacenterId address:(MTDatacenterAddress *)address;

- (void)performDeferredServiceTasks;

- (NSInteger)masterDatacenterId;
- (id)requestDownloadWorkerForDatacenterId:(NSInteger)datacenterId completion:(void (^)(TGNetworkWorkerGuard *))completion;
- (void)cancelDownloadWorkerRequestByToken:(id)token;

- (void)addRequest:(MTRequest *)request;

// legacy
- (void)switchBackends;

- (NSObject *)performRpc:(TLMetaRpc *)rpc completionBlock:(void (^)(id<TLObject> response, int64_t responseTime, MTRpcError *error))completionBlock progressBlock:(void (^)(int length, float progress))progressBlock requiresCompletion:(bool)requiresCompletion requestClass:(int)requestClass;
- (NSObject *)performRpc:(TLMetaRpc *)rpc completionBlock:(void (^)(id<TLObject> response, int64_t responseTime, MTRpcError *error))completionBlock progressBlock:(void (^)(int length, float progress))progressBlock requiresCompletion:(bool)requiresCompletion requestClass:(int)requestClass datacenterId:(int)datacenterId;
- (NSObject *)performRpc:(TLMetaRpc *)rpc completionBlock:(void (^)(id<TLObject> response, int64_t responseTime, MTRpcError *error))completionBlock progressBlock:(void (^)(int length, float progress))progressBlock quickAckBlock:(void (^)())quickAckBlock requiresCompletion:(bool)requiresCompletion requestClass:(int)requestClass datacenterId:(int)datacenterId;

- (void)cancelRpc:(id)token;

- (bool)isNetworkAvailable;
- (bool)isConnecting;
- (bool)isUpdating;

- (bool)_isReadyToBeSuspended;

- (void)wakeUpWithCompletion:(void (^)())completion;

- (SSignal *)downloadWorkerForDatacenterId:(NSInteger)datacenterId;
- (SSignal *)requestSignal:(TLMetaRpc *)rpc;
- (SSignal *)requestSignal:(TLMetaRpc *)rpc continueOnServerErrors:(bool)continueOnServerErrors;
- (SSignal *)requestSignal:(TLMetaRpc *)rpc requestClass:(int)requestClass;
- (SSignal *)requestSignal:(TLMetaRpc *)rpc worker:(TGNetworkWorkerGuard *)worker;

- (NSString *)extractNetworkErrorType:(id)error;

@end

@interface MTRequest (LegacyTL)

- (void)setBody:(TLMetaRpc *)body;

@end
