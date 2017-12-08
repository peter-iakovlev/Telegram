#import <SSignalKit/SSignalKit.h>

@class TGLiveLocationSession;

@interface TGLiveLocationManager : NSObject

- (void)restoreSessions;

- (SSignal *)sessionForPeerId:(int64_t)peerId;
- (SSignal *)sessions;

- (void)startWithPeerId:(int64_t)peerId messageId:(int32_t)messageId period:(int32_t)period started:(int32_t)started;
- (void)stopWithPeerId:(int64_t)peerId;

- (id<SDisposable>)subscribeForFrequentLocationUpdatesWithPeerId:(int64_t)peerId;
- (void)performInfrequentLocationUpdate:(void (^)(bool))willPerform;

- (void)reset;

@end
