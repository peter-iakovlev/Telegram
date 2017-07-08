#import "TGOverlayController.h"
#import "TGOverlayControllerWindow.h"

@class TGUser;
@class TGCallSession;

@interface TGCallControllerWindow : TGOverlayControllerWindow

@end

@interface TGCallController : TGOverlayController

@property (nonatomic, readonly) int64_t peerId;
@property (nonatomic, readonly) TGUser *peer;

@property (nonatomic, copy) void (^onTransitionIn)(void);

- (instancetype)initWithSession:(TGCallSession *)session;
- (void)presentController;
- (void)minimize;

- (void)hangUpCall;
- (void)hangUpCallWithCompletion:(void (^)(void))completion;

- (SSignal *)callDuration;

+ (void)requestMicrophoneAccess:(void (^)(bool granted))resultBlock;

+ (void)presentRatingAlertView:(int64_t)callId accessHash:(int64_t)accessHash presentTabAlert:(bool)presentTabAlert;

@end
