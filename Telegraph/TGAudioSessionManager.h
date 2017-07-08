#import <Foundation/Foundation.h>
#import <SSignalKit/SSignalKit.h>
#import <AVFoundation/AVFoundation.h>

typedef enum {
    TGAudioSessionTypePlayVoice,
    TGAudioSessionTypePlayMusic,
    TGAudioSessionTypePlayVideo,
    TGAudioSessionTypePlayEmbedVideo,
    TGAudioSessionTypePlayAndRecord,
    TGAudioSessionTypePlayAndRecordHeadphones,
    TGAudioSessionTypeCall
} TGAudioSessionType;


typedef enum {
    TGAudioSessionRouteChangePause,
    TGAudioSessionRouteChangeResume
} TGAudioSessionRouteChange;

@class TGAudioRoute;

@interface TGAudioSessionManager : NSObject

+ (TGAudioSessionManager *)instance;

- (id<SDisposable>)requestSessionWithType:(TGAudioSessionType)type interrupted:(void (^)())interrupted;
- (void)cancelCurrentSession;
+ (SSignal *)routeChange;

- (void)applyRoute:(TGAudioRoute *)route;

@end


@interface TGAudioRoute : NSObject

@property (nonatomic, readonly) NSString *uid;
@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) bool isBuiltIn;
@property (nonatomic, readonly) bool isLoudspeaker;
@property (nonatomic, readonly) bool isBluetooth;
@property (nonatomic, readonly) bool isHeadphones;

@property (nonatomic, readonly) AVAudioSessionPortDescription *device;

+ (instancetype)routeWithDescription:(AVAudioSessionPortDescription *)description;
+ (instancetype)routeForBuiltIn:(bool)headphones;
+ (instancetype)routeForSpeaker;

@end
