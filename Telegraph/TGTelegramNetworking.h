/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <Foundation/Foundation.h>

typedef enum {
    TGRequestClassGeneric = 1,
    TGRequestClassDownloadMedia = 2,
    TGRequestClassUploadMedia = 4,
    TGRequestClassEnableUnauthorized = 8,
    TGRequestClassEnableMerging = 16,
    TGRequestClassHidesActivityIndicator = 64,
    TGRequestClassLargeMedia = 128,
    TGRequestClassFailOnServerErrors = 256
} TGRequestClass;

#define TG_DEFAULT_DATACENTER_ID INT_MAX

#define TGUseModernNetworking true//defined(DEBUG)

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

- (void)updatePts:(int)pts date:(int)date seq:(int)seq;

- (MTContext *)context;
- (MTProto *)mtProto;

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

- (NSObject *)performRpc:(TLMetaRpc *)rpc completionBlock:(void (^)(id<TLObject> response, int64_t responseTime, TLError *error))completionBlock progressBlock:(void (^)(int length, float progress))progressBlock requiresCompletion:(bool)requiresCompletion requestClass:(int)requestClass;
- (NSObject *)performRpc:(TLMetaRpc *)rpc completionBlock:(void (^)(id<TLObject> response, int64_t responseTime, TLError *error))completionBlock progressBlock:(void (^)(int length, float progress))progressBlock requiresCompletion:(bool)requiresCompletion requestClass:(int)requestClass datacenterId:(int)datacenterId;
- (NSObject *)performRpc:(TLMetaRpc *)rpc completionBlock:(void (^)(id<TLObject> response, int64_t responseTime, TLError *error))completionBlock progressBlock:(void (^)(int length, float progress))progressBlock quickAckBlock:(void (^)())quickAckBlock requiresCompletion:(bool)requiresCompletion requestClass:(int)requestClass datacenterId:(int)datacenterId;

- (void)cancelRpc:(id)token;

- (bool)isNetworkAvailable;
- (bool)isConnecting;
- (bool)isUpdating;

- (void)wakeUpWithCompletion:(void (^)())completion;

@end
