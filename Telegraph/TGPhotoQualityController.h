#import "TGPhotoEditorTabController.h"

#import "TGVideoEditAdjustments.h"

@class PGPhotoEditor;
@class TGPhotoEditorPreviewView;
@class TGPhotoEditorController;

@interface TGPhotoQualityController : TGViewController

@property (nonatomic, weak) id item;

@property (nonatomic, weak) TGPhotoEditorController *mainController;

@property (nonatomic, copy) void(^beginTransitionOut)(void);
@property (nonatomic, copy) void(^finishedCombinedTransition)(void);

@property (nonatomic, assign) CGFloat toolbarLandscapeSize;

@property (nonatomic, readonly) TGMediaVideoConversionPreset preset;


- (instancetype)initWithPhotoEditor:(PGPhotoEditor *)photoEditor;

- (void)attachPreviewView:(TGPhotoEditorPreviewView *)previewView;

- (void)_animatePreviewViewTransitionOutToFrame:(CGRect)targetFrame saving:(bool)saving parentView:(UIView *)parentView completion:(void (^)(void))completion;

- (void)prepareForCombinedAppearance;
- (void)finishedCombinedAppearance;

@end
