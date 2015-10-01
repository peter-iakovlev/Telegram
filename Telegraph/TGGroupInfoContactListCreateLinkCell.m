#import "TGGroupInfoContactListCreateLinkCell.h"

#import "TGFont.h"
#import "TGImageUtils.h"

@interface TGGroupInfoContactListCreateLinkCell ()
{
    UIImageView *_iconView;
    UILabel *_titleLabel;
}

@end

@implementation TGGroupInfoContactListCreateLinkCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self != nil)
    {
        UIView *selectedView = [[UIView alloc] init];
        UIView *innerSelectedView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 0.0f, 48.0f)];
        innerSelectedView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [selectedView addSubview:innerSelectedView];
        innerSelectedView.backgroundColor = TGSelectionColor();
        self.selectedBackgroundView = selectedView;
        
        CGFloat originX = TGIsPad() ? 74.0f : 66.0f;
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(originX, 14 - TGRetinaPixel + (TGIsPad() ? 4.0f : 0.0f), self.contentView.frame.size.width - originX - 6, 20)];
        _titleLabel.contentMode = UIViewContentModeLeft;
        _titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _titleLabel.font = TGSystemFontOfSize(17);
        _titleLabel.backgroundColor = [UIColor whiteColor];
        _titleLabel.textColor = TGAccentColor();
        _titleLabel.text = TGLocalized(@"GroupInfo.InviteByLink");
        [self.contentView addSubview:_titleLabel];
        
        _iconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ModernContactListInviteFriendsIcon.png"]];
        [self.contentView addSubview:_iconView];
        
        CGFloat verticalOffset = TGIsPad() ? 4.0f : 0.0f;
        CGFloat horizontalOffset = TGIsPad() ? 8.0f : 0.0f;
        
        CGRect iconFrame = _iconView.frame;
        iconFrame.origin = CGPointMake(20 - TGRetinaPixel + horizontalOffset, 9 + verticalOffset);
        _iconView.frame = iconFrame;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

@end
