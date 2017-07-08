#import "TGShareCaptionPanel.h"

#import <LegacyDatabase/LegacyDatabase.h>

#import "TGStringUtils.h"
#import "TGShareTextViewInternal.h"
#import "TGShareButton.h"

static void setViewFrame(UIView *view, CGRect frame)
{
    CGAffineTransform transform = view.transform;
    view.transform = CGAffineTransformIdentity;
    if (!CGRectEqualToRect(view.frame, frame))
        view.frame = frame;
    view.transform = transform;
}

@interface TGShareCaptionPanel () <TGShareGrowingTextViewDelegate>
{
    CGFloat _keyboardHeight;
    NSString *_caption;
    bool _dismissing;
    bool _dismissDisabled;
    
    UIView *_wrapperView;
    UIView *_backgroundView;
    UIImageView *_fieldBackground;
    UIView *_inputFieldClippingContainer;
    TGShareGrowingTextView *_inputField;
    UILabel *_placeholderLabel;
    
    UILabel *_inputFieldOnelineLabel;
    
    UILabel *_counterLabel;
    
    CGFloat _contentAreaHeight;
    
    TGShareButton *_sendButton;
}

@end

@implementation TGShareCaptionPanel

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        static UIImage *placeholderImage = nil;
        
        if (placeholderImage == nil)
        {
            NSString *placeholderText = NSLocalizedString(@"Share.AddCaption", nil);
            UIFont *placeholderFont = [UIFont systemFontOfSize:16];
            CGSize placeholderSize = [placeholderText sizeWithFont:placeholderFont];
            placeholderSize.width += 2.0f;
            placeholderSize.height += 2.0f;
            
            UIGraphicsBeginImageContextWithOptions(placeholderSize, false, 0.0f);
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextSetFillColorWithColor(context, TGColorWithHex(0xffffff).CGColor);
            [placeholderText drawAtPoint:CGPointMake(1.0f, 1.0f) withFont:placeholderFont];
            placeholderImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
        
        UIView *backgroundWrapperView = [[UIView alloc] initWithFrame:frame];
        backgroundWrapperView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        backgroundWrapperView.clipsToBounds = true;
        [self addSubview:backgroundWrapperView];
        
        _wrapperView = [[UIView alloc] initWithFrame:frame];
        _wrapperView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:_wrapperView];
        
        _backgroundView = [[UIView alloc] initWithFrame:_wrapperView.bounds];
        _backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _backgroundView.backgroundColor = TGColorWithHex(0xf7f7f7);
        [backgroundWrapperView addSubview:_backgroundView];
        
        CGFloat separatorHeight = 1.0f / [[UIScreen mainScreen] scale];
        UIView *stripeView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, -separatorHeight, self.frame.size.width, separatorHeight)];
        stripeView.backgroundColor = TGColorWithHex(0xb2b2b2);
        stripeView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [_wrapperView addSubview:stripeView];
        
        _fieldBackground = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"ModernConversationInput.png"] stretchableImageWithLeftCapWidth:16 topCapHeight:16]];
        _fieldBackground.userInteractionEnabled = true;
        [_wrapperView addSubview:_fieldBackground];
        
        _placeholderLabel = [[UILabel alloc] init];
        _placeholderLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        _placeholderLabel.backgroundColor = [UIColor clearColor];
        _placeholderLabel.font = [UIFont systemFontOfSize:16];
        _placeholderLabel.textColor = TGColorWithHex(0xbebec0);
        _placeholderLabel.text = NSLocalizedString(@"Share.AddCaption", nil);
        _placeholderLabel.userInteractionEnabled = true;
        [_placeholderLabel sizeToFit];
        [_wrapperView addSubview:_placeholderLabel];
        
        _inputFieldOnelineLabel = [[UILabel alloc] init];
        _inputFieldOnelineLabel.backgroundColor = [UIColor clearColor];
        _inputFieldOnelineLabel.font = [UIFont systemFontOfSize:16];
        _inputFieldOnelineLabel.hidden = true;
        _inputFieldOnelineLabel.numberOfLines = 1;
        _inputFieldOnelineLabel.textColor = [UIColor blackColor];
        _inputFieldOnelineLabel.userInteractionEnabled = false;
        //[_wrapperView addSubview:_inputFieldOnelineLabel];
        
        _sendButton = [[TGShareButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 45.0f, 45.0f)];
        _sendButton.adjustsImageWhenHighlighted = false;
        _sendButton.alpha = 0.0f;
        _sendButton.userInteractionEnabled = false;
        [_sendButton setImage:[UIImage imageNamed:@"ModernConversationSend"] forState:UIControlStateNormal];
        [_sendButton addTarget:self action:@selector(sendPressed) forControlEvents:UIControlEventTouchUpInside];
        [_wrapperView addSubview:_sendButton];
        
        [_wrapperView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleFieldBackgroundTap:)]];
    }
    return self;
}

- (void)createInputFieldIfNeeded
{
    if (_inputField != nil)
        return;
    
    CGRect inputFieldClippingFrame = _fieldBackground.frame;
    _inputFieldClippingContainer = [[UIView alloc] initWithFrame:inputFieldClippingFrame];
    _inputFieldClippingContainer.clipsToBounds = true;
    [_wrapperView addSubview:_inputFieldClippingContainer];
    
    CGFloat screenPixel = 1.0f / [[UIScreen mainScreen] scale];
    
    UIEdgeInsets inputFieldInternalEdgeInsets = [self _inputFieldInternalEdgeInsets];
    _inputField = [[TGShareGrowingTextView alloc] initWithFrame:CGRectMake(inputFieldInternalEdgeInsets.left, inputFieldInternalEdgeInsets.top + screenPixel, _inputFieldClippingContainer.frame.size.width - inputFieldInternalEdgeInsets.left - 24, _inputFieldClippingContainer.frame.size.height)];
    _inputField.textColor = [UIColor blackColor];
    _inputField.placeholderView = _placeholderLabel;
    _inputField.font = [UIFont systemFontOfSize:16];
    _inputField.clipsToBounds = true;
    _inputField.backgroundColor = nil;
    _inputField.opaque = false;
    _inputField.showPlaceholderWhenFocussed = true;
    _inputField.internalTextView.returnKeyType = UIReturnKeyDone;
    _inputField.internalTextView.backgroundColor = nil;
    _inputField.internalTextView.opaque = false;
    _inputField.internalTextView.contentMode = UIViewContentModeLeft;
    _inputField.maxNumberOfLines = [self _maxNumberOfLinesForSize:CGSizeMake(320.0f, 480.0f)];
    _inputField.delegate = self;
    
    _inputField.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(-inputFieldInternalEdgeInsets.top, 0, 5 - screenPixel, 0);
    
    _inputField.text = _caption;
    
    [_inputFieldClippingContainer addSubview:_inputField];
}

- (void)handleFieldBackgroundTap:(UITapGestureRecognizer *)__unused gestureRecognizer
{
    if (self.isCollapsed)
        return;
    
    [self createInputFieldIfNeeded];
    _inputFieldClippingContainer.hidden = false;
    _inputField.internalTextView.enableFirstResponder = true;
    [_inputField.internalTextView becomeFirstResponder];
}

- (bool)sendPressed
{
    NSMutableString *text = [[NSMutableString alloc] initWithString:_inputField.text == nil ? @"" : _inputField.text];
    int textLength = (int)text.length;
    for (int i = 0; i < textLength; i++)
    {
        unichar c = [text characterAtIndex:i];
        
        if (c == ' ' || c == '\t' || c == '\n')
        {
            [text deleteCharactersInRange:NSMakeRange(i, 1)];
            i--;
            textLength--;
        }
        else
            break;
    }
    
    for (int i = textLength - 1; i >= 0; i--)
    {
        unichar c = [text characterAtIndex:i];
        
        if (c == ' ' || c == '\t' || c == '\n')
        {
            [text deleteCharactersInRange:NSMakeRange(i, 1)];
            textLength--;
        }
        else
            break;
    }
    
    _inputField.internalTextView.text = text;
    
    id<TGShareCaptionPanelDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(inputPanelRequestedSend:text:)])
        [delegate inputPanelRequestedSend:self text:text];
    
    [_inputField.internalTextView resignFirstResponder];
    
    return true;
}

- (void)dismiss
{
    [_inputField.internalTextView resignFirstResponder];
}

#pragma mark -

- (void)setCollapsed:(bool)collapsed
{
    [self setCollapsed:collapsed animated:false];
}

- (void)setCollapsed:(bool)collapsed animated:(bool)animated
{
    _collapsed = collapsed;
    
    void (^frameChangeBlock)(void) = ^
    {
        _backgroundView.frame = CGRectMake(_backgroundView.frame.origin.x,
                                           collapsed ? self.frame.size.height : 0,
                                           _backgroundView.frame.size.width, _backgroundView.frame.size.height);
        _wrapperView.frame = CGRectMake(_wrapperView.frame.origin.x,
                                        collapsed ? self.frame.size.height : 0,
                                        _wrapperView.frame.size.width, _wrapperView.frame.size.height);
    };
    
    if (animated)
    {
        [UIView animateWithDuration:0.3f delay:0.0f options:7 << 16 animations:frameChangeBlock completion:nil];
    }
    else
    {
        frameChangeBlock();
    }
}

#pragma mark -

- (void)adjustForOrientation:(UIInterfaceOrientation)orientation keyboardHeight:(CGFloat)keyboardHeight duration:(NSTimeInterval)duration animationCurve:(NSInteger)animationCurve
{
    [self adjustForOrientation:orientation keyboardHeight:keyboardHeight duration:duration animationCurve:animationCurve completion:nil];
}

- (void)adjustForOrientation:(UIInterfaceOrientation)__unused orientation keyboardHeight:(CGFloat)keyboardHeight duration:(NSTimeInterval)duration animationCurve:(NSInteger)animationCurve completion:(void (^)(void))completion
{
    _keyboardHeight = keyboardHeight;
    
    void(^changeBlock)(void) = ^
    {
        bool isKeyboardVisible = (keyboardHeight > FLT_EPSILON);
        CGFloat inputContainerHeight = [self heightForInputFieldHeight:_inputField.frame.size.height];
        CGSize screenSize = self.superview.frame.size;
        
        if (isKeyboardVisible)
        {
            self.frame = CGRectMake(self.frame.origin.x, screenSize.height - keyboardHeight - inputContainerHeight, self.frame.size.width, inputContainerHeight + keyboardHeight);
        }
        else
        {
            self.frame = CGRectMake(self.frame.origin.x, screenSize.height - inputContainerHeight, self.frame.size.width, inputContainerHeight);
        }
        
        [self layoutSubviews];
    };
    
    void (^finishedBlock)(BOOL) = ^(__unused BOOL finished)
    {
        if (completion != nil)
            completion();
    };
    
    if (duration > DBL_EPSILON)
    {
        [UIView animateWithDuration:duration delay:0.0f options:animationCurve animations:changeBlock completion:finishedBlock];
    }
    else
    {
        changeBlock();
        finishedBlock(true);
    }
}

#pragma mark -

- (NSString *)caption
{
    return _caption;
}

- (void)setCaption:(NSString *)caption
{
    [self setCaption:caption animated:false];
}

- (void)setCaption:(NSString *)caption animated:(bool)animated
{
    NSString *previousCaption = _caption;
    _caption = caption;
    
    if (animated)
    {
        _inputFieldOnelineLabel.text = [self oneLinedCaptionForText:caption];
        
        if ([previousCaption isEqualToString:caption] || (previousCaption.length == 0 && caption.length == 0))
            return;
        
        UIView *snapshotView = nil;
        UIView *snapshottedView = nil;
        UIView *fadingInView = nil;
        if (previousCaption.length > 0)
            snapshottedView = _inputFieldOnelineLabel;
        else
            snapshottedView = _placeholderLabel;
        
        snapshotView = [snapshottedView snapshotViewAfterScreenUpdates:false];
        snapshotView.frame = snapshottedView.frame;
        [snapshottedView.superview addSubview:snapshotView];
        
        if (previousCaption.length > 0 && caption.length == 0)
            fadingInView = _placeholderLabel;
        else
            fadingInView = _inputFieldOnelineLabel;
        
        fadingInView.hidden = false;
        fadingInView.alpha = 0.0f;
        
        _placeholderLabel.hidden = (caption.length > 0);
        
        [UIView animateWithDuration:0.3f delay:0.05f options:UIViewAnimationOptionCurveEaseInOut animations:^
         {
             fadingInView.alpha = 1.0f;
         } completion:nil];
        
        [UIView animateWithDuration:0.21f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^
         {
             snapshotView.alpha = 0.0f;
         } completion:^(__unused BOOL finished)
         {
             [snapshotView removeFromSuperview];
         }];
    }
    else
    {
        _inputFieldOnelineLabel.text = [self oneLinedCaptionForText:caption];
        _inputFieldOnelineLabel.hidden = (caption.length == 0);
        _placeholderLabel.hidden = !_inputFieldOnelineLabel.hidden;
    }
    
    _inputField.text = caption;
}

#pragma mark -

- (BOOL)becomeFirstResponder
{
    [self handleFieldBackgroundTap:nil];
    return true;
}

- (BOOL)isFirstResponder
{
    return _inputField.internalTextView.isFirstResponder;
}

- (void)growingTextViewDidBeginEditing:(TGShareGrowingTextView *)__unused growingTextView
{
    id<TGShareCaptionPanelDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(inputPanelFocused:)])
        [delegate inputPanelFocused:self];
    
//    _inputField.alpha = 0.0f;
//    [UIView animateWithDuration:0.2f animations:^
//     {
//         _inputField.alpha = 1.0f;
//         _inputFieldOnelineLabel.alpha = 0.0f;
//     } completion:^(BOOL finished)
//     {
//         if (finished)
//         {
//             _inputFieldOnelineLabel.alpha = 1.0f;
//             _inputFieldOnelineLabel.hidden = true;
//         }
//     }];
    
    if (_keyboardHeight < FLT_EPSILON)
    {
        [self adjustForOrientation:UIInterfaceOrientationPortrait keyboardHeight:0 duration:0.2f animationCurve:7 << 16];
    }
    
    [_inputField refreshHeight:false];
}

-(void)growingTextViewDidEndEditing:(TGShareGrowingTextView *)__unused growingTextView
{
    _caption = _inputField.text;
//    _inputFieldOnelineLabel.text = [self oneLinedCaptionForText:_caption];
//    _inputFieldOnelineLabel.alpha = 0.0f;
//    _inputFieldOnelineLabel.hidden = false;
//    
//    [UIView animateWithDuration:0.2f animations:^
//     {
//         _inputField.alpha = 0.0f;
//         _inputFieldOnelineLabel.alpha = 1.0f;
//     } completion:^(BOOL finished)
//     {
//         if (finished)
//         {
//             _inputField.alpha = 1.0f;
//             _inputFieldClippingContainer.hidden = true;
//         }
//     }];
//    
    [_inputField refreshHeight:false];
}

- (void)growingTextView:(TGShareGrowingTextView *)__unused growingTextView willChangeHeight:(CGFloat)height duration:(NSTimeInterval)duration animationCurve:(int)animationCurve
{
    UIEdgeInsets inputFieldInsets = [self _inputFieldInsets];
    CGFloat inputContainerHeight = MAX([self baseHeight], height - 8 + inputFieldInsets.top + inputFieldInsets.bottom);
    
    id<TGShareCaptionPanelDelegate> delegate = (id<TGShareCaptionPanelDelegate>)self.delegate;
    if ([delegate respondsToSelector:@selector(inputPanelWillChangeHeight:height:duration:animationCurve:)])
    {
        [delegate inputPanelWillChangeHeight:self height:inputContainerHeight duration:duration animationCurve:animationCurve];
    }
}

- (void)growingTextViewDidChange:(TGShareGrowingTextView *)__unused growingTextView afterSetText:(bool)__unused afterSetText afterPastingText:(bool)__unused afterPastingText
{
    id<TGShareCaptionPanelDelegate> delegate = (id<TGShareCaptionPanelDelegate>)self.delegate;
    
    NSString *text = growingTextView.text;
    [self updateSendButton];
    
    if ([delegate respondsToSelector:@selector(inputPanelTextChanged:text:)])
        [delegate inputPanelTextChanged:self text:text];
}

- (BOOL)growingTextViewShouldReturn:(TGShareGrowingTextView *)__unused growingTextView
{
    [self sendPressed];
    return false;
}

- (void)growingTextView:(TGShareGrowingTextView *)__unused growingTextView receivedReturnKeyCommandWithModifierFlags:(UIKeyModifierFlags)__unused flags
{
    [self sendPressed];
}

static void removeViewAnimation(UIView *view, NSString *animationPrefix)
{
    for (NSString *key in view.layer.animationKeys)
    {
        if ([key hasPrefix:animationPrefix])
            [view.layer removeAnimationForKey:key];
    }
}

- (void)updateSendButton
{
    CGFloat targetAlpha = _inputField.text.length > 0 ? 1.0 : 0.0f;
    bool targetUserInteraction = _inputField.text.length > 0 ? true : false;
    
    if (_sendButton.userInteractionEnabled != targetUserInteraction)
    {
        _sendButton.userInteractionEnabled = targetUserInteraction;
        
        if (_sendButton.layer.presentationLayer != nil)
            _sendButton.layer.transform = _sendButton.layer.presentationLayer.transform;
        removeViewAnimation(_sendButton, @"transform");
        
        if (_sendButton.layer.presentationLayer != nil)
            _sendButton.layer.opacity = _sendButton.layer.presentationLayer.opacity;
        removeViewAnimation(_sendButton, @"opacity");

        [UIView animateWithDuration:0.4 delay:0.0 usingSpringWithDamping:1.5 initialSpringVelocity:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^
        {
            if (targetAlpha > FLT_EPSILON)
                _sendButton.transform = CGAffineTransformIdentity;
            else
                _sendButton.transform = CGAffineTransformMakeScale(0.001f, 0.001f);
            
            [self layoutSubviews];
        } completion:nil];
        
        [UIView animateWithDuration:0.1 delay:(targetAlpha > FLT_EPSILON ? 0.1 : 0.0) options:kNilOptions animations:^
        {
            _sendButton.alpha = targetAlpha;
        } completion:nil];

    }
}

- (void)addNewLine
{
    self.caption = [NSString stringWithFormat:@"%@\n", self.caption];
}

- (NSString *)oneLinedCaptionForText:(NSString *)text
{
    static NSString *tokenString = nil;
    if (tokenString == nil)
    {
        unichar tokenChar = 0x2026;
        tokenString = [[NSString alloc] initWithCharacters:&tokenChar length:1];
    }
    
    if (text == nil)
        return nil;
    
    NSMutableString *string = [[NSMutableString alloc] initWithString:text];
    
    for (NSUInteger i = 0; i < string.length; i++)
    {
        unichar c = [text characterAtIndex:i];
        if (c == '\t' || c == '\n')
        {
            [string insertString:tokenString atIndex:i];
            break;
        }
    }
    
    return string;
}

- (void)setContentAreaHeight:(CGFloat)contentAreaHeight
{
    _contentAreaHeight = contentAreaHeight;
    [self setNeedsLayout];
}

#pragma mark - Style

- (UIEdgeInsets)_inputFieldInsets
{
    static UIEdgeInsets insets;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
            insets = UIEdgeInsetsMake(6.0f, 6.0f, 6.0f, 6.0f + 39.0f);
        else
            insets = UIEdgeInsetsMake(6.0f, 6.0f, 6.0f, 6.0f + 39.0f);
    });
    
    return insets;
}

- (UIEdgeInsets)_inputFieldInternalEdgeInsets
{
    static UIEdgeInsets insets;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
            insets = UIEdgeInsetsMake(-2.0f, 8.0f, 0.0f, 0.0f);
        else
            insets = UIEdgeInsetsMake(-2.0f, 8.0f, 0.0f, 0.0f);
    });
    
    return insets;
}

- (CGPoint)_inputFieldPlaceholderOffset
{
    static CGPoint offset;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
            offset = CGPointMake(12.0f, 5.0f + 1.0f / [[UIScreen mainScreen] scale]);
        else
            offset = CGPointMake(12.0f, 6.0f);
    });

    return offset;
}

- (CGFloat)heightForInputFieldHeight:(CGFloat)inputFieldHeight
{
    if (inputFieldHeight < FLT_EPSILON)
        inputFieldHeight = 36;
    
    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPhone)
        inputFieldHeight += 4;
    
    UIEdgeInsets inputFieldInsets = [self _inputFieldInsets];
    CGFloat height = MAX([self baseHeight], inputFieldHeight - 4 + inputFieldInsets.top + inputFieldInsets.bottom);
    
    return height;
}

- (CGFloat)baseHeight
{
    static CGFloat value = 0.0f;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        value = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 45.0f : 56.0f;
    });
    
    return value;
}

- (CGPoint)_setButtonOffset
{
    static CGPoint offset;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
            offset = CGPointZero;
        else
            offset = CGPointMake(-11.0f, -6.0f);
    });
    
    return offset;
}

- (int)_maxNumberOfLinesForSize:(CGSize)size
{
    if (size.height <= 320.0f - FLT_EPSILON) {
        return 3;
    } else if (size.height <= 480.0f - FLT_EPSILON) {
        return 5;
    } else {
        return 7;
    }
}

#pragma mark -

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect frame = self.frame;
    
    UIEdgeInsets inputFieldInsets = [self _inputFieldInsets];
  
    CGFloat inputContainerHeight = [self heightForInputFieldHeight:_inputField.frame.size.height];
    CGRect fieldFrame = CGRectMake(inputFieldInsets.left, inputFieldInsets.top, frame.size.width - inputFieldInsets.left - inputFieldInsets.right, inputContainerHeight - inputFieldInsets.top - inputFieldInsets.bottom);
    CGRect visualFieldFrame = fieldFrame;
    if (!_sendButton.userInteractionEnabled)
        visualFieldFrame.size.width += 39.0f;
    
    setViewFrame(_fieldBackground, visualFieldFrame);
    
    CGFloat screenPixel =  1.0f / [[UIScreen mainScreen] scale];
    
    UIEdgeInsets inputFieldInternalEdgeInsets = [self _inputFieldInternalEdgeInsets];
    CGRect onelineFrame = fieldFrame;
    onelineFrame.origin.x += inputFieldInternalEdgeInsets.left + 5;
    onelineFrame.origin.y += inputFieldInternalEdgeInsets.top + screenPixel;
    onelineFrame.size.width -= inputFieldInternalEdgeInsets.left * 2 + 10;
    onelineFrame.size.height = 36;
    setViewFrame(_inputFieldOnelineLabel, onelineFrame);
    
    CGRect placeholderFrame = CGRectMake(onelineFrame.origin.x, floor(([self baseHeight] - _placeholderLabel.frame.size.height) / 2.0f) + 1.0f, _placeholderLabel.frame.size.width, _placeholderLabel.frame.size.height);
    setViewFrame(_placeholderLabel, placeholderFrame);
    
    CGRect inputFieldClippingFrame = fieldFrame;
    setViewFrame(_inputFieldClippingContainer, inputFieldClippingFrame);
    
    CGFloat inputFieldWidth = _inputFieldClippingContainer.frame.size.width - inputFieldInternalEdgeInsets.left - 24;
    if (fabs(inputFieldWidth - _inputField.frame.size.width) > FLT_EPSILON)
    {
        CGRect inputFieldFrame = CGRectMake(inputFieldInternalEdgeInsets.left, inputFieldInternalEdgeInsets.top, inputFieldWidth, _inputFieldClippingContainer.frame.size.height);
        setViewFrame(_inputField, inputFieldFrame);
    }
    
    _sendButton.center = CGPointMake(frame.size.width - 45.0f / 2.0f, CGRectGetMaxY(_fieldBackground.frame) - 45.0f / 2.0f + 6.0f);
}

@end
