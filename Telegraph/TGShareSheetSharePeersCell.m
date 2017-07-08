#import "TGShareSheetSharePeersCell.h"

#import "TGLetteredAvatarView.h"
#import "TGCheckButtonView.h"

#import "TGConversation.h"
#import "TGUser.h"

#import "TGFont.h"
#import "TGImageUtils.h"

@interface TGShareSheetSharePeersCell () <UIGestureRecognizerDelegate>
{
    id _peer;
    TGLetteredAvatarView *_avatarView;
    UIImageView *_selectedCircleView;
    UILabel *_titleLabel;
    int64_t _peerId;
    bool _isSelected;
    bool _isSecret;
    UILongPressGestureRecognizer *_longTapRecognizer;
    TGCheckButtonView *_checkView;
    UIImageView *_badgeBackgroundView;
    UILabel *_badgeLabel;
}

@end

@implementation TGShareSheetSharePeersCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        _avatarView = [[TGLetteredAvatarView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 60.0f, 60.0f)];
        [_avatarView setSingleFontSize:28.0f doubleFontSize:28.0f useBoldFont:false];
        [self.contentView addSubview:_avatarView];
        
        static UIImage *circleImage = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(60.0f, 60.0f), false, 0.0f);
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextSetBlendMode(context, kCGBlendModeCopy);
            CGContextSetFillColorWithColor(context, TGAccentColor().CGColor);
            CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, 60.0f, 60.0f));
            CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
            CGContextFillEllipseInRect(context, CGRectMake(2.0f, 2.0f, 60.0f - 4.0f, 60.0f - 4.0f));
            circleImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        });
        
        _selectedCircleView = [[UIImageView alloc] initWithImage:circleImage];
        _selectedCircleView.hidden = true;
        [self.contentView addSubview:_selectedCircleView];
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.font = TGSystemFontOfSize(11.0f);
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.contentView addSubview:_titleLabel];
        
        [self.contentView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)]];
        
        _longTapRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longTapGesture:)];
        _longTapRecognizer.enabled = false;
        _longTapRecognizer.delegate = self;
        [self.contentView addGestureRecognizer:_longTapRecognizer];
    }
    return self;
}

- (void)tapGesture:(UITapGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        if (_toggleSelected) {
            _toggleSelected(_peerId);
        }
    }
}

- (void)setPeer:(id)peer {
    if (_peer == peer) {
        return;
    }
    
    _peer = peer;
    CGSize size = _avatarView.bounds.size;
    static UIImage *placeholder = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
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
    
    int64_t peerId = 0;
    _isSecret = false;
    
    if ([peer isKindOfClass:[TGConversation class]]) {
        TGConversation *conversation = peer;
        peerId = conversation.conversationId;
        _isSecret = conversation.isEncrypted;
        if (conversation.additionalProperties[@"user"] != nil) {
            TGUser *user = conversation.additionalProperties[@"user"];

            if (user.photoUrlSmall.length != 0) {
                [_avatarView loadImage:user.photoUrlSmall filter:@"circle:60x60" placeholder:placeholder];
            } else {
                [_avatarView loadUserPlaceholderWithSize:size uid:user.uid firstName:user.firstName lastName:user.lastName placeholder:placeholder];
            }
            _titleLabel.text = user.displayFirstName;
        } else {
            if (conversation.chatPhotoSmall.length != 0) {
                [_avatarView loadImage:conversation.chatPhotoSmall filter:@"circle:60x60" placeholder:placeholder];
            } else {
                [_avatarView loadGroupPlaceholderWithSize:size conversationId:conversation.conversationId title:conversation.chatTitle placeholder:placeholder];
            }
            _titleLabel.text = conversation.chatTitle;
        }
    } else if ([peer isKindOfClass:[TGUser class]]) {
        TGUser *user = peer;

        peerId = user.uid;
        if (user.photoUrlSmall.length != 0) {
            [_avatarView loadImage:user.photoUrlSmall filter:@"circle:60x60" placeholder:placeholder];
        } else {
            [_avatarView loadUserPlaceholderWithSize:size uid:user.uid firstName:user.firstName lastName:user.lastName placeholder:placeholder];
        }
        _titleLabel.text = user.displayFirstName;
    }
    
    if (!_isSelected) {
        _titleLabel.textColor = _isSecret ? UIColorRGB(0x00a629) : [UIColor blackColor];
    }
    
    _peerId = peerId;
    
    [self setNeedsLayout];
}

- (int64_t)peerId {
    return _peerId;
}

- (void)setUnreadCount:(int32_t)unreadCount {
    [self setBadgeText:unreadCount > 0 ? [NSString stringWithFormat:@"%d", unreadCount] : nil];
}

- (void)setBadgeText:(NSString *)text
{
    if (_badgeBackgroundView == nil)
    {
        static dispatch_once_t onceToken;
        static UIImage *badgeBackgroundImage;
        dispatch_once(&onceToken, ^
        {
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(22, 22), false, 0);
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextSetFillColorWithColor(context, TGAccentColor().CGColor);
            CGContextFillEllipseInRect(context, CGRectMake(0, 0, 22, 22));
            badgeBackgroundImage = [UIGraphicsGetImageFromCurrentImageContext() stretchableImageWithLeftCapWidth:12 topCapHeight:12];
            UIGraphicsEndImageContext();
        });
        
        _badgeBackgroundView = [[UIImageView alloc] initWithImage:badgeBackgroundImage];
        [self addSubview:_badgeBackgroundView];
        
        _badgeLabel = [[UILabel alloc] init];
        _badgeLabel.backgroundColor = [UIColor clearColor];
        _badgeLabel.font = TGLightSystemFontOfSize(15);
        _badgeLabel.textAlignment = NSTextAlignmentCenter;
        _badgeLabel.textColor = [UIColor whiteColor];
        [_badgeBackgroundView addSubview:_badgeLabel];
    }
    
    if (text == nil)
    {
        _badgeBackgroundView.hidden = true;
    }
    else
    {
        _badgeBackgroundView.hidden = false;
        _badgeLabel.text = text;
        [_badgeLabel sizeToFit];
        
        CGFloat badgeWidth = round(_badgeLabel.frame.size.width) + 13.0f;
        if (badgeWidth < 25.0f)
            badgeWidth = 22.0f;
        
        _badgeBackgroundView.frame = CGRectMake(round(74.0f - 18.0f - badgeWidth / 2.0f), -2.0f, badgeWidth, 22);
        _badgeLabel.frame = CGRectMake(TGScreenPixelFloor((badgeWidth - _badgeLabel.frame.size.width) / 2), 1.0f + TGScreenPixel, _badgeLabel.frame.size.width, _badgeLabel.frame.size.height);
    }
}

- (void)updateSelectedPeerIds:(NSSet *)selectedPeerIds animated:(bool)animated {
    [self updateSelected:[selectedPeerIds containsObject:@(_peerId)] animated:animated];
}

- (void)updateSelected:(bool)selected animated:(bool)animated {
    if (_isSelected != selected) {
        _isSelected = selected;
        
        _titleLabel.textColor = selected ? TGAccentColor() : (_isSecret ? UIColorRGB(0x00a629) : [UIColor blackColor]);
        
        if (animated && iosMajorVersion() >= 8) {
            [UIView animateWithDuration:0.4 delay:0.0 usingSpringWithDamping:0.48f initialSpringVelocity:0.0f options:0 animations:^{
                _avatarView.transform = selected ? CGAffineTransformMakeScale(0.8666666f, 0.8666666f) : CGAffineTransformIdentity;
            } completion:nil];
        } else {
            _avatarView.transform = selected ? CGAffineTransformMakeScale(0.8666666f, 0.8666666f) : CGAffineTransformIdentity;
        }
        
        _selectedCircleView.hidden = !selected;
        
        if (_isSelected && _checkView == nil)
        {
            _checkView = [[TGCheckButtonView alloc] initWithStyle:TGCheckButtonStyleShare];
            _checkView.userInteractionEnabled = false;
            [_checkView setSelected:true animated:false];
            [self addSubview:_checkView];
        }
        else if (_checkView != nil)
        {
            [_checkView setSelected:selected animated:false];
        }
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _avatarView.center = CGPointMake(CGFloor(self.bounds.size.width / 2.0f), _avatarView.center.y);
    _selectedCircleView.center = _avatarView.center;
    
    CGSize titleSize = [_titleLabel.text sizeWithFont:_titleLabel.font];
    _titleLabel.frame = CGRectMake(0.0f, 64.0f, self.bounds.size.width, titleSize.height);
    
    _checkView.frame = CGRectMake(self.bounds.size.width / 2.0f + 30.0f - _checkView.frame.size.width + 6.0f, 60.0f - _checkView.frame.size.height + 6.0f, _checkView.frame.size.width, _checkView.frame.size.height);
}

- (void)setLongTap:(void (^)(int64_t))longTap {
    _longTap = [longTap copy];
    
    _longTapRecognizer.enabled = longTap != nil;
}

- (void)longTapGesture:(UILongPressGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        if (_longTap && _peerId != 0) {
            _longTap(_peerId);
        }
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)__unused gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)__unused otherGestureRecognizer
{
    //if ([otherGestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]])
    //    return true;
    
    return false;
}

@end
