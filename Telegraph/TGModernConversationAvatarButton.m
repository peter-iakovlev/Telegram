#import "TGModernConversationAvatarButton.h"

#import <LegacyComponents/LegacyComponents.h>

#import <LegacyComponents/TGLetteredAvatarView.h>

#import "TGAppDelegate.h"

@interface TGModernConversationAvatarButton ()
{
    UIInterfaceOrientation _orientation;
    
    NSString *_avatarUrl;
    TGLetteredAvatarView *_avatarView;
    UIImageView *_iconView;
    
    int64_t _avatarConversationId;
    NSString *_avatarTitle;
    NSString *_avatarFirstName;
    NSString *_avatarLastName;
    UIImage *_avatarIcon;
    
    CGFloat _horizontalOffset;
    CGFloat _verticalOffset;
}

@end

@implementation TGModernConversationAvatarButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _avatarView = [[TGLetteredAvatarView alloc] init];
        [_avatarView setSingleFontSize:18.0f doubleFontSize:18.0f useBoldFont:true];
        [self addSubview:_avatarView];
        
        if (iosMajorVersion() < 7) {
            _horizontalOffset = -11.0f;
        } else if (iosMajorVersion() >= 11) {
            _horizontalOffset = 25.0f;
            _verticalOffset = 13.0f;
            
            if (TGAppDelegateInstance.rootController.isRTL)
                _horizontalOffset = -5.0f;
        }
        
        _iconView = [[UIImageView alloc] init];
        [_avatarView addSubview:_iconView];
    }
    return self;
}

- (void)setPreview:(bool)preview
{
    _preview = preview;
    if (iosMajorVersion() >= 11 && preview)
    {
        _horizontalOffset -= 20.0f;
        _verticalOffset += 2.0f;
        
        if (TGAppDelegateInstance.rootController.isRTL)
            _horizontalOffset = -15;
        
        [self setNeedsLayout];
    }
}

- (void)setOrientation:(UIInterfaceOrientation)orientation
{
    if (_orientation != orientation)
    {
        _orientation = orientation;
        
        [self setNeedsLayout];
        [_avatarView setTitleNeedsDisplay];
    }
}

- (void)setAvatarConversationId:(int64_t)avatarConversationId
{
    _avatarConversationId = avatarConversationId;
}

- (void)setAvatarTitle:(NSString *)avatarTitle
{
    _avatarTitle = avatarTitle;
    [_avatarView setTitle:avatarTitle];
}

- (void)setAvatarIcon:(UIImage *)avatarIcon
{
    _iconView.image = avatarIcon;
    _iconView.frame = (CGRect){_iconView.frame.origin, avatarIcon.size};
    [self setNeedsLayout];
}

- (void)setAvatarFirstName:(NSString *)firstName lastName:(NSString *)lastName
{
    _avatarFirstName = firstName;
    _avatarLastName = lastName;
    [_avatarView setFirstName:firstName lastName:lastName];
}

- (NSString *)avatarUrl
{
    return _avatarUrl;
}

- (void)setAvatarUrl:(NSString *)uri
{
    static UIImage *placeholder = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        //!placeholder
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(37.0f, 37.0f), false, 0.0f);
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
        CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, 37.0f, 37.0f));
        CGContextSetStrokeColorWithColor(context, UIColorRGB(0xd9d9d9).CGColor);
        CGContextSetLineWidth(context, 1.0f);
        CGContextStrokeEllipseInRect(context, CGRectMake(0.5f, 0.5f, 36.0f, 36.0f));
        
        placeholder = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    });
    
    if (uri.length == 0)
    {
        _avatarUrl = nil;
        
        if (_avatarConversationId < 0)
        {
            [_avatarView loadGroupPlaceholderWithSize:CGSizeMake(37.0f, 37.0f) conversationId:_avatarConversationId title:_avatarTitle placeholder:placeholder];
        }
        else
        {
            [_avatarView loadUserPlaceholderWithSize:CGSizeMake(37.0f, 37.0f) uid:(int32_t)_avatarConversationId firstName:_avatarFirstName lastName:_avatarLastName placeholder:placeholder];
        }
    }
    else
    {
        if (!TGStringCompare(_avatarUrl, uri))
        {
            _avatarUrl = uri;
            
            UIImage *currentPlaceholder = placeholder;
            UIImage *currentImage = [_avatarView currentImage];
            if (currentImage != nil)
                currentPlaceholder = currentImage;
            
            [_avatarView loadImage:uri filter:@"circle:37x37" placeholder:nil];
        }
    }
}

- (void)layoutSubviews
{
    CGFloat scaling = 1.0f;
    if (UIInterfaceOrientationIsPortrait(_orientation) || TGIsPad())
    {
        CGFloat rtlOffset = -23.0f;
        if (TGAppDelegateInstance.rootController.isRTL) {
            rtlOffset = 10.0f;
        }
        
        _avatarView.frame = CGRectMake(rtlOffset + _horizontalOffset, -17 + _verticalOffset, 37, 37);
        
        if (TGAppDelegateInstance.rootController.isRTL) {
            CGRect frame = _avatarView.frame;
            frame.origin.x = -frame.origin.x;
            _avatarView.frame = frame;
        }
    }
    else
    {
        CGFloat rtlOffset = -10.0f;
        if (TGAppDelegateInstance.rootController.isRTL) {
            rtlOffset = -12.0f;
        }
        scaling = 0.7f;
        
        CGFloat verticalOffset = iosMajorVersion() >= 11 ? 2.0f : 0.0f;
        
        _avatarView.frame = CGRectMake(rtlOffset + _horizontalOffset, -12 + _verticalOffset + verticalOffset, 26, 26);
    }
    
    CGSize iconSize = _iconView.image.size;
    iconSize.width = CGFloor(iconSize.width * scaling);
    iconSize.height = CGFloor(iconSize.height * scaling);
    
    _iconView.frame = (CGRect){{CGFloor((_avatarView.frame.size.width - iconSize.width) / 2.0f), CGFloor((_avatarView.frame.size.height - iconSize.height) / 2.0f + 1.0f * scaling)}, iconSize};
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)__unused event
{
    if (CGRectContainsPoint(_avatarView.frame, point))
        return self;
    
    return nil;
}

@end
