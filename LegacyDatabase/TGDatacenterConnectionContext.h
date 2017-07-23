#import <Foundation/Foundation.h>

#import <MTProtoKitDynamic/MTContext.h>
#import <MTProtoKitDynamic/MTProto.h>
#import <MTProtoKitDynamic/MTRequestMessageService.h>
#import <SSignalKit/SSignalKit.h>
#import "ApiLayer70.h"

@interface TGDatacenterConnectionContext : NSObject

@property (nonatomic, readonly) NSInteger datacenterId;
@property (nonatomic, strong, readonly) MTContext *mtContext;
@property (nonatomic, strong, readonly) MTProto *mtProto;
@property (nonatomic, strong, readonly) MTRequestMessageService *mtRequestService;

- (instancetype)initWithDatacenterId:(NSInteger)datacenterId mtContext:(MTContext *)mtContext mtProto:(MTProto *)mtProto mtRequestService:(MTRequestMessageService *)mtRequestService;

- (SSignal *)function:(Api70_FunctionContext *)functionContext;

@end

@interface TGPooledDatacenterConnectionContext : NSObject

@property (nonatomic, strong, readonly) TGDatacenterConnectionContext *context;
@property (nonatomic, copy, readonly) void (^returnContext)(TGDatacenterConnectionContext *);

- (instancetype)initWithDatacenterConnectionContext:(TGDatacenterConnectionContext *)context returnContext:(void (^)(TGDatacenterConnectionContext *))returnContext;

@end
