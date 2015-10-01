#import <SSignalKit/SSignalKit.h>

@interface TGBridgeSignalManager : NSObject

- (bool)startSignalForKey:(NSString *)key producer:(SSignal *(^)())producer;
- (void)haltSignalForKey:(NSString *)key;
- (void)haltAllSignals;

@end
