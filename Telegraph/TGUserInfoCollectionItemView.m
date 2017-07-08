#import "TGUserInfoCollectionItemView.h"

#import "TGFont.h"
#import "TGStringUtils.h"
#import "TGImageUtils.h"

#import "TGTextField.h"
#import "TGLetteredAvatarView.h"
#import "TGModernButton.h"

#import "TGSynchronizeContactsActor.h"

#import "TGModernGalleryTransitionView.h"

@interface TGLetteredAvatarView (TGModernGalleryTransition) <TGModernGalleryTransitionView>

@end

@implementation TGLetteredAvatarView (TGModernGalleryTransition)

- (UIImage *)transitionImage
{
    return self.image;
}

@end

@interface TGUserInfoCollectionItemView () <UITextFieldDelegate>
{
    TGLetteredAvatarView *_avatarView;
    UILabel *_nameLabel;
    UILabel *_statusLabel;
    CGSize _avatarOffset;
    CGSize _nameOffset;
    
    NSString *_firstName;
    NSString *_lastName;
    
    TGTextField *_firstNameField;
    TGTextField *_lastNameField;
    
    bool _editing;
    
    UIView *_editingFirstNameSeparator;
    UIView *_editingLastNameSeparator;
    
    UIImageView *_avatarOverlay;
    UIActivityIndicatorView *_activityIndicator;
    
    int32_t _uidForPlaceholderCalculation;
    
    UIImageView *_verifiedIcon;
    
    TGModernButton *_callButton;
}

@end

@implementation TGUserInfoCollectionItemView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {   
        _avatarView = [[TGLetteredAvatarView alloc] initWithFrame:CGRectMake(15, 15 + TGRetinaPixel, 66, 66)];
        [_avatarView setSingleFontSize:28.0f doubleFontSize:28.0f useBoldFont:false];
        _avatarView.fadeTransition = true;
        _avatarView.userInteractionEnabled = true;
        [_avatarView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(avatarTapGesture:)]];
        [self addSubview:_avatarView];
        
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.backgroundColor = [UIColor clearColor];
        _nameLabel.textColor = [UIColor blackColor];
        _nameLabel.font = TGMediumSystemFontOfSize(20);
        _nameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _nameLabel.numberOfLines = 1;
        [self addSubview:_nameLabel];
        
        _statusLabel = [[UILabel alloc] init];
        _statusLabel.backgroundColor = [UIColor clearColor];
        _statusLabel.font = TGSystemFontOfSize(15.0f);
        [self addSubview:_statusLabel];
        
        _firstNameField = [[TGTextField alloc] init];
        _firstNameField.placeholder = TGLocalized(@"UserInfo.FirstNamePlaceholder");
        _firstNameField.placeholderFont = TGSystemFontOfSize(17.0f);
        _firstNameField.placeholderColor = UIColorRGB(0xc7c7cd);
        [_firstNameField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        _firstNameField.textColor = [UIColor blackColor];
        _firstNameField.font = TGSystemFontOfSize(17.0f);
        _firstNameField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        if (TGIsRTL())
            _firstNameField.textAlignment = NSTextAlignmentRight;
        else if (iosMajorVersion() >= 7)
            _firstNameField.textAlignment = NSTextAlignmentNatural;
        _firstNameField.alpha = 0.0f;
        _firstNameField.hidden = true;
        _firstNameField.autocorrectionType = UITextAutocorrectionTypeNo;
        _firstNameField.spellCheckingType = UITextSpellCheckingTypeNo;
        [self addSubview:_firstNameField];
        
        _lastNameField = [[TGTextField alloc] init];
        _lastNameField.placeholder = TGLocalized(@"UserInfo.LastNamePlaceholder");
        _lastNameField.placeholderFont = TGSystemFontOfSize(17.0f);
        _lastNameField.placeholderColor = UIColorRGB(0xc7c7cd);
        [_lastNameField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        _lastNameField.textColor = [UIColor blackColor];
        _lastNameField.font = TGSystemFontOfSize(17.0f);
        _lastNameField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        if (TGIsRTL())
            _lastNameField.textAlignment = NSTextAlignmentRight;
        else if (iosMajorVersion() >= 7)
            _lastNameField.textAlignment = NSTextAlignmentNatural;
        _lastNameField.alpha = 0.0f;
        _lastNameField.hidden = true;
        _lastNameField.autocorrectionType = UITextAutocorrectionTypeNo;
        _lastNameField.spellCheckingType = UITextSpellCheckingTypeNo;
        [self addSubview:_lastNameField];
        
        _editingFirstNameSeparator = [[UIView alloc] init];
        _editingFirstNameSeparator.backgroundColor = TGSeparatorColor();
        _editingFirstNameSeparator.hidden = true;
        _editingFirstNameSeparator.alpha = 0.0f;
        [self addSubview:_editingFirstNameSeparator];
        
        _editingLastNameSeparator = [[UIView alloc] init];
        _editingLastNameSeparator.backgroundColor = TGSeparatorColor();
        _editingLastNameSeparator.hidden = true;
        _editingLastNameSeparator.alpha = 0.0f;
        //[self addSubview:_editingLastNameSeparator];
        
        _callButton = [[TGModernButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 44.0f, 44.0f)];
        _callButton.adjustsImageWhenHighlighted = false;
        _callButton.exclusiveTouch = true;
        _callButton.hidden = true;
        [_callButton setImage:TGTintedImage([UIImage imageNamed:@"TabIconCalls"], TGAccentColor()) forState:UIControlStateNormal];
        [_callButton addTarget:self action:@selector(callButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_callButton];
    }
    return self;
}

- (void)dealloc
{
    _firstNameField.delegate = nil;
    [_firstNameField removeTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    _lastNameField.delegate = nil;
    [_lastNameField removeTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
}

- (id)avatarView
{
    return _avatarView;
}

- (void)callButtonPressed
{
    [_itemHandle requestAction:@"callTapped" options:nil];
}

- (void)makeNameFieldFirstResponder
{
    [_firstNameField becomeFirstResponder];
}

- (void)setFirstName:(NSString *)firstName lastName:(NSString *)lastName uidForPlaceholderCalculation:(int32_t)uidForPlaceholderCalculation
{
    _uidForPlaceholderCalculation = uidForPlaceholderCalculation;
    
    _firstName = firstName;
    _lastName = lastName;
    
    NSString *nameText = nil;
    if (firstName != nil && lastName != nil)
        nameText = [[NSString alloc] initWithFormat:@"%@ %@", firstName, lastName];
    else if (firstName != nil)
        nameText = firstName;
    else if (lastName != nil)
        nameText = lastName;
    
    if (!TGStringCompare(nameText, _nameLabel.text))
    {
        _nameLabel.text = nameText;
        
        [_avatarView setFirstName:firstName lastName:lastName];
        
        [self setNeedsLayout];
    }
    
    if (!_editing)
    {
        if (!TGStringCompare(firstName, _firstNameField.text))
        {
            _firstNameField.text = firstName;
            [self setNeedsLayout];
        }
        
        if (!TGStringCompare(lastName, _lastNameField.text))
        {
            _lastNameField.text = lastName;
            [self setNeedsLayout];
        }
    }
}

- (void)setEditing:(bool)editing animated:(bool)animated
{
    if (_editing != editing)
    {
        _editing = editing;
        
        _verifiedIcon.hidden = _editing;
        
        if (editing)
        {
            _firstNameField.hidden = false;
            _lastNameField.hidden = false;
            _editingFirstNameSeparator.hidden = false;
            _editingLastNameSeparator.hidden = false;
            _callButton.userInteractionEnabled = false;
            
            if (animated)
            {
                [UIView animateWithDuration:0.3 animations:^
                {
                    _nameLabel.alpha = 0.0f;
                    _statusLabel.alpha = 0.0f;
                    _callButton.alpha = 0.0f;
                    
                    _firstNameField.alpha = 1.0f;
                    _lastNameField.alpha = 1.0f;
                    _editingFirstNameSeparator.alpha = 1.0f;
                    _editingLastNameSeparator.alpha = 1.0f;
                }];
            }
            else
            {
                _nameLabel.alpha = 0.0f;
                _statusLabel.alpha = 0.0f;
                _callButton.alpha = 0.0f;
                
                _firstNameField.alpha = 1.0f;
                _lastNameField.alpha = 1.0f;
                _editingFirstNameSeparator.alpha = 1.0f;
                _editingLastNameSeparator.alpha = 1.0f;
            }
        }
        else
        {
            [self endEditing:true];
            
            _callButton.userInteractionEnabled = true;
            
            if (animated)
            {
                [UIView animateWithDuration:0.3 animations:^
                {
                    _nameLabel.alpha = 1.0f;
                    _statusLabel.alpha = 1.0f;
                    _callButton.alpha = 1.0f;
                    
                    _firstNameField.alpha = 0.0f;
                    _lastNameField.alpha = 0.0f;
                    _editingFirstNameSeparator.alpha = 0.0f;
                    _editingLastNameSeparator.alpha = 0.0f;
                } completion:^(BOOL finished)
                {
                    if (finished)
                    {
                        _firstNameField.hidden = true;
                        _lastNameField.hidden = true;
                        _editingFirstNameSeparator.hidden = true;
                        _editingLastNameSeparator.hidden = true;
                    }
                }];
            }
            else
            {
                _nameLabel.alpha = 1.0f;
                _statusLabel.alpha = 1.0f;
                _callButton.alpha = 1.0f;
                
                _firstNameField.alpha = 0.0f;
                _lastNameField.alpha = 0.0f;
                _editingFirstNameSeparator.alpha = 0.0f;
                _editingLastNameSeparator.alpha = 0.0f;
                
                _firstNameField.hidden = true;
                _lastNameField.hidden = true;
                _editingFirstNameSeparator.hidden = true;
                _editingLastNameSeparator.hidden = true;
            }
        }
        
        [_avatarView setFirstName:_editing ? _firstNameField.text : _firstName lastName:_editing ? _lastNameField.text : _lastName];
    }
}

- (void)setStatus:(NSString *)status active:(bool)active
{
    if (!TGStringCompare(status, _statusLabel.text))
    {
        _statusLabel.text = status;
        _statusLabel.textColor = active ? TGAccentColor() : UIColorRGB(0xb3b3b3);
        [self setNeedsLayout];
    }
}

- (void)setAvatarUri:(NSString *)avatarUri animated:(bool)animated synchronous:(bool)synchronous
{
    static UIImage *placeholder = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        //!placeholder
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(64.0f, 64.0f), false, 0.0f);
        CGContextRef context = UIGraphicsGetCurrentContext();
        
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
    {
        [_avatarView loadUserPlaceholderWithSize:CGSizeMake(64.0f, 64.0f) uid:_uidForPlaceholderCalculation firstName:_firstName lastName:_lastName placeholder:placeholder];
    }
    else if (!TGStringCompare([_avatarView currentUrl], avatarUri))
    {
        _avatarView.fadeTransitionDuration = animated ? 0.3 : 0.1;
        _avatarView.contentHints = synchronous ? TGRemoteImageContentHintLoadFromDiskSynchronously : 0;
        [_avatarView loadImage:avatarUri filter:@"circle:64x64" placeholder:currentPlaceholder forceFade:animated];
    }
}

- (void)setAvatarImage:(UIImage *)avatarImage animated:(bool)__unused animated
{
    [_avatarView loadImage:avatarImage];
}

- (void)setUpdatingAvatar:(bool)updatingAvatar animated:(bool)animated
{
    if (updatingAvatar)
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

- (void)setAvatarOffset:(CGSize)avatarOffset
{
    _avatarOffset = avatarOffset;
    
    [self setNeedsLayout];
}

- (void)setNameOffset:(CGSize)nameOffset
{
    _nameOffset = nameOffset;
    
    [self setNeedsLayout];
}

- (void)setShowCall:(bool)showCall
{
    _callButton.hidden = !showCall;
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect bounds = self.bounds;
    
    _avatarView.frame = CGRectMake(15.0f + _avatarOffset.width, 16.0f + _avatarOffset.height, 66.0f, 66.0f);
    
    _callButton.frame = CGRectMake(self.frame.size.width - 57.0f, 25.0f, _callButton.frame.size.width, _callButton.frame.size.height);
    
    CGFloat maxNameWidth = bounds.size.width - 92 - 14;
    CGFloat maxStatusWidth = bounds.size.width - 92 - 14;
    
    if (_verifiedIcon.superview != nil) {
        maxNameWidth -= _verifiedIcon.bounds.size.width + 5.0f;
    }
    if (!_callButton.hidden) {
        maxNameWidth -= 54.0f;
        maxStatusWidth -= 54.0f;
    }
    
    CGSize nameLabelSize = [_nameLabel sizeThatFits:CGSizeMake(maxNameWidth, 1000)];
    nameLabelSize.width = MIN(nameLabelSize.width, maxNameWidth);
    CGRect firstNameLabelFrame = CGRectMake(92 + _nameOffset.width, 26 + TGRetinaPixel + _nameOffset.height, nameLabelSize.width, nameLabelSize.height);
    _nameLabel.frame = firstNameLabelFrame;
    
    CGSize statusLabelSize = [_statusLabel sizeThatFits:CGSizeMake(maxStatusWidth, 1000)];
    statusLabelSize.width = MIN(statusLabelSize.width, maxStatusWidth);
    CGRect statusLabelFrame = CGRectMake(92 + _nameOffset.width, 53 + _nameOffset.height, statusLabelSize.width, statusLabelSize.height);
    if (!CGRectEqualToRect(statusLabelFrame, _statusLabel.frame))
        _statusLabel.frame = statusLabelFrame;
    
    CGFloat fieldLeftPadding = 100.0f;
    
    CGRect firstNameFieldFrame = CGRectMake(fieldLeftPadding + 13.0f, 12 + TGRetinaPixel, bounds.size.width - fieldLeftPadding - 14.0f - 13.0f, 30);
    _firstNameField.frame = firstNameFieldFrame;
    
    CGRect lastNameFieldFrame = CGRectMake(fieldLeftPadding + 13.0f, 56 + TGRetinaPixel, bounds.size.width - fieldLeftPadding - 14.0f - 13.0f, 30);
    _lastNameField.frame = lastNameFieldFrame;
    
    CGFloat separatorHeight = TGScreenPixel;
    _editingFirstNameSeparator.frame = CGRectMake(fieldLeftPadding, 49.0f, bounds.size.width - fieldLeftPadding, separatorHeight);
    _editingLastNameSeparator.frame = CGRectMake(fieldLeftPadding, 88.0f, bounds.size.width - fieldLeftPadding, separatorHeight);
    
    if (_verifiedIcon.superview != nil) {
        _verifiedIcon.frame = CGRectOffset(_verifiedIcon.bounds, firstNameLabelFrame.origin.x + nameLabelSize.width + 4.0f, firstNameLabelFrame.origin.y + 5.0f + TGRetinaPixel);
    }
}

#pragma mark -

- (void)avatarTapGesture:(UITapGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateRecognized)
    {
        [_itemHandle requestAction:@"avatarTapped" options:nil];
    }
}

- (void)textFieldDidChange:(UITextField *)textField
{
    if (textField == _firstNameField || textField == _lastNameField)
    {
        if (textField.text.length > 64)
            textField.text = [textField.text substringToIndex:64];
     
        if (_editing)
        {
            NSString *nameText = nil;
            if (_firstNameField.text.length != 0 && _lastNameField.text.length != 0)
                nameText = [[NSString alloc] initWithFormat:@"%@ %@", _firstNameField.text, _lastNameField.text];
            else if (_firstNameField.text != nil)
                nameText = _firstNameField.text;
            else if (_lastNameField.text != nil)
                nameText = _lastNameField.text;
            
            _nameLabel.text = nameText;
            
            if (_editing)
                [_avatarView setFirstName:_firstNameField.text lastName:_lastNameField.text];
            
            [self setNeedsLayout];
            
            [_itemHandle requestAction:@"editingNameChanged" options:@{@"field": textField == _firstNameField ? @"firstName" : @"lastName", @"text": textField.text == nil ? @"" : textField.text}];
        }
    }
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

@end
