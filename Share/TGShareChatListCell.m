#import "TGShareChatListCell.h"

#import "TGShareImageView.h"
#import "TGCheckButtonView.h"

#import "TGChatModel.h"
#import "TGPrivateChatModel.h"
#import "TGGroupChatModel.h"
#import "TGChannelChatModel.h"
#import "TGUserModel.h"

#import "TGChatListAvatarSignal.h"

@interface TGShareChatListCell ()
{
    TGCheckButtonView *_checkButton;
    TGShareImageView *_avatarView;
    UILabel *_titleLabel;
    
    bool _selectionEnabled;
}

@end

@implementation TGShareChatListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self != nil)
    {        
        _avatarView = [[TGShareImageView alloc] init];
        [self.contentView addSubview:_avatarView];
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.font = [UIFont boldSystemFontOfSize:17.0f];
        [self.contentView addSubview:_titleLabel];
    }
    return self;
}

- (void)setChatModel:(TGChatModel *)chatModel associatedUsers:(NSArray *)associatedUsers shareContext:(TGShareContext *)shareContext
{
    if ([chatModel isKindOfClass:[TGPrivateChatModel class]])
    {
        TGPrivateChatModel *privateChatModel = (TGPrivateChatModel *)chatModel;
        TGUserModel *userModel = nil;
        for (id model in associatedUsers)
        {
            if ([model isKindOfClass:[TGUserModel class]] && ((TGUserModel *)model).userId == privateChatModel.peerId.peerId)
            {
                userModel = model;
                break;
            }
        }
        
        _titleLabel.text = [userModel displayName];
        
        if (userModel.avatarLocation == nil)
        {
            NSString *letters = @"";
            if (userModel.firstName.length != 0 && userModel.lastName.length != 0)
            {
                letters = [[NSString alloc] initWithFormat:@"%@%@", [[userModel.firstName substringToIndex:1] uppercaseString], [[userModel.lastName substringToIndex:1] uppercaseString]];
            }
            else if (userModel.firstName.length != 0)
                letters = [[userModel.firstName substringToIndex:1] uppercaseString];
            else if (userModel.lastName.length != 0)
                letters = [[userModel.lastName substringToIndex:1] uppercaseString];
            [_avatarView setSignal:[TGChatListAvatarSignal chatListAvatarWithContext:shareContext letters:letters peerId:chatModel.peerId]];
        }
        else
        {
            [_avatarView setSignal:[TGChatListAvatarSignal chatListAvatarWithContext:shareContext location:userModel.avatarLocation]];
        }
    }
    else if ([chatModel isKindOfClass:[TGGroupChatModel class]])
    {
        TGGroupChatModel *groupChatModel = (TGGroupChatModel *)chatModel;
        _titleLabel.text = groupChatModel.title;
        
        if (groupChatModel.avatarLocation == nil)
        {
            NSString *letters = [[groupChatModel.title substringToIndex:1] uppercaseString];
            [_avatarView setSignal:[TGChatListAvatarSignal chatListAvatarWithContext:shareContext letters:letters peerId:chatModel.peerId]];
        }
        else
        {
            [_avatarView setSignal:[TGChatListAvatarSignal chatListAvatarWithContext:shareContext location:groupChatModel.avatarLocation]];
        }
    }
    else if ([chatModel isKindOfClass:[TGChannelChatModel class]])
    {
        TGChannelChatModel *channelChatModel = (TGChannelChatModel *)chatModel;
        _titleLabel.text = channelChatModel.title;
        
        if (channelChatModel.avatarLocation == nil)
        {
            NSString *letters = [[channelChatModel.title substringFromIndex:1] uppercaseString];
            [_avatarView setSignal:[TGChatListAvatarSignal chatListAvatarWithContext:shareContext letters:letters peerId:channelChatModel.peerId]];
        }
        else
        {
            [_avatarView setSignal:[TGChatListAvatarSignal chatListAvatarWithContext:shareContext location:channelChatModel.avatarLocation]];
        }
    }
    
    [self setNeedsLayout];
}

- (void)setHighlighted:(BOOL)highlighted
{
    if (_selectionEnabled)
        highlighted = false;
    
    [super setHighlighted:highlighted];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    if (_selectionEnabled)
    {
        highlighted = false;
        animated = false;
    }
    
    [super setHighlighted:highlighted animated:animated];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    if (_selectionEnabled)
        return;
    
    [super setSelected:selected animated:animated];
}

- (void)checkButtonPressed
{
    [self setChecked:!_checkButton.selected animated:true];
}

- (void)setSelectionEnabled:(bool)enabled animated:(bool)animated
{
    if (_selectionEnabled == enabled)
        return;
    
    _selectionEnabled = enabled;
    
    if (enabled && _checkButton == nil)
    {
        _checkButton = [[TGCheckButtonView alloc] initWithStyle:TGCheckButtonStyleDefault];
        _checkButton.frame = CGRectMake(-_checkButton.frame.size.width, (CGFloat)ceil((self.contentView.frame.size.height - _checkButton.frame.size.height) / 2.0f), _checkButton.frame.size.width, _checkButton.frame.size.height);
        _checkButton.userInteractionEnabled = false;
        [_checkButton addTarget:self action:@selector(checkButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_checkButton];
    }
    
    [self setNeedsLayout];
    
    if (animated)
    {
        [UIView animateWithDuration:0.25 delay:0.0 options:(7 << 16 | UIViewAnimationOptionLayoutSubviews) animations:^
        {
            [self layoutIfNeeded];
        } completion:^(BOOL finished)
        {
            if (!enabled)
                [_checkButton setSelected:false animated:false];
        }];
    }
}

- (void)setChecked:(bool)checked animated:(bool)animated
{
    if (!_selectionEnabled)
        return;
    
    [_checkButton setSelected:checked animated:animated bump:true];
}

- (void)layoutSubviews
{
    CGSize size = self.contentView.frame.size;
    CGFloat leftPadding = 10.0f;
    CGFloat avatarWidth = 40.0f;
    CGFloat avatarSpacing = 8.0f;
    CGFloat rightPadding = 8.0f;
    
    CGRect checkFrame = CGRectMake(0, (CGFloat)ceil((size.height - _checkButton.frame.size.height) / 2.0f), _checkButton.frame.size.width, _checkButton.frame.size.height);
    if (_selectionEnabled)
    {
        leftPadding += 38;
        checkFrame.origin.x = 7;
    }
    else
    {
        checkFrame.origin.x = -32;
    }
    
    [self setSeparatorInset:UIEdgeInsetsMake(0, leftPadding + avatarWidth + avatarSpacing, 0, 0)];
    
    [super layoutSubviews];
    

    _checkButton.frame = checkFrame;
    
    CGSize titleSize = [_titleLabel.text sizeWithAttributes:@{NSFontAttributeName: _titleLabel.font}];
    titleSize.width = MIN(size.width - leftPadding - avatarSpacing - avatarWidth - rightPadding, (CGFloat)ceil(titleSize.width));
    titleSize.height = (CGFloat)ceil(titleSize.height);
    
    [UIView performWithoutAnimation:^
    {
        _titleLabel.frame = CGRectMake(_titleLabel.frame.origin.x, _titleLabel.frame.origin.y, titleSize.width, titleSize.height);
    }];
    
    _titleLabel.frame = CGRectMake(leftPadding + avatarWidth + avatarSpacing, (CGFloat)ceil((size.height - titleSize.height) / 2.0f), _titleLabel.frame.size.width, _titleLabel.frame.size.height);
    
    _avatarView.frame = CGRectMake(leftPadding, (CGFloat)ceil((size.height - avatarWidth) / 2.0f), avatarWidth, avatarWidth);
}

@end
