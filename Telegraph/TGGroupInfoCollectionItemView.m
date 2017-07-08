/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGGroupInfoCollectionItemView.h"

#import "TGLetteredAvatarView.h"
#import "TGImageUtils.h"
#import "TGFont.h"
#import "TGStringUtils.h"

#import "TGTextField.h"

@interface TGGroupInfoCollectionItemView ()
{
    bool _editing;
    
    bool _updatingTitle;
    bool _updatingAvatar;
    
    TGLetteredAvatarView *_avatarView;
    UIImageView *_avatarIconView;
    UIImageView *_avatarOverlay;
    UIActivityIndicatorView *_activityIndicator;
    
    UIImageView *_verifiedIcon;
    
    UILabel *_titleLabel;
    TGTextField *_titleField;
    UIView *_editingSeparator;
    
    int64_t _groupId;
}

@end

@implementation TGGroupInfoCollectionItemView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {   
        _avatarView = [[TGLetteredAvatarView alloc] initWithFrame:CGRectMake(15, 10, 66, 66)];
        [_avatarView setSingleFontSize:28.0f doubleFontSize:28.0f useBoldFont:false];
        _avatarView.fadeTransition = true;
        _avatarView.userInteractionEnabled = true;
        [_avatarView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(avatarTapGesture:)]];
        [self addSubview:_avatarView];
        
        _avatarIconView = [[UIImageView alloc] init];
        [_avatarView addSubview:_avatarIconView];
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.font = TGBoldSystemFontOfSize(20);
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _titleLabel.numberOfLines = 2;
        [self addSubview:_titleLabel];
    }
    return self;
}

- (void)dealloc
{
    _titleField.delegate = nil;
    [_titleField removeTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
}

- (id)avatarView
{
    return _avatarView;
}

- (void)setGroupId:(int64_t)groupId
{
    _groupId = groupId;
}

- (void)setIsVerified:(bool)isVerified {
    if (_isVerified != isVerified) {
        _isVerified = isVerified;
        
        if (_isVerified) {
            if (_verifiedIcon == nil) {
                _verifiedIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ChannelVerifiedIconMedium.png"]];
            }
            if (_verifiedIcon.superview == nil) {
                [self.contentView addSubview:_verifiedIcon];
            }
        } else if (_verifiedIcon.superview != nil) {
            [_verifiedIcon removeFromSuperview];
        }
        
        [self setNeedsLayout];
    }
}

- (void)setAvatarUri:(NSString *)avatarUri animated:(bool)animated
{
    static UIImage *placeholder = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(64.0f, 64.0f), false, 0.0f);
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        //!placeholder
        CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
        CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, 64.0f, 64.0f));
        CGContextSetStrokeColorWithColor(context, UIColorRGB(0xd9d9d9).CGColor);
        CGContextSetLineWidth(context, 1.0f);
        CGContextStrokeEllipseInRect(context, CGRectMake(0.5f, 0.5f, 63.0f, 63.0f));
        
        placeholder = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    });
    
    UIImage *currentPlaceholder = [_avatarView currentImage];
    if (currentPlaceholder == nil)
        currentPlaceholder = placeholder;
    
    if (avatarUri.length == 0)
        [_avatarView loadGroupPlaceholderWithSize:CGSizeMake(64.0f, 64.0f) conversationId:_groupId title:_isBroadcast ? @"" : _titleLabel.text placeholder:placeholder];
    else if (!TGStringCompare([_avatarView currentUrl], avatarUri))
    {
        _avatarView.fadeTransitionDuration = animated ? 0.3 : 0.1;
        [_avatarView loadImage:avatarUri filter:@"circle:64x64" placeholder:currentPlaceholder forceFade:animated];
    }
}

- (void)setAvatarImage:(UIImage *)avatarImage animated:(bool)__unused animated
{
    if (avatarImage == nil) {
        static UIImage *placeholder = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^ {
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(64.0f, 64.0f), false, 0.0f);
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextSetFillColorWithColor(context, UIColorRGB(0xd8d8d8).CGColor);
            CGContextFillEllipseInRect(context, CGRectMake(0.0, 0.0, 64.0f, 64.0f));
            UIImage *iconImage = [UIImage imageNamed:@"CreateGroupAvatarPlaceholderIcon.png"];
            [iconImage drawAtPoint:CGPointMake(CGFloor((64.0f - iconImage.size.width) / 2.0f) + TGRetinaPixel, CGFloor((64.0f - iconImage.size.height) / 2.0f))];
            placeholder = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        });
        [_avatarView loadImage:placeholder];
    } else {
        [_avatarView loadImage:avatarImage];
    }
}

- (void)setTitle:(NSString *)title
{
    if (!TGStringCompare(title, _titleLabel.text))
        _titleLabel.text = title;
    
    if (!_editing && !TGStringCompare(title, _titleField.text))
        _titleField.text = title;
    
    if (!_isBroadcast && _groupId != 0)
        [_avatarView setTitle:title];
    
    [self setNeedsLayout];
}

- (void)setUpdatingTitle:(bool)updatingTitle animated:(bool)__unused animated
{
    _updatingTitle = updatingTitle;
    
    _titleField.enabled = !_updatingTitle;
}

- (void)setUpdatingAvatar:(bool)updatingAvatar animated:(bool)__unused animated
{
    _updatingAvatar = updatingAvatar;
    
    if (_updatingAvatar)
    {
        if (_avatarOverlay == nil)
        {
            static UIImage *overlayImage = nil;
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^
            {
                UIGraphicsBeginImageContextWithOptions(CGSizeMake(64.0f, 64.0f), false, 0.0f);
                CGContextRef context = UIGraphicsGetCurrentContext();
                
                CGContextSetFillColorWithColor(context, UIColorRGBA(0x000000, 0.5f).CGColor);
                CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, 64.0f, 64.0f));
                
                overlayImage = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
            });
            
            _avatarOverlay = [[UIImageView alloc] initWithImage:overlayImage];
            _avatarOverlay.frame = _avatarView.frame;
            _avatarOverlay.userInteractionEnabled = false;
            [self insertSubview:_avatarOverlay aboveSubview:_avatarView];
        }
        
        if (_activityIndicator == nil)
        {
            _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
            _activityIndicator.userInteractionEnabled = false;
            CGRect activityFrame = _activityIndicator.frame;
            activityFrame.origin = CGPointMake(_avatarView.frame.origin.x + CGFloor((_avatarView.frame.size.width - activityFrame.size.width) / 2.0f), _avatarView.frame.origin.y + CGFloor((_avatarView.frame.size.height - activityFrame.size.height) / 2.0f));
            _activityIndicator.frame = activityFrame;
            [self insertSubview:_activityIndicator aboveSubview:_avatarOverlay];
        }
        
        _activityIndicator.hidden = false;
        [_activityIndicator startAnimating];
        
        if (animated)
        {
            _avatarOverlay.alpha = 0.0f;
            _activityIndicator.alpha = 0.0f;
            [UIView animateWithDuration:0.3 animations:^
            {
                _avatarOverlay.alpha = 1.0f;
                _activityIndicator.alpha = 1.0f;
            }];
        }
        else
        {
            _avatarOverlay.alpha = 1.0f;
            _activityIndicator.alpha = 1.0f;
        }
    }
    else if (_avatarOverlay != nil)
    {
        if (animated)
        {
            [UIView animateWithDuration:0.3 animations:^
            {
                _avatarOverlay.alpha = 0.0f;
                _activityIndicator.alpha = 0.0f;
            } completion:^(BOOL finished) {
                if (finished)
                    [_activityIndicator stopAnimating];
            }];
        }
        else
        {
            _avatarOverlay.alpha = 0.0f;
            [_activityIndicator stopAnimating];
            _activityIndicator.alpha = 0.0f;
        }
    }
}

- (void)setIsBroadcast:(bool)isBroadcast
{
    if (_isBroadcast != isBroadcast)
    {
        _isBroadcast = isBroadcast;
        
        _avatarIconView.image = _isBroadcast ? [UIImage imageNamed:@"BroadcastLargeAvatarIcon.png"] : nil;
        
        [self setNeedsLayout];
    }
}

- (void)setEditing:(bool)editing animated:(bool)__unused animated
{
    if (_editing != editing)
    {
        _editing = editing;
        
        _verifiedIcon.hidden = _editing;
        
        if (_editing)
        {
            if (_titleField == nil)
            {
                _titleField = [[TGTextField alloc] init];
                [_titleField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
                _titleField.textColor = [UIColor blackColor];
                _titleField.font = TGSystemFontOfSize(20);
                _titleField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
                _titleField.enabled = !_updatingTitle;
                if (_isBroadcast) {
                    _titleField.placeholder = TGLocalized(@"GroupInfo.BroadcastListNamePlaceholder");
                } else if (_isChannel) {
                    _titleField.placeholder = TGLocalized(@"GroupInfo.ChannelListNamePlaceholder");
                } else {
                    _titleField.placeholder = TGLocalized(@"GroupInfo.GroupNamePlaceholder");
                }
                _titleField.placeholderColor = UIColorRGB(0xc7c7cd);
                _titleField.placeholderFont = _titleField.font;
                if (TGIsRTL())
                    _titleField.textAlignment = NSTextAlignmentRight;
                else if (iosMajorVersion() >= 7)
                    _titleField.textAlignment = NSTextAlignmentNatural;
            }
            
            if (_editingSeparator == nil)
            {
                _editingSeparator = [[UIView alloc] init];
                _editingSeparator.backgroundColor = TGSeparatorColor();
                _editingSeparator.userInteractionEnabled = false;
                [self addSubview:_editingSeparator];
            }
            
            if ([_titleField superview] == nil)
                [self addSubview:_titleField];
            
            _titleField.text = _titleLabel.text;
            
            if (animated)
            {
                _titleField.alpha = 0.0f;
                _editingSeparator.alpha = 0.0f;
                
                [UIView animateWithDuration:0.25 animations:^
                {
                    _titleField.alpha = 1.0f;
                    _editingSeparator.alpha = 1.0f;
                }];
                
                [UIView animateWithDuration:0.25 delay:0.05 options:0 animations:^
                {
                    _titleLabel.alpha = 0.0f;
                } completion:nil];
                
                [self setNeedsLayout];
            }
            else
            {
                _titleField.alpha = 1.0f;
                _titleLabel.alpha = 0.0f;
                _editingSeparator.alpha = 1.0f;
                
                [self setNeedsLayout];
            }
        }
        else
        {
            [_titleField resignFirstResponder];
            
            if (animated)
            {
                [UIView animateWithDuration:0.25 animations:^
                {
                    _titleLabel.alpha = 1.0f;
                    _editingSeparator.alpha = 0.0f;
                }];
                
                [UIView animateWithDuration:0.25 delay:0.05 options:0 animations:^
                {
                    _titleField.alpha = 0.0f;
                } completion:^(BOOL finished)
                {
                    if (finished)
                        [_titleField removeFromSuperview];
                }];
            }
            else
            {
                _titleField.alpha = 0.0f;
                _titleLabel.alpha = 1.0f;
                _editingSeparator.alpha = 0.0f;
                [_titleField removeFromSuperview];
            }
            
            if (!_isBroadcast && _groupId != 0)
                [_avatarView setTitle:_titleLabel.text];
        }
    }
}

- (void)makeNameFieldFirstResponder
{
    [_titleField becomeFirstResponder];
}

- (void)textFieldDidChange:(UITextField *)textField
{
    id<TGGroupInfoCollectionItemViewDelegate> delegate = _delegate;
    if ([delegate respondsToSelector:@selector(groupInfoViewHasChangedEditedTitle:title:)])
        [delegate groupInfoViewHasChangedEditedTitle:self title:textField.text];
    
    if (_editing && !_isBroadcast && _groupId != 0)
        [_avatarView setTitle:textField.text];
}

#pragma mark -

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect bounds = self.bounds;
    
    CGSize iconSize = _avatarIconView.image.size;
    _avatarIconView.frame = (CGRect){{CGFloor((_avatarView.frame.size.width - iconSize.width) / 2.0f), CGFloor((_avatarView.frame.size.height - iconSize.height) / 2.0f + 1.0f)}, iconSize};
    
    CGFloat maxTitleWidth = bounds.size.width - 92 - 14;
    
    if (_verifiedIcon.superview != nil) {
        maxTitleWidth -= _verifiedIcon.bounds.size.width + 5.0f;
    }
    
    CGSize titleSize = [_titleLabel sizeThatFits:CGSizeMake(maxTitleWidth, CGFLOAT_MAX)];
    titleSize.width = MIN(titleSize.width, maxTitleWidth);
    if (titleSize.height < FLT_EPSILON)
    {
        NSString *currentText = _titleLabel.text;
        _titleLabel.text = @" ";
        titleSize = [_titleLabel sizeThatFits:CGSizeMake(maxTitleWidth, CGFLOAT_MAX)];
        _titleLabel.text = currentText;
    }
    
    titleSize.width = MIN(titleSize.width, maxTitleWidth);
    CGRect titleLabelFrame = CGRectMake(92, floor((93.0f - titleSize.height) / 2.0f) - 2.0f, titleSize.width, titleSize.height);
    
    _titleLabel.frame = titleLabelFrame;
    _titleField.frame = CGRectMake(titleLabelFrame.origin.x, 22, maxTitleWidth, 44);
    
    if (_verifiedIcon.superview != nil) {
        _verifiedIcon.frame = CGRectOffset(_verifiedIcon.bounds, titleLabelFrame.origin.x + titleSize.width + 4.0f, titleLabelFrame.origin.y + 5.0f + TGRetinaPixel);
    }
    
    _editingSeparator.frame = CGRectMake(92.0f, 62.0f, bounds.size.width - 92.0f, TGScreenPixel);
}

#pragma mark -

- (void)avatarTapGesture:(UITapGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateRecognized)
    {
        id<TGGroupInfoCollectionItemViewDelegate> delegate = _delegate;
        if ([delegate respondsToSelector:@selector(groupInfoViewHasTappedAvatar:)])
            [delegate groupInfoViewHasTappedAvatar:self];
    }
}

@end
