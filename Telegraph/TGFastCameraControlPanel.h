#import <UIKit/UIKit.h>

@interface TGFastCameraControlPanel : UIView

@property (nonatomic, copy) void (^videoPressed)(void);
@property (nonatomic, copy) void (^photoPressed)(void);
@property (nonatomic, copy) void (^cancelPressed)(void);

- (void)setRecordingVideo:(bool)recordingVideo animated:(bool)animated;
- (void)setLabelsHidden:(bool)hidden;

- (void)handlePanAt:(CGPoint)location;
- (void)handleReleaseAt:(CGPoint)location;

@end
