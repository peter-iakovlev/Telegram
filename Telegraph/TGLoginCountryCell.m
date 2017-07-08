#import "TGLoginCountryCell.h"

#import "TGFont.h"

@interface TGLoginCountryCell ()

@property (nonatomic, strong) UILabel *titleLabel;
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
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _titleLabel.font = TGSystemFontOfSize(17);
        _titleLabel.backgroundColor = [UIColor whiteColor];
        _titleLabel.textColor = [UIColor blackColor];
        [self.contentView addSubview:_titleLabel];
        
        _codeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _codeLabel.textAlignment = NSTextAlignmentRight;
        _codeLabel.contentMode = UIViewContentModeRight;
        _codeLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        _codeLabel.font = TGMediumSystemFontOfSize(17);
        _codeLabel.backgroundColor = [UIColor whiteColor];
        _codeLabel.textColor = UIColorRGB(0x0);
        [self addSubview:_codeLabel];
        
        self.selectedBackgroundView = [[UIView alloc] init];
        self.selectedBackgroundView.backgroundColor = TGSelectionColor();
        
        [self setUseIndex:false];
    }
    return self;
}

- (void)setTitle:(NSString *)title
{
    _titleLabel.text = title;
}

- (void)setCode:(NSString *)code
{
    _codeLabel.text = code;
}

- (void)setUseIndex:(bool)useIndex
{
    _titleLabel.frame = useIndex ? CGRectMake(iosMajorVersion() >= 7 ? 15 : 9, 12, self.contentView.frame.size.width - 74 - 5, 20) : CGRectMake(9, 12, self.contentView.frame.size.width - 74 - 15, 20);
    _codeLabel.frame = useIndex ? CGRectMake(self.frame.size.width - 49 - 32, 12, 70, 20) : CGRectMake(self.frame.size.width - 50 - 9, 12, 70, 20);
}

@end
