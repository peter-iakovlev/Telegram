#import <SSignalKit/SSignalKit.h>

@class TGBridgeSubscription;
@class TGFileCache;

@interface TGBridgeClient : NSObject

- (SSignal *)requestSignalWithSubscription:(TGBridgeSubscription *)subscription;
- (SSignal *)contextSignal;

@property (nonatomic, readonly) NSDictionary *startupData;
- (void)saveStartupData:(NSDictionary *)dataObject;

- (SSignal *)fileSignalForKey:(NSString *)key;
- (NSArray *)stickerPacks;

- (void)handleDidBecomeActive;
- (void)handleWillResignActive;

- (void)sendFileWithURL:(NSURL *)url metadata:(NSDictionary *)metadata;

- (void)updateReachability;
- (bool)isServerReachable;
- (bool)isActuallyReachable;
- (SSignal *)actualReachabilitySignal;
- (SSignal *)reachabilitySignal;

- (SSignal *)userInfoSignal;

- (SSignal *)sendMessageData:(NSData *)messageData;
- (void)sendRawMessageData:(NSData *)messageData replyHandler:(void (^)(NSData *))replyHandler errorHandler:(void (^)(NSError *))errorHandler;

- (void)transferUserInfo:(NSDictionary *)userInfo;

+ (instancetype)instance;

@end
