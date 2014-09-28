/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGModernConversationInputTextPanel.h"

#import <MTProtoKit/MTTime.h>
#import "TGHacks.h"
#import "TGFont.h"
#import "TGImageUtils.h"
#import "TGTimerTarget.h"

#import "TGViewController.h"

#import "HPGrowingTextView.h"
#import "HPTextViewInternal.h"

#import "TGModernButton.h"
#import "TGModernConversationInputMicButton.h"

static void setViewFrame(UIView *view, CGRect frame)
{
    CGAffineTransform transform = view.transform;
    view.transform = CGAffineTransformIdentity;
    if (!CGRectEqualToRect(view.frame, frame))
        view.frame = frame;
    view.transform = transform;
}

static CGRect viewFrame(UIView *view)
{
    CGAffineTransform transform = view.transform;
    view.transform = CGAffineTransformIdentity;
    CGRect result = view.frame;
    view.transform = transform;
    
    return result;
}

@interface TGModernConversationInputTextPanel () <HPGrowingTextViewDelegate, TGModernConversationInputMicButtonDelegate>
{
    CALayer *_stripeLayer;
    UIView *_backgroundView;
    
    CGFloat _sendButtonWidth;
    
#if TG_ENABLE_AUDIO_NOTES
    TGModernConversationInputMicButton *_micButton;
    UIImageView *_micButtonIconView;
#endif
    
    UIView *_audioRecordingContainer;
    NSUInteger _audioRecordingDurationSeconds;
    NSTimer *_audioRecordingTimer;
    UIImageView *_recordIndicatorView;
    UILabel *_recordDurationLabel;
    
    UIImageView *_slideToCancelArrow;
    UILabel *_slideToCancelLabel;
    
    CFAbsoluteTime _recordingInterfaceShowTime;
}

@end

@implementation TGModernConversationInputTextPanel

- (instancetype)initWithFrame:(CGRect)frame accessoryView:(UIView *)panelAccessoryView
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _sendButtonWidth = MIN(100.0f, [TGLocalized(@"Conversation.Send") sizeWithFont:TGMediumSystemFontOfSize(17)].width + 8.0f);
        _panelAccessoryView = panelAccessoryView;
        
        _backgroundView = [[UIView alloc] init];
        _backgroundView.backgroundColor = UIColorRGBA(0xfafafa, 0.98f);
        [self addSubview:_backgroundView];
        
        _stripeLayer = [[CALayer alloc] init];
        _stripeLayer.backgroundColor = UIColorRGBA(0xb3aab2, 0.4f).CGColor;
        [self.layer addSublayer:_stripeLayer];
        
        static UIImage *fieldBackgroundImage = nil;
        static UIImage *attachImage = nil;
        static UIImage *placeholderImage = nil;
        static int localizationVersion = 0;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^
        {
            fieldBackgroundImage = [[UIImage imageNamed:@"ModernConversationInput.png"] stretchableImageWithLeftCapWidth:8 topCapHeight:8];
            attachImage = [UIImage imageNamed:@"ModernConversationAttach.png"];
        });
        
        if (placeholderImage == nil || localizationVersion != TGLocalizedStaticVersion)
        {
            NSString *placeholderText = TGLocalized(@"Conversation.InputTextPlaceholder");
            UIFont *placeholderFont = TGSystemFontOfSize(16);
            CGSize placeholderSize = [placeholderText sizeWithFont:placeholderFont];
            placeholderSize.width += 2.0f;
            placeholderSize.height += 2.0f;
            
            UIGraphicsBeginImageContextWithOptions(placeholderSize, false, 0.0f);
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextSetFillColorWithColor(context, UIColorRGB(0xbebec0).CGColor);
            [placeholderText drawAtPoint:CGPointMake(1.0f, 1.0f) withFont:placeholderFont];
            placeholderImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            localizationVersion = TGLocalizedStaticVersion;
        }
        
        _fieldBackground = [[UIImageView alloc] initWithImage:fieldBackgroundImage];
        setViewFrame(_fieldBackground, CGRectMake(41, 9, self.frame.size.width - 41 - _sendButtonWidth - 1, 28));
        _fieldBackground.userInteractionEnabled = true;
        [_fieldBackground addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fieldBackgroundTapGesture:)]];
        [self addSubview:_fieldBackground];
        
        CGRect fieldBackgroundFrame = viewFrame(_fieldBackground);
        setViewFrame(_panelAccessoryView, CGRectMake(CGRectGetMaxX(fieldBackgroundFrame) - _panelAccessoryView.frame.size.width, fieldBackgroundFrame.origin.y, _panelAccessoryView.frame.size.width, _panelAccessoryView.frame.size.height));
        [self addSubview:_panelAccessoryView];
        
        CGPoint placeholderOffset = [self inputFieldPlaceholderOffset];
        _inputFieldPlaceholder = [[UIImageView alloc] initWithImage:placeholderImage];
        setViewFrame(_inputFieldPlaceholder, CGRectOffset(_inputFieldPlaceholder.frame, placeholderOffset.x, placeholderOffset.y));
        [_fieldBackground addSubview:_inputFieldPlaceholder];
        
        TGModernButton *sendButton = [[TGModernButton alloc] initWithFrame:CGRectZero];
        sendButton.modernHighlight = true;
        _sendButton = sendButton;
        _sendButton.exclusiveTouch = true;
        [_sendButton setTitle:TGLocalized(@"Conversation.Send") forState:UIControlStateNormal];
        [_sendButton setTitleColor:TGAccentColor() forState:UIControlStateNormal];
        [_sendButton setTitleColor:UIColorRGB(0x8e8e93) forState:UIControlStateDisabled];
        _sendButton.titleLabel.font = [self sendButtonFont];
        _sendButton.enabled = false;
        [_sendButton addTarget:self action:@selector(sendButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_sendButton];
        
        _attachButton = [[TGModernButton alloc] initWithFrame:CGRectMake(9, 11, attachImage.size.width, attachImage.size.height)];
        _attachButton.exclusiveTouch = true;
        [_attachButton setImage:attachImage forState:UIControlStateNormal];
        [_attachButton addTarget:self action:@selector(attachButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_attachButton];
        
        _micButton = [[TGModernConversationInputMicButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, _sendButtonWidth, 0.0f)];
        _micButton.delegate = self;
        _micButtonIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ModernConversationMicButton.png"]];
        [_micButton addSubview:_micButtonIconView];
        [self addSubview:_micButton];
        
        [self updateSendButtonVisibility];
    }
    return self;
}

- (void)dealloc
{
    [self stopAudioRecordingTimer];
}

- (HPGrowingTextView *)maybeInputField
{
    return _inputField;
}

- (HPGrowingTextView *)inputField
{
    if (_inputField == nil)
    {
        CGRect inputFieldClippingFrame = _fieldBackground.frame;
        inputFieldClippingFrame.size.width -= _panelAccessoryView.frame.size.width;
        _inputFieldClippingContainer = [[UIView alloc] initWithFrame:inputFieldClippingFrame];
        _inputFieldClippingContainer.clipsToBounds = true;
        [self addSubview:_inputFieldClippingContainer];
        
        UIEdgeInsets inputFieldInternalEdgeInsets = [self inputFieldInternalEdgeInsets];
        
        _inputField = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(inputFieldInternalEdgeInsets.left, inputFieldInternalEdgeInsets.top, _inputFieldClippingContainer.frame.size.width - inputFieldInternalEdgeInsets.left, _inputFieldClippingContainer.frame.size.height)];
        _inputField.placeholderView = _inputFieldPlaceholder;
        _inputField.font = TGSystemFontOfSize(16);
        _inputField.clipsToBounds = true;
        _inputField.backgroundColor = nil;
        _inputField.opaque = false;
        _inputField.internalTextView.backgroundColor = nil;
        _inputField.internalTextView.opaque = false;
        _inputField.internalTextView.contentMode = UIViewContentModeLeft;
        _inputField.maxNumberOfLines = [self _maxNumberOfLinesForInterfaceOrientation:_interfaceOrientation];
        _inputField.delegate = self;
        
        _inputField.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(-inputFieldInternalEdgeInsets.top, 0, 5 - TGRetinaPixel, 0);
        
        [_inputFieldClippingContainer addSubview:_inputField];
    }
    
    return _inputField;
}

- (void)growingTextViewDidChange:(HPGrowingTextView *)__unused growingTextView
{
    int textLength = growingTextView.text.length;
    NSString *text = growingTextView.text;
    bool hasNonWhitespace = false;
    for (int i = 0; i < textLength; i++)
    {
        unichar c = [text characterAtIndex:i];
        if (c != ' ' && c != '\n' && c != '\t')
        {
            hasNonWhitespace = true;
            break;
        }
    }
    
    if (_sendButton.enabled != hasNonWhitespace)
        _sendButton.enabled = hasNonWhitespace;
    
    [self updateSendButtonVisibility];
    
    if (hasNonWhitespace)
    {
        id<TGModernConversationInputTextPanelDelegate> delegate = (id<TGModernConversationInputTextPanelDelegate>)self.delegate;
        if ([delegate respondsToSelector:@selector(inputTextPanelHasIndicatedTypingActivity:)])
            [delegate inputTextPanelHasIndicatedTypingActivity:self];
    }
}

- (void)updateSendButtonVisibility
{
#if TG_ENABLE_AUDIO_NOTES
    
    bool hidden = _inputField == nil || _inputField.text.length == 0;
    
    if (!hidden)
    {
        NSString *text = _inputField.text;
        NSUInteger length = text.length;
        bool foundNonWhitespace = false;
        for (NSUInteger i = 0; i < length; i++)
        {
            unichar c = [text characterAtIndex:i];
            if (c != ' ')
            {
                foundNonWhitespace = true;
                break;
            }
        }
        
        if (!foundNonWhitespace)
            hidden = true;
    }
    
    _sendButton.hidden = hidden;
    _micButton.hidden = !_sendButton.hidden;
#endif
}

- (void)fieldBackgroundTapGesture:(UITapGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateRecognized)
    {
        [self inputField].internalTextView.enableFirstResponder = true;
        [[self inputField].internalTextView becomeFirstResponder];
    }
}

- (void)sendButtonPressed
{
    if (_inputField.internalTextView.isFirstResponder)
        [TGHacks applyCurrentKeyboardAutocorrectionVariant];
    
    NSMutableString *text = [[NSMutableString alloc] initWithString:_inputField.text];
    int textLength = text.length;
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
    
    if (text.length != 0)
    {
        id<TGModernConversationInputTextPanelDelegate> delegate = (id<TGModernConversationInputTextPanelDelegate>)self.delegate;
        if ([delegate respondsToSelector:@selector(inputPanelRequestedSendMessage:text:)])
            [delegate inputPanelRequestedSendMessage:self text:text];
    }
}

- (void)attachButtonPressed
{
    id<TGModernConversationInputTextPanelDelegate> delegate = (id<TGModernConversationInputTextPanelDelegate>)self.delegate;
    if ([delegate respondsToSelector:@selector(inputPanelRequestedAttachmentsMenu:)])
        [delegate inputPanelRequestedAttachmentsMenu:self];
}

- (void)micButtonInteractionBegan
{
    [self setShowRecordingInterface:true velocity:0.0f];
    
    id<TGModernConversationInputTextPanelDelegate> delegate = (id<TGModernConversationInputTextPanelDelegate>)self.delegate;
    if ([delegate respondsToSelector:@selector(inputPanelAudioRecordingStart:)])
        [delegate inputPanelAudioRecordingStart:self];
}

- (void)micButtonInteractionCancelled:(CGFloat)velocity
{
    [self setShowRecordingInterface:false velocity:velocity];
    
    id<TGModernConversationInputTextPanelDelegate> delegate = (id<TGModernConversationInputTextPanelDelegate>)self.delegate;
    if ([delegate respondsToSelector:@selector(inputPanelAudioRecordingCancel:)])
        [delegate inputPanelAudioRecordingCancel:self];
}

- (void)micButtonInteractionCompleted:(CGFloat)velocity
{
    [self setShowRecordingInterface:false velocity:velocity];
    
    id<TGModernConversationInputTextPanelDelegate> delegate = (id<TGModernConversationInputTextPanelDelegate>)self.delegate;
    if ([delegate respondsToSelector:@selector(inputPanelAudioRecordingComplete:)])
        [delegate inputPanelAudioRecordingComplete:self];
}

- (void)micButtonInteractionUpdate:(float)value
{
    CGFloat offset = value * 100.0f;
    
    offset = MAX(0.0f, offset - 5.0f);
    
    if (value < 0.3f)
        offset = value / 0.6f * offset;
    else
        offset -= 0.15f * 100.0f;
    
    _slideToCancelArrow.transform = CGAffineTransformMakeTranslation(-offset, 0.0f);
    
    CGAffineTransform labelTransform = CGAffineTransformIdentity;
    labelTransform = CGAffineTransformTranslate(labelTransform, -offset, 0.0f);
    _slideToCancelLabel.transform = labelTransform;
    
    CGAffineTransform indicatorTransform = CGAffineTransformIdentity;
    CGAffineTransform durationTransform = CGAffineTransformIdentity;
    
    static CGFloat freeOffsetLimit = 35.0f;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        CGFloat labelWidth = [TGLocalized(@"Conversation.SlideToCancel") sizeWithFont:TGSystemFontOfSize(14.0f)].width;
        CGFloat arrowOrigin = CGFloor((TGScreenSize().width - labelWidth) / 2.0f) - 9.0f - 6.0f;
        CGFloat timerWidth = 70.0f;
        
        freeOffsetLimit = MAX(0.0f, arrowOrigin - timerWidth);
    });
    
    if (offset > freeOffsetLimit)
    {
        indicatorTransform = CGAffineTransformMakeTranslation(freeOffsetLimit - offset, 0.0f);
        durationTransform = CGAffineTransformMakeTranslation(freeOffsetLimit - offset, 0.0f);
    }
    
    if (!CGAffineTransformEqualToTransform(indicatorTransform, _recordIndicatorView.transform))
        _recordIndicatorView.transform = indicatorTransform;
    
    if (!CGAffineTransformEqualToTransform(durationTransform, _recordDurationLabel.transform))
        _recordDurationLabel.transform = durationTransform;
}

- (int)_maxNumberOfLinesForInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    return UIInterfaceOrientationIsLandscape(orientation) ? 3 : ([TGViewController isWidescreen] ? 7 : 5);
}

- (void)adjustForOrientation:(UIInterfaceOrientation)orientation keyboardHeight:(float)keyboardHeight duration:(NSTimeInterval)duration animationCurve:(int)animationCurve
{
    if (UIInterfaceOrientationIsPortrait(_interfaceOrientation) != UIInterfaceOrientationIsPortrait(orientation))
        [self changeOrientationToOrientation:orientation keyboardHeight:keyboardHeight duration:0.0];

    _interfaceOrientation = orientation;
    
    [self _adjustForOrientation:orientation keyboardHeight:keyboardHeight inputFieldHeight:_inputField == nil ? 36.0f : _inputField.frame.size.height duration:duration animationCurve:animationCurve];
}

- (CGFloat)baseHeight
{
    static CGFloat value = 0.0f;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        value = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? 45.0f : 56.0f;
    });
    
    return value;
}

- (UIEdgeInsets)inputFieldInsets
{
    static UIEdgeInsets insets;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
            insets = UIEdgeInsetsMake(9.0f, 41.0f, 8.0f, 0.0f);
        else
            insets = UIEdgeInsetsMake(TGIsRetina() ? 12.0f : 12.0f, 58.0f, 12.0f, 21.0f);
    });
    
    return insets;
}

- (UIEdgeInsets)inputFieldInternalEdgeInsets
{
    static UIEdgeInsets insets;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
            insets = UIEdgeInsetsMake(-3 - TGRetinaPixel, 0.0f, 0.0f, 0.0f);
        else
            insets = UIEdgeInsetsMake(-1 - TGRetinaPixel, 4.0f, 0.0f, 0.0f);
    });
    
    return insets;
}

- (CGPoint)inputFieldPlaceholderOffset
{
    static CGPoint offset;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
            offset = CGPointMake(4.0f, 3.0f);
        else
            offset = CGPointMake(8.0f, 5.0f);
    });
    
    return offset;
}

- (CGFloat)heightForInputFieldHeight:(CGFloat)inputFieldHeight
{
    if (TGIsPad())
        inputFieldHeight += 4;
    
    UIEdgeInsets inputFieldInsets = [self inputFieldInsets];
    CGFloat height = MAX([self baseHeight], inputFieldHeight - 8 + inputFieldInsets.top + inputFieldInsets.bottom);
    
    return height;
}

- (UIFont *)sendButtonFont
{
    return TGMediumSystemFontOfSize(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? 17 : 18);
}

- (CGPoint)sendButtonOffset
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

- (void)_adjustForOrientation:(UIInterfaceOrientation)orientation keyboardHeight:(float)keyboardHeight inputFieldHeight:(float)inputFieldHeight duration:(NSTimeInterval)duration animationCurve:(int)animationCurve
{
    dispatch_block_t block = ^
    {
        id<TGModernConversationInputPanelDelegate> delegate = self.delegate;
        CGSize messageAreaSize = [delegate messageAreaSizeForInterfaceOrientation:orientation];
        
        CGFloat inputContainerHeight = [self heightForInputFieldHeight:inputFieldHeight];
        self.frame = CGRectMake(0, messageAreaSize.height - keyboardHeight - inputContainerHeight, messageAreaSize.width, inputContainerHeight);
        [self layoutSubviews];
    };
    
    if (duration > DBL_EPSILON)
        [UIView animateWithDuration:duration delay:0 options:animationCurve << 16 animations:block completion:nil];
    else
        block();
}

- (void)changeOrientationToOrientation:(UIInterfaceOrientation)orientation keyboardHeight:(float)keyboardHeight duration:(NSTimeInterval)duration
{
    _interfaceOrientation = orientation;
    
    id<TGModernConversationInputPanelDelegate> delegate = self.delegate;
    CGSize messageAreaSize = [delegate messageAreaSizeForInterfaceOrientation:orientation];
    
    UIView *inputFieldSnapshotView = nil;
    if (duration > DBL_EPSILON)
    {
        inputFieldSnapshotView = [_inputField.internalTextView snapshotViewAfterScreenUpdates:false];
        inputFieldSnapshotView.frame = CGRectOffset(_inputField.frame, _inputFieldClippingContainer.frame.origin.x, _inputFieldClippingContainer.frame.origin.y);
        [self addSubview:inputFieldSnapshotView];
    }
    
    [UIView performWithoutAnimation:^
    {
        NSRange range = _inputField.internalTextView.selectedRange;
        
        _inputField.delegate = nil;
        
        UIEdgeInsets inputFieldInsets = [self inputFieldInsets];
        UIEdgeInsets inputFieldInternalEdgeInsets = [self inputFieldInternalEdgeInsets];
        
        CGRect inputFieldClippingFrame = CGRectMake(inputFieldInsets.left, inputFieldInsets.top, messageAreaSize.width - inputFieldInsets.left - inputFieldInsets.right - _sendButtonWidth - 1, 0.0f);
        
        CGRect inputFieldFrame = CGRectMake(inputFieldInternalEdgeInsets.left, inputFieldInternalEdgeInsets.top, inputFieldClippingFrame.size.width - inputFieldInternalEdgeInsets.left, 0.0f);
        
        setViewFrame(_inputField, inputFieldFrame);
        [_inputField setMaxNumberOfLines:[self _maxNumberOfLinesForInterfaceOrientation:orientation]];
        [_inputField refreshHeight];
        
        _inputField.internalTextView.selectedRange = range;
        
        _inputField.delegate = self;
    }];
    
    CGFloat inputContainerHeight = [self heightForInputFieldHeight:_inputField.frame.size.height];
    CGRect newInputContainerFrame = CGRectMake(0, messageAreaSize.height - keyboardHeight - inputContainerHeight, messageAreaSize.width, inputContainerHeight);
    
    if (duration > DBL_EPSILON)
    {
        if (inputFieldSnapshotView != nil)
            _inputField.alpha = 0.0f;
        
        [UIView animateWithDuration:duration animations:^
        {
            self.frame = newInputContainerFrame;
            [self layoutSubviews];
            
            if (inputFieldSnapshotView != nil)
            {
                _inputField.alpha = 1.0f;
                inputFieldSnapshotView.frame = CGRectOffset(_inputField.frame, _inputFieldClippingContainer.frame.origin.x, _inputFieldClippingContainer.frame.origin.y);
                inputFieldSnapshotView.alpha = 0.0f;
            }
        } completion:^(__unused BOOL finished)
        {
            [inputFieldSnapshotView removeFromSuperview];
        }];
    }
    else
    {
        self.frame = newInputContainerFrame;
    }
}

- (void)growingTextView:(HPGrowingTextView *)__unused growingTextView willChangeHeight:(float)height duration:(NSTimeInterval)duration animationCurve:(int)animationCurve
{
    UIEdgeInsets inputFieldInsets = [self inputFieldInsets];
    CGFloat inputContainerHeight = MAX([self baseHeight], height - 8 + inputFieldInsets.top + inputFieldInsets.bottom);
    
    id<TGModernConversationInputTextPanelDelegate> delegate = (id<TGModernConversationInputTextPanelDelegate>)self.delegate;
    if ([delegate respondsToSelector:@selector(inputPanelWillChangeHeight:height:duration:animationCurve:)])
        [delegate inputPanelWillChangeHeight:self height:inputContainerHeight duration:duration animationCurve:animationCurve];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect frame = self.frame;
    
    _stripeLayer.frame = CGRectMake(-3.0f, -TGRetinaPixel, frame.size.width + 6.0f, TGRetinaPixel);
    _backgroundView.frame = CGRectMake(-3.0f, 0.0f, frame.size.width + 6.0f, frame.size.height);
    
    UIEdgeInsets inputFieldInsets = [self inputFieldInsets];
    
    setViewFrame(_fieldBackground, CGRectMake(inputFieldInsets.left, inputFieldInsets.top, frame.size.width - inputFieldInsets.left - inputFieldInsets.right - _sendButtonWidth - 1, frame.size.height - inputFieldInsets.top - inputFieldInsets.bottom));
    if (_panelAccessoryView != nil)
    {
        setViewFrame(_panelAccessoryView, CGRectMake(CGRectGetMaxX(_fieldBackground.frame) - _panelAccessoryView.frame.size.width, _fieldBackground.frame.origin.y, _panelAccessoryView.frame.size.width, _panelAccessoryView.frame.size.height));
    }
    
    CGPoint sendButtonOffset = [self sendButtonOffset];
    CGRect inputFieldClippingFrame = _fieldBackground.frame;
    inputFieldClippingFrame.size.width -= _panelAccessoryView.frame.size.width;
    setViewFrame(_inputFieldClippingContainer, inputFieldClippingFrame);
    setViewFrame(_sendButton, CGRectMake(frame.size.width - _sendButtonWidth + sendButtonOffset.x * 2.0f, frame.size.height - [self baseHeight], _sendButtonWidth - sendButtonOffset.x * 2.0f, [self baseHeight] - 1.0f));
    
    setViewFrame(_attachButton, CGRectMake(TGIsPad() ? (1.0f) : (-TGRetinaPixel), frame.size.height - [self baseHeight], inputFieldClippingFrame.origin.x - 1.0f, [self baseHeight] - (TGIsPad() ? 1 : 0)));
    
#if TG_ENABLE_AUDIO_NOTES
    setViewFrame(_micButton, _sendButton.frame);
    
    setViewFrame(_micButtonIconView, CGRectMake(CGFloor((_micButton.frame.size.width - _micButtonIconView.frame.size.width) / 2.0f), CGFloor((_micButton.frame.size.height - _micButtonIconView.frame.size.height) / 2.0f) + 1, _micButtonIconView.frame.size.width, _micButtonIconView.frame.size.height));
    
    if (_slideToCancelLabel != nil)
    {
        CGRect slideToCancelLabelFrame = viewFrame(_slideToCancelLabel);
        setViewFrame(_slideToCancelLabel, CGRectMake(CGFloor((self.frame.size.width - slideToCancelLabelFrame.size.width) / 2.0f), CGFloor((self.frame.size.height - slideToCancelLabelFrame.size.height) / 2.0f), slideToCancelLabelFrame.size.width, slideToCancelLabelFrame.size.height));
        
        CGRect slideToCancelArrowFrame = viewFrame(_slideToCancelArrow);
        setViewFrame(_slideToCancelArrow, CGRectMake(CGFloor((self.frame.size.width - slideToCancelLabelFrame.size.width) / 2.0f) - slideToCancelArrowFrame.size.width - 6.0f, CGFloor((self.frame.size.height - slideToCancelLabelFrame.size.height) / 2.0f) + 1.0f, slideToCancelArrowFrame.size.width, slideToCancelArrowFrame.size.height));
    }
#endif
    
    setViewFrame(_audioRecordingContainer, self.bounds);
}

- (void)setShowRecordingInterface:(bool)show velocity:(CGFloat)velocity
{
#if TG_ENABLE_AUDIO_NOTES
    if (show)
    {
        _recordingInterfaceShowTime = CFAbsoluteTimeGetCurrent();
        
        _micButtonIconView.image = [UIImage imageNamed:@"ModernConversationMicButton_Highlighted.png"];
        
        if (_audioRecordingContainer == nil)
        {
            _audioRecordingContainer = [[UIView alloc] initWithFrame:self.bounds];
            _audioRecordingContainer.clipsToBounds = true;
            [self insertSubview:_audioRecordingContainer aboveSubview:_backgroundView];
        }
        
        if (_recordIndicatorView == nil)
        {
            static UIImage *indicatorImage = nil;
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^
            {
                indicatorImage = TGCircleImage(9.0f, UIColorRGB(0xF33D2B));
            });
            _recordIndicatorView = [[UIImageView alloc] initWithImage:indicatorImage];
            setViewFrame(_recordIndicatorView, CGRectMake(11.0f, CGFloor(([self baseHeight] - 9.0f) / 2.0f) + (TGIsPad() ? 1.0f : 0.0f), 9.0f, 9.0f));
            _recordIndicatorView.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
            _recordIndicatorView.alpha = 0.0f;
            
            _recordIndicatorView.transform = CGAffineTransformMakeTranslation(-80.0f, 0.0f);
        }
        
        if (_recordDurationLabel == nil)
        {
            _recordDurationLabel = [[UILabel alloc] init];
            _recordDurationLabel.backgroundColor = [UIColor clearColor];
            _recordDurationLabel.textColor = [UIColor blackColor];
            _recordDurationLabel.font = TGSystemFontOfSize(15.0f);
            _recordDurationLabel.text = @"0:00";
            [_recordDurationLabel sizeToFit];
            _recordDurationLabel.alpha = 0.0f;
            _recordDurationLabel.layer.anchorPoint = CGPointMake((26.0f - _recordDurationLabel.frame.size.width) / (2 * 26.0f), 0.5f);
            setViewFrame(_recordDurationLabel, CGRectMake(26.0f, CGFloor(([self baseHeight] - _recordDurationLabel.frame.size.height) / 2.0f), 60.0f, _recordDurationLabel.frame.size.height));
            
            _recordDurationLabel.transform = CGAffineTransformMakeTranslation(-80.0f, 0.0f);
        }
        
        if (_slideToCancelLabel == nil)
        {
            _slideToCancelLabel = [[UILabel alloc] init];
            _slideToCancelLabel.backgroundColor = [UIColor clearColor];
            _slideToCancelLabel.textColor = UIColorRGB(0xaaaab2);
            _slideToCancelLabel.font = TGSystemFontOfSize(14.0f);
            _slideToCancelLabel.text = TGLocalized(@"Conversation.SlideToCancel");
            _slideToCancelLabel.clipsToBounds = false;
            [_slideToCancelLabel sizeToFit];
            setViewFrame(_slideToCancelLabel, CGRectMake(CGFloor((self.frame.size.width - _slideToCancelLabel.frame.size.width) / 2.0f), CGFloor((self.frame.size.height - _slideToCancelLabel.frame.size.height) / 2.0f), _slideToCancelLabel.frame.size.width, _slideToCancelLabel.frame.size.height));
            _slideToCancelLabel.alpha = 0.0f;
            
            _slideToCancelArrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ModernConversationAudioSlideToCancel.png"]];
            CGRect slideToCancelArrowFrame = viewFrame(_slideToCancelArrow);
            setViewFrame(_slideToCancelArrow, CGRectMake(CGFloor((self.frame.size.width - _slideToCancelLabel.frame.size.width) / 2.0f) - slideToCancelArrowFrame.size.width - 6.0f, CGFloor((self.frame.size.height - _slideToCancelLabel.frame.size.height) / 2.0f) + 1.0f, slideToCancelArrowFrame.size.width, slideToCancelArrowFrame.size.height));
            _slideToCancelArrow.alpha = 0.0f;
            [self addSubview:_slideToCancelArrow];
            
            _slideToCancelArrow.transform = CGAffineTransformMakeTranslation(320.0f, 0.0f);
            _slideToCancelLabel.transform = CGAffineTransformMakeTranslation(320.0f, 0.0f);
        }
        
        _recordDurationLabel.text = @"0:00";
        
        if (_recordIndicatorView.superview == nil)
            [_audioRecordingContainer addSubview:_recordIndicatorView];
        
        if (_recordDurationLabel.superview == nil)
            [_audioRecordingContainer addSubview:_recordDurationLabel];
        
        if (_slideToCancelLabel.superview == nil)
            [_audioRecordingContainer addSubview:_slideToCancelLabel];
        
        _slideToCancelArrow.transform = CGAffineTransformMakeTranslation(300.0f, 0.0f);
        _slideToCancelLabel.transform = CGAffineTransformMakeTranslation(300.0f, 0.0f);
        
        [UIView animateWithDuration:0.26 delay:0.0 options:0 animations:^
        {
            _inputFieldClippingContainer.alpha = 0.0f;
            _fieldBackground.alpha = 0.0f;
            _fieldBackground.transform = CGAffineTransformMakeTranslation(-320.0f, 0.0f);
            _inputFieldPlaceholder.alpha = 0.0f;
        } completion:nil];

        int animationCurveOption = iosMajorVersion() >= 7 ? (7 << 16) : 0;
        
        [UIView animateWithDuration:0.15 animations:^
        {
            _attachButton.alpha = 0.0f;
            _attachButton.transform = CGAffineTransformMakeTranslation(-320.0f, 0.0f);
        }];
        
        [UIView animateWithDuration:0.25 delay:0.06 options:animationCurveOption animations:^
        {
            _recordIndicatorView.alpha = 1.0f;
            _recordIndicatorView.transform = CGAffineTransformIdentity;
        } completion:nil];
        
        [UIView animateWithDuration:0.25 delay:0.0 options:animationCurveOption animations:^
        {
            _recordDurationLabel.alpha = 1.0f;
            _recordDurationLabel.transform = CGAffineTransformIdentity;
        } completion:nil];
        
        [UIView animateWithDuration:0.18 delay:0.0 options:animationCurveOption animations:^
        {
            _slideToCancelArrow.alpha = 1.0f;
            _slideToCancelArrow.transform = CGAffineTransformIdentity;
        } completion:nil];
        
        [UIView animateWithDuration:0.18 delay:0.04 options:animationCurveOption animations:^
        {
            _slideToCancelLabel.alpha = 1.0f;
            _slideToCancelLabel.transform = CGAffineTransformIdentity;
        } completion:nil];
    }
    else
    {
        NSTimeInterval durationFactor = MIN(0.4, MAX(1.0, velocity / 1000.0));
        
        _micButtonIconView.image = [UIImage imageNamed:@"ModernConversationMicButton.png"];
        
        int options = 0;
        
        if (ABS(CFAbsoluteTimeGetCurrent() - _recordingInterfaceShowTime) < 0.2)
        {
            options = UIViewAnimationOptionBeginFromCurrentState;
        }
        else
        {
            _attachButton.transform = CGAffineTransformMakeTranslation(320.0f, 0.0f);
            _fieldBackground.transform = CGAffineTransformMakeTranslation(320.0f, 0.0f);
        }
        
        [UIView animateWithDuration:0.25 delay:0.0 options:options animations:^
        {
            _inputFieldClippingContainer.alpha = 1.0f;
            _fieldBackground.alpha = 1.0f;
            _fieldBackground.transform = CGAffineTransformIdentity;
            _inputFieldPlaceholder.alpha = 1.0f;
        } completion:nil];
        
        [UIView animateWithDuration:0.25 delay:0 options:options animations:^
        {
            _attachButton.alpha = 1.0f;
            _attachButton.transform = CGAffineTransformIdentity;
        } completion:nil];

        int animationCurveOption = iosMajorVersion() >= 7 ? (7 << 16) : 0;
        [UIView animateWithDuration:0.25 * durationFactor delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState | animationCurveOption animations:^
        {
            _recordIndicatorView.alpha = 0.0f;
            _recordIndicatorView.transform = CGAffineTransformMakeTranslation(-90.0f, 0.0f);
        } completion:^(BOOL finished)
        {
            if (finished)
            {
                [_recordIndicatorView removeFromSuperview];
            }
        }];
        
        [UIView animateWithDuration:0.25 * durationFactor delay:0.05 * durationFactor options:UIViewAnimationOptionBeginFromCurrentState | animationCurveOption animations:^
        {
            _recordDurationLabel.alpha = 0.0f;
            _recordDurationLabel.transform = CGAffineTransformMakeTranslation(-90.0f, 0.0f);
        } completion:^(BOOL finished)
        {
            if (finished)
            {
                [_recordDurationLabel removeFromSuperview];
            }
        }];
        
        [UIView animateWithDuration:0.2 * durationFactor delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState | animationCurveOption animations:^
        {
            _slideToCancelArrow.alpha = 0.0f;
            _slideToCancelArrow.transform = CGAffineTransformMakeTranslation(-200, 0.0f);
        } completion:^(__unused BOOL finished)
        {
        }];
        
        [UIView animateWithDuration:0.2 * durationFactor delay:0.05 * durationFactor options:UIViewAnimationOptionBeginFromCurrentState | animationCurveOption animations:^
        {
            _slideToCancelLabel.alpha = 0.0f;
            _slideToCancelLabel.transform = CGAffineTransformMakeTranslation(-200, 0.0f);
        } completion:^(__unused BOOL finished)
        {
        }];
    }
#endif
}

- (void)startAudioRecordingTimer
{
    _recordDurationLabel.text = @"0:00";
    
    _audioRecordingDurationSeconds = 0;
    _audioRecordingTimer = [TGTimerTarget scheduledMainThreadTimerWithTarget:self action:@selector(audioTimerEvent) interval:1.0 repeat:false];
}

- (void)audioTimerEvent
{
    if (_audioRecordingTimer != nil)
    {
        [_audioRecordingTimer invalidate];
        _audioRecordingTimer = nil;
    }
    
    NSTimeInterval recordingDuration = 0.0;
    id<TGModernConversationInputTextPanelDelegate> delegate = (id<TGModernConversationInputTextPanelDelegate>)self.delegate;
    if ([delegate respondsToSelector:@selector(inputPanelAudioRecordingDuration:)])
        recordingDuration = [delegate inputPanelAudioRecordingDuration:self];
    
    MTAbsoluteTime currentTime = MTAbsoluteSystemTime();
    NSUInteger currentAudioDurationSeconds = (NSUInteger)recordingDuration;
    if (currentAudioDurationSeconds == _audioRecordingDurationSeconds)
    {
        _audioRecordingTimer = [TGTimerTarget scheduledMainThreadTimerWithTarget:self action:@selector(audioTimerEvent) interval:MAX(0.01, _audioRecordingDurationSeconds + 1.0 - currentTime) repeat:false];
    }
    else
    {
        _audioRecordingDurationSeconds = currentAudioDurationSeconds;
        _recordDurationLabel.text = [[NSString alloc] initWithFormat:@"%d:%02d", (int)_audioRecordingDurationSeconds / 60, (int)_audioRecordingDurationSeconds % 60];
        _audioRecordingTimer = [TGTimerTarget scheduledMainThreadTimerWithTarget:self action:@selector(audioTimerEvent) interval:1.0 repeat:false];
    }
}

- (void)stopAudioRecordingTimer
{
    if (_audioRecordingTimer != nil)
    {
        [_audioRecordingTimer invalidate];
        _audioRecordingTimer = nil;
    }
}

- (void)audioRecordingStarted
{
    [self startAudioRecordingTimer];
}

- (void)audioRecordingFinished
{
    [self stopAudioRecordingTimer];
}

- (void)shakeControls
{
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    NSMutableArray *values = [[NSMutableArray alloc] init];
    for (NSUInteger i = 0; i < 8; i++)
    {
        [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeTranslation(i % 2 == 0 ? -3.0f : 3.0f, 0.0f, 0.0f)]];
    }
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeTranslation(0.0f, 0.0f, 0.0f)]];
    animation.values = values;
    NSMutableArray *keyTimes = [[NSMutableArray alloc] init];
    for (NSUInteger i = 0; i < animation.values.count; i++)
        [keyTimes addObject:@((NSTimeInterval)i / (animation.values.count - 1.0))];
    animation.keyTimes = keyTimes;
    animation.duration = 0.5;
    [self.layer addAnimation:animation forKey:@"transform"];
    _micButton.userInteractionEnabled = false;
    TGDispatchAfter(0.5, dispatch_get_main_queue(), ^
    {
        _micButton.userInteractionEnabled = true;
    });
}

- (CGRect)attachmentButtonFrame
{
    return _attachButton.frame;
}

- (void)growingTextView:(HPGrowingTextView *)__unused growingTextView didPasteImages:(NSArray *)images
{    
    id<TGModernConversationInputTextPanelDelegate> delegate = (id<TGModernConversationInputTextPanelDelegate>)self.delegate;
    if ([delegate respondsToSelector:@selector(inputPanelRequestedSendImages:images:)])
        [delegate inputPanelRequestedSendImages:self images:images];
}

- (void)growingTextView:(HPGrowingTextView *)__unused growingTextView didPasteData:(NSData *)data
{
    id<TGModernConversationInputTextPanelDelegate> delegate = (id<TGModernConversationInputTextPanelDelegate>)self.delegate;
    if ([delegate respondsToSelector:@selector(inputPanelRequestedSendData:data:)])
        [delegate inputPanelRequestedSendData:self data:data];
}

@end
