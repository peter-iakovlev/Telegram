#import "TGWallpapersCollectionItemView.h"

#import "TGImageUtils.h"
#import "TGFont.h"
#import "TGRemoteImageView.h"

#import "TGWallpaperInfo.h"

@interface TGWallpapersCollectionItemView ()
{
    UILabel *_titleLabel;
    UIImageView *_disclosureIndicator;
    
    NSMutableArray *_imageViews;
    NSArray *_wallpaperInfos;
    
    bool _syncLoad;
    
    TGWallpaperInfo *_selectedWallpaperInfo;
}

@end

@implementation TGWallpapersCollectionItemView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = TGSystemFontOfSize(17);
        [self addSubview:_titleLabel];
        
        _disclosureIndicator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ModernListsDisclosureIndicator.png"]];
        [self addSubview:_disclosureIndicator];
        
        _imageViews = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)setTitle:(NSString *)title
{
    _titleLabel.text = title;
}

- (void)setSelectedWallpaperInfo:(TGWallpaperInfo *)selectedWallpaperInfo
{
    _selectedWallpaperInfo = selectedWallpaperInfo;
    
    for (int i = 0; i < (int)_wallpaperInfos.count && i < (int)_imageViews.count; i++)
    {
        UIControl *imageContainer = [_imageViews objectAtIndex:i];
        TGRemoteImageView *imageView = imageContainer.subviews.firstObject;
        [imageView viewWithTag:100].hidden = ![_wallpaperInfos[i] isEqual:_selectedWallpaperInfo];
    }
}

- (void)setWallpaperInfos:(NSArray *)wallpaperInfos synchronous:(bool)synchronous
{
    _wallpaperInfos = wallpaperInfos;
    
    if (synchronous)
    {
        _syncLoad = true;
        [self layoutSubviews];
        _syncLoad = false;
    }
    else
        [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect bounds = self.bounds;
    
    _titleLabel.frame = CGRectMake(15, bounds.size.height - 26 - 9, bounds.size.width - 15 - 40, 26);
    _disclosureIndicator.frame = CGRectMake(bounds.size.width - _disclosureIndicator.frame.size.width - 15, bounds.size.height - 29, _disclosureIndicator.frame.size.width, _disclosureIndicator.frame.size.height);
    
    CGSize imageSize = CGSizeMake(91.0f, 162.0f);
    
    if (TGIsPad())
    {
        if (bounds.size.width > 320.0f + FLT_EPSILON)
            imageSize = CGSizeMake(110.0f, 146.0f);
        else
            imageSize = CGSizeMake(91.0f, 121.0f);
    }
    else
    {
        CGSize screenSize = TGScreenSize();
        CGFloat widescreenWidth = MAX(screenSize.width, screenSize.height);
        
        if ([UIScreen mainScreen].scale >= 2.0f - FLT_EPSILON)
        {
            if (widescreenWidth >= 736.0f - FLT_EPSILON)
            {
                imageSize = CGSizeMake(122.0f, 216.0f);
            }
            else if (widescreenWidth >= 667.0f - FLT_EPSILON)
            {
                imageSize = CGSizeMake(108.0f, 163.0f);
            }
            else
            {
                imageSize = CGSizeMake(91.0f, 162.0f);
            }
        }
        else
        {
            imageSize = CGSizeMake(91.0f, 162.0f);
        }
    }
    
    CGFloat padding = 15.0f;
    CGFloat minSpacing = 7.0f;
    
    int imageCount = (int)((bounds.size.width - padding * 2.0f + minSpacing) / (imageSize.width + minSpacing));
    CGFloat spacing = CGFloor((bounds.size.width - padding * 2.0f - imageCount * imageSize.width) / (imageCount - 1));
    
    for (int i = 0; i < imageCount && i < (int)_wallpaperInfos.count; i++)
    {
        UIControl *imageViewContainer = nil;
        TGRemoteImageView *imageView = nil;
        
        if (i >= (int)_imageViews.count)
        {
            imageView = [[TGRemoteImageView alloc] init];
            imageView.fadeTransition = true;
            imageView.fadeTransitionDuration = 0.2;
            imageView.clipsToBounds = true;
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            
            imageViewContainer = [[UIButton alloc] init];
            imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            [imageViewContainer addSubview:imageView];
            
            UIImageView *checkView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ModernWallpaperSelectedIndicator.png"]];
            checkView.frame = CGRectOffset(checkView.frame, imageView.frame.size.width - 5.0f - checkView.frame.size.width, imageView.frame.size.height - 4.0f - checkView.frame.size.height);
            checkView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
            checkView.tag = 100;
            [imageView addSubview:checkView];
            
            [self addSubview:imageViewContainer];
            [_imageViews addObject:imageViewContainer];
            
            [imageViewContainer addTarget:self action:@selector(imageViewTapped:) forControlEvents:UIControlEventTouchUpInside];
        }
        else
        {
            imageViewContainer = _imageViews[i];
            imageView = [imageViewContainer.subviews firstObject];
        }
        
        imageView.contentHints = _syncLoad ? TGRemoteImageContentHintLoadFromDiskSynchronously : 0;
        
        imageViewContainer.hidden = false;
        
        imageViewContainer.frame = CGRectMake((i == imageCount - 1 && _wallpaperInfos.count >= 3) ? (bounds.size.width - padding - imageSize.width) : (padding + i * (imageSize.width + spacing)), 15, imageSize.width, imageSize.height);
        
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
        
        NSString *url = [(TGWallpaperInfo *)_wallpaperInfos[i] thumbnailUrl];
        if (!TGStringCompare([imageView currentUrl], url))
            [imageView loadImage:url filter:nil placeholder:placeholderImage];
        
        [imageView viewWithTag:100].hidden = ![_wallpaperInfos[i] isEqual:_selectedWallpaperInfo];
    }
    
    for (int i = imageCount; i < (int)_imageViews.count; i++)
    {
        UIControl *imageViewContainer = _imageViews[i];
        TGRemoteImageView *imageView = [imageViewContainer.subviews firstObject];
        
        [imageView loadImage:nil];
        imageViewContainer.hidden = true;
    }
}

- (void)imageViewTapped:(UIControl *)imageViewContainer
{
    int index = -1;
    
    for (UIControl *view in _imageViews)
    {
        index++;
        if (view == imageViewContainer)
        {
            if (index < (int)_wallpaperInfos.count)
            {
                [_itemHandle requestAction:@"wallpaperImagePressed" options:@{@"wallpaperInfo": _wallpaperInfos[index]}];
            }
            
            break;
        }
    }
}

@end
