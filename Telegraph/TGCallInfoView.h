#import <UIKit/UIKit.h>

@class TGCallSessionState;
@class TGCallCommState;

@interface TGCallInfoView : UIView

@property (nonatomic, copy) void (^debugPressed)(void);

- (void)setState:(TGCallSessionState *)state duration:(NSTimeInterval)duration;

- (void)onResume;
- (void)onPause;

@end

extern const CGFloat TGCallInfoViewHeight;
