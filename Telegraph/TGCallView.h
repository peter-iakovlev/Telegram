#import <UIKit/UIKit.h>

@class TGCallSessionState;
@class TGCallCommState;

@interface TGCallView : UIView

@property (nonatomic, readonly) UIButton *speakerButton;

@property (nonatomic, copy) void (^backPressed)(void);
@property (nonatomic, copy) void (^mutePressed)(void);
@property (nonatomic, copy) void (^messagePressed)(void);
@property (nonatomic, copy) void (^speakerPressed)(void);

@property (nonatomic, copy) void (^cancelPressed)(void);
@property (nonatomic, copy) void (^declinePressed)(void);
@property (nonatomic, copy) void (^callPressed)(void);

@property (nonatomic, copy) void (^debugPressed)(void);

@property (nonatomic, copy) void (^minimizeRequested)(void);

- (void)setState:(TGCallSessionState *)state duration:(NSTimeInterval)duration;

- (void)centralize;
- (void)resetPan;

- (void)onPause;
- (void)onResume;

@end
