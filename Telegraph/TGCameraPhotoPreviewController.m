#import "TGCameraPhotoPreviewController.h"

#import <objc/runtime.h>

#import "UIImage+TGEditablePhotoItem.h"

#import "PGCameraShotMetadata.h"
#import "PGPhotoEditorValues.h"
#import "TGPhotoEditorUtils.h"
#import "TGImageUtils.h"
#import "TGHacks.h"
#import "ATQueue.h"

#import "TGModernGalleryZoomableScrollView.h"

#import "TGFullscreenContainerView.h"
#import "TGOverlayControllerWindow.h"
#import "TGPhotoEditorController.h"
#import "TGPhotoEditorTabController.h"
#import "TGPhotoToolbarView.h"
#import "TGPhotoEditorAnimation.h"

@interface TGCameraPhotoPreviewWrapperView : UIView

@end

@implementation TGCameraPhotoPreviewWrapperView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *view = [super hitTest:point withEvent:event];
    if (view != self)
        return view;
    
    return nil;
}

@end

@interface TGCameraPhotoPreviewController () <UIScrollViewDelegate>
{
    UIImage *_image;
    UIImage *_editedImage;
    PGPhotoEditorValues *_editorValues;
    PGCameraShotMetadata *_metadata;
    NSString *_caption;
    
    TGCameraPhotoPreviewWrapperView *_wrapperView;
    UIView *_transitionParentView;
    TGModernGalleryZoomableScrollView *_scrollView;
    UIImageView *_imageView;

    NSArray *_availableTabs;
    TGPhotoToolbarView *_portraitToolbarView;
    TGPhotoToolbarView *_landscapeToolbarView;
    
    bool _transitionInProgress;
    bool _dismissing;
}

@property (nonatomic, weak) TGPhotoEditorController *editorController;

@end

@implementation TGCameraPhotoPreviewController

- (instancetype)initWithImage:(UIImage *)image metadata:(PGCameraShotMetadata *)metadata
{
    self = [super init];
    if (self != nil)
    {
        _image = image;
        _metadata = metadata;
        
        self.automaticallyManageScrollViewInsets = false;
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    object_setClass(self.view, [TGFullscreenContainerView class]);
    
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.view.backgroundColor = [UIColor clearColor];
    
    _transitionParentView = [[UIView alloc] initWithFrame:self.view.bounds];
    _transitionParentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_transitionParentView];
    
    CGRect containerFrame = self.view.bounds;
    CGSize fittedSize = TGScaleToSize(_image.size, containerFrame.size);

    _scrollView = [[TGModernGalleryZoomableScrollView alloc] initWithFrame:self.view.bounds];
    _scrollView.clipsToBounds = false;
    _scrollView.delegate = self;
    _scrollView.showsHorizontalScrollIndicator = false;
    _scrollView.showsVerticalScrollIndicator = false;
    [self.view addSubview:_scrollView];
    
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, fittedSize.width, fittedSize.height)];
    _imageView.image = _image;
    [self.view addSubview:_imageView];
    
    if (_metadata.frontal)
        _imageView.transform = CGAffineTransformMakeScale(-1, 1);
    
    _wrapperView = [[TGCameraPhotoPreviewWrapperView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:_wrapperView];
    
    __weak TGCameraPhotoPreviewController *weakSelf = self;
    
    void (^cancelPressed)(void) = ^
    {
        __strong TGCameraPhotoPreviewController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        if (strongSelf.retakePressed != nil)
            strongSelf.retakePressed();
        
        [strongSelf transitionOutWithCompletion:^
        {
            [strongSelf dismiss];
        }];
    };
    
    void (^donePressed)(void) = ^
    {
        __strong TGCameraPhotoPreviewController *strongSelf = weakSelf;
        if (strongSelf == nil || strongSelf->_dismissing)
            return;
        
        strongSelf->_dismissing = true;
        strongSelf.view.userInteractionEnabled = false;
        
        if (strongSelf->_editorValues != nil)
        {
            strongSelf.sendPressed(strongSelf->_image, strongSelf->_editedImage, strongSelf->_editorValues, strongSelf->_caption);
        }
        else
        {
            [[ATQueue concurrentDefaultQueue] dispatch:^
            {
                UIImage *image = TGPhotoEditorCrop(strongSelf->_image, UIImageOrientationUp, 0, CGRectMake(0, 0, strongSelf->_image.size.width, strongSelf->_image.size.height), CGSizeMake(1280, 1280), strongSelf->_image.size);
                
                strongSelf.sendPressed(strongSelf->_image, image, nil, strongSelf->_caption);
            }];
        }
    };
    
    void (^tabPressed)(TGPhotoEditorTab) = ^(TGPhotoEditorTab tab)
    {
        __strong TGCameraPhotoPreviewController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        [strongSelf presentPhotoEditorWithTab:tab];
    };
    
    NSMutableArray *tabs = [[NSMutableArray alloc] init];
    if (!self.disallowCaptions)
        [tabs addObject:@(TGPhotoEditorCaptionTab)];
    
    [tabs addObject:@(TGPhotoEditorCropTab)];
    
    if (iosMajorVersion() >= 7)
        [tabs addObject:@(TGPhotoEditorToolsTab)];
    
    _availableTabs = tabs;
    
    _portraitToolbarView = [[TGPhotoToolbarView alloc] initWithBackButtonTitle:TGLocalized(@"Camera.Retake") doneButtonTitle:TGLocalized(@"MediaPicker.Send") accentedDone:false solidBackground:false tabs:tabs];
    _portraitToolbarView.cancelPressed = cancelPressed;
    _portraitToolbarView.donePressed = donePressed;
    _portraitToolbarView.tabPressed = tabPressed;
    [_wrapperView addSubview:_portraitToolbarView];
    
    _landscapeToolbarView = [[TGPhotoToolbarView alloc] initWithBackButtonTitle:TGLocalized(@"Camera.Retake") doneButtonTitle:TGLocalized(@"MediaPicker.Send") accentedDone:false solidBackground:false tabs:tabs];
    _landscapeToolbarView.cancelPressed = cancelPressed;
    _landscapeToolbarView.donePressed = donePressed;
    _landscapeToolbarView.tabPressed = tabPressed;
    [_wrapperView addSubview:_landscapeToolbarView];
}

- (UIBarStyle)requiredNavigationBarStyle
{
    return UIBarStyleDefault;
}

- (bool)navigationBarShouldBeHidden
{
    return true;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self transitionIn];
}

#pragma mark - Transition

- (void)transitionIn
{
    _transitionInProgress = true;
    
    _portraitToolbarView.alpha = 0.0f;
    _landscapeToolbarView.alpha = 0.0f;
    
    [UIView animateWithDuration:0.3f delay:0.1f options:UIViewAnimationOptionCurveLinear animations:^
    {
        _portraitToolbarView.alpha = 1.0f;
        _landscapeToolbarView.alpha = 1.0f;
    } completion:nil];
    
    CGSize referenceSize = [self referenceViewSizeForOrientation:self.interfaceOrientation];
    CGRect referenceFrame = CGRectZero;
    if (self.beginTransitionIn != nil)
        referenceFrame = self.beginTransitionIn();
    
    if (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft)
    {
        referenceFrame = CGRectMake(referenceSize.width - referenceFrame.size.height - referenceFrame.origin.y,
                                    referenceFrame.origin.x,
                                    referenceFrame.size.height, referenceFrame.size.width);
    }
    else if (self.interfaceOrientation == UIInterfaceOrientationLandscapeRight)
    {
        referenceFrame = CGRectMake(referenceFrame.origin.y,
                                    referenceSize.height - referenceFrame.size.width - referenceFrame.origin.x,
                                    referenceFrame.size.height, referenceFrame.size.width);
    }
    
    CGRect containerFrame = CGRectMake(0, 0, referenceSize.width, referenceSize.height);
    CGSize fittedSize = TGScaleToSize(_imageView.image.size, containerFrame.size);
    CGRect targetFrame = CGRectMake(containerFrame.origin.x + (containerFrame.size.width - fittedSize.width) / 2,
                                    containerFrame.origin.y + (containerFrame.size.height - fittedSize.height) / 2,
                                    fittedSize.width,
                                    fittedSize.height);
    
    CGFloat referenceAspectRatio = referenceFrame.size.width / referenceFrame.size.height;
    CGFloat targetAspectRatio = targetFrame.size.width / targetFrame.size.height;
    
    if (ABS(targetAspectRatio - referenceAspectRatio) > 0.03f)
    {
        CGSize newSize = CGSizeZero;
        if (referenceFrame.size.width > referenceFrame.size.height)
            newSize = CGSizeMake(referenceFrame.size.width, _imageView.image.size.height * referenceFrame.size.width / _imageView.image.size.width);
        else
            newSize = CGSizeMake(_imageView.image.size.width * referenceFrame.size.height / _imageView.image.size.height, referenceFrame.size.height);
        
        referenceFrame = CGRectMake(CGRectGetMidX(referenceFrame) - newSize.width / 2,
                                    CGRectGetMidY(referenceFrame) - newSize.height / 2,
                                    newSize.width, newSize.height);
    }
    
    _imageView.frame = referenceFrame;
    
    POPSpringAnimation *animation = [TGPhotoEditorAnimation prepareTransitionAnimationForPropertyNamed:kPOPViewFrame];
    animation.fromValue = [NSValue valueWithCGRect:referenceFrame];
    animation.toValue = [NSValue valueWithCGRect:targetFrame];
    animation.completionBlock = ^(__unused POPAnimation *animation, __unused BOOL finished)
    {
        _transitionInProgress = false;
        [_scrollView addSubview:_imageView];
        _imageView.frame = CGRectMake(0, 0, _scrollView.frame.size.width, _scrollView.frame.size.height);
        self.view.backgroundColor = [UIColor blackColor];
        
        [self reset];
    };

    if (_metadata.frontal)
    {
        [UIView transitionWithView:_imageView duration:0.3f options:UIViewAnimationOptionTransitionFlipFromLeft | UIViewAnimationOptionCurveEaseOut animations:^
        {
            _imageView.transform = CGAffineTransformIdentity;
        } completion:nil];
    }
    
    [_imageView pop_addAnimation:animation forKey:@"frame"];
}

- (void)transitionOutWithCompletion:(void (^)(void))completion
{
    _transitionInProgress = true;
    
    self.view.backgroundColor = [UIColor clearColor];
    
    CGRect frame = [self.view convertRect:_imageView.frame fromView:_scrollView];
    [self.view addSubview:_imageView];
    _imageView.frame = frame;
    
    CGSize referenceSize = [self referenceViewSizeForOrientation:self.interfaceOrientation];
    CGRect referenceFrame = _imageView.frame;
    
    if (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft)
    {
        referenceFrame = CGRectMake(referenceSize.height - referenceFrame.size.height - referenceFrame.origin.y,
                                    referenceFrame.origin.x,
                                    referenceFrame.size.height, referenceFrame.size.width);
    }
    else if (self.interfaceOrientation == UIInterfaceOrientationLandscapeRight)
    {
        referenceFrame = CGRectMake(referenceFrame.origin.y,
                                    referenceSize.width - referenceFrame.size.width - referenceFrame.origin.x,
                                    referenceFrame.size.height, referenceFrame.size.width);
    }
    
    CGRect targetFrame = CGRectZero;
    if (self.beginTransitionOut != nil)
        targetFrame = self.beginTransitionOut(referenceFrame);
    
    if (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft)
    {
        targetFrame = CGRectMake(referenceSize.width - targetFrame.size.height - targetFrame.origin.y,
                                targetFrame.origin.x,
                                targetFrame.size.height, targetFrame.size.width);
    }
    else if (self.interfaceOrientation == UIInterfaceOrientationLandscapeRight)
    {
        targetFrame = CGRectMake(targetFrame.origin.y,
                                 referenceSize.height - targetFrame.size.width - targetFrame.origin.x,
                                 targetFrame.size.height, targetFrame.size.width);
    }
    
    CGFloat referenceAspectRatio = referenceFrame.size.width / referenceFrame.size.height;
    CGFloat targetAspectRatio = targetFrame.size.width / targetFrame.size.height;
        
    if (ABS(targetAspectRatio - referenceAspectRatio) > 0.03f)
    {
        CGSize newSize = CGSizeZero;
        if (targetFrame.size.width > targetFrame.size.height)
            newSize = CGSizeMake(targetFrame.size.width, _imageView.image.size.height * targetFrame.size.width / _imageView.image.size.width);
        else
            newSize = CGSizeMake(_imageView.image.size.width * targetFrame.size.height / _imageView.image.size.height, targetFrame.size.height);
        
        targetFrame = CGRectMake(CGRectGetMidX(targetFrame) - newSize.width / 2,
                                 CGRectGetMidY(targetFrame) - newSize.height / 2,
                                 newSize.width, newSize.height);
    }
    
    POPSpringAnimation *animation = [TGPhotoEditorAnimation prepareTransitionAnimationForPropertyNamed:kPOPViewFrame];
    animation.fromValue = [NSValue valueWithCGRect:_imageView.frame];
    animation.toValue = [NSValue valueWithCGRect:targetFrame];
    [_imageView pop_addAnimation:animation forKey:@"frame"];
    
    [UIView animateWithDuration:0.3f animations:^
    {
        _imageView.alpha = 0.0f;
        _portraitToolbarView.alpha = 0.0f;
        _landscapeToolbarView.alpha = 0.0f;
    } completion:^(__unused BOOL finished)
    {
        if (completion != nil)
            completion();
    }];
}

#pragma mark - Scroll View

- (void)scrollViewDidZoom:(UIScrollView *)__unused scrollView
{
    [self adjustZoom];
}

- (void)scrollViewDidEndZooming:(UIScrollView *)__unused scrollView withView:(UIView *)__unused view atScale:(CGFloat)__unused scale
{
    [self adjustZoom];
    
    if (_scrollView.zoomScale < _scrollView.normalZoomScale - FLT_EPSILON)
    {
        [TGHacks setAnimationDurationFactor:0.5f];
        [_scrollView setZoomScale:_scrollView.normalZoomScale animated:true];
        [TGHacks setAnimationDurationFactor:1.0f];
    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    if (_imageView.superview == scrollView)
        return _imageView;
    
    return nil;
}

- (CGSize)contentSize
{
    if (_editorValues != nil)
        return _editedImage.size;
    
    return _image.size;
}

- (void)reset
{
    CGSize contentSize = [self contentSize];
    
    _scrollView.minimumZoomScale = 1.0f;
    _scrollView.maximumZoomScale = 1.0f;
    _scrollView.normalZoomScale = 1.0f;
    _scrollView.zoomScale = 1.0f;
    _scrollView.contentSize = contentSize;
    _imageView.frame = CGRectMake(0.0f, 0.0f, contentSize.width, contentSize.height);
    
    [self adjustZoom];
    _scrollView.zoomScale = _scrollView.normalZoomScale;
}

- (void)adjustZoom
{
    CGSize contentSize = [self contentSize];
    CGSize boundsSize = _scrollView.frame.size;
    if (contentSize.width < FLT_EPSILON || contentSize.height < FLT_EPSILON || boundsSize.width < FLT_EPSILON || boundsSize.height < FLT_EPSILON)
        return;
    
    CGFloat scaleWidth = boundsSize.width / contentSize.width;
    CGFloat scaleHeight = boundsSize.height / contentSize.height;
    CGFloat minScale = MIN(scaleWidth, scaleHeight);
    CGFloat maxScale = MAX(scaleWidth, scaleHeight);
    maxScale = MAX(maxScale, minScale * 3.0f);
    
    if (ABS(maxScale - minScale) < 0.01f)
        maxScale = minScale;
    
    if (_scrollView.minimumZoomScale != 0.05f)
        _scrollView.minimumZoomScale = 0.05f;
    if (_scrollView.normalZoomScale != minScale)
        _scrollView.normalZoomScale = minScale;
    if (_scrollView.maximumZoomScale != maxScale)
        _scrollView.maximumZoomScale = maxScale;
    
    CGRect contentFrame = _imageView.frame;
    
    if (boundsSize.width > contentFrame.size.width)
        contentFrame.origin.x = (boundsSize.width - contentFrame.size.width) / 2.0f;
    else
        contentFrame.origin.x = 0;
    
    if (boundsSize.height > contentFrame.size.height)
        contentFrame.origin.y = (boundsSize.height - contentFrame.size.height) / 2.0f;
    else
        contentFrame.origin.y = 0;
    
    _imageView.frame = contentFrame;
}

#pragma mark -

- (void)updateEditorButtonsForEditorValues:(PGPhotoEditorValues *)editorValues hasCaption:(bool)hasCaption
{
    NSInteger highlightedButtons = [TGPhotoEditorTabController highlightedButtonsForEditorValues:editorValues forAvatar:false hasCaption:hasCaption];
    [_portraitToolbarView setEditButtonsHighlighted:highlightedButtons];
    [_landscapeToolbarView setEditButtonsHighlighted:highlightedButtons];
}

- (void)presentPhotoEditorWithTab:(TGPhotoEditorTab)tab
{
    __weak TGCameraPhotoPreviewController *weakSelf = self;
    
    id<TGEditablePhotoItem> editableMediaItem = _image;
    
    UIView *referenceView = _imageView;
    CGRect refFrame = [self.view convertRect:_imageView.frame fromView:_scrollView];
    UIImage *screenImage = [(UIImageView *)referenceView image];
    
    TGPhotoEditorController *controller = [[TGPhotoEditorController alloc] initWithItem:editableMediaItem intent:TGPhotoEditorControllerFromCameraIntent adjustments:_editorValues caption:_caption screenImage:screenImage availableTabs:_availableTabs selectedTab:tab];
    self.editorController = controller;
    controller.metadata = _metadata;
    controller.userListSignal = self.userListSignal;
    controller.hashtagListSignal = self.hashtagListSignal;
    controller.finishedEditing = ^(PGPhotoEditorValues *editorValues, UIImage *resultImage, __unused UIImage *thumbnailImage, bool noChanges)
    {
#ifdef DEBUG
        if (editorValues != nil && !noChanges)
            NSAssert(resultImage != nil, @"resultImage should not be nil");
#endif
        
        __strong TGCameraPhotoPreviewController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        if (!noChanges)
        {
            strongSelf->_editorValues = editorValues;
            strongSelf->_editedImage = resultImage;
        
            if (editorValues != nil)
                strongSelf->_imageView.image = strongSelf->_editedImage;
            else
                strongSelf->_imageView.image = strongSelf->_image;
        }
        
        PGPhotoEditorValues *values = noChanges ? strongSelf->_editorValues : editorValues;
        [strongSelf updateEditorButtonsForEditorValues:values hasCaption:strongSelf->_caption.length > 0];
        
        [strongSelf reset];
    };
    
    controller.captionSet = ^(NSString *caption)
    {
        __strong TGCameraPhotoPreviewController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        [strongSelf reset];
        
        strongSelf->_caption = caption;
    };
    
    controller.requestToolbarsHidden = ^(bool hidden, bool animated)
    {
        __strong TGCameraPhotoPreviewController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        [strongSelf setToolbarsHidden:hidden animated:animated];
    };
    
    controller.beginTransitionIn = ^UIView *(CGRect *referenceFrame, UIView **parentView)
    {
        __strong TGCameraPhotoPreviewController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return nil;
        
        if (strongSelf.photoEditorShown != nil)
            strongSelf.photoEditorShown();
        
        strongSelf->_imageView.hidden = true;

        *parentView = strongSelf->_transitionParentView;
        *referenceFrame = refFrame;
        
        [strongSelf reset];
        
        return referenceView;
    };
    
    controller.beginTransitionOut = ^UIView *(CGRect *referenceFrame, UIView **parentView)
    {
        __strong TGCameraPhotoPreviewController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return nil;
        
        *parentView = strongSelf->_transitionParentView;
        *referenceFrame = [strongSelf.view convertRect:strongSelf->_imageView.frame fromView:strongSelf->_scrollView];
        
        return strongSelf->_imageView;
    };
    
    controller.finishedTransitionOut = ^(__unused bool saved)
    {
        __strong TGCameraPhotoPreviewController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        if (strongSelf.photoEditorHidden != nil)
            strongSelf.photoEditorHidden();
        
        strongSelf->_imageView.hidden = false;
    };
    
    TGOverlayControllerWindow *controllerWindow = [[TGOverlayControllerWindow alloc] initWithParentController:self contentController:controller];
    controllerWindow.windowLevel = self.view.window.windowLevel + 0.0001f;
    controllerWindow.hidden = false;
    controller.view.clipsToBounds = true;
}

- (void)setToolbarsHidden:(bool)hidden animated:(bool)animated
{
    if (hidden)
    {
        [_portraitToolbarView transitionOutAnimated:animated transparent:true hideOnCompletion:false];
        [_landscapeToolbarView transitionOutAnimated:animated transparent:true hideOnCompletion:false];
    }
    else
    {
        [_portraitToolbarView transitionInAnimated:animated transparent:true];
        [_landscapeToolbarView transitionInAnimated:animated transparent:true];
    }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    [_imageView pop_removeAllAnimations];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    [self updateLayout:[UIApplication sharedApplication].statusBarOrientation];
}

- (void)updateLayout:(UIInterfaceOrientation)orientation
{
    CGSize referenceSize = [self referenceViewSizeForOrientation:orientation];
    
    CGFloat screenSide = MAX(referenceSize.width, referenceSize.height);
    _wrapperView.frame = CGRectMake((referenceSize.width - screenSide) / 2, (referenceSize.height - screenSide) / 2, screenSide, screenSide);
    
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
    
    if (_transitionInProgress)
        return;

    if (!CGRectEqualToRect(_scrollView.frame, self.view.bounds))
    {
        _scrollView.frame = self.view.bounds;
        [self reset];
    }
//    CGRect containerFrame = CGRectMake(0, 0, referenceSize.width, referenceSize.height);
//    CGSize fittedSize = TGScaleToSize(_imageView.image.size, containerFrame.size);
//    _scrollView.frame = CGRectMake(containerFrame.origin.x + (containerFrame.size.width - fittedSize.width) / 2,
//                                   containerFrame.origin.y + (containerFrame.size.height - fittedSize.height) / 2,
//                                   fittedSize.width,
//                                   fittedSize.height);
}

@end
