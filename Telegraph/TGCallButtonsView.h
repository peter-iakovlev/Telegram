#include "TGCallButton.h"

@class TGCallSessionState;
@class TGCallCommState;
@protocol TGPasscodeBackground;

@interface TGCallButtonsView : UIView

@property (nonatomic, readonly) UIButton *speakerButton;

@property (nonatomic, copy) void (^declinePressed)(void);
@property (nonatomic, copy) void (^callPressed)(void);

@property (nonatomic, copy) void (^cancelPressed)(void);
@property (nonatomic, copy) void (^messagePressed)(void);
@property (nonatomic, copy) void (^mutePressed)(void);
@property (nonatomic, copy) void (^speakerPressed)(void);

- (void)setState:(TGCallSessionState *)state;
- (void)setBackground:(NSObject<TGPasscodeBackground> *)background;

@end

extern const CGFloat TGCallButtonsSpacing;
