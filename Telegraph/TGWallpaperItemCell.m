#import "TGWallpaperItemCell.h"

#import <LegacyComponents/LegacyComponents.h>
#import <LegacyComponents/TGWallpaperInfo.h>
#import <LegacyComponents/TGRemoteImageView.h>
#import <LegacyComponents/TGCheckButtonView.h>
#import <LegacyComponents/TGColorWallpaperInfo.h>

#import "TGPresentation.h"

@interface TGWallpaperItemCell ()
{
    TGRemoteImageView *_imageView;
    TGCheckButtonView *_checkView;
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
    }
    return self;
}

- (void)setWallpaperInfo:(TGWallpaperInfo *)wallpaperInfo
{
    _wallpaperInfo = wallpaperInfo;
    [_imageView loadImage:[wallpaperInfo thumbnailUrl] filter:nil placeholder:self.presentation.images.placeholderImage];
    
    if ([wallpaperInfo isKindOfClass:[TGColorWallpaperInfo class]] && ((TGColorWallpaperInfo *)wallpaperInfo).color == TGColorHexCode([UIColor whiteColor]))
    {
        self.layer.borderWidth = TGScreenPixel;
        self.layer.borderColor = UIColorRGB(0xc7c7cc).CGColor;
    }
    else
    {
        self.layer.borderWidth = 0.0f;
        self.layer.borderColor = NULL;
    }
}

- (UIImage *)currentImage
{
    return [_imageView currentImage];
}

- (void)setIsSelected:(bool)isSelected
{
    _isSelected = isSelected;
    
    if (_checkView == nil)
    {
        _checkView = [[TGCheckButtonView alloc] initWithStyle:TGCheckButtonStyleMedia];
        _checkView.frame = CGRectMake(self.frame.size.width - 3.0f - _checkView.frame.size.width, self.frame.size.height - 3.0f - _checkView.frame.size.height, _checkView.frame.size.width, _checkView.frame.size.height);
        [_checkView setSelected:true animated:false];
        _checkView.userInteractionEnabled = false;
        [self addSubview:_checkView];
    }
    _checkView.hidden = !isSelected;
}

@end
