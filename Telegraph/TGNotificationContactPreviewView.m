#import "TGNotificationContactPreviewView.h"

#import <LegacyComponents/LegacyComponents.h>

#import "TGNotificationView.h"

#import <LegacyComponents/TGLetteredAvatarView.h>

@interface TGNotificationContactPreviewView ()
{
    UIView *_wrapperView;
    TGLetteredAvatarView *_avatarView;
    UILabel *_nameLabel;
    UILabel *_phoneLabel;
}
@end

@implementation TGNotificationContactPreviewView

- (instancetype)initWithMessage:(TGMessage *)message conversation:(TGConversation *)conversation attachment:(TGContactMediaAttachment *)attachment peers:(NSDictionary *)peers
{
    self = [super initWithMessage:message conversation:conversation peers:peers];
    if (self != nil)
    {
        self.userInteractionEnabled = false;
        
        TGUser *user = peers[@(attachment.uid)];
        if (user == nil)
        {
            user = [[TGUser alloc] init];
            user.firstName = attachment.firstName;
            user.lastName = attachment.lastName;
            user.phoneNumber = attachment.phoneNumber;
        }
        
        [self setIcon:[UIImage imageNamed:@"MediaContact"] text:TGLocalized(@"Message.Contact")];
        
        _wrapperView = [[UIView alloc] initWithFrame:CGRectMake(TGNotificationPreviewContentInset.left, 0, 0, 29)];
        _wrapperView.alpha = 0.0f;
        _wrapperView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _wrapperView.userInteractionEnabled = false;
        [self addSubview:_wrapperView];
        
        _avatarView = [[TGLetteredAvatarView alloc] initWithFrame:CGRectMake(0, 0, 29, 29)];
        [_avatarView setSingleFontSize:14.0f doubleFontSize:14.0f useBoldFont:true];
        [_wrapperView addSubview:_avatarView];
        
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _nameLabel.backgroundColor = [UIColor clearColor];
        _nameLabel.font = TGMediumSystemFontOfSize(13);
        _nameLabel.text = user.displayName;
        _nameLabel.textColor = [UIColor whiteColor];
        [_wrapperView addSubview:_nameLabel];
        
        [_nameLabel sizeToFit];
        _nameLabel.frame = CGRectMake(36, -1, ceil(_nameLabel.frame.size.width), ceil(_nameLabel.frame.size.height));
        
        _phoneLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _phoneLabel.backgroundColor = [UIColor clearColor];
        _phoneLabel.font = TGSystemFontOfSize(13);
        _phoneLabel.text = [TGPhoneUtils formatPhone:user.phoneNumber forceInternational:user.uid != 0];
        _phoneLabel.textColor = [UIColor whiteColor];
        [_wrapperView addSubview:_phoneLabel];
        
        [_phoneLabel sizeToFit];
        _phoneLabel.frame = CGRectMake(36, 15, ceil(_phoneLabel.frame.size.width), ceil(_phoneLabel.frame.size.height));
        
        static UIImage *placeholder = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^
        {
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(29.0f, 29.0f), false, 0.0f);
            CGContextRef context = UIGraphicsGetCurrentContext();
            
            CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
            CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, 29.0f, 29.0f));
            CGContextSetStrokeColorWithColor(context, UIColorRGB(0xd9d9d9).CGColor);
            CGContextSetLineWidth(context, 1.0f);
            CGContextStrokeEllipseInRect(context, CGRectMake(0.5f, 0.5f, 28.0f, 28.0f));
            
            placeholder = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        });
        
        if (user.photoUrlSmall != nil)
        {
            [_avatarView loadImage:user.photoUrlSmall filter:@"circle:44x44" placeholder:placeholder];
        }
        else
        {
            [_avatarView loadUserPlaceholderWithSize:CGSizeMake(29.0f, 29.0f) uid:user.uid firstName:user.firstName lastName:user.lastName placeholder:placeholder];
        }
    }
    return self;
}

- (void)setExpandProgress:(CGFloat)progress
{
    _expandProgress = progress;
    
    _wrapperView.alpha = progress * progress;
    [self _updateExpandProgress:progress hideText:true];
    
    [self setNeedsLayout];
}

- (CGFloat)expandedHeightForContainerSize:(CGSize)containerSize
{
    [super expandedHeightForContainerSize:containerSize];
    return _headerHeight + TGNotificationDefaultHeight + 2;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _wrapperView.frame = CGRectMake(_wrapperView.frame.origin.x, _textLabel.frame.origin.y + 4, self.frame.size.width - _wrapperView.frame.origin.x - TGNotificationPreviewContentInset.right, _wrapperView.frame.size.height);
    _nameLabel.frame = CGRectMake(_nameLabel.frame.origin.x, _nameLabel.frame.origin.y, _wrapperView.frame.size.width - _nameLabel.frame.origin.x, _nameLabel.frame.size.height);
    _phoneLabel.frame = CGRectMake(_phoneLabel.frame.origin.x, _phoneLabel.frame.origin.y, _wrapperView.frame.size.width - _phoneLabel.frame.origin.x, _phoneLabel.frame.size.height);
}

@end
