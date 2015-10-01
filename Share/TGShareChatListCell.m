#import "TGShareChatListCell.h"

#import "TGShareImageView.h"

#import "TGChatModel.h"
#import "TGPrivateChatModel.h"
#import "TGGroupChatModel.h"
#import "TGUserModel.h"

#import "TGChatListAvatarSignal.h"

@interface TGShareChatListCell ()
{
    TGShareImageView *_avatarView;
    UILabel *_titleLabel;
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
        for (TGUserModel *user in associatedUsers)
        {
            if (user.userId == privateChatModel.peerId.peerId)
            {
                userModel = user;
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
    
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGSize size = self.contentView.frame.size;
    CGFloat leftPadding = 14.0f;
    CGFloat avatarWidth = 40.0f;
    CGFloat avatarSpacing = 12.0f;
    CGFloat rightPadding = 8.0f;
    
    CGSize titleSize = [_titleLabel.text sizeWithAttributes:@{NSFontAttributeName: _titleLabel.font}];
    titleSize.width = MIN(size.width - leftPadding - avatarSpacing - avatarWidth - rightPadding, (CGFloat)ceil(titleSize.width));
    titleSize.height = (CGFloat)ceil(titleSize.height);
    
    _titleLabel.frame = CGRectMake(leftPadding + avatarWidth + avatarSpacing, (CGFloat)floor((size.height - titleSize.height) / 2.0f), titleSize.width, titleSize.height);
    _avatarView.frame = CGRectMake(leftPadding, (CGFloat)ceil((size.height - avatarWidth) / 2.0f), avatarWidth, avatarWidth);
}

@end
