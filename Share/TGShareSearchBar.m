#import "TGShareSearchBar.h"
#import "TGShareButton.h"

#import <LegacyDatabase/LegacyDatabase.h>

@interface TGShareSearchBar () <UITextFieldDelegate>
{
    CGFloat _cancelButtonWidth;
}

@property (nonatomic, strong) UIView *wrappingClip;
@property (nonatomic, strong) UIView *wrappingView;

@property (nonatomic, strong) UIImageView *textFieldBackground;

@property (nonatomic, strong) UIImage *normalTextFieldBackgroundImage;
@property (nonatomic, strong) UIImage *activeTextFieldBackgroundImage;

@property (nonatomic, strong) TGShareButton *customCancelButton;

@property (nonatomic) bool showsCustomCancelButton;
@property (nonatomic, strong) UILabel *placeholderLabel;
@property (nonatomic, strong) UIImageView *customSearchIcon;
@property (nonatomic, strong) UIActivityIndicatorView *customSearchActivityIndicator;
@property (nonatomic, strong) NSTimer *searchActivityTimer;
@property (nonatomic, strong) UIButton *customClearButton;

@end

@implementation TGShareSearchBar

+ (CGFloat)searchBarBaseHeight
{
    return 44.0f;
}

- (CGFloat)baseHeight {
    return [self inputHeight] + 12.0f;
}

- (CGFloat)inputContentOffset {
    return 0.0f;
}

- (CGFloat)searchIconOffset {
    return 0.0f;
}

- (CGFloat)inputHeight {
    return 28.0f;
}

+ (CGFloat)searchBarScopeHeight
{
    return 44.0f;
}

- (CGFloat)topPadding
{
    return -1.0f;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        _delayActivity = true;
        
        _wrappingClip = [[UIView alloc] initWithFrame:CGRectMake(0.0f, -20.0f, frame.size.width, frame.size.height + 20.0f)];
        _wrappingClip.clipsToBounds = true;
        [self addSubview:_wrappingClip];
        
        _wrappingView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 20.0f, frame.size.width, frame.size.height)];
        [_wrappingClip addSubview:_wrappingView];
        
        static UIImage *image = nil;
        static UIImage *imagePlain = nil;
        
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^
        {
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(1.0f, 3.0f), true, 0.0f);
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
            CGContextFillRect(context, CGRectMake(0.0f, 0.0f, 1.0f, 3.0f));
            imagePlain = [UIGraphicsGetImageFromCurrentImageContext() stretchableImageWithLeftCapWidth:0 topCapHeight:1];
            
            
            CGContextSetFillColorWithColor(context, TGColorWithHex(0xc8c7cc).CGColor);
            CGFloat separatorHeight = 1.0f / [[UIScreen mainScreen] scale];
            CGContextFillRect(context, CGRectMake(0.0f, 3.0f - separatorHeight, 1.0f, separatorHeight));
            
            image = [UIGraphicsGetImageFromCurrentImageContext() stretchableImageWithLeftCapWidth:0 topCapHeight:1];
            UIGraphicsEndImageContext();
        });
        
        _customBackgroundView = [[UIImageView alloc] initWithFrame:self.bounds];
        _customBackgroundView.image = imagePlain;
        _customBackgroundView.userInteractionEnabled = true;
        [_customBackgroundView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTapGesture:)]];
        [_wrappingView addSubview:_customBackgroundView];
        
        _customActiveBackgroundView = [[UIImageView alloc] initWithFrame:self.bounds];
        _customActiveBackgroundView.image = image;
        _customActiveBackgroundView.alpha = 0.0f;
        [_wrappingView addSubview:_customActiveBackgroundView];
        
        _textFieldBackground = [[UIImageView alloc] initWithImage:self.normalTextFieldBackgroundImage];
        _textFieldBackground.userInteractionEnabled = false;
        [_wrappingView addSubview:_textFieldBackground];
        
        UIColor *placeholderColor = TGColorWithHex(0x8e8e93);
        
        _placeholderLabel = [[UILabel alloc] init];
        _placeholderLabel.textAlignment = NSTextAlignmentLeft;
        _placeholderLabel.userInteractionEnabled = false;
        _placeholderLabel.textColor = placeholderColor;
        _placeholderLabel.backgroundColor = [UIColor clearColor];
        _placeholderLabel.font = [UIFont systemFontOfSize:14.0f];
        _placeholderLabel.text = NSLocalizedString(@"Share.Search", nil);
        [_wrappingView addSubview:_placeholderLabel];
        
        NSString *iconFileName = @"SearchBarIconLight.png";
        _customSearchIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:iconFileName]];
        _customSearchIcon.userInteractionEnabled = false;
        [_wrappingView addSubview:_customSearchIcon];
        
        _customSearchActivityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:4];
        _customSearchActivityIndicator.alpha = 0.4f;
        _customSearchActivityIndicator.userInteractionEnabled = false;
        _customSearchActivityIndicator.hidden = true;
        [_wrappingView addSubview:_customSearchActivityIndicator];
    }
    return self;
}

- (void)setAlwaysExtended:(bool)alwaysExtended
{
    if (_alwaysExtended != alwaysExtended)
    {
        _alwaysExtended = alwaysExtended;
        
        [self layoutSubviews];
    }
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
}

- (void)sizeToFit
{
    CGFloat requiredHeight = [self baseHeight];
    
    CGRect frame = self.frame;
    frame.size.height = requiredHeight;
    self.frame = frame;
}

- (BOOL)showsCancelButton
{
    return _showsCustomCancelButton;
}

- (UIImage *)normalTextFieldBackgroundImage
{
    if (_normalTextFieldBackgroundImage == nil)
    {
        NSString *fileName = @"SearchInputFieldLight.png";
        
        UIImage *rawImage = [UIImage imageNamed:fileName];
        _normalTextFieldBackgroundImage = [rawImage stretchableImageWithLeftCapWidth:(int)(rawImage.size.width / 2) topCapHeight:(int)(rawImage.size.height / 2)];
    }
    
    return _normalTextFieldBackgroundImage;
}

- (UIImage *)activeTextFieldBackgroundImage
{
    if (_activeTextFieldBackgroundImage == nil)
    {
        NSString *fileName = @"SearchInputFieldLight.png";
    
        UIImage *rawImage = [UIImage imageNamed:fileName];
        _activeTextFieldBackgroundImage = [rawImage stretchableImageWithLeftCapWidth:(int)(rawImage.size.width / 2) topCapHeight:(int)(rawImage.size.height / 2)];
    }
    
    return _activeTextFieldBackgroundImage;
}

- (UITextField *)maybeCustomTextField
{
    return _customTextField;
}

- (UITextField *)customTextField
{
    if (_customTextField == nil)
    {
        CGRect frame = _textFieldBackground.frame;
        frame.origin.x += 27;
        frame.size.width -= 27 + 8 + 14;
        _customTextField = [[UITextField alloc] initWithFrame:frame];
        _customTextField.font = _placeholderLabel.font;
        _customTextField.textAlignment = NSTextAlignmentNatural;
        _customTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _customTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        
        UIColor *textColor = [UIColor blackColor];
        UIImage *clearImage = [UIImage imageNamed:@"SearchBarClearIcon.png"];
        
        _customTextField.textColor = textColor;
        
        _customTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        _customTextField.returnKeyType = UIReturnKeySearch;
        _customTextField.keyboardAppearance = UIKeyboardAppearanceDefault;
        _customTextField.delegate = self;
        [_customTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        
        _customClearButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, clearImage.size.width, clearImage.size.height)];
        [_customClearButton setBackgroundImage:clearImage forState:UIControlStateNormal];
        [_customClearButton addTarget:self action:@selector(customClearButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        _customClearButton.hidden = true;
        
        [_wrappingView addSubview:_customTextField];
        [_wrappingView addSubview:_customClearButton];
        
        [self setNeedsLayout];
    }
    
    return _customTextField;
}

- (UIButton *)customCancelButton
{
    if (_customCancelButton == nil)
    {
        _cancelButtonWidth = [NSLocalizedString(@"Share.Cancel", nil) sizeWithFont:[UIFont systemFontOfSize:17.0f]].width + 11.0f;
        
        CGRect textFieldBackgroundFrame = _textFieldBackground.frame;
        _customCancelButton = [[TGShareButton alloc] initWithFrame:CGRectMake(textFieldBackgroundFrame.origin.x + textFieldBackgroundFrame.size.width + 10, 0, _cancelButtonWidth, [self baseHeight])];
        [_customCancelButton setTitle:NSLocalizedString(@"Share.Cancel", nil) forState:UIControlStateNormal];
        
        UIColor *buttonColor = TGAccentColor();
        
        [_customCancelButton setTitleColor:buttonColor];
        _customCancelButton.titleLabel.font = [UIFont systemFontOfSize:17.0f];
        _customCancelButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        _customCancelButton.hidden = true;
        [_customCancelButton addTarget:self action:@selector(searchCancelButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [_wrappingView addSubview:_customCancelButton];
    }
    
    return _customCancelButton;
}

- (void)setShowsCancelButton:(BOOL)showsCancelButton
{
    [self setShowsCancelButton:showsCancelButton animated:false];
}

- (void)setShowsCancelButton:(bool)showsCancelButton animated:(bool)animated
{
    if (_showsCustomCancelButton != showsCancelButton)
    {
        if (showsCancelButton)
        {
            [self customCancelButton];
            _customCancelButton.hidden = _hidesCancelButton;
        }
        else
        {
            [_customTextField setText:@""];
            [self updatePlaceholder:@""];
        }
        
        _textFieldBackground.image = showsCancelButton ? self.activeTextFieldBackgroundImage : self.normalTextFieldBackgroundImage;
        
        _showsCustomCancelButton = showsCancelButton;
        
        if (animated)
        {
            if (showsCancelButton)
                _wrappingClip.clipsToBounds = false;
            
            [UIView animateWithDuration:0.2 animations:^
            {
                 if (!showsCancelButton)
                 {
                     _customTextField.alpha = 0.0f;
                     _customClearButton.alpha = 0.0f;
                 }
                
                 [self layoutSubviews];
                 
                 _customActiveBackgroundView.alpha = showsCancelButton ? 1.0f : 0.0f;
             } completion:^(__unused BOOL finished)
             {
                 //if (finished)
                 {
                     if (showsCancelButton)
                     {
                         _customTextField.alpha = 1.0f;
                         _customClearButton.alpha = 1.0f;
                     }
                     else
                     {
                         _customCancelButton.hidden = true;
                         
                         _wrappingClip.clipsToBounds = true;
                     }
                 }
             }];
        }
        else
        {
            _wrappingClip.clipsToBounds = !showsCancelButton;
            
            _customTextField.alpha = showsCancelButton ? 1.0f : 0.0f;
            _customClearButton.alpha = _customTextField.alpha;
            _customActiveBackgroundView.alpha = showsCancelButton ? 1.0f : 0.0f;
            _customCancelButton.hidden = !showsCancelButton;
            
            [self layoutSubviews];
        }
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect bounds = self.bounds;
    
    CGRect clippingFrame = _wrappingClip.frame;
    clippingFrame.size = CGSizeMake(bounds.size.width, bounds.size.height + 20.0f);
    _wrappingClip.frame = clippingFrame;
    
    CGRect wrappingFrame = _wrappingView.frame;
    wrappingFrame.size = bounds.size;
    _wrappingView.frame = wrappingFrame;
    
    float retinaPixel = 0.5f;
    
    CGFloat rightPadding = _showsCustomCancelButton && !_hidesCancelButton ? _cancelButtonWidth : 0.0f;
    
    _customBackgroundView.frame = CGRectMake(0, ((_showsCustomCancelButton || _alwaysExtended) ? -20.0f : 0.0f), self.frame.size.width, self.frame.size.height + (_showsCustomCancelButton || _alwaysExtended ? 20.0f : 0.0f));
    _customActiveBackgroundView.frame = _customBackgroundView.frame;
    
    CGSize placeholderSize = [_placeholderLabel.text sizeWithFont:_placeholderLabel.font];
    placeholderSize.width = MIN(placeholderSize.width, self.frame.size.width - rightPadding - 40.0f);
    
    _textFieldBackground.frame = CGRectMake(8, 9 + [self topPadding], self.frame.size.width - 16 - rightPadding, [self inputHeight]);
    
    _customSearchIcon.frame = CGRectMake(_showsCustomCancelButton ? (_textFieldBackground.frame.origin.x + 8.0f) : ((floor((self.frame.size.width - placeholderSize.width) / 2) + 10 + retinaPixel) - 20), [self searchIconOffset] + [self inputContentOffset] + 16 + retinaPixel + [self topPadding], _customSearchIcon.frame.size.width, _customSearchIcon.frame.size.height);
    
    _customSearchActivityIndicator.frame = (CGRect){{floor(_customSearchIcon.frame.origin.x + (_customSearchIcon.frame.size.width - _customSearchActivityIndicator.frame.size.width) / 2.0f), floor(_customSearchIcon.frame.origin.y + (_customSearchIcon.frame.size.height - _customSearchActivityIndicator.frame.size.height) / 2.0f) + 1.0f + retinaPixel}, _customSearchActivityIndicator.frame.size};
    
    bool isRTL = false;
    _placeholderLabel.frame = CGRectMake(_showsCustomCancelButton ? (isRTL ? (CGRectGetMaxX(_textFieldBackground.frame) - placeholderSize.width - 32.0f) : 36) : (floor((self.frame.size.width - placeholderSize.width) / 2) + 10 + retinaPixel), [self inputContentOffset] + 14 + [self topPadding], placeholderSize.width, placeholderSize.height);
    
    if (_customTextField != nil)
    {
        CGRect frame = _textFieldBackground.frame;
        frame.origin.y -= retinaPixel;
        frame.origin.x += 27;
        frame.size.width -= 27 + 8 + 24;
        _customTextField.frame = frame;
        
        _customClearButton.frame = CGRectMake(CGRectGetMaxX(_textFieldBackground.frame) - 22, [self inputContentOffset] + 16 + [self topPadding], _customClearButton.frame.size.width, _customClearButton.frame.size.height);
    }
    
    if (_customCancelButton != nil)
    {
        _customCancelButton.frame = CGRectMake(self.frame.size.width + (_showsCustomCancelButton ? (-_customCancelButton.frame.size.width - 9) : 9), [self topPadding] + 2.0f, _cancelButtonWidth, [self baseHeight]);
    }
}

#pragma mark -

- (void)tappedSearchBar:(id)__unused arg
{
}

- (BOOL)becomeFirstResponder
{
    if (![_customTextField isFirstResponder])
    {
        bool shouldBeginEditing = true;
        id<UISearchBarDelegate> delegate = self.delegate;
        if ([delegate respondsToSelector:@selector(searchBarShouldBeginEditing:)])
            shouldBeginEditing = [delegate searchBarShouldBeginEditing:(UISearchBar *)self];
        
        if (shouldBeginEditing)
        {
            [self.customTextField becomeFirstResponder];
            
            if ([delegate respondsToSelector:@selector(searchBarTextDidBeginEditing:)])
                [delegate searchBarTextDidBeginEditing:(UISearchBar *)self];
            
            return true;
        }
    }
    
    return false;
}

- (BOOL)resignFirstResponder
{
    return [_customTextField resignFirstResponder];
}

- (BOOL)canBecomeFirstResponder
{
    return _customTextField == nil || [_customTextField canBecomeFirstResponder];
}

- (BOOL)canResignFirstResponder
{
    return [_customTextField canResignFirstResponder];
}

#pragma mark -

- (void)searchCancelButtonPressed
{
    id delegate = self.delegate;
    
    if ([delegate respondsToSelector:@selector(searchBarCancelButtonClicked:)])
        [delegate searchBarCancelButtonClicked:(UISearchBar *)self];
}

- (void)backgroundTapGesture:(UITapGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateRecognized)
    {
        if (![_customTextField isFirstResponder])
        {
            bool shouldBeginEditing = true;
            id<UISearchBarDelegate> delegate = self.delegate;
            if ([delegate respondsToSelector:@selector(searchBarShouldBeginEditing:)])
                shouldBeginEditing = [delegate searchBarShouldBeginEditing:(UISearchBar *)self];
            
            if (shouldBeginEditing)
            {
                [self.customTextField becomeFirstResponder];
                
                if ([delegate respondsToSelector:@selector(searchBarTextDidBeginEditing:)])
                    [delegate searchBarTextDidBeginEditing:(UISearchBar *)self];
            }
        }
    }
}

- (void)updatePlaceholder:(NSString *)text
{
    _placeholderLabel.hidden = text.length != 0;
    _customClearButton.hidden = !_placeholderLabel.hidden;
}

- (void)textFieldDidChange:(UITextField *)textField
{
    if (textField == _customTextField)
    {
        NSString *text = textField.text;
        
        id<UISearchBarDelegate> delegate = self.delegate;
        if ([delegate respondsToSelector:@selector(searchBar:textDidChange:)])
            [delegate searchBar:(UISearchBar *)self textDidChange:text];
        
        [self updatePlaceholder:text];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == _customTextField)
    {
        if (textField.text.length != 0)
        {
            id<UISearchBarDelegate> delegate = self.delegate;
            if ([delegate respondsToSelector:@selector(searchBarSearchButtonClicked:)])
                [delegate searchBarSearchButtonClicked:(UISearchBar *)self];
        }
        
        [textField resignFirstResponder];
        
        return false;
    }
    
    return false;
}

- (void)customClearButtonPressed
{
    [_customTextField setText:@""];
    [self updatePlaceholder:@""];
    
    [self becomeFirstResponder];
    
    NSString *text = @"";
    
    id<UISearchBarDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(searchBar:textDidChange:)])
        [delegate searchBar:(UISearchBar *)self textDidChange:text];
}

- (void)setPlaceholder:(NSString *)placeholder
{
    _placeholder = placeholder;
    _placeholderLabel.text = placeholder;
    
    [self setNeedsLayout];
}

- (NSString *)text
{
    return _customTextField.text;
}

- (void)setText:(NSString *)text
{
    bool layout = _customTextField == nil;
    self.customTextField.text = text;
    if (layout)
        [self setNeedsLayout];
    
    [self textFieldDidChange:_customTextField];
}

- (void)updateClipping:(CGFloat)clippedHeight
{
    CGFloat offset = self.frame.size.height + MAX(0.0f, MIN(clippedHeight, self.frame.size.height));
    
    CGRect frame = _wrappingClip.frame;
    frame.origin.y = offset - frame.size.height + 20.0f;
    _wrappingClip.frame = frame;
    
    CGRect wrapFrame = _wrappingView.frame;
    wrapFrame.origin.y = -offset + wrapFrame.size.height;
    _wrappingView.frame = wrapFrame;
}

- (void)setShowActivity:(bool)showActivity
{
    if (_showActivity != showActivity)
    {
        [_searchActivityTimer invalidate];
        _searchActivityTimer = nil;
        
        _showActivity = showActivity;
        
        if (_delayActivity && showActivity)
        {
            //_searchActivityTimer = [TGTimerTarget scheduledMainThreadTimerWithTarget:self action:@selector(searchActivityTimerEvent) interval:0.2 repeat:false];
        }
        else
            [self searchActivityTimerEvent];
    }
}

- (void)searchActivityTimerEvent
{
    _customSearchIcon.hidden = _showActivity;
    if (_showActivity)
    {
        _customSearchActivityIndicator.hidden = false;
        [_customSearchActivityIndicator startAnimating];
    }
    else
    {
        _customSearchActivityIndicator.hidden = true;
        [_customSearchActivityIndicator stopAnimating];
    }
}

@end
