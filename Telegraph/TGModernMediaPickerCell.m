#import "TGModernMediaPickerCell.h"

#import "TGMediaPickerAsset.h"

#import "TGImageView.h"
#import "TGFont.h"

@interface TGModernMediaPickerCell ()
{
    TGImageView *_imageView;
    UIImageView *_shadowView;
    UILabel *_durationLabel;
}

@end

@implementation TGModernMediaPickerCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        _imageView = [[TGImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:_imageView];
        
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
            
            UIImage *videoIcon = [UIImage imageNamed:@"ModernMediaItemVideoIcon.png"];
            [videoIcon drawAtPoint:CGPointMake(5.0f, 20.0f - 5.0f - videoIcon.size.height)];
            
            shadowImage = [UIGraphicsGetImageFromCurrentImageContext() stretchableImageWithLeftCapWidth:23.0f topCapHeight:0.0f];
            UIGraphicsEndImageContext();
        });
        
        _shadowView = [[UIImageView alloc] initWithImage:shadowImage];
        [self.contentView addSubview:_shadowView];
        
        _durationLabel = [[UILabel alloc] init];
        _durationLabel.textColor = [UIColor whiteColor];
        _durationLabel.backgroundColor = [UIColor clearColor];
        _durationLabel.textAlignment = NSTextAlignmentRight;
        _durationLabel.font = TGSystemFontOfSize(12.0f);
        _durationLabel.text = @" ";
        [_durationLabel sizeToFit];
        [self.contentView addSubview:_durationLabel];
    }
    return self;
}

- (void)setAsset:(TGMediaPickerAsset *)asset
{
    _asset = asset;
    
    UIImage *image = [asset thumbnail];
    if (image != nil)
        [_imageView loadUri:@"embedded://" withOptions:@{TGImageViewOptionEmbeddedImage: image}];
    else
        [_imageView reset];
    
    if ([asset isVideo])
    {
        _shadowView.hidden = false;
        
        _durationLabel.hidden = false;
        int duration = (int)[asset videoDuration];
        _durationLabel.text = [[NSString alloc] initWithFormat:@"%d:%02d", duration / 60, duration % 60];
    }
    else
    {
        _shadowView.hidden = true;
        _durationLabel.hidden = true;
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _imageView.frame = self.contentView.bounds;
    _shadowView.frame = (CGRect){{0.0f, self.contentView.bounds.size.height - _shadowView.frame.size.height}, {self.contentView.frame.size.width, _shadowView.frame.size.height}};
    _durationLabel.frame = (CGRect){{5.0f, _shadowView.frame.origin.y + CGFloor((_shadowView.frame.size.height - _durationLabel.frame.size.height) / 2.0f) - 2.0f}, {self.contentView.frame.size.width - 5.0f - 4.0f, _shadowView.frame.size.height}};
}

@end
