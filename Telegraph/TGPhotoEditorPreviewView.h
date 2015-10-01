#import <UIKit/UIKit.h>

@class PGPhotoEditorView;

@interface TGPhotoEditorPreviewView : UIView

@property (nonatomic, readonly) PGPhotoEditorView *imageView;

@property (nonatomic, copy) void(^touchedDown)(void);
@property (nonatomic, copy) void(^touchedUp)(void);
@property (nonatomic, copy) void(^interactionEnded)(void);

@property (nonatomic, readonly) bool isTracking;

- (void)setSnapshotImage:(UIImage *)image;
- (void)setSnapshotView:(UIView *)view;

- (UIView *)originalSnapshotView;

- (void)performTransitionInWithCompletion:(void (^)(void))completion;
- (void)setNeedsTransitionIn;
- (void)performTransitionInIfNeeded;

- (void)prepareTransitionFadeView;
- (void)performTransitionFade;

- (void)prepareForTransitionOut;

- (void)performTransitionToCropAnimated:(bool)animated;

@end
