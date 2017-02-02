#import <UIKit/UIKit.h>

@class TGCallSessionState;
@class TGCallCommState;

@interface TGCallView : UIView

@property (nonatomic, copy) void (^mutePressed)(void);
@property (nonatomic, copy) void (^messagePressed)(void);
@property (nonatomic, copy) void (^speakerPressed)(void);

@property (nonatomic, copy) void (^declinePressed)(void);
@property (nonatomic, copy) void (^callPressed)(void);

- (void)setState:(TGCallSessionState *)state duration:(NSTimeInterval)duration;
- (void)setLevel:(CGFloat)level;

- (void)onPause;
- (void)onResume;

@end
