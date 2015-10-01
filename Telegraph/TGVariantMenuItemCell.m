#import "TGVariantMenuItemCell.h"

#import "TGInterfaceAssets.h"

#import "TGImageUtils.h"

@interface TGVariantMenuItemCell ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *variantLabel;
@property (nonatomic, strong) UIImageView *variantImageView;

@end

@implementation TGVariantMenuItemCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        float retinaPixel = TGIsRetina() ? 0.5f : 0.0f;
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(11, 12, self.contentView.frame.size.width - 28, 20)];
        _titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _titleLabel.font = [UIFont boldSystemFontOfSize:17];
        _titleLabel.backgroundColor = [UIColor whiteColor];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.highlightedTextColor = [UIColor whiteColor];
        [self.contentView addSubview:_titleLabel];
        
        _variantLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.contentView.frame.size.width - 200 - 11 - 14, 11 + retinaPixel, 200, 20)];
        _variantLabel.textAlignment = NSTextAlignmentRight;
        _variantLabel.contentMode = UIViewContentModeRight;
        _variantLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _variantLabel.font = [UIFont systemFontOfSize:16];
        _variantLabel.backgroundColor = [UIColor clearColor];
        _variantLabel.textColor = UIColorRGB(0x356596);
        _variantLabel.highlightedTextColor = [UIColor whiteColor];
        [self.contentView addSubview:_variantLabel];
        
        UIImageView *disclosureIndicator = [[UIImageView alloc] initWithImage:[TGInterfaceAssets groupedCellDisclosureArrow] highlightedImage:[TGInterfaceAssets groupedCellDisclosureArrowHighlighted]];
        disclosureIndicator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        disclosureIndicator.frame = CGRectOffset(disclosureIndicator.frame, self.contentView.frame.size.width - disclosureIndicator.frame.size.width - 11, 14);
        [self.contentView addSubview:disclosureIndicator];
    }
    return self;
}

- (void)setTitle:(NSString *)title
{
    _title = title;
    
    _titleLabel.text = title;
}

- (void)setVariant:(NSString *)variant
{
    _variant = variant;
    
    _variantLabel.text = variant;
}

- (void)setVariantImage:(UIImage *)image
{
    _variantLabel.hidden = image != nil;
    
    if (_variantImageView == nil)
    {
        _variantImageView = [[UIImageView alloc] init];
        _variantImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [self.contentView addSubview:_variantImageView];
    }
    
    _variantImageView.hidden = image == nil;
    _variantImageView.image = image;
    
    if (image != nil)
    {
        _variantImageView.frame = CGRectMake(self.contentView.frame.size.width - 30 - image.size.width, CGFloor((self.contentView.frame.size.height - image.size.height) / 2), image.size.width, image.size.height);
    }
}

@end
