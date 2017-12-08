#import <Foundation/Foundation.h>
#import <SSignalKit/SSignalKit.h>
#import <CoreLocation/CoreLocation.h>

@class TGMessage;

@interface TGLiveLocationSignals : NSObject

+ (SSignal *)updateLiveLocationWithPeerId:(int64_t)peerId messageId:(int32_t)messageId coordinate:(CLLocationCoordinate2D)coordinate;
+ (SSignal *)stopLiveLocationWithPeerId:(int64_t)peerId messageId:(int32_t)messageId;
+ (SSignal *)recentLocationsForPeerId:(int64_t)peerId limit:(int32_t)limit;

+ (SSignal *)liveLocationsForPeerId:(int64_t)peerId includeExpired:(bool)includeExpired onlyLocal:(bool)onlyLocal;
+ (SSignal *)remainingTimeForMessage:(TGMessage *)message;

@end
