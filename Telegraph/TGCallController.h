#import "TGOverlayController.h"
#import "TGOverlayControllerWindow.h"

@class TGCallSession;

@interface TGCallControllerWindow : TGOverlayControllerWindow

@end

@interface TGCallController : TGOverlayController

@property (nonatomic, readonly) int64_t peerId;
@property (nonatomic, copy) void (^onDismissBlock)(void);

- (instancetype)initWithSession:(TGCallSession *)session;

- (void)presentController;

- (SSignal *)callDuration;

+ (void)requestMicrophoneAccess:(void (^)(bool granted))resultBlock;

@end
