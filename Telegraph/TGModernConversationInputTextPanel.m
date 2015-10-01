/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGModernConversationInputTextPanel.h"

#import "TGStickerKeyboardView.h"
#import "TGStickersSignals.h"

#import <MTProtoKit/MTTime.h>
#import "TGHacks.h"
#import "TGFont.h"
#import "TGImageUtils.h"
#import "TGStringUtils.h"
#import "TGTimerTarget.h"

#import "TGViewController.h"

#import "HPGrowingTextView.h"
#import "HPTextViewInternal.h"

#import "TGModernButton.h"
#import "TGModernConversationInputMicButton.h"

#import "TGModernConversationAssociatedInputPanel.h"
#import "TGStickerAssociatedInputPanel.h"
#import "TGCommandKeyboardView.h"

#import "TGModenConcersationReplyAssociatedPanel.h"
#import "TGModernConversationCommandsAssociatedPanel.h"

#import "TGAppDelegate.h"

#import "TGMessage.h"

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
    id<SDisposable> _stickerPacksDisposable;
    
    CALayer *_stripeLayer;
    UIView *_backgroundView;
    
    CGFloat _sendButtonWidth;
    
    CGSize _messageAreaSize;
    CGFloat _keyboardHeight;
    
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
    
    TGModernConversationAssociatedInputPanel *_associatedPanel;
    
    TGModernConversationAssociatedInputPanel *_firstExtendedPanel;
    TGModernConversationAssociatedInputPanel *_secondExtendedPanel;
    
    TGModernConversationAssociatedInputPanel *_currentExtendedPanel;

    TGModernButton *_keyboardModeButton;
    TGModernButton *_stickerModeButton;
    TGModernButton *_commandModeButton;
    TGModernButton *_slashModeButton;
    TGModernButton *_broadcastButton;
    
    NSArray *_modeButtons;
    
    TGStickerKeyboardView *_stickerKeyboardView;
    bool _shouldShowKeyboardAutomatically;
    
    UIView *_overlayDisabledView;
    
    CGSize _parentSize;
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
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^
        {
            fieldBackgroundImage = [[UIImage imageNamed:@"ModernConversationInput.png"] stretchableImageWithLeftCapWidth:8 topCapHeight:8];
            attachImage = [UIImage imageNamed:@"ModernConversationAttach.png"];
        });
        
        _fieldBackground = [[UIImageView alloc] initWithImage:fieldBackgroundImage];
        setViewFrame(_fieldBackground, CGRectMake(41, 9, self.frame.size.width - 41 - _sendButtonWidth - 1, 28));
        _fieldBackground.userInteractionEnabled = true;
        [_fieldBackground addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fieldBackgroundTapGesture:)]];
        [self addSubview:_fieldBackground];
        
        CGRect fieldBackgroundFrame = viewFrame(_fieldBackground);
        setViewFrame(_panelAccessoryView, CGRectMake(CGRectGetMaxX(fieldBackgroundFrame) - _panelAccessoryView.frame.size.width, fieldBackgroundFrame.origin.y, _panelAccessoryView.frame.size.width, _panelAccessoryView.frame.size.height));
        [self addSubview:_panelAccessoryView];
        
        CGPoint placeholderOffset = [self inputFieldPlaceholderOffset];
        _inputFieldPlaceholder = [[UIImageView alloc] init];
        [self _updatePlaceholderImage];
        setViewFrame(_inputFieldPlaceholder, CGRectOffset(_inputFieldPlaceholder.bounds, placeholderOffset.x, placeholderOffset.y));
        [_fieldBackground addSubview:_inputFieldPlaceholder];
        
        UIImage *stickerModeImage = [UIImage imageNamed:@"ConversationInputFieldStickerIcon.png"];
        _stickerModeButton = [[TGModernButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, stickerModeImage.size.width, 28.0f)];
        [_stickerModeButton setImage:stickerModeImage forState:UIControlStateNormal];
        [_stickerModeButton addTarget:self action:@selector(stickerModeButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        _stickerModeButton.adjustsImageWhenHighlighted = false;
        
        UIImage *commandModeImage = [UIImage imageNamed:@"ConversationInputFieldActionsIcon.png"];
        _commandModeButton = [[TGModernButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, commandModeImage.size.width, 28.0f)];
        [_commandModeButton setImage:commandModeImage forState:UIControlStateNormal];
        [_commandModeButton addTarget:self action:@selector(commandModeButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        _commandModeButton.adjustsImageWhenHighlighted = false;
        
        UIImage *slashModeImage = [UIImage imageNamed:@"ConversationInputFieldCommandIcon.png"];
        _slashModeButton = [[TGModernButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, slashModeImage.size.width, 28.0f)];
        [_slashModeButton setImage:slashModeImage forState:UIControlStateNormal];
        [_slashModeButton addTarget:self action:@selector(slashModeButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        _slashModeButton.adjustsImageWhenHighlighted = false;
        
        UIImage *broadcastImage = _isBroadcasting ? [UIImage imageNamed:@"ConversationInputFieldBroadcastIconActive.png"] : [UIImage imageNamed:@"ConversationInputFieldBroadcastIconInactive.png"];
        _broadcastButton = [[TGModernButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, broadcastImage.size.width, 28.0f)];
        [_broadcastButton setContentEdgeInsets:UIEdgeInsetsMake(0.0f, 0.0f, 1.0f, 0.0f)];
        [_broadcastButton setImage:broadcastImage forState:UIControlStateNormal];
        [_broadcastButton addTarget:self action:@selector(broadcastButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        _broadcastButton.adjustsImageWhenHighlighted = false;
        
        UIImage *keyboardModeImage = [UIImage imageNamed:@"ConversationInputFieldKeyboardIcon.png"];
        _keyboardModeButton = [[TGModernButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, keyboardModeImage.size.width, 28.0f)];
        [_keyboardModeButton setImage:keyboardModeImage forState:UIControlStateNormal];
        [_keyboardModeButton addTarget:self action:@selector(keyboardModeButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        _keyboardModeButton.adjustsImageWhenHighlighted = false;
        
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
        [self updateModeButtonVisibility];
        
        __weak TGModernConversationInputTextPanel *weakSelf = self;
        _stickerPacksDisposable = [[[[TGStickersSignals stickerPacks] startOn:[SQueue concurrentDefaultQueue]] deliverOn:[SQueue mainQueue]] startWithNext:^(__unused NSDictionary *stickerPacks)
        {
            __strong TGModernConversationInputTextPanel *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                [strongSelf updateModeButtonVisibility];
            }
        }];
    }
    return self;
}

- (void)dealloc
{
    [_stickerPacksDisposable dispose];
    
    [self stopAudioRecordingTimer];
}

- (void)_updatePlaceholderImage {
    static int localizationVersion = 0;
    static UIImage *placeholderImage = nil;
    static UIImage *placeholderBroadcastImage = nil;
    static UIImage *placeholderDisabledImage = nil;
    static UIImage *placeholderCommentImage = nil;
    if (placeholderImage == nil || localizationVersion != TGLocalizedStaticVersion)
    {
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
        }
        
        {
            NSString *placeholderText = TGLocalized(@"Conversation.InputTextCommentPlaceholder");
            UIFont *placeholderFont = TGSystemFontOfSize(16);
            CGSize placeholderSize = [placeholderText sizeWithFont:placeholderFont];
            placeholderSize.width += 2.0f;
            placeholderSize.height += 2.0f;
            
            UIGraphicsBeginImageContextWithOptions(placeholderSize, false, 0.0f);
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextSetFillColorWithColor(context, UIColorRGB(0xbebec0).CGColor);
            [placeholderText drawAtPoint:CGPointMake(1.0f, 1.0f) withFont:placeholderFont];
            placeholderCommentImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
        
        {
            NSString *placeholderBroadcastText = TGLocalized(@"Conversation.InputTextBroadcastPlaceholder");
            UIFont *placeholderFont = TGSystemFontOfSize(16);
            CGSize placeholderSize = [placeholderBroadcastText sizeWithFont:placeholderFont];
            placeholderSize.width += 2.0f;
            placeholderSize.height += 2.0f;
            
            UIGraphicsBeginImageContextWithOptions(placeholderSize, false, 0.0f);
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextSetFillColorWithColor(context, UIColorRGB(0xbebec0).CGColor);
            [placeholderBroadcastText drawAtPoint:CGPointMake(1.0f, 1.0f) withFont:placeholderFont];
            placeholderBroadcastImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
        
        {
            NSString *placeholderDisabledText = TGLocalized(@"Conversation.InputTextDisabledPlaceholder");
            UIFont *placeholderFont = TGSystemFontOfSize(16);
            CGSize placeholderSize = [placeholderDisabledText sizeWithFont:placeholderFont];
            placeholderSize.width += 2.0f;
            placeholderSize.height += 2.0f;
            
            UIGraphicsBeginImageContextWithOptions(placeholderSize, false, 0.0f);
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextSetFillColorWithColor(context, UIColorRGB(0xbebec0).CGColor);
            [placeholderDisabledText drawAtPoint:CGPointMake(1.0f, 1.0f) withFont:placeholderFont];
            placeholderDisabledImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
        
        localizationVersion = TGLocalizedStaticVersion;
    }
    
    if (_inputDisabled) {
        _inputFieldPlaceholder.image = placeholderDisabledImage;
    } else if ((_canBroadcast && _isBroadcasting) || _isAlwaysBroadcasting) {
        _inputFieldPlaceholder.image = placeholderBroadcastImage;
    } else if (_isChannel) {
        _inputFieldPlaceholder.image = placeholderCommentImage;
    } else {
        _inputFieldPlaceholder.image = placeholderImage;
    }
    [_inputFieldPlaceholder sizeToFit];
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
        _inputField.maxNumberOfLines = [self _maxNumberOfLinesForSize:_parentSize];
        _inputField.delegate = self;
        
        _inputField.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(-inputFieldInternalEdgeInsets.top, 0, 5 - TGRetinaPixel, 0);
        
        [_inputFieldClippingContainer addSubview:_inputField];
    }
    
    return _inputField;
}

- (BOOL)growingTextViewEnabled:(HPGrowingTextView *)__unused growingTextView
{
    id<TGModernConversationInputTextPanelDelegate> delegate = (id<TGModernConversationInputTextPanelDelegate>)self.delegate;
    if ([delegate respondsToSelector:@selector(isInputPanelTextEnabled:)])
        return [delegate isInputPanelTextEnabled:self];
    
    return true;
}

- (void)growingTextViewDidBeginEditing:(HPGrowingTextView *)__unused growingTextView
{
    id<TGModernConversationInputTextPanelDelegate> delegate = (id<TGModernConversationInputTextPanelDelegate>)self.delegate;
    if ([delegate respondsToSelector:@selector(inputPanelFocused:)])
        [delegate inputPanelFocused:self];
}

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

+ (NSString *)linkCandidateInText:(NSString *)text
{
    if ([text rangeOfString:@"http://"].location == NSNotFound && [text rangeOfString:@"https://"].location == NSNotFound)
    {
        return nil;
    }
    
    static NSDataDetector *dataDetector = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        dataDetector = [NSDataDetector dataDetectorWithTypes:(int)(NSTextCheckingTypeLink) error:NULL];
    });
    
    __block NSString *linkCandidate = nil;
    [[dataDetector matchesInString:text options:0 range:NSMakeRange(0, text.length)] enumerateObjectsUsingBlock:^(NSTextCheckingResult *result, __unused NSUInteger idx, BOOL *stop)
    {
        if ([[result URL].scheme isEqualToString:@"http"] || [[result URL].scheme isEqualToString:@"https"])
        {
            linkCandidate = [[result URL] absoluteString];
            if (stop)
                *stop = true;
        }
    }];
    
    return linkCandidate;
}

- (void)growingTextViewDidChange:(HPGrowingTextView *)growingTextView afterSetText:(bool)afterSetText afterPastingText:(bool)afterPastingText
{
    id<TGModernConversationInputTextPanelDelegate> delegate = (id<TGModernConversationInputTextPanelDelegate>)self.delegate;
    
    int textLength = (int)growingTextView.text.length;
    NSString *text = growingTextView.text;
    bool hasNonWhitespace = [text hasNonWhitespaceCharacters];
    
    UITextRange *selRange = _inputField.internalTextView.selectedTextRange;
    UITextPosition *selStartPos = selRange.start;
    NSInteger idx = [_inputField.internalTextView offsetFromPosition:_inputField.internalTextView.beginningOfDocument toPosition:selStartPos];
    idx--;
    
    NSString *candidateMention = nil;
    NSString *candidateHashtag = nil;
    NSString *candidateCommand = nil;
    
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
            unichar previousC = 0;
            if (i > 0)
                previousC = [text characterAtIndex:i - 1];
            if (c == '@' && (previousC == 0 || ![characterSet characterIsMember:previousC]))
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
        
        if (candidateHashtag == nil)
        {
            if (idx >= 0 && idx < textLength)
            {
                for (NSInteger i = idx; i >= 0; i--)
                {
                    unichar c = [text characterAtIndex:i];
                    if (c == '/' && i == 0)
                    {
                        if (i == idx)
                            candidateCommand = @"";
                        else
                        {
                            @try {
                                candidateCommand = [text substringWithRange:NSMakeRange(i + 1, idx - i)];
                            } @catch(NSException *e) { }
                        }
                        
                        break;
                    }
                    
                    if (c == ' ' || (![characterSet characterIsMember:c] && c != '_'))
                        break;
                }
            }
        }
    }
    
    if ([delegate respondsToSelector:@selector(inputPanelMentionEntered:mention:)])
        [delegate inputPanelMentionEntered:self mention:candidateMention];
    
    if ([delegate respondsToSelector:@selector(inputPanelHashtagEntered:hashtag:)])
        [delegate inputPanelHashtagEntered:self hashtag:candidateHashtag];
    
    if ([delegate respondsToSelector:@selector(inputPanelCommandEntered:command:)])
        [delegate inputPanelCommandEntered:self command:candidateCommand];
    
    NSString *linkCandidate = [TGModernConversationInputTextPanel linkCandidateInText:text];
    if ([delegate respondsToSelector:@selector(inputPanelLinkParsed:link:probablyComplete:)])
        [delegate inputPanelLinkParsed:self link:linkCandidate probablyComplete:afterPastingText];
    
    bool sendButtonEnabled = hasNonWhitespace;
    if ([delegate respondsToSelector:@selector(inputPanelSendShouldBeAlwaysEnabled:)])
    {
        if ([delegate inputPanelSendShouldBeAlwaysEnabled:self])
            sendButtonEnabled = true;
    }
    
    if (_sendButton.enabled != sendButtonEnabled)
        _sendButton.enabled = sendButtonEnabled;
    
    if ([delegate respondsToSelector:@selector(inputPanelTextChanged:text:)])
        [delegate inputPanelTextChanged:self text:text];
    
    [self updateSendButtonVisibility];
    [self updateModeButtonVisibility];
    
    if (!afterSetText)
    {
        if (hasNonWhitespace)
        {
            id<TGModernConversationInputTextPanelDelegate> delegate = (id<TGModernConversationInputTextPanelDelegate>)self.delegate;
            if ([delegate respondsToSelector:@selector(inputTextPanelHasIndicatedTypingActivity:)])
                [delegate inputTextPanelHasIndicatedTypingActivity:self];
        }
    }
    
    if (!hasNonWhitespace)
    {
        id<TGModernConversationInputTextPanelDelegate> delegate = (id<TGModernConversationInputTextPanelDelegate>)self.delegate;
        if ([delegate respondsToSelector:@selector(inputTextPanelHasCancelledTypingActivity:)])
            [delegate inputTextPanelHasCancelledTypingActivity:self];
    }
}

- (void)updateModeButtonVisibility
{
    NSMutableArray *commands = [[NSMutableArray alloc] init];
    if (self.maybeInputField.internalTextView.inputView != nil) {
        [commands addObject:_keyboardModeButton];
        
        if (_canBroadcast && !_isAlwaysBroadcasting) {
            [commands addObject:_broadcastButton];
        }
    } else
    {
        if (_inputField.text.length == 0)
        {
            if (!(TGAppDelegateInstance.alwaysShowStickersMode != 2))
                [commands addObject:_stickerModeButton];
            if ([self currentReplyMarkup] != nil)
                [commands addObject:_commandModeButton];
            else if (_hasBots)
                [commands addObject:_slashModeButton];
        }
        
        if (_canBroadcast && !_isAlwaysBroadcasting) {
            [commands addObject:_broadcastButton];
        }
    }
    [self setModeButtons:commands];
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
    
    id<TGModernConversationInputTextPanelDelegate> delegate = (id<TGModernConversationInputTextPanelDelegate>)self.delegate;
    if ([delegate respondsToSelector:@selector(inputPanelSendShouldBeAlwaysEnabled:)])
    {
        if ([delegate inputPanelSendShouldBeAlwaysEnabled:self])
            hidden = false;
    }
    
    _sendButton.hidden = hidden;
    _micButton.hidden = !_sendButton.hidden;
#endif
}

- (void)fieldBackgroundTapGesture:(UITapGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateRecognized)
    {
        if (self.maybeInputField.isFirstResponder && self.maybeInputField.internalTextView.inputView != nil)
        {
            [self keyboardModeButtonPressed];
        }
        else
        {
            [self inputField].internalTextView.enableFirstResponder = true;
            [[self inputField].internalTextView becomeFirstResponder];
        }
    }
}

- (void)sendButtonPressed
{
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
    
    bool enableSend = text.length != 0;
    
    id<TGModernConversationInputTextPanelDelegate> delegate = (id<TGModernConversationInputTextPanelDelegate>)self.delegate;
    if ([delegate respondsToSelector:@selector(inputPanelSendShouldBeAlwaysEnabled:)])
    {
        if ([delegate inputPanelSendShouldBeAlwaysEnabled:self])
            enableSend = true;
    }
    
    if (enableSend)
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
    id<TGModernConversationInputTextPanelDelegate> delegate = (id<TGModernConversationInputTextPanelDelegate>)self.delegate;
    if ([delegate respondsToSelector:@selector(inputPanelAudioRecordingEnabled:)])
    {
        if (![delegate inputPanelAudioRecordingEnabled:self])
            return;
    }
    
    [self setShowRecordingInterface:true velocity:0.0f];
    
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

- (void)micButtonInteractionUpdate:(CGFloat)value
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

- (void)adjustForSize:(CGSize)size keyboardHeight:(CGFloat)keyboardHeight duration:(NSTimeInterval)duration animationCurve:(int)animationCurve
{
    CGSize previousSize = _parentSize;
    _parentSize = size;
    if (ABS(previousSize.width - size.width) > FLT_EPSILON) {
        [self changeToSize:size keyboardHeight:keyboardHeight duration:0.0];
    }
    
    [self _adjustForSize:size keyboardHeight:keyboardHeight inputFieldHeight:_inputField == nil ? 36.0f : _inputField.frame.size.height duration:duration animationCurve:animationCurve];
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

- (bool)shouldDisplayPanels
{
    return [TGViewController hasLargeScreen] || _messageAreaSize.width <= _messageAreaSize.height || _keyboardHeight < FLT_EPSILON;
}

- (CGFloat)extendedPanelHeight
{
    return [self shouldDisplayPanels] ? [_currentExtendedPanel preferredHeight] : 0.0f;
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
    
    return height + [self extendedPanelHeight];
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

- (void)_adjustForSize:(CGSize)size keyboardHeight:(CGFloat)keyboardHeight inputFieldHeight:(CGFloat)inputFieldHeight duration:(NSTimeInterval)duration animationCurve:(int)animationCurve
{
    dispatch_block_t block = ^
    {
        CGSize messageAreaSize = size;
        
        _messageAreaSize = messageAreaSize;
        _keyboardHeight = keyboardHeight;
        
        CGFloat inputContainerHeight = [self heightForInputFieldHeight:inputFieldHeight];
        self.frame = CGRectMake(0, messageAreaSize.height - keyboardHeight - inputContainerHeight, messageAreaSize.width, inputContainerHeight);
        [self layoutSubviews];
    };
    
    if (duration > DBL_EPSILON)
        [UIView animateWithDuration:duration delay:0 options:animationCurve << 16 animations:block completion:nil];
    else
        block();
}

- (void)changeToSize:(CGSize)size keyboardHeight:(CGFloat)keyboardHeight duration:(NSTimeInterval)duration
{
    _parentSize = size;
    
    CGSize messageAreaSize = size;
    _messageAreaSize = messageAreaSize;
    _keyboardHeight = keyboardHeight;
    
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
        
        CGRect inputFieldClippingFrame = CGRectMake(inputFieldInsets.left, inputFieldInsets.top, messageAreaSize.width - inputFieldInsets.left - inputFieldInsets.right - _sendButtonWidth - 1 - _panelAccessoryView.frame.size.width, 0.0f);
        
        CGRect inputFieldFrame = CGRectMake(inputFieldInternalEdgeInsets.left, inputFieldInternalEdgeInsets.top, inputFieldClippingFrame.size.width - inputFieldInternalEdgeInsets.left, 0.0f);
        
        setViewFrame(_inputField, inputFieldFrame);
        [_inputField setMaxNumberOfLines:[self _maxNumberOfLinesForSize:size]];
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

- (void)growingTextView:(HPGrowingTextView *)__unused growingTextView willChangeHeight:(CGFloat)height duration:(NSTimeInterval)duration animationCurve:(int)animationCurve
{
    UIEdgeInsets inputFieldInsets = [self inputFieldInsets];
    CGFloat inputContainerHeight = MAX([self baseHeight], height - 8 + inputFieldInsets.top + inputFieldInsets.bottom) + [self extendedPanelHeight];
    
    id<TGModernConversationInputTextPanelDelegate> delegate = (id<TGModernConversationInputTextPanelDelegate>)self.delegate;
    if ([delegate respondsToSelector:@selector(inputPanelWillChangeHeight:height:duration:animationCurve:)])
    {
        [delegate inputPanelWillChangeHeight:self height:inputContainerHeight duration:duration animationCurve:animationCurve];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect frame = self.frame;
    
    if (_overlayDisabledView != nil) {
        _overlayDisabledView.frame = self.bounds;
    }
    
    _stripeLayer.frame = CGRectMake(-3.0f, -TGRetinaPixel, frame.size.width + 6.0f, TGRetinaPixel);
    _backgroundView.frame = CGRectMake(-3.0f, 0.0f, frame.size.width + 6.0f, frame.size.height);
    
    bool displayPanels = [self shouldDisplayPanels];
    
    if (_currentExtendedPanel != nil)
    {
        _currentExtendedPanel.frame = CGRectMake(0.0f, 0.0f, frame.size.width, displayPanels ? [_currentExtendedPanel preferredHeight] : 0.0f);
    }
    
    if (_associatedPanel != nil)
    {
        CGRect associatedPanelFrame = CGRectMake(0.0f, -[_associatedPanel preferredHeight] + _currentExtendedPanel.frame.size.height, frame.size.width, displayPanels ? [_associatedPanel preferredHeight] : 0.0f);
        if (!CGRectEqualToRect(associatedPanelFrame, _associatedPanel.frame))
            _associatedPanel.frame = associatedPanelFrame;
    }
    
    UIEdgeInsets inputFieldInsets = [self inputFieldInsets];
    
    setViewFrame(_fieldBackground, CGRectMake(inputFieldInsets.left, inputFieldInsets.top + [self extendedPanelHeight], frame.size.width - inputFieldInsets.left - inputFieldInsets.right - _sendButtonWidth - 1, frame.size.height - inputFieldInsets.top - inputFieldInsets.bottom - [self extendedPanelHeight]));
    if (_panelAccessoryView != nil)
    {
        setViewFrame(_panelAccessoryView, CGRectMake(CGRectGetMaxX(_fieldBackground.frame) - _panelAccessoryView.frame.size.width - 2.0f, _fieldBackground.frame.origin.y, _panelAccessoryView.frame.size.width, _panelAccessoryView.frame.size.height));
    }
    
    CGFloat accessoryViewInset = 0.0f;
    if (_panelAccessoryView != nil)
        accessoryViewInset = _panelAccessoryView.frame.size.width + 2.0f;
    accessoryViewInset += 6.0f;
    CGFloat modeButtonVerticalOffset = TGIsPad() ? 2.0f : 0.0f;
    CGFloat modeButtonRightEdge = CGRectGetMaxX(_fieldBackground.frame) - accessoryViewInset - 4.0f;
    CGFloat modeButtonSpacing = 9.0f;
    for (UIButton *button in _modeButtons)
    {
        setViewFrame(button, CGRectMake(modeButtonRightEdge - button.frame.size.width, _fieldBackground.frame.origin.y + modeButtonVerticalOffset, button.frame.size.width, button.frame.size.height));
        modeButtonRightEdge -= modeButtonSpacing + button.frame.size.width;
    }
    
    CGPoint sendButtonOffset = [self sendButtonOffset];
    CGRect inputFieldClippingFrame = _fieldBackground.frame;
    inputFieldClippingFrame.size.width -= _panelAccessoryView.frame.size.width;
    setViewFrame(_inputFieldClippingContainer, inputFieldClippingFrame);
    setViewFrame(_sendButton, CGRectMake(frame.size.width - _sendButtonWidth + sendButtonOffset.x * 2.0f, frame.size.height - [self baseHeight], _sendButtonWidth - sendButtonOffset.x * 2.0f, [self baseHeight] - 1.0f));
    
    setViewFrame(_attachButton, CGRectMake(TGIsPad() ? (1.0f) : (-TGRetinaPixel), frame.size.height - [self baseHeight], inputFieldClippingFrame.origin.x - 1.0f, [self baseHeight] - (TGIsPad() ? 1 : 0)));
    
#if TG_ENABLE_AUDIO_NOTES
    setViewFrame(_micButton, CGRectInset(_sendButton.frame, 0.0f, -2.0f));
    
    setViewFrame(_micButtonIconView, CGRectMake(CGFloor((_micButton.frame.size.width - _micButtonIconView.frame.size.width) / 2.0f), CGFloor((_micButton.frame.size.height - _micButtonIconView.frame.size.height) / 2.0f) + 1.0f + TGRetinaPixel, _micButtonIconView.frame.size.width, _micButtonIconView.frame.size.height));
    
    if (_slideToCancelLabel != nil)
    {
        CGRect slideToCancelLabelFrame = viewFrame(_slideToCancelLabel);
        setViewFrame(_slideToCancelLabel, CGRectMake(CGFloor((self.frame.size.width - slideToCancelLabelFrame.size.width) / 2.0f), _currentExtendedPanel.frame.size.height + CGFloor((self.frame.size.height - _currentExtendedPanel.frame.size.height - slideToCancelLabelFrame.size.height) / 2.0f), slideToCancelLabelFrame.size.width, slideToCancelLabelFrame.size.height));
        
        CGRect slideToCancelArrowFrame = viewFrame(_slideToCancelArrow);
        setViewFrame(_slideToCancelArrow, CGRectMake(CGFloor((self.frame.size.width - slideToCancelLabelFrame.size.width) / 2.0f) - slideToCancelArrowFrame.size.width - 6.0f, _currentExtendedPanel.frame.size.height + CGFloor((self.frame.size.height - _currentExtendedPanel.frame.size.height - slideToCancelLabelFrame.size.height) / 2.0f) + 1.0f, slideToCancelArrowFrame.size.width, slideToCancelArrowFrame.size.height));
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
            _recordIndicatorView.alpha = 0.0f;
        }
        
        setViewFrame(_recordIndicatorView, CGRectMake(11.0f, _currentExtendedPanel.frame.size.height + CGFloor(([self baseHeight] - 9.0f) / 2.0f) + (TGIsPad() ? 1.0f : 0.0f), 9.0f, 9.0f));
        _recordIndicatorView.transform = CGAffineTransformMakeTranslation(-80.0f, 0.0f);
        
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
            _recordDurationLabel.textAlignment = NSTextAlignmentLeft;
        }
        
        setViewFrame(_recordDurationLabel, CGRectMake(26.0f, _currentExtendedPanel.frame.size.height + CGFloor(([self baseHeight] - _recordDurationLabel.frame.size.height) / 2.0f), 60.0f, _recordDurationLabel.frame.size.height));
        
        _recordDurationLabel.transform = CGAffineTransformMakeTranslation(-80.0f, 0.0f);
        
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
            _panelAccessoryView.transform = CGAffineTransformMakeTranslation(-320.0f, 0.0f);
            for (UIButton *button in _modeButtons)
            {
                button.transform = CGAffineTransformMakeTranslation(-320.0f, 0.0f);
            }
            _panelAccessoryView.alpha = 0.0f;
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
            _panelAccessoryView.alpha = 1.0f;
            _panelAccessoryView.transform = CGAffineTransformIdentity;
            for (UIButton *button in _modeButtons)
            {
                button.transform = CGAffineTransformIdentity;
            }
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
            __weak TGModernConversationInputTextPanel *weakSelf = self;
            _associatedPanel.preferredHeightUpdated = ^
            {
                __strong TGModernConversationInputTextPanel *strongSelf = weakSelf;
                if (strongSelf != nil)
                {
                    strongSelf->_associatedPanel.frame = CGRectMake(0.0f, -[strongSelf->_associatedPanel preferredHeight] + strongSelf->_currentExtendedPanel.frame.size.height, strongSelf.frame.size.width, [strongSelf shouldDisplayPanels] ? [strongSelf->_associatedPanel preferredHeight] : 0.0f);
                }
            };
            _associatedPanel.frame = CGRectMake(0.0f, -[_associatedPanel preferredHeight] + _currentExtendedPanel.frame.size.height, self.frame.size.width, [self shouldDisplayPanels] ? [_associatedPanel preferredHeight] : 0.0f);
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

- (TGBotReplyMarkup *)currentReplyMarkup
{
    if ([_firstExtendedPanel isKindOfClass:[TGModenConcersationReplyAssociatedPanel class]])
    {
        TGMessage *message = ((TGModenConcersationReplyAssociatedPanel *)_firstExtendedPanel).message;
        return message.replyMarkup;
    }
    return _replyMarkup;
}

- (bool)shouldDisableAutocorrection
{
    if ([_firstExtendedPanel isKindOfClass:[TGModernConversationCommandsAssociatedPanel class]])
        return true;
    return false;
}

- (void)setPrimaryExtendedPanel:(TGModernConversationAssociatedInputPanel *)extendedPanel animated:(bool)animated
{
    [self setPrimaryExtendedPanel:extendedPanel animated:animated skipHeightAnimation:false];
}

- (void)setPrimaryExtendedPanel:(TGModernConversationAssociatedInputPanel *)extendedPanel animated:(bool)animated skipHeightAnimation:(bool)skipHeightAnimation
{
    TGBotReplyMarkup *previousReplyMarkup = [self currentReplyMarkup];
    
    _firstExtendedPanel = extendedPanel;
    if (_secondExtendedPanel == nil)
    {
        [self _setCurrentExtendedPanel:extendedPanel animated:animated skipHeightAnimation:skipHeightAnimation];
    }
    
    if (!TGObjectCompare(previousReplyMarkup, [self currentReplyMarkup]))
        [self setCurrentReplyMarkup:[self currentReplyMarkup]];
}

- (void)setSecondaryExtendedPanel:(TGModernConversationAssociatedInputPanel *)extendedPanel animated:(bool)animated
{
    [self setSecondaryExtendedPanel:extendedPanel animated:animated skipHeightAnimation:false];
}

- (void)setSecondaryExtendedPanel:(TGModernConversationAssociatedInputPanel *)extendedPanel animated:(bool)animated skipHeightAnimation:(bool)skipHeightAnimation
{
    _secondExtendedPanel = extendedPanel;
    if (_secondExtendedPanel == nil)
    {
        if (_firstExtendedPanel != nil)
        {
            [self _setCurrentExtendedPanel:_firstExtendedPanel animated:animated skipHeightAnimation:skipHeightAnimation];
        }
        else
        {
            [self _setCurrentExtendedPanel:nil animated:animated skipHeightAnimation:skipHeightAnimation];
        }
    }
    else
        [self _setCurrentExtendedPanel:extendedPanel animated:animated skipHeightAnimation:skipHeightAnimation];
}

- (void)_setCurrentExtendedPanel:(TGModernConversationAssociatedInputPanel *)currentExtendedPanel animated:(bool)animated skipHeightAnimation:(bool)skipHeightAnimation
{
    if (_currentExtendedPanel != currentExtendedPanel)
    {
        bool displayPanels = [self shouldDisplayPanels];
        
        if (animated)
        {
            UIView *previousExtendedPanel = _currentExtendedPanel;
            _currentExtendedPanel = currentExtendedPanel;
            
            if (_currentExtendedPanel != nil)
            {
                [_currentExtendedPanel setSendAreaWidth:_sendButtonWidth attachmentAreaWidth:[self inputFieldInsets].left];
                _currentExtendedPanel.frame = CGRectMake(0.0f, 0.0f, self.frame.size.width, displayPanels ? [_currentExtendedPanel preferredHeight] : 0.0f);
                
                if (previousExtendedPanel != nil)
                    [self insertSubview:_currentExtendedPanel aboveSubview:previousExtendedPanel];
                else
                    [self insertSubview:_currentExtendedPanel aboveSubview:_backgroundView];
            }
            
            _currentExtendedPanel.alpha = 0.0f;
            [UIView animateWithDuration:0.2 delay:0 options:0 animations:^
            {
                previousExtendedPanel.alpha = 0.0f;
                _currentExtendedPanel.alpha = 1.0f;
            } completion:^(__unused BOOL finished)
            {
                [previousExtendedPanel removeFromSuperview];
            }];
            
            if (!skipHeightAnimation)
            {
                CGFloat inputContainerHeight = [self heightForInputFieldHeight:_inputField.frame.size.height];
                
                id<TGModernConversationInputTextPanelDelegate> delegate = (id<TGModernConversationInputTextPanelDelegate>)self.delegate;
                if ([delegate respondsToSelector:@selector(inputPanelWillChangeHeight:height:duration:animationCurve:)])
                {
                    [delegate inputPanelWillChangeHeight:self height:inputContainerHeight duration:0.2 animationCurve:0];
                }
            }
        }
        else
        {
            UIView *previousPrimaryExtendedPanel = _currentExtendedPanel;
            _currentExtendedPanel = currentExtendedPanel;
            
            if (_currentExtendedPanel != nil)
            {
                [_currentExtendedPanel setSendAreaWidth:_sendButtonWidth attachmentAreaWidth:[self inputFieldInsets].left];
                _currentExtendedPanel.frame = CGRectMake(0.0f, 0.0f, self.frame.size.width, displayPanels ? [_currentExtendedPanel preferredHeight] : 0.0f);
                if (previousPrimaryExtendedPanel != nil)
                    [self insertSubview:_currentExtendedPanel aboveSubview:previousPrimaryExtendedPanel];
                else
                    [self insertSubview:_currentExtendedPanel aboveSubview:_backgroundView];
            }
            
            [previousPrimaryExtendedPanel removeFromSuperview];
            
            if (!skipHeightAnimation)
            {
                CGFloat inputContainerHeight = [self heightForInputFieldHeight:_inputField.frame.size.height];
                
                id<TGModernConversationInputTextPanelDelegate> delegate = (id<TGModernConversationInputTextPanelDelegate>)self.delegate;
                if ([delegate respondsToSelector:@selector(inputPanelWillChangeHeight:height:duration:animationCurve:)])
                {
                    [delegate inputPanelWillChangeHeight:self height:inputContainerHeight duration:0.0 animationCurve:0];
                }
            }
        }
    }
    
    id<TGModernConversationInputTextPanelDelegate> delegate = (id<TGModernConversationInputTextPanelDelegate>)self.delegate;
    bool sendButtonEnabled = [_inputField.internalTextView.text hasNonWhitespaceCharacters];
    if ([delegate respondsToSelector:@selector(inputPanelSendShouldBeAlwaysEnabled:)])
    {
        if ([delegate inputPanelSendShouldBeAlwaysEnabled:self])
            sendButtonEnabled = true;
    }
    
    if (_sendButton.enabled != sendButtonEnabled)
        _sendButton.enabled = sendButtonEnabled;
    
    [self updateSendButtonVisibility];
}

- (TGModernConversationAssociatedInputPanel *)primaryExtendedPanel
{
    return _firstExtendedPanel;
}

- (TGModernConversationAssociatedInputPanel *)secondaryExtendedPanel
{
    return _secondExtendedPanel;
}

- (void)setAssociatedStickerList:(NSArray *)stickerList stickerSelected:(void (^)(TGDocumentMediaAttachment *))stickerSelected
{
    if (stickerList.count != 0)
    {
        if ([_associatedPanel isKindOfClass:[TGStickerAssociatedInputPanel class]])
            [((TGStickerAssociatedInputPanel *)_associatedPanel) setDocumentList:stickerList];
        else
        {
            TGStickerAssociatedInputPanel *stickerPanel = [[TGStickerAssociatedInputPanel alloc] init];
            stickerPanel.documentSelected = stickerSelected;
            [stickerPanel setDocumentList:stickerList];
            [stickerPanel setTargetOffset:113.0f];
            [self setAssociatedPanel:stickerPanel animated:true];
        }
    }
    else
    {
        [self setAssociatedPanel:nil animated:true];
    }
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

- (void)growingTextView:(HPGrowingTextView *)__unused growingTextView receivedReturnKeyCommandWithModifierFlags:(UIKeyModifierFlags)flags
{
    if (flags & UIKeyModifierCommand)
        [self sendButtonPressed];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    if (_inputDisabled) {
        return nil;
    }
    
    for (UIButton *button in _modeButtons)
    {
        if (!button.hidden && CGRectContainsPoint(button.frame, point))
            return button;
    }
    
    if (_associatedPanel != nil)
    {
        UIView *result = [_associatedPanel hitTest:[self convertPoint:point toView:_associatedPanel] withEvent:event];
        if (result != nil)
            return result;
    }
    
    if (_currentExtendedPanel != nil)
    {
        UIView *result = [_currentExtendedPanel hitTest:[self convertPoint:point toView:_currentExtendedPanel] withEvent:event];
        if (result != nil)
            return result;
    }
    
    if (CGRectContainsPoint(_fieldBackground.frame, point) && self.maybeInputField.isFirstResponder && self.maybeInputField.internalTextView.inputView != nil)
    {
        return _fieldBackground;
    }
    
    return [super hitTest:point withEvent:event];
}

- (void)adjustCustomKeyboardForWidth:(CGFloat)width
{
    [_stickerKeyboardView sizeToFitForWidth:width];
    [_stickerKeyboardView.superview setNeedsLayout];
}

- (void)setModeButtons:(NSArray *)modeButtons
{
    if ([_modeButtons isEqualToArray:modeButtons])
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
        if (_overlayDisabledView.superview != nil) {
            [self insertSubview:button belowSubview:_overlayDisabledView];
        } else {
            [self addSubview:button];
        }
        inset += button.frame.size.width + 9.0f;
    }

    if (iosMajorVersion() >= 7) {
        UIEdgeInsets insets = _inputField.internalTextView.textContainerInset;
        if (ABS(inset - insets.right) > FLT_EPSILON) {
            insets.right = inset;
            _inputField.internalTextView.textContainerInset = insets;
            [_inputField refreshHeight];
        }
    }
    
    [self setNeedsLayout];
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
    
    [self updateModeButtonVisibility];
}

- (void)stickerModeButtonPressed
{
    if ([self.inputField.internalTextView.inputView isKindOfClass:[TGStickerKeyboardView class]])
        return;
    
    if (self.maybeInputField.isFirstResponder)
    {
        _changingKeyboardMode = true;
        [self.inputField resignFirstResponder];
    }
    
    if (_stickerKeyboardView == nil)
    {
        _stickerKeyboardView = [[TGStickerKeyboardView alloc] init];
        id<TGModernConversationInputTextPanelDelegate> delegate = (id<TGModernConversationInputTextPanelDelegate>)self.delegate;
        _stickerKeyboardView.parentViewController = [delegate inputPanelParentViewController:self];
        __weak TGModernConversationInputTextPanel *weakSelf = self;
        _stickerKeyboardView.stickerSelected = ^(TGDocumentMediaAttachment *sticker)
        {
            __strong TGModernConversationInputTextPanel *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                id<TGModernConversationInputTextPanelDelegate> delegate = (id<TGModernConversationInputTextPanelDelegate>)strongSelf.delegate;
                [delegate inputPanelRequestedSendSticker:strongSelf sticker:sticker];
            }
        };
        [_stickerKeyboardView sizeToFitForWidth:self.frame.size.width];
    }
    else
        [_stickerKeyboardView updateIfNeeded];
    
    self.inputField.internalTextView.inputView = _stickerKeyboardView;
    
    self.inputField.internalTextView.enableFirstResponder = true;
    [self.inputField becomeFirstResponder];
    _changingKeyboardMode = false;
    
    [self updateModeButtonVisibility];
}

- (void)slashModeButtonPressed
{
    if (self.maybeInputField.text.length == 0)
    {
        self.inputField.internalTextView.enableFirstResponder = true;
        self.inputField.text = @"/";
        
        [self updateModeButtonVisibility];
    }
}

- (void)commandModeButtonPressed
{
    if ([self.inputField.internalTextView.inputView isKindOfClass:[TGCommandKeyboardView class]])
        return;
    
    if (self.maybeInputField.isFirstResponder)
    {
        _changingKeyboardMode = true;
        [self.inputField resignFirstResponder];
    }
    
    TGCommandKeyboardView *commandKeyboardView = [[TGCommandKeyboardView alloc] init];
    if ([self currentReplyMarkup].matchDefaultHeight)
    {
        commandKeyboardView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    [commandKeyboardView setReplyMarkup:[self currentReplyMarkup]];
    __weak TGModernConversationInputTextPanel *weakSelf = self;
    commandKeyboardView.commandActivated = ^(NSString *command, int32_t userId, int32_t messageId)
    {
        __strong TGModernConversationInputTextPanel *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            if ([strongSelf currentReplyMarkup].hideKeyboardOnActivation)
                [strongSelf keyboardModeButtonPressed];
            
            id<TGModernConversationInputTextPanelDelegate> delegate = (id<TGModernConversationInputTextPanelDelegate>)strongSelf.delegate;
            if ([delegate respondsToSelector:@selector(inputPanelRequestedActivateCommand:command:userId:messageId:)])
            {
                [delegate inputPanelRequestedActivateCommand:self command:command userId:userId messageId:messageId];
            }
        }
    };
    CGSize size = [commandKeyboardView sizeThatFits:self.frame.size];
    commandKeyboardView.frame = CGRectMake(0.0f, 0.0f, size.width, size.height);
    
    self.inputField.internalTextView.inputView = commandKeyboardView;
    
    self.inputField.internalTextView.enableFirstResponder = true;
    [self.inputField becomeFirstResponder];
    _changingKeyboardMode = false;
    
    [self updateModeButtonVisibility];
}

- (void)growingTextViewDidEndEditing:(HPGrowingTextView *)__unused growingTextView
{
    if (!_changingKeyboardMode)
    {
        self.maybeInputField.internalTextView.inputView = nil;
        [self updateModeButtonVisibility];
    }
}

- (void)setReplyMarkup:(TGBotReplyMarkup *)replyMarkup
{
    if (!TGObjectCompare(_replyMarkup, replyMarkup))
    {
        _replyMarkup = replyMarkup;
        
        [self setCurrentReplyMarkup:[self currentReplyMarkup]];
    }
}

- (void)setHasBots:(bool)hasBots
{
    if (_hasBots != hasBots)
    {
        _hasBots = hasBots;
        
        [self updateModeButtonVisibility];
    }
}

- (void)setCanBroadcast:(bool)canBroadcast {
    if (_canBroadcast != canBroadcast) {
        _canBroadcast = canBroadcast;
        
        [self updateModeButtonVisibility];
        [self _updatePlaceholderImage];
    }
}

- (void)setIsBroadcasting:(bool)isBroadcasting {
    if (_isBroadcasting != isBroadcasting) {
        _isBroadcasting = isBroadcasting;
        
        UIImage *broadcastImage = _isBroadcasting ? [UIImage imageNamed:@"ConversationInputFieldBroadcastIconActive.png"] : [UIImage imageNamed:@"ConversationInputFieldBroadcastIconInactive.png"];
        [_broadcastButton setImage:broadcastImage forState:UIControlStateNormal];
        
        [self _updatePlaceholderImage];
    }
}

- (void)setIsAlwaysBroadcasting:(bool)isAlwaysBroadcasting {
    if (_isAlwaysBroadcasting != isAlwaysBroadcasting) {
        _isAlwaysBroadcasting = isAlwaysBroadcasting;
        
        [self updateModeButtonVisibility];
        [self _updatePlaceholderImage];
    }
}

- (void)setIsChannel:(bool)isChannel {
    if (_isChannel != isChannel) {
        _isChannel = isChannel;
        
        [self _updatePlaceholderImage];
    }
}

- (void)setInputDisabled:(bool)inputDisabled {
    if (_inputDisabled != inputDisabled) {
        _inputDisabled = inputDisabled;
        
        if (inputDisabled) {
            if (_overlayDisabledView == nil) {
                _overlayDisabledView = [[UIView alloc] init];
                _overlayDisabledView.backgroundColor = UIColorRGBA(0xf7f7f7, 0.5f);
            }
            if (_overlayDisabledView.superview == nil) {
                [self addSubview:_overlayDisabledView];
            }
            self.userInteractionEnabled = false;
        } else {
            if (_overlayDisabledView.superview != nil) {
                [_overlayDisabledView removeFromSuperview];
            }
            self.userInteractionEnabled = true;
        }
        
        [self _updatePlaceholderImage];
        [self setNeedsLayout];
    }
}

- (void)setCurrentReplyMarkup:(TGBotReplyMarkup *)replyMarkup
{
    if ([self.maybeInputField.internalTextView.inputView isKindOfClass:[TGCommandKeyboardView class]])
    {
        if (replyMarkup == nil || replyMarkup.rows.count == 0)
            [self keyboardModeButtonPressed];
        else
        {
            _changingKeyboardMode = true;
            
            TGCommandKeyboardView *commandKeyboardView = [[TGCommandKeyboardView alloc] init];
            if (replyMarkup.matchDefaultHeight)
            {
                commandKeyboardView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            }
            [commandKeyboardView setReplyMarkup:replyMarkup];
            __weak TGModernConversationInputTextPanel *weakSelf = self;
            commandKeyboardView.commandActivated = ^(NSString *command, int32_t userId, int32_t messageId)
            {
                __strong TGModernConversationInputTextPanel *strongSelf = weakSelf;
                if (strongSelf != nil)
                {
                    if ([strongSelf currentReplyMarkup].hideKeyboardOnActivation)
                        [strongSelf keyboardModeButtonPressed];
                    
                    id<TGModernConversationInputTextPanelDelegate> delegate = (id<TGModernConversationInputTextPanelDelegate>)strongSelf.delegate;
                    if ([delegate respondsToSelector:@selector(inputPanelRequestedActivateCommand:command:userId:messageId:)])
                        [delegate inputPanelRequestedActivateCommand:self command:command userId:userId messageId:messageId];
                }
            };
            CGSize size = [commandKeyboardView sizeThatFits:self.frame.size];
            commandKeyboardView.frame = CGRectMake(0.0f, 0.0f, size.width, size.height);
            
            self.inputField.internalTextView.inputView = commandKeyboardView;
            [self.inputField.internalTextView reloadInputViews];
            
            _changingKeyboardMode = false;
        }
    }
    else if (self.maybeInputField.text.length == 0 && replyMarkup != nil && replyMarkup.rows.count != 0)
    {
        if (![self.maybeInputField.internalTextView.inputView isKindOfClass:[TGStickerKeyboardView class]])
        {
            if (_enableKeyboard)
                [self commandModeButtonPressed];
            else
                _shouldShowKeyboardAutomatically = true;
        }
    }
    
    [self updateModeButtonVisibility];
}

- (void)setEnableKeyboard:(bool)enableKeyboard
{
    if (!_enableKeyboard)
    {
        _enableKeyboard = enableKeyboard;
        if (_canShowKeyboardAutomatically && _shouldShowKeyboardAutomatically && [self currentReplyMarkup] != nil && (![self currentReplyMarkup].hideKeyboardOnActivation || ![self currentReplyMarkup].alreadyActivated))
        {
            [self commandModeButtonPressed];
        }
    }
    else
        _enableKeyboard = enableKeyboard;
    _shouldShowKeyboardAutomatically = false;
}

- (void)broadcastButtonPressed {
    id<TGModernConversationInputTextPanelDelegate> delegate = (id<TGModernConversationInputTextPanelDelegate>)self.delegate;
    if ([delegate respondsToSelector:@selector(inputPanelToggleBroadcastMode:)]) {
        [delegate inputPanelToggleBroadcastMode:self];
    }
}

@end
