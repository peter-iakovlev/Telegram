#import "TGPhotoToolsController.h"

#import "TGAppDelegate.h"

#import "TGPhotoEditorAnimation.h"
#import "TGPhotoEditorInterfaceAssets.h"
#import "TGPhotoEditorCollectionView.h"
#import "TGPhotoToolCell.h"

#import "TGImageUtils.h"
#import "TGPhotoEditorUtils.h"
#import "UICollectionView+Utils.h"

#import "PGPhotoEditor.h"
#import "PGPhotoTool.h"

#import "TGOverlayControllerWindow.h"
#import "TGPhotoEditorController.h"
#import "TGPhotoEditorItemController.h"
#import "TGPhotoEditorPreviewView.h"

@interface TGPhotoToolsController () <TGPhotoEditorCollectionViewToolsDataSource>
{
    NSArray *_tools;
    
    UIView *_wrapperView;
    UIView *_portraitToolsWrapperView;
    UIView *_landscapeToolsWrapperView;
    TGPhotoEditorCollectionView *_portraitCollectionView;
    TGPhotoEditorCollectionView *_landscapeCollectionView;
    
    void(^_interactionEnded)(void);
    
    NSValue *_contentOffsetAfterRotation;
    bool _appeared;
    CGFloat _cellWidth;
}

@property (nonatomic, weak) PGPhotoEditor *photoEditor;
@property (nonatomic, weak) TGPhotoEditorPreviewView *previewView;
@property (nonatomic, weak) TGPhotoEditorItemController *editorItemController;

@end

@implementation TGPhotoToolsController

- (instancetype)initWithPhotoEditor:(PGPhotoEditor *)photoEditor previewView:(TGPhotoEditorPreviewView *)previewView
{
    self = [super init];
    if (self != nil)
    {
        self.photoEditor = photoEditor;
        self.previewView = previewView;
        
        NSMutableArray *tools = [[NSMutableArray alloc] init];
        for (PGPhotoTool *tool in photoEditor.tools)
        {
            if (!tool.isHidden)
                [tools addObject:tool];
        }
        _tools = tools;
    }
    return self;
}

- (void)dealloc
{
    _portraitCollectionView.toolsDataSource = nil;
    _landscapeCollectionView.toolsDataSource = nil;
}

- (void)loadView
{
    [super loadView];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    __weak TGPhotoToolsController *weakSelf = self;
    _interactionEnded = ^
    {
        __strong TGPhotoToolsController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        if ([strongSelf shouldAutorotate])
            [TGViewController attemptAutorotation];
    };
    
    _wrapperView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:_wrapperView];
    
    TGPhotoEditorPreviewView *previewView = _previewView;
    previewView.hidden = true;
    previewView.interactionEnded = _interactionEnded;
    [self.view addSubview:_previewView];
    
    _portraitToolsWrapperView = [[UIView alloc] initWithFrame:CGRectZero];
    _portraitToolsWrapperView.alpha = 0.0f;
    [_wrapperView addSubview:_portraitToolsWrapperView];

    _landscapeToolsWrapperView = [[UIView alloc] initWithFrame:CGRectZero];
    _landscapeToolsWrapperView.alpha = 0.0f;
    [_wrapperView addSubview:_landscapeToolsWrapperView];
    
    CGFloat maxTitleWidth = 0.0f;
    for (PGPhotoTool *tool in _tools)
    {
        NSString *title = tool.title;
        CGFloat width = 0.0f;
        if ([title respondsToSelector:@selector(sizeWithAttributes:)])
            width = CGCeil([title sizeWithAttributes:@{ NSFontAttributeName:[TGPhotoEditorInterfaceAssets editorItemTitleFont] }].width);
        else
            width = CGCeil([title sizeWithFont:[TGPhotoEditorInterfaceAssets editorItemTitleFont]].width);
        
        if (width > maxTitleWidth)
            maxTitleWidth = width;
    }
    maxTitleWidth = MAX(64, maxTitleWidth);
    
    CGSize referenceSize = [self referenceViewSize];
    CGFloat collectionViewSize = MIN(referenceSize.width, referenceSize.height);
    _portraitCollectionView = [[TGPhotoEditorCollectionView alloc] initWithOrientation:UIInterfaceOrientationPortrait cellWidth:maxTitleWidth];
    _portraitCollectionView.backgroundColor = [UIColor clearColor];
    _portraitCollectionView.contentInset = UIEdgeInsetsMake(8, 10, 16, 10);
    _portraitCollectionView.frame = CGRectMake(0, 0, collectionViewSize, TGPhotoEditorPanelSize);
    _portraitCollectionView.toolsDataSource = self;
    _portraitCollectionView.interactionEnded = _interactionEnded;
    [_portraitToolsWrapperView addSubview:_portraitCollectionView];
    
    _landscapeCollectionView = [[TGPhotoEditorCollectionView alloc] initWithOrientation:UIInterfaceOrientationLandscapeLeft cellWidth:maxTitleWidth];
    _landscapeCollectionView.backgroundColor = [UIColor clearColor];
    _landscapeCollectionView.contentInset = UIEdgeInsetsMake(10, 10, 10, 10);
    _landscapeCollectionView.frame = CGRectMake(0, 0, TGPhotoEditorPanelSize, collectionViewSize);
    _landscapeCollectionView.minimumLineSpacing = 12;
    _landscapeCollectionView.toolsDataSource = self;
    _landscapeCollectionView.interactionEnded = _interactionEnded;
    
    if ([UIDevice currentDevice].userInterfaceIdiom != UIUserInterfaceIdiomPad)
        [_landscapeToolsWrapperView addSubview:_landscapeCollectionView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self transitionIn];
}

- (BOOL)shouldAutorotate
{
    TGPhotoEditorItemController *controller = self.editorItemController;
    if (controller != nil)
        return [controller shouldAutorotate];
    
    TGPhotoEditorPreviewView *previewView = self.previewView;
    return (!previewView.isTracking && !_portraitCollectionView.isTracking && !_landscapeCollectionView.isTracking && [super shouldAutorotate]);
}

- (bool)isDismissAllowed
{
    return _appeared;
}

#pragma mark - Transition

- (void)prepareForCombinedAppearance
{
    _wrapperView.hidden = true;
}

- (void)finishedCombinedAppearance
{
    _wrapperView.hidden = false;
}

- (void)transitionIn
{
    [UIView animateWithDuration:0.3f animations:^
    {
        _portraitToolsWrapperView.alpha = 1.0f;
        _landscapeToolsWrapperView.alpha = 1.0f;
    }];
}

- (void)transitionOutSwitching:(bool)__unused switching completion:(void (^)(void))completion
{
    TGPhotoEditorPreviewView *previewView = self.previewView;
    previewView.interactionEnded = nil;
    
    [UIView animateWithDuration:0.3f animations:^
    {
        _portraitToolsWrapperView.alpha = 0.0f;
        _landscapeToolsWrapperView.alpha = 0.0f;
    } completion:^(__unused BOOL finished)
    {
        if (completion != nil)
            completion();
    }];
}

- (void)_animatePreviewViewTransitionOutToFrame:(CGRect)targetFrame saving:(bool)saving parentView:(UIView *)parentView completion:(void (^)(void))completion
{
    _dismissing = true;
    
    TGPhotoEditorPreviewView *previewView = self.previewView;
    [previewView prepareForTransitionOut];
    
    UIView *snapshotView = nil;
    POPSpringAnimation *snapshotAnimation = nil;
    
    if (saving && CGRectIsNull(targetFrame) && parentView != nil)
    {
        snapshotView = [previewView snapshotViewAfterScreenUpdates:false];
        snapshotView.frame = previewView.frame;
        
        CGSize fittedSize = TGScaleToSize(previewView.frame.size, self.view.frame.size);
        targetFrame = CGRectMake((self.view.frame.size.width - fittedSize.width) / 2,
                                 (self.view.frame.size.height - fittedSize.height) / 2,
                                 fittedSize.width,
                                 fittedSize.height);
        
        [parentView addSubview:snapshotView];
        
        snapshotAnimation = [TGPhotoEditorAnimation prepareTransitionAnimationForPropertyNamed:kPOPViewFrame];
        snapshotAnimation.fromValue = [NSValue valueWithCGRect:snapshotView.frame];
        snapshotAnimation.toValue = [NSValue valueWithCGRect:targetFrame];
    }
    
    POPSpringAnimation *previewAnimation = [TGPhotoEditorAnimation prepareTransitionAnimationForPropertyNamed:kPOPViewFrame];
    previewAnimation.fromValue = [NSValue valueWithCGRect:previewView.frame];
    previewAnimation.toValue = [NSValue valueWithCGRect:targetFrame];
    
    POPSpringAnimation *previewAlphaAnimation = [TGPhotoEditorAnimation prepareTransitionAnimationForPropertyNamed:kPOPViewAlpha];
    previewAlphaAnimation.fromValue = @(previewView.alpha);
    previewAlphaAnimation.toValue = @(0.0f);
    
    NSMutableArray *animations = [NSMutableArray arrayWithArray:@[ previewAnimation, previewAlphaAnimation ]];
    if (snapshotAnimation != nil)
        [animations addObject:snapshotAnimation];
    
    [TGPhotoEditorAnimation performBlock:^(__unused bool allFinished)
    {
        [snapshotView removeFromSuperview];
         
        if (completion != nil)
            completion();
    } whenCompletedAllAnimations:animations];
    
    if (snapshotAnimation != nil)
        [snapshotView pop_addAnimation:snapshotAnimation forKey:@"frame"];
    [previewView pop_addAnimation:previewAnimation forKey:@"frame"];
    [previewView pop_addAnimation:previewAlphaAnimation forKey:@"alpha"];
}

- (void)_finishedTransitionInWithView:(UIView *)transitionView
{
    _appeared = true;
    
    [transitionView removeFromSuperview];
    
    TGPhotoEditorPreviewView *previewView = _previewView;
    previewView.hidden = false;
    [previewView performTransitionInIfNeeded];
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

#pragma mark - Data Source and Delegate

- (NSInteger)numberOfToolsInCollectionView:(TGPhotoEditorCollectionView *)__unused collectionView
{
    return _tools.count;
}

- (PGPhotoTool *)collectionView:(TGPhotoEditorCollectionView *)__unused collectionView toolAtIndex:(NSInteger)index
{
    return _tools[index];
}

- (void)collectionView:(TGPhotoEditorCollectionView *)__unused collectionView didSelectToolWithIndex:(NSInteger)index
{
    if (self.editorItemController != nil)
        return;
    
    PGPhotoTool *selectedTool = _tools[index];
    
    __weak TGPhotoToolsController *weakSelf = self;
    TGPhotoEditorItemController *controller = [[TGPhotoEditorItemController alloc] initWithEditorItem:selectedTool photoEditor:_photoEditor previewView:_previewView];
    controller.toolbarLandscapeSize = self.toolbarLandscapeSize;
    controller.editorItemUpdated = ^
    {
        __strong TGPhotoToolsController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        [strongSelf->_portraitCollectionView reloadData];
        [strongSelf->_landscapeCollectionView reloadData];
    };
    controller.beginTransitionIn = ^
    {
        __strong TGPhotoToolsController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        if (strongSelf.beginItemTransitionIn != nil)
            strongSelf.beginItemTransitionIn();
    };
    controller.beginTransitionOut = ^
    {
        __strong TGPhotoToolsController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        if (strongSelf.beginItemTransitionOut != nil)
            strongSelf.beginItemTransitionOut();
        
        TGPhotoEditorPreviewView *previewView = strongSelf.previewView;
        previewView.interactionEnded = strongSelf->_interactionEnded;
    };
    
    [self.parentViewController addChildViewController:controller];
    [self.parentViewController.view addSubview:controller.view];
    
    CGSize referenceSize = [self referenceViewSize];
    controller.view.frame = CGRectMake(0, 0, referenceSize.width, referenceSize.height);
    
    controller.view.clipsToBounds = true;
    self.editorItemController = controller;
}

- (void)updateValues
{
    [_portraitCollectionView reloadData];
    [_landscapeCollectionView reloadData];
}

#pragma mark - Layout

- (void)_prepareCollectionViewsForTransitionFromOrientation:(UIInterfaceOrientation)fromOrientation toOrientation:(UIInterfaceOrientation)toOrientation
{
    if ((UIInterfaceOrientationIsLandscape(fromOrientation) && UIInterfaceOrientationIsLandscape(toOrientation)) || [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
        return;
    
    UICollectionView *currentCollectionView = nil;
    UICollectionView *targetCollectionView = nil;
    
    if (UIInterfaceOrientationIsPortrait(fromOrientation))
    {
        currentCollectionView = _portraitCollectionView;
        targetCollectionView = _landscapeCollectionView;
    }
    else
    {
        currentCollectionView = _landscapeCollectionView;
        targetCollectionView = _portraitCollectionView;
    }
    
    bool scrollToEnd = false;
    
    if (currentCollectionView == _portraitCollectionView && currentCollectionView.contentOffset.x > currentCollectionView.contentSize.width - currentCollectionView.frame.size.width - 2)
    {
        scrollToEnd = true;
    }
    else if (currentCollectionView == _landscapeCollectionView && currentCollectionView.contentOffset.y > currentCollectionView.contentSize.height - currentCollectionView.frame.size.height - 2)
    {
        scrollToEnd = true;
    }
    
    CGPoint targetOffset = CGPointZero;
    CGFloat collectionViewSize = MIN(TGScreenSize().width, TGScreenSize().height);
    
    if (!scrollToEnd)
    {
        NSIndexPath *firstVisibleIndexPath = nil;
        
        NSArray *visibleLayoutAttributes = [currentCollectionView.collectionViewLayout layoutAttributesForElementsInRect:currentCollectionView.bounds];
        
        CGFloat firstItemPosition = FLT_MAX;
        for (UICollectionViewLayoutAttributes *layoutAttributes in visibleLayoutAttributes)
        {
            CGFloat position = 0;
            
            if (currentCollectionView == _portraitCollectionView)
            {
                 position = CGRectOffset(layoutAttributes.frame, -currentCollectionView.bounds.origin.x, 0).origin.x;
            }
            else
            {
                position = CGRectOffset(layoutAttributes.frame, 0, -currentCollectionView.bounds.origin.y).origin.y;
            }
            
            if (position > 0 && position < firstItemPosition)
            {
                firstItemPosition = position;
                firstVisibleIndexPath = layoutAttributes.indexPath;
            }
        }
        
        if (firstVisibleIndexPath == nil)
            return;
    
        UICollectionViewLayoutAttributes *attributes = [targetCollectionView.collectionViewLayout layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:firstVisibleIndexPath.row inSection:0]];
        
        if (targetCollectionView == _portraitCollectionView)
        {
            targetOffset = CGPointMake(MIN(targetCollectionView.contentSize.width + targetCollectionView.contentInset.right - collectionViewSize, -targetCollectionView.contentInset.left + attributes.frame.origin.x), -targetCollectionView.contentInset.top);
        }
        else
        {
            targetOffset = CGPointMake(-targetCollectionView.contentInset.left,
                                       MIN(targetCollectionView.contentSize.height + targetCollectionView.contentInset.bottom - collectionViewSize, -targetCollectionView.contentInset.top + attributes.frame.origin.y));
        }
    }
    else
    {
        if (targetCollectionView == _portraitCollectionView)
        {
            targetOffset = CGPointMake(targetCollectionView.contentSize.width + targetCollectionView.contentInset.right - collectionViewSize, -targetCollectionView.contentInset.top);
        }
        else
        {
            targetOffset = CGPointMake(-targetCollectionView.contentInset.left, targetCollectionView.contentSize.height + targetCollectionView.contentInset.bottom - collectionViewSize);
        }
    }
    
    _contentOffsetAfterRotation = [NSValue valueWithCGPoint:targetOffset];
}

- (void)_applyPreparedContentOffset
{
    if (_contentOffsetAfterRotation != nil)
    {
        [UIView performWithoutAnimation:^
        {
            if (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation))
            {
                if (_portraitCollectionView.contentSize.width > _portraitCollectionView.frame.size.width)
                    [_portraitCollectionView setContentOffset:_contentOffsetAfterRotation.CGPointValue];
            }
            else
            {
                if (_landscapeCollectionView.contentSize.height > _landscapeCollectionView.frame.size.height)
                    [_landscapeCollectionView setContentOffset:_contentOffsetAfterRotation.CGPointValue];
            }
        }];
        _contentOffsetAfterRotation = nil;
    }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self.view setNeedsLayout];
    
    if (![self inFormSheet])
        [self _prepareCollectionViewsForTransitionFromOrientation:self.interfaceOrientation toOrientation:toInterfaceOrientation];
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    [self updateLayout:[UIApplication sharedApplication].statusBarOrientation];
    
    if (![self inFormSheet])
        [self _applyPreparedContentOffset];
}

- (void)updateLayout:(UIInterfaceOrientation)orientation
{
    if ([self inFormSheet] || [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
    {
        _landscapeToolsWrapperView.hidden = true;
        orientation = UIInterfaceOrientationPortrait;
    }
    
    CGSize referenceSize = [self referenceViewSize];
    
    CGFloat screenSide = MAX(referenceSize.width, referenceSize.height) + 2 * TGPhotoEditorPanelSize;
    _wrapperView.frame = CGRectMake((referenceSize.width - screenSide) / 2, (referenceSize.height - screenSide) / 2, screenSide, screenSide);
    
    CGFloat panelToolbarPortraitSize = TGPhotoEditorPanelSize + TGPhotoEditorToolbarSize;
    CGFloat panelToolbarLandscapeSize = TGPhotoEditorPanelSize + self.toolbarLandscapeSize;
    
    UIEdgeInsets screenEdges = UIEdgeInsetsMake((screenSide - referenceSize.height) / 2, (screenSide - referenceSize.width) / 2, (screenSide + referenceSize.height) / 2, (screenSide + referenceSize.width) / 2);
    
    switch (orientation)
    {
        case UIInterfaceOrientationLandscapeLeft:
        {
            [UIView performWithoutAnimation:^
            {
                _landscapeToolsWrapperView.frame = CGRectMake(0, screenEdges.top, panelToolbarLandscapeSize, _landscapeToolsWrapperView.frame.size.height);
                _landscapeCollectionView.frame = CGRectMake(panelToolbarLandscapeSize - TGPhotoEditorPanelSize, 0, TGPhotoEditorPanelSize, _landscapeCollectionView.frame.size.height);
            }];
            
            _landscapeToolsWrapperView.frame = CGRectMake(screenEdges.left, screenEdges.top, panelToolbarLandscapeSize, referenceSize.height);
            _landscapeCollectionView.frame = CGRectMake(_landscapeCollectionView.frame.origin.x, _landscapeCollectionView.frame.origin.y, _landscapeCollectionView.frame.size.width, _landscapeToolsWrapperView.frame.size.height);
            
            _portraitToolsWrapperView.frame = CGRectMake(screenEdges.left, screenSide - panelToolbarPortraitSize, referenceSize.width, panelToolbarPortraitSize);
            _portraitCollectionView.frame = CGRectMake(0, 0, _portraitToolsWrapperView.frame.size.width, TGPhotoEditorPanelSize);
        }
            break;
            
        case UIInterfaceOrientationLandscapeRight:
        {
            [UIView performWithoutAnimation:^
            {
                _landscapeToolsWrapperView.frame = CGRectMake(screenSide - panelToolbarLandscapeSize, screenEdges.top, panelToolbarLandscapeSize, _landscapeToolsWrapperView.frame.size.height);
                _landscapeCollectionView.frame = CGRectMake(0, 0, TGPhotoEditorPanelSize, _landscapeCollectionView.frame.size.height);
            }];
            
            _landscapeToolsWrapperView.frame = CGRectMake(screenEdges.right - panelToolbarLandscapeSize, screenEdges.top, panelToolbarLandscapeSize, referenceSize.height);
            _landscapeCollectionView.frame = CGRectMake(_landscapeCollectionView.frame.origin.x, _landscapeCollectionView.frame.origin.y, _landscapeCollectionView.frame.size.width, _landscapeToolsWrapperView.frame.size.height);
            
            _portraitToolsWrapperView.frame = CGRectMake(screenEdges.top, screenSide - panelToolbarPortraitSize, referenceSize.width, panelToolbarPortraitSize);
            _portraitCollectionView.frame = CGRectMake(0, 0, _portraitToolsWrapperView.frame.size.width, TGPhotoEditorPanelSize);
        }
            break;
            
        default:
        {
            CGFloat x = _landscapeToolsWrapperView.frame.origin.x;
            if (x < screenSide / 2)
                x = 0;
            else
                x = screenSide - TGPhotoEditorPanelSize;
            _landscapeToolsWrapperView.frame = CGRectMake(x, screenEdges.top, panelToolbarLandscapeSize, referenceSize.height);
            _landscapeCollectionView.frame = CGRectMake(_landscapeCollectionView.frame.origin.x, _landscapeCollectionView.frame.origin.y, TGPhotoEditorPanelSize, _landscapeToolsWrapperView.frame.size.height);
            
            _portraitToolsWrapperView.frame = CGRectMake(screenEdges.left, screenEdges.bottom - panelToolbarPortraitSize, referenceSize.width, panelToolbarPortraitSize);
            _portraitCollectionView.frame = CGRectMake(0, 0, _portraitToolsWrapperView.frame.size.width, TGPhotoEditorPanelSize);
        }
            break;
    }
    
    [_portraitCollectionView.collectionViewLayout invalidateLayout];
    [_landscapeCollectionView.collectionViewLayout invalidateLayout];
    
    PGPhotoEditor *photoEditor = self.photoEditor;
    TGPhotoEditorPreviewView *previewView = self.previewView;
    
    if (_dismissing || previewView.superview != self.view)
        return;
    
    CGRect containerFrame = [TGPhotoEditorTabController photoContainerFrameForParentViewFrame:CGRectMake(0, 0, referenceSize.width, referenceSize.height) toolbarLandscapeSize:self.toolbarLandscapeSize orientation:orientation includePanel:false];
    CGSize fittedSize = TGScaleToSize(photoEditor.rotatedCropSize, containerFrame.size);
    previewView.frame = CGRectMake(containerFrame.origin.x + (containerFrame.size.width - fittedSize.width) / 2,
                                   containerFrame.origin.y + (containerFrame.size.height - fittedSize.height) / 2,
                                   fittedSize.width,
                                   fittedSize.height);
}

@end
