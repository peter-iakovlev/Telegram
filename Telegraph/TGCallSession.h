#import <SSignalKit/SSignalKit.h>
#import "TGCallState.h"
#import "TGAudioSessionManager.h"

@class TGUser;

@interface TGCallSession : NSObject

@property (nonatomic, readonly) bool outgoing;
@property (nonatomic, readonly) int64_t callId;
@property (nonatomic, readonly) int64_t accessHash;
@property (nonatomic, readonly) int64_t peerId;
@property (nonatomic, readonly) bool completed;
@property (nonatomic, readonly) bool hungUpOutside;

@property (nonatomic, assign) bool hasCallKit;

@property (nonatomic, copy) void (^onStartedConnecting)(void);
@property (nonatomic, copy) void (^onConnected)(void);

@property (nonatomic, strong) SVariable *audioSessionActivated;
@property (nonatomic, strong) SVariable *audioSessionDeactivated;

- (instancetype)initOutgoing:(bool)outgoing;
- (instancetype)initWithSignal:(SSignal *)signal outgoing:(bool)outgoing;

- (void)startWithSignal:(SSignal *)signal;

- (void)markCallAcceptedTime;
- (NSTimeInterval)callConnectionDuration;

- (void)acceptIncomingCall;
- (void)hangUpCurrentCall;
- (void)hangUpCurrentCall:(bool)external;
- (void)hangUpCurrentCallCompletion:(void (^)(void))completion;

- (void)toggleMute;
- (void)setMuted:(bool)muted;
- (void)toggleSpeaker;
- (void)applyAudioRoute:(TGAudioRoute *)audioRoute;

- (void)presentCallNotification:(int64_t)peerId;

- (NSTimeInterval)duration;

- (SSignal *)stateSignal;
- (SSignal *)debugSignal;
- (SSignal *)levelSignal;

- (void)setupAudioSession:(void (^)(void))completion;
+ (void)resetAudioSession;
+ (bool)hasMicrophoneAccess;

- (void)setDebugBitrate:(NSInteger)bitrate;
- (void)setDebugPacketLoss:(NSInteger)packetLossPercent;
- (void)setDebugP2PEnabled:(bool)enabled;

+ (NSTimeInterval)callReceiveTimeout;

+ (void)applyCallsConfig:(NSString *)data;

@end

typedef enum {
    TGCallTransmissionStateInitializing,
    TGCallTransmissionStateEstablished,
    TGCallTransmissionStateFailed,
    TGCallTransmissionStateReconnecting
} TGCallTransmissionState;

@interface TGCallSessionState : NSObject

@property (nonatomic, readonly) bool outgoing;
@property (nonatomic, readonly) TGCallState state;
@property (nonatomic, readonly) TGCallStateData *stateData;
@property (nonatomic, readonly) TGCallTransmissionState transmissionState;
@property (nonatomic, readonly) CFAbsoluteTime startTime;

@property (nonatomic, readonly) TGUser *peer;
@property (nonatomic, readonly) NSData *keySha256;

@property (nonatomic, strong, readonly) NSArray *audioRoutes;
@property (nonatomic, strong, readonly) TGAudioRoute *activeAudioRoute;

@property (nonatomic, readonly) bool mute;
@property (nonatomic, readonly) bool speaker;

- (instancetype)initWithOutgoing:(bool)outgoing callStateData:(TGCallStateData *)stateData transmissionState:(TGCallTransmissionState)transmissionState peer:(TGUser *)peer keySha256:(NSData *)keySha256 startTime:(CFAbsoluteTime)startTime mute:(bool)mute speaker:(bool)speaker audioRoutes:(NSArray *)audioRoutes activeAudioRoute:(TGAudioRoute *)activeAudioRoute;

@end
