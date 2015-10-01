#import "TGPhotoEditorController.h"

#import "TGApplication.h"
#import "TGAppDelegate.h"
#import <objc/runtime.h>

#import "ATQueue.h"
#import "TGOverlayControllerWindow.h"

#import "TGPhotoEditorAnimation.h"
#import "TGPhotoEditorInterfaceAssets.h"
#import "TGImageUtils.h"
#import "TGPhotoEditorUtils.h"
#import "TGAssetImageManager.h"
#import "TGMediaPickerAsset.h"
#import <Photos/Photos.h>

#import "TGHacks.h"

#import "TGProgressWindow.h"

#import "TGActionSheet.h"

#import "PGPhotoEditor.h"
#import "PGEnhanceTool.h"

#import "PGPhotoEditorValues.h"
#import "TGVideoEditAdjustments.h"

#import "TGPhotoToolbarView.h"
#import "TGPhotoEditorPreviewView.h"

#import "TGPhotoCaptionController.h"
#import "TGPhotoCropController.h"
#import "TGPhotoAvatarCropController.h"
#import "TGPhotoToolsController.h"
#import "TGPhotoEditorItemController.h"

@interface TGPhotoEditorController () <TGViewControllerNavigationBarAppearance>
{
    bool _switchingTab;
    NSArray *_availableTabs;
    TGPhotoEditorTab _currentTab;
    TGPhotoEditorTabController *_currentTabController;
    
    UIView *_backgroundView;
    UIView *_containerView;
    UIView *_wrapperView;
    TGPhotoToolbarView *_portraitToolbarView;
    TGPhotoToolbarView *_landscapeToolbarView;
    TGPhotoEditorPreviewView *_previewView;
    
    PGPhotoEditor *_photoEditor;
    
    ATQueue *_queue;
    TGPhotoEditorControllerIntent _intent;
    id<TGEditablePhotoItem> _item;
    UIImage *_screenImage;
    UIImage *_thumbnailImage;
    UIImage *_aspectRatioThumbnailImage;
    
    id<TGMediaEditAdjustments> _initialAdjustments;
    NSString *_caption;
    
    bool _viewFillingWholeScreen;
    bool _forceStatusBarVisible;
    
    bool _ignoreDefaultPreviewViewTransitionIn;
    bool _hasOpenedPhotoTools;
    bool _hiddenToolbarView;
}

@property (nonatomic, weak) UIImage *fullSizeImage;

@end

@implementation TGPhotoEditorController

- (instancetype)initWithItem:(id<TGEditablePhotoItem>)item intent:(TGPhotoEditorControllerIntent)intent adjustments:(id<TGMediaEditAdjustments>)adjustments caption:(NSString *)caption screenImage:(UIImage *)screenImage availableTabs:(NSArray *)availableTabs selectedTab:(TGPhotoEditorTab)selectedTab
{
    self = [super init];
    if (self != nil)
    {
        self.automaticallyManageScrollViewInsets = false;
        self.autoManageStatusBarBackground = false;
        
        _availableTabs = availableTabs;

        _item = item;
        _currentTab = selectedTab;
        _intent = intent;
        
        _caption = caption;
        _initialAdjustments = adjustments;
        _screenImage = screenImage;
        
        _queue = [[ATQueue alloc] init];
        _photoEditor = [[PGPhotoEditor alloc] initWithOriginalSize:_item.originalSize adjustments:adjustments forVideo:(intent == TGPhotoEditorControllerVideoIntent)];
        if ([self presentedForAvatarCreation])
        {
            CGFloat shortSide = MIN(_item.originalSize.width, _item.originalSize.height);
            _photoEditor.cropRect = CGRectMake((_item.originalSize.width - shortSide) / 2,
                                               (_item.originalSize.height - shortSide) / 2,
                                               shortSide, shortSide);
        }
    }
    return self;
}

- (void)dealloc
{
    
}

- (void)loadView
{
    [super loadView];
    
    self.view.frame = (CGRect){self.view.frame.origin, [self referenceViewSize]};
    self.view.clipsToBounds = true;
    
    if ([self presentedForAvatarCreation] && ![self presentedFromCamera])
        self.view.backgroundColor = [UIColor blackColor];
    
    _wrapperView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:_wrapperView];
    
    _backgroundView = [[UIView alloc] initWithFrame:_wrapperView.bounds];
    _backgroundView.alpha = 0.0f;
    _backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _backgroundView.backgroundColor = [TGPhotoEditorInterfaceAssets toolbarBackgroundColor];
    [_wrapperView addSubview:_backgroundView];
    
    _containerView = [[UIView alloc] initWithFrame:CGRectZero];
    [_wrapperView addSubview:_containerView];
    
    __weak TGPhotoEditorController *weakSelf = self;
    
    void(^toolbarCancelPressed)(void) = ^
    {
        __strong TGPhotoEditorController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        [strongSelf cancelButtonPressed];
    };
    
    void(^toolbarDonePressed)(void) = ^
    {
        __strong TGPhotoEditorController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        [strongSelf doneButtonPressed];
    };
    
    void(^toolbarTabPressed)(TGPhotoEditorTab) = ^(TGPhotoEditorTab tab)
    {
        __strong TGPhotoEditorController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        if (tab == TGPhotoEditorRotateTab)
            [strongSelf rotateVideoOrReset:false];
        else
            [strongSelf presentEditorTab:tab];
    };
    
    
    NSString *backButtonTitle = TGLocalized(@"Common.Cancel");
    if ([self presentedForAvatarCreation])
    {
        if ([self presentedFromCamera])
            backButtonTitle = TGLocalized(@"Camera.Retake");
        else
            backButtonTitle = TGLocalized(@"Common.Back");
    }

    NSString *doneButtonTitle = [self presentedForAvatarCreation] ? TGLocalized(@"MediaPicker.Choose") : TGLocalized(@"Common.Done");

    _portraitToolbarView = [[TGPhotoToolbarView alloc] initWithBackButtonTitle:backButtonTitle doneButtonTitle:doneButtonTitle accentedDone:![self presentedForAvatarCreation] solidBackground:true tabs:_availableTabs];
    [_portraitToolbarView setActiveTab:_currentTab];
    _portraitToolbarView.cancelPressed = toolbarCancelPressed;
    _portraitToolbarView.donePressed = toolbarDonePressed;
    _portraitToolbarView.tabPressed = toolbarTabPressed;
    [_wrapperView addSubview:_portraitToolbarView];
    
    _landscapeToolbarView = [[TGPhotoToolbarView alloc] initWithBackButtonTitle:backButtonTitle doneButtonTitle:doneButtonTitle accentedDone:![self presentedForAvatarCreation] solidBackground:true tabs:_availableTabs];
    [_landscapeToolbarView setActiveTab:_currentTab];
    _landscapeToolbarView.cancelPressed = toolbarCancelPressed;
    _landscapeToolbarView.donePressed = toolbarDonePressed;
    _landscapeToolbarView.tabPressed = toolbarTabPressed;
    
    if ([UIDevice currentDevice].userInterfaceIdiom != UIUserInterfaceIdiomPad)
        [_wrapperView addSubview:_landscapeToolbarView];
    
    if (_intent & TGPhotoEditorControllerWebIntent)
        [self updateDoneButtonEnabled:false animated:false];
    
    UIInterfaceOrientation orientation = self.interfaceOrientation;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
        orientation = UIInterfaceOrientationPortrait;
    
    CGRect containerFrame = [TGPhotoEditorTabController photoContainerFrameForParentViewFrame:self.view.frame toolbarLandscapeSize:[_landscapeToolbarView landscapeSize] orientation:orientation includePanel:false];
    CGSize fittedSize = TGScaleToSize(_photoEditor.rotatedCropSize, containerFrame.size);
    
    _previewView = [[TGPhotoEditorPreviewView alloc] initWithFrame:CGRectMake(0, 0, fittedSize.width, fittedSize.height)];
    [_previewView setSnapshotImage:_screenImage];
    [_photoEditor setPreviewOutput:_previewView];
    
    [self updateEditorButtonsWithAdjustments:_initialAdjustments];
    
    [self presentEditorTab:_currentTab];
                    
    if ([self presentedForAvatarCreation])
    {
        [_landscapeToolbarView calculateLandscapeSizeForPossibleButtonTitles:@[ backButtonTitle,
                                                                                TGLocalized(@"MediaPicker.Choose") ]];
    }
    else
    {
        [_landscapeToolbarView calculateLandscapeSizeForPossibleButtonTitles:@[ backButtonTitle,
                                                                                TGLocalized(@"Common.Back"),
                                                                                TGLocalized(@"Common.Done"),
                                                                                TGLocalized(@"MediaPicker.Send") ]];
    }
}

- (BOOL)prefersStatusBarHidden
{
    if (_forceStatusBarVisible)
        return false;
    
    if ([self inFormSheet])
        return false;
    
    if (self.navigationController != nil)
        return _viewFillingWholeScreen;
    
    if (self.dontHideStatusBar)
        return false;
    
    return true;
}

- (UIBarStyle)requiredNavigationBarStyle
{
    return UIBarStyleDefault;
}

- (bool)navigationBarShouldBeHidden
{
    return true;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [_item fetchThumbnailImageWithCompletion:^(UIImage *image)
    {
        _aspectRatioThumbnailImage = image;

        if ([_currentTabController isKindOfClass:[TGPhotoCropController class]])
            [(TGPhotoCropController *)_currentTabController setBackdropImage:_aspectRatioThumbnailImage];
    }];
    
    if ([_currentTabController isKindOfClass:[TGPhotoCropController class]] || [_currentTabController isKindOfClass:[TGPhotoCaptionController class]])
        return;
    
    void (^setImageBlock)(UIImage *image) = ^(UIImage *image)
    {
        [_photoEditor setImage:image forCropRect:_photoEditor.cropRect cropRotation:_photoEditor.cropRotation cropOrientation:_photoEditor.cropOrientation];

        if (_ignoreDefaultPreviewViewTransitionIn)
        {
            TGDispatchOnMainThread(^
            {
                [_previewView setSnapshotImage:image];
            });
        }
        else
        {
            [_photoEditor processAnimated:false completion:^
            {
                TGDispatchOnMainThread(^
                {
                    [_previewView performTransitionInWithCompletion:^
                    {
                        [_previewView setSnapshotImage:image];
                    }];
                });
            }];
        }
    };
    
    if (![_photoEditor hasDefaultCropping])
    {
        [_item fetchOriginalFullSizeImageWithCompletion:^(UIImage *image)
        {
            [_queue dispatch:^
            {
                UIImage *croppedImage = TGPhotoEditorCrop(image, _photoEditor.cropOrientation, _photoEditor.cropRotation, _photoEditor.cropRect, TGPhotoEditorScreenImageMaxSize(), _photoEditor.originalSize);
                setImageBlock(croppedImage);
            }];
        }];
    }
    else
    {
        [_item fetchOriginalScreenSizeImageWithCompletion:^(UIImage *image)
        {
            [_queue dispatch:^
            {
                setImageBlock(image);
            }];
        }];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    if (![self inFormSheet] && (self.navigationController != nil || self.dontHideStatusBar))
    {
        if (animated)
        {
            [UIView animateWithDuration:0.3 animations:^
            {
                [TGHacks setApplicationStatusBarAlpha:0.0f];
            }];
        }
        else
        {
            [TGHacks setApplicationStatusBarAlpha:0.0f];
        }
    }
    else if (!self.dontHideStatusBar)
    {
        if (iosMajorVersion() < 7)
            [(TGApplication *)[UIApplication sharedApplication] forceSetStatusBarHidden:true withAnimation:UIStatusBarAnimationNone];
    }
    
    [super viewWillAppear:animated];

    [self transitionIn];
}

- (void)viewDidAppear:(BOOL)animated
{
    if (self.navigationController != nil)
    {
        _viewFillingWholeScreen = true;

        if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)])
            [self setNeedsStatusBarAppearanceUpdate];
        else
            [(TGApplication *)[UIApplication sharedApplication] forceSetStatusBarHidden:[self prefersStatusBarHidden] withAnimation:UIStatusBarAnimationNone];
    }
    
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    if (self.navigationController != nil || self.dontHideStatusBar)
    {
        _viewFillingWholeScreen = false;
        
        if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)])
            [self setNeedsStatusBarAppearanceUpdate];
        else
            [(TGApplication *)[UIApplication sharedApplication] forceSetStatusBarHidden:[self prefersStatusBarHidden] withAnimation:UIStatusBarAnimationNone];
        
        if (animated)
        {
            [UIView animateWithDuration:0.3 animations:^
            {
                [TGHacks setApplicationStatusBarAlpha:1.0f];
            }];
        }
        else
        {
            [TGHacks setApplicationStatusBarAlpha:1.0f];
        }
    }
    
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    //strange ios6 crashfix
    if (iosMajorVersion() < 7 && !self.dontHideStatusBar)
    {
        TGDispatchAfter(0.5f, dispatch_get_main_queue(), ^
        {
            [(TGApplication *)[UIApplication sharedApplication] forceSetStatusBarHidden:false withAnimation:UIStatusBarAnimationNone];
        });
    }
}

- (void)updateDoneButtonEnabled:(bool)enabled animated:(bool)animated
{
    [_portraitToolbarView setDoneButtonEnabled:enabled animated:animated];
    [_landscapeToolbarView setDoneButtonEnabled:enabled animated:animated];
}

- (void)updateStatusBarAppearanceForDismiss
{
    _forceStatusBarVisible = true;
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)])
        [self setNeedsStatusBarAppearanceUpdate];
    else
        [(TGApplication *)[UIApplication sharedApplication] forceSetStatusBarHidden:[self prefersStatusBarHidden] withAnimation:UIStatusBarAnimationNone];
}

- (BOOL)shouldAutorotate
{
    return (!(_currentTabController != nil && ![_currentTabController shouldAutorotate]) && [super shouldAutorotate]);
}

#pragma mark - 

- (void)createEditedImageWithEditorValues:(PGPhotoEditorValues *)editorValues createThumbnail:(bool)createThumbnail showProgress:(bool)showProgress completion:(void (^)(void))completion
{
    bool forAvatar = [self presentedForAvatarCreation];
    if (!forAvatar && [editorValues isDefaultValuesForAvatar:forAvatar])
    {
        if (self.finishedEditing != nil)
            self.finishedEditing(nil, nil, nil, false);

        if (completion != nil)
            completion();
        
        return;
    }
    
    if ([editorValues isEqual:_initialAdjustments])
    {
        if (self.finishedEditing != nil)
            self.finishedEditing(nil, nil, nil, true);
        
        if (completion != nil)
            completion();
        
        return;
    }
    
    TGProgressWindow *progressWindow = nil;
    if (showProgress)
    {
        progressWindow = [[TGProgressWindow alloc] init];
        progressWindow.windowLevel = self.view.window.windowLevel + 0.001f;
        [progressWindow showAnimated];
    }
    
    void(^completionBlock)(UIImage *) = ^(UIImage *image)
    {
        CGSize size = TGPhotoThumbnailSizeForCurrentScreen();
        size.width = CGCeil(size.width);
        size.height = CGCeil(size.height);
        
        UIImage *thumbnailImage = nil;

        if (createThumbnail)
        {
            UIGraphicsBeginImageContextWithOptions(size, true, 0.0f);
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextSetInterpolationQuality(context, kCGInterpolationMedium);
            
            CGSize drawingSize = TGScaleToFillSize(image.size, size);
            CGRect imageRect = CGRectMake((size.width - drawingSize.width) / 2.0f, (size.height - drawingSize.height) / 2.0f, drawingSize.width, drawingSize.height);
            [image drawInRect:imageRect];
             
            thumbnailImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
                
        TGDispatchOnMainThread(^
        {
            [progressWindow dismiss:true];
            if (self.finishedEditing != nil)
                self.finishedEditing(editorValues, image, thumbnailImage, false);
            
            if (completion != nil)
                completion();
        });
    };
    
    void(^processBlock)(UIImage *, PGPhotoEditor *) = ^(UIImage *image, PGPhotoEditor *photoEditor)
    {
        UIImage *croppedImage = TGPhotoEditorCrop(image, photoEditor.cropOrientation, photoEditor.cropRotation, photoEditor.cropRect, TGPhotoEditorResultImageMaxSize, _photoEditor.originalSize);
        
        if (editorValues.toolsApplied)
        {
            [_photoEditor setImage:croppedImage forCropRect:photoEditor.cropRect cropRotation:photoEditor.cropRotation cropOrientation:photoEditor.cropOrientation];
            [_photoEditor createResultImageWithCompletion:completionBlock];
        }
        else
        {
            completionBlock(croppedImage);
        }
    };
    
    UIImage *fullSizeImage = self.fullSizeImage;
    PGPhotoEditor *photoEditor = _photoEditor;
    
    if (fullSizeImage == nil)
    {
        __strong TGPhotoEditorController *strongSelf = self;
        [_item fetchOriginalFullSizeImageWithCompletion:^(UIImage *image)
        {
            if (strongSelf == nil)
                return;
            
            processBlock(image, photoEditor);
        }];
    }
    else
    {
        processBlock(fullSizeImage, photoEditor);
    }
}

#pragma mark - Intent

- (bool)presentedFromCamera
{
    return _intent & TGPhotoEditorControllerFromCameraIntent;
}

- (bool)presentedForAvatarCreation
{
    return _intent & TGPhotoEditorControllerAvatarIntent;
}

#pragma mark - Transition

- (void)transitionIn
{
    if (self.navigationController != nil)
        return;
    
    CGFloat delay = [self presentedFromCamera] ? 0.1f: 0.0f;
    
    _portraitToolbarView.alpha = 0.0f;
    _landscapeToolbarView.alpha = 0.0f;
    
    [UIView animateWithDuration:0.3f delay:delay options:UIViewAnimationOptionCurveLinear animations:^
    {
        _portraitToolbarView.alpha = 1.0f;
        _landscapeToolbarView.alpha = 1.0f;
    } completion:nil];
}

- (void)transitionOutSaving:(bool)saving completion:(void (^)(void))completion
{
    [UIView animateWithDuration:0.3f animations:^
    {
        _portraitToolbarView.alpha = 0.0f;
        _landscapeToolbarView.alpha = 0.0f;
    }];
    
    _currentTabController.beginTransitionOut = self.beginTransitionOut;
    if (_hiddenToolbarView && self.requestToolbarsHidden != nil)
    {
        if (_intent == TGPhotoEditorControllerVideoIntent)
            self.requestToolbarsHidden(false, UIInterfaceOrientationIsLandscape(self.interfaceOrientation));
        else
            self.requestToolbarsHidden(false, true);
    }
    
    [_currentTabController transitionOutSaving:saving completion:^
    {
        if (completion != nil)
            completion();
        
        if (self.finishedTransitionOut != nil)
            self.finishedTransitionOut(saving);
    }];
}

- (void)presentEditorTab:(TGPhotoEditorTab)tab
{    
    if (_switchingTab || (tab == _currentTab && _currentTabController != nil))
        return;
    
    bool isInitialAppearance = true;

    CGRect transitionReferenceFrame = CGRectZero;
    UIView *transitionReferenceView = nil;
    UIView *transitionParentView = nil;
    bool transitionNoTransitionView = false;
    
    UIImage *snapshotImage = nil;
    UIView *snapshotView = nil;
    
    TGPhotoEditorTabController *currentController = _currentTabController;
    if (currentController != nil)
    {
        if (![currentController isDismissAllowed])
            return;
        
        transitionReferenceFrame = [currentController transitionOutReferenceFrame];
        transitionReferenceView = [currentController transitionOutReferenceView];
        transitionNoTransitionView = [currentController isKindOfClass:[TGPhotoAvatarCropController class]];
        
        [currentController transitionOutSwitching:true completion:^
        {
            [currentController removeFromParentViewController];
            [currentController.view removeFromSuperview];
        }];
        
        if ([currentController isKindOfClass:[TGPhotoCropController class]])
        {
            _backgroundView.alpha = 1.0f;
            [UIView animateWithDuration:0.3f animations:^
            {
                _backgroundView.alpha = 0.0f;
            } completion:nil];
        }
        
        isInitialAppearance = false;
        
        snapshotView = [currentController snapshotView];
    }
    else
    {
        if (self.beginTransitionIn != nil)
            transitionReferenceView = self.beginTransitionIn(&transitionReferenceFrame, &transitionParentView);
        
        if ([self presentedFromCamera] && [self presentedForAvatarCreation])
        {
            if (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft)
            {
                transitionReferenceFrame = CGRectMake(self.view.frame.size.width - transitionReferenceFrame.size.height - transitionReferenceFrame.origin.y,
                                                      transitionReferenceFrame.origin.x,
                                                      transitionReferenceFrame.size.height, transitionReferenceFrame.size.width);
            }
            else if (self.interfaceOrientation == UIInterfaceOrientationLandscapeRight)
            {
                transitionReferenceFrame = CGRectMake(transitionReferenceFrame.origin.y,
                                                      self.view.frame.size.height - transitionReferenceFrame.size.width - transitionReferenceFrame.origin.x,
                                                      transitionReferenceFrame.size.height, transitionReferenceFrame.size.width);
            }
        }
        
        snapshotImage = _screenImage;
    }
    
    PGPhotoEditorValues *editorValues = [_photoEditor exportAdjustments];
    [self updateEditorButtonsWithAdjustments:editorValues];
    
    _switchingTab = true;
    
    __weak TGPhotoEditorController *weakSelf = self;
    TGPhotoEditorTabController *controller = nil;
    switch (tab)
    {
        case TGPhotoEditorCaptionTab:
        {
            TGPhotoCaptionController *captionController = [[TGPhotoCaptionController alloc] initWithPhotoEditor:_photoEditor
                                                                                                    previewView:_previewView
                                                                                                        caption:_caption];
            captionController.toolbarLandscapeSize = _landscapeToolbarView.landscapeSize;
            captionController.userListSignal = self.userListSignal;
            captionController.hashtagListSignal = self.hashtagListSignal;
            captionController.captionSet = ^(NSString *caption)
            {
                if (caption.length == 0)
                    caption = nil;
                
                __strong TGPhotoEditorController *strongSelf = weakSelf;
                if (strongSelf == nil)
                    return;
                
                strongSelf->_caption = caption;
                if (strongSelf.captionSet != nil)
                    strongSelf.captionSet(caption);
                
                [strongSelf doneButtonPressed];
            };
            
            captionController.beginTransitionIn = ^UIView *(CGRect *referenceFrame, UIView **parentView, bool *noTransitionView)
            {
                __strong TGPhotoEditorController *strongSelf = weakSelf;
                if (strongSelf == nil)
                    return nil;
                
                *referenceFrame = transitionReferenceFrame;
                *parentView = transitionParentView;
                *noTransitionView = transitionNoTransitionView;

                [strongSelf->_portraitToolbarView transitionOutAnimated:!isInitialAppearance transparent:true hideOnCompletion:true];
                [strongSelf->_landscapeToolbarView transitionOutAnimated:!isInitialAppearance transparent:true hideOnCompletion:true];
                
                return transitionReferenceView;
            };
            captionController.finishedTransitionIn = ^
            {
                __strong TGPhotoEditorController *strongSelf = weakSelf;
                if (strongSelf == nil)
                    return;
                
                if (isInitialAppearance && strongSelf.finishedTransitionIn != nil)
                    strongSelf.finishedTransitionIn();
                
                strongSelf->_switchingTab = false;
            };
            
            controller = captionController;
            
            if (self.requestToolbarsHidden != nil)
            {
                self.requestToolbarsHidden(true, isInitialAppearance);
                _hiddenToolbarView = true;                
            }
        }
            break;
            
        case TGPhotoEditorCropTab:
        {
            __block UIView *initialBackgroundView = nil;
            
            if ([self presentedForAvatarCreation])
            {
                TGPhotoAvatarCropController *cropController = [[TGPhotoAvatarCropController alloc] initWithPhotoEditor:_photoEditor
                                                                                                           previewView:_previewView];
                
                bool skipInitialTransition = (![self presentedFromCamera] && self.navigationController != nil);
                cropController.fromCamera = [self presentedFromCamera];
                cropController.skipTransitionIn = skipInitialTransition;
                if (snapshotView != nil)
                    [cropController setSnapshotView:snapshotView];
                else if (snapshotImage != nil)
                    [cropController setSnapshotImage:snapshotImage];
                cropController.toolbarLandscapeSize = _landscapeToolbarView.landscapeSize;
                cropController.beginTransitionIn = ^UIView *(CGRect *referenceFrame, UIView **parentView, bool *noTransitionView)
                {
                    __strong TGPhotoEditorController *strongSelf = weakSelf;
                    *referenceFrame = transitionReferenceFrame;
                    *noTransitionView = transitionNoTransitionView;
                    *parentView = transitionParentView;
                    
                    if (strongSelf != nil)
                    {
                        UIView *backgroundView = nil;
                        if (!skipInitialTransition)
                        {
                            UIView *backgroundSuperview = transitionParentView;
                            if (backgroundSuperview == nil)
                                backgroundSuperview = transitionReferenceView.superview.superview;
                            
                            initialBackgroundView = [[UIView alloc] initWithFrame:backgroundSuperview.bounds];
                            initialBackgroundView.alpha = 0.0f;
                            initialBackgroundView.backgroundColor = [TGPhotoEditorInterfaceAssets toolbarBackgroundColor];
                            [backgroundSuperview addSubview:initialBackgroundView];
                            backgroundView = initialBackgroundView;
                        }
                        else
                        {
                            backgroundView = strongSelf->_backgroundView;
                        }
                        
                        [UIView animateWithDuration:0.3f animations:^
                        {
                            backgroundView.alpha = 1.0f;
                        }];
                    }
                    
                    return transitionReferenceView;
                };
                cropController.finishedTransitionIn = ^
                {
                    __strong TGPhotoEditorController *strongSelf = weakSelf;
                    if (strongSelf == nil)
                        return;
                    
                    if (!skipInitialTransition)
                    {
                        [initialBackgroundView removeFromSuperview];
                        if (strongSelf.finishedTransitionIn != nil)
                            strongSelf.finishedTransitionIn();
                    }
                    else
                    {
                        strongSelf->_backgroundView.alpha = 0.0f;
                    }
                    
                    strongSelf->_switchingTab = false;
                };
                cropController.finishedTransitionOut = ^
                {
                    __strong TGPhotoEditorController *strongSelf = weakSelf;
                    if (strongSelf == nil)
                        return;
                    
                    if (strongSelf->_currentTabController.finishedTransitionIn != nil)
                    {
                        strongSelf->_currentTabController.finishedTransitionIn();
                        strongSelf->_currentTabController.finishedTransitionIn = nil;
                    }
                    
                    [strongSelf->_currentTabController _finishedTransitionInWithView:nil];
                };
                
                [_item fetchOriginalFullSizeImageWithCompletion:^(UIImage *image)
                {
                    __strong TGPhotoEditorController *strongSelf = weakSelf;
                    if (strongSelf == nil)
                        return;
                    
                    TGDispatchOnMainThread(^
                    {
                        if (cropController.dismissing && !cropController.switching)
                            return;
                        
                        strongSelf.fullSizeImage = image;
                        [cropController setImage:image];
                        
                        if (strongSelf->_intent & TGPhotoEditorControllerWebIntent)
                            [strongSelf updateDoneButtonEnabled:true animated:true];
                    });
                }];
                
                controller = cropController;
            }
            else
            {
                TGPhotoCropController *cropController = [[TGPhotoCropController alloc] initWithPhotoEditor:_photoEditor
                                                                                               previewView:_previewView
                                                                                                  metadata:self.metadata
                                                                                                  forVideo:(_intent == TGPhotoEditorControllerVideoIntent)];
                [cropController setBackdropImage:_aspectRatioThumbnailImage];
                if (snapshotView != nil)
                    [cropController setSnapshotView:snapshotView];
                else if (snapshotImage != nil)
                    [cropController setSnapshotImage:snapshotImage];
                cropController.toolbarLandscapeSize = _landscapeToolbarView.landscapeSize;
                cropController.beginTransitionIn = ^UIView *(CGRect *referenceFrame, UIView **parentView, bool *noTransitionView)
                {
                    *referenceFrame = transitionReferenceFrame;
                    *noTransitionView = transitionNoTransitionView;
                    *parentView = transitionParentView;
                    
                    __strong TGPhotoEditorController *strongSelf = weakSelf;
                    if (strongSelf != nil)
                    {
                        UIView *backgroundView = nil;
                        if (isInitialAppearance)
                        {
                            UIView *backgroundSuperview = transitionParentView;
                            if (backgroundSuperview == nil)
                                backgroundSuperview = transitionReferenceView.superview.superview;
                            
                            initialBackgroundView = [[UIView alloc] initWithFrame:backgroundSuperview.bounds];
                            initialBackgroundView.alpha = 0.0f;
                            initialBackgroundView.backgroundColor = [TGPhotoEditorInterfaceAssets toolbarBackgroundColor];
                            [backgroundSuperview addSubview:initialBackgroundView];
                            backgroundView = initialBackgroundView;
                        }
                        else
                        {
                            backgroundView = strongSelf->_backgroundView;
                        }
                        
                        [UIView animateWithDuration:0.3f animations:^
                        {
                            backgroundView.alpha = 1.0f;
                        }];
                        
                        if (strongSelf->_intent == TGPhotoEditorControllerVideoIntent && strongSelf.requestToolbarsHidden != nil && UIInterfaceOrientationIsLandscape(strongSelf.interfaceOrientation))
                        {
                            strongSelf.requestToolbarsHidden(true, true);
                            strongSelf->_hiddenToolbarView = true;
                        }
                    }
                    
                    return transitionReferenceView;
                };
                cropController.finishedTransitionIn = ^
                {
                    __strong TGPhotoEditorController *strongSelf = weakSelf;
                    if (strongSelf == nil)
                        return;
                    
                    if (isInitialAppearance)
                    {
                        [initialBackgroundView removeFromSuperview];
                        if (strongSelf.finishedTransitionIn != nil)
                            strongSelf.finishedTransitionIn();
                    }
                    else
                    {
                        strongSelf->_backgroundView.alpha = 0.0f;
                    }
                    
                    if (strongSelf->_intent == TGPhotoEditorControllerVideoIntent && strongSelf.requestToolbarsHidden != nil && !strongSelf->_hiddenToolbarView)
                    {
                        strongSelf.requestToolbarsHidden(true, false);
                        strongSelf->_hiddenToolbarView = true;
                    }
                    
                    strongSelf->_switchingTab = false;
                };
                cropController.cropReset = ^
                {
                    __strong TGPhotoEditorController *strongSelf = weakSelf;
                    if (strongSelf == nil)
                        return;
                    
                    [strongSelf rotateVideoOrReset:true];
                };
                
                if (_intent != TGPhotoEditorControllerVideoIntent)
                {
                    [_item fetchOriginalFullSizeImageWithCompletion:^(UIImage *image)
                    {
                        __strong TGPhotoEditorController *strongSelf = weakSelf;
                        if (strongSelf == nil)
                            return;
                        
                        TGDispatchOnMainThread(^
                        {
                            if (cropController.dismissing && !cropController.switching)
                                return;
                            
                            strongSelf.fullSizeImage = image;
                            [cropController setImage:image];
                        });
                    }];
                }
                else if (self.requestImage != nil)
                {
                    UIImage *image = self.requestImage();
                    [cropController setImage:image];
                }
                
                if ([_item respondsToSelector:@selector(fetchMetadataWithCompletion:)])
                {
                    [_item fetchMetadataWithCompletion:^(NSDictionary *metadata)
                    {
                        if (metadata == nil)
                            return;
                        
                        NSDictionary *exif = metadata[@"{Exif}"];
                        if (exif == nil)
                            return;
                        
                        NSString *userComment = exif[@"UserComment"];
                        if (userComment == nil)
                            return;
                        
                        @try
                        {
                            NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:[userComment dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                            if (dictionary == nil)
                                return;
                            
                            if (dictionary[@"DeviceAngle"] == nil)
                                return;
                            
                            CGFloat val = [[dictionary objectForKey:@"DeviceAngle"] floatValue];
                            [cropController setAutorotationAngle:-TGRadiansToDegrees(val)];
                        }
                        @catch (NSException *e)
                        {
                            TGLog(@"Editor: failed to parse UserComment");
                        }
                    }];
                }
                
                controller = cropController;
            }
        }
            break;
            
        case TGPhotoEditorToolsTab:
        {
            TGPhotoToolsController *toolsController = [[TGPhotoToolsController alloc] initWithPhotoEditor:_photoEditor
                                                                                              previewView:_previewView];
            toolsController.toolbarLandscapeSize = _landscapeToolbarView.landscapeSize;

            TGPhotoEditorItemController *enhanceController = nil;
            if (![editorValues toolsApplied] && !_hasOpenedPhotoTools)
            {
                _ignoreDefaultPreviewViewTransitionIn = true;
                _hasOpenedPhotoTools = true;
                
                PGEnhanceTool *enhanceTool = nil;
                for (PGPhotoTool *tool in _photoEditor.tools)
                {
                    if ([tool isKindOfClass:[PGEnhanceTool class]])
                    {
                        enhanceTool = (PGEnhanceTool *)tool;
                        break;
                    }
                }
            
                enhanceController = [[TGPhotoEditorItemController alloc] initWithEditorItem:enhanceTool
                                                                                photoEditor:_photoEditor
                                                                                previewView:nil];
                enhanceController.toolbarLandscapeSize = _landscapeToolbarView.landscapeSize;
                enhanceController.initialAppearance = true;
                
                if ([_currentTabController isKindOfClass:[TGPhotoCropController class]] || [_currentTabController isKindOfClass:[TGPhotoAvatarCropController class]])
                {
                    enhanceController.skipProcessingOnCompletion = true;
                    
                    void (^block)(void) = ^
                    {
                        enhanceController.skipProcessingOnCompletion = false;
                    };
                    
                    if ([_currentTabController isKindOfClass:[TGPhotoCropController class]])
                        ((TGPhotoCropController *)_currentTabController).finishedPhotoProcessing = block;
                    else if ([_currentTabController isKindOfClass:[TGPhotoAvatarCropController class]])
                        ((TGPhotoAvatarCropController *)_currentTabController).finishedPhotoProcessing = block;
                }
                
                __weak TGPhotoToolsController *weakToolsController = toolsController;
                enhanceController.editorItemUpdated = ^
                {
                    __strong TGPhotoToolsController *strongToolsController = weakToolsController;
                    if (strongToolsController != nil)
                        [strongToolsController updateValues];
                };
                
                enhanceController.beginTransitionOut = ^
                {
                    __strong TGPhotoEditorController *strongSelf = weakSelf;
                    if (strongSelf == nil)
                        return;
                    
                    if (strongSelf->_currentTabController.beginItemTransitionOut != nil)
                        strongSelf->_currentTabController.beginItemTransitionOut();
                    
                    //TGPhotoEditorPreviewView *previewView = strongSelf->_previewView;
                    //previewView.interactionEnded = strongSelf->_currentTabController.interactionEnded;
                };
                
                enhanceController.finishedCombinedTransition = ^
                {
                    __strong TGPhotoEditorController *strongSelf = weakSelf;
                    if (strongSelf == nil)
                        return;
                    
                    strongSelf->_ignoreDefaultPreviewViewTransitionIn = false;
                };
                
                [self addChildViewController:enhanceController];
            }
            
            __weak TGPhotoEditorItemController *weakEnhanceController = enhanceController;
            
            toolsController.beginTransitionIn = ^UIView *(CGRect *referenceFrame, UIView **parentView, bool *noTransitionView)
            {
                *referenceFrame = transitionReferenceFrame;
                *parentView = transitionParentView;
                *noTransitionView = transitionNoTransitionView;
                
                __strong TGPhotoEditorController *strongSelf = weakSelf;
                if (strongSelf != nil)
                {
                    __strong TGPhotoEditorItemController *strongEnhanceController = weakEnhanceController;
                    if (strongEnhanceController != nil)
                    {
                        if (isInitialAppearance)
                        {
                            strongSelf->_portraitToolbarView.hidden = true;
                            strongSelf->_landscapeToolbarView.hidden = true;
                        }
                        [(TGPhotoToolsController *)strongSelf->_currentTabController prepareForCombinedAppearance];
                        [strongSelf.view addSubview:strongEnhanceController.view];
                        
                        [strongEnhanceController prepareForCombinedAppearance];
                        
                        CGSize referenceSize = [strongSelf referenceViewSize];
                        strongEnhanceController.view.frame = CGRectMake(0, 0, referenceSize.width, referenceSize.height);
                        
                        strongEnhanceController.view.clipsToBounds = true;
                    }
                }
                
                return transitionReferenceView;
            };
            toolsController.finishedTransitionIn = ^
            {
                __strong TGPhotoEditorController *strongSelf = weakSelf;
                if (strongSelf == nil)
                    return;
                
                if (isInitialAppearance && strongSelf.finishedTransitionIn != nil)
                    strongSelf.finishedTransitionIn();
                
                __strong TGPhotoEditorItemController *strongEnhanceController = weakEnhanceController;
                if (strongEnhanceController != nil)
                {
                    [strongEnhanceController attachPreviewView:strongSelf->_previewView];
                    
                    strongSelf->_portraitToolbarView.hidden = false;
                    strongSelf->_landscapeToolbarView.hidden = false;
                    [(TGPhotoToolsController *)strongSelf->_currentTabController finishedCombinedAppearance];
                    [strongEnhanceController finishedCombinedAppearance];
                }
                
                strongSelf->_switchingTab = false;
            };
            
            controller = toolsController;
        }
            break;
            
        default:
        {

        }
            break;
    }
    
    _currentTabController = controller;
    _currentTabController.intent = _intent;
    _currentTabController.initialAppearance = isInitialAppearance;
    
    if ([self presentedForAvatarCreation] && self.navigationController == nil)
        _currentTabController.transitionSpeed = 20.0f;
    
    [self addChildViewController:_currentTabController];
    [_containerView addSubview:_currentTabController.view];

    _currentTabController.view.frame = _containerView.bounds;
    
    _currentTabController.beginItemTransitionIn = ^
    {
        __strong TGPhotoEditorController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        UIInterfaceOrientation orientation = strongSelf.interfaceOrientation;
        if ([strongSelf inFormSheet])
            orientation = UIInterfaceOrientationPortrait;
        
        if (UIInterfaceOrientationIsPortrait(orientation))
        {
            [strongSelf->_portraitToolbarView transitionOutAnimated:true];
            [strongSelf->_landscapeToolbarView transitionOutAnimated:false];
        }
        else
        {
            [strongSelf->_portraitToolbarView transitionOutAnimated:false];
            [strongSelf->_landscapeToolbarView transitionOutAnimated:true];
        }
    };
    _currentTabController.beginItemTransitionOut = ^
    {
        __strong TGPhotoEditorController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        UIInterfaceOrientation orientation = strongSelf.interfaceOrientation;
        if ([strongSelf inFormSheet])
            orientation = UIInterfaceOrientationPortrait;
        
        if (UIInterfaceOrientationIsPortrait(orientation))
        {
            [strongSelf->_portraitToolbarView transitionInAnimated:true];
            [strongSelf->_landscapeToolbarView transitionInAnimated:false];
        }
        else
        {
            [strongSelf->_portraitToolbarView transitionInAnimated:false];
            [strongSelf->_landscapeToolbarView transitionInAnimated:true];
        }
    };
    
    _currentTab = tab;
    
    [_portraitToolbarView setActiveTab:tab];
    [_landscapeToolbarView setActiveTab:tab];
}

- (void)updateEditorButtonsWithAdjustments:(id<TGMediaEditAdjustments>)adjustments
{
    NSInteger highlightedButtons = [TGPhotoEditorTabController highlightedButtonsForEditorValues:adjustments forAvatar:[self presentedForAvatarCreation] hasCaption:(_caption.length > 0)];
    [_portraitToolbarView setEditButtonsHighlighted:highlightedButtons];
    [_landscapeToolbarView setEditButtonsHighlighted:highlightedButtons];
}

- (void)rotateVideoOrReset:(bool)reset
{
    if (_intent != TGPhotoEditorControllerVideoIntent)
        return;
    
    TGPhotoCropController *cropController = (TGPhotoCropController *)_currentTabController;
    if (![cropController isKindOfClass:[TGPhotoCropController class]])
        return;
    
    if (!reset)
        [cropController rotate];
    
    TGVideoEditAdjustments *adjustments = _item.fetchEditorValues(_item);
    
    PGPhotoEditor *editor = _photoEditor;
    CGRect cropRect = (adjustments != nil) ? adjustments.cropRect : CGRectMake(0, 0, editor.originalSize.width, editor.originalSize.height);
    TGVideoEditAdjustments *updatedAdjustments = [TGVideoEditAdjustments editAdjustmentsWithOriginalSize:editor.originalSize cropRect:cropRect cropOrientation:reset ? UIImageOrientationUp : cropController.cropOrientation cropLockedAspectRatio:adjustments.cropLockedAspectRatio trimStartValue:adjustments.trimStartValue trimEndValue:adjustments.trimEndValue];
    
    [self updateEditorButtonsWithAdjustments:updatedAdjustments];
}

- (void)cancelButtonPressed
{
    if (![_currentTabController isDismissAllowed])
        return;
 
    __weak TGPhotoEditorController *weakSelf = self;
    void(^dismiss)(void) = ^
    {
        __strong TGPhotoEditorController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        strongSelf.view.userInteractionEnabled = false;
        [strongSelf->_currentTabController prepareTransitionOutSaving:false];
        
        if (strongSelf.navigationController != nil)
        {
            [strongSelf.navigationController popViewControllerAnimated:true];
        }
        else
        {
            [strongSelf transitionOutSaving:false completion:^
            {
                [strongSelf dismiss];
            }];
        }
        
        if (strongSelf.finishedEditing != nil)
            strongSelf.finishedEditing(nil, nil, nil, true);
    };
    
    PGPhotoEditorValues *editorValues = [_photoEditor exportAdjustments];
    
    if ((_initialAdjustments == nil && (![editorValues isDefaultValuesForAvatar:[self presentedForAvatarCreation]] || editorValues.cropOrientation != UIImageOrientationUp)) || (_initialAdjustments != nil && ![editorValues isEqual:_initialAdjustments]))
    {
        NSArray *actions = @[ [[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"PhotoEditor.DiscardChanges") action:@"discard"],
                              [[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Common.Cancel") action:@"cancel" type:TGActionSheetActionTypeCancel]];
        
        TGActionSheet *actionSheet = [[TGActionSheet alloc] initWithTitle:nil actions:actions actionBlock:^(id __unused target, NSString *action)
        {
            if ([action isEqualToString:@"discard"])
                dismiss();
        } target:self];
        
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
        {
            CGRect rect = CGRectZero;
            if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation))
                rect = [self.view convertRect:_portraitToolbarView.cancelButtonFrame fromView:_portraitToolbarView];
            else
                rect = [self.view convertRect:_landscapeToolbarView.cancelButtonFrame fromView:_landscapeToolbarView];
            
            [actionSheet showFromRect:rect inView:self.view animated:true];
        }
        else
        {
            [actionSheet showInView:self.view];
        }
    }
    else
    {
        dismiss();
    }
}

- (void)doneButtonPressed
{
    if (![_currentTabController isDismissAllowed])
        return;
    
    self.view.userInteractionEnabled = false;
    [_currentTabController prepareTransitionOutSaving:true];
    
    if (_intent != TGPhotoEditorControllerVideoIntent)
    {
        TGProgressWindow *progressWindow = nil;
        if (![_currentTabController isKindOfClass:[TGPhotoCaptionController class]])
        {
            progressWindow = [[TGProgressWindow alloc] init];
            progressWindow.windowLevel = self.view.window.windowLevel + 0.001f;
            [progressWindow performSelector:@selector(showAnimated) withObject:nil afterDelay:0.5];
        }
        
        PGPhotoEditorValues *editorValues = [_photoEditor exportAdjustments];
        [self createEditedImageWithEditorValues:editorValues createThumbnail:![self presentedForAvatarCreation] showProgress:(progressWindow == nil) completion:^
        {
            [NSObject cancelPreviousPerformRequestsWithTarget:progressWindow selector:@selector(showAnimated) object:nil];
            [progressWindow dismiss:true];
            
            if (![self presentedForAvatarCreation])
            {
                [self transitionOutSaving:true completion:^
                {
                    [self dismiss];
                }];
            }
        }];
    }
    else
    {
        TGVideoEditAdjustments *adjustments = [_photoEditor exportAdjustments];
        
        if (self.finishedEditing != nil)
        {
            if ([adjustments isEqual:_initialAdjustments] || (_initialAdjustments == nil && [adjustments isDefaultValuesForAvatar:false] && adjustments.cropOrientation == UIImageOrientationUp))
                self.finishedEditing(nil, nil, nil, true);
            else
                self.finishedEditing(adjustments, nil, nil, false);
        }
        
        [self transitionOutSaving:true completion:^
        {
            [self dismiss];
        }];
    }
}

#pragma mark - Layout

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self.view setNeedsLayout];
    
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    [self updateLayout:[UIApplication sharedApplication].statusBarOrientation];
}

- (bool)inFormSheet
{
    if (iosMajorVersion() < 9)
        return [super inFormSheet];
    
    UIUserInterfaceSizeClass sizeClass = TGAppDelegateInstance.rootController.traitCollection.horizontalSizeClass;
    if (sizeClass == UIUserInterfaceSizeClassCompact)
        return false;
    
    return [super inFormSheet];
}

- (CGSize)referenceViewSize
{
    if ([self inFormSheet])
        return CGSizeMake(540.0f, 620.0f);
    
    return TGAppDelegateInstance.rootController.view.bounds.size;
}

- (void)updateLayout:(UIInterfaceOrientation)orientation
{
    if ([self inFormSheet] || [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
        orientation = UIInterfaceOrientationPortrait;
    
    CGSize referenceSize = [self referenceViewSize];
    
    CGFloat screenSide = MAX(referenceSize.width, referenceSize.height);
    _wrapperView.frame = CGRectMake((referenceSize.width - screenSide) / 2, (referenceSize.height - screenSide) / 2, screenSide, screenSide);
    
    _containerView.frame = CGRectMake((screenSide - referenceSize.width) / 2,
                                      (screenSide - referenceSize.height) / 2,
                                      referenceSize.width,
                                      referenceSize.height);
    
    UIEdgeInsets screenEdges = UIEdgeInsetsMake((screenSide - referenceSize.height) / 2, (screenSide - referenceSize.width) / 2, (screenSide + referenceSize.height) / 2, (screenSide + referenceSize.width) / 2);
    
    _landscapeToolbarView.interfaceOrientation = orientation;
    
    switch (orientation)
    {
        case UIInterfaceOrientationLandscapeLeft:
        {
            [UIView performWithoutAnimation:^
            {
                _landscapeToolbarView.frame = CGRectMake(screenEdges.left, screenEdges.top, [_landscapeToolbarView landscapeSize], referenceSize.height);
            }];
        }
            break;
            
        case UIInterfaceOrientationLandscapeRight:
        {
            [UIView performWithoutAnimation:^
            {
                _landscapeToolbarView.frame = CGRectMake(screenEdges.right - [_landscapeToolbarView landscapeSize], screenEdges.top, [_landscapeToolbarView landscapeSize], referenceSize.height);
            }];
        }
            break;
            
        default:
        {
            _landscapeToolbarView.frame = CGRectMake(_landscapeToolbarView.frame.origin.x, screenEdges.top, [_landscapeToolbarView landscapeSize], referenceSize.height);
        }
            break;
    }
    
    _portraitToolbarView.frame = CGRectMake(screenEdges.left, screenSide - TGPhotoEditorToolbarSize, referenceSize.width, TGPhotoEditorToolbarSize);
}

+ (NSArray *)defaultTabsForAvatarIntent
{
    static dispatch_once_t onceToken;
    static NSArray *avatarTabs = nil;
    dispatch_once(&onceToken, ^
    {
        if (iosMajorVersion() >= 7)
            avatarTabs = @[ @(TGPhotoEditorCropTab), @(TGPhotoEditorToolsTab) ];
        else
            avatarTabs = @[];
    });
    return avatarTabs;
}

@end
