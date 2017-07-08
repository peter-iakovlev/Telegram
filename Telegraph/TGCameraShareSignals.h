#import <SSignalKit/SSignalKit.h>

@interface TGCameraShareSignals : NSObject

+ (SSignal *)shareMedia:(NSDictionary *)description peerIds:(NSArray *)peerIds;

@end
