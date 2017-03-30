#import <SSignalKit/SSignalKit.h>

@class TGBridgeContext;
@class TGBridgeMessage;

@interface TGBridgeServer : NSObject

@property (nonatomic, readonly) NSURL *temporaryFilesURL;

@property (nonatomic, readonly) bool isPaired;
@property (nonatomic, readonly) bool isWatchAppInstalled;
@property (nonatomic, readonly) bool isRunning;
- (void)startRunning;
- (void)startServices;

- (SSignal *)watchAppInstalledSignal;

- (void)setAuthorized:(bool)authorized userId:(int32_t)userId;
- (void)setPasscodeEnabled:(bool)passcodeEnabled passcodeEncrypted:(bool)passcodeEncrypted;
- (void)setMicAccessAllowed:(bool)allowed;
- (void)setCustomLocalizationEnabled:(bool)enabled;
- (void)setStartupData:(NSDictionary *)dataObject micAccessAllowed:(bool)micAccessAllowed;

- (void)sendFileWithURL:(NSURL *)url metadata:(NSDictionary *)metadata;

- (SSignal *)serviceSignalForKey:(NSString *)key producer:(SSignal *(^)())producer;
- (void)startSignalForKey:(NSString *)key producer:(SSignal *(^)())producer;

- (SSignal *)pipeForKey:(NSString *)key;
- (void)putNext:(id)next forKey:(NSString *)key;

- (NSInteger)wakeupNetwork;
- (void)suspendNetworkIfReady:(NSInteger)token;

- (SSignal *)server;

+ (instancetype)instance;
+ (SSignal *)instanceSignal;
+ (bool)serverQueueIsCurrent;

@end
