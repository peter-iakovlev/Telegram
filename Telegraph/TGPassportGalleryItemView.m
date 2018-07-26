#import "TGPassportGalleryItemView.h"

#import <LegacyComponents/LegacyComponents.h>

#import "TGTelegraph.h"
#import "MediaBox.h"
#import "TGPassportFile.h"

#import "TGPassportSignals.h"

#import <LegacyComponents/TGModernGalleryZoomableScrollView.h>

#import "TGPassportGalleryItem.h"

#import "PhotoResources.h"
#import "TransformImageView.h"

#import "TGEmptyGalleryFooterAccessoryView.h"

@interface TGPassportGalleryItemView () {
    UIView *_wrapperView;
    TransformImageView *_imageView;
    TGMessageImageViewOverlayView *_progressView;
    SVariable *_readyForTransitionIn;
    
    CGSize _imageSize;
}

@end

@implementation TGPassportGalleryItemView

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

- (void)setFocused:(bool)isFocused {
    [super setFocused:isFocused];
}

- (CGSize)contentSize {
    if (_imageSize.width < FLT_EPSILON)
        return ((TGPassportGalleryItem *)self.item).contentSize;
    
    return _imageSize;
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

- (SSignal *)readyForTransitionIn {
    return [_readyForTransitionIn signal];
}

- (void)setItem:(id<TGModernGalleryItem>)item synchronously:(bool)synchronously {
    [super setItem:item synchronously:synchronously];
    
    id file = ((TGPassportGalleryItem *)self.item).file;
    [_imageView removeFromSuperview];
    
    __weak TGPassportGalleryItemView *weakSelf = self;
    _imageView = [[TransformImageView alloc] initWithFrame:_wrapperView.bounds];
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    [_imageView setArguments:[[TransformImageArguments alloc] initAutoSizeWithBoundingSize:CGSizeZero cornerRadius:0.0f]];
    _imageView.imageUpdated = ^
    {
        __strong TGPassportGalleryItemView *strongSelf = weakSelf;
        strongSelf->_imageSize = strongSelf->_imageView.imageSize;
        [strongSelf forceUpdateLayout];
        [strongSelf->_readyForTransitionIn set:[SSignal single:@true]];
    };
    [_wrapperView addSubview:_imageView];
    _imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    if ([file isKindOfClass:[TGPassportFile class]])
    {
        TGPassportFile *passportFile = (TGPassportFile *)file;
        [_imageView setSignal:secureMediaTransform(TGTelegraphInstance.mediaBox, passportFile, false)];
    }
    else if ([file isKindOfClass:[TGPassportFileUpload class]])
    {
        TGPassportFileUpload *upload = (TGPassportFileUpload *)file;
        [_imageView setSignal:[SSignal single:upload.image]];
    }
    
    [self forceUpdateLayout];
}

@end
