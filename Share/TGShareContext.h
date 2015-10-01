#import <Foundation/Foundation.h>

#import <MTProtoKit/MTContext.h>
#import <MTProtoKit/MTProto.h>
#import <MTProtoKit/MTRequestMessageService.h>
#import <SSignalKit/SSignalKit.h>
#import "ApiLayer38.h"

#import "TGModernCache.h"
#import "TGMemoryImageCache.h"
#import "TGMemoryCache.h"

#import "TGDatacenterConnectionContext.h"

@interface TGShareContext : NSObject

@property (nonatomic, strong, readonly) NSURL *containerUrl;

@property (nonatomic, strong, readonly) MTContext *mtContext;
@property (nonatomic, strong, readonly) MTProto *mtProto;
@property (nonatomic, strong, readonly) MTRequestMessageService *mtRequestService;

@property (nonatomic, strong, readonly) TGModernCache *persistentCache;
@property (nonatomic, strong, readonly) TGMemoryImageCache *memoryImageCache;
@property (nonatomic, strong, readonly) TGMemoryCache *memoryCache;
@property (nonatomic, strong, readonly) SThreadPool *sharedThreadPool;

- (instancetype)initWithContainerUrl:(NSURL *)containerUrl mtContext:(MTContext *)mtContext mtProto:(MTProto *)mtProto mtRequestService:(MTRequestMessageService *)mtRequestService;

- (SSignal *)function:(Api38_FunctionContext *)functionContext;
- (SSignal *)datacenter:(NSInteger)datacenterId function:(Api38_FunctionContext *)functionContext;

- (SSignal *)connectionContextForDatacenter:(NSInteger)datacenterId;


@end
