#import "TGMediaFoldersCell.h"

#import "TGMediaPickerAsset.h"
#import "TGMediaPickerAssetsGroup.h"

#import "TGAssetImageView.h"

#import "TGFont.h"

#import <AssetsLibrary/AssetsLibrary.h>

@interface TGMediaFoldersCell ()
{
    NSArray *_assetImageViews;
    
    UIImageView *_shadowView;
    UIImageView *_iconView;
    
    UILabel *_folderNameLabel;
    UILabel *_countLabel;
}

@end

@implementation TGMediaFoldersCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        UIView *selectedBackgroundView = [[UIView alloc] init];
        selectedBackgroundView.backgroundColor = TGSelectionColor();
        self.selectedBackgroundView = selectedBackgroundView;
        
        UIView *strokeView2 = [[UIImageView alloc] initWithFrame:CGRectMake(11.0f, 6.0f, 63.0f, 63.0f)];
        strokeView2.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:strokeView2];
        
        TGAssetImageView *imageView2 = [[TGAssetImageView alloc] initWithFrame:CGRectMake(12.0f, 7.0f, 61.0f, 61.0f)];
        imageView2.backgroundColor = UIColorRGB(0xefeff4);
        imageView2.clipsToBounds = YES;
        imageView2.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:imageView2];

        UIView *strokeView1 = [[UIImageView alloc] initWithFrame:CGRectMake(9.0f, 8.0f, 67.0f, 67.0f)];
        strokeView1.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:strokeView1];
        TGAssetImageView *imageView1 = [[TGAssetImageView alloc] initWithFrame:CGRectMake(10.0f, 9.0f, 65.0f, 65.0f)];
        imageView1.backgroundColor = UIColorRGB(0xefeff4);
        imageView1.clipsToBounds = YES;
        imageView1.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:imageView1];
        
        UIView *strokeView0 = [[UIImageView alloc] initWithFrame:CGRectMake(7.0f, 10.0f, 71.0f, 71.0f)];
        strokeView0.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:strokeView0];
        TGAssetImageView *imageView0 = [[TGAssetImageView alloc] initWithFrame:CGRectMake(8.0f, 11.0f, 69.0f, 69.0f)];
        imageView0.backgroundColor = UIColorRGB(0xefeff4);
        imageView0.clipsToBounds = YES;
        imageView0.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:imageView0];
        
        _assetImageViews = @[imageView0, imageView1, imageView2];
        
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
        
        _shadowView = [[UIImageView alloc] initWithFrame:CGRectMake(imageView0.frame.origin.x, imageView0.frame.origin.y + imageView0.frame.size.height - 20, imageView0.frame.size.width, 20)];
        _shadowView.image = shadowImage;
        [self addSubview:_shadowView];
        
        _iconView = [[UIImageView alloc] init];
        _iconView.contentMode = UIViewContentModeCenter;
        [self addSubview:_iconView];
        
        _folderNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(96, 24, 0, 0)];
        _folderNameLabel.contentMode = UIViewContentModeLeft;
        _folderNameLabel.font = TGSystemFontOfSize(17);
        _folderNameLabel.backgroundColor = [UIColor clearColor];
        _folderNameLabel.textColor = [UIColor blackColor];
        [self.contentView addSubview:_folderNameLabel];
        
        _countLabel = [[UILabel alloc] initWithFrame:CGRectMake(96, 49, 0, 0)];
        _countLabel.contentMode = UIViewContentModeLeft;
        _countLabel.font = TGSystemFontOfSize(13);
        _countLabel.backgroundColor = [UIColor clearColor];
        _countLabel.textColor = [UIColor blackColor];
        [self.contentView addSubview:_countLabel];
        
        UIImageView *disclosureIndicator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MenuDisclosureIndicator.png"]];
        disclosureIndicator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        disclosureIndicator.frame = CGRectOffset(disclosureIndicator.frame, self.contentView.frame.size.width - disclosureIndicator.frame.size.width - 15, 37);
        [self.contentView addSubview:disclosureIndicator];
    }
    return self;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    for (NSUInteger i = 0; i < _assetImageViews.count; i++)
        [((TGImageView *)_assetImageViews[i]) reset];
}

- (void)setAssetsGroup:(TGMediaPickerAssetsGroup *)assetsGroup
{
    if ([assetsGroup latestAssets].count == 0)
    {
        for (NSUInteger i = 0; i < _assetImageViews.count; i++)
            [((TGImageView *)_assetImageViews[i]) reset];
        
        [(TGAssetImageView *)_assetImageViews.firstObject setImage:[UIImage imageNamed:@"ModernMediaEmptyAlbumIcon.png"]];
        
        _shadowView.hidden = true;
        _iconView.hidden = true;
    }
    else
    {
        for (NSUInteger i = 0; i < _assetImageViews.count; i++)
        {
            if (i < [assetsGroup latestAssets].count)
            {
                [((TGAssetImageView *)_assetImageViews[i]) loadWithAsset:(TGMediaPickerAsset *)[assetsGroup latestAssets][i] imageType:TGAssetImageTypeThumbnail size:CGSizeMake(138, 138)];
            }
            else
            {
                [((TGAssetImageView *)_assetImageViews[i]) reset];
            }
        }
        
        TGMediaPickerAsset *latestAsset = assetsGroup.latestAssets.firstObject;
        
        if (latestAsset.type == TGMediaPickerAssetVideoType)
        {
            _shadowView.hidden = false;
            _iconView.hidden = false;
            
            if (latestAsset.subtypes & TGMediaPickerAssetSubtypeVideoTimelapse)
                _iconView.image = [UIImage imageNamed:@"ModernMediaItemTimelapseIcon.png"];
            else if (latestAsset.subtypes & TGMediaPickerAssetSubtypeVideoHighFrameRate)
                _iconView.image = [UIImage imageNamed:@"ModernMediaItemSloMoIcon.png"];
            else
                _iconView.image = [UIImage imageNamed:@"ModernMediaItemVideoIcon.png"];
        }
        else
        {
            _shadowView.hidden = true;
            _iconView.hidden = true;
        }
    }
    
    _folderNameLabel.text = [assetsGroup title];
    _countLabel.text = [[NSString alloc] initWithFormat:@"%d", (int)[assetsGroup assetCount]];
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _iconView.frame = CGRectMake(8, self.frame.size.height - 25, 19, 19);
    
    CGSize titleSize = [_folderNameLabel sizeThatFits:CGSizeMake(self.frame.size.width - _folderNameLabel.frame.origin.x - 20, _folderNameLabel.frame.size.height)];
    _folderNameLabel.frame = CGRectMake(_folderNameLabel.frame.origin.x, _folderNameLabel.frame.origin.y, titleSize.width, titleSize.height);
    
    _countLabel.frame = (CGRect){_countLabel.frame.origin, [_countLabel.text sizeWithFont:_countLabel.font]};
}

@end
