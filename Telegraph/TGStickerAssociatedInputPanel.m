#import "TGStickerAssociatedInputPanel.h"

#import <LegacyComponents/LegacyComponents.h>

#import <AudioToolbox/AudioToolbox.h>

#import "TGStickerAssociatedPanelCollectionLayout.h"
#import "TGStickerAssociatedInputPanelCell.h"

#import <LegacyComponents/TGItemPreviewController.h>
#import <LegacyComponents/TGStickerItemPreviewView.h>
#import <LegacyComponents/TGItemMenuSheetPreviewView.h>
#import <LegacyComponents/TGMenuSheetButtonItemView.h>

#import <LegacyComponents/TGDoubleTapGestureRecognizer.h>
#import "TGForceTouchGestureRecognizer.h"

#import "TGStickersMenu.h"

#import "TGFavoriteStickersSignal.h"

#import "TGLegacyComponentsContext.h"

@interface TGStickerAssociatedInputPanel () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, TGDoubleTapGestureRecognizerDelegate, UIGestureRecognizerDelegate>
{
    UICollectionView *_collectionView;
    TGStickerAssociatedPanelCollectionLayout *_layout;
    
    NSArray *_documentList;
    NSDictionary *_associations;
    NSDictionary *_stickerPacks;
    
    CGFloat _targetOffset;
    UIImageView *_leftBackgroundView;
    UIImageView *_rightBackgroundView;
    UIImageView *_middleBackgroundView;
    
    __weak TGItemPreviewController *_previewController;
    __weak TGMenuSheetButtonItemView *_faveItem;
    
    UILongPressGestureRecognizer *_pressGestureRecognizer;
    TGForceTouchGestureRecognizer *_forceTouchRecognizer;
    
    NSTimer *_actionsTimer;
}

@end

@implementation TGStickerAssociatedInputPanel

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        NSString *leftImageName = (self.style == TGModernConversationAssociatedInputPanelDarkBlurredStyle) ? @"StickerPanelPopupLeftDark.png" : @"StickerPanelPopupLeft.png";
        NSString *rightImageName = (self.style == TGModernConversationAssociatedInputPanelDarkBlurredStyle) ? @"StickerPanelPopupRightDark.png" : @"StickerPanelPopupRight.png";
        NSString *middleImageName = (self.style == TGModernConversationAssociatedInputPanelDarkBlurredStyle) ? @"StickerPanelPopupMiddleDark.png" : @"StickerPanelPopupMiddle.png";
        
        UIImage *leftImage = [[UIImage imageNamed:leftImageName] resizableImageWithCapInsets:UIEdgeInsetsMake(18, 10, 18, 1)];
        UIImage *rightImage = [[UIImage imageNamed:rightImageName] resizableImageWithCapInsets:UIEdgeInsetsMake(18, 1, 18, 10)];
        UIImage *middleImage = [[UIImage imageNamed:middleImageName] resizableImageWithCapInsets:UIEdgeInsetsMake(18, 2, 18, 2)];
        
        _leftBackgroundView = [[UIImageView alloc] initWithImage:leftImage];
        [self addSubview:_leftBackgroundView];
        _rightBackgroundView = [[UIImageView alloc] initWithImage:rightImage];
        [self addSubview:_rightBackgroundView];
        _middleBackgroundView = [[UIImageView alloc] initWithImage:middleImage];
        [self addSubview:_middleBackgroundView];
        
        if (self.style == TGModernConversationAssociatedInputPanelDarkBlurredStyle)
        {
            _leftBackgroundView.alpha = 0.96f;
            _rightBackgroundView.alpha = 0.96f;
            _middleBackgroundView.alpha = 0.96f;
        }
        
        _layout = [[TGStickerAssociatedPanelCollectionLayout alloc] init];
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:_layout];
        if (iosMajorVersion() >= 11)
            _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.backgroundColor = [UIColor clearColor];
        _layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _collectionView.delaysContentTouches = false;
        _collectionView.showsHorizontalScrollIndicator = false;
        _collectionView.showsVerticalScrollIndicator = false;
        _collectionView.clipsToBounds = true;
        [_collectionView registerClass:[TGStickerAssociatedInputPanelCell class]
            forCellWithReuseIdentifier:@"TGStickerAssociatedInputPanelCell"];
        [self addSubview:_collectionView];
        
        _pressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
        _pressGestureRecognizer.minimumPressDuration = 0.25;
        
        [_collectionView addGestureRecognizer:_pressGestureRecognizer];
    }
    return self;
}

- (CGFloat)preferredHeight
{
    return 75.0f;
}

- (NSArray *)documentList
{
    return _documentList;
}

- (void)setDocumentList:(NSDictionary *)dictionary
{
    NSArray *documents = dictionary[@"documents"];
    NSDictionary *associations = dictionary[@"associations"];
    NSDictionary *stickerPacks = dictionary[@"stickerPacks"];
    
    if (!TGObjectCompare(_documentList, documents))
    {
        _documentList = documents;
        _associations = associations;
        _stickerPacks = stickerPacks;
        [_collectionView reloadData];
        [_collectionView layoutSubviews];
    }
}

- (void)setTargetOffset:(CGFloat)targetOffset
{
    _targetOffset = targetOffset;
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat localTargetOffset = _targetOffset + self.safeAreaInset.left;
    
    CGFloat topPadding = 5.0f;
    CGFloat collectionTopPadding = topPadding;
    
    if (self.style == TGModernConversationAssociatedInputPanelDarkBlurredStyle)
    {
        topPadding = -12.0f;
        collectionTopPadding = -4.0f;
    }
    
    CGFloat backgroundHeight = _middleBackgroundView.image.size.height + 1 - TGRetinaPixel;
    
    CGFloat itemWidth = [self collectionView:_collectionView layout:_layout sizeForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]].width;
    CGFloat collectionWidth = itemWidth * [self collectionView:_collectionView numberOfItemsInSection:0];
    
    CGFloat padding = 2.0f + self.safeAreaInset.left;
    CGFloat collectionPadding = 2.0f;
    
    CGFloat collectionOrigin = CGFloor((localTargetOffset - collectionWidth) / 2.0f);
    CGFloat middleOrigin = CGFloor((localTargetOffset - _middleBackgroundView.frame.size.width) / 2.0f);
    collectionOrigin = MAX(padding, collectionOrigin);
    
    _collectionView.frame = CGRectMake(collectionOrigin + collectionPadding, collectionTopPadding, self.frame.size.width - padding * 2.0f - collectionPadding * 2.0f, [self preferredHeight]);
    
    _middleBackgroundView.frame = CGRectMake(middleOrigin, topPadding, _middleBackgroundView.frame.size.width, backgroundHeight);
    _leftBackgroundView.frame = CGRectMake(collectionOrigin, topPadding, _middleBackgroundView.frame.origin.x - collectionOrigin, backgroundHeight);
    _rightBackgroundView.frame = CGRectMake(CGRectGetMaxX(_middleBackgroundView.frame), topPadding, MIN(collectionOrigin + collectionWidth, self.frame.size.width - padding) - CGRectGetMaxX(_middleBackgroundView.frame), backgroundHeight);
}

- (NSInteger)collectionView:(UICollectionView *)__unused collectionView numberOfItemsInSection:(NSInteger)__unused section
{
    return _documentList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TGStickerAssociatedInputPanelCell *cell = (TGStickerAssociatedInputPanelCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"TGStickerAssociatedInputPanelCell" forIndexPath:indexPath];
    
    [cell setDocument:_documentList[indexPath.row]];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)__unused collectionView layout:(UICollectionViewLayout *)__unused collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)__unused indexPath
{
    return CGSizeMake(72.0f, 72.0f);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)__unused collectionView layout:(UICollectionViewLayout *)__unused collectionViewLayout insetForSectionAtIndex:(NSInteger)__unused section
{
    return UIEdgeInsetsZero;
}

- (CGFloat)collectionView:(UICollectionView *)__unused collectionView layout:(UICollectionViewLayout *)__unused collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)__unused section
{
    return 0.0f;
}

- (CGFloat)collectionView:(UICollectionView *)__unused collectionView layout:(UICollectionViewLayout *)__unused collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)__unused section
{
    return 0.0f;
}

- (void)collectionView:(UICollectionView *)__unused collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (_documentSelected)
        _documentSelected(_documentList[indexPath.row]);
}

- (void)startActionsTimer
{
    if (_actionsTimer != nil)
    {
        [_actionsTimer invalidate];
        _actionsTimer = nil;
    }
    
    _actionsTimer = [TGTimerTarget scheduledMainThreadTimerWithTarget:self action:@selector(presentActions) interval:0.9 repeat:false];
}

- (void)presentActions
{
    if (_previewController != nil)
    {
        if (self.resultPreviewAppeared != nil)
            self.resultPreviewAppeared();
        
        TGStickerItemPreviewView *previewView = (TGStickerItemPreviewView *)_previewController.previewView;
        
        bool isFaved = [TGFavoriteStickersSignal isFaved:previewView.item];
        [_faveItem setTitle:isFaved ? TGLocalized(@"Stickers.RemoveFromFavorites") : TGLocalized(@"Stickers.AddToFavorites")];
        
        [previewView presentActions];
    }
    
    [_actionsTimer invalidate];
    _actionsTimer = nil;
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
        __strong TGViewController *parentController = _controller;
        
        NSIndexPath *indexPath = [_collectionView indexPathForItemAtPoint:[gestureRecognizer locationInView:_collectionView]];
        if (indexPath != nil && parentController != nil)
        {
            TGDocumentMediaAttachment *document = _documentList[indexPath.item];
            
            TGStickerItemPreviewView *previewView = [[TGStickerItemPreviewView alloc] initWithContext:[TGLegacyComponentsContext shared] frame:CGRectZero];
            
            __weak TGStickerAssociatedInputPanel *weakSelf = self;
            __weak TGStickerItemPreviewView *weakPreviewView = previewView;
            NSMutableArray *actions = [[NSMutableArray alloc] init];
            TGMenuSheetButtonItemView *sendItem = [[TGMenuSheetButtonItemView alloc] initWithTitle:TGLocalized(@"ShareMenu.Send") type:TGMenuSheetButtonTypeSend action:^
            {
                __strong TGStickerItemPreviewView *strongPreviewView = weakPreviewView;
                __strong TGStickerAssociatedInputPanel *strongSelf = weakSelf;
                if (strongSelf == nil || strongPreviewView == nil)
                    return;
                
                [strongPreviewView performCommit];
                
                TGDispatchAfter(0.2, dispatch_get_main_queue(), ^
                {
                    if (strongSelf->_documentSelected)
                        strongSelf->_documentSelected(strongPreviewView.item);
                });
            }];
            [actions addObject:sendItem];
            
            TGMenuSheetButtonItemView *faveItem = [[TGMenuSheetButtonItemView alloc] initWithTitle:TGLocalized(@"Stickers.AddToFavorites") type:TGMenuSheetButtonTypeDefault action:^
            {
                __strong TGStickerItemPreviewView *strongPreviewView = weakPreviewView;
                __strong TGStickerAssociatedInputPanel *strongSelf = weakSelf;
                if (strongSelf == nil || strongPreviewView == nil)
                    return;
                
                [TGFavoriteStickersSignal setSticker:strongPreviewView.item faved:![TGFavoriteStickersSignal isFaved:strongPreviewView.item]];
                [strongPreviewView performDismissal];
            }];
            [actions addObject:faveItem];
            _faveItem = faveItem;
            
            TGMenuSheetButtonItemView *viewItem = [[TGMenuSheetButtonItemView alloc] initWithTitle:TGLocalized(@"StickerPack.ViewPack") type:TGMenuSheetButtonTypeDefault action:^
            {
                __strong TGStickerItemPreviewView *strongPreviewView = weakPreviewView;
                __strong TGStickerAssociatedInputPanel *strongSelf = weakSelf;
                if (strongSelf == nil || strongPreviewView == nil)
                    return;
                
                if (strongSelf.resultPreviewDisappeared != nil)
                    strongSelf.resultPreviewDisappeared(false);
                strongSelf->_previewController.onDismiss = nil;
                
                [strongPreviewView performDismissal];
                
                TGDocumentMediaAttachment *sticker = (TGDocumentMediaAttachment *)strongPreviewView.item;
                TGStickerPack *stickerPack = strongSelf->_stickerPacks[@(sticker.documentId)];
                
                TGDispatchAfter(0.2, dispatch_get_main_queue(), ^
                {
                    [strongSelf previewStickerPack:stickerPack sticker:sticker];
                });
            }];
            [actions addObject:viewItem];
            
            TGMenuSheetButtonItemView *cancelItem = [[TGMenuSheetButtonItemView alloc] initWithTitle:TGLocalized(@"Common.Cancel") type:TGMenuSheetButtonTypeDefault action:^
            {
                __strong TGStickerItemPreviewView *strongPreviewView = weakPreviewView;
                if (strongPreviewView == nil)
                    return;
                
                [strongPreviewView performDismissal];
            }];
            [actions addObject:cancelItem];
            
            [previewView setupWithMainItemViews:nil actionItemViews:actions];
            
            TGItemPreviewController *controller = [[TGItemPreviewController alloc] initWithContext:[TGLegacyComponentsContext shared] parentController:parentController previewView:previewView];
            controller.onDismiss = ^{
                __strong TGStickerAssociatedInputPanel *strongSelf = weakSelf;
                if (strongSelf != nil && strongSelf.resultPreviewDisappeared != nil)
                    strongSelf.resultPreviewDisappeared(true);
            };
            _previewController = controller;
            
            controller.sourcePointForItem = ^(id item)
            {
                __strong TGStickerAssociatedInputPanel *strongSelf = weakSelf;
                if (strongSelf == nil)
                    return CGPointZero;
                
                for (TGStickerAssociatedInputPanelCell *cell in strongSelf->_collectionView.visibleCells)
                {
                    if ([cell.document isEqual:item])
                    {
                        NSIndexPath *indexPath = [strongSelf->_collectionView indexPathForCell:cell];
                        if (indexPath != nil)
                            return [strongSelf->_collectionView convertPoint:cell.center toView:nil];
                    }
                }
                
                return CGPointZero;
            };
            
            [previewView setSticker:document associations:_associations[@(document.documentId)]];
            
            TGStickerAssociatedInputPanelCell *cell = (TGStickerAssociatedInputPanelCell *)[_collectionView cellForItemAtIndexPath:indexPath];
            [cell setHighlighted:true animated:true];

            if (!_forceTouchRecognizer.enabled)
                [self startActionsTimer];
        }
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateChanged)
    {
        TGStickerItemPreviewView *previewView = (TGStickerItemPreviewView *)_previewController.previewView;
        if (previewView.isLocked)
            return;
        
        if (_actionsTimer != nil)
            [self startActionsTimer];
        
        NSIndexPath *cellIndexPath = [_collectionView indexPathForItemAtPoint:[gestureRecognizer locationInView:_collectionView]];
        if (cellIndexPath != nil)
        {
            TGDocumentMediaAttachment *document = _documentList[cellIndexPath.item];
            [previewView setSticker:document associations:_associations[@(document.documentId)]];
            
            for (NSIndexPath *indexPath in [_collectionView indexPathsForVisibleItems])
            {
                TGStickerAssociatedInputPanelCell *cell = (TGStickerAssociatedInputPanelCell *)[_collectionView cellForItemAtIndexPath:indexPath];
                [cell setHighlighted:[indexPath isEqual:cellIndexPath] animated:true];
            }
        }
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateEnded || gestureRecognizer.state == UIGestureRecognizerStateCancelled)
    {
        [_actionsTimer invalidate];
        _actionsTimer = nil;
        
        for (TGStickerAssociatedInputPanelCell *cell in _collectionView.visibleCells)
            [cell setHighlighted:false animated:true];
        
        TGItemPreviewController *controller = _previewController;
        TGStickerItemPreviewView *previewView = (TGStickerItemPreviewView *)_previewController.previewView;
        if (previewView.isLocked)
            return;
        
        [controller dismiss];
    }
}

- (void)handleForceTouch:(TGForceTouchGestureRecognizer *)gestureRecognizer
{
    if (_previewController != nil && gestureRecognizer.state == UIGestureRecognizerStateRecognized)
    {
        AudioServicesPlaySystemSound(1519);
        [self presentActions];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if (gestureRecognizer == _pressGestureRecognizer || otherGestureRecognizer == _pressGestureRecognizer)
        return true;
    
    if (gestureRecognizer == _forceTouchRecognizer || otherGestureRecognizer == _forceTouchRecognizer)
        return true;
    
    return false;
}

- (void)didMoveToSuperview
{
    [super didMoveToSuperview];
    
    if (_forceTouchRecognizer == nil)
    {
        _forceTouchRecognizer = [[TGForceTouchGestureRecognizer alloc] initWithTarget:self action:@selector(handleForceTouch:)];
        _forceTouchRecognizer.delegate = self;
        [_collectionView addGestureRecognizer:_forceTouchRecognizer];
        
        if (![_forceTouchRecognizer forceTouchAvailable])
            _forceTouchRecognizer.enabled = false;
    }
}

- (void)previewStickerPack:(TGStickerPack *)stickerPack sticker:(TGDocumentMediaAttachment *)sticker {
    TGViewController *parentViewController = _controller;
    
    __weak TGStickerAssociatedInputPanel *weakSelf = self;
    
    CGRect sourceRect = CGRectMake(CGFloor(self.bounds.size.width / 2.0f), [UIScreen mainScreen].bounds.size.height, 0.0f, 0.0f);
    
    id<TGStickerPackReference> packReference = stickerPack == nil ? sticker.stickerPackReference : nil;
    TGMenuSheetController *controller = [TGStickersMenu presentWithParentController:parentViewController packReference:packReference stickerPack:stickerPack showShareAction:false sendSticker:^(TGDocumentMediaAttachment *document) {
        __strong TGStickerAssociatedInputPanel *strongSelf = weakSelf;
        if (strongSelf != nil) {
            if (strongSelf.documentSelected) {
                strongSelf.documentSelected(document);
            }
        }
    } stickerPackRemoved:nil stickerPackHidden:nil stickerPackArchived:false stickerPackIsMask:stickerPack.isMask sourceView:parentViewController.view sourceRect:^CGRect{
        return sourceRect;
    } centered:true existingController:nil];
    if (!TGIsPad())
    {
        controller.willDismiss = ^(__unused bool manual) {
            __strong TGStickerAssociatedInputPanel *strongSelf = weakSelf;
            if (strongSelf != nil) {
                strongSelf.resultPreviewDisappeared(true);
            }
        };
    }
}

@end
