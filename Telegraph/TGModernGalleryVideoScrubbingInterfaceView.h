#import <UIKit/UIKit.h>

@interface TGModernGalleryVideoScrubbingInterfaceView : UIView

@property (nonatomic, copy) void (^scrubbingBegan)();
@property (nonatomic, copy) void (^scrubbingChanged)(float position);
@property (nonatomic, copy) void (^scrubbingCancelled)();
@property (nonatomic, copy) void (^scrubbingFinished)(float position);

- (void)setDuration:(NSTimeInterval)duration currentTime:(NSTimeInterval)currentTime isPlaying:(bool)isPlaying isPlayable:(bool)isPlayable animated:(bool)animated;

@end
