#import "TGMediaFoldersCell.h"

#import "TGMediaPickerAsset.h"
#import "TGMediaPickerAssetsGroup.h"

#import "TGFont.h"

@interface TGMediaFoldersCell ()
{
    NSArray *_assetImageViews;
    
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
        
        UIImageView *imageView2 = [[UIImageView alloc] initWithFrame:CGRectMake(12.0f, 7.0f, 61.0f, 61.0f)];
        [self.contentView addSubview:imageView2];

        UIView *strokeView1 = [[UIImageView alloc] initWithFrame:CGRectMake(9.0f, 8.0f, 67.0f, 67.0f)];
        strokeView1.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:strokeView1];
        UIImageView *imageView1 = [[UIImageView alloc] initWithFrame:CGRectMake(10.0f, 9.0f, 65.0f, 65.0f)];
        [self.contentView addSubview:imageView1];
        
        UIView *strokeView0 = [[UIImageView alloc] initWithFrame:CGRectMake(7.0f, 10.0f, 71.0f, 71.0f)];
        strokeView0.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:strokeView0];
        UIImageView *imageView0 = [[UIImageView alloc] initWithFrame:CGRectMake(8.0f, 11.0f, 69.0f, 69.0f)];
        [self.contentView addSubview:imageView0];
        
        _assetImageViews = @[imageView0, imageView1, imageView2];
        
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

- (void)setAssetsGroup:(TGMediaPickerAssetsGroup *)assetsGroup
{
    if ([assetsGroup latestAssets].count == 0)
    {
        for (NSUInteger i = 0; i < _assetImageViews.count; i++)
        {
            if (i == 0)
                ((UIImageView *)_assetImageViews[i]).image = [assetsGroup groupThumbnail];
            else
               ((UIImageView *)_assetImageViews[i]).image = nil;
        }
    }
    else
    {
        for (NSUInteger i = 0; i < _assetImageViews.count; i++)
        {
            if (i < [assetsGroup latestAssets].count)
            {
                ((UIImageView *)_assetImageViews[i]).image = [((TGMediaPickerAsset *)([assetsGroup latestAssets][i])) thumbnail];
            }
            else
                ((UIImageView *)_assetImageViews[i]).image = nil;
        }
    }
    
    _folderNameLabel.text = [assetsGroup title];
    _countLabel.text = [[NSString alloc] initWithFormat:@"%d", (int)[assetsGroup assetCount]];
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGSize titleSize = [_folderNameLabel sizeThatFits:CGSizeMake(self.frame.size.width - _folderNameLabel.frame.origin.x - 20, _folderNameLabel.frame.size.height)];
    _folderNameLabel.frame = CGRectMake(_folderNameLabel.frame.origin.x, _folderNameLabel.frame.origin.y, titleSize.width, titleSize.height);
    
    _countLabel.frame = (CGRect){_countLabel.frame.origin, [_countLabel.text sizeWithFont:_countLabel.font]};
}

@end
