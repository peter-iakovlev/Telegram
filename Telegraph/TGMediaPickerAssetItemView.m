#import "TGMediaPickerAssetItemView.h"

#import "TGMediaPickerItem.h"

#import "TGPhotoEditorUtils.h"
#import "TGAssetImageView.h"

#import "TGImagePickerCellCheckButton.h"

#import "TGModernGalleryTransitionView.h"

@interface TGMediaPickerAssetItemView () <TGModernGalleryTransitionView>

@end

@implementation TGMediaPickerAssetItemView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        _imageView = [[TGAssetImageView alloc] initWithFrame:(CGRect){CGPointZero, frame.size}];
        _imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = true;
        [self addSubview:_imageView];
    }
    return self;
}

- (void)setItem:(TGMediaPickerItem *)item synchronously:(bool)synchronously
{
    [super setItem:item synchronously:synchronously];
    
    _changeItemSelection = [item.itemSelected copy];
    _isItemSelected = [item.isItemSelected copy];
    _isItemHidden = [item.isItemHidden copy];
    
    [self updateSelectionAnimated:false];
    [self updateHiddenAnimated:false];
    
    [self updateItem];
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    CGAffineTransform transform = _imageView.transform;
    _imageView.transform = CGAffineTransformIdentity;
    _imageView.frame = (CGRect){CGPointZero, frame.size};
    _imageView.transform = transform;
}

- (void)setImage:(UIImage *)image
{
    [_imageView reset];
    [_imageView loadWithImage:image];
}

- (void)setAsset:(TGMediaPickerAsset *)asset
{
    CGFloat thumbnailImageSide = TGPhotoThumbnailSizeForCurrentScreen().width * [UIScreen mainScreen].scale;
    [_imageView loadWithAsset:asset imageType:TGAssetImageTypeThumbnail size:CGSizeMake(thumbnailImageSide, thumbnailImageSide)];
}

- (void)updateHiddenAnimated:(bool)__unused animated
{
    
}

- (void)updateSelectionAnimated:(bool)animated
{
    if (_isItemSelected != nil)
    {
        if (_checkButton == nil)
        {
            _checkButton = [[TGImagePickerCellCheckButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 33.0f, 33.0f)];
            [_checkButton setChecked:false animated:false];
            [_checkButton addTarget:self action:@selector(checkButtonPressed) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:_checkButton];
        }
        [_checkButton setChecked:_isItemSelected(self.item) animated:animated];
    }
}

- (void)checkButtonPressed
{
    if (_isItemSelected != nil && _changeItemSelection != nil)
    {
        _changeItemSelection(self.item, false);
        [_checkButton setChecked:_isItemSelected(self.item) animated:true];
    }
}

- (void)prepareForReuse
{
    [_imageView reset];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _checkButton.frame = (CGRect){{self.frame.size.width - _checkButton.frame.size.width - 2.0f, 2.0f}, _checkButton.frame.size};
}

- (UIImage *)transitionImage
{
    if (ABS(self.imageView.image.size.width - self.imageView.image.size.height) > FLT_EPSILON)
    {
        CGFloat scale = 1.0f;
        CGSize scaledBoundsSize = CGSizeZero;
        CGSize scaledImageSize = CGSizeZero;
        
        if (self.imageView.image.size.width > self.imageView.image.size.height)
        {
            scale = self.frame.size.height / self.imageView.image.size.height;
            scaledBoundsSize = CGSizeMake(self.frame.size.width / scale, self.imageView.image.size.height);
            
            scaledImageSize = CGSizeMake(self.imageView.image.size.width * scale, self.imageView.image.size.height * scale);
            
            if (scaledImageSize.width < self.frame.size.width)
            {
                scale = self.frame.size.width / self.imageView.image.size.width;
                scaledBoundsSize = CGSizeMake(self.imageView.image.size.width, self.frame.size.height / scale);
            }
        }
        else
        {
            scale = self.frame.size.width / self.imageView.image.size.width;
            scaledBoundsSize = CGSizeMake(self.imageView.image.size.width, self.frame.size.height / scale);
            
            scaledImageSize = CGSizeMake(self.imageView.image.size.width * scale, self.imageView.image.size.height * scale);
            
            if (scaledImageSize.width < self.frame.size.width)
            {
                scale = self.frame.size.height / self.imageView.image.size.height;
                scaledBoundsSize = CGSizeMake(self.frame.size.width / scale, self.imageView.image.size.height);
            }
        }
        
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(self.frame.size.width, self.frame.size.height), true, 0.0f);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextScaleCTM(context, scale, scale);
        [self.imageView.image drawInRect:CGRectMake((scaledBoundsSize.width - self.imageView.image.size.width) / 2,
                                                    (scaledBoundsSize.height - self.imageView.image.size.height) / 2,
                                                    self.imageView.image.size.width,
                                                    self.imageView.image.size.height)];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return image;
    }
    
    return self.imageView.image;
}

@end
