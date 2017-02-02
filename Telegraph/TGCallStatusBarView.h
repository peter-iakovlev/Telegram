#import <UIKit/UIKit.h>
#import <SSignalKit/SSignalKit.h>

@interface TGCallStatusBarView : UIView

@property (nonatomic, readonly) bool realHidden;
@property (nonatomic, copy) void (^visiblilityChanged)(bool hidden);
@property (nonatomic, copy) void (^statusBarPressed)(void);

- (void)setSignal:(SSignal *)signal;

- (void)setOffset:(CGFloat)offset;

@end
