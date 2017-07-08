#import "TGShareCollectionCell.h"

#import "TGLetteredAvatarView.h"

#import "TGConversation.h"
#import "TGUser.h"

#import "TGFont.h"
#import "TGImageUtils.h"

#import "TGCheckButtonView.h"

NSString *const TGShareCollectionCellIdentifier = @"TGShareCollectionCell";

@interface TGShareCollectionCell ()
{
    TGLetteredAvatarView *_avatarView;
    UIImageView *_selectedCircleView;
    TGCheckButtonView *_checkView;
    UILabel *_titleLabel;
    int64_t _peerId;
    bool _isSecret;
    
    bool _isChecked;
    
    bool _showOnlyFirstName;
}
@end

@implementation TGShareCollectionCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        self.opaque = true;
        self.backgroundColor = [UIColor whiteColor];
        
        _avatarView = [[TGLetteredAvatarView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 60.0f, 60.0f)];
        _avatarView.backgroundColor = [UIColor whiteColor];
        _avatarView.opaque = true;
        [_avatarView setSingleFontSize:28.0f doubleFontSize:28.0f useBoldFont:false];
        [self.contentView addSubview:_avatarView];
        
        static UIImage *circleImage = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^
        {
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
        
        _checkView = [[TGCheckButtonView alloc] initWithStyle:TGCheckButtonStyleShare];
        _checkView.userInteractionEnabled = false;
        [self.contentView addSubview:_checkView];
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.font = TGSystemFontOfSize(11.0f);
        _titleLabel.numberOfLines = 2;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.contentView addSubview:_titleLabel];
    }
    return self;
}

- (void)setShowOnlyFirstName:(bool)showOnlyFirstName
{
    _showOnlyFirstName = showOnlyFirstName;
    _titleLabel.numberOfLines = showOnlyFirstName ? 1 : 2;
}

- (void)setPeer:(id)peer
{
    CGSize size = _avatarView.bounds.size;
    static UIImage *placeholder = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0f);
        CGContextRef context = UIGraphicsGetCurrentContext();
        
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
    
    NSString *title = @"";
    if ([peer isKindOfClass:[TGConversation class]])
    {
        TGConversation *conversation = peer;
        peerId = conversation.conversationId;
        _isSecret = conversation.isEncrypted;
        if (conversation.additionalProperties[@"user"] != nil)
        {
            TGUser *user = conversation.additionalProperties[@"user"];
            
            if (user.photoUrlSmall.length != 0)
                [_avatarView loadImage:user.photoUrlSmall filter:@"circle:60x60" placeholder:placeholder];
            else
                [_avatarView loadUserPlaceholderWithSize:size uid:user.uid firstName:user.firstName lastName:user.lastName placeholder:placeholder];
            
            if (_showOnlyFirstName)
                title = user.displayFirstName;
            else
                title = [user.displayName stringByReplacingOccurrencesOfString:@" " withString:@"\n"];
        }
        else
        {
            if (conversation.chatPhotoSmall.length != 0)
                [_avatarView loadImage:conversation.chatPhotoSmall filter:@"circle:60x60" placeholder:placeholder];
            else
                [_avatarView loadGroupPlaceholderWithSize:size conversationId:conversation.conversationId title:conversation.chatTitle placeholder:placeholder];
            title = conversation.chatTitle;
        }
    }
    else if ([peer isKindOfClass:[TGUser class]])
    {
        TGUser *user = peer;
        
        peerId = user.uid;
        if (user.photoUrlSmall.length != 0)
            [_avatarView loadImage:user.photoUrlSmall filter:@"circle:60x60" placeholder:placeholder];
        else
            [_avatarView loadUserPlaceholderWithSize:size uid:user.uid firstName:user.firstName lastName:user.lastName placeholder:placeholder];
        
        if (_showOnlyFirstName)
            title = user.displayFirstName;
        else
            title = [user.displayName stringByReplacingOccurrencesOfString:@" " withString:@"\n"];
    }
    
    _titleLabel.text = title;
    _titleLabel.frame = CGRectMake(_titleLabel.frame.origin.x, _titleLabel.frame.origin.y, self.frame.size.width, self.frame.size.height);
    [_titleLabel sizeToFit];
    
    if (!_isChecked)
        _titleLabel.textColor = _isSecret ? UIColorRGB(0x00a629) : [UIColor blackColor];
    
    _peerId = peerId;
    
    [self setNeedsLayout];
}

- (int64_t)peerId
{
    return _peerId;
}

- (void)setChecked:(bool)checked
{
    [UIView performWithoutAnimation:^
    {
        [self setChecked:checked animated:false];        
    }];
}

- (void)setChecked:(bool)checked animated:(bool)animated
{
    if (_isChecked == checked)
        return;
    
    _isChecked = checked;
    
    _titleLabel.textColor = checked ? TGAccentColor() : (_isSecret ? UIColorRGB(0x00a629) : [UIColor blackColor]);
    
    if (animated && iosMajorVersion() >= 8)
    {
        [UIView animateWithDuration:0.4 delay:0.0 usingSpringWithDamping:0.48f initialSpringVelocity:0.0f options:0 animations:^{
            _avatarView.transform = checked ? CGAffineTransformMakeScale(0.8666666f, 0.8666666f) : CGAffineTransformIdentity;
        } completion:nil];
        [_checkView setSelected:checked animated:true bump:true];
    }
    else
    {
        _avatarView.transform = checked ? CGAffineTransformMakeScale(0.8666666f, 0.8666666f) : CGAffineTransformIdentity;
        [_checkView setSelected:checked animated:false];
    }
    
    _selectedCircleView.hidden = !checked;
}

- (void)performTransitionInWithDelay:(NSTimeInterval)delay
{
    CGRect targetTitleFrame = _titleLabel.frame;
    _titleLabel.frame = CGRectOffset(_titleLabel.frame, 0, 20);
    
    UIViewAnimationOptions options = kNilOptions;
    if (iosMajorVersion() >= 7)
        options = options | (7 << 16);
    
    [UIView animateWithDuration:0.2 delay:delay options:options animations:^
    {
        _titleLabel.frame = targetTitleFrame;
    } completion:nil];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [UIView performWithoutAnimation:^
    {
        _avatarView.center = CGPointMake(CGFloor(self.bounds.size.width / 2.0f), _avatarView.center.y);
        _selectedCircleView.center = _avatarView.center;
        _checkView.frame = CGRectMake(self.bounds.size.width / 2.0f + 30.0f - _checkView.frame.size.width + 6.0f, 60.0f - _checkView.frame.size.height + 6.0f, _checkView.frame.size.width, _checkView.frame.size.height);

        _titleLabel.frame = CGRectMake(0.0f, 64.0f, self.bounds.size.width, _titleLabel.frame.size.height);
    }];
}

@end
