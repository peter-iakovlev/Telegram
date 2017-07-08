#import "TGWidgetUserCell.h"
#import "TGLegacyUser.h"
#import <LegacyDatabase/TGColor.h>

#import "TGShareImageView.h"

NSString *const TGWidgetUserCellIdentifier = @"TGWidgetUserCell";
const CGSize TGWidgetUserCellSize = { 76.0f, 76.0f };
const CGSize TGWidgetSmallUserCellSize = { 68.0f, 76.0f };

@interface TGWidgetUserCell ()
{
    TGShareImageView *_imageView;
    UILabel *_nameLabel;
    
    UIImageView *_badgeBackgroundView;
    UILabel *_badgeLabel;
    
    UIVisualEffectView *_effectView;
}
@end

@implementation TGWidgetUserCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        CGFloat x = 10.0f;
        if ([UIScreen mainScreen].bounds.size.width == 320)
            x = 6.0f;
        
        _imageView = [[TGShareImageView alloc] initWithFrame:CGRectMake(x, 3.0f, 56.0f, 56.0f)];
        _imageView.clipsToBounds = true;
        _imageView.layer.cornerRadius = 28.0f;
        [self addSubview:_imageView];
        
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.backgroundColor = [UIColor clearColor];
        _nameLabel.font = [UIFont systemFontOfSize:12.0f];
        _nameLabel.textAlignment = NSTextAlignmentCenter;
    }
    return self;
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
        _badgeLabel.font = [UIFont systemFontOfSize:16.0f weight:UIFontWeightThin];
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
        
        CGFloat badgeWidth = MAX(22, floor(_badgeLabel.frame.size.width) + 13.0f);
        _badgeBackgroundView.frame = CGRectMake(floor(TGWidgetUserCellSize.width - 18.0f - badgeWidth / 2.0f), 0, badgeWidth, 22);
        _badgeLabel.frame = CGRectMake(floor((badgeWidth - _badgeLabel.frame.size.width) / 2), 1.0f, _badgeLabel.frame.size.width, ceil(_badgeLabel.frame.size.height));
    }
}

- (void)setUser:(TGLegacyUser *)user avatarSignal:(SSignal *)avatarSignal unreadCount:(NSUInteger)unreadCount effectView:(UIVisualEffectView *)effectView
{
    _effectView = effectView;
    
    if (_nameLabel.superview != _effectView.contentView)
        [_effectView.contentView addSubview:_nameLabel];
    
    [_imageView setSignal:avatarSignal];

    _nameLabel.text = user.firstName.length > 0 ? user.firstName : user.lastName;
    [_nameLabel sizeToFit];
    
    [self setBadgeText:unreadCount > 0 ? [NSString stringWithFormat:@"%d", (int)unreadCount] : nil];
    
    CGRect nameFrame = CGRectMake(0, 63.0f, self.frame.size.width, ceil(_nameLabel.frame.size.height));
    _nameLabel.frame = [self convertRect:nameFrame toView:_effectView];
}

- (void)setHidden:(bool)hidden animated:(bool)animated
{
    void (^changeBlock)(void) = ^
    {
        self.alpha = hidden ? 0.0f : 1.0f;
    };
    
    NSTimeInterval delay = hidden ? 0.0 : 0.05;
    if (animated)
        [UIView animateWithDuration:0.3 delay:delay options:kNilOptions animations:changeBlock completion:nil];
    else
        changeBlock();
}

@end
