#import "TGPhotoEditorController.h"

#import "TGApplication.h"
#import "TGAppDelegate.h"
#import <objc/runtime.h>

#import "ASWatcher.h"

#import "TGOverlayControllerWindow.h"

#import "TGPhotoEditorAnimation.h"
#import "TGPhotoEditorInterfaceAssets.h"
#import "TGImageUtils.h"
#import "TGPhotoEditorUtils.h"
#import <Photos/Photos.h>

#import "TGHacks.h"
#import "UIImage+TG.h"

#import "TGProgressWindow.h"

#import "TGActionSheet.h"

#import "PGPhotoEditor.h"
#import "PGEnhanceTool.h"

#import "PGPhotoEditorValues.h"
#import "TGVideoEditAdjustments.h"

#import "TGPhotoToolbarView.h"
#import "TGPhotoEditorPreviewView.h"

#import "TGMenuView.h"

#import "TGMediaAssetsLibrary.h"

#import "TGPhotoCaptionController.h"
#import "TGPhotoCropController.h"
#import "TGPhotoAvatarCropController.h"
#import "TGPhotoToolsController.h"
#import "TGPhotoEditorItemController.h"

#import "TGMessageImageViewOverlayView.h"

@interface TGPhotoEditorController () <ASWatcher, TGViewControllerNavigationBarAppearance, UIDocumentInteractionControllerDelegate>
{
    bool _switchingTab;
    TGPhotoEditorTab _availableTabs;
    TGPhotoEditorTab _currentTab;
    TGPhotoEditorTabController *_currentTabController;
    
    UIView *_backgroundView;
    UIView *_containerView;
    UIView *_wrapperView;
    UIView *_transitionWrapperView;
    TGPhotoToolbarView *_portraitToolbarView;
    TGPhotoToolbarView *_landscapeToolbarView;
    TGPhotoEditorPreviewView *_previewView;
    
    PGPhotoEditor *_photoEditor;
    
    SQueue *_queue;
    TGPhotoEditorControllerIntent _intent;
    id<TGMediaEditableItem> _item;
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
    
    TGMenuContainerView *_menuContainerView;
    UIDocumentInteractionController *_documentController;
    
    bool _progressVisible;
    TGMessageImageViewOverlayView *_progressView;
}

@property (nonatomic, weak) UIImage *fullSizeImage;

@end

@implementation TGPhotoEditorController

@synthesize actionHandle = _actionHandle;

- (instancetype)initWithItem:(id<TGMediaEditableItem>)item intent:(TGPhotoEditorControllerIntent)intent adjustments:(id<TGMediaEditAdjustments>)adjustments caption:(NSString *)caption screenImage:(UIImage *)screenImage availableTabs:(TGPhotoEditorTab)availableTabs selectedTab:(TGPhotoEditorTab)selectedTab
{
    self = [super init];
    if (self != nil)
    {
        _actionHandle = [[ASHandle alloc] initWithDelegate:self releaseOnMainThread:true];
        
        self.automaticallyManageScrollViewInsets = false;
        self.autoManageStatusBarBackground = false;
        self.isImportant = true;
        
        _availableTabs = availableTabs;

        _item = item;
        _currentTab = selectedTab;
        _intent = intent;
        
        _caption = caption;
        _initialAdjustments = adjustments;
        _screenImage = screenImage;
        
        _queue = [[SQueue alloc] init];
        _photoEditor = [[PGPhotoEditor alloc] initWithOriginalSize:_item.originalSize adjustments:adjustments forVideo:(intent == TGPhotoEditorControllerVideoIntent)];
        if ([self presentedForAvatarCreation])
        {
            CGFloat shortSide = MIN(_item.originalSize.width, _item.originalSize.height);
            _photoEditor.cropRect = CGRectMake((_item.originalSize.width - shortSide) / 2, (_item.originalSize.height - shortSide) / 2, shortSide, shortSide);
        }
    }
    return self;
}

- (void)dealloc
{
    [_actionHandle reset];
}

- (void)loadView
{
    [super loadView];
    
    self.view.frame = (CGRect){ CGPointZero, [self referenceViewSize]};
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
    
    _transitionWrapperView = [[UIView alloc] initWithFrame:_wrapperView.bounds];
    [_wrapperView addSubview:_transitionWrapperView];
    
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
    
    void(^toolbarDoneLongPressed)(id) = ^(id sender)
    {
        __strong TGPhotoEditorController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        [strongSelf doneButtonLongPressed:sender];
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

    _portraitToolbarView = [[TGPhotoToolbarView alloc] initWithBackButtonTitle:backButtonTitle doneButtonTitle:doneButtonTitle accentedDone:![self presentedForAvatarCreation] solidBackground:true];
    [_portraitToolbarView setToolbarTabs:_availableTabs animated:false];
    [_portraitToolbarView setActiveTab:_currentTab];
    _portraitToolbarView.cancelPressed = toolbarCancelPressed;
    _portraitToolbarView.donePressed = toolbarDonePressed;
    _portraitToolbarView.doneLongPressed = toolbarDoneLongPressed;
    _portraitToolbarView.tabPressed = toolbarTabPressed;
    [_wrapperView addSubview:_portraitToolbarView];
    
    _landscapeToolbarView = [[TGPhotoToolbarView alloc] initWithBackButtonTitle:backButtonTitle doneButtonTitle:doneButtonTitle accentedDone:![self presentedForAvatarCreation] solidBackground:true];
    [_landscapeToolbarView setToolbarTabs:_availableTabs animated:false];
    [_landscapeToolbarView setActiveTab:_currentTab];
    _landscapeToolbarView.cancelPressed = toolbarCancelPressed;
    _landscapeToolbarView.donePressed = toolbarDonePressed;
    _landscapeToolbarView.doneLongPressed = toolbarDoneLongPressed;
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
    
    SSignal *thumbnailImageSignal = self.requestThumbnailImage(_item);
    [[thumbnailImageSignal filter:^bool(id image)
    {
        return [image isKindOfClass:[UIImage class]];
    }] startWithNext:^(UIImage *next)
    {
        _aspectRatioThumbnailImage = next;
        
        if ([_currentTabController isKindOfClass:[TGPhotoCropController class]])
            [(TGPhotoCropController *)_currentTabController setBackdropImage:_aspectRatioThumbnailImage];
    }];
    
    if ([_currentTabController isKindOfClass:[TGPhotoCropController class]] || [_currentTabController isKindOfClass:[TGPhotoCaptionController class]] || [_currentTabController isKindOfClass:[TGPhotoAvatarCropController class]])
        return;
    
    SSignal *signal = nil;
    if ([_photoEditor hasDefaultCropping])
    {
        signal = [self.requestOriginalScreenSizeImage(_item) filter:^bool(id image)
        {
            return [image isKindOfClass:[UIImage class]];
        }];
    }
    else
    {
        signal = [[[[self.requestOriginalFullSizeImage(_item) takeLast] deliverOn:_queue] filter:^bool(id image)
        {
            return [image isKindOfClass:[UIImage class]];
        }] map:^UIImage *(UIImage *image)
        {
            return TGPhotoEditorCrop(image, _photoEditor.cropOrientation, _photoEditor.cropRotation, _photoEditor.cropRect, TGPhotoEditorScreenImageMaxSize(), _photoEditor.originalSize, true);
        }];
    }
    
    [signal startWithNext:^(UIImage *next)
    {
        [_photoEditor setImage:next forCropRect:_photoEditor.cropRect cropRotation:_photoEditor.cropRotation cropOrientation:_photoEditor.cropOrientation fullSize:false];
        
        if (_ignoreDefaultPreviewViewTransitionIn)
        {
            TGDispatchOnMainThread(^
            {
                [_previewView setSnapshotImage:next];
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
                        [_previewView setSnapshotImage:next];
                    }];
                });
            }];
        }
    }];
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
    [_portraitToolbarView setEditButtonsEnabled:enabled animated:animated];
    [_landscapeToolbarView setEditButtonsEnabled:enabled animated:animated];
    
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

- (void)createEditedImageWithEditorValues:(PGPhotoEditorValues *)editorValues createThumbnail:(bool)createThumbnail showProgress:(bool)showProgress saveOnly:(bool)saveOnly completion:(void (^)(UIImage *))completion
{
    if (!saveOnly)
    {
        bool forAvatar = [self presentedForAvatarCreation];
        if (!forAvatar && [editorValues isDefaultValuesForAvatar:false])
        {
            if (self.willFinishEditing != nil)
                self.willFinishEditing(nil, [_currentTabController currentResultRepresentation], true);
            
            if (self.didFinishEditing != nil)
                self.didFinishEditing(nil, nil, nil, true);

            if (completion != nil)
                completion(nil);
            
            return;
        }
        
        if ([editorValues isEqual:_initialAdjustments])
        {
            if (self.willFinishEditing != nil)
                self.willFinishEditing(nil, nil, false);
            
            if (self.didFinishEditing != nil)
                self.didFinishEditing(nil, nil, nil, false);
            
            if (completion != nil)
                completion(nil);
            
            return;
        }
    }
    
    TGProgressWindow *progressWindow = nil;
    if (showProgress)
    {
        progressWindow = [[TGProgressWindow alloc] init];
        progressWindow.windowLevel = self.view.window.windowLevel + 0.001f;
        [progressWindow showAnimated];
    }
    
    UIImage *fullSizeImage = self.fullSizeImage;
    PGPhotoEditor *photoEditor = _photoEditor;
    
    SSignal *imageSignal = nil;
    if (fullSizeImage == nil)
    {
        imageSignal = [[self.requestOriginalFullSizeImage(_item) filter:^bool(id result)
        {
            return [result isKindOfClass:[UIImage class]];
        }] takeLast];
    }
    else
    {
        imageSignal = [SSignal single:fullSizeImage];
    }
    
    SSignal *(^imageCropSignal)(UIImage *, bool) = ^(UIImage *image, bool resize)
    {
        return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
        {
            UIImage *croppedImage = TGPhotoEditorCrop(image, photoEditor.cropOrientation, photoEditor.cropRotation, photoEditor.cropRect, TGPhotoEditorResultImageMaxSize, _photoEditor.originalSize, resize);
            [subscriber putNext:croppedImage];
            [subscriber putCompletion];
            
            return nil;
        }];
    };
    
    SSignal *(^imageRenderSignal)(UIImage *) = ^(UIImage *image)
    {
        return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
        {
            [_photoEditor setImage:image forCropRect:photoEditor.cropRect cropRotation:photoEditor.cropRotation cropOrientation:photoEditor.cropOrientation fullSize:true];
            [_photoEditor createResultImageWithCompletion:^(UIImage *result)
            {
                [subscriber putNext:result];
                [subscriber putCompletion];
            }];
            
            return nil;
        }];
    };
    
    if (!saveOnly && self.willFinishEditing != nil)
        self.willFinishEditing(editorValues, [_currentTabController currentResultRepresentation], true);
    
    if (!saveOnly && completion != nil)
        completion(nil);
    
    bool hasImageAdjustments = editorValues.toolsApplied || saveOnly;
    
    SSignal *renderedImageSignal = [[imageSignal mapToSignal:^SSignal *(UIImage *image)
    {
        return [imageCropSignal(image, !hasImageAdjustments) startOn:_queue];
    }] mapToSignal:^SSignal *(UIImage *image)
    {
        if (hasImageAdjustments)
            return [[[SSignal complete] delay:0.3 onQueue:_queue] then:imageRenderSignal(image)];
        else
            return [SSignal single:image];
    }];
    
    if (saveOnly)
    {
        [[renderedImageSignal deliverOn:[SQueue mainQueue]] startWithNext:^(UIImage *image)
        {
            if (completion != nil)
                completion(image);
        }];
    }
    else
    {
        [[[[renderedImageSignal map:^id(UIImage *image)
        {
            if (!hasImageAdjustments)
            {
                return image;
            }
            else
            {
                if (!saveOnly && self.didFinishRenderingFullSizeImage != nil)
                    self.didFinishRenderingFullSizeImage(image);
                
                return TGPhotoEditorFitImage(image, TGPhotoEditorResultImageMaxSize);
            }
        }] map:^NSDictionary *(UIImage *image)
        {
            NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
            if (image != nil)
                result[@"image"] = image;
            
            if (createThumbnail)
            {
                CGSize fillSize = TGPhotoThumbnailSizeForCurrentScreen();
                fillSize.width = CGCeil(fillSize.width);
                fillSize.height = CGCeil(fillSize.height);
                
                CGSize size = TGScaleToFillSize(image.size, fillSize);
                
                UIGraphicsBeginImageContextWithOptions(size, true, 0.0f);
                CGContextRef context = UIGraphicsGetCurrentContext();
                CGContextSetInterpolationQuality(context, kCGInterpolationMedium);
                
                [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
                
                UIImage *thumbnailImage = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                
                if (thumbnailImage != nil)
                    result[@"thumbnail"] = thumbnailImage;
            }
            
            return result;
        }] deliverOn:[SQueue mainQueue]] startWithNext:^(NSDictionary *result)
        {
            [progressWindow dismiss:true];
            
            UIImage *image = result[@"image"];
            UIImage *thumbnailImage = result[@"thumbnail"];
            
            if (!saveOnly && self.didFinishEditing != nil)
                self.didFinishEditing(editorValues, image, thumbnailImage, true);
        } error:^(__unused id error) {
            TGLog(@"renderedImageSignal error");
        } completed:nil];
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
    
    if (self.beginCustomTransitionOut != nil)
    {
        id rep = [_currentTabController currentResultRepresentation];
        if ([rep isKindOfClass:[UIImage class]])
        {
            UIImageView *imageView = [[UIImageView alloc] initWithImage:(UIImage *)rep];
            rep = imageView;
        }
        [_currentTabController prepareForCustomTransitionOut];
        self.beginCustomTransitionOut([_currentTabController transitionOutReferenceFrame], rep, completion);
    }
    else
    {
        [_currentTabController transitionOutSaving:saving completion:^
        {
            if (completion != nil)
                completion();
            
            if (self.finishedTransitionOut != nil)
                self.finishedTransitionOut(saving);
        }];
    }
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
            captionController.suggestionContext = self.suggestionContext;
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
                TGPhotoAvatarCropController *cropController = [[TGPhotoAvatarCropController alloc] initWithPhotoEditor:_photoEditor previewView:_previewView];
                
                bool skipInitialTransition = (![self presentedFromCamera] && self.navigationController != nil) || self.skipInitialTransition;
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
                
                [[[[self.requestOriginalFullSizeImage(_item) reduceLeftWithPassthrough:nil with:^id(__unused id current, __unused id next, void (^emit)(id))
                {
                    if ([next isKindOfClass:[UIImage class]])
                    {
                        if ([next degraded])
                        {
                            emit(next);
                            return current;
                        }
                        return next;
                    }
                    else
                    {
                        return current;
                    }
                }] filter:^bool(id result)
                {
                    return (result != nil);
                }] deliverOn:[SQueue mainQueue]] startWithNext:^(UIImage *image)
                {
                    if (cropController.dismissing && !cropController.switching)
                        return;
                    
                    [self updateDoneButtonEnabled:!image.degraded animated:true];
                    if (image.degraded)
                    {
                        return;
                    }
                    else
                    {
                        self.fullSizeImage = image;
                        [cropController setImage:image];
                    }
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
                    [[self.requestOriginalFullSizeImage(_item) deliverOn:[SQueue mainQueue]] startWithNext:^(UIImage *image)
                    {
                        if (cropController.dismissing && !cropController.switching)
                            return;
                        
                        if (![image isKindOfClass:[UIImage class]] || image.degraded)
                            return;
                        
                        self.fullSizeImage = image;
                        [cropController setImage:image];
                    }];
                }
                else if (self.requestImage != nil)
                {
                    UIImage *image = self.requestImage();
                    [cropController setImage:image];
                }
                
//                if ([_item respondsToSelector:@selector(fetchMetadataWithCompletion:)])
//                {
//                    [_item fetchMetadataWithCompletion:^(NSDictionary *metadata)
//                    {
//                        if (metadata == nil)
//                            return;
//                        
//                        NSDictionary *exif = metadata[@"{Exif}"];
//                        if (exif == nil)
//                            return;
//                        
//                        NSString *userComment = exif[@"UserComment"];
//                        if (userComment == nil)
//                            return;
//                        
//                        @try
//                        {
//                            NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:[userComment dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
//                            if (dictionary == nil)
//                                return;
//                            
//                            if (dictionary[@"DeviceAngle"] == nil)
//                                return;
//                            
//                            CGFloat val = [[dictionary objectForKey:@"DeviceAngle"] floatValue];
//                            [cropController setAutorotationAngle:-TGRadiansToDegrees(val)];
//                        }
//                        @catch (NSException *e)
//                        {
//                            TGLog(@"Editor: failed to parse UserComment");
//                        }
//                    }];
//                }
                
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
    TGPhotoEditorTab highlightedButtons = [TGPhotoEditorTabController highlightedButtonsForEditorValues:adjustments forAvatar:[self presentedForAvatarCreation] hasCaption:(_caption.length > 0)];
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
    
    TGVideoEditAdjustments *adjustments = (TGVideoEditAdjustments *)self.requestAdjustments(_item);
    
    PGPhotoEditor *editor = _photoEditor;
    CGRect cropRect = (adjustments != nil) ? adjustments.cropRect : CGRectMake(0, 0, editor.originalSize.width, editor.originalSize.height);
    TGVideoEditAdjustments *updatedAdjustments = [TGVideoEditAdjustments editAdjustmentsWithOriginalSize:editor.originalSize cropRect:cropRect cropOrientation:reset ? UIImageOrientationUp : cropController.cropOrientation cropLockedAspectRatio:adjustments.cropLockedAspectRatio trimStartValue:adjustments.trimStartValue trimEndValue:adjustments.trimEndValue];
    
    [self updateEditorButtonsWithAdjustments:updatedAdjustments];
}

- (void)dismissAnimated:(bool)animated
{
    self.view.userInteractionEnabled = false;
    
    if (animated)
    {
        const CGFloat velocity = 2000.0f;
        CGFloat duration = self.view.frame.size.height / velocity;
        CGRect targetFrame = CGRectOffset(self.view.frame, 0, self.view.frame.size.height);
        
        [UIView animateWithDuration:duration animations:^
        {
            self.view.frame = targetFrame;
        } completion:^(__unused BOOL finished)
        {
            [self dismiss];
        }];
    }
    else
    {
        [self dismiss];
    }
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
        
        if (strongSelf.willFinishEditing != nil)
            strongSelf.willFinishEditing(nil, nil, false);
        
        if (strongSelf.didFinishEditing != nil)
            strongSelf.didFinishEditing(nil, nil, nil, false);
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
        
        bool forAvatar = [self presentedForAvatarCreation];
        PGPhotoEditorValues *editorValues = [_photoEditor exportAdjustments];
        [self createEditedImageWithEditorValues:editorValues createThumbnail:!forAvatar showProgress:(progressWindow == nil) saveOnly:false completion:^(__unused UIImage *image)
        {
            [NSObject cancelPreviousPerformRequestsWithTarget:progressWindow selector:@selector(showAnimated) object:nil];
            [progressWindow dismiss:true];
            
            if (forAvatar)
                return;
            
            [self transitionOutSaving:true completion:^
            {
                [self dismiss];
            }];
        }];
    }
    else
    {
        TGVideoEditAdjustments *adjustments = [_photoEditor exportAdjustments];
        
        bool hasChanges = !([adjustments isEqual:_initialAdjustments] || (_initialAdjustments == nil && [adjustments isDefaultValuesForAvatar:false] && adjustments.cropOrientation == UIImageOrientationUp));
        
        if (self.willFinishEditing != nil)
            self.willFinishEditing(hasChanges ? adjustments : nil, nil, hasChanges);
        
        if (self.didFinishEditing != nil)
            self.didFinishEditing(hasChanges ? adjustments : nil, nil, nil, hasChanges);
        
        [self transitionOutSaving:true completion:^
        {
            [self dismiss];
        }];
    }
}

- (void)doneButtonLongPressed:(UIButton *)sender
{
    if (_menuContainerView != nil)
    {
        [_menuContainerView removeFromSuperview];
        _menuContainerView = nil;
    }

    _menuContainerView = [[TGMenuContainerView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:_menuContainerView];
    
    NSMutableArray *actions = [[NSMutableArray alloc] init];
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"instagram://"]])
        [actions addObject:@{ @"title": @"Share on Instagram", @"action": @"instagram" }];
    [actions addObject:@{ @"title": @"Save to Camera Roll", @"action": @"save" }];
    
    [_menuContainerView.menuView setButtonsAndActions:actions watcherHandle:_actionHandle];
    [_menuContainerView.menuView sizeToFit];
    
    CGRect titleLockIconViewFrame = [sender.superview convertRect:sender.frame toView:_menuContainerView];
    titleLockIconViewFrame.origin.y += 16.0f;
    [_menuContainerView showMenuFromRect:titleLockIconViewFrame animated:false];
}

- (void)actionStageActionRequested:(NSString *)action options:(id)options
{
    if ([action isEqualToString:@"menuAction"])
    {
        NSString *menuAction = options[@"action"];
        if ([menuAction isEqualToString:@"save"])
            [self _saveToCameraRoll];
        else if ([menuAction isEqualToString:@"instagram"])
            [self _openInInstagram];
    }
}

#pragma mark - External Export

- (void)_saveToCameraRoll
{
    TGProgressWindow *progressWindow = [[TGProgressWindow alloc] init];
    progressWindow.windowLevel = self.view.window.windowLevel + 0.001f;
    [progressWindow performSelector:@selector(showAnimated) withObject:nil afterDelay:0.5];
    
    PGPhotoEditorValues *editorValues = [_photoEditor exportAdjustments];
    [self createEditedImageWithEditorValues:editorValues createThumbnail:false showProgress:false saveOnly:true completion:^(UIImage *resultImage)
    {
        [[[[TGMediaAssetsLibrary sharedLibrary] saveAssetWithImage:resultImage] deliverOn:[SQueue mainQueue]] startWithNext:nil completed:^
        {
            [NSObject cancelPreviousPerformRequestsWithTarget:progressWindow selector:@selector(showAnimated) object:nil];
            [progressWindow dismissWithSuccess];
        }];
    }];
}

- (void)_openInInstagram
{
    TGProgressWindow *progressWindow = [[TGProgressWindow alloc] init];
    progressWindow.windowLevel = self.view.window.windowLevel + 0.001f;
    [progressWindow performSelector:@selector(showAnimated) withObject:nil afterDelay:0.5];
    
    PGPhotoEditorValues *editorValues = [_photoEditor exportAdjustments];
    [self createEditedImageWithEditorValues:editorValues createThumbnail:false showProgress:false saveOnly:true completion:^(UIImage *resultImage)
    {
        [NSObject cancelPreviousPerformRequestsWithTarget:progressWindow selector:@selector(showAnimated) object:nil];
        [progressWindow dismiss:true];
        
        NSData *imageData = UIImageJPEGRepresentation(resultImage, 0.9);
        NSString *writePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"instagram.igo"];
        if (![imageData writeToFile:writePath atomically:true])
        {
            return;
        }
        
        NSURL *fileURL = [NSURL fileURLWithPath:writePath];
        
        _documentController = [UIDocumentInteractionController interactionControllerWithURL:fileURL];
        _documentController.delegate = self;
        [_documentController setUTI:@"com.instagram.exclusivegram"];
        if (_caption.length > 0)
            [_documentController setAnnotation:@{@"InstagramCaption" : _caption}];
        [_documentController presentOpenInMenuFromRect:self.view.frame inView:self.view animated:true];
    }];
}

- (void)documentInteractionControllerDidDismissOpenInMenu:(UIDocumentInteractionController *)__unused controller
{
    _documentController = nil;
}

#pragma mark -

- (void)dismiss
{
    if (self.overlayWindow != nil)
    {
        [super dismiss];
    }
    else
    {
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
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
    
    if (self.parentViewController != nil)
        return self.parentViewController.view.frame.size;
    else if (self.navigationController != nil)
        return self.navigationController.view.frame.size;
    
    return TGAppDelegateInstance.rootController.applicationBounds.size;
}

- (void)updateLayout:(UIInterfaceOrientation)orientation
{
    bool isPad = [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad;
    
    if ([self inFormSheet] || isPad)
        orientation = UIInterfaceOrientationPortrait;
    
    CGSize referenceSize = [self referenceViewSize];
    
    CGFloat screenSide = MAX(referenceSize.width, referenceSize.height);
    _wrapperView.frame = CGRectMake((referenceSize.width - screenSide) / 2, (referenceSize.height - screenSide) / 2, screenSide, screenSide);
    
    _containerView.frame = CGRectMake((screenSide - referenceSize.width) / 2, (screenSide - referenceSize.height) / 2, referenceSize.width, referenceSize.height);
    _transitionWrapperView.frame = _containerView.frame;
    
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
    
    CGFloat portraitToolbarViewBottomEdge = screenSide;
    if (isPad)
        portraitToolbarViewBottomEdge = screenEdges.bottom;
    _portraitToolbarView.frame = CGRectMake(screenEdges.left, portraitToolbarViewBottomEdge - TGPhotoEditorToolbarSize, referenceSize.width, TGPhotoEditorToolbarSize);
}

- (void)_setScreenImage:(UIImage *)screenImage
{
    _screenImage = screenImage;
    if ([_currentTabController isKindOfClass:[TGPhotoAvatarCropController class]])
        [(TGPhotoAvatarCropController *)_currentTabController setSnapshotImage:screenImage];
}

- (void)_finishedTransitionIn
{
    _switchingTab = false;
    if ([_currentTabController isKindOfClass:[TGPhotoAvatarCropController class]])
        [(TGPhotoAvatarCropController *)_currentTabController _finishedTransitionIn];
}

- (CGFloat)toolbarLandscapeSize
{
    return _landscapeToolbarView.landscapeSize;
}

- (UIView *)transitionWrapperView
{
    return _transitionWrapperView;
}

- (void)setProgressVisible:(bool)progressVisible value:(CGFloat)value animated:(bool)animated
{
    _progressVisible = progressVisible;
    
    if (progressVisible && _progressView == nil)
    {
        _progressView = [[TGMessageImageViewOverlayView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 50.0f, 50.0f)];
        _progressView.userInteractionEnabled = false;
        
        _progressView.frame = (CGRect){{CGFloor((_wrapperView.frame.size.width - _progressView.frame.size.width) / 2.0f), CGFloor((_wrapperView.frame.size.height - _progressView.frame.size.height) / 2.0f)}, _progressView.frame.size};
    }
    
    if (progressVisible)
    {
        if (_progressView.superview == nil)
            [_wrapperView addSubview:_progressView];
        
        _progressView.alpha = 1.0f;
    }
    else if (_progressView.superview != nil)
    {
        if (animated)
        {
            [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^
            {
                _progressView.alpha = 0.0f;
            } completion:^(BOOL finished)
            {
                if (finished)
                    [_progressView removeFromSuperview];
            }];
        }
        else
            [_progressView removeFromSuperview];
    }
    
    [_progressView setProgress:value cancelEnabled:false animated:animated];
}

+ (TGPhotoEditorTab)defaultTabsForAvatarIntent
{
    static dispatch_once_t onceToken;
    static TGPhotoEditorTab avatarTabs = TGPhotoEditorNoneTab;
    dispatch_once(&onceToken, ^
    {
        if (iosMajorVersion() >= 7)
            avatarTabs = TGPhotoEditorCropTab | TGPhotoEditorToolsTab;
    });
    return avatarTabs;
}

@end
