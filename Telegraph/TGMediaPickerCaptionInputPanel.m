#import "TGMediaPickerCaptionInputPanel.h"

#import "TGPhotoEditorInterfaceAssets.h"

#import "TGHacks.h"
#import "TGFont.h"
#import "TGImageUtils.h"
#import "TGStringUtils.h"
#import "TGViewController.h"

#import "HPTextViewInternal.h"

#import "TGModernConversationAssociatedInputPanel.h"

const NSInteger TGMediaPickerCaptionInputPanelCaptionLimit = 140;
const NSInteger TGMediaPickerCaptionInputPanelCaptionCounterThreshold = 70;

static void setViewFrame(UIView *view, CGRect frame)
{
    CGAffineTransform transform = view.transform;
    view.transform = CGAffineTransformIdentity;
    if (!CGRectEqualToRect(view.frame, frame))
        view.frame = frame;
    view.transform = transform;
}

@interface TGMediaPickerCaptionInputPanel () <HPGrowingTextViewDelegate>
{
    CGFloat _keyboardHeight;
    NSString *_caption;
    bool _dismissing;
    bool _dismissDisabled;
    
    UIView *_wrapperView;
    UIView *_backgroundView;
    UIImageView *_fieldBackground;
    UIView *_inputFieldClippingContainer;
    HPGrowingTextView *_inputField;
    UIView *_inputFieldPlaceholder;
    UILabel *_inputFieldOnelineLabel;
    
    UILabel *_counterLabel;

    TGModernConversationAssociatedInputPanel *_associatedPanel;
}

@end

@implementation TGMediaPickerCaptionInputPanel

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        static UIImage *fieldBackgroundImage = nil;
        static UIImage *placeholderImage = nil;
        static int localizationVersion = 0;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^
        {
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(16, 16), false, 0.0f);
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextSetFillColorWithColor(context, UIColorRGBA(0xffffff, 0.1f).CGColor);
            
            UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 16, 16) cornerRadius:5];
            [path fill];
            
            fieldBackgroundImage = [UIGraphicsGetImageFromCurrentImageContext() resizableImageWithCapInsets:UIEdgeInsetsMake(8, 8, 8, 8)];
            UIGraphicsEndImageContext();
        });
        
        if (placeholderImage == nil || localizationVersion != TGLocalizedStaticVersion)
        {
            NSString *placeholderText = TGLocalized(@"MediaPicker.AddCaption");
            UIFont *placeholderFont = TGSystemFontOfSize(16);
            CGSize placeholderSize = [placeholderText sizeWithFont:placeholderFont];
            placeholderSize.width += 2.0f;
            placeholderSize.height += 2.0f;
            
            UIGraphicsBeginImageContextWithOptions(placeholderSize, false, 0.0f);
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextSetFillColorWithColor(context, UIColorRGB(0x979797).CGColor);
            [placeholderText drawAtPoint:CGPointMake(1.0f, 1.0f) withFont:placeholderFont];
            placeholderImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            localizationVersion = TGLocalizedStaticVersion;
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
        _backgroundView.backgroundColor = [TGPhotoEditorInterfaceAssets toolbarTransparentBackgroundColor];
        [backgroundWrapperView addSubview:_backgroundView];
        
        _fieldBackground = [[UIImageView alloc] initWithImage:fieldBackgroundImage];
        _fieldBackground.userInteractionEnabled = true;
        [_fieldBackground addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleFieldBackgroundTap:)]];
        [_wrapperView addSubview:_fieldBackground];
        
        CGPoint placeholderOffset = [self _inputFieldPlaceholderOffset];
        _inputFieldPlaceholder = [[UIImageView alloc] initWithImage:placeholderImage];
        setViewFrame(_inputFieldPlaceholder, CGRectOffset(_inputFieldPlaceholder.frame, placeholderOffset.x, placeholderOffset.y));
        [_fieldBackground addSubview:_inputFieldPlaceholder];
        
        _inputFieldOnelineLabel = [[UILabel alloc] init];
        _inputFieldOnelineLabel.backgroundColor = [UIColor clearColor];
        _inputFieldOnelineLabel.font = TGSystemFontOfSize(16);
        _inputFieldOnelineLabel.hidden = true;
        _inputFieldOnelineLabel.numberOfLines = 1;
        _inputFieldOnelineLabel.textColor = [UIColor whiteColor];
        _inputFieldOnelineLabel.userInteractionEnabled = false;
        [_wrapperView addSubview:_inputFieldOnelineLabel];
        
        _counterLabel = [[UILabel alloc] initWithFrame:CGRectMake(_fieldBackground.frame.size.width - 32, 4, 24, 16)];
        _counterLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        _counterLabel.backgroundColor = [UIColor clearColor];
        _counterLabel.font = TGSystemFontOfSize(12);
        _counterLabel.hidden = true;
        _counterLabel.textAlignment = NSTextAlignmentRight;
        _counterLabel.textColor = UIColorRGB(0x828282);
        _counterLabel.highlightedTextColor = UIColorRGB(0xff4848);
        _counterLabel.userInteractionEnabled = false;
        [_fieldBackground addSubview:_counterLabel];
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
    
    UIEdgeInsets inputFieldInternalEdgeInsets = [self _inputFieldInternalEdgeInsets];
    _inputField = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(inputFieldInternalEdgeInsets.left, inputFieldInternalEdgeInsets.top + TGRetinaPixel, _inputFieldClippingContainer.frame.size.width - inputFieldInternalEdgeInsets.left - 24, _inputFieldClippingContainer.frame.size.height)];
    _inputField.placeholderView = _inputFieldPlaceholder;
    _inputField.font = TGSystemFontOfSize(16);
    _inputField.clipsToBounds = true;
    _inputField.backgroundColor = nil;
    _inputField.opaque = false;
    _inputField.textColor = [UIColor whiteColor];
    _inputField.showPlaceholderWhenFocussed = true;
    _inputField.internalTextView.returnKeyType = UIReturnKeyDone;
    _inputField.internalTextView.backgroundColor = nil;
    _inputField.internalTextView.opaque = false;
    _inputField.internalTextView.contentMode = UIViewContentModeLeft;
    if (iosMajorVersion() >= 7)
        _inputField.internalTextView.keyboardAppearance = UIKeyboardAppearanceDark;
    else
        _inputField.internalTextView.keyboardAppearance = UIKeyboardAppearanceAlert;
    _inputField.maxNumberOfLines = [self _maxNumberOfLinesForSize:CGSizeMake(320.0f, 480.0f)];
    _inputField.delegate = self;
    
    _inputField.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(-inputFieldInternalEdgeInsets.top, 0, 5 - TGRetinaPixel, 0);
    
    _inputField.text = _caption;
    
    [_inputFieldClippingContainer addSubview:_inputField];
}

- (void)handleFieldBackgroundTap:(UITapGestureRecognizer *)__unused gestureRecognizer
{
    bool shouldBecomeFirstResponder = true;
    
    id<TGMediaPickerCaptionInputPanelDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(inputPanelShouldBecomeFirstResponder:)])
        shouldBecomeFirstResponder = [delegate inputPanelShouldBecomeFirstResponder:self];
    
    if (!shouldBecomeFirstResponder || self.isCollapsed)
        return;
    
    [self createInputFieldIfNeeded];
    _inputFieldClippingContainer.hidden = false;
    _inputField.internalTextView.enableFirstResponder = true;
    [_inputField.internalTextView becomeFirstResponder];
}

- (bool)setButtonPressed
{
    if (_dismissDisabled)
        return false;
    
    if (_inputField.text.length > TGMediaPickerCaptionInputPanelCaptionLimit)
    {
        [self shakeControls];
        return false;
    }
    
    _dismissing = true;
    
    if (_inputField.internalTextView.isFirstResponder)
        [TGHacks applyCurrentKeyboardAutocorrectionVariant];
    
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
    
    id<TGMediaPickerCaptionInputPanelDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(inputPanelRequestedSetCaption:text:)])
        [delegate inputPanelRequestedSetCaption:self text:text];
    
    [_inputField.internalTextView resignFirstResponder];
    
    return true;
}

- (void)dismiss
{
    [self setButtonPressed];
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
    
    void (^visibilityChangeBlock)(void) = ^
    {
        CGFloat alpha = collapsed ? 0.0f : 1.0f;
        _wrapperView.alpha = alpha;
    };
    
    if (animated)
    {
        [UIView animateWithDuration:0.3f delay:0.0f options:[TGViewController preferredAnimationCurve] << 16 animations:frameChangeBlock completion:nil];
        [UIView animateWithDuration:0.25f delay:collapsed ? 0.0f : 0.05f options:kNilOptions animations:visibilityChangeBlock completion:nil];
    }
    else
    {
        frameChangeBlock();
        visibilityChangeBlock();
    }
}

#pragma mark - 

- (void)adjustForOrientation:(UIInterfaceOrientation)__unused orientation keyboardHeight:(CGFloat)keyboardHeight duration:(NSTimeInterval)duration animationCurve:(NSInteger)animationCurve
{
    _keyboardHeight = keyboardHeight;
    
    void(^changeBlock)(void) = ^
    {
        bool isKeyboardVisible = (keyboardHeight > FLT_EPSILON);
        CGFloat inputContainerHeight = [self heightForInputFieldHeight:[self isFirstResponder] ? _inputField.frame.size.height : 0];
        CGSize screenSize = self.superview.frame.size;
        
        if (isKeyboardVisible)
        {
            self.frame = CGRectMake(self.frame.origin.x, screenSize.height - keyboardHeight - inputContainerHeight, self.frame.size.width, inputContainerHeight + keyboardHeight - self.bottomMargin);
            _backgroundView.backgroundColor = [TGPhotoEditorInterfaceAssets toolbarBackgroundColor];
        }
        else
        {
            CGFloat height = inputContainerHeight;
            self.frame = CGRectMake(self.frame.origin.x, screenSize.height - self.bottomMargin - inputContainerHeight + (_dismissing ? height : 0), self.frame.size.width, inputContainerHeight);
            _backgroundView.backgroundColor = [TGPhotoEditorInterfaceAssets toolbarTransparentBackgroundColor];
        }
        
        [self layoutSubviews];
    };
    
    if (duration > DBL_EPSILON)
        [UIView animateWithDuration:duration delay:0.0f options:animationCurve animations:changeBlock completion:nil];
    else
        changeBlock();
}

- (void)shrinkToSingleLineWithDuration:(NSTimeInterval)duration animationCurve:(NSInteger)animationCurve
{
    return;
    void(^changeBlock)(void) = ^
    {
        CGFloat inputContainerHeight = [self heightForInputFieldHeight:0];
        CGSize screenSize = TGScreenSize();
        
        self.frame = CGRectMake(self.frame.origin.x, screenSize.height - self.bottomMargin - inputContainerHeight, self.frame.size.width, inputContainerHeight);
        _backgroundView.backgroundColor = [TGPhotoEditorInterfaceAssets toolbarTransparentBackgroundColor];
        
        [self layoutSubviews];
    };
    
    if (duration > DBL_EPSILON)
        [UIView animateWithDuration:duration delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState | animationCurve animations:changeBlock completion:nil];
    else
        changeBlock();
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
            snapshottedView = _inputFieldPlaceholder;
        
        snapshotView = [snapshottedView snapshotViewAfterScreenUpdates:false];
        snapshotView.frame = snapshottedView.frame;
        [snapshottedView.superview addSubview:snapshotView];
        
        if (previousCaption.length > 0 && caption.length == 0)
            fadingInView = _inputFieldPlaceholder;
        else
            fadingInView = _inputFieldOnelineLabel;
        
        fadingInView.hidden = false;
        fadingInView.alpha = 0.0f;
        
        _inputFieldPlaceholder.hidden = (caption.length > 0);
        
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
        _inputFieldPlaceholder.hidden = !_inputFieldOnelineLabel.hidden;
    }
    
    _inputField.text = caption;
}

- (void)updateCounterWithText:(NSString *)text
{
    bool appearance = false;
    
    NSInteger textLength = text.length;
    _counterLabel.text = [NSString stringWithFormat:@"%d", (int)(TGMediaPickerCaptionInputPanelCaptionLimit - textLength)];
    
    bool hidden = (text.length < TGMediaPickerCaptionInputPanelCaptionCounterThreshold);
    if (hidden != _counterLabel.hidden)
    {
        appearance = true;
        
        [UIView transitionWithView:_counterLabel duration:0.16f options:UIViewAnimationOptionTransitionCrossDissolve animations:^
        {
            _counterLabel.hidden = hidden;
        } completion:nil];
    }

    bool highlighted = (textLength > TGMediaPickerCaptionInputPanelCaptionLimit);
    if (highlighted != _counterLabel.highlighted)
    {
        if (!appearance)
        {
            [UIView transitionWithView:_counterLabel duration:0.16f options:UIViewAnimationOptionTransitionCrossDissolve animations:^
            {
                _counterLabel.highlighted = highlighted;
            } completion:nil];
        }
        else
        {
            _counterLabel.highlighted = highlighted;
        }
    }
    
    _counterLabel.hidden = textLength < TGMediaPickerCaptionInputPanelCaptionCounterThreshold;
}

- (void)shakeControls
{
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    NSMutableArray *values = [[NSMutableArray alloc] init];
    for (NSUInteger i = 0; i < 6; i++)
        [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeTranslation(i % 2 == 0 ? -3.0f : 3.0f, 0.0f, 0.0f)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeTranslation(0.0f, 0.0f, 0.0f)]];
    animation.values = values;
    NSMutableArray *keyTimes = [[NSMutableArray alloc] init];
    for (NSUInteger i = 0; i < animation.values.count; i++)
        [keyTimes addObject:@((NSTimeInterval)i / (animation.values.count - 1.0))];
    animation.keyTimes = keyTimes;
    animation.duration = 0.3;
    [_wrapperView.layer addAnimation:animation forKey:@"transform"];
    
    _dismissDisabled = true;
    TGDispatchAfter(0.3, dispatch_get_main_queue(), ^
    {
        _dismissDisabled = false;
    });
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

- (void)growingTextViewDidBeginEditing:(HPGrowingTextView *)__unused growingTextView
{
    id<TGMediaPickerCaptionInputPanelDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(inputPanelFocused:)])
        [delegate inputPanelFocused:self];
    
    _inputField.alpha = 0.0f;
    [UIView animateWithDuration:0.2f animations:^
    {
        _inputField.alpha = 1.0f;
        _inputFieldOnelineLabel.alpha = 0.0f;
    } completion:^(BOOL finished)
    {
        if (finished)
        {
            _inputFieldOnelineLabel.alpha = 1.0f;
            _inputFieldOnelineLabel.hidden = true;
        }
    }];
    
    if (_keyboardHeight < FLT_EPSILON)
        [self adjustForOrientation:UIInterfaceOrientationPortrait keyboardHeight:0 duration:0.25f animationCurve:[TGViewController preferredAnimationCurve]];
    
     [_inputField refreshHeight];
}

-(void)growingTextViewDidEndEditing:(HPGrowingTextView *)__unused growingTextView
{
    _caption = _inputField.text;
    _inputFieldOnelineLabel.text = [self oneLinedCaptionForText:_caption];
    _inputFieldOnelineLabel.alpha = 0.0f;
    _inputFieldOnelineLabel.hidden = false;
    [UIView animateWithDuration:0.2f animations:^
    {
        _inputField.alpha = 0.0f;
        _inputFieldOnelineLabel.alpha = 1.0f;
    } completion:^(BOOL finished)
    {
        if (finished)
        {
            _inputField.alpha = 1.0f;
            _inputFieldClippingContainer.hidden = true;
        }
    }];
    
    [self shrinkToSingleLineWithDuration:0.25f animationCurve:[TGViewController preferredAnimationCurve]];
    [self setAssociatedPanel:nil animated:true];
}

- (void)growingTextView:(HPGrowingTextView *)__unused growingTextView willChangeHeight:(CGFloat)height duration:(NSTimeInterval)duration animationCurve:(int)animationCurve
{
    UIEdgeInsets inputFieldInsets = [self _inputFieldInsets];
    CGFloat inputContainerHeight = MAX([self _baseHeight], height - 8 + inputFieldInsets.top + inputFieldInsets.bottom);
    
    id<TGMediaPickerCaptionInputPanelDelegate> delegate = (id<TGMediaPickerCaptionInputPanelDelegate>)self.delegate;
    if ([delegate respondsToSelector:@selector(inputPanelWillChangeHeight:height:duration:animationCurve:)])
    {
        [delegate inputPanelWillChangeHeight:self height:inputContainerHeight duration:duration animationCurve:animationCurve];
    }
}

- (void)growingTextViewDidChange:(HPGrowingTextView *)__unused growingTextView afterSetText:(bool)__unused afterSetText afterPastingText:(bool)__unused afterPastingText
{
    id<TGMediaPickerCaptionInputPanelDelegate> delegate = (id<TGMediaPickerCaptionInputPanelDelegate>)self.delegate;
    
    int textLength = (int)growingTextView.text.length;
    NSString *text = growingTextView.text;
    
    UITextRange *selRange = _inputField.internalTextView.selectedTextRange;
    UITextPosition *selStartPos = selRange.start;
    NSInteger idx = [_inputField.internalTextView offsetFromPosition:_inputField.internalTextView.beginningOfDocument toPosition:selStartPos];
    idx--;
    
    NSString *candidateMention = nil;
    NSString *candidateHashtag = nil;
    
    if (idx >= 0 && idx < textLength)
    {
        for (NSInteger i = idx; i >= 0; i--)
        {
            unichar c = [text characterAtIndex:i];
            if (c == '@')
            {
                if (i == idx)
                    candidateMention = @"";
                else
                {
                    @try {
                        candidateMention = [text substringWithRange:NSMakeRange(i + 1, idx - i)];
                    } @catch(NSException *e) { }
                }
                break;
            }
            
            if (!((c >= '0' && c <= '9') || (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || c == '_'))
                break;
        }
    }
    
    if (candidateMention == nil)
    {
        static NSCharacterSet *characterSet = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^
        {
            characterSet = [NSCharacterSet alphanumericCharacterSet];
        });
        
        if (idx >= 0 && idx < textLength)
        {
            for (NSInteger i = idx; i >= 0; i--)
            {
                unichar c = [text characterAtIndex:i];
                if (c == '#')
                {
                    if (i == idx)
                        candidateHashtag = @"";
                    else
                    {
                        @try {
                            candidateHashtag = [text substringWithRange:NSMakeRange(i + 1, idx - i)];
                        } @catch(NSException *e) { }
                    }
                    
                    break;
                }
                
                if (c == ' ' || (![characterSet characterIsMember:c] && c != '_'))
                    break;
            }
        }
    }
    
    if ([delegate respondsToSelector:@selector(inputPanelMentionEntered:mention:)])
        [delegate inputPanelMentionEntered:self mention:candidateMention];
    
    if ([delegate respondsToSelector:@selector(inputPanelHashtagEntered:hashtag:)])
        [delegate inputPanelHashtagEntered:self hashtag:candidateHashtag];
    
    if ([delegate respondsToSelector:@selector(inputPanelTextChanged:text:)])
        [delegate inputPanelTextChanged:self text:text];
    
    [self updateCounterWithText:text];
}

- (BOOL)growingTextViewShouldReturn:(HPGrowingTextView *)__unused growingTextView
{
    [self setButtonPressed];
    return false;
}

- (void)growingTextView:(HPGrowingTextView *)__unused growingTextView receivedReturnKeyCommandWithModifierFlags:(UIKeyModifierFlags)flags
{
    if (flags & UIKeyModifierCommand)
        [self setButtonPressed];
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

#pragma mark -

- (void)replaceMention:(NSString *)mention
{
    NSString *replacementText = [mention stringByAppendingString:@" "];
    
    NSString *text = _inputField.text;
    
    UITextRange *selRange = _inputField.internalTextView.selectedTextRange;
    UITextPosition *selStartPos = selRange.start;
    NSInteger idx = [_inputField.internalTextView offsetFromPosition:_inputField.internalTextView.beginningOfDocument toPosition:selStartPos];
    idx--;
    NSRange candidateMentionRange = NSMakeRange(NSNotFound, 0);
    
    if (idx >= 0 && idx < (int)text.length)
    {
        for (NSInteger i = idx; i >= 0; i--)
        {
            unichar c = [text characterAtIndex:i];
            if (c == '@')
            {
                if (i == idx)
                    candidateMentionRange = NSMakeRange(i + 1, 0);
                else
                    candidateMentionRange = NSMakeRange(i + 1, idx - i);
                break;
            }
            
            if (!((c >= '0' && c <= '9') || (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || c == '_'))
                break;
        }
    }
    
    if (candidateMentionRange.location != NSNotFound)
    {
        text = [text stringByReplacingCharactersInRange:candidateMentionRange withString:replacementText];
        [_inputField setText:text];
        UITextPosition *textPosition = [_inputField.internalTextView positionFromPosition:_inputField.internalTextView.beginningOfDocument offset:candidateMentionRange.location + replacementText.length];
        [_inputField.internalTextView setSelectedTextRange:[_inputField.internalTextView textRangeFromPosition:textPosition toPosition:textPosition]];
    }
}

- (void)replaceHashtag:(NSString *)hashtag
{
    static NSCharacterSet *characterSet = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        characterSet = [NSCharacterSet alphanumericCharacterSet];
    });
    
    NSString *replacementText = [hashtag stringByAppendingString:@" "];
    
    NSString *text = _inputField.text;
    
    UITextRange *selRange = _inputField.internalTextView.selectedTextRange;
    UITextPosition *selStartPos = selRange.start;
    NSInteger idx = [_inputField.internalTextView offsetFromPosition:_inputField.internalTextView.beginningOfDocument toPosition:selStartPos];
    idx--;
    NSRange candidateHashtagRange = NSMakeRange(NSNotFound, 0);
    
    if (idx >= 0 && idx < (int)text.length)
    {
        for (NSInteger i = idx; i >= 0; i--)
        {
            unichar c = [text characterAtIndex:i];
            if (c == '#')
            {
                if (i == idx)
                    candidateHashtagRange = NSMakeRange(i + 1, 0);
                else
                    candidateHashtagRange = NSMakeRange(i + 1, idx - i);
                break;
            }
            
            if (c == ' ' || (![characterSet characterIsMember:c] && c != '_'))
                break;
        }
    }
    
    if (candidateHashtagRange.location != NSNotFound)
    {
        text = [text stringByReplacingCharactersInRange:candidateHashtagRange withString:replacementText];
        [_inputField setText:text];
        UITextPosition *textPosition = [_inputField.internalTextView positionFromPosition:_inputField.internalTextView.beginningOfDocument offset:candidateHashtagRange.location + replacementText.length];
        [_inputField.internalTextView setSelectedTextRange:[_inputField.internalTextView textRangeFromPosition:textPosition toPosition:textPosition]];
    }
}

- (bool)shouldDisplayPanels
{
    return true;
}

- (TGModernConversationAssociatedInputPanel *)associatedPanel
{
    return _associatedPanel;
}

- (void)setAssociatedPanel:(TGModernConversationAssociatedInputPanel *)associatedPanel animated:(bool)animated
{
    if (_associatedPanel != associatedPanel)
    {
        TGModernConversationAssociatedInputPanel *currentPanel = _associatedPanel;
        if (currentPanel != nil)
        {
            if (animated)
            {
                [UIView animateWithDuration:0.18 animations:^
                {
                     currentPanel.alpha = 0.0f;
                } completion:^(BOOL finished)
                {
                    if (finished)
                        [currentPanel removeFromSuperview];
                }];
            }
            else
                [currentPanel removeFromSuperview];
        }
        
        _associatedPanel = associatedPanel;
        if (_associatedPanel != nil)
        {
            __weak TGMediaPickerCaptionInputPanel *weakSelf = self;
            _associatedPanel.preferredHeightUpdated = ^
            {
                __strong TGMediaPickerCaptionInputPanel *strongSelf = weakSelf;
                if (strongSelf != nil)
                {
                    strongSelf->_associatedPanel.frame = CGRectMake(0.0f, -[strongSelf->_associatedPanel preferredHeight], strongSelf.frame.size.width, [strongSelf shouldDisplayPanels] ? [strongSelf->_associatedPanel preferredHeight] : 0.0f);
                }
            };
            _associatedPanel.frame = CGRectMake(0.0f, -[_associatedPanel preferredHeight], self.frame.size.width, [self shouldDisplayPanels] ? [_associatedPanel preferredHeight] : 0.0f);
            [self addSubview:_associatedPanel];
            if (animated)
            {
                _associatedPanel.alpha = 0.0f;
                [UIView animateWithDuration:0.18 animations:^
                {
                    _associatedPanel.alpha = 1.0f;
                }];
            }
            else
            {
                _associatedPanel.alpha = 1.0f;
            }
        }
    }
}

#pragma mark - Style

- (UIFont *)_setButtonFont
{
    return TGMediumSystemFontOfSize(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? 17 : 18);
}

- (UIEdgeInsets)_inputFieldInsets
{
    static UIEdgeInsets insets;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
            insets = UIEdgeInsetsMake(9.0f, 9.0f, 9.0f, 9.0f);
        else
            insets = UIEdgeInsetsMake(12.0f, 12.0f, 12.0f, 12.0f);
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
            insets = UIEdgeInsetsMake(-4 - TGRetinaPixel, 1.0f, 0.0f, 0.0f);
        else
            insets = UIEdgeInsetsMake(-1, 4.0f, 0.0f, 0.0f);
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
            offset = CGPointMake(5.0f, 3.0f);
        else
            offset = CGPointMake(8.0f, 5.0f);
    });
    
    return offset;
}

- (CGFloat)heightForInputFieldHeight:(CGFloat)inputFieldHeight
{
    if (inputFieldHeight < FLT_EPSILON)
        inputFieldHeight = 36;
    
    if (TGIsPad())
        inputFieldHeight += 4;
    
    UIEdgeInsets inputFieldInsets = [self _inputFieldInsets];
    CGFloat height = MAX([self _baseHeight], inputFieldHeight - 8 + inputFieldInsets.top + inputFieldInsets.bottom);
    
    return height;
}

- (CGFloat)_baseHeight
{
    static CGFloat value = 0.0f;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        value = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? 46.0f : 57.0f;
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

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    if (_associatedPanel != nil)
    {
        UIView *result = [_associatedPanel hitTest:[self convertPoint:point toView:_associatedPanel] withEvent:event];
        if (result != nil)
            return result;
    }
    
    return [super hitTest:point withEvent:event];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect frame = self.frame;
    
    if (_associatedPanel != nil)
    {
        CGRect associatedPanelFrame = CGRectMake(0.0f, -[_associatedPanel preferredHeight], frame.size.width, [self shouldDisplayPanels] ? [_associatedPanel preferredHeight] : 0.0f);
        if (!CGRectEqualToRect(associatedPanelFrame, _associatedPanel.frame))
            _associatedPanel.frame = associatedPanelFrame;
    }
    
    UIEdgeInsets inputFieldInsets = [self _inputFieldInsets];
    CGFloat inputContainerHeight = [self heightForInputFieldHeight:self.isFirstResponder ? _inputField.frame.size.height : 0];
    setViewFrame(_fieldBackground, CGRectMake(inputFieldInsets.left, inputFieldInsets.top, frame.size.width - inputFieldInsets.left - inputFieldInsets.right, inputContainerHeight - inputFieldInsets.top - inputFieldInsets.bottom));
    
    UIEdgeInsets inputFieldInternalEdgeInsets = [self _inputFieldInternalEdgeInsets];
    CGRect onelineFrame = _fieldBackground.frame;
    onelineFrame.origin.x += inputFieldInternalEdgeInsets.left + 5;
    onelineFrame.origin.y += inputFieldInternalEdgeInsets.top;
    onelineFrame.size.width -= inputFieldInternalEdgeInsets.left * 2 + 10;
    onelineFrame.size.height = 36;
    setViewFrame(_inputFieldOnelineLabel, onelineFrame);
    
    CGRect inputFieldClippingFrame = _fieldBackground.frame;
    setViewFrame(_inputFieldClippingContainer, inputFieldClippingFrame);

    CGFloat inputFieldWidth = _inputFieldClippingContainer.frame.size.width - inputFieldInternalEdgeInsets.left - 24;
    if (ABS(inputFieldWidth - _inputField.frame.size.width))
    {
        CGRect inputFieldFrame = CGRectMake(inputFieldInternalEdgeInsets.left, inputFieldInternalEdgeInsets.top + TGRetinaPixel, inputFieldWidth, _inputFieldClippingContainer.frame.size.height);
        setViewFrame(_inputField, inputFieldFrame);
    }
}

@end
