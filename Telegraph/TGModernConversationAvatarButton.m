#import "TGModernConversationAvatarButton.h"

#import <LegacyComponents/LegacyComponents.h>

#import <LegacyComponents/TGLetteredAvatarView.h>

#import "TGAppDelegate.h"

#import "TGPresentation.h"

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
    
    NSMutableArray *_avatarViews;
    NSArray *_avatarConversationIds;
    NSArray *_avatarTitles;
    NSArray *_avatarUrls;
    
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
            _horizontalOffset = 23.0f;
            _verticalOffset = 14.0f + 2.0f + TGScreenPixel;
            
            if (TGAppDelegateInstance.rootController.isRTL)
                _horizontalOffset = 6.0f;
        }
        
        _iconView = [[UIImageView alloc] init];
        [_avatarView addSubview:_iconView];
    }
    return self;
}

- (UIEdgeInsets)alignmentRectInsets
{
    if (iosMajorVersion() < 11)
        return [super alignmentRectInsets];
    
    return UIEdgeInsetsMake(0.0f, -8.0f, 0.0f, 8.0f);
}

- (bool)translatesAutoresizingMaskIntoConstraints
{
    if (iosMajorVersion() >= 11)
        return false;
    
    return [super translatesAutoresizingMaskIntoConstraints];
}

- (CGSize)intrinsicContentSize
{
    return CGSizeMake(37.0f, 37.0f);
}

- (void)setPreview:(bool)preview
{
    _preview = preview;
    if (iosMajorVersion() >= 11 && preview)
    {
        _horizontalOffset -= 18.0f;
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

- (void)setAvatarConversationIds:(NSArray *)avatarConversationIds
{
    bool needsLayout = _avatarConversationIds.count == 0;
    _avatarConversationIds = avatarConversationIds;
    
    if (needsLayout)
        [self setNeedsLayout];
}

- (void)setAvatarTitle:(NSString *)avatarTitle
{
    _avatarTitle = avatarTitle;
    [_avatarView setTitle:avatarTitle];
}

- (void)setAvatarTitles:(NSArray *)avatarTitles
{
    _avatarTitles = avatarTitles;
    
    NSInteger i = 0;
    for (NSString *title in avatarTitles)
    {
        if (i == 4)
            break;
        
        TGLetteredAvatarView *avatarView = [self dequeueAvatarViewForIndex:i];
        [avatarView setTitle:title];
        
        i++;
    }
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
    UIImage *placeholder = [TGPresentation.current.images avatarPlaceholderWithDiameter:37.0f];
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

- (void)setAvatarUrls:(NSArray *)urls
{
    if (_avatarView != nil)
    {
        [_avatarView removeFromSuperview];
        _avatarView = nil;
        
        [_iconView removeFromSuperview];
        _iconView = nil;
    }
    
    UIImage *placeholder = [TGPresentation.current.images avatarPlaceholderWithDiameter:17.0f];
    
    NSInteger i = 0;
    for (NSString *uri in urls)
    {
        if (i == 4)
            break;
        
        TGLetteredAvatarView *avatarView = [self dequeueAvatarViewForIndex:i];
        
        if (uri.length == 0)
        {
            [avatarView loadGroupPlaceholderWithSize:CGSizeMake(17.0f, 17.0f) conversationId:[_avatarConversationIds[i] int64Value] title:_avatarTitles[i] placeholder:placeholder];
        }
        else
        {
            if (i >= (NSInteger)_avatarUrls.count || !TGStringCompare(_avatarUrls[i], uri))
            {
                UIImage *currentPlaceholder = placeholder;
                UIImage *currentImage = [avatarView currentImage];
                if (currentImage != nil)
                    currentPlaceholder = currentImage;
                
                [avatarView loadImage:uri filter:@"circle:17x17" placeholder:nil];
            }
        }
        i++;
    }
    
    _avatarUrls = urls;
}

- (TGLetteredAvatarView *)dequeueAvatarViewForIndex:(NSInteger)index
{
    if (_avatarViews == nil)
        _avatarViews = [[NSMutableArray alloc] init];
    
    if ((NSInteger)_avatarViews.count < index + 1)
    {
        TGLetteredAvatarView *avatarView = [[TGLetteredAvatarView alloc] init];
        [avatarView setSingleFontSize:10.0f doubleFontSize:10.0f useBoldFont:true];
        [_avatarViews addObject:avatarView];
        [self addSubview:avatarView];
        
        return avatarView;
    }
    
    return _avatarViews[index];
}

- (void)layoutSubviews
{
    CGFloat scaling = 1.0f;
    CGPoint origin = CGPointZero;
    if (UIInterfaceOrientationIsPortrait(_orientation) || TGIsPad())
    {
        CGFloat rtlOffset = -23.0f;
        if (TGAppDelegateInstance.rootController.isRTL) {
            rtlOffset = 10.0f;
        }
        
        origin = CGPointMake(rtlOffset + _horizontalOffset, -17 + _verticalOffset);
        
        _avatarView.frame = CGRectMake(origin.x, origin.y, 37, 37);
        
        if (TGAppDelegateInstance.rootController.isRTL) {
            CGRect frame = _avatarView.frame;
            frame.origin.x = -frame.origin.x;
            origin = frame.origin;
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
        
        CGFloat verticalOffset = iosMajorVersion() >= 11 ? -1.0f - TGScreenPixel : 0.0f;
        
        origin = CGPointMake(rtlOffset + _horizontalOffset, -12 + _verticalOffset + verticalOffset);
        _avatarView.frame = CGRectMake(origin.x, origin.y, 26, 26);
    }
    
    NSInteger i = 0;
    if (_avatarViews.count > 0)
    {
        origin = CGPointMake(origin.x + 2.0f, origin.y + 2.0f);
        
        for (TGLetteredAvatarView *avatarView in _avatarViews)
        {
            switch (i)
            {
                case 0:
                    avatarView.frame = CGRectMake(origin.x, origin.y, 17.0f, 17.0f);
                    break;
                    
                case 1:
                    avatarView.frame = CGRectMake(origin.x + 17.0f + 1.0f + TGScreenPixel, origin.y, 17.0f, 17.0f);
                    break;
                    
                case 2:
                    avatarView.frame = CGRectMake(origin.x, origin.y + 17.0f + 1.0f + TGScreenPixel, 17.0f, 17.0f);
                    break;
                    
                case 3:
                    avatarView.frame = CGRectMake(origin.x + 17.0f + 1.0f + TGScreenPixel, origin.y + 17.0f + 1.0f + TGScreenPixel, 17.0f, 17.0f);
                    break;
                    
                default:
                    break;
            }
            
            i++;
        }
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
    
    if (_avatarViews.count > 0)
    {
        CGRect unionRect = CGRectZero;
        for (TGLetteredAvatarView *avatarView in _avatarViews)
        {
            unionRect = CGRectUnion(unionRect, avatarView.frame);
        }
        
        if (CGRectContainsPoint(unionRect, point))
            return self;
    }
        
    
    return nil;
}

- (UIView *)snapshotViewAfterScreenUpdates:(BOOL)afterUpdates
{
    return [super snapshotViewAfterScreenUpdates:afterUpdates];
}

- (BOOL)drawViewHierarchyInRect:(CGRect)rect afterScreenUpdates:(BOOL)afterUpdates
{
    return [super drawViewHierarchyInRect:rect afterScreenUpdates:afterUpdates];
}

@end
