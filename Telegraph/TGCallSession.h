#import <SSignalKit/SSignalKit.h>
#import "TGCallState.h"

@class TGUser;

@interface TGCallSession : NSObject

@property (nonatomic, readonly) bool outgoing;
@property (nonatomic, readonly) int64_t callId;
@property (nonatomic, readonly) int64_t peerId;
@property (nonatomic, readonly) bool completed;

@property (nonatomic, copy) void (^onStartedConnecting)(void);
@property (nonatomic, copy) void (^onConnected)(void);

- (instancetype)initOutgoing:(bool)outgoing;
- (instancetype)initWithSignal:(SSignal *)signal outgoing:(bool)outgoing;

- (void)startWithSignal:(SSignal *)signal;

- (void)acceptIncomingCall;
- (void)hangUpCurrentCall;
- (void)hangUpCurrentCall:(bool)external;

- (void)toggleMute;
- (void)setMuted:(bool)muted;

- (void)toggleSpeaker;

- (NSTimeInterval)duration;

- (SSignal *)stateSignal;
- (SSignal *)debugSignal;
- (SSignal *)levelSignal;

- (void)setupAudioSession;
+ (void)resetAudioSession;

- (void)setDebugBitrate:(NSInteger)bitrate;
- (void)setDebugPacketLoss:(NSInteger)packetLossPercent;
- (void)setDebugP2PEnabled:(bool)enabled;

@end

typedef enum {
    TGCallTransmissionStateInitializing,
    TGCallTransmissionStateEstablished,
    TGCallTransmissionStateFailed
} TGCallTransmissionState;

@interface TGCallSessionState : NSObject

@property (nonatomic, readonly) bool outgoing;
@property (nonatomic, readonly) TGCallState state;
@property (nonatomic, readonly) TGCallTransmissionState transmissionState;
@property (nonatomic, readonly) CFAbsoluteTime startTime;

@property (nonatomic, readonly) TGUser *peer;
@property (nonatomic, readonly) NSData *keySha1;
@property (nonatomic, readonly) NSData *keySha256;

@property (nonatomic, readonly) bool mute;
@property (nonatomic, readonly) bool speaker;

- (instancetype)initWithOutgoing:(bool)outgoing callStateData:(TGCallStateData *)stateData transmissionState:(TGCallTransmissionState)transmissionState peer:(TGUser *)peer keySha1:(NSData *)keySha1 keySha256:(NSData *)keySha256 startTime:(CFAbsoluteTime)startTime mute:(bool)mute speaker:(bool)speaker;

@end
