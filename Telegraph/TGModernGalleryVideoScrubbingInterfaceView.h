#import <UIKit/UIKit.h>

@interface TGModernGalleryVideoScrubbingInterfaceView : UIView

@property (nonatomic, copy) void (^scrubbingBegan)();
@property (nonatomic, copy) void (^scrubbingChanged)(CGFloat position);
@property (nonatomic, copy) void (^scrubbingCancelled)();
@property (nonatomic, copy) void (^scrubbingFinished)(CGFloat position);

@property (nonatomic, copy) void (^pipPressed)(void);

- (void)setDuration:(NSTimeInterval)duration currentTime:(NSTimeInterval)currentTime isPlaying:(bool)isPlaying isPlayable:(bool)isPlayable animated:(bool)animated;

- (void)setPictureInPictureHidden:(bool)hidden;
- (void)setPictureInPictureEnabled:(bool)enabled;

@end
