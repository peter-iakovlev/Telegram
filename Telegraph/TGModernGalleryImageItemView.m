/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGModernGalleryImageItemView.h"

#import "TGModernGalleryImageItem.h"

#import "TGImageInfo.h"
#import "TGImageView.h"

#import "TGFont.h"

#import "TGModernGalleryImageItemImageView.h"
#import "TGModernGalleryZoomableScrollView.h"

#import "TGMessageImageViewOverlayView.h"

#import "TGModernGalleryEmbeddedStickersHeaderView.h"

#import "TGDocumentMediaAttachment.h"

#import "TGStickersMenu.h"
#import "TGDownloadMessagesSignal.h"
#import "TGImageMediaAttachment.h"

#import "TGMenuSheetController.h"
#import "TGMultipleStickerPacksCollectionItemView.h"

@interface TGModernGalleryImageItemView ()
{
    TGMessageImageViewOverlayView *_progressView;
    dispatch_block_t _resetBlock;
    
    bool _progressVisible;
    void (^_currentAvailabilityObserver)(bool);
    
    TGModernGalleryEmbeddedStickersHeaderView *_stickersHeaderView;
    
    SMetaDisposable *_stickersInfoDisposable;
    SVariable *_stickersInfo;
    bool _requestedStickersInfo;
}

@end

@implementation TGModernGalleryImageItemView

- (UIImage *)shadowImage
{
    static UIImage *image = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        
    });
    return image;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        __weak TGModernGalleryImageItemView *weakSelf = self;
        _imageView = [[TGModernGalleryImageItemImageView alloc] init];
        _imageView.progressChanged = ^(CGFloat value)
        {
            __strong TGModernGalleryImageItemView *strongSelf = weakSelf;
            [strongSelf setProgressVisible:value < 1.0f - FLT_EPSILON value:value animated:true];
        };
        _imageView.availabilityStateChanged = ^(bool available)
        {
            __strong TGModernGalleryImageItemView *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                if (strongSelf->_currentAvailabilityObserver)
                    strongSelf->_currentAvailabilityObserver(available);
            }
        };
        [self.scrollView addSubview:_imageView];
        
        _stickersInfoDisposable = [[SMetaDisposable alloc] init];
        _stickersInfo = [[SVariable alloc] init];
    }
    return self;
}

- (void)dealloc {
    [_stickersInfoDisposable dispose];
    [_stickersInfo set:[SSignal single:nil]];
}

- (void)prepareForRecycle
{
    [_imageView reset];
    if (_resetBlock)
    {
        _resetBlock();
        _resetBlock = nil;
    }
    [self setProgressVisible:false value:0.0f animated:false];
    [_stickersInfoDisposable setDisposable:nil];
    [_stickersInfo set:[SSignal single:nil]];
    _requestedStickersInfo = false;
}

- (UIView *)headerView {
    if ([self.item isKindOfClass:[TGModernGalleryImageItem class]] && ((TGModernGalleryImageItem *)self.item).hasStickers) {
        if (_stickersHeaderView == nil) {
            _stickersHeaderView = [[TGModernGalleryEmbeddedStickersHeaderView alloc] init];
            __weak TGModernGalleryImageItemView *weakSelf = self;
            _stickersHeaderView.showEmbeddedStickers = ^{
                __strong TGModernGalleryImageItemView *strongSelf = weakSelf;
                if (strongSelf != nil) {
                    [strongSelf showEmbeddedStickerPacks];
                }
            };
        }
        return _stickersHeaderView;
    }
    
    return nil;
}

- (void)setItem:(TGModernGalleryImageItem *)item synchronously:(bool)synchronously
{
    [super setItem:item synchronously:synchronously];
    
    _imageSize = item.imageSize;
    if (item.loader != nil)
        _resetBlock = [item.loader(_imageView, synchronously) copy];
    else if (item.uri == nil)
        [_imageView reset];
    else
        [_imageView loadUri:item.uri withOptions:@{TGImageViewOptionSynchronous: @(synchronously)}];
    
    [self reset];
}

- (SSignal *)contentAvailabilityStateSignal
{
    __weak TGModernGalleryImageItemView *weakSelf = self;
    return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
    {
        __strong TGModernGalleryImageItemView *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            [subscriber putNext:@([strongSelf->_imageView isAvailableNow])];
            strongSelf->_currentAvailabilityObserver = ^(bool available)
            {
                [subscriber putNext:@(available)];
            };
        }
        
        return nil;
    }];
}

- (CGSize)contentSize
{
    return _imageSize;
}

- (UIView *)contentView
{
    return _imageView;
}

- (UIView *)transitionView
{
    return self.containerView;
}

- (CGRect)transitionViewContentRect
{
    return [_imageView convertRect:_imageView.bounds toView:[self transitionView]];
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    if (_progressView != nil)
    {
        _progressView.frame = (CGRect){{CGFloor((frame.size.width - _progressView.frame.size.width) / 2.0f), CGFloor((frame.size.height - _progressView.frame.size.height) / 2.0f)}, _progressView.frame.size};
    }
}

- (void)setProgressVisible:(bool)progressVisible value:(CGFloat)value animated:(bool)animated
{
    _progressVisible = progressVisible;
    
    if (progressVisible && _progressView == nil)
    {
        _progressView = [[TGMessageImageViewOverlayView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 50.0f, 50.0f)];
        _progressView.userInteractionEnabled = false;
        
        _progressView.frame = (CGRect){{CGFloor((self.frame.size.width - _progressView.frame.size.width) / 2.0f), CGFloor((self.frame.size.height - _progressView.frame.size.height) / 2.0f)}, _progressView.frame.size};
    }
    
    if (progressVisible)
    {
        if (_progressView.superview == nil)
            [self.containerView addSubview:_progressView];
        
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

- (void)showEmbeddedStickerPacks {
    if ([self.item isKindOfClass:[TGModernGalleryImageItem class]] && ((TGModernGalleryImageItem *)self.item).hasStickers) {
        NSMutableArray *stickerPackReferences = [[NSMutableArray alloc] init];
        for (TGDocumentMediaAttachment *document in ((TGModernGalleryImageItem *)self.item).embeddedStickerDocuments) {
            for (id attribute in document.attributes) {
                if ([attribute isKindOfClass:[TGDocumentAttributeSticker class]]) {
                    if (((TGDocumentAttributeSticker *)attribute).packReference != nil) {
                        if (![stickerPackReferences containsObject:((TGDocumentAttributeSticker *)attribute).packReference]) {
                            [stickerPackReferences addObject:((TGDocumentAttributeSticker *)attribute).packReference];
                        }
                    }
                }
            }
        }
        
        TGViewController *controller = [self.delegate parentControllerForPresentation];
        if (controller != nil) {
            CGRect sourceRect = _stickersHeaderView.bounds;
            if (stickerPackReferences.count == 1) {
                [TGStickersMenu presentInParentController:controller stickerPackReference:stickerPackReferences[0] showShareAction:false sendSticker:nil stickerPackRemoved:nil stickerPackHidden:nil sourceView:_stickersHeaderView sourceRect:^CGRect
                 {
                     return sourceRect;
                 }];
            } else if (stickerPackReferences.count != 0) {
                
            } else if (((TGModernGalleryImageItem *)self.item).imageId != 0) {
                if (!_requestedStickersInfo) {
                    _requestedStickersInfo = true;
                    TGImageMediaAttachment *imageMedia = [[TGImageMediaAttachment alloc] init];
                    imageMedia.imageId = ((TGModernGalleryImageItem *)self.item).imageId;
                    imageMedia.accessHash = ((TGModernGalleryImageItem *)self.item).accessHash;
                    [_stickersInfo set:[TGDownloadMessagesSignal mediaStickerpacks:imageMedia]];
                }
                
                __weak TGModernGalleryImageItemView *weakSelf = self;
                [_stickersInfoDisposable setDisposable:[[[[[_stickersInfo signal] filter:^bool(id next) {
                    return next != nil;
                }] take:1] deliverOn:[SQueue mainQueue]] startWithNext:^(NSArray<TGStickerPack *> *stickerPacks) {
                    __strong TGModernGalleryImageItemView *strongSelf = weakSelf;
                    if (strongSelf != nil) {
                        if (stickerPacks.count == 1) {
                            TGViewController *controller = [strongSelf.delegate parentControllerForPresentation];
                            [TGStickersMenu presentInParentController:controller stickerPack:stickerPacks[0] showShareAction:false sendSticker:nil stickerPackRemoved:nil stickerPackHidden:nil stickerPackArchived:false stickerPackIsMask:stickerPacks[0].isMask sourceView:strongSelf->_stickersHeaderView sourceRect:^CGRect{
                                return sourceRect;
                            }];
                        } else if (stickerPacks.count != 0) {
                            [strongSelf previewMultipleStickerPacks:stickerPacks];
                        }
                    }
                }]];
            }
        }
    }
}

- (void)previewStickerPack:(TGStickerPack *)stickerPack inMenuController:(TGMenuSheetController *)menuController {
    TGViewController *controller = [self.delegate parentControllerForPresentation];
    if (controller != nil) {
        CGRect sourceRect = _stickersHeaderView.bounds;
        [TGStickersMenu presentWithParentController:controller packReference:nil stickerPack:stickerPack showShareAction:false sendSticker:nil stickerPackRemoved:nil stickerPackHidden:nil stickerPackArchived:false stickerPackIsMask:stickerPack.isMask sourceView:_stickersHeaderView sourceRect:^CGRect{
            return sourceRect;
        } centered:true existingController:menuController];
    }
}

- (void)previewMultipleStickerPacks:(NSArray<TGStickerPack *> *)stickerPacks {
    TGMenuSheetController *controller = [[TGMenuSheetController alloc] init];
    __weak TGMenuSheetController *weakController = controller;
    controller.dismissesByOutsideTap = true;
    controller.hasSwipeGesture = true;
    controller.narrowInLandscape = true;
    CGRect sourceRect = [_stickersHeaderView convertRect:_stickersHeaderView.bounds toView:self];;
    controller.sourceRect = ^CGRect { return sourceRect; };
    controller.permittedArrowDirections = 0;
    
    NSMutableArray *itemViews = [[NSMutableArray alloc] init];
    TGMultipleStickerPacksCollectionItemView *collectionItem = [[TGMultipleStickerPacksCollectionItemView alloc] init];
    [itemViews addObject:collectionItem];
    __weak TGModernGalleryImageItemView *weakSelf = self;
    collectionItem.previewPack = ^(TGStickerPack *pack, __unused id<TGStickerPackReference> packReference) {
        __strong TGMenuSheetController *strongController = weakController;
        if (strongController == nil)
            return;
        
        //[strongController dismissAnimated:true manual:true];
        
        if (pack != nil) {
            __strong TGModernGalleryImageItemView *strongSelf = weakSelf;
            if (strongSelf != nil) {
                [strongSelf previewStickerPack:pack inMenuController:strongController];
            }
        }
    };
    [collectionItem setStickerPacks:stickerPacks animated:false];
    
    collectionItem.collapseInLandscape = false;
    
    TGMenuSheetButtonItemView *cancelButton = [[TGMenuSheetButtonItemView alloc] initWithTitle:TGLocalized(@"Common.Cancel") type:TGMenuSheetButtonTypeCancel action:^
    {
        __strong TGMenuSheetController *strongController = weakController;
        if (strongController == nil)
            return;
        
        [strongController dismissAnimated:true manual:true];
    }];
    [itemViews addObject:cancelButton];
    
    [controller setItemViews:itemViews];
    
    TGViewController *parentController = [self.delegate parentControllerForPresentation];
    if (parentController != nil) {
        [controller presentInViewController:parentController sourceView:parentController.view animated:true];
    }
}

@end
