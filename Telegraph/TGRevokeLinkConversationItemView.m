#import "TGRevokeLinkConversationItemView.h"

#import "TGConversation.h"

#import "TGFont.h"

#import "TGLetteredAvatarView.h"

@interface TGRevokeLinkConversationItemView () {
    TGLetteredAvatarView *_avatarView;
    UILabel *_titleLabel;
    UILabel *_usernameLabel;
}

@end

@implementation TGRevokeLinkConversationItemView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        [self setEnableEditing:true];
        self.optionText = TGLocalized(@"GroupInfo.InviteLink.RevokeAlert.Revoke");
        
        _avatarView = [[TGLetteredAvatarView alloc] initWithFrame:CGRectMake(46.0f, 5.0f, 40.0f, 40.0f)];
        [_avatarView setSingleFontSize:18.0f doubleFontSize:18.0f useBoldFont:true];
        [self.editingContentView addSubview:_avatarView];
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = TGMediumSystemFontOfSize(17.0f);
        [self.editingContentView addSubview:_titleLabel];
        
        _usernameLabel = [[UILabel alloc] init];
        _usernameLabel.textColor = [UIColor blackColor];
        _usernameLabel.backgroundColor = [UIColor clearColor];
        _usernameLabel.font = TGSystemFontOfSize(13.0f);
        [self.editingContentView addSubview:_usernameLabel];
    }
    return self;
}

- (void)setConversation:(TGConversation *)conversation {
    CGSize size = _avatarView.bounds.size;
    static UIImage *placeholder = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0f);
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        //!placeholder
        CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
        CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, size.width, size.height));
        CGContextSetStrokeColorWithColor(context, UIColorRGB(0xd9d9d9).CGColor);
        CGContextSetLineWidth(context, 1.0f);
        CGContextStrokeEllipseInRect(context, CGRectMake(0.5f, 0.5f, size.width - 1.0f, size.height - 1.0f));
        
        placeholder = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    });
    
    if (conversation.chatPhotoSmall.length != 0) {
        [_avatarView loadImage:conversation.chatPhotoSmall filter:@"circle:40x40" placeholder:placeholder];
    } else {
        [_avatarView loadGroupPlaceholderWithSize:size conversationId:conversation.conversationId title:conversation.chatTitle placeholder:placeholder];
    }
    _titleLabel.text = conversation.chatTitle;
    
    NSMutableAttributedString *attributedUsername = [[NSMutableAttributedString alloc] initWithString:[[NSString alloc] initWithFormat:@"https://t.me/%@", conversation.username]];
    [attributedUsername addAttribute:NSFontAttributeName value:_usernameLabel.font range:NSMakeRange(0, attributedUsername.length)];
    [attributedUsername addAttribute:NSForegroundColorAttributeName value:UIColorRGB(0x8e8e93) range:NSMakeRange(0, @"https://t.me/".length)];
    [attributedUsername addAttribute:NSForegroundColorAttributeName value:TGAccentColor() range:NSMakeRange(@"https://t.me/".length, attributedUsername.length - @"https://t.me/".length)];
    
    _usernameLabel.attributedText = attributedUsername;
    
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGSize titleSize = [_titleLabel.text sizeWithFont:_titleLabel.font];
    titleSize.width = CGCeil(MIN(titleSize.width, self.bounds.size.width - 98.0f - 8.0f));
    titleSize.height = CGCeil(titleSize.height);
    _titleLabel.frame = CGRectMake(98.0f, 5.0f, titleSize.width, titleSize.height);
    
    CGSize usernameSize = [_usernameLabel.attributedText boundingRectWithSize:CGSizeMake(self.bounds.size.width - 98.0f - 8.0f, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    _usernameLabel.frame = CGRectMake(98.0f, 27.0f, usernameSize.width, usernameSize.height);
}

- (void)deleteAction {
    if (_revoke) {
        _revoke();
    }
}

@end
