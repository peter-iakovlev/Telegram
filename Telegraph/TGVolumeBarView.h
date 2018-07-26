#import <UIKit/UIKit.h>

@class TGPresentation;

@interface TGVolumeBarView : UIView

@property (nonatomic, strong) TGPresentation *presentation;
@property (nonatomic, assign) UIEdgeInsets safeAreaInset;

- (void)setVolume:(CGFloat)volume;

@end
