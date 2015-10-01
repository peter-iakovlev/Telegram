#import "TGActionMenuItemCell.h"

#import "TGInterfaceAssets.h"

@interface TGActionMenuItemCell ()

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UIImageView *disclosureIndicator;
@property (nonatomic, strong) UIImageView *checkIndicator;

@end

@implementation TGActionMenuItemCell

@synthesize forcePaddings = _forcePaddings;

@synthesize title = _title;

@synthesize titleLabel = _titleLabel;

@synthesize disclosureIndicator = _disclosureIndicator;
@synthesize checkIndicator = _checkIndicator;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(11, 12, self.contentView.frame.size.width - 30, 20)];
        _titleLabel.contentMode = UIViewContentModeLeft;
        _titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _titleLabel.font = [UIFont boldSystemFontOfSize:17];
        _titleLabel.backgroundColor = [UIColor whiteColor];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.highlightedTextColor = [UIColor whiteColor];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:_titleLabel];
        
        _disclosureIndicator = [[UIImageView alloc] initWithImage:[TGInterfaceAssets groupedCellDisclosureArrow] highlightedImage:[TGInterfaceAssets groupedCellDisclosureArrowHighlighted]];
        _disclosureIndicator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        _disclosureIndicator.frame = CGRectOffset(_disclosureIndicator.frame, self.contentView.frame.size.width - _disclosureIndicator.frame.size.width - 11, 14);
        [self.contentView addSubview:_disclosureIndicator];
    }
    return self;
}

- (void)setTitle:(NSString *)title
{
    _title = title;
    _titleLabel.text = title;
}

- (void)setHideDisclosureIndicator:(bool)hide
{
    _disclosureIndicator.hidden = hide;
}

- (void)setHideCheckIndicator:(bool)hide
{
    if (hide)
    {
        if (_checkIndicator != nil)
            _checkIndicator.hidden = true;
        _titleLabel.textColor = [UIColor blackColor];
    }
    else
    {
        if (_checkIndicator == nil)
        {
            _checkIndicator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ListCheck.png"] highlightedImage:[UIImage imageNamed:@"ListCheck_Highlighted.png"]];
            _checkIndicator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
            _checkIndicator.frame = CGRectOffset(_checkIndicator.frame, self.contentView.frame.size.width - _checkIndicator.frame.size.width - 9, 14);
            [self.contentView addSubview:_checkIndicator];
        }
        else
            _checkIndicator.hidden = false;
        _titleLabel.textColor = UIColorRGB(0x516691);
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (_forcePaddings)
    {
        _titleLabel.frame = CGRectMake(11, 14, self.contentView.frame.size.width - 30, 20);
        _disclosureIndicator.frame = CGRectMake(self.contentView.frame.size.width - _disclosureIndicator.frame.size.width - 11, 16, _disclosureIndicator.frame.size.width, _disclosureIndicator.frame.size.height);
        
        CGRect frame = self.contentView.frame;
        frame.origin.x = 9;
        frame.size.width = self.frame.size.width - 18;
        self.contentView.frame = frame;
        
        CGRect backgroundFrame = self.backgroundView.frame;
        backgroundFrame.origin.x = 9;
        backgroundFrame.size.width = self.frame.size.width - 18;
        self.backgroundView.frame = backgroundFrame;
        
        self.selectedBackgroundView.frame = backgroundFrame;
    }
}

@end
