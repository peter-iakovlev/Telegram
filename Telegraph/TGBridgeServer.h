#import <SSignalKit/SSignalKit.h>

@class TGBridgeContext;

@interface TGBridgeServer : NSObject

@property (nonatomic, readonly) NSURL *temporaryFilesURL;

@property (nonatomic, readonly) bool isWatchAppInstalled;
@property (nonatomic, readonly) bool isRunning;
- (void)startRunning;
- (void)startServices;

- (void)setAuthorized:(bool)authorized userId:(int32_t)userId;
- (void)setPasscodeEnabled:(bool)passcodeEnabled passcodeEncrypted:(bool)passcodeEncrypted;
- (void)setStartupData:(NSDictionary *)dataObject;

- (void)sendFileWithURL:(NSURL *)url key:(NSString *)key;

- (SSignal *)serviceSignalForKey:(NSString *)key producer:(SSignal *(^)())producer;

- (NSInteger)wakeupNetwork;
- (void)suspendNetworkIfReady:(NSInteger)token;

+ (instancetype)instance;

@end
