#import "TGChannelModeratorCollectionItemView.h"

#import "TGLetteredAvatarView.h"
#import "TGImageUtils.h"
#import "TGFont.h"
#import "TGDateUtils.h"

#import "TGUser.h"

@interface TGChannelModeratorCollectionItemView () {
    TGLetteredAvatarView *_avatarView;
    UILabel *_nameLabel;
    UILabel *_statusLabel;
}

@end

@implementation TGChannelModeratorCollectionItemView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        _avatarView = [[TGLetteredAvatarView alloc] initWithFrame:CGRectMake(15.0f, 10.0f, 66.0f, 66.0f)];
        [_avatarView setSingleFontSize:28.0f doubleFontSize:28.0f useBoldFont:false];
        [self.contentView addSubview:_avatarView];
        
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.textColor = [UIColor blackColor];
        _nameLabel.backgroundColor = [UIColor clearColor];
        _nameLabel.font = TGMediumSystemFontOfSize(20.0f);
        [self.contentView addSubview:_nameLabel];
        
        _statusLabel = [[UILabel alloc] init];
        _statusLabel.backgroundColor = [UIColor clearColor];
        _statusLabel.font = TGSystemFontOfSize(15.0f);
        [self.contentView addSubview:_statusLabel];
    }
    return self;
}

- (NSString *)_statusStringFromUserPresence:(TGUserPresence)presence active:(out bool *)active
{
    if (presence.online)
    {
        if (active != NULL)
            *active = true;
        return TGLocalized(@"Presence.online");
    }
    else if (presence.lastSeen != 0)
        return [TGDateUtils stringForRelativeLastSeen:presence.lastSeen];
    
    return TGLocalized(@"Presence.offline");
}

- (void)setUser:(TGUser *)user {
    _nameLabel.text = user.displayName;

    bool active = false;
    NSString *status = [self _statusStringFromUserPresence:user.presence active:&active];
    if (user.kind == TGUserKindBot || user.kind == TGUserKindSmartBot) {
        status = TGLocalized(@"Bot.GenericBotStatus");
    }
    
    _statusLabel.text = status;
    if (active) {
        _statusLabel.textColor = TGAccentColor();
    } else {
        _statusLabel.textColor = UIColorRGB(0xb3b3b3);
    }
    
    NSString *avatarUri = user.photoUrlSmall;
    CGSize size = CGSizeMake(66.0f, 66.0f);
    
    static UIImage *placeholder = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0f);
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        //!placeholder
        CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
        CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, 40.0f, 40.0f));
        CGContextSetStrokeColorWithColor(context, UIColorRGB(0xd9d9d9).CGColor);
        CGContextSetLineWidth(context, 1.0f);
        CGContextStrokeEllipseInRect(context, CGRectMake(0.5f, 0.5f, size.width - 1.0f, size.height - 1.0f));
        
        placeholder = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    });
    
    if (avatarUri.length == 0)
        [_avatarView loadUserPlaceholderWithSize:size uid:user.uid firstName:user.firstName lastName:user.lastName placeholder:placeholder];
    else if (!TGStringCompare([_avatarView currentUrl], avatarUri))
        [_avatarView loadImage:avatarUri filter:@"circle:66x66" placeholder:placeholder];
    
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat maxWidth = self.bounds.size.width - 92.0f - 18.0f;
    CGSize nameSize = [_nameLabel sizeThatFits:CGSizeMake(maxWidth, CGFLOAT_MAX)];
    nameSize.width = MIN(maxWidth, nameSize.width);
    CGSize statusSize = [_statusLabel sizeThatFits:CGSizeMake(maxWidth, CGFLOAT_MAX)];
    statusSize.width = MIN(maxWidth, statusSize.width);
    
    _nameLabel.frame = CGRectMake(92.0f, 21.0f, nameSize.width, nameSize.height);
    _statusLabel.frame = CGRectMake(92.0f, 47.0f, statusSize.width, statusSize.height);
}

@end
