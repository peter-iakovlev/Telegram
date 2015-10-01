#import <Foundation/Foundation.h>
#import <SSignalKit/SSignalKit.h>

typedef enum {
    TGAudioSessionTypePlayVoice,
    TGAudioSessionTypePlayMusic,
    TGAudioSessionTypePlayVideo,
    TGAudioSessionTypePlayAndRecord,
    TGAudioSessionTypePlayAndRecordHeadphones
} TGAudioSessionType;


typedef enum {
    TGAudioSessionRouteChangePause,
    TGAudioSessionRouteChangeResume
} TGAudioSessionRouteChange;

@interface TGAudioSessionManager : NSObject

+ (TGAudioSessionManager *)instance;

- (id<SDisposable>)requestSessionWithType:(TGAudioSessionType)type interrupted:(void (^)())interrupted;
- (void)cancelCurrentSession;
+ (SSignal *)routeChange;

@end
