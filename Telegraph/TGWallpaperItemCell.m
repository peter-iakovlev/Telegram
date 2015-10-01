#import "TGWallpaperItemCell.h"

#import "TGWallpaperInfo.h"

#import "TGRemoteImageView.h"
#import "TGImageUtils.h"

@interface TGWallpaperItemCell ()
{
    TGRemoteImageView *_imageView;
    UIImageView *_selectedView;
}

@end

@implementation TGWallpaperItemCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        _imageView = [[TGRemoteImageView alloc] initWithFrame:self.bounds];
        _imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _imageView.fadeTransition = true;
        _imageView.clipsToBounds = true;
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:_imageView];
        
        UIImage *indicatorImage = [UIImage imageNamed:@"ModernWallpaperSelectedIndicator.png"];
        _selectedView = [[UIImageView alloc] initWithFrame:CGRectMake(frame.size.width - 5.0f - indicatorImage.size.width, frame.size.height - 4.0f - indicatorImage.size.height, indicatorImage.size.width, indicatorImage.size.height)];
        _selectedView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
        _selectedView.image = indicatorImage;
        [self addSubview:_selectedView];
    }
    return self;
}

- (void)setWallpaperInfo:(TGWallpaperInfo *)wallpaperInfo
{
    _wallpaperInfo = wallpaperInfo;
    
    static UIImage *placeholderImage = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(4.0f, 4.0f), true, 0.0f);
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
        CGContextFillRect(context, CGRectMake(0.0f, 0.0f, 4.0f, 4.0f));
        
        CGContextSetStrokeColorWithColor(context, UIColorRGB(0xd9d9d9).CGColor);
        CGContextSetLineWidth(context, 1.0f);
        //CGContextStrokeRect(context, CGRectMake(0.5f, 0.5f, 3.0f, 3.0f));
        
        placeholderImage = [UIGraphicsGetImageFromCurrentImageContext() stretchableImageWithLeftCapWidth:2 topCapHeight:2];
        UIGraphicsEndImageContext();
    });
    
    [_imageView loadImage:[wallpaperInfo thumbnailUrl] filter:nil placeholder:placeholderImage];
}

- (UIImage *)currentImage
{
    return [_imageView currentImage];
}

- (void)setIsSelected:(bool)isSelected
{
    _isSelected = isSelected;
    
    _selectedView.hidden = !isSelected;
}

@end
