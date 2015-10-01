/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGGroupInfoUserCollectionItemView.h"

#import "TGImageUtils.h"
#import "TGFont.h"

#import "TGUser.h"

#import "TGLetteredAvatarView.h"

@interface TGGroupInfoUserCollectionItemViewContent : UIView

@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) NSString *status;
@property (nonatomic) bool statusIsActive;
@property (nonatomic) bool isSecretChat;

@end

@implementation TGGroupInfoUserCollectionItemViewContent

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        self.contentMode = UIViewContentModeLeft;
        self.opaque = false;
    }
    return self;
}

- (void)drawRect:(CGRect)__unused rect
{
    static UIFont *regularNameFont = nil;
    static UIFont *boldNameFont = nil;
    static CGColorRef nameColor = NULL;
    static CGColorRef secretNameColor = NULL;
    
    static UIFont *statusFont = nil;
    static dispatch_once_t onceToken;
    static CGColorRef activeStatusColor = NULL;
    static CGColorRef regularStatusColor = NULL;
    dispatch_once(&onceToken, ^
    {
        regularNameFont = TGSystemFontOfSize(17.0f);
        boldNameFont = TGMediumSystemFontOfSize(17.0f);
        statusFont = TGSystemFontOfSize(13.0f);
        
        nameColor = CGColorRetain([UIColor blackColor].CGColor);
        secretNameColor = CGColorRetain(UIColorRGB(0x00a629).CGColor);
        activeStatusColor = CGColorRetain(TGAccentColor().CGColor);
        regularStatusColor = CGColorRetain(UIColorRGB(0xb3b3b3).CGColor);
    });
    
    CGRect bounds = self.bounds;
    CGFloat availableWidth = bounds.size.width - 20.0f - 1.0f;
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGSize firstNameSize = [_firstName sizeWithFont:regularNameFont];
    CGSize lastNameSize = [_lastName sizeWithFont:boldNameFont];
    CGFloat nameSpacing = 4.0f;
    
    firstNameSize.width = MIN(firstNameSize.width, availableWidth - 30.0f);
    lastNameSize.width = MIN(lastNameSize.width, availableWidth - nameSpacing - firstNameSize.width);
    
    CGContextSetFillColorWithColor(context, _isSecretChat ? secretNameColor : nameColor);
    [_firstName drawInRect:CGRectMake(1.0f, 1.0f, firstNameSize.width, firstNameSize.height) withFont:regularNameFont lineBreakMode:NSLineBreakByTruncatingTail];
    [_lastName drawInRect:CGRectMake(1.0f + firstNameSize.width + nameSpacing, TGRetinaPixel, lastNameSize.width, lastNameSize.height) withFont:boldNameFont lineBreakMode:NSLineBreakByTruncatingTail];
    
    CGSize statusSize = [_status sizeWithFont:statusFont];
    CGContextSetFillColorWithColor(context, _statusIsActive ? activeStatusColor : regularStatusColor);
    [_status drawInRect:CGRectMake(1.0f, 23.0f - TGRetinaPixel, MIN(statusSize.width, availableWidth), statusSize.height) withFont:statusFont lineBreakMode:NSLineBreakByTruncatingTail];
}

@end

@interface TGGroupInfoUserCollectionItemView ()
{
    int32_t _uidForPlaceholderCalculation;
    TGLetteredAvatarView *_avatarView;
    TGGroupInfoUserCollectionItemViewContent *_content;
    
    UIView *_disabledOverlayView;
}

@end

@implementation TGGroupInfoUserCollectionItemView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        self.separatorInset = 65.0f;
        
        _avatarView = [[TGLetteredAvatarView alloc] init];
        [_avatarView setSingleFontSize:17.0f doubleFontSize:17.0f useBoldFont:true];
        _avatarView.fadeTransition = true;
        [self.editingContentView addSubview:_avatarView];
        
        _content = [[TGGroupInfoUserCollectionItemViewContent alloc] init];
        [self.editingContentView addSubview:_content];
    }
    return self;
}

- (void)setFirstName:(NSString *)firstName lastName:(NSString *)lastName uidForPlaceholderCalculation:(int32_t)uidForPlaceholderCalculation
{
    if (firstName.length != 0)
    {
        _content.firstName = firstName;
        _content.lastName = lastName;
    }
    else
    {
        _content.firstName = lastName;
        _content.lastName = nil;
    }
    
    _uidForPlaceholderCalculation = uidForPlaceholderCalculation;
    
    [_content setNeedsDisplay];
}

- (void)setStatus:(NSString *)status active:(bool)active
{
    if (!TGStringCompare(_content.status, status) || _content.statusIsActive != active)
    {
        _content.status = status;
        _content.statusIsActive = active;
        [_content setNeedsDisplay];
    }
}

- (void)setAvatarUri:(NSString *)avatarUri
{
    static UIImage *placeholder = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(40.0f, 40.0f), false, 0.0f);
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        //!placeholder
        CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
        CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, 40.0f, 40.0f));
        CGContextSetStrokeColorWithColor(context, UIColorRGB(0xd9d9d9).CGColor);
        CGContextSetLineWidth(context, 1.0f);
        CGContextStrokeEllipseInRect(context, CGRectMake(0.5f, 0.5f, 39.0f, 39.0f));
        
        placeholder = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    });
    
    if (avatarUri.length == 0)
        [_avatarView loadUserPlaceholderWithSize:CGSizeMake(40.0f, 40.0f) uid:_uidForPlaceholderCalculation firstName:_content.firstName lastName:_content.lastName placeholder:placeholder];
    else if (!TGStringCompare([_avatarView currentUrl], avatarUri))
        [_avatarView loadImage:avatarUri filter:@"circle:40x40" placeholder:placeholder];
}

- (void)setIsSecretChat:(bool)isSecretChat
{
    if (_content.isSecretChat != isSecretChat)
    {
        _content.isSecretChat = isSecretChat;
        [_content setNeedsDisplay];
    }
}

- (void)setDisabled:(bool)disabled animated:(bool)animated
{
    if (disabled)
    {
        if (_disabledOverlayView == nil)
        {
            _disabledOverlayView = [[UIView alloc] init];
            _disabledOverlayView.backgroundColor = UIColorRGBA(0xffffff, 0.7f);
            _disabledOverlayView.alpha = 0.0f;
            _disabledOverlayView.userInteractionEnabled = false;
            [self addSubview:_disabledOverlayView];
            [self setNeedsLayout];
        }
        
        if (animated)
        {
            [UIView animateWithDuration:0.3 animations:^
            {
                _disabledOverlayView.alpha = 1.0f;
            }];
        }
        else
            _disabledOverlayView.alpha = 1.0f;
    }
    else if (_disabledOverlayView != nil)
    {
        if (animated)
        {
            UIView *view = _disabledOverlayView;
            _disabledOverlayView = nil;
            
            [UIView animateWithDuration:0.3 animations:^
            {
                view.alpha = 0.0f;
            } completion:^(__unused BOOL finished)
            {
                [view removeFromSuperview];
            }];
        }
        else
        {
            [_disabledOverlayView removeFromSuperview];
            _disabledOverlayView = nil;
        }
    }
}

- (void)layoutSubviews
{
    CGFloat leftInset = self.showsDeleteIndicator ? 38.0f : 0.0f;
    self.separatorInset = 65.0f + leftInset;
    
    [super layoutSubviews];
    
    CGRect bounds = self.bounds;
    
    if (_disabledOverlayView != nil)
        [_disabledOverlayView setFrame:CGRectInset(bounds, 0.0f, 1.0f)];
    
    _avatarView.frame = CGRectMake(leftInset + 14.0f, 4.0f + TGRetinaPixel, 40.0f, 40.0f);
    
    CGRect contentFrame = CGRectMake(65.0f + leftInset, 4.0f, bounds.size.width - 65.0f, bounds.size.height - 8.0f);
    if (!CGSizeEqualToSize(_content.frame.size, contentFrame.size))
        [_content setNeedsDisplay];
    _content.frame = contentFrame;
}

#pragma mark -

- (void)deleteAction
{
    [self setShowsEditingOptions:false animated:true];
    
    id<TGGroupInfoUserCollectionItemViewDelegate> delegate = _delegate;
    if ([delegate respondsToSelector:@selector(groupInfoUserItemViewRequestedDeleteAction:)])
        [delegate groupInfoUserItemViewRequestedDeleteAction:self];
}

@end
