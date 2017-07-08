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
        
        _checkButton = [[TGCheckButtonView alloc] initWithStyle:TGCheckButtonStyleDefaultBlue];
        _checkButton.frame = CGRectMake(0.0f, (CGFloat)ceil((self.contentView.frame.size.height - _checkButton.frame.size.height) / 2.0f), _checkButton.frame.size.width, _checkButton.frame.size.height);
        _checkButton.userInteractionEnabled = false;
        [_checkButton addTarget:self action:@selector(checkButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_checkButton];
    }
    return self;
}

- (void)setChatModel:(TGChatModel *)chatModel associatedUsers:(id)associatedUsers shareContext:(TGShareContext *)shareContext
{
    CGSize imageSize = CGSizeMake(40.0f, 40.0f);
    if ([chatModel isKindOfClass:[TGPrivateChatModel class]])
    {
        TGPrivateChatModel *privateChatModel = (TGPrivateChatModel *)chatModel;
        TGUserModel *userModel = nil;
        if ([associatedUsers isKindOfClass:[NSDictionary class]])
        {
            userModel = associatedUsers[@(privateChatModel.peerId.peerId)];
        }
        else
        {
            for (id model in associatedUsers)
            {
                if ([model isKindOfClass:[TGUserModel class]] && ((TGUserModel *)model).userId == privateChatModel.peerId.peerId)
                {
                    userModel = model;
                    break;
                }
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
            [_avatarView setSignal:[TGChatListAvatarSignal chatListAvatarWithContext:shareContext letters:letters peerId:chatModel.peerId imageSize:imageSize]];
        }
        else
        {
            [_avatarView setSignal:[TGChatListAvatarSignal chatListAvatarWithContext:shareContext location:userModel.avatarLocation imageSize:imageSize]];
        }
    }
    else if ([chatModel isKindOfClass:[TGGroupChatModel class]])
    {
        TGGroupChatModel *groupChatModel = (TGGroupChatModel *)chatModel;
        _titleLabel.text = groupChatModel.title;
        
        if (groupChatModel.avatarLocation == nil)
        {
            NSString *letters = [[groupChatModel.title substringToIndex:1] uppercaseString];
            [_avatarView setSignal:[TGChatListAvatarSignal chatListAvatarWithContext:shareContext letters:letters peerId:chatModel.peerId imageSize:imageSize]];
        }
        else
        {
            [_avatarView setSignal:[TGChatListAvatarSignal chatListAvatarWithContext:shareContext location:groupChatModel.avatarLocation imageSize:imageSize]];
        }
    }
    else if ([chatModel isKindOfClass:[TGChannelChatModel class]])
    {
        TGChannelChatModel *channelChatModel = (TGChannelChatModel *)chatModel;
        _titleLabel.text = channelChatModel.title;
        
        if (channelChatModel.avatarLocation == nil)
        {
            NSString *letters = [[channelChatModel.title substringToIndex:1] uppercaseString];
            [_avatarView setSignal:[TGChatListAvatarSignal chatListAvatarWithContext:shareContext letters:letters peerId:channelChatModel.peerId imageSize:imageSize]];
        }
        else
        {
            [_avatarView setSignal:[TGChatListAvatarSignal chatListAvatarWithContext:shareContext location:channelChatModel.avatarLocation imageSize:imageSize]];
        }
    }
    
    [self setNeedsLayout];
}

- (void)setHighlighted:(BOOL)highlighted
{
    highlighted = false;
    
    [super setHighlighted:highlighted];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    highlighted = false;
    animated = false;
    
    [super setHighlighted:highlighted animated:animated];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    selected = false;
    [super setSelected:selected animated:animated];
}

- (void)checkButtonPressed
{
    [self setChecked:!_checkButton.selected animated:true];
}

- (void)setChecked:(bool)checked animated:(bool)animated
{
    [_checkButton setSelected:checked animated:animated bump:true];
}

- (void)layoutSubviews
{
    CGSize size = self.contentView.frame.size;
    CGFloat leftPadding = 10.0f;
    CGFloat avatarWidth = 40.0f;
    CGFloat avatarSpacing = 8.0f;
    CGFloat rightPadding = _checkButton.frame.size.width + 16.0f;
    
    CGRect checkFrame = CGRectMake(size.width - _checkButton.frame.size.width - 10.0f, (CGFloat)ceil((size.height - _checkButton.frame.size.height) / 2.0f), _checkButton.frame.size.width, _checkButton.frame.size.height);
    
    [self setSeparatorInset:UIEdgeInsetsMake(0, leftPadding + avatarWidth + avatarSpacing, 0, 0)];
    
    [super layoutSubviews];
    

    _checkButton.frame = checkFrame;
    
    CGSize titleSize = [_titleLabel.text sizeWithAttributes:@{NSFontAttributeName: _titleLabel.font}];
    titleSize.width = MIN(size.width - leftPadding - avatarSpacing - avatarWidth - rightPadding, (CGFloat)ceil(titleSize.width));
    titleSize.height = (CGFloat)ceil(titleSize.height);
    
    
    _titleLabel.frame = CGRectMake(leftPadding + avatarWidth + avatarSpacing, (CGFloat)ceil((size.height - titleSize.height) / 2.0f) - 1.0f, titleSize.width, titleSize.height);
    
    _avatarView.frame = CGRectMake(leftPadding, (CGFloat)ceil((size.height - avatarWidth) / 2.0f), avatarWidth, avatarWidth);
}

@end
