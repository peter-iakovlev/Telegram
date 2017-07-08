#import "TGDialogListBroadcastsMenuCell.h"

#import "TGModernButton.h"

#import "TGFont.h"
#import "TGImageUtils.h"

@interface TGDialogListBroadcastsMenuCell ()
{
    UIView *_separatorView;
    TGModernButton *_broadcastListsButton;
    TGModernButton *_newGroupButton;
}

@end

@implementation TGDialogListBroadcastsMenuCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self != nil)
    {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        _separatorView = [[UIView alloc] init];
        _separatorView.backgroundColor = TGSeparatorColor();
        [self.contentView addSubview:_separatorView];
        self.contentView.clipsToBounds = false;
        
        _broadcastListsButton = [[TGModernButton alloc] init];
        [_broadcastListsButton setTitle:TGLocalized(@"Compose.NewChannelButton") forState:UIControlStateNormal];
        [_broadcastListsButton setTitleColor:TGAccentColor()];
        _broadcastListsButton.titleLabel.font = TGSystemFontOfSize(15.0f + TGRetinaPixel);
        [_broadcastListsButton setContentEdgeInsets:UIEdgeInsetsMake(0, 8, 0, 8)];
        [_broadcastListsButton addTarget:self action:@selector(broadcastListsButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_broadcastListsButton];
        
        _newGroupButton = [[TGModernButton alloc] init];
        [_newGroupButton setTitle:TGLocalized(@"Compose.NewGroup") forState:UIControlStateNormal];
        [_newGroupButton setTitleColor:TGAccentColor()];
        _newGroupButton.titleLabel.font = TGSystemFontOfSize(15.0f + TGRetinaPixel);
        [_newGroupButton setContentEdgeInsets:UIEdgeInsetsMake(0, 8, 0, 8)];
        [_newGroupButton addTarget:self action:@selector(newGroupButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_newGroupButton];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat separatorHeight = TGScreenPixel;
    _separatorView.frame = CGRectMake(0.0f, self.contentView.frame.size.height, self.contentView.frame.size.width, separatorHeight);
    
    [_newGroupButton sizeToFit];
    _newGroupButton.frame = (CGRect){{CGFloor((self.contentView.frame.size.width / 2.0f - _newGroupButton.frame.size.width) / 2.0f), 0.0f}, {_newGroupButton.frame.size.width, self.contentView.frame.size.height}};
    
    [_broadcastListsButton sizeToFit];
    _broadcastListsButton.frame = (CGRect){{CGFloor(self.contentView.frame.size.width / 2.0f + (self.contentView.frame.size.width / 2.0f - _broadcastListsButton.frame.size.width) / 2.0f), 0.0f}, {_broadcastListsButton.frame.size.width, self.contentView.frame.size.height}};
}

- (void)broadcastListsButtonPressed
{
    if (_broadcastListsPressed != nil)
        _broadcastListsPressed();
}

- (void)newGroupButtonPressed
{
    if (_newGroupPressed != nil)
        _newGroupPressed();
}

- (void)resetLocalization
{
    [_broadcastListsButton setTitle:TGLocalized(@"Compose.NewChannelButton") forState:UIControlStateNormal];
    [_newGroupButton setTitle:TGLocalized(@"Compose.NewGroup") forState:UIControlStateNormal];
    
    [self setNeedsLayout];
}

@end
