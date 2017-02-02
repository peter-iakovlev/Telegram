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

#import "TGMediaSelectionContext.h"
#import "TGMediaEditingContext.h"
#import "TGVideoEditAdjustments.h"
#import "TGMediaPickerGallerySelectedItemsModel.h"

#import "TGModernGallerySelectableItem.h"
#import "TGModernGalleryEditableItem.h"
#import "TGMediaPickerGalleryPhotoItemView.h"
#import "TGMediaPickerGalleryVideoItemView.h"

#import "TGMessageImageViewOverlayView.h"

#import "TGPhotoEditorTabController.h"
#import "TGPhotoToolbarView.h"
#import "TGPhotoEditorButton.h"
#import "TGCheckButtonView.h"
#import "TGMediaPickerPhotoCounterButton.h"
#import "TGMediaPickerPhotoStripView.h"

#import "TGMenuView.h"

#import "TGPhotoCaptionInputMixin.h"

@interface TGMediaPickerGalleryInterfaceView ()
{
    id<TGModernGalleryItem> _currentItem;
    __weak TGModernGalleryItemView *_currentItemView;
    
    TGMediaSelectionContext *_selectionContext;
    TGMediaEditingContext *_editingContext;
    
    NSMutableArray *_itemHeaderViews;
    NSMutableArray *_itemFooterViews;
    
    UIView *_wrapperView;
    UIView *_headerWrapperView;
    TGPhotoToolbarView *_portraitToolbarView;
    TGPhotoToolbarView *_landscapeToolbarView;
    
    TGPhotoCaptionInputMixin *_captionMixin;
    
    TGCheckButtonView *_checkButton;
    TGMediaPickerPhotoCounterButton *_photoCounterButton;
    
    TGMediaPickerPhotoStripView *_selectedPhotosView;
    
    SMetaDisposable *_adjustmentsDisposable;
    SMetaDisposable *_captionDisposable;
    SMetaDisposable *_itemAvailabilityDisposable;
    SMetaDisposable *_itemSelectedDisposable;
    
    void (^_closePressed)();
    void (^_scrollViewOffsetRequested)(CGFloat offset);
}
@end

@implementation TGMediaPickerGalleryInterfaceView

- (instancetype)initWithFocusItem:(id<TGModernGalleryItem>)focusItem selectionContext:(TGMediaSelectionContext *)selectionContext editingContext:(TGMediaEditingContext *)editingContext hasSelectionPanel:(bool)hasSelectionPanel
{
    self = [super initWithFrame:CGRectZero];
    if (self != nil)
    {
        _selectionContext = selectionContext;
        _editingContext = editingContext;
        
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
        
        _portraitToolbarView = [[TGPhotoToolbarView alloc] initWithBackButtonTitle:TGLocalized(@"Common.Back") doneButtonTitle:TGLocalized(@"MediaPicker.Send") accentedDone:false solidBackground:false];
        _portraitToolbarView.cancelPressed = toolbarCancelPressed;
        _portraitToolbarView.donePressed = toolbarDonePressed;
        [_wrapperView addSubview:_portraitToolbarView];

        _landscapeToolbarView = [[TGPhotoToolbarView alloc] initWithBackButtonTitle:TGLocalized(@"Common.Back") doneButtonTitle:TGLocalized(@"MediaPicker.Send") accentedDone:false solidBackground:false];
        _landscapeToolbarView.cancelPressed = toolbarCancelPressed;
        _landscapeToolbarView.donePressed = toolbarDonePressed;
        [_wrapperView addSubview:_landscapeToolbarView];
        
        [_landscapeToolbarView calculateLandscapeSizeForPossibleButtonTitles:@[ TGLocalized(@"Common.Back"), TGLocalized(@"Common.Cancel"), TGLocalized(@"Common.Done"), TGLocalized(@"MediaPicker.Send") ]];
        
        if (_selectionContext != nil)
        {
            _checkButton = [[TGCheckButtonView alloc] initWithStyle:TGCheckButtonStyleGallery];
            _checkButton.frame = CGRectMake(self.frame.size.width - 53, 11, _checkButton.frame.size.width, _checkButton.frame.size.height);
            [_checkButton addTarget:self action:@selector(checkButtonPressed) forControlEvents:UIControlEventTouchUpInside];
            [_wrapperView addSubview:_checkButton];
        
            if (hasSelectionPanel)
            {
                _selectedPhotosView = [[TGMediaPickerPhotoStripView alloc] initWithFrame:CGRectZero];
                _selectedPhotosView.selectionContext = _selectionContext;
                _selectedPhotosView.editingContext = _editingContext;
                _selectedPhotosView.itemSelected = ^(NSInteger index)
                {
                    __strong TGMediaPickerGalleryInterfaceView *strongSelf = weakSelf;
                    if (strongSelf == nil)
                        return;
                    
                    if (strongSelf.photoStripItemSelected != nil)
                        strongSelf.photoStripItemSelected(index);
                };
                _selectedPhotosView.hidden = true;
                [_wrapperView addSubview:_selectedPhotosView];
            }
        
            _photoCounterButton = [[TGMediaPickerPhotoCounterButton alloc] initWithFrame:CGRectMake(0, 0, 64, 38)];
            [_photoCounterButton addTarget:self action:@selector(photoCounterButtonPressed) forControlEvents:UIControlEventTouchUpInside];
            _photoCounterButton.userInteractionEnabled = false;
            [_wrapperView addSubview:_photoCounterButton];
        }
        
        [self updateEditorButtonsForItem:focusItem animated:false];
        
        _adjustmentsDisposable = [[SMetaDisposable alloc] init];
        _captionDisposable = [[SMetaDisposable alloc] init];
        _itemSelectedDisposable = [[SMetaDisposable alloc] init];
        _itemAvailabilityDisposable = [[SMetaDisposable alloc] init];
        
        _captionMixin = [[TGPhotoCaptionInputMixin alloc] init];
        _captionMixin.panelParentView = ^UIView *
        {
            __strong TGMediaPickerGalleryInterfaceView *strongSelf = weakSelf;
            return strongSelf->_wrapperView;
        };
        
        _captionMixin.panelFocused = ^
        {
            __strong TGMediaPickerGalleryInterfaceView *strongSelf = weakSelf;
            if (strongSelf == nil)
                return;
            
            TGModernGalleryItemView *currentItemView = strongSelf->_currentItemView;
            if ([currentItemView isKindOfClass:[TGMediaPickerGalleryVideoItemView class]])
            {
                TGMediaPickerGalleryVideoItemView *videoItemView = (TGMediaPickerGalleryVideoItemView *)strongSelf->_currentItemView;
                [videoItemView stop];
            }
            
            [strongSelf setSelectionInterfaceHidden:true animated:true];
            [strongSelf setItemHeaderViewHidden:true animated:true];
        };
        
        _captionMixin.finishedWithCaption = ^(NSString *caption)
        {
            __strong TGMediaPickerGalleryInterfaceView *strongSelf = weakSelf;
            if (strongSelf == nil)
                return;
            
            [strongSelf setSelectionInterfaceHidden:false delay:0.25 animated:true];
            [strongSelf setItemHeaderViewHidden:false animated:true];
            
            if (strongSelf.captionSet != nil)
                strongSelf.captionSet(strongSelf->_currentItem, caption);
            
            [strongSelf updateEditorButtonsForItem:strongSelf->_currentItem animated:false];
        };
        
        _captionMixin.keyboardHeightChanged = ^(CGFloat keyboardHeight, NSTimeInterval duration, NSInteger animationCurve)
        {
            __strong TGMediaPickerGalleryInterfaceView *strongSelf = weakSelf;
            if (strongSelf == nil)
                return;
            
            CGFloat offset = 0.0f;
            if (keyboardHeight > 0)
                offset = -keyboardHeight / 2.0f;
            
            [UIView animateWithDuration:duration delay:0.0f options:animationCurve animations:^
            {
                if (strongSelf->_scrollViewOffsetRequested != nil)
                    strongSelf->_scrollViewOffsetRequested(offset);
            } completion:nil];
        };
        
        [_captionMixin createInputPanelIfNeeded];
    }
    return self;
}

- (void)dealloc
{
    [_adjustmentsDisposable dispose];
    [_captionDisposable dispose];
    [_itemSelectedDisposable dispose];
    [_itemAvailabilityDisposable dispose];
}

- (void)setHasCaptions:(bool)hasCaptions
{
    _hasCaptions = hasCaptions;
    if (!hasCaptions)
        [_captionMixin destroy];
}

- (void)setSuggestionContext:(TGSuggestionContext *)suggestionContext
{
    _captionMixin.suggestionContext = suggestionContext;
}

- (void)setClosePressed:(void (^)())closePressed
{
    _closePressed = [closePressed copy];
}

- (void)setScrollViewOffsetRequested:(void (^)(CGFloat))scrollViewOffsetRequested
{
    _scrollViewOffsetRequested = [scrollViewOffsetRequested copy];
}

- (void)setEditorTabPressed:(void (^)(TGPhotoEditorTab tab))editorTabPressed
{
    __weak TGMediaPickerGalleryInterfaceView *weakSelf = self;
    void (^tabPressed)(TGPhotoEditorTab) = ^(TGPhotoEditorTab tab)
    {
        __strong TGMediaPickerGalleryInterfaceView *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        if (tab == TGPhotoEditorGifTab)
            [strongSelf toggleSendAsGif];
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
  
    __weak TGMediaPickerGalleryInterfaceView *weakSelf = self;
    
    if (_selectionContext != nil)
    {
        _checkButton.frame = [self _checkButtonFrameForOrientation:[self interfaceOrientation] screenEdges:screenEdges hasHeaderView:(itemView.headerView != nil)];
        
        SSignal *signal = nil;
        id<TGMediaSelectableItem>selectableItem = nil;
        if ([_currentItem conformsToProtocol:@protocol(TGModernGallerySelectableItem)])
            selectableItem = ((id<TGModernGallerySelectableItem>)_currentItem).selectableMediaItem;
        
        [_checkButton setSelected:[_selectionContext isItemSelected:selectableItem] animated:false];
        signal = [_selectionContext itemInformativeSelectedSignal:selectableItem];
        [_itemSelectedDisposable setDisposable:[signal startWithNext:^(TGMediaSelectionChange *next)
        {
            __strong TGMediaPickerGalleryInterfaceView *strongSelf = weakSelf;
            if (strongSelf == nil)
                return;
            
            if (next.sender != strongSelf->_checkButton)
                [strongSelf->_checkButton setSelected:next.selected animated:next.animated];
        }]];
    }
    
    [self updateEditorButtonsForItem:item animated:true];
    
    __weak TGModernGalleryItemView *weakItemView = itemView;
    [_itemAvailabilityDisposable setDisposable:[[[itemView contentAvailabilityStateSignal] deliverOn:[SQueue mainQueue]] startWithNext:^(id next)
    {
        __strong TGMediaPickerGalleryInterfaceView *strongSelf = weakSelf;
        __strong TGModernGalleryItemView *strongItemView = weakItemView;
        if (strongSelf == nil || strongItemView == nil)
            return;

        bool available = [next boolValue];
        
        NSString *itemId = nil;
        if ([strongItemView.item respondsToSelector:@selector(uniqueId)])
            itemId = [itemView.item performSelector:@selector(uniqueId)];
                      
        NSString *currentId = nil;
        if ([strongSelf->_currentItem respondsToSelector:@selector(uniqueId)])
            currentId = [strongSelf->_currentItem performSelector:@selector(uniqueId)];
        
        if (strongItemView.item == strongSelf->_currentItem || [itemId isEqualToString:currentId])
        {
            [strongSelf->_portraitToolbarView setEditButtonsEnabled:available animated:true];
            [strongSelf->_landscapeToolbarView setEditButtonsEnabled:available animated:true];
        }
    }]];
}

- (TGPhotoEditorTab)currentTabs
{
    return _portraitToolbarView.currentTabs;
}

- (void)setTabBarUserInteractionEnabled:(bool)enabled
{
    _portraitToolbarView.userInteractionEnabled = enabled;
    _landscapeToolbarView.userInteractionEnabled = enabled;
}

- (void)setThumbnailSignalForItem:(SSignal *(^)(id))thumbnailSignalForItem
{
    [_selectedPhotosView setThumbnailSignalForItem:thumbnailSignalForItem];
}

- (void)checkButtonPressed
{
    if (_currentItem == nil)
        return;
    
    bool animated = false;
    if (!_selectedPhotosView.isAnimating)
    {
        animated = true;
    }

    id<TGMediaSelectableItem>selectableItem = nil;
    if ([_currentItem conformsToProtocol:@protocol(TGModernGallerySelectableItem)])
        selectableItem = ((id<TGModernGallerySelectableItem>)_currentItem).selectableMediaItem;
    
    [_checkButton setSelected:!_checkButton.selected animated:true];
    
    if (selectableItem != nil)
        [_selectionContext setItem:selectableItem selected:_checkButton.selected animated:animated sender:_checkButton];
}

- (void)photoCounterButtonPressed
{
    [_photoCounterButton setSelected:!_photoCounterButton.selected animated:true];
    [_selectedPhotosView setHidden:!_photoCounterButton.selected animated:true];
}

- (void)updateEditorButtonsForItem:(id<TGModernGalleryItem>)item animated:(bool)animated
{
    if (_editingContext == nil || _editingContext.inhibitEditing)
    {
        [_portraitToolbarView setEditButtonsHidden:true animated:false];
        [_landscapeToolbarView setEditButtonsHidden:true animated:false];
        return;
    }
    
    TGPhotoEditorTab tabs = TGPhotoEditorNoneTab;
    if ([item conformsToProtocol:@protocol(TGModernGalleryEditableItem)])
        tabs = [(id<TGModernGalleryEditableItem>)item toolbarTabs];
    
    if (!self.hasCaptions)
        tabs &= ~TGPhotoEditorCaptionTab;
    
    if (iosMajorVersion() < 7)
    {
        tabs &= ~ TGPhotoEditorPaintTab;
        tabs &= ~ TGPhotoEditorToolsTab;
    }
    
    [_portraitToolbarView setToolbarTabs:tabs animated:animated];
    [_landscapeToolbarView setToolbarTabs:tabs animated:animated];
    
    bool editButtonsHidden = ![item conformsToProtocol:@protocol(TGModernGalleryEditableItem)];
    [_portraitToolbarView setEditButtonsHidden:editButtonsHidden animated:animated];
    [_landscapeToolbarView setEditButtonsHidden:editButtonsHidden animated:animated];
    
    if (editButtonsHidden)
    {
        [_adjustmentsDisposable setDisposable:nil];
        [_captionDisposable setDisposable:nil];
        return;
    }
    
    id<TGModernGalleryEditableItem> galleryEditableItem = (id<TGModernGalleryEditableItem>)item;
    if ([item conformsToProtocol:@protocol(TGModernGalleryEditableItem)])
    {
        id<TGMediaEditableItem> editableMediaItem = [galleryEditableItem editableMediaItem];
        
        __weak TGMediaPickerGalleryInterfaceView *weakSelf = self;
        [_adjustmentsDisposable setDisposable:[[[galleryEditableItem.editingContext adjustmentsSignalForItem:editableMediaItem] deliverOn:[SQueue mainQueue]] startWithNext:^(id<TGMediaEditAdjustments> adjustments)
        {
            __strong TGMediaPickerGalleryInterfaceView *strongSelf = weakSelf;
            if (strongSelf == nil)
                return;
            
            if ([adjustments isKindOfClass:[TGVideoEditAdjustments class]])
            {
                TGVideoEditAdjustments *videoAdjustments = (TGVideoEditAdjustments *)adjustments;
                [strongSelf->_captionMixin setCaptionPanelHidden:(videoAdjustments.sendAsGif && strongSelf->_inhibitDocumentCaptions) animated:true];
            }
            else
            {
                [strongSelf->_captionMixin setCaptionPanelHidden:false animated:true];
            }

            [strongSelf updateEditorButtonsForAdjustments:adjustments];
        }]];
        
        [_captionDisposable setDisposable:[[galleryEditableItem.editingContext captionSignalForItem:editableMediaItem] startWithNext:^(NSString *caption)
        {
            __strong TGMediaPickerGalleryInterfaceView *strongSelf = weakSelf;
            if (strongSelf == nil)
                return;
            
            [strongSelf->_captionMixin setCaption:caption animated:animated];
        }]];
    }
    else
    {
        [_adjustmentsDisposable setDisposable:nil];
        [_captionDisposable setDisposable:nil];
        [self updateEditorButtonsForAdjustments:nil];
        [_captionMixin setCaption:nil animated:animated];
    }
}

- (void)updateEditorButtonsForAdjustments:(id<TGMediaEditAdjustments>)adjustments
{
    TGPhotoEditorTab highlightedButtons = [TGPhotoEditorTabController highlightedButtonsForEditorValues:adjustments forAvatar:false];
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
}

- (void)updateSelectedPhotosView:(bool)reload incremental:(bool)incremental add:(bool)add index:(NSInteger)index
{
    if (_selectedPhotosView == nil)
        return;
    
    if (!reload)
        return;
    
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

#pragma mark - 

- (void)setItemHeaderViewHidden:(bool)hidden animated:(bool)animated
{
    if (animated)
    {
        [UIView animateWithDuration:0.2f animations:^
        {
            for (UIView *view in _itemHeaderViews)
            {
                if (!view.hidden)
                    view.alpha = hidden ? 0.0f : 1.0f;
            }
        } completion:^(BOOL finished)
        {
            if (finished)
            {
                for (UIView *view in _itemHeaderViews)
                {
                    if (!view.hidden)
                        view.userInteractionEnabled = !hidden;
                }
            }
        }];
    }
    else
    {
        for (UIView *view in _itemHeaderViews)
        {
            if (!view.hidden)
            {
                view.alpha = hidden ? 0.0f : 1.0f;
                view.userInteractionEnabled = !hidden;
            }
        }
    }
}

- (void)toggleSendAsGif
{
    if (![_currentItem conformsToProtocol:@protocol(TGModernGalleryEditableItem)])
        return;
    
    TGModernGalleryItemView *currentItemView = _currentItemView;
    if ([currentItemView isKindOfClass:[TGMediaPickerGalleryVideoItemView class]])
        [(TGMediaPickerGalleryVideoItemView *)currentItemView toggleSendAsGif];
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

- (void)editorTransitionIn
{
    [self setSelectionInterfaceHidden:true animated:true];
    
    [UIView animateWithDuration:0.2 animations:^
    {
        _captionMixin.inputPanel.alpha = 0.0f;
    }];
}

- (void)editorTransitionOut
{
    [self setSelectionInterfaceHidden:false animated:true];
    
    [UIView animateWithDuration:0.3 animations:^
    {
        _captionMixin.inputPanel.alpha = 1.0f;
    }];
}

#pragma mark -

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *view = [super hitTest:point withEvent:event];
    
    if (view == _photoCounterButton
        || view == _checkButton
        || [view isDescendantOfView:_headerWrapperView]
        || [view isDescendantOfView:_portraitToolbarView]
        || [view isDescendantOfView:_landscapeToolbarView]
        || [view isDescendantOfView:_selectedPhotosView]
        || [view isDescendantOfView:_captionMixin.inputPanel]
        || [view isDescendantOfView:_captionMixin.dismissView]
        || [view isKindOfClass:[TGMenuButtonView class]])
        
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
            frame = CGRectMake(screenEdges.right - 53, screenEdges.top + 11, _checkButton.frame.size.width, _checkButton.frame.size.height);
            break;
            
        case UIInterfaceOrientationLandscapeRight:
            frame = CGRectMake(screenEdges.left + 4, screenEdges.top + 11, _checkButton.frame.size.width, _checkButton.frame.size.height);
            break;
            
        default:
            frame = CGRectMake(screenEdges.right - 53, screenEdges.top + 11, _checkButton.frame.size.width, _checkButton.frame.size.height);
            break;
    }
    
    if (hasHeaderView)
        frame.origin.y += 64;
    
    return frame;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)__unused duration
{
    _landscapeToolbarView.interfaceOrientation = toInterfaceOrientation;
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
    return TGAppDelegateInstance.rootController.applicationBounds.size;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [_captionMixin setContentAreaHeight:self.frame.size.height];
    
    UIInterfaceOrientation orientation = [self interfaceOrientation];
    CGSize screenSize = TGScreenSize();
    if (TGIsPad())
        screenSize = [self referenceViewSize];
    
    CGFloat screenSide = MAX(screenSize.width, screenSize.height);
    UIEdgeInsets screenEdges = UIEdgeInsetsZero;
    
    if (TGIsPad())
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
    
    _selectedPhotosView.interfaceOrientation = orientation;
    
    CGFloat photosViewSize = TGPhotoThumbnailSizeForCurrentScreen().height + 4 * 2;
    
    bool hasHeaderView = (_currentItemView.headerView != nil);
    CGFloat headerInset = hasHeaderView ? 64.0f : 0.0f;
    
    CGFloat portraitToolbarViewBottomEdge = screenSide;
    if (self.usesSimpleLayout || TGIsPad())
        portraitToolbarViewBottomEdge = screenEdges.bottom;
    _portraitToolbarView.frame = CGRectMake(screenEdges.left, portraitToolbarViewBottomEdge - TGPhotoEditorToolbarSize, self.frame.size.width, TGPhotoEditorToolbarSize);
    
    UIEdgeInsets captionEdgeInsets = screenEdges;
    captionEdgeInsets.bottom = _portraitToolbarView.frame.size.height;
    [_captionMixin updateLayoutWithFrame:self.bounds edgeInsets:captionEdgeInsets];
    
    switch (orientation)
    {
        case UIInterfaceOrientationLandscapeLeft:
        {
            [UIView performWithoutAnimation:^
            {
                _photoCounterButton.frame = CGRectMake(screenEdges.left + [_landscapeToolbarView landscapeSize] + 1, screenEdges.top + 14 + headerInset, 64, 38);
                
                _selectedPhotosView.frame = CGRectMake(screenEdges.left + [_landscapeToolbarView landscapeSize] + 66, screenEdges.top + 4 + headerInset, photosViewSize, self.frame.size.height - 4 * 2 - headerInset);
                
                _landscapeToolbarView.frame = CGRectMake(screenEdges.left, screenEdges.top, [_landscapeToolbarView landscapeSize], self.frame.size.height);
            }];
            
            _headerWrapperView.frame = CGRectMake([_landscapeToolbarView landscapeSize] + screenEdges.left, screenEdges.top, self.frame.size.width - [_landscapeToolbarView landscapeSize], 64);
        }
            break;
            
        case UIInterfaceOrientationLandscapeRight:
        {
            [UIView performWithoutAnimation:^
            {
                _photoCounterButton.frame = CGRectMake(screenEdges.right - [_landscapeToolbarView landscapeSize] - 64 - 1, screenEdges.top + 14 + headerInset, 64, 38);
                
                _selectedPhotosView.frame = CGRectMake(screenEdges.right - [_landscapeToolbarView landscapeSize] - photosViewSize - 66, screenEdges.top + 4 + headerInset, photosViewSize, self.frame.size.height - 4 * 2 - headerInset);
                
                _landscapeToolbarView.frame = CGRectMake(screenEdges.right - [_landscapeToolbarView landscapeSize], screenEdges.top, [_landscapeToolbarView landscapeSize], self.frame.size.height);
            }];
            
            _headerWrapperView.frame = CGRectMake(screenEdges.left, screenEdges.top, self.frame.size.width - [_landscapeToolbarView landscapeSize], 64);
        }
            break;
            
        default:
        {
            [UIView performWithoutAnimation:^
            {
                _photoCounterButton.frame = CGRectMake(screenEdges.right - 64, screenEdges.bottom - TGPhotoEditorToolbarSize - [_captionMixin.inputPanel baseHeight] - 38 - 14, 64, 38);
                
                _selectedPhotosView.frame = CGRectMake(screenEdges.left + 4, screenEdges.bottom - TGPhotoEditorToolbarSize - [_captionMixin.inputPanel baseHeight] - photosViewSize - 66, self.frame.size.width - 4 * 2, photosViewSize);
            }];
            
            _landscapeToolbarView.frame = CGRectMake(_landscapeToolbarView.frame.origin.x, screenEdges.top, [_landscapeToolbarView landscapeSize], self.frame.size.height);
            
            _headerWrapperView.frame = CGRectMake(screenEdges.left, screenEdges.top, self.frame.size.width, 64);
        }
            break;
    }
    
    _checkButton.frame = [self _checkButtonFrameForOrientation:orientation screenEdges:screenEdges hasHeaderView:hasHeaderView];
    
    for (UIView *itemHeaderView in _itemHeaderViews)
        itemHeaderView.frame = _headerWrapperView.bounds;
    
    CGRect itemFooterViewFrame = [self itemFooterViewFrameForSize:self.frame.size];
    for (UIView *itemFooterView in _itemFooterViews)
        itemFooterView.frame = itemFooterViewFrame;
}

@end
