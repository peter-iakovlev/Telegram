#import "TGItemCollectionGalleryItemView.h"

#import "TGTelegraph.h"
#import "MediaBox.h"

#import "TGModernGalleryZoomableScrollView.h"

#import "TGItemCollectionGalleryItem.h"

#import "TGMessage.h"

#import "TGInstantPageImageView.h"
#import "TGEmptyGalleryFooterAccessoryView.h"

@interface TGItemCollectionGalleryItemView () {
    UIView *_wrapperView;
    TGInstantPageImageView *_imageView;
    SVariable *_readyForTransitionIn;
}

@end

@implementation TGItemCollectionGalleryItemView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        _readyForTransitionIn = [[SVariable alloc] init];
        _wrapperView = [[UIView alloc] init];
        _wrapperView.clipsToBounds = true;
        [self.scrollView addSubview:_wrapperView];
    }
    return self;
}

- (SSignal *)readyForTransitionIn {
    return [_readyForTransitionIn signal];
}

- (CGSize)contentSize {
    id media = ((TGItemCollectionGalleryItem *)self.item).media.media;
    if ([media isKindOfClass:[TGImageMediaAttachment class]]) {
        return [((TGImageMediaAttachment *)media) dimensions];
    } else if ([media isKindOfClass:[TGVideoMediaAttachment class]]) {
        return [((TGVideoMediaAttachment *)media) dimensions];
    } else {
        return CGSizeZero;
    }
}

- (UIView *)contentView
{
    return _wrapperView;
}

- (UIView *)transitionView
{
    return self.containerView;
}

- (CGRect)transitionViewContentRect {
    return [_wrapperView convertRect:_wrapperView.bounds toView:[self transitionView]];
}

- (UIView *)footerView {
    return nil;
}

- (void)setItem:(id<TGModernGalleryItem>)item synchronously:(bool)synchronously {
    [super setItem:item synchronously:synchronously];
    
    TGInstantPageMedia *media = ((TGItemCollectionGalleryItem *)self.item).media;
    [_imageView removeFromSuperview];
    
    id arguments = nil;
    if ([media.media isKindOfClass:[TGVideoMediaAttachment class]]) {
        arguments = [[TGInstantPageVideoMediaArguments alloc] initWithInteractive:false autoplay:true];
    }
    
    SVariable *readyForTransitionIn = _readyForTransitionIn;
    _imageView = [[TGInstantPageImageView alloc] initWithFrame:_wrapperView.bounds media:media arguments:arguments imageUpdated:^{
        [readyForTransitionIn set:[SSignal single:@true]];
    }];
    [_wrapperView addSubview:_imageView];
    _imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [_imageView setIsVisible:true];
    
    [self forceUpdateLayout];
}

- (UIView<TGModernGalleryDefaultFooterAccessoryView> *) defaultFooterAccessoryLeftView1 {
    TGInstantPageMedia *media = ((TGItemCollectionGalleryItem *)self.item).media;
    if ([media.media isKindOfClass:[TGVideoMediaAttachment class]]) {
        return [[TGEmptyGalleryFooterAccessoryView alloc] init];
    } else {
        return nil;
    }
}

@end
