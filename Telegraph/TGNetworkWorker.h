//
//  TGDownloadWorker.h
//  Telegraph
//
//  Created by Peter on 14/02/14.
//
//

#import <Foundation/Foundation.h>

@class MTContext;

@class TGNetworkWorker;
@class MTRequestMessageService;
@class MTRequest;
@class TGNetworkWorkerGuard;
@class MTNetworkUsageCalculationInfo;

@protocol TGNetworkWorkerDelegate <NSObject>

@optional

- (void)networkWorkerReadyToBeRemoved:(TGNetworkWorker *)networkWorker;
- (void)networkWorkerDidBecomeAvailable:(TGNetworkWorker *)networkWorker;

@end

@interface TGNetworkWorker : NSObject

@property (nonatomic, weak) id<TGNetworkWorkerDelegate> delegate;

@property (nonatomic, readonly) NSInteger datacenterId;

@property (nonatomic, strong) MTNetworkUsageCalculationInfo *usageCalculationInfo;
    
@property (nonatomic, readonly) bool isCdn;

- (instancetype)initWithContext:(MTContext *)context datacenterId:(NSInteger)datacenterId masterDatacenterId:(NSInteger)masterDatacenterId isCdn:(bool)isCdn;

- (bool)isBusy;
- (void)setIsBusy:(bool)isBusy;
- (void)updateReadyToBeRemoved;
- (void)addRequest:(MTRequest *)request;
- (void)cancelRequestById:(id)requestId;
- (void)cancelRequestByIdSoft:(id)requestId;
- (void)ensureConnection;

@end

@interface TGNetworkWorkerGuard : NSObject

@property (nonatomic, weak) TGNetworkWorker *worker;

- (instancetype)initWithWorker:(TGNetworkWorker *)worker;
- (TGNetworkWorker *)strongWorker;
- (void)releaseWorker;

@end
