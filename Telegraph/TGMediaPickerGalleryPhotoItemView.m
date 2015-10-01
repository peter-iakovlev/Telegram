#import "TGMediaPickerGalleryPhotoItemView.h"

#import "TGFont.h"
#import "TGStringUtils.h"

#import "TGModernGalleryZoomableScrollView.h"

#import "TGMediaPickerGalleryPhotoItem.h"

#import "TGMediaPickerAsset+TGEditablePhotoItem.h"

#import "TGMessageImageViewOverlayView.h"

#import "TGAssetImageView.h"

@interface TGMediaPickerGalleryPhotoItemView ()
{
    UILabel *_fileInfoLabel;
    
    TGMessageImageViewOverlayView *_progressView;
    bool _progressVisible;
    
    NSUInteger _attributesRequestToken;
    volatile NSInteger _attributesVersion;
}
@end

@implementation TGMediaPickerGalleryPhotoItemView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        _imageView = [[TGAssetImageView alloc] init];
        [self.scrollView addSubview:_imageView];
        
        _fileInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 20)];
        _fileInfoLabel.backgroundColor = [UIColor clearColor];
        _fileInfoLabel.font = TGSystemFontOfSize(13);
        _fileInfoLabel.textAlignment = NSTextAlignmentCenter;
        _fileInfoLabel.textColor = [UIColor whiteColor];
    }
    return self;
}

- (void)setHiddenAsBeingEdited:(bool)hidden
{
    _imageView.hidden = hidden;
}

- (void)prepareForRecycle
{
    _imageView.hidden = false;
    [_imageView reset];
    [self setProgressVisible:false value:0.0f animated:false];
}

- (void)setItem:(TGMediaPickerGalleryPhotoItem *)item synchronously:(bool)synchronously
{
    [super setItem:item synchronously:synchronously];
    
    _imageSize = item.asset.dimensions;
    [self reset];
    
    if (item.asset == nil)
    {
        [_imageView reset];
    }
    else
    {
        if (item.immediateThumbnailImage != nil)
            _imageView.image = item.immediateThumbnailImage;
        
        id<TGEditablePhotoItem> editableMediaItem = [item editableMediaItem];
        PGPhotoEditorValues *editorValues = nil;
        if (editableMediaItem.fetchEditorValues != nil)
            editorValues = (PGPhotoEditorValues *)editableMediaItem.fetchEditorValues(editableMediaItem);
        
        if (editorValues != nil)
        {
            UIImage *image = editableMediaItem.fetchScreenImage(editableMediaItem);
            [_imageView loadWithImage:image];
            _imageSize = image.size;
            [self reset];
        }
        else
        {
            if (_imageView.image == nil)
                [_imageView loadWithAsset:item.asset imageType:TGAssetImageTypeAspectRatioThumbnail size:CGSizeZero];
            
            __weak TGMediaPickerGalleryPhotoItemView *weakSelf = self;
            [_imageView loadWithAsset:item.asset imageType:TGAssetImageTypeScreen size:CGSizeMake(1280, 1280) completionBlock:^(UIImage *result)
            {
                __strong TGMediaPickerGalleryPhotoItemView *strongSelf = weakSelf;
                if (strongSelf == nil)
                    return;
                
                strongSelf->_imageSize = result.size;
                [strongSelf reset];
            }];
        }
        
        if (_attributesRequestToken != 0)
        {
            [TGAssetImageManager cancelRequestWithToken:_attributesRequestToken];
            _attributesRequestToken = 0;
        }
        
        _attributesVersion++;
        NSInteger version = _attributesVersion;
        
        __weak TGMediaPickerGalleryPhotoItemView *weakSelf = self;
        _attributesRequestToken = [TGAssetImageManager requestFileAttributesForAsset:item.asset completion:^(NSString *fileName, __unused NSString *dataUTI, CGSize dimensions, NSUInteger fileSize)
        {
            __strong TGMediaPickerGalleryPhotoItemView *strongSelf = weakSelf;
            if (strongSelf == nil)
                return;
            
            if (version == strongSelf->_attributesVersion)
            {
                NSString *extension = [fileName.pathExtension uppercaseString];
                strongSelf->_fileInfoLabel.text = [[NSString alloc] initWithFormat:@"%@ • %@ • %dx%d", extension, [TGStringUtils stringForFileSize:fileSize precision:2], (int)dimensions.width, (int)dimensions.height];
                strongSelf->_attributesRequestToken = 0;
            }
        }];
    }
}

- (void)setProgressVisible:(bool)progressVisible value:(float)value animated:(bool)animated
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

- (void)singleTap
{
    if ([self.item conformsToProtocol:@protocol(TGModernGallerySelectableItem)])
    {
        id<TGModernGallerySelectableItem> item = (id<TGModernGallerySelectableItem>)self.item;
        
        if (item.itemSelected != nil)
            item.itemSelected(item);
    }
    else
    {
        id<TGModernGalleryItemViewDelegate> delegate = self.delegate;
        if ([delegate respondsToSelector:@selector(itemViewDidRequestInterfaceShowHide:)])
            [delegate itemViewDidRequestInterfaceShowHide:self];
    }
}

- (UIView *)footerView
{
    if (((TGMediaPickerGalleryItem *)self.item).asFile)
        return _fileInfoLabel;
    
    return nil;
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

@end
