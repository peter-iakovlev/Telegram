#import "TGWebSearchResultsGalleryImageItemView.h"
#import "TGModernGalleryImageItemImageView.h"

#import "TGWebSearchResultsGalleryImageItem.h"
#import "TGWebSearchResultsGalleryInternalImageItem.h"

#import "TGImageUtils.h"
#import "TGPhotoEditorUtils.h"

#import "TGWebSearchResult.h"
#import "PGPhotoEditorValues.h"

#import "TGBingSearchResultItem+TGMediaItem.h"
#import "TGWebSearchInternalImageResult+TGMediaItem.h"

@interface TGWebSearchResultsGalleryImageItemView ()
{
    UIView *_temporaryRepView;
}
@end

@implementation TGWebSearchResultsGalleryImageItemView

- (void)setHiddenAsBeingEdited:(bool)hidden
{
    self.imageView.hidden = hidden;
}

- (void)setItem:(id<TGModernGalleryItem>)item synchronously:(bool)synchronously
{
    if (item == nil)
    {
        [self.imageView setSignal:nil];
        [super setItem:item synchronously:synchronously];
    }
    else if ([item isKindOfClass:[TGWebSearchResultsGalleryImageItem class]] || [item isKindOfClass:[TGWebSearchResultsGalleryInternalImageItem class]])
    {
        _item = item;
        
        id<TGModernGalleryEditableItem> editableItem = (id<TGModernGalleryEditableItem>)item;
        self.imageSize = TGFitSize(editableItem.editableMediaItem.originalSize, CGSizeMake(1600, 1600));
        
        __weak TGWebSearchResultsGalleryImageItemView *weakSelf = self;
        void (^fadeOutRepView)(void) = ^
        {
            __strong TGWebSearchResultsGalleryImageItemView *strongSelf = weakSelf;
            if (strongSelf == nil)
                return;
            
            if (strongSelf->_temporaryRepView == nil)
                return;
            
            UIView *repView = strongSelf->_temporaryRepView;
            strongSelf->_temporaryRepView = nil;
            [UIView animateWithDuration:0.2f animations:^
            {
                repView.alpha = 0.0f;
            } completion:^(__unused BOOL finished)
            {
                [repView removeFromSuperview];
            }];
        };
        
        SSignal *imageSignal = [[editableItem.editingContext imageSignalForItem:editableItem.editableMediaItem] mapToSignal:^SSignal *(id result)
        {
            __strong TGWebSearchResultsGalleryImageItemView *strongSelf = weakSelf;
            if (strongSelf == nil)
                return [SSignal complete];
            
            if ([result isKindOfClass:[UIImage class]] || [result isKindOfClass:[NSNumber class]])
            {
                return [[[SSignal single:result] deliverOn:[SQueue mainQueue]] afterNext:^(__unused id next)
                {
                    fadeOutRepView();
                }];
            }
            else if ([result isKindOfClass:[UIView class]])
            {
                [strongSelf _setTemporaryRepView:result];
                return [[SSignal single:nil] deliverOn:[SQueue mainQueue]];
            }
            else
            {
                return [[editableItem.editableMediaItem originalImageSignal:0] afterNext:^(__unused id next)
                {
                    fadeOutRepView();
                }];
            }
            
            return [SSignal complete];
        }];
        
        
        [self.imageView setSignal:[[imageSignal deliverOn:[SQueue mainQueue]] afterNext:^(id next)
        {
            __strong TGWebSearchResultsGalleryImageItemView *strongSelf = weakSelf;
            if (strongSelf == nil)
                return;
            
            if ([next isKindOfClass:[UIImage class]])
                strongSelf.imageSize = ((UIImage *)next).size;
            
            [strongSelf reset];
        }]];

        [self reset];
    }
}

- (void)_setTemporaryRepView:(UIView *)view
{
    [_temporaryRepView removeFromSuperview];
    _temporaryRepView = view;
    
    self.imageSize = TGScaleToSize(view.frame.size, self.containerView.frame.size);
    
    view.hidden = self.imageView.hidden;
    view.frame = CGRectMake((self.containerView.frame.size.width - self.imageSize.width) / 2.0f, (self.containerView.frame.size.height - self.imageSize.height) / 2.0f, self.imageSize.width, self.imageSize.height);
    
    [self.containerView addSubview:view];
}

- (void)singleTap
{
    if ([self.item conformsToProtocol:@protocol(TGModernGallerySelectableItem)])
    {
        id<TGModernGallerySelectableItem> item = (id<TGModernGallerySelectableItem>)self.item;
        [item.selectionContext setItem:item.selectableMediaItem selected:true];
    }
    else
    {
        id<TGModernGalleryItemViewDelegate> delegate = self.delegate;
        if ([delegate respondsToSelector:@selector(itemViewDidRequestInterfaceShowHide:)])
            [delegate itemViewDidRequestInterfaceShowHide:self];
    }
}

- (UIView *)contentView
{
    return self.imageView;
}

- (UIView *)transitionContentView
{
    if (_temporaryRepView != nil)
        return _temporaryRepView;
    
    return [self contentView];
}

- (CGRect)transitionViewContentRect
{
    UIView *contentView = [self transitionContentView];
    return [contentView convertRect:contentView.bounds toView:[self transitionView]];
}

@end
