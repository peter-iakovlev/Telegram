#import "TGImagePickerGalleryCell.h"

#import "TGImageUtils.h"

#import "TGFont.h"

@interface TGImagePickerGalleryCell ()

@property (nonatomic, strong) UIImageView *iconView1;
@property (nonatomic, strong) UIImageView *iconView2;
@property (nonatomic, strong) UIImageView *iconView3;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *countLabel;

@end

@implementation TGImagePickerGalleryCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        static UIImage *strokeImage = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^
        {
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(4, 4), false, 0.0f);
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
            CGContextStrokeRect(context, CGRectMake(0, 0, 4, 4));
            strokeImage = [UIGraphicsGetImageFromCurrentImageContext() stretchableImageWithLeftCapWidth:2 topCapHeight:2];
            UIGraphicsEndImageContext();
        });
        
        static UIImage *selectedCellImage = nil;
        if (selectedCellImage == nil)
            selectedCellImage = [[UIImage imageNamed:@"CellHighlighted96.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:1];
        
        self.selectedBackgroundView = [[UIImageView alloc] initWithImage:selectedCellImage];
        
        float baseY = 10;
        
        _iconView3 = [[UIImageView alloc] initWithFrame:CGRectMake(8 + 4, baseY - 4, 69 - 8, 69 - 8)];
        UIImageView *iconStroke3 = [[UIImageView alloc] initWithFrame:CGRectInset(_iconView3.bounds, -0.5f, -0.5f)];
        iconStroke3.image = strokeImage;
        [_iconView3 addSubview:iconStroke3];
        [self.contentView addSubview:_iconView3];
        
        _iconView2 = [[UIImageView alloc] initWithFrame:CGRectMake(8 + 2, baseY - 2, 69 - 4, 69 - 4)];
        UIImageView *iconStroke2 = [[UIImageView alloc] initWithFrame:CGRectInset(_iconView2.bounds, -0.5f, -0.5f)];
        iconStroke2.image = strokeImage;
        [_iconView2 addSubview:iconStroke2];
        [self.contentView addSubview:_iconView2];
        
        _iconView1 = [[UIImageView alloc] initWithFrame:CGRectMake(8, baseY, 69, 69)];
        UIImageView *iconStroke1 = [[UIImageView alloc] initWithFrame:CGRectInset(_iconView1.bounds, -0.5f, -0.5f)];
        iconStroke1.image = strokeImage;
        [_iconView1 addSubview:iconStroke1];
        [self.contentView addSubview:_iconView1];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(96, 24, 10, 20)];
        _titleLabel.contentMode = UIViewContentModeLeft;
        _titleLabel.font = TGSystemFontOfSize(17);
        _titleLabel.backgroundColor = [UIColor whiteColor];
        _titleLabel.textColor = [UIColor blackColor];
        [self.contentView addSubview:_titleLabel];
        
        _countLabel = [[UILabel alloc] initWithFrame:CGRectMake(96, 49, 10, 20)];
        _countLabel.contentMode = UIViewContentModeLeft;
        _countLabel.font = TGSystemFontOfSize(13);
        _countLabel.backgroundColor = [UIColor whiteColor];
        _countLabel.textColor = [UIColor blackColor];
        [self.contentView addSubview:_countLabel];
        
        UIImageView *disclosureIndicator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MenuDisclosureIndicator.png"]];
        disclosureIndicator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        disclosureIndicator.frame = CGRectOffset(disclosureIndicator.frame, self.contentView.frame.size.width - disclosureIndicator.frame.size.width - 15, 37);
        [self.contentView addSubview:disclosureIndicator];
    }
    return self;
}

- (void)setIcon:(UIImage *)icon icon2:(UIImage *)icon2 icon3:(UIImage *)icon3
{
    _iconView1.image = icon;
    _iconView2.image = icon2;
    _iconView3.image = icon3;
}

- (void)setTitle:(NSString *)title countString:(NSString *)countString
{
    _titleLabel.text = title;
    _countLabel.text = countString;
    [_countLabel sizeToFit];
}

- (void)setTitleAccentColor:(bool)accent
{
    if (accent)
    {
        _titleLabel.textColor = UIColorRGB(0x0072d0);
    }
    else
    {
        _titleLabel.textColor = [UIColor blackColor];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    if (selected)
    {
        CGRect frame = self.selectedBackgroundView.frame;
        frame.origin.y = true ? -1 : 0;
        frame.size.height = self.frame.size.height + 1;
        self.selectedBackgroundView.frame = frame;
        
        [self adjustOrdering];
    }
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    
    if (highlighted)
    {
        CGRect frame = self.selectedBackgroundView.frame;
        frame.origin.y = true ? -1 : 0;
        frame.size.height = self.frame.size.height + 1;
        self.selectedBackgroundView.frame = frame;
        
        [self adjustOrdering];
    }
}

- (void)adjustOrdering
{
    if ([self.superview isKindOfClass:[UITableView class]])
    {
        Class UITableViewCellClass = [UITableViewCell class];
        Class UISearchBarClass = [UISearchBar class];
        int maxCellIndex = 0;
        int index = -1;
        int selfIndex = 0;
        for (UIView *view in self.superview.subviews)
        {
            index++;
            if ([view isKindOfClass:UITableViewCellClass] || [view isKindOfClass:UISearchBarClass] || view.tag == 0x33FC2014)
            {
                maxCellIndex = index;
                
                if (view == self)
                    selfIndex = index;
            }
        }
        
        if (selfIndex < maxCellIndex)
        {
            [self.superview insertSubview:self atIndex:maxCellIndex];
        }
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect frame = self.selectedBackgroundView.frame;
    frame.origin.y = true ? -1 : 0;
    frame.size.height = self.frame.size.height + 1;
    self.selectedBackgroundView.frame = frame;
    
    CGSize titleSize = [_titleLabel sizeThatFits:CGSizeMake(self.frame.size.width - _titleLabel.frame.origin.x - 20, _titleLabel.frame.size.height)];
    _titleLabel.frame = CGRectMake(_titleLabel.frame.origin.x, _titleLabel.frame.origin.y, titleSize.width, titleSize.height);
    
    _countLabel.frame = CGRectMake(_countLabel.frame.origin.x, _countLabel.frame.origin.y, _countLabel.frame.size.width, _countLabel.frame.size.height);
}

@end
