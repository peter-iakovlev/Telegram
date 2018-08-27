#import "TGLoginCountryCell.h"

#import <LegacyComponents/LegacyComponents.h>

#import "TGPresentation.h"

@interface TGLoginCountryCell ()
{
    bool _useIndex;
}
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subtitleLabel;
@property (nonatomic, strong) UILabel *codeLabel;

@end

@implementation TGLoginCountryCell

@synthesize titleLabel = _titleLabel;
@synthesize codeLabel = _codeLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        _codeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _codeLabel.textAlignment = NSTextAlignmentRight;
        _codeLabel.contentMode = UIViewContentModeRight;
        _codeLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        _codeLabel.font = TGMediumSystemFontOfSize(17);
        _codeLabel.backgroundColor = [UIColor whiteColor];
        _codeLabel.textColor = UIColorRGB(0x0);
        [self.contentView addSubview:_codeLabel];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _titleLabel.font = TGSystemFontOfSize(17);
        _titleLabel.backgroundColor = [UIColor whiteColor];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.contentView addSubview:_titleLabel];
        
        _subtitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _subtitleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _subtitleLabel.font = TGSystemFontOfSize(14);
        _subtitleLabel.backgroundColor = [UIColor whiteColor];
        _subtitleLabel.textColor = [UIColor blackColor];
        _subtitleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.contentView addSubview:_subtitleLabel];
        
        self.selectedBackgroundView = [[UIView alloc] init];
        self.selectedBackgroundView.backgroundColor = TGSelectionColor();
        
        [self setUseIndex:false];
    }
    return self;
}

- (void)setPresentation:(TGPresentation *)presentation
{
    self.backgroundColor = presentation.pallete.backgroundColor;
    self.selectedBackgroundView.backgroundColor = presentation.pallete.selectionColor;
    _titleLabel.backgroundColor = self.backgroundColor;
    _titleLabel.textColor = presentation.pallete.textColor;
    _subtitleLabel.backgroundColor = self.backgroundColor;
    _subtitleLabel.textColor = presentation.pallete.textColor;
    _codeLabel.textColor = presentation.pallete.textColor;
    _codeLabel.backgroundColor = self.backgroundColor;
}

- (void)setTitle:(NSString *)title
{
    _titleLabel.text = title;
}

- (void)setSubtitle:(NSString *)subtitle
{
    _subtitleLabel.text = subtitle;
    [self setNeedsLayout];
}

- (void)setCode:(NSString *)code
{
    _codeLabel.text = code;
}

- (void)setUseIndex:(bool)useIndex
{
    _useIndex = useIndex;
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat titleY = 12.0f;
    if (_subtitleLabel.text.length > 0)
    {
        CGFloat subtitleY = 22.0f;
        _subtitleLabel.frame = _useIndex ? CGRectMake(iosMajorVersion() >= 7 ? 15 : 9, subtitleY, self.contentView.frame.size.width - 74 - 5, 20) : CGRectMake(9, subtitleY, self.contentView.frame.size.width - 74 - 15 - 10, 18);
        titleY = 3.0f;
    }
    
    _titleLabel.frame = _useIndex ? CGRectMake(iosMajorVersion() >= 7 ? 15 : 9, titleY, self.contentView.frame.size.width - 74 - 5, 20) : CGRectMake(9, titleY, self.contentView.frame.size.width - 74 - 15 - 10, 20);
    
    _codeLabel.frame = _useIndex ? CGRectMake(self.contentView.frame.size.width - 49 - 32, 12, 70, 20) : CGRectMake(self.contentView.frame.size.width - 81, 12, 70, 20);
}

@end
