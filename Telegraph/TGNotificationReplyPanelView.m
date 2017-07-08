#import "TGNotificationReplyPanelView.h"

#import "TGFont.h"
#import "TGImageUtils.h"
#import "TGStringUtils.h"
#import "TGViewController.h"
#import "TGAppDelegate.h"

#import "TGModernButton.h"
#import "HPGrowingTextView.h"
#import "HPTextViewInternal.h"

#import "TGModernConversationInputTextPanel.h"
#import "TGModernConversationAssociatedInputPanel.h"
#import "TGStickerAssociatedInputPanel.h"
#import "TGStickerKeyboardView.h"

@interface TGNotificationReplyPanelView () <HPGrowingTextViewDelegate>
{
    UIView *_wrapperView;
    UIView *_separatorView;
    UIView *_fieldBackground;
    TGModernButton *_keyboardModeButton;
    TGModernButton *_stickerModeButton;
    TGModernButton *_sendButton;
    
    UIView *_inputFieldClippingContainer;
    HPGrowingTextView *_inputField;
        
    NSArray *_modeButtons;
    TGModernConversationAssociatedInputPanel *_associatedPanel;
    TGStickerKeyboardView *_stickerKeyboardView;
    
    bool _notIdle;
    
    SMetaDisposable *_stickerPacksDisposable;
}

@property (nonatomic, readonly) bool changingKeyboardMode;

@end

@implementation TGNotificationReplyPanelView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        _wrapperView = [[UIView alloc] initWithFrame:self.bounds];
        _wrapperView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:_wrapperView];
        
        CGFloat thickness = TGScreenPixel;
        _separatorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, thickness)];
        _separatorView.alpha = 0.7f;
        _separatorView.backgroundColor = UIColorRGB(0xb2b2b2);
        [_wrapperView addSubview:_separatorView];
        
        _fieldBackground = [[UIView alloc] initWithFrame:CGRectZero];
        _fieldBackground.alpha = 0.82f;
        _fieldBackground.backgroundColor = UIColorRGB(0x666666);
        _fieldBackground.layer.cornerRadius = 16;
        [_wrapperView addSubview:_fieldBackground];
        
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleFieldBackgroundTap:)];
        [_fieldBackground addGestureRecognizer:tapGestureRecognizer];
        
        static dispatch_once_t onceToken;
        static UIImage *stickerImage;
        static UIImage *keyboardImage;
        dispatch_once(&onceToken, ^
        {
            stickerImage = TGTintedImage([UIImage imageNamed:@"ConversationInputFieldStickerIcon.png"], UIColorRGB(0xffffff));
            keyboardImage = TGTintedImage([UIImage imageNamed:@"ConversationInputFieldKeyboardIcon.png"], UIColorRGB(0xffffff));
        });

        _stickerModeButton = [[TGModernButton alloc] initWithFrame:CGRectMake(0, 0, 28, 28)];
        _stickerModeButton.adjustsImageWhenHighlighted = false;
        _stickerModeButton.alpha = 0.8f;
        _stickerModeButton.exclusiveTouch = true;
        [_stickerModeButton setImage:stickerImage forState:UIControlStateNormal];
        [_stickerModeButton addTarget:self action:@selector(stickerModeButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        
        _keyboardModeButton = [[TGModernButton alloc] initWithFrame:CGRectMake(0, 0, 28, 28)];
        _keyboardModeButton.adjustsImageWhenHighlighted = false;
        _keyboardModeButton.alpha = 0.8f;
        _keyboardModeButton.exclusiveTouch = true;
        [_keyboardModeButton setImage:keyboardImage forState:UIControlStateNormal];
        [_keyboardModeButton addTarget:self action:@selector(keyboardModeButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        
        _sendButton = [[TGModernButton alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.height, self.frame.size.height)];
        _sendButton.enabled = false;
        _sendButton.adjustsImageWhenHighlighted = false;
        [_sendButton setImage:[UIImage imageNamed:@"NotificationSend"] forState:UIControlStateNormal];
        [_sendButton addTarget:self action:@selector(sendButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_sendButton];
        
        [self updateModeButtonVisibilityForce:false];
    }
    return self;
}

#pragma mark -

- (HPGrowingTextView *)inputField
{
    if (_inputField != nil)
        return _inputField;
    
    CGRect clippingFrame = _fieldBackground.frame;
    _inputFieldClippingContainer = [[UIView alloc] initWithFrame:clippingFrame];
    _inputFieldClippingContainer.clipsToBounds = true;
    [_wrapperView addSubview:_inputFieldClippingContainer];
    
    UIEdgeInsets internalInsets = [self _inputFieldInternalEdgeInsets];
    _inputField = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(internalInsets.left, internalInsets.top + TGRetinaPixel, _inputFieldClippingContainer.frame.size.width - internalInsets.left - internalInsets.right, _inputFieldClippingContainer.frame.size.height)];
    _inputField.font = TGSystemFontOfSize(16);
    _inputField.clipsToBounds = true;
    _inputField.backgroundColor = nil;
    _inputField.opaque = false;
    _inputField.textColor = [UIColor whiteColor];
    _inputField.internalTextView.backgroundColor = nil;
    _inputField.internalTextView.opaque = false;
    _inputField.internalTextView.contentMode = UIViewContentModeLeft;
    if (iosMajorVersion() >= 7)
        _inputField.internalTextView.keyboardAppearance = UIKeyboardAppearanceDark;
    else
        _inputField.internalTextView.keyboardAppearance = UIKeyboardAppearanceAlert;
    _inputField.maxNumberOfLines = 4;
    _inputField.delegate = self;
    _inputField.internalTextView.enableFirstResponder = true;
    
    _inputField.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(-internalInsets.top, 0, 5 - TGRetinaPixel, 0);
    [_inputFieldClippingContainer addSubview:_inputField];
    
    return _inputField;
}

- (HPGrowingTextView *)maybeInputField
{
    return _inputField;
}

- (NSString *)text
{
    return _inputField.text;
}

#pragma mark -

- (BOOL)becomeFirstResponder
{
    if (!_inputField.isFirstResponder)
        [TGAppDelegateInstance.window endEditing:true];
    
    [self handleFieldBackgroundTap:nil];
    return true;
}

- (BOOL)resignFirstResponder
{
    [_inputField resignFirstResponder];
    return true;
}

- (BOOL)isFirstResponder
{
    return _inputField.internalTextView.isFirstResponder;
}

- (void)growingTextViewDidBeginEditing:(HPGrowingTextView *)__unused growingTextView
{
    [_inputField refreshHeight:false];
    [self updateModeButtonVisibilityForce:true];
}

- (void)growingTextViewDidEndEditing:(HPGrowingTextView *)__unused growingTextView
{
    [self setAssociatedPanel:nil animated:true];
}

- (void)growingTextView:(HPGrowingTextView *)__unused growingTextView willChangeHeight:(CGFloat)height duration:(NSTimeInterval)duration animationCurve:(int)animationCurve
{
    UIEdgeInsets inputFieldInsets = [self _inputFieldInsets];
    CGFloat inputContainerHeight = MAX([self _baseHeight], height - 8 + inputFieldInsets.top + inputFieldInsets.bottom);
    
    id<TGNotificationReplyPanelDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(inputPanelWillChangeHeight:height:duration:animationCurve:)])
        [delegate inputPanelWillChangeHeight:self height:inputContainerHeight duration:duration animationCurve:animationCurve];
}

- (void)growingTextViewDidChange:(HPGrowingTextView *)__unused growingTextView afterSetText:(bool)__unused afterSetText afterPastingText:(bool)__unused afterPastingText
{
    id<TGNotificationReplyPanelDelegate> delegate = self.delegate;
    
    int textLength = (int)growingTextView.text.length;
    NSString *text = growingTextView.text;
    
    if (!_notIdle && textLength > 0)
        _notIdle = true;
    
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
    
    if ([delegate respondsToSelector:@selector(inputPanelMentionEntered:mention:startOfLine:)])
        [delegate inputPanelMentionEntered:self mention:candidateMention startOfLine:false];
    
    if ([delegate respondsToSelector:@selector(inputPanelHashtagEntered:hashtag:)])
        [delegate inputPanelHashtagEntered:self hashtag:candidateHashtag];
    
    if ([delegate respondsToSelector:@selector(inputPanelTextChanged:text:)])
        [delegate inputPanelTextChanged:self text:text];
    
    [self updateSendButtonVisibility];
    [self updateModeButtonVisibilityForce:false];
    
    [self updateStickerPanel];
}

- (void)growingTextView:(HPGrowingTextView *)__unused growingTextView receivedReturnKeyCommandWithModifierFlags:(UIKeyModifierFlags)flags
{
    if (flags & UIKeyModifierAlternate)
        [self addNewLine];
    else
        [self sendButtonPressed];
}

- (void)addNewLine
{
    _inputField.text = [NSString stringWithFormat:@"%@\n", _inputField.text];
}

#pragma mark -

- (void)handleFieldBackgroundTap:(UITapGestureRecognizer *)__unused gestureRecognizer
{
    [self.inputField becomeFirstResponder];
}

- (void)sendButtonPressed
{
    id<TGNotificationReplyPanelDelegate> delegate = self.delegate;
    
    if ([delegate respondsToSelector:@selector(inputPanelRequestedSendText:text:)])
        [delegate inputPanelRequestedSendText:self text:_inputField.text];
}

- (void)keyboardModeButtonPressed
{
    if (self.maybeInputField.internalTextView.inputView == nil)
        return;
    
    if (self.maybeInputField.isFirstResponder)
    {
        _changingKeyboardMode = true;
        [self.inputField resignFirstResponder];
    }
    
    self.inputField.internalTextView.inputView = nil;
    
    self.inputField.internalTextView.enableFirstResponder = true;
    [self.inputField becomeFirstResponder];
    _changingKeyboardMode = false;
    
    [self updateModeButtonVisibilityForce:false];
}

- (void)stickerModeButtonPressed
{
    _notIdle = true;
    
    if ([self.inputField.internalTextView.inputView isKindOfClass:[TGStickerKeyboardView class]])
        return;
    
    if (self.maybeInputField.isFirstResponder)
    {
        _changingKeyboardMode = true;
        [self.inputField resignFirstResponder];
    }
    
    if (_stickerKeyboardView == nil)
    {
        _stickerKeyboardView = [[TGStickerKeyboardView alloc] initWithFrame:CGRectZero style:TGStickerKeyboardViewDarkBlurredStyle];
        id<TGNotificationReplyPanelDelegate> delegate = self.delegate;
        if ([delegate respondsToSelector:@selector(inputPanelParentViewController:)])
            _stickerKeyboardView.parentViewController = [delegate inputPanelParentViewController:self];
        __weak TGNotificationReplyPanelView *weakSelf = self;
        _stickerKeyboardView.stickerSelected = ^(TGDocumentMediaAttachment *sticker)
        {
            __strong TGNotificationReplyPanelView *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                id<TGNotificationReplyPanelDelegate> delegate = strongSelf.delegate;
                [delegate inputPanelRequestedSendSticker:strongSelf sticker:sticker];
            }
        };
        [_stickerKeyboardView sizeToFitForWidth:self.frame.size.width];
    }
    else
    {
        [_stickerKeyboardView updateIfNeeded];
    }
    
    self.inputField.internalTextView.inputView = _stickerKeyboardView;
    
    self.inputField.internalTextView.enableFirstResponder = true;
    [self.inputField becomeFirstResponder];
    _changingKeyboardMode = false;
    
    [self updateModeButtonVisibilityForce:false];
}

- (void)updateSendButtonVisibility
{
    _sendButton.enabled = [self.inputField.text hasNonWhitespaceCharacters];
}

- (void)updateModeButtonVisibilityForce:(bool)force
{
    NSMutableArray *commands = [[NSMutableArray alloc] init];
    if (self.maybeInputField.internalTextView.inputView != nil)
    {
        [commands addObject:_keyboardModeButton];
    }
    else
    {
        if (_inputField.text.length == 0 && !(TGAppDelegateInstance.alwaysShowStickersMode != 2))
            [commands addObject:_stickerModeButton];
    }
    [self setModeButtons:commands force:force];
}

- (void)setModeButtons:(NSArray *)modeButtons force:(bool)force
{
    if (!force && [_modeButtons isEqualToArray:modeButtons])
        return;
    
    for (UIButton *button in _modeButtons)
    {
        [button removeFromSuperview];
        button.transform = CGAffineTransformIdentity;
    }
    
    _modeButtons = modeButtons;
    
    CGFloat inset = 4.0f;
    for (UIButton *button in _modeButtons)
    {
        [_wrapperView addSubview:button];
        inset += button.frame.size.width + 9.0f;
    }
    
    if (iosMajorVersion() >= 7)
    {
        UIEdgeInsets insets = _inputField.internalTextView.textContainerInset;
        if (ABS(inset - insets.right) > FLT_EPSILON)
        {
            insets.right = inset;
            _inputField.internalTextView.textContainerInset = insets;
            [_inputField refreshHeight:false];
        }
    }
    
    [self setNeedsLayout];
}

#pragma mark -

- (void)replaceMention:(NSString *)mention
{
    [TGModernConversationInputTextPanel replaceMention:mention inputField:_inputField];
}

- (void)replaceHashtag:(NSString *)hashtag
{
    [TGModernConversationInputTextPanel replaceHashtag:hashtag inputField:_inputField];
}

- (bool)shouldDisplayPanels
{
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone && UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation))
        return false;
    
    return true;
}

- (TGModernConversationAssociatedInputPanel *)associatedPanel
{
    return _associatedPanel;
}

- (void)setAssociatedPanel:(TGModernConversationAssociatedInputPanel *)associatedPanel animated:(bool)animated
{
    int screenSize = (int)TGScreenSize().height;
    if (screenSize < 568)
        return;
    
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
            __weak TGNotificationReplyPanelView *weakSelf = self;
            _associatedPanel.preferredHeightUpdated = ^
            {
                __strong TGNotificationReplyPanelView *strongSelf = weakSelf;
                if (strongSelf != nil)
                {
                    strongSelf->_associatedPanel.frame = CGRectMake(0.0f, strongSelf.frame.size.height, strongSelf.frame.size.width, [strongSelf shouldDisplayPanels] ? [strongSelf->_associatedPanel preferredHeight] : 0.0f);
                }
            };
            _associatedPanel.frame = CGRectMake(0.0f, self.frame.size.height, self.frame.size.width, [self shouldDisplayPanels] ? [_associatedPanel preferredHeight] : 0.0f);
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

- (void)setAssociatedStickerList:(NSDictionary *)stickerList
{
    int screenSize = (int)TGScreenSize().height;
    if (screenSize < 568)
        return;
    
    NSArray *documents = stickerList[@"documents"];
    if (documents.count != 0)
    {
        if ([_associatedPanel isKindOfClass:[TGStickerAssociatedInputPanel class]])
            [((TGStickerAssociatedInputPanel *)_associatedPanel) setDocumentList:stickerList];
        else
        {
            __weak TGNotificationReplyPanelView *weakSelf = self;
            
            TGStickerAssociatedInputPanel *stickerPanel = [[TGStickerAssociatedInputPanel alloc] initWithStyle:TGModernConversationAssociatedInputPanelDarkBlurredStyle];
            stickerPanel.documentSelected = ^(TGDocumentMediaAttachment *sticker)
            {
                __strong TGNotificationReplyPanelView *strongSelf = weakSelf;
                if (strongSelf == nil)
                    return;
                
                if ([strongSelf.delegate respondsToSelector:@selector(inputPanelRequestedSendSticker:sticker:)])
                    [strongSelf.delegate inputPanelRequestedSendSticker:strongSelf sticker:sticker];
                
                [strongSelf->_inputField setText:@"" animated:true];
            };
            [stickerPanel setDocumentList:stickerList];
            [stickerPanel setTargetOffset:53.0f];
            [self setAssociatedPanel:stickerPanel animated:true];
        }
    }
    else
    {
        [self setAssociatedPanel:nil animated:true];
    }
}

- (void)updateStickerPanel
{
    
}

#pragma mark - 

- (bool)hasUnsavedData
{
    return (self.maybeInputField.text.length > 0);
}

- (bool)isIdle
{
    return !_notIdle && (self.maybeInputField.text.length == 0);
}

- (void)refreshHeight
{
    [_inputField refreshHeight:false];
}

- (void)localizationUpdated
{
}

- (void)reset
{
    _inputField.internalTextView.inputView = nil;
    _inputField.text = nil;
    _stickerKeyboardView = nil;
    _notIdle = false;
}

#pragma mark -

- (CGFloat)_baseHeight
{
    return 45;
}

- (UIEdgeInsets)_inputFieldInsets
{
    static UIEdgeInsets insets;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        insets = UIEdgeInsetsMake(9.0f, 7.0f - TGScreenPixel, 13.0f, 0.0f);
    });
    
    return insets;
}

- (UIEdgeInsets)_inputFieldInternalEdgeInsets
{
    static UIEdgeInsets insets;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        insets = UIEdgeInsetsMake(-2.0f - TGScreenPixel, 8.0f, 0.0f, 0.0f);
    });
    
    return insets;
}

- (CGFloat)heightForWidth:(CGFloat)__unused width
{
    UIEdgeInsets inputFieldInsets = [self _inputFieldInsets];
    CGFloat height = MAX([self _baseHeight], _inputField.frame.size.height - 8 + inputFieldInsets.top + inputFieldInsets.bottom);
    
    return height;
}

- (CGFloat)heightForInputFieldHeight:(CGFloat)inputFieldHeight
{
    UIEdgeInsets inputFieldInsets = [self _inputFieldInsets];
    CGFloat height = MAX([self _baseHeight], inputFieldHeight - 4 + inputFieldInsets.top + inputFieldInsets.bottom);
    
    return height;
}

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

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    bool pointInside = [super pointInside:point withEvent:event];
    if (_associatedPanel == nil)
        return pointInside;
    
    return CGRectContainsPoint(_associatedPanel.frame, point) || pointInside;
}

static void setViewFrame(UIView *view, CGRect frame)
{
    CGAffineTransform transform = view.transform;
    view.transform = CGAffineTransformIdentity;
    if (!CGRectEqualToRect(view.frame, frame))
        view.frame = frame;
    view.transform = transform;
}

- (void)layoutSubviews
{
    CGRect frame = self.frame;
    
    if (_associatedPanel != nil)
    {
        CGRect associatedPanelFrame = CGRectMake(0.0f, self.frame.size.height, frame.size.width, [self shouldDisplayPanels] ? [_associatedPanel preferredHeight] : 0.0f);
        if (!CGRectEqualToRect(associatedPanelFrame, _associatedPanel.frame))
            _associatedPanel.frame = associatedPanelFrame;
    }
    
    _separatorView.frame = CGRectMake(0, 0, frame.size.width, _separatorView.frame.size.height);
    
    UIEdgeInsets inputFieldInsets = [self _inputFieldInsets];
    CGFloat inputContainerHeight = [self heightForInputFieldHeight:_inputField.frame.size.height];
    setViewFrame(_fieldBackground, CGRectMake(inputFieldInsets.left, inputFieldInsets.top, frame.size.width - inputFieldInsets.left - inputFieldInsets.right - _sendButton.frame.size.width, MAX(32, inputContainerHeight - inputFieldInsets.top - inputFieldInsets.bottom)));
    
    UIEdgeInsets inputFieldInternalEdgeInsets = [self _inputFieldInternalEdgeInsets];
    
    CGRect inputFieldClippingFrame = _fieldBackground.frame;
    setViewFrame(_inputFieldClippingContainer, inputFieldClippingFrame);
    
    CGFloat inputFieldWidth = _inputFieldClippingContainer.frame.size.width - inputFieldInternalEdgeInsets.left - inputFieldInternalEdgeInsets.right;
    if (fabs(inputFieldWidth - _inputField.frame.size.width) > FLT_EPSILON)
    {
        CGRect inputFieldFrame = CGRectMake(inputFieldInternalEdgeInsets.left, inputFieldInternalEdgeInsets.top + TGRetinaPixel, inputFieldWidth, _inputFieldClippingContainer.frame.size.height);
        setViewFrame(_inputField, inputFieldFrame);
    }

    _sendButton.frame = CGRectMake(frame.size.width - _sendButton.frame.size.width, frame.size.height - _sendButton.frame.size.height - 2.0f, _sendButton.frame.size.width, _sendButton.frame.size.height);

    _stickerModeButton.frame = CGRectMake(CGRectGetMaxX(_fieldBackground.frame) - _stickerModeButton.frame.size.width - 4.0f, CGRectGetMinY(_fieldBackground.frame) + 2.0f, _stickerModeButton.frame.size.width, _stickerModeButton.frame.size.height);
    
    _keyboardModeButton.frame = CGRectMake(CGRectGetMaxX(_fieldBackground.frame) - _keyboardModeButton.frame.size.width - 4.0f, CGRectGetMinY(_fieldBackground.frame) + 2.0f, _keyboardModeButton.frame.size.width, _keyboardModeButton.frame.size.height);
}

@end
