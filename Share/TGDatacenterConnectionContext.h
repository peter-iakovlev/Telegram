#import <Foundation/Foundation.h>

#import <MTProtoKit/MTContext.h>
#import <MTProtoKit/MTProto.h>
#import <MTProtoKit/MTRequestMessageService.h>
#import <SSignalKit/SSignalKit.h>
#import "ApiLayer38.h"

@interface TGDatacenterConnectionContext : NSObject

@property (nonatomic, strong, readonly) MTContext *mtContext;
@property (nonatomic, strong, readonly) MTProto *mtProto;
@property (nonatomic, strong, readonly) MTRequestMessageService *mtRequestService;

- (instancetype)initWithMtContext:(MTContext *)mtContext mtProto:(MTProto *)mtProto mtRequestService:(MTRequestMessageService *)mtRequestService;

- (SSignal *)function:(Api38_FunctionContext *)functionContext;

@end

@interface TGPooledDatacenterConnectionContext : NSObject

@property (nonatomic, strong, readonly) TGDatacenterConnectionContext *context;
@property (nonatomic, copy, readonly) void (^returnContext)(TGDatacenterConnectionContext *);

- (instancetype)initWithDatacenterConnectionContext:(TGDatacenterConnectionContext *)context returnContext:(void (^)(TGDatacenterConnectionContext *))returnContext;

@end