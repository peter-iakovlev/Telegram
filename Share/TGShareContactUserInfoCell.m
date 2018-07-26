#import "TGShareContactUserInfoCell.h"
#import "TGShareImageView.h"

@interface TGShareContactUserInfoCell ()
{
    TGShareImageView *_avatarView;
    UILabel *_nameLabel;
}
@end

@implementation TGShareContactUserInfoCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self != nil)
    {
        _avatarView = [[TGShareImageView alloc] init];
        [self.contentView addSubview:_avatarView];
        
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.backgroundColor = [UIColor clearColor];
        _nameLabel.textColor = [UIColor blackColor];
        _nameLabel.numberOfLines = 0;
        _nameLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _nameLabel.font = [UIFont boldSystemFontOfSize:17.0f];
        [self.contentView addSubview:_nameLabel];
    }
    return self;
}

- (void)setName:(NSString *)name avatarSignal:(SSignal *)avatarSignal
{
    [_avatarView setSignal:avatarSignal];
    _nameLabel.text = name;
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _avatarView.frame = CGRectMake(15.0f, 15.0f, 66.0f, 66.0f);
    
    CGFloat maxNameWidth = self.bounds.size.width - 92 - 14;
    CGSize nameSize = [_nameLabel sizeThatFits:CGSizeMake(maxNameWidth, CGFLOAT_MAX)];
    nameSize.width = MIN(nameSize.width, maxNameWidth);
    if (nameSize.height < FLT_EPSILON)
    {
        NSString *currentText = _nameLabel.text;
        _nameLabel.text = @" ";
        nameSize = [_nameLabel sizeThatFits:CGSizeMake(maxNameWidth, CGFLOAT_MAX)];
        _nameLabel.text = currentText;
    }
    
    CGFloat nameY = 98.0f;
    
    nameSize.width = MIN(nameSize.width, maxNameWidth);
    CGRect nameLabelFrame = CGRectMake(92, floor((nameY - nameSize.height) / 2.0f), nameSize.width, nameSize.height);
    _nameLabel.frame = nameLabelFrame;
}

//- (void)

@end
