#import "TGMediaPickerVideoItemView.h"

#import "TGMediaPickerItem.h"

#import "TGStringUtils.h"

#import "TGImagePickerCellCheckButton.h"

#import "TGVideoEditAdjustments.h"
#import "TGModernMediaListEditableItem.h"
#import "TGEditablePhotoItem.h"

#import "TGAssetImageView.h"
#import "TGPhotoEditorUtils.h"

#import "TGFont.h"

@interface TGMediaPickerVideoItemView ()
{
    UIImageView *_iconView;
    UIImageView *_shadowView;
    UILabel *_durationLabel;
}

@property (nonatomic, strong) TGMediaPickerItem *item;

@end

@implementation TGMediaPickerVideoItemView

@dynamic item;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        self.clipsToBounds = true;
        
        static UIImage *shadowImage = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^
        {
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(24.0f, 20.0f), false, 0.0f);
            CGContextRef context = UIGraphicsGetCurrentContext();

            CGColorRef colors[2] = {
                CGColorRetain(UIColorRGBA(0x000000, 0.0f).CGColor),
                CGColorRetain(UIColorRGBA(0x000000, 0.8f).CGColor)
            };

            CFArrayRef colorsArray = CFArrayCreate(kCFAllocatorDefault, (const void **)&colors, 2, NULL);
            CGFloat locations[3] = {0.0f, 1.0f};

            CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
            CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, colorsArray, (CGFloat const *)&locations);

            CFRelease(colorsArray);
            CFRelease(colors[0]);
            CFRelease(colors[1]);

            CGColorSpaceRelease(colorSpace);

            CGContextDrawLinearGradient(context, gradient, CGPointMake(0.0f, 0.0f), CGPointMake(0.0f, 20.0f), 0);

            CFRelease(gradient);

            shadowImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        });
        
        _shadowView = [[UIImageView alloc] initWithFrame:CGRectMake(0, frame.size.height - 20, frame.size.width, 20)];
        _shadowView.image = shadowImage;
        [self addSubview:_shadowView];
        
        _iconView = [[UIImageView alloc] init];
        _iconView.contentMode = UIViewContentModeCenter;
        [self addSubview:_iconView];
        
        _durationLabel = [[UILabel alloc] init];
        _durationLabel.textColor = [UIColor whiteColor];
        _durationLabel.backgroundColor = [UIColor clearColor];
        _durationLabel.textAlignment = NSTextAlignmentRight;
        _durationLabel.font = TGSystemFontOfSize(12.0f);
        _durationLabel.text = @" ";
        [_durationLabel sizeToFit];
        [self addSubview:_durationLabel];

    }
    return self;
}

- (void)updateItem
{
    NSInteger duration = (NSInteger)[self.item.asset videoDuration];
    
    TGMediaPickerAsset *asset = self.item.asset;
    
    id<TGEditablePhotoItem> editableMediaItem = self.item.editableMediaItem;
    if (editableMediaItem.fetchEditorValues != nil)
    {
        TGVideoEditAdjustments *adjustments = editableMediaItem.fetchEditorValues(editableMediaItem);
        
        if (adjustments != nil && editableMediaItem.fetchThumbnailImage != nil)
        {
            UIImage *image = editableMediaItem.fetchThumbnailImage(editableMediaItem);
            if (image != nil)
                [self setImage:image];
            else
                [self setAsset:self.item.asset];
                        
            if (adjustments.trimStartValue > FLT_EPSILON || (adjustments.trimEndValue > adjustments.trimStartValue && adjustments.trimEndValue < duration - FLT_EPSILON))
            {
                duration = (NSInteger)(adjustments.trimEndValue - adjustments.trimStartValue);
            }
            
            [self _layoutImageForOriginalSize:adjustments.originalSize cropRect:adjustments.cropRect cropOrientation:adjustments.cropOrientation];
        }
        else
        {
            [self setAsset:self.item.asset];
            [self _layoutImageDefault];
        }
    }
    else
    {
        [self setAsset:self.item.asset];
        [self _layoutImageDefault];
    }
    
    _durationLabel.text = [[NSString alloc] initWithFormat:@"%d:%02d", (int)(duration / 60), (int)(duration % 60)];
    
    if (asset.subtypes & TGMediaPickerAssetSubtypeVideoTimelapse)
        _iconView.image = [UIImage imageNamed:@"ModernMediaItemTimelapseIcon.png"];
    else if (asset.subtypes & TGMediaPickerAssetSubtypeVideoHighFrameRate)
        _iconView.image = [UIImage imageNamed:@"ModernMediaItemSloMoIcon.png"];
    else
        _iconView.image = [UIImage imageNamed:@"ModernMediaItemVideoIcon.png"];
}

- (void)_transformLayoutForOrientation:(UIImageOrientation)orientation originalSize:(CGSize *)inOriginalSize cropRect:(CGRect *)inCropRect
{
    if (inOriginalSize == NULL || inCropRect == NULL)
        return;
    
    CGSize originalSize = *inOriginalSize;
    CGRect cropRect = *inCropRect;
    
    if (orientation == UIImageOrientationLeft)
    {
        cropRect = CGRectMake(cropRect.origin.y, originalSize.width - cropRect.size.width - cropRect.origin.x, cropRect.size.height, cropRect.size.width);
        originalSize = CGSizeMake(originalSize.height, originalSize.width);
    }
    else if (orientation == UIImageOrientationRight)
    {
        cropRect = CGRectMake(originalSize.height - cropRect.size.height - cropRect.origin.y, cropRect.origin.x, cropRect.size.height, cropRect.size.width);
        originalSize = CGSizeMake(originalSize.height, originalSize.width);
    }
    else if (orientation == UIImageOrientationDown)
    {
        cropRect = CGRectMake(originalSize.width - cropRect.size.width - cropRect.origin.x, originalSize.height - cropRect.size.height - cropRect.origin.y, cropRect.size.width, cropRect.size.height);
    }
    
    *inOriginalSize = originalSize;
    *inCropRect = cropRect;
}

- (void)_layoutImageForOriginalSize:(CGSize)originalSize cropRect:(CGRect)cropRect cropOrientation:(UIImageOrientation)cropOrientation
{
    self.imageView.transform = CGAffineTransformMakeRotation(TGRotationForOrientation(cropOrientation));
    
    [self _transformLayoutForOrientation:cropOrientation originalSize:&originalSize cropRect:&cropRect];
    
    CGFloat ratio = (cropRect.size.width > cropRect.size.height) ? self.frame.size.height / cropRect.size.height : self.frame.size.width / cropRect.size.width;
    CGSize fillSize = CGSizeMake(cropRect.size.width * ratio, cropRect.size.height * ratio);

    self.imageView.frame = CGRectMake(-cropRect.origin.x * ratio + (self.frame.size.width - fillSize.width) / 2, -cropRect.origin.y * ratio + (self.frame.size.height - fillSize.height) / 2, originalSize.width * ratio, originalSize.height * ratio);
}

- (void)_layoutImageDefault
{
    self.imageView.transform = CGAffineTransformIdentity;
    self.imageView.frame = self.bounds;
}

- (UIImage *)transitionImage
{
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, true, 0.0f);
    
    UIImage *image = self.imageView.image;
    
    CGSize originalSize = CGSizeZero;
    CGRect cropRect = CGRectZero;
    UIImageOrientation cropOrientation = UIImageOrientationUp;
    
    id<TGEditablePhotoItem> editableMediaItem = self.item.editableMediaItem;
    if (editableMediaItem.fetchEditorValues != nil)
    {
        TGVideoEditAdjustments *adjustments = editableMediaItem.fetchEditorValues(editableMediaItem);
        
        if (adjustments != nil && editableMediaItem.fetchThumbnailImage != nil)
        {
            originalSize = adjustments.originalSize;
            cropRect = adjustments.cropRect;
            cropOrientation = adjustments.cropOrientation;
            
            UIImage *editedImage = editableMediaItem.fetchThumbnailImage(editableMediaItem);
            if (editedImage != nil)
                image = editedImage;
        }
    }
    
    CGSize fillSize = TGScaleToFillSize(image.size, self.bounds.size);
    if (CGRectEqualToRect(cropRect, CGRectZero))
    {
        [image drawInRect:CGRectMake((self.bounds.size.width - fillSize.width) / 2, (self.bounds.size.height - fillSize.height) / 2, fillSize.width, fillSize.height)];
    }
    else
    {
        CGContextConcatCTM(UIGraphicsGetCurrentContext(), TGVideoCropTransformForOrientation(cropOrientation, self.frame.size, false));
        
        CGFloat ratio = (cropRect.size.width > cropRect.size.height) ? self.frame.size.height / cropRect.size.height : self.frame.size.width / cropRect.size.width;
        CGSize fillSize = CGSizeMake(cropRect.size.width * ratio, cropRect.size.height * ratio);
        
        [image drawInRect:CGRectMake(-cropRect.origin.x * ratio + (self.frame.size.width - fillSize.width) / 2, -cropRect.origin.y * ratio + (self.frame.size.height - fillSize.height) / 2, originalSize.width * ratio, originalSize.height * ratio)];
    }
    
    UIImage *transitionImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return transitionImage;
}

- (void)updateHiddenAnimated:(bool)animated
{
    if (_isItemHidden)
    {
        bool hidden = _isItemHidden(self.item);
        if (hidden != self.imageView.hidden)
        {
            self.imageView.hidden = hidden;
            
            if (animated)
            {
                if (!hidden)
                {
                    _checkButton.alpha = 0.0f;
                    _iconView.alpha = 0.0f;
                    _shadowView.alpha = 0.0f;
                    _durationLabel.alpha = 0.0f;
                }
                [UIView animateWithDuration:0.2 animations:^
                {
                    if (!hidden)
                    {
                        _checkButton.alpha = 1.0f;
                        _iconView.alpha = 1.0f;
                        _shadowView.alpha = 1.0f;
                        _durationLabel.alpha = 1.0f;
                    }
                }];
            }
            else
            {
                self.imageView.hidden = hidden;
                _checkButton.alpha = hidden ? 0.0f : 1.0f;
                _iconView.alpha = hidden ? 0.0f : 1.0f;
                _shadowView.alpha = hidden ? 0.0f : 1.0f;
                _durationLabel.alpha = hidden ? 0.0f : 1.0f;
            }
        }
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _shadowView.frame = (CGRect){{0.0f, self.frame.size.height - _shadowView.frame.size.height}, {self.frame.size.width, _shadowView.frame.size.height}};
    _iconView.frame = CGRectMake(0, self.frame.size.height - 19, 19, 19);
    _durationLabel.frame = (CGRect){{5.0f, _shadowView.frame.origin.y + CGFloor((_shadowView.frame.size.height - _durationLabel.frame.size.height) / 2.0f)}, {self.frame.size.width - 5.0f - 4.0f, _shadowView.frame.size.height}};
}

@end
