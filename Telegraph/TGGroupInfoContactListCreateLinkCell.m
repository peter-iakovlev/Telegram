#import "TGGroupInfoContactListCreateLinkCell.h"

#import <LegacyComponents/LegacyComponents.h>

#import "TGPresentation.h"

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
        self.selectedBackgroundView = [[UIView alloc] init];
        self.selectedBackgroundView.backgroundColor = TGSelectionColor();
        
        CGFloat originX = TGIsPad() ? 74.0f : 66.0f;
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(originX, 14 - TGRetinaPixel + (TGIsPad() ? 4.0f : 0.0f), self.contentView.frame.size.width - originX - 6, 20)];
        _titleLabel.contentMode = UIViewContentModeLeft;
        _titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _titleLabel.font = TGSystemFontOfSize(17);
        _titleLabel.backgroundColor = [UIColor whiteColor];
        _titleLabel.textColor = TGAccentColor();
        _titleLabel.text = TGLocalized(@"GroupInfo.InviteByLink");
        [self.contentView addSubview:_titleLabel];
        
        _iconView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 26.0f, 26.0f)];
        [self.contentView addSubview:_iconView];
        
        CGFloat verticalOffset = TGIsPad() ? 4.0f : 0.0f;
        CGFloat horizontalOffset = TGIsPad() ? 8.0f : 0.0f;
        
        CGRect iconFrame = _iconView.frame;
        iconFrame.origin = CGPointMake(20 - TGRetinaPixel + horizontalOffset, 9 + verticalOffset);
        _iconView.frame = iconFrame;
    }
    return self;
}

- (void)setPresentation:(TGPresentation *)presentation
{
    _presentation = presentation;
    
    self.backgroundColor = presentation.pallete.backgroundColor;
    self.selectedBackgroundView.backgroundColor = presentation.pallete.selectionColor;
    _titleLabel.textColor = presentation.pallete.accentColor;
    _titleLabel.backgroundColor = self.backgroundColor;
    _iconView.image = presentation.images.contactsInviteLinkIcon;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

@end
