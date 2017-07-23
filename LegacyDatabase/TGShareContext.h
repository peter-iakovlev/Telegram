#import <Foundation/Foundation.h>

#import <MTProtoKitDynamic/MTContext.h>
#import <MTProtoKitDynamic/MTProto.h>
#import <MTProtoKitDynamic/MTRequestMessageService.h>
#import <SSignalKit/SSignalKit.h>

#import <SSignalKit/SSignalKit.h>
#import <LegacyDatabase/ApiLayer70.h>

#import <LegacyDatabase/TGModernCache.h>
#import <LegacyDatabase/TGMemoryImageCache.h>
#import <LegacyDatabase/TGMemoryCache.h>

#import <LegacyDatabase/TGDatacenterConnectionContext.h>

@class TGLegacyDatabase;

@interface TGShareContext : NSObject

@property (nonatomic, strong, readonly) NSURL *containerUrl;

@property (nonatomic, readonly) int32_t clientUserId;

@property (nonatomic, strong, readonly) MTContext *mtContext;
@property (nonatomic, strong, readonly) MTProto *mtProto;
@property (nonatomic, strong, readonly) MTRequestMessageService *mtRequestService;
@property (nonatomic, strong, readonly) TGLegacyDatabase *legacyDatabase;

@property (nonatomic, strong, readonly) TGModernCache *persistentCache;
@property (nonatomic, strong, readonly) TGMemoryImageCache *memoryImageCache;
@property (nonatomic, strong, readonly) TGMemoryCache *memoryCache;
@property (nonatomic, strong, readonly) SThreadPool *sharedThreadPool;

- (instancetype)initWithContainerUrl:(NSURL *)containerUrl mtContext:(MTContext *)mtContext mtProto:(MTProto *)mtProto mtRequestService:(MTRequestMessageService *)mtRequestService clientUserId:(int32_t)clientUserId legacyDatabase:(TGLegacyDatabase *)legacyDatabase;

- (SSignal *)function:(Api70_FunctionContext *)functionContext;
- (SSignal *)datacenter:(NSInteger)datacenterId function:(Api70_FunctionContext *)functionContext;

- (SSignal *)connectionContextForDatacenter:(NSInteger)datacenterId;

@end
