#import "TGPhotoDummyController.h"

#import "TGPhotoEditorUtils.h"

#import "PGPhotoEditor.h"

#import "TGPhotoEditorPreviewView.h"

#import "TGPhotoQualityController.h"

@interface TGPhotoDummyController ()
{
    UIView *_wrapperView;
}

@property (nonatomic, weak) PGPhotoEditor *photoEditor;
@property (nonatomic, weak) TGPhotoEditorPreviewView *previewView;

@end

@implementation TGPhotoDummyController

- (instancetype)initWithPhotoEditor:(PGPhotoEditor *)photoEditor previewView:(TGPhotoEditorPreviewView *)previewView
{
    self = [super init];
    if (self != nil)
    {
        self.photoEditor = photoEditor;
        self.previewView = previewView;
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    _wrapperView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:_wrapperView];
    
    TGPhotoEditorPreviewView *previewView = _previewView;
    previewView.hidden = true;
    [self.view addSubview:_previewView];
}

- (void)prepareForCombinedAppearance
{
    _wrapperView.hidden = true;
}

- (void)finishedCombinedAppearance
{
    _wrapperView.hidden = false;
}

- (void)_finishedTransitionInWithView:(UIView *)transitionView
{
    [transitionView removeFromSuperview];
    
    TGPhotoEditorPreviewView *previewView = _previewView;
    previewView.hidden = false;
    [previewView performTransitionInIfNeeded];
}

- (void)_animatePreviewViewTransitionOutToFrame:(CGRect)targetFrame saving:(bool)saving parentView:(UIView *)parentView completion:(void (^)(void))completion
{
    [self.controller prepareForCombinedAppearance];
    [self.controller _animatePreviewViewTransitionOutToFrame:targetFrame saving:saving parentView:parentView completion:completion];
}

- (CGRect)transitionOutReferenceFrame
{
    TGPhotoEditorPreviewView *previewView = _previewView;
    return previewView.frame;
}

- (UIView *)transitionOutReferenceView
{
    return _previewView;
}

- (UIView *)snapshotView
{
    TGPhotoEditorPreviewView *previewView = self.previewView;
    return [previewView originalSnapshotView];
}

- (id)currentResultRepresentation
{
    return [self.previewView originalSnapshotView];
    //return TGPaintCombineCroppedImages(self.photoEditor.currentResultImage, self.photoEditor.paintingData.image, true, self.photoEditor.originalSize, self.photoEditor.cropRect, self.photoEditor.cropOrientation, self.photoEditor.cropRotation, self.photoEditor.cropMirrored);
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    [self updateLayout:[UIApplication sharedApplication].statusBarOrientation];
}

- (void)updateLayout:(UIInterfaceOrientation)orientation
{
    if ([self inFormSheet] || [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
    {
        orientation = UIInterfaceOrientationPortrait;
    }
    
    CGSize referenceSize = [self referenceViewSize];
    
    CGFloat screenSide = MAX(referenceSize.width, referenceSize.height) + 2 * TGPhotoEditorPanelSize;
    _wrapperView.frame = CGRectMake((referenceSize.width - screenSide) / 2, (referenceSize.height - screenSide) / 2, screenSide, screenSide);
    
    PGPhotoEditor *photoEditor = self.photoEditor;
    TGPhotoEditorPreviewView *previewView = self.previewView;
    
    if (_dismissing || previewView.superview != self.view)
        return;
    
    CGRect containerFrame = [TGPhotoEditorTabController photoContainerFrameForParentViewFrame:CGRectMake(0, 0, referenceSize.width, referenceSize.height) toolbarLandscapeSize:self.toolbarLandscapeSize orientation:orientation panelSize:TGPhotoEditorPanelSize];
    CGSize fittedSize = TGScaleToSize(photoEditor.rotatedCropSize, containerFrame.size);
    previewView.frame = CGRectMake(containerFrame.origin.x + (containerFrame.size.width - fittedSize.width) / 2,
                                   containerFrame.origin.y + (containerFrame.size.height - fittedSize.height) / 2,
                                   fittedSize.width,
                                   fittedSize.height);
}

@end
