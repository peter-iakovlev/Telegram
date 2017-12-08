#import <UIKit/UIKit.h>

@interface TGVolumeBarView : UIView

@property (nonatomic, assign) UIEdgeInsets safeAreaInset;

- (void)setVolume:(CGFloat)volume;

@end
