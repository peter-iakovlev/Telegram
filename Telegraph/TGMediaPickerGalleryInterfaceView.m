#import "TGMediaPickerGalleryInterfaceView.h"

#import "pop/POP.h"
#import <SSignalKit/SSignalKit.h>

#import "TGAppDelegate.h"
#import "TGHacks.h"
#import "TGFont.h"
#import "TGImageUtils.h"
#import "TGPhotoEditorUtils.h"
#import "TGObserverProxy.h"

#import "TGModernButton.h"

#import "TGMediaPickerItem.h"
#import "TGModernGalleryEditableItem.h"
#import "TGMediaPickerGallerySelectedItemsModel.h"

#import "TGMediaPickerGalleryPhotoItemView.h"
#import "TGMediaPickerGalleryVideoItemView.h"

#import "TGEditablePhotoItem.h"

#import "TGMessageImageViewOverlayView.h"
#import "TGAssetImageView.h"

#import "TGPhotoEditorTabController.h"
#import "TGPhotoToolbarView.h"
#import "TGPhotoEditorButton.h"
#import "TGMediaPickerGalleryCheckButton.h"
#import "TGMediaPickerPhotoCounterButton.h"
#import "TGMediaPickerPhotoStripView.h"

@interface TGMediaPickerGalleryInterfaceView ()
{
    id<TGModernGalleryItem> _currentItem;
    
    NSMutableArray *_itemHeaderViews;
    NSMutableArray *_itemFooterViews;
    
    void (^_closePressed)();
    
    UIView *_wrapperView;
    UIView *_progressWrapperView;
    UIView *_headerWrapperView;
    TGPhotoToolbarView *_portraitToolbarView;
    TGPhotoToolbarView *_landscapeToolbarView;
    
    TGMediaPickerGalleryCheckButton *_checkButton;
    TGMediaPickerPhotoCounterButton *_photoCounterButton;
    TGMediaPickerPhotoCounterButton *_progressCounterButton;
    
    TGMediaPickerPhotoStripView *_selectedPhotosView;
    
    SMetaDisposable *_currentItemViewAvailabilityDisposable;
    
    UIView *_progressContainer;
    TGModernButton *_progressButton;
    TGMessageImageViewOverlayView *_progressView;
    
    __weak TGModernGalleryItemView *_currentItemView;
}
@end

@implementation TGMediaPickerGalleryInterfaceView

- (instancetype)initWithFocusItem:(id<TGModernGalleryItem>)focusItem allowsSelection:(bool)allowsSelection availableTabs:(NSArray *)availableTabs
{
    self = [super initWithFrame:CGRectZero];
    if (self != nil)
    {
        _hasSwipeGesture = true;
        
        _itemHeaderViews = [[NSMutableArray alloc] init];
        _itemFooterViews = [[NSMutableArray alloc] init];
        
        _wrapperView = [[UIView alloc] initWithFrame:CGRectZero];
        [self addSubview:_wrapperView];
        
        _headerWrapperView = [[UIView alloc] init];
        [_wrapperView addSubview:_headerWrapperView];
        
        __weak TGMediaPickerGalleryInterfaceView *weakSelf = self;
        void(^toolbarCancelPressed)(void) = ^
        {
            __strong TGMediaPickerGalleryInterfaceView *strongSelf = weakSelf;
            if (strongSelf == nil)
                return;
            
            strongSelf->_closePressed();
        };
        void(^toolbarDonePressed)(void) = ^
        {
            __strong TGMediaPickerGalleryInterfaceView *strongSelf = weakSelf;
            if (strongSelf == nil)
                return;
            
            strongSelf->_donePressed(strongSelf->_currentItem);
        };
        
        _portraitToolbarView = [[TGPhotoToolbarView alloc] initWithBackButtonTitle:TGLocalized(@"Common.Back") doneButtonTitle:TGLocalized(@"MediaPicker.Send") accentedDone:false solidBackground:false tabs:availableTabs];
        _portraitToolbarView.cancelPressed = toolbarCancelPressed;
        _portraitToolbarView.donePressed = toolbarDonePressed;
        [_wrapperView addSubview:_portraitToolbarView];

        _landscapeToolbarView = [[TGPhotoToolbarView alloc] initWithBackButtonTitle:TGLocalized(@"Common.Back") doneButtonTitle:TGLocalized(@"MediaPicker.Send") accentedDone:false solidBackground:false tabs:availableTabs];
        _landscapeToolbarView.cancelPressed = toolbarCancelPressed;
        _landscapeToolbarView.donePressed = toolbarDonePressed;
        [_wrapperView addSubview:_landscapeToolbarView];
        
        [_landscapeToolbarView calculateLandscapeSizeForPossibleButtonTitles:@[ TGLocalized(@"Common.Back"), TGLocalized(@"Common.Cancel"), TGLocalized(@"Common.Done"), TGLocalized(@"MediaPicker.Send") ]];
        
        if (allowsSelection)
        {
            _checkButton = [[TGMediaPickerGalleryCheckButton alloc] initWithFrame:CGRectMake(self.frame.size.width - 56, 7, 49, 49)];
            [_checkButton setChecked:false animated:false];
            [_checkButton addTarget:self action:@selector(checkButtonPressed) forControlEvents:UIControlEventTouchUpInside];
            [_wrapperView addSubview:_checkButton];
        
            _selectedPhotosView = [[TGMediaPickerPhotoStripView alloc] initWithFrame:CGRectZero];
            _selectedPhotosView.hidden = true;
            _selectedPhotosView.itemSelected = ^(NSInteger index)
            {
                __strong TGMediaPickerGalleryInterfaceView *strongSelf = weakSelf;
                if (strongSelf == nil)
                    return;
                
                if (strongSelf.photoStripItemSelected != nil)
                    strongSelf.photoStripItemSelected(index);
            };
            [_wrapperView addSubview:_selectedPhotosView];
        
            _photoCounterButton = [[TGMediaPickerPhotoCounterButton alloc] initWithFrame:CGRectMake(0, 0, 64, 38)];
            [_photoCounterButton addTarget:self action:@selector(photoCounterButtonPressed) forControlEvents:UIControlEventTouchUpInside];
            _photoCounterButton.userInteractionEnabled = false;
            [_wrapperView addSubview:_photoCounterButton];
        }
        
        [self updateEditorButtonsForItem:focusItem animated:false];
        
        _progressContainer = [[UIView alloc] initWithFrame:self.bounds];
        _progressContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _progressContainer.alpha = 0.0f;
        _progressContainer.backgroundColor = UIColorRGBA(0x000000, 0.7f);
        _progressContainer.userInteractionEnabled = false;
        [self addSubview:_progressContainer];
        
        CGFloat diameter = 50.0f;
        
        _progressButton = [[TGModernButton alloc] initWithFrame:CGRectMake(CGFloor((_progressContainer.frame.size.width - diameter) / 2.0f), CGFloor((_progressContainer.frame.size.height - diameter) / 2.0f), diameter, diameter)];
        _progressButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        _progressButton.exclusiveTouch = true;
        _progressButton.modernHighlight = true;
        [_progressButton addTarget:self action:@selector(progressCancelPressed) forControlEvents:UIControlEventTouchUpInside];
        [_progressContainer addSubview:_progressButton];
        
        static UIImage *highlightImage = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^
        {
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(diameter, diameter), false, 0.0f);
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextSetFillColorWithColor(context, UIColorRGBA(0x000000, 0.4f).CGColor);
            CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, diameter, diameter));
            highlightImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        });
        
        _progressButton.highlightImage = highlightImage;
        
        _progressView = [[TGMessageImageViewOverlayView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, diameter, diameter)];
        _progressView.userInteractionEnabled = false;
        
        [_progressButton addSubview:_progressView];
        
        _progressWrapperView = [[UIView alloc] initWithFrame:CGRectZero];
        _progressWrapperView.userInteractionEnabled = false;
        [self addSubview:_progressWrapperView];
        
        _progressCounterButton = [[TGMediaPickerPhotoCounterButton alloc] initWithFrame:CGRectMake(0, 0, 64, 38)];
        _progressCounterButton.hidden = true;
        _progressCounterButton.userInteractionEnabled = false;
        [_progressWrapperView addSubview:_progressCounterButton];
    }
    return self;
}

- (void)setClosePressed:(void (^)())closePressed
{
    _closePressed = [closePressed copy];
}

- (void)setEditorTabPressed:(void (^)(TGPhotoEditorTab tab))editorTabPressed
{
    __weak TGMediaPickerGalleryInterfaceView *weakSelf = self;
    void (^tabPressed)(TGPhotoEditorTab) = ^(TGPhotoEditorTab tab)
    {
        __strong TGMediaPickerGalleryInterfaceView *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        if (tab == TGPhotoEditorRotateTab)
            [strongSelf rotateVideo];
        else
            editorTabPressed(tab);
    };
    _portraitToolbarView.tabPressed = tabPressed;
    _landscapeToolbarView.tabPressed = tabPressed;
}

- (void)setSelectedItemsModel:(TGMediaPickerGallerySelectedItemsModel *)selectedItemsModel
{
    _selectedPhotosView.selectedItemsModel = selectedItemsModel;
    [_selectedPhotosView reloadData];
    
    if (selectedItemsModel != nil)
        _photoCounterButton.userInteractionEnabled = true;
}

- (void)setUsesSimpleLayout:(bool)usesSimpleLayout
{
    _usesSimpleLayout = usesSimpleLayout;
    _landscapeToolbarView.hidden = usesSimpleLayout;
}

- (void)itemFocused:(id<TGModernGalleryItem>)item itemView:(TGModernGalleryItemView *)itemView
{
    _currentItem = item;
    _currentItemView = itemView;
    
    CGFloat screenSide = MAX(TGScreenSize().width, TGScreenSize().height);
    UIEdgeInsets screenEdges = UIEdgeInsetsMake((screenSide - self.frame.size.height) / 2, (screenSide - self.frame.size.width) / 2, (screenSide + self.frame.size.height) / 2, (screenSide + self.frame.size.width) / 2);
    
    UIInterfaceOrientation orientation = [self interfaceOrientation];
    
    _checkButton.frame = [self _checkButtonFrameForOrientation:orientation screenEdges:screenEdges hasHeaderView:(itemView.headerView != nil)];
    [_checkButton setChecked:_isItemSelected && _isItemSelected(item) animated:false];
    
    [self updateEditorButtonsForItem:item animated:true];
    
    if (_currentItemViewAvailabilityDisposable == nil)
        _currentItemViewAvailabilityDisposable = [[SMetaDisposable alloc] init];

    __weak TGMediaPickerGalleryInterfaceView *weakSelf = self;
    [_currentItemViewAvailabilityDisposable setDisposable:[[itemView contentAvailabilityStateSignal] startWithNext:^(id next)
    {
        __strong TGMediaPickerGalleryInterfaceView *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            bool available = [next boolValue];
            TGDispatchOnMainThread(^
            {
                if (itemView.item == _currentItem)
                {
                    [strongSelf->_portraitToolbarView setEditButtonsEnabled:available animated:true];
                    [strongSelf->_landscapeToolbarView setEditButtonsEnabled:available animated:true];
                }
            });
        }
    } error:nil completed:nil]];
}

- (void)showVideoConversionProgressForItemsCount:(NSInteger)itemsCount
{
    TGMediaPickerGalleryVideoItemView *videoItemView = (TGMediaPickerGalleryVideoItemView *)_currentItemView;
    if ([videoItemView isKindOfClass:[TGMediaPickerGalleryVideoItemView class]])
        [videoItemView setPlayButtonHidden:true animated:true];
    
    _progressContainer.userInteractionEnabled = true;
    
    [_progressView setProgress:0.005f cancelEnabled:false animated:false];
    [UIView animateWithDuration:0.2 delay:0.0 options:[TGViewController preferredAnimationCurve] << 16 animations:^
    {
        _progressContainer.alpha = 1.0f;
    } completion:nil];

    [_photoCounterButton setSelected:false animated:true];
    [_selectedPhotosView setHidden:true animated:true];
    
    if (itemsCount > 1)
    {
        _photoCounterButton.hidden = true;
        _progressCounterButton.hidden = false;
        _progressCounterButton.internalHidden = false;
        [_progressCounterButton setSelectedCount:itemsCount animated:false];
        [self updateVideoConversionActiveItemNumber:1];
    }
}

- (void)updateVideoConversionActiveItemNumber:(NSInteger)itemNumber
{
    if (!_progressCounterButton.hidden)
        [_progressCounterButton setActiveNumber:itemNumber animated:true];
}

- (void)updateVideoConversionProgress:(CGFloat)progress cancelEnabled:(bool)cancelEnabled
{
    [_progressView setProgress:progress cancelEnabled:cancelEnabled animated:true];
}

- (void)progressCancelPressed
{
    if (self.videoConversionCancelled != nil)
        self.videoConversionCancelled();
    
    _progressContainer.userInteractionEnabled = false;
    
    [UIView animateWithDuration:0.3 delay:0.0 options:[TGViewController preferredAnimationCurve] << 16 animations:^
    {
        _progressContainer.alpha = 0.0f;
    } completion:^(__unused BOOL finished)
    {
        [_progressView setProgress:0.0f cancelEnabled:false animated:false];
        
        TGMediaPickerGalleryVideoItemView *videoItemView = (TGMediaPickerGalleryVideoItemView *)_currentItemView;
        if ([videoItemView isKindOfClass:[TGMediaPickerGalleryVideoItemView class]])
            [videoItemView setPlayButtonHidden:false animated:true];
    }];
    
    if (!_progressCounterButton.hidden)
    {
        [_progressCounterButton cancelledProcessingAnimated:true completion:^{
            _progressCounterButton.hidden = true;
            _photoCounterButton.hidden = false;
        }];
    }
}

- (void)checkButtonPressed
{
    if (_currentItem != nil)
    {
        bool animated = false;
        if (!_selectedPhotosView.isAnimating)
        {
            if (_itemSelected != nil)
                _itemSelected(_currentItem);
        
            animated = true;
        }

        [_checkButton setChecked:_isItemSelected && _isItemSelected(_currentItem) animated:animated];
    }
}

- (void)photoCounterButtonPressed
{
    [_photoCounterButton setSelected:!_photoCounterButton.selected animated:true];
    [_selectedPhotosView setHidden:!_photoCounterButton.selected animated:true];
}

- (void)updateEditorButtonsForItem:(id<TGModernGalleryItem>)item animated:(bool)animated
{
    if (!self.allowsEditing)
    {
        [_portraitToolbarView setEditButtonsHidden:true animated:false];
        [_landscapeToolbarView setEditButtonsHidden:true animated:false];
        return;
    }
    
    bool editButtonsHidden = ![item conformsToProtocol:@protocol(TGModernGalleryEditableItem)];
    [_portraitToolbarView setEditButtonsHidden:editButtonsHidden animated:animated];
    [_landscapeToolbarView setEditButtonsHidden:editButtonsHidden animated:animated];
    
    if (!editButtonsHidden)
    {
        id<TGEditablePhotoItem> editableMediaItem = [(id<TGModernGalleryEditableItem>)item editableMediaItem];
        id<TGMediaEditAdjustments> adjustments = nil;
        if (editableMediaItem.fetchEditorValues != nil)
            adjustments = editableMediaItem.fetchEditorValues(editableMediaItem);
        
        NSString *caption = nil;
        if ([item conformsToProtocol:@protocol(TGModernGalleryEditableItem)])
        {
            if ([item respondsToSelector:@selector(editableMediaItem)])
            {
                id<TGEditablePhotoItem> editableMediaItem = [(id<TGModernGalleryEditableItem>)item editableMediaItem];
                if (editableMediaItem.fetchCaption != nil)
                    caption = editableMediaItem.fetchCaption(editableMediaItem);
            }
        }
        
        [self updateEditorButtonsForAdjustments:adjustments hasCaption:(caption.length > 0)];
    }
}

- (void)updateEditorButtonsForAdjustments:(id<TGMediaEditAdjustments>)adjustments hasCaption:(bool)hasCaption
{
    NSInteger highlightedButtons = [TGPhotoEditorTabController highlightedButtonsForEditorValues:adjustments forAvatar:false hasCaption:hasCaption];
    [_portraitToolbarView setEditButtonsHighlighted:highlightedButtons];
    [_landscapeToolbarView setEditButtonsHighlighted:highlightedButtons];
}

- (void)updateSelectionInterface:(NSUInteger)selectedCount counterVisible:(bool)counterVisible animated:(bool)animated
{
    if (counterVisible)
    {
        bool animateCount = animated && !(counterVisible && _photoCounterButton.internalHidden);
        [_photoCounterButton setSelectedCount:selectedCount animated:animateCount];
        [_photoCounterButton setInternalHidden:false animated:animated completion:nil];
    }
    else
    {
        __weak TGMediaPickerPhotoCounterButton *weakButton = _photoCounterButton;
        [_photoCounterButton setInternalHidden:true animated:animated completion:^
        {
            __strong TGMediaPickerPhotoCounterButton *strongButton = weakButton;
            if (strongButton != nil)
            {
                strongButton.selected = false;
                [strongButton setSelectedCount:selectedCount animated:false];
            }
        }];
        [_selectedPhotosView setHidden:true animated:animated];
    }
    
    [_checkButton setChecked:_isItemSelected && _isItemSelected(_currentItem) animated:true];
}

- (void)updateSelectedPhotosView:(bool)reload incremental:(bool)incremental add:(bool)add index:(NSInteger)index
{
    if (reload)
    {
        if (incremental)
        {
            if (add)
                [_selectedPhotosView insertItemAtIndex:index];
            else
                [_selectedPhotosView deleteItemAtIndex:index];
        }
        else
        {
            [_selectedPhotosView reloadData];
        }
    }
    else
    {
        [_selectedPhotosView updateSelectedItems];
    }
}

- (void)setSelectionInterfaceHidden:(bool)hidden animated:(bool)animated
{
    [self setSelectionInterfaceHidden:hidden delay:0 animated:animated];
}

- (void)setSelectionInterfaceHidden:(bool)hidden delay:(NSTimeInterval)delay animated:(bool)animated
{
    if (animated)
    {
        POPBasicAnimation *opacityAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPViewAlpha];
        opacityAnimation.duration = 0.2f;
        opacityAnimation.fromValue = @(_checkButton.alpha);
        opacityAnimation.beginTime = CACurrentMediaTime() + delay;
        opacityAnimation.completionBlock = ^(__unused POPAnimation *animation, BOOL finished)
        {
            if (finished)
                _checkButton.hidden = hidden;
        };
        
        if (hidden)
        {
            if ([_checkButton.pop_animationKeys containsObject:@"hideOpacity"] || _checkButton.hidden)
                return;
            
            _checkButton.hidden = false;
            
            opacityAnimation.toValue = @(0.0f);
            [_checkButton pop_addAnimation:opacityAnimation forKey:@"hideOpacity"];
        }
        else
        {
            if ([_checkButton.pop_animationKeys containsObject:@"showOpacity"])
                return;
            
            _checkButton.hidden = false;
            
            opacityAnimation.toValue = @(1.0f);
            [_checkButton pop_addAnimation:opacityAnimation forKey:@"showOpacity"];
        }
        
        if (hidden)
        {
            [_photoCounterButton setSelected:false animated:true];
            [_selectedPhotosView setHidden:true animated:true];
        }
        
        [_photoCounterButton setHidden:hidden delay:delay animated:true];
    }
    else
    {
        [_checkButton pop_removeAllAnimations];
        
        _checkButton.hidden = hidden;
        _checkButton.alpha = (hidden ? 0.0f : 1.0f);
        
        if (hidden)
        {
            [_photoCounterButton setSelected:false animated:false];
            [_selectedPhotosView setHidden:true animated:false];
        }
        
        [_photoCounterButton setHidden:hidden animated:false];
    }
}

- (void)setItemHeaderViewHidden:(bool)hidden animated:(bool)animated
{
    if (animated)
    {
        [UIView animateWithDuration:0.2f animations:^
        {
            for (UIView *view in _itemHeaderViews)
                view.alpha = hidden ? 0.0f : 1.0f;
        } completion:^(BOOL finished)
        {
            if (finished)
            {
                for (UIView *view in _itemHeaderViews)
                    view.userInteractionEnabled = !hidden;
            }
        }];
    }
    else
    {
        for (UIView *view in _itemHeaderViews)
        {
            view.alpha = hidden ? 0.0f : 1.0f;
            view.userInteractionEnabled = !hidden;
        }
    }
}

- (void)updateEditedItem:(id<TGModernGalleryEditableItem>)editedItem
{
    TGMediaPickerGallerySelectedItemsModel *selectedItemsModel = _selectedPhotosView.selectedItemsModel;
    __block NSInteger index = NSNotFound;

    [selectedItemsModel.items enumerateObjectsUsingBlock:^(id<TGModernMediaListItem> item, NSUInteger idx, BOOL *stop)
    {
        if ([item conformsToProtocol:@protocol(TGModernMediaListEditableItem)])
        {
            if ([[(id<TGModernMediaListEditableItem>)item uniqueId] isEqualToString:[editedItem uniqueId]])
            {
                index = idx;
                *stop = true;
            }
        }
    }];
    
    if (index != NSNotFound)
        [_selectedPhotosView updateItemAtIndex:index];
    
    [self updateEditorButtonsForItem:editedItem animated:false];
}

- (void)rotateVideo
{
    if (![_currentItem conformsToProtocol:@protocol(TGModernGalleryEditableItem)])
        return;
    
    TGModernGalleryItemView *currentItemView = _currentItemView;
    if ([currentItemView isKindOfClass:[TGMediaPickerGalleryVideoItemView class]])
        [(TGMediaPickerGalleryVideoItemView *)currentItemView rotate];
    
    [self updateEditedItem:(id<TGModernGalleryEditableItem>)_currentItem];
}

- (CGRect)itemFooterViewFrameForSize:(CGSize)size
{
    CGFloat padding = 44.0f;
    
    return CGRectMake(padding, 0.0f, size.width - padding * 2.0f, 44.0f);
}

- (void)addItemHeaderView:(UIView *)itemHeaderView
{
    if (itemHeaderView == nil)
        return;
    
    [_itemHeaderViews addObject:itemHeaderView];
    [_headerWrapperView addSubview:itemHeaderView];
    itemHeaderView.frame = _headerWrapperView.bounds;
}

- (void)removeItemHeaderView:(UIView *)itemHeaderView
{
    if (itemHeaderView == nil)
        return;
    
    [itemHeaderView removeFromSuperview];
    [_itemHeaderViews removeObject:itemHeaderView];
}

- (void)addItemFooterView:(UIView *)itemFooterView
{
    if (itemFooterView == nil)
        return;
    
    [_itemFooterViews addObject:itemFooterView];
    [_portraitToolbarView addSubview:itemFooterView];
    itemFooterView.frame = [self itemFooterViewFrameForSize:self.frame.size];
}

- (void)removeItemFooterView:(UIView *)itemFooterView
{
    if (itemFooterView == nil)
        return;
    
    [itemFooterView removeFromSuperview];
    [_itemFooterViews removeObject:itemFooterView];
}

- (void)addItemLeftAcessoryView:(UIView *)__unused itemLeftAcessoryView
{
    
}

- (void)removeItemLeftAcessoryView:(UIView *)__unused itemLeftAcessoryView
{
    
}

- (void)addItemRightAcessoryView:(UIView *)__unused itemRightAcessoryView
{
    
}

- (void)removeItemRightAcessoryView:(UIView *)__unused itemRightAcessoryView
{
    
}

- (void)animateTransitionInWithDuration:(NSTimeInterval)__unused dutation
{
    
}

- (void)animateTransitionOutWithDuration:(NSTimeInterval)__unused dutation
{
    
}

- (void)setTransitionOutProgress:(CGFloat)transitionOutProgress
{
    if (transitionOutProgress > FLT_EPSILON)
        [self setSelectionInterfaceHidden:true animated:true];
    else
        [self setSelectionInterfaceHidden:false animated:true];
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

#pragma mark -

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *view = [super hitTest:point withEvent:event];
    
    if ([view isDescendantOfView:_headerWrapperView]
        || [view isDescendantOfView:_portraitToolbarView]
        || [view isDescendantOfView:_landscapeToolbarView]
        || [view isDescendantOfView:_selectedPhotosView]
        || [view isDescendantOfView:_progressContainer]
        || view == _photoCounterButton
        || view == _checkButton)
        
    {
        return view;
    }
    
    return nil;
}

- (bool)prefersStatusBarHidden
{
    return true;
}

- (bool)allowsHide
{
    return true;
}

- (bool)showHiddenInterfaceOnScroll
{
    return true;
}

- (bool)allowsDismissalWithSwipeGesture
{
    return self.hasSwipeGesture;
}

- (bool)shouldAutorotate
{
    return true;
}

- (CGRect)_checkButtonFrameForOrientation:(UIInterfaceOrientation)orientation screenEdges:(UIEdgeInsets)screenEdges hasHeaderView:(bool)hasHeaderView
{
    CGRect frame = CGRectZero;
    switch (orientation)
    {
        case UIInterfaceOrientationLandscapeLeft:
            frame = CGRectMake(screenEdges.right - 56, screenEdges.top + 7, 49, 49);
            break;
            
        case UIInterfaceOrientationLandscapeRight:
            frame = CGRectMake(screenEdges.left + 7, screenEdges.top + 7, 49, 49);
            break;
            
        default:
            frame = CGRectMake(screenEdges.right - 56, screenEdges.top + 7, 49, 49);
            break;
    }
    
    if (hasHeaderView)
        frame.origin.y += 64;
    
    return frame;
}

- (void)willRotateWithDuration:(NSTimeInterval)duration
{    
    if (!_selectedPhotosView.hidden)
    {
        UIView *snapshotView = [_selectedPhotosView snapshotViewAfterScreenUpdates:false];
        snapshotView.frame = _selectedPhotosView.frame;
        [_wrapperView insertSubview:snapshotView aboveSubview:_selectedPhotosView];
        
        _selectedPhotosView.alpha = 0.0f;
        
        [UIView animateWithDuration:duration animations:^
        {
            snapshotView.alpha = 0.0f;
            _selectedPhotosView.alpha = 1.0f;
        } completion:^(__unused BOOL finished)
        {
            [snapshotView removeFromSuperview];
        }];
    }
    
    [self setNeedsLayout];
}

- (UIInterfaceOrientation)interfaceOrientation
{
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (self.usesSimpleLayout || [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
        orientation = UIInterfaceOrientationPortrait;
    
    return orientation;
}

- (CGSize)referenceViewSize
{
    return TGAppDelegateInstance.rootController.view.bounds.size;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    bool isPad = [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad;
    
    UIInterfaceOrientation orientation = [self interfaceOrientation];
    CGSize screenSize = TGScreenSize();
    if (isPad)
        screenSize = [self referenceViewSize];
    
    CGFloat screenSide = MAX(screenSize.width, screenSize.height);
    UIEdgeInsets screenEdges = UIEdgeInsetsZero;
    
    if (isPad)
    {
        _landscapeToolbarView.hidden = true;
        screenEdges = UIEdgeInsetsMake(0, 0, self.frame.size.height, self.frame.size.width);
        _wrapperView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    }
    else
    {
        screenEdges = UIEdgeInsetsMake((screenSide - self.frame.size.height) / 2, (screenSide - self.frame.size.width) / 2, (screenSide + self.frame.size.height) / 2, (screenSide + self.frame.size.width) / 2);
        _wrapperView.frame = CGRectMake((self.frame.size.width - screenSide) / 2, (self.frame.size.height - screenSide) / 2, screenSide, screenSide);
    }
    
    _progressWrapperView.frame = _wrapperView.frame;
    
    _selectedPhotosView.interfaceOrientation = orientation;
    
    CGFloat photosViewSize = TGPhotoThumbnailSizeForCurrentScreen().height + 4 * 2;
    
    switch (orientation)
    {
        case UIInterfaceOrientationLandscapeLeft:
        {
            [UIView performWithoutAnimation:^
            {
                _photoCounterButton.frame = CGRectMake(screenEdges.left + [_landscapeToolbarView landscapeSize] + 1,
                                                       screenEdges.top + 14,
                                                       64,
                                                       38);
                _progressCounterButton.frame = _photoCounterButton.frame;
                
                _selectedPhotosView.frame = CGRectMake(screenEdges.left + [_landscapeToolbarView landscapeSize] + 66,
                                                       screenEdges.top + 4,
                                                       photosViewSize,
                                                       self.frame.size.height - 4 * 2);
                
                _landscapeToolbarView.frame = CGRectMake(screenEdges.left,
                                                         screenEdges.top,
                                                         [_landscapeToolbarView landscapeSize],
                                                         self.frame.size.height);
            }];
            
            _headerWrapperView.frame = CGRectMake([_landscapeToolbarView landscapeSize] + screenEdges.left, screenEdges.top, self.frame.size.width - [_landscapeToolbarView landscapeSize], 64);
        }
            break;
            
        case UIInterfaceOrientationLandscapeRight:
        {
            [UIView performWithoutAnimation:^
            {
                _photoCounterButton.frame = CGRectMake(screenEdges.right - [_landscapeToolbarView landscapeSize] - 64 - 1,
                                                       screenEdges.top + 14,
                                                       64,
                                                       38);
                _progressCounterButton.frame = _photoCounterButton.frame;
                                
                _selectedPhotosView.frame = CGRectMake(screenEdges.right - [_landscapeToolbarView landscapeSize] - photosViewSize - 66,
                                                       screenEdges.top + 4,
                                                       photosViewSize,
                                                       self.frame.size.height - 4 * 2);
                
                _landscapeToolbarView.frame = CGRectMake(screenEdges.right - [_landscapeToolbarView landscapeSize],
                                                         screenEdges.top,
                                                         [_landscapeToolbarView landscapeSize],
                                                         self.frame.size.height);
            }];
            
            _headerWrapperView.frame = CGRectMake(screenEdges.left, screenEdges.top, self.frame.size.width - [_landscapeToolbarView landscapeSize], 64);
        }
            break;
            
        default:
        {
            [UIView performWithoutAnimation:^
            {
                _photoCounterButton.frame = CGRectMake(screenEdges.right - 64,
                                                       screenEdges.bottom - TGPhotoEditorToolbarSize - 38 - 14,
                                                       64,
                                                       38);
                _progressCounterButton.frame = _photoCounterButton.frame;
                
                _selectedPhotosView.frame = CGRectMake(screenEdges.left + 4,
                                                       screenEdges.bottom - TGPhotoEditorToolbarSize - photosViewSize - 66,
                                                       self.frame.size.width - 4 * 2,
                                                       photosViewSize);
            }];
            
            _landscapeToolbarView.frame = CGRectMake(_landscapeToolbarView.frame.origin.x,
                                                     screenEdges.top,
                                                     [_landscapeToolbarView landscapeSize],
                                                     self.frame.size.height);
            
            _headerWrapperView.frame = CGRectMake(screenEdges.left, screenEdges.top, self.frame.size.width, 64);
        }
            break;
    }
    
    TGModernGalleryItemView *currentItemView = _currentItemView;
    _checkButton.frame = [self _checkButtonFrameForOrientation:orientation screenEdges:screenEdges hasHeaderView:(currentItemView.headerView != nil)];
    
    CGFloat portraitToolbarViewBottomEdge = screenSide;
    if (self.usesSimpleLayout || isPad)
        portraitToolbarViewBottomEdge = screenEdges.bottom;
    _portraitToolbarView.frame = CGRectMake(screenEdges.left, portraitToolbarViewBottomEdge - TGPhotoEditorToolbarSize, self.frame.size.width, TGPhotoEditorToolbarSize);
    
    for (UIView *itemHeaderView in _itemHeaderViews)
        itemHeaderView.frame = _headerWrapperView.bounds;
    
    CGRect itemFooterViewFrame = [self itemFooterViewFrameForSize:self.frame.size];
    for (UIView *itemFooterView in _itemFooterViews)
        itemFooterView.frame = itemFooterViewFrame;
}

@end
