#import <UIKit/UIKit.h>

@interface TGPhotoAvatarCropView : UIView

@property (nonatomic, strong) UIImage *image;

@property (nonatomic, assign) CGRect cropRect;
@property (nonatomic, assign) UIImageOrientation cropOrientation;

@property (nonatomic, copy) void(^croppingChanged)(void);
@property (nonatomic, copy) void(^interactionEnded)(void);

@property (nonatomic, readonly) bool isTracking;
@property (nonatomic, readonly) bool isAnimating;

- (instancetype)initWithOriginalSize:(CGSize)originalSize screenSize:(CGSize)screenSize;

- (void)setSnapshotImage:(UIImage *)image;
- (void)setSnapshotView:(UIView *)snapshotView;

- (void)rotate90DegreesCCWAnimated:(bool)animated;
- (void)resetAnimated:(bool)animated;

- (void)animateTransitionIn;
- (void)animateTransitionOutSwitching:(bool)switching;
- (void)transitionInFinishedFromCamera:(bool)fromCamera;

- (void)invalidateCropRect;

- (CGRect)contentFrameForView:(UIView *)view;
- (CGRect)cropRectFrameForView:(UIView *)view;
- (UIImage *)croppedImageWithMaxSize:(CGSize)maxSize;
- (UIView *)cropSnapshotView;

- (void)updateCircleImageWithReferenceSize:(CGSize)referenceSize;

+ (CGSize)areaInsetSize;

@end
