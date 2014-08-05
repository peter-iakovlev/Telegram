/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGContentBubbleViewModel.h"

#import "TGMessage.h"
#import "TGUser.h"

#import "TGImageUtils.h"
#import "TGDateUtils.h"
#import "TGStringUtils.h"

#import "TGTelegraphConversationMessageAssetsSource.h"
#import "TGReusableLabel.h"
#import "TGModernConversationItem.h"

#import "TGTextMessageBackgroundViewModel.h"
#import "TGModernFlatteningViewModel.h"
#import "TGModernDateViewModel.h"
#import "TGModernClockProgressViewModel.h"
#import "TGModernTextViewModel.h"

#import "TGModernView.h"

#import "TGDoubleTapGestureRecognizer.h"

@interface TGContentBubbleViewModel () <UIGestureRecognizerDelegate, TGDoubleTapGestureRecognizerDelegate>
{
    UITapGestureRecognizer *_unsentButtonTapRecognizer;
    TGDoubleTapGestureRecognizer *_boundDoubleTapRecognizer;
    
    TGModernImageViewModel *_broadcastIconModel;
}

@end

@implementation TGContentBubbleViewModel

- (instancetype)initWithMessage:(TGMessage *)message author:(TGUser *)author context:(TGModernViewContext *)context
{
    self = [super initWithAuthor:author context:context];
    if (self != nil)
    {
        static TGTelegraphConversationMessageAssetsSource *assetsSource = nil;
        
        static UIColor *incomingDateColor = nil;
        static UIColor *outgoingDateColor = nil;
        
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^
        {
            assetsSource = [TGTelegraphConversationMessageAssetsSource instance];
            
            incomingDateColor = UIColorRGBA(0x525252, 0.6f);
            outgoingDateColor = UIColorRGBA(0x008c09, 0.8f);
        });
        
        _needsEditingCheckButton = true;
        
        _mid = message.mid;
        _incoming = !message.outgoing;
        _deliveryState = message.deliveryState;
        _read = !message.unread;
        _date = (int32_t)message.date;
        
        _backgroundModel = [[TGTextMessageBackgroundViewModel alloc] initWithType:_incoming ? TGTextMessageBackgroundIncoming : TGTextMessageBackgroundOutgoing];
        _backgroundModel.blendMode = kCGBlendModeCopy;
        _backgroundModel.skipDrawInContext = true;
        [self addSubmodel:_backgroundModel];
        
        _contentModel = [[TGModernFlatteningViewModel alloc] initWithContext:_context];
        _contentModel.viewUserInteractionDisabled = true;
        [self addSubmodel:_contentModel];
        
        if (author != nil)
        {
            _authorNameModel = [[TGModernTextViewModel alloc] initWithText:author.displayName font:[assetsSource messageAuthorNameFont]];
            [_contentModel addSubmodel:_authorNameModel];
            
            _hasAvatar = true;
        }
        
        int daytimeVariant = 0;
        NSString *dateText = [TGDateUtils stringForShortTime:(int)message.date daytimeVariant:&daytimeVariant];
        _dateModel = [[TGModernDateViewModel alloc] initWithText:dateText textColor:_incoming ? incomingDateColor : outgoingDateColor daytimeVariant:daytimeVariant];
        [_contentModel addSubmodel:_dateModel];
        
        if (message.isBroadcast)
        {
            _broadcastIconModel = [[TGModernImageViewModel alloc] initWithImage:[UIImage imageNamed:@"ModernMessageBroadcastIcon.png"]];
            [_broadcastIconModel sizeToFit];
            [_contentModel addSubmodel:_broadcastIconModel];
        }
        
        if (!_incoming)
        {
            static UIImage *checkPartialImage = nil;
            static UIImage *checkCompleteImage = nil;
            
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^
            {
                checkPartialImage = [UIImage imageNamed:@"ModernMessageCheckmark2.png"];
                checkCompleteImage = [UIImage imageNamed:@"ModernMessageCheckmark1.png"];
            });
            
            _checkFirstModel = [[TGModernImageViewModel alloc] initWithImage:checkCompleteImage];
            _checkSecondModel = [[TGModernImageViewModel alloc] initWithImage:checkPartialImage];
            
            if (_deliveryState == TGMessageDeliveryStatePending)
            {
                _progressModel = [[TGModernClockProgressViewModel alloc] initWithType:TGModernClockProgressTypeOutgoingClock];
                [self addSubmodel:_progressModel];
                
                [self addSubmodel:_checkFirstModel];
                [self addSubmodel:_checkSecondModel];
                _checkFirstModel.alpha = 0.0f;
                _checkSecondModel.alpha = 0.0f;
            }
            else if (_deliveryState == TGMessageDeliveryStateFailed)
            {
                [self addSubmodel:[self unsentButtonModel]];
            }
            else if (_deliveryState == TGMessageDeliveryStateDelivered)
            {
                [_contentModel addSubmodel:_checkFirstModel];
                _checkFirstEmbeddedInContent = true;
                
                if (_read)
                {
                    [_contentModel addSubmodel:_checkSecondModel];
                    _checkSecondEmbeddedInContent = true;
                }
                else
                {
                    [self addSubmodel:_checkSecondModel];
                    _checkSecondModel.alpha = 0.0f;
                }
            }
        }
    }
    return self;
}

- (void)setTemporaryHighlighted:(bool)temporaryHighlighted viewStorage:(TGModernViewStorage *)__unused viewStorage
{
    if (temporaryHighlighted)
        [_backgroundModel setHighlightedIfBound];
    else
        [_backgroundModel clearHighlight];
}

- (void)setAuthorNameColor:(UIColor *)authorNameColor
{
    _authorNameModel.textColor = authorNameColor;
}

- (void)setForwardHeader:(TGUser *)forwardUser
{
    if (_forwardedHeaderModel == nil)
    {
        static UIColor *incomingForwardColor = nil;
        static UIColor *outgoingForwardColor = nil;
        
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^
        {
            incomingForwardColor = UIColorRGBA(0x007bff, 1.0f);
            outgoingForwardColor = UIColorRGBA(0x00a516, 1.0f);
        });
        
        static NSRange formatNameRange;
        
        static int localizationVersion = -1;
        if (localizationVersion != TGLocalizedStaticVersion)
            formatNameRange = [TGLocalized(@"Message.ForwardedMessage") rangeOfString:@"%@"];
        
        _forwardedUid = forwardUser.uid;
        
        NSString *authorName = forwardUser.displayName;
        NSString *text = [[NSString alloc] initWithFormat:TGLocalizedStatic(@"Message.ForwardedMessage"), authorName];
        
        _forwardedHeaderModel = [[TGModernTextViewModel alloc] initWithText:text font:[[TGTelegraphConversationMessageAssetsSource instance] messageForwardTitleFont]];
        _forwardedHeaderModel.textColor = _incoming ? incomingForwardColor : outgoingForwardColor;
        _forwardedHeaderModel.layoutFlags = TGReusableLabelLayoutMultiline;
        if (formatNameRange.location != NSNotFound && authorName.length != 0)
        {
            NSArray *fontAttributes = [[NSArray alloc] initWithObjects:(__bridge id)[[TGTelegraphConversationMessageAssetsSource instance] messageForwardNameFont], (NSString *)kCTFontAttributeName, nil];
            NSRange range = NSMakeRange(formatNameRange.location, authorName.length);
            _forwardedHeaderModel.additionalAttributes = [[NSArray alloc] initWithObjects:[[NSValue alloc] initWithBytes:&range objCType:@encode(NSRange)], fontAttributes, nil];
        }
        
        [_contentModel addSubmodel:_forwardedHeaderModel];
    }
}

- (TGModernImageViewModel *)unsentButtonModel
{
    if (_unsentButtonModel == nil)
    {
        static UIImage *image = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^
        {
            image = [UIImage imageNamed:@"ModernMessageUnsentButton.png"];
        });
        
        _unsentButtonModel = [[TGModernImageViewModel alloc] initWithImage:image];
        _unsentButtonModel.frame = CGRectMake(0.0f, 0.0f, image.size.width, image.size.height);
        _unsentButtonModel.extendedEdges = UIEdgeInsetsMake(6, 6, 6, 6);
    }
    
    return _unsentButtonModel;
}

- (void)updateMessage:(TGMessage *)message viewStorage:(TGModernViewStorage *)viewStorage
{
    [super updateMessage:message viewStorage:viewStorage];
    
    _mid = message.mid;
    
    if (_deliveryState != message.deliveryState || (!_incoming && _read != !message.unread))
    {
        TGMessageViewModelLayoutConstants const *layoutConstants = TGGetMessageViewModelLayoutConstants();
        
        TGMessageDeliveryState previousDeliveryState = _deliveryState;
        _deliveryState = message.deliveryState;
        
        bool previousRead = _read;
        _read = !message.unread;
        
        if (_date != (int32_t)message.date)
        {
            _date = (int32_t)message.date;
            
            int daytimeVariant = 0;
            NSString *dateText = [TGDateUtils stringForShortTime:(int)message.date daytimeVariant:&daytimeVariant];
            [_dateModel setText:dateText daytimeVariant:daytimeVariant];
        }
        
        if (_deliveryState == TGMessageDeliveryStateDelivered)
        {
            if (_progressModel != nil)
            {
                [self removeSubmodel:_progressModel viewStorage:viewStorage];
                _progressModel = nil;
            }
            
            _checkFirstModel.alpha = 1.0f;
            
            if (previousDeliveryState == TGMessageDeliveryStatePending && [_checkFirstModel boundView] != nil)
            {
                CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
                animation.fromValue = @(1.3f);
                animation.toValue = @(1.0f);
                animation.duration = 0.1;
                animation.removedOnCompletion = true;
                
                [[_checkFirstModel boundView].layer addAnimation:animation forKey:@"transform.scale"];
            }
            
            if (_read)
            {
                _checkSecondModel.alpha = 1.0f;
                
                if (!previousRead && [_checkSecondModel boundView] != nil)
                {
                    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
                    animation.fromValue = @(1.3f);
                    animation.toValue = @(1.0f);
                    animation.duration = 0.1;
                    animation.removedOnCompletion = true;
                    
                    [[_checkSecondModel boundView].layer addAnimation:animation forKey:@"transform.scale"];
                }
            }
            
            if (_unsentButtonModel != nil)
            {
                [self removeSubmodel:_unsentButtonModel viewStorage:viewStorage];
                _unsentButtonModel = nil;
            }
        }
        else if (_deliveryState == TGMessageDeliveryStateFailed)
        {
            if (_progressModel != nil)
            {
                [self removeSubmodel:_progressModel viewStorage:viewStorage];
                _progressModel = nil;
            }
            
            if (_checkFirstModel != nil)
            {
                if (_checkFirstEmbeddedInContent)
                {
                    [_contentModel removeSubmodel:_checkFirstModel viewStorage:viewStorage];
                    [_contentModel setNeedsSubmodelContentsUpdate];
                }
                else
                    [self removeSubmodel:_checkFirstModel viewStorage:viewStorage];
            }
            
            if (_checkSecondModel != nil)
            {
                if (_checkSecondEmbeddedInContent)
                {
                    [_contentModel removeSubmodel:_checkSecondModel viewStorage:viewStorage];
                    [_contentModel setNeedsSubmodelContentsUpdate];
                }
                else
                    [self removeSubmodel:_checkSecondModel viewStorage:viewStorage];
            }
            
            if (_unsentButtonModel == nil)
            {
                [self addSubmodel:[self unsentButtonModel]];
                if ([_contentModel boundView] != nil)
                    [_unsentButtonModel bindViewToContainer:[_contentModel boundView].superview viewStorage:viewStorage];
                _unsentButtonModel.frame = CGRectOffset(_unsentButtonModel.frame, self.frame.size.width + _unsentButtonModel.frame.size.width, self.frame.size.height - _unsentButtonModel.frame.size.height - ((_collapseFlags & TGModernConversationItemCollapseBottom) ? 5 : 6));
                
                _unsentButtonTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(unsentButtonTapGesture:)];
                [[_unsentButtonModel boundView] addGestureRecognizer:_unsentButtonTapRecognizer];
            }
            
            if (self.frame.size.width > FLT_EPSILON)
            {
                if ([_contentModel boundView] != nil)
                {
                    [UIView animateWithDuration:0.2 animations:^
                     {
                         [self layoutForContainerSize:CGSizeMake(self.frame.size.width, 0.0f)];
                     }];
                }
                else
                    [self layoutForContainerSize:CGSizeMake(self.frame.size.width, 0.0f)];
            }
            
            [_contentModel updateSubmodelContentsIfNeeded];
        }
        else if (_deliveryState == TGMessageDeliveryStatePending)
        {
            if (_progressModel == nil)
            {
                CGFloat unsentOffset = 0.0f;
                if (!_incoming && previousDeliveryState == TGMessageDeliveryStateFailed)
                    unsentOffset = 29.0f;
                
                _progressModel = [[TGModernClockProgressViewModel alloc] initWithType:TGModernClockProgressTypeOutgoingClock];
                _progressModel.frame = CGRectMake(self.frame.size.width - 28 - layoutConstants->rightInset - unsentOffset, _contentModel.frame.origin.y + _contentModel.frame.size.height - 17 + 1.0f, 15, 15);
                [self addSubmodel:_progressModel];
                
                if ([_contentModel boundView] != nil)
                {
                    [_progressModel bindViewToContainer:[_contentModel boundView].superview viewStorage:viewStorage];
                }
            }
            
            [_contentModel removeSubmodel:_checkFirstModel viewStorage:viewStorage];
            [_contentModel removeSubmodel:_checkSecondModel viewStorage:viewStorage];
            _checkFirstEmbeddedInContent = false;
            _checkSecondEmbeddedInContent = false;
            
            if (![self containsSubmodel:_checkFirstModel])
            {
                [self addSubmodel:_checkFirstModel];
                
                if ([_contentModel boundView] != nil)
                    [_checkFirstModel bindViewToContainer:[_contentModel boundView].superview viewStorage:viewStorage];
            }
            if (![self containsSubmodel:_checkSecondModel])
            {
                [self addSubmodel:_checkSecondModel];
                
                if ([_contentModel boundView] != nil)
                    [_checkSecondModel bindViewToContainer:[_contentModel boundView].superview viewStorage:viewStorage];
            }
            
            _checkFirstModel.alpha = 0.0f;
            _checkSecondModel.alpha = 0.0f;
            
            if (_unsentButtonModel != nil)
            {
                UIView<TGModernView> *unsentView = [_unsentButtonModel boundView];
                if (unsentView != nil)
                {
                    [unsentView removeGestureRecognizer:_unsentButtonTapRecognizer];
                    _unsentButtonTapRecognizer = nil;
                }
                
                if (unsentView != nil)
                {
                    [viewStorage allowResurrectionForOperations:^
                     {
                         [self removeSubmodel:_unsentButtonModel viewStorage:viewStorage];
                         
                         UIView *restoredView = [viewStorage dequeueViewWithIdentifier:[unsentView viewIdentifier] viewStateIdentifier:[unsentView viewStateIdentifier]];
                         
                         if (restoredView != nil)
                         {
                             [[_contentModel boundView].superview addSubview:restoredView];
                             
                             [UIView animateWithDuration:0.2 animations:^
                              {
                                  restoredView.frame = CGRectOffset(restoredView.frame, restoredView.frame.size.width + 9, 0.0f);
                                  restoredView.alpha = 0.0f;
                              } completion:^(__unused BOOL finished)
                              {
                                  [viewStorage enqueueView:restoredView];
                              }];
                         }
                     }];
                }
                else
                    [self removeSubmodel:_unsentButtonModel viewStorage:viewStorage];
                
                _unsentButtonModel = nil;
            }
            
            if (self.frame.size.width > FLT_EPSILON)
            {
                if ([_contentModel boundView] != nil)
                {
                    [UIView animateWithDuration:0.2 animations:^
                     {
                         [self layoutForContainerSize:CGSizeMake(self.frame.size.width, 0.0f)];
                     }];
                }
                else
                    [self layoutForContainerSize:CGSizeMake(self.frame.size.width, 0.0f)];
            }
            
            [_contentModel setNeedsSubmodelContentsUpdate];
            [_contentModel updateSubmodelContentsIfNeeded];
        }
    }
}

- (void)updateEditingState:(UIView *)container viewStorage:(TGModernViewStorage *)viewStorage animationDelay:(NSTimeInterval)animationDelay
{
    bool editing = _context.editing;
    if (editing != _editing)
    {
        [super updateEditingState:container viewStorage:viewStorage animationDelay:animationDelay];
        
        _backgroundModel.viewUserInteractionDisabled = _editing;
    }
}

- (void)_maybeRestructureStateModels:(TGModernViewStorage *)viewStorage
{
    if (!_incoming && [_contentModel boundView] == nil)
    {
        if (_deliveryState == TGMessageDeliveryStateDelivered)
        {
            if (!_checkFirstEmbeddedInContent)
            {
                if ([self.submodels containsObject:_checkFirstModel])
                {
                    _checkFirstEmbeddedInContent = true;
                    
                    [self removeSubmodel:_checkFirstModel viewStorage:viewStorage];
                    _checkFirstModel.frame = CGRectOffset(_checkFirstModel.frame, -_contentModel.frame.origin.x, -_contentModel.frame.origin.y);
                    [_contentModel addSubmodel:_checkFirstModel];
                }
            }
            
            if (_read && !_checkSecondEmbeddedInContent)
            {
                if ([self.submodels containsObject:_checkSecondModel])
                {
                    _checkSecondEmbeddedInContent = true;
                    
                    [self removeSubmodel:_checkSecondModel viewStorage:viewStorage];
                    _checkSecondModel.frame = CGRectOffset(_checkSecondModel.frame, -_contentModel.frame.origin.x, -_contentModel.frame.origin.y);
                    [_contentModel addSubmodel:_checkSecondModel];
                }
            }
        }
    }
}

- (void)bindSpecialViewsToContainer:(UIView *)container viewStorage:(TGModernViewStorage *)viewStorage atItemPosition:(CGPoint)itemPosition
{
    [super bindSpecialViewsToContainer:container viewStorage:viewStorage atItemPosition:itemPosition];
    
    [_backgroundModel bindViewToContainer:container viewStorage:viewStorage];
    [_backgroundModel boundView].frame = CGRectOffset([_backgroundModel boundView].frame, itemPosition.x, itemPosition.y);
}

- (void)bindViewToContainer:(UIView *)container viewStorage:(TGModernViewStorage *)viewStorage
{
    [self _maybeRestructureStateModels:viewStorage];
    
    [self updateEditingState:nil viewStorage:nil animationDelay:-1.0];
    
    [super bindViewToContainer:container viewStorage:viewStorage];
    
    _boundDoubleTapRecognizer = [[TGDoubleTapGestureRecognizer alloc] initWithTarget:self action:@selector(messageDoubleTapGesture:)];
    _boundDoubleTapRecognizer.delegate = self;
    
    UIView *backgroundView = [_backgroundModel boundView];
    [backgroundView addGestureRecognizer:_boundDoubleTapRecognizer];
    
    if (_unsentButtonModel != nil)
    {
        _unsentButtonTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(unsentButtonTapGesture:)];
        [[_unsentButtonModel boundView] addGestureRecognizer:_unsentButtonTapRecognizer];
    }
}

- (void)unbindView:(TGModernViewStorage *)viewStorage
{
    UIView *backgroundView = [_backgroundModel boundView];
    [backgroundView removeGestureRecognizer:_boundDoubleTapRecognizer];
    _boundDoubleTapRecognizer.delegate = nil;
    _boundDoubleTapRecognizer = nil;
    
    if (_unsentButtonModel != nil)
    {
        [[_unsentButtonModel boundView] removeGestureRecognizer:_unsentButtonTapRecognizer];
        _unsentButtonTapRecognizer = nil;
    }
    
    [super unbindView:viewStorage];
}

- (void)relativeBoundsUpdated:(CGRect)bounds
{
    [super relativeBoundsUpdated:bounds];
    
    [_contentModel updateSubmodelContentsForVisibleRect:CGRectOffset(bounds, -_contentModel.frame.origin.x, -_contentModel.frame.origin.y)];
}

- (CGRect)effectiveContentFrame
{
    return _backgroundModel.frame;
}

- (void)messageDoubleTapGesture:(TGDoubleTapGestureRecognizer *)recognizer
{
    if (recognizer.state != UIGestureRecognizerStateBegan)
    {
        if (recognizer.state == UIGestureRecognizerStateRecognized)
        {
            CGPoint point = [recognizer locationInView:[_contentModel boundView]];
            
            if (recognizer.longTapped)
                [_context.companionHandle requestAction:@"messageSelectionRequested" options:@{@"mid": @(_mid)}];
            else if (recognizer.doubleTapped)
                [_context.companionHandle requestAction:@"messageSelectionRequested" options:@{@"mid": @(_mid)}];
            else if (_forwardedHeaderModel && CGRectContainsPoint(_forwardedHeaderModel.frame, point))
                [_context.companionHandle requestAction:@"userAvatarTapped" options:@{@"uid": @(_forwardedUid)}];
        }
    }
}

- (void)gestureRecognizer:(TGDoubleTapGestureRecognizer *)__unused recognizer didBeginAtPoint:(CGPoint)__unused point
{
}

- (void)gestureRecognizerDidFail:(TGDoubleTapGestureRecognizer *)__unused recognizer
{
}

- (void)unsentButtonTapGesture:(UITapGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateRecognized)
    {
        [_context.companionHandle requestAction:@"showUnsentMessageMenu" options:@{@"mid": @(_mid)}];
    }
}

- (bool)gestureRecognizerShouldHandleLongTap:(TGDoubleTapGestureRecognizer *)__unused recognizer
{
    return true;
}

- (int)gestureRecognizer:(TGDoubleTapGestureRecognizer *)__unused recognizer shouldFailTap:(CGPoint)__unused point
{
    return 0;
}

- (void)doubleTapGestureRecognizerSingleTapped:(TGDoubleTapGestureRecognizer *)__unused recognizer
{
}

- (void)setCollapseFlags:(int)collapseFlags
{
    if (_collapseFlags != collapseFlags)
    {
        _collapseFlags = collapseFlags;
        [_backgroundModel setPartialMode:collapseFlags & TGModernConversationItemCollapseBottom];
    }
}

- (void)layoutContentForHeaderHeight:(CGFloat)__unused headerHeight
{
}

- (CGSize)contentSizeForContainerSize:(CGSize)__unused containerSize needsContentsUpdate:(bool *)__unused needsContentsUpdate
{
    return CGSizeZero;
}

- (void)layoutForContainerSize:(CGSize)containerSize
{
    TGMessageViewModelLayoutConstants const *layoutConstants = TGGetMessageViewModelLayoutConstants();
    
    bool isRTL = TGIsRTL();
    
    CGFloat topSpacing = (_collapseFlags & TGModernConversationItemCollapseTop) ? layoutConstants->topInsetCollapsed : layoutConstants->topInset;
    CGFloat bottomSpacing = (_collapseFlags & TGModernConversationItemCollapseBottom) ? layoutConstants->bottomInsetCollapsed : layoutConstants->bottomInset;
    
    CGSize contentContainerSize = CGSizeMake(MIN(420.0f, containerSize.width - 80.0f - (_hasAvatar ? 38.0f : 0.0f)), containerSize.height);
    
    bool updateContents = false;
    CGSize contentSize = [self contentSizeForContainerSize:contentContainerSize needsContentsUpdate:&updateContents];
    
    CGSize headerSize = CGSizeZero;
    if (_authorNameModel != nil)
    {
        if (_authorNameModel.frame.size.width < FLT_EPSILON)
            [_authorNameModel layoutForContainerSize:CGSizeMake(320.0f - 80.0f - (_hasAvatar ? 38.0f : 0.0f), 0.0f)];
        
        CGRect authorNameFrame = _authorNameModel.frame;
        authorNameFrame.origin = CGPointMake(1.0f, 1.0f + TGRetinaPixel);
        _authorNameModel.frame = authorNameFrame;
        
        headerSize = CGSizeMake(_authorNameModel.frame.size.width, _authorNameModel.frame.size.height + 1.0f);
    }
    
    if (_forwardedHeaderModel != nil)
    {
        [_forwardedHeaderModel layoutForContainerSize:CGSizeMake(containerSize.width - 80.0f - (_hasAvatar ? 38.0f : 0.0f), containerSize.height)];
        CGRect forwardedHeaderFrame = _forwardedHeaderModel.frame;
        forwardedHeaderFrame.origin = CGPointMake(1.0f, headerSize.height + 1.0f);
        _forwardedHeaderModel.frame = forwardedHeaderFrame;
        
        headerSize.height += forwardedHeaderFrame.size.height;
        headerSize.width = MAX(headerSize.width, forwardedHeaderFrame.size.width);
    }
    
    CGFloat avatarOffset = 0.0f;
    if (_hasAvatar)
        avatarOffset = 38.0f;
    
    CGFloat unsentOffset = 0.0f;
    if (!_incoming && _deliveryState == TGMessageDeliveryStateFailed)
        unsentOffset = 29.0f;
    
    CGFloat backgroundWidth = MAX(60.0f, MAX(headerSize.width, contentSize.width) + 25.0f);
    CGRect backgroundFrame = CGRectMake(_incoming ? (avatarOffset + layoutConstants->leftInset) : (containerSize.width - backgroundWidth - layoutConstants->rightInset - unsentOffset), topSpacing, backgroundWidth, MAX((_hasAvatar ? 44.0f : 30.0f), headerSize.height + contentSize.height + layoutConstants->textBubblePaddingTop + layoutConstants->textBubblePaddingBottom));
    if (_incoming && _editing)
        backgroundFrame.origin.x += 42.0f;
    _backgroundModel.frame = backgroundFrame;
    
    _contentModel.frame = CGRectMake(backgroundFrame.origin.x + (_incoming ? 14 : 8), topSpacing + 2.0f, MAX(32.0f, MAX(headerSize.width, contentSize.width) + 2 + (_incoming ? 0.0f : 5.0f)), MAX(headerSize.height + contentSize.height + 5, _hasAvatar ? 30.0f : 14.0f));
    
    if (_authorNameModel != nil)
    {
        CGRect authorModelFrame = _authorNameModel.frame;
        authorModelFrame.origin.x = isRTL ? (_contentModel.frame.size.width - authorModelFrame.size.width - 1.0f) : 1.0f;
        _authorNameModel.frame = authorModelFrame;
    }
    
    if (_forwardedHeaderModel != nil)
    {
        CGRect forwardedHeaderFrame = _forwardedHeaderModel.frame;
        forwardedHeaderFrame.origin.x = isRTL ? (_contentModel.frame.size.width - forwardedHeaderFrame.size.width - 1.0f) : 1.0f;
        _forwardedHeaderModel.frame = forwardedHeaderFrame;
    }
    
    [self layoutContentForHeaderHeight:headerSize.height];
    
    _dateModel.frame = CGRectMake(_contentModel.frame.size.width - (_incoming ? (3 + TGRetinaPixel) : 20.0f) - _dateModel.frame.size.width, _contentModel.frame.size.height - 18.0f - (TGIsLocaleArabic() ? 1.0f : 0.0f), _dateModel.frame.size.width, _dateModel.frame.size.height);
    
    if (_broadcastIconModel != nil)
    {
        _broadcastIconModel.frame = (CGRect){{_dateModel.frame.origin.x - 5.0f - _broadcastIconModel.frame.size.width, _dateModel.frame.origin.y + 3.0f + TGRetinaPixel}, _broadcastIconModel.frame.size};
    }
    
    if (_progressModel != nil)
        _progressModel.frame = CGRectMake(containerSize.width - 28 - layoutConstants->rightInset - unsentOffset, _contentModel.frame.origin.y + _contentModel.frame.size.height - 17 + 1.0f, 15, 15);
    
    CGPoint stateOffset = _contentModel.frame.origin;
    if (_checkFirstModel != nil)
        _checkFirstModel.frame = CGRectMake((_checkFirstEmbeddedInContent ? 0.0f : stateOffset.x) + _contentModel.frame.size.width - 17, (_checkFirstEmbeddedInContent ? 0.0f : stateOffset.y) + _contentModel.frame.size.height - 14 + TGRetinaPixel, 12, 11);
    
    if (_checkSecondModel != nil)
        _checkSecondModel.frame = CGRectMake((_checkSecondEmbeddedInContent ? 0.0f : stateOffset.x) + _contentModel.frame.size.width - 13, (_checkSecondEmbeddedInContent ? 0.0f : stateOffset.y) + _contentModel.frame.size.height - 14 + TGRetinaPixel, 12, 11);
    
    if (_unsentButtonModel != nil)
    {
        _unsentButtonModel.frame = CGRectMake(containerSize.width - _unsentButtonModel.frame.size.width - 9, backgroundFrame.size.height + topSpacing + bottomSpacing - _unsentButtonModel.frame.size.height - ((_collapseFlags & TGModernConversationItemCollapseBottom) ? 5 : 6), _unsentButtonModel.frame.size.width, _unsentButtonModel.frame.size.height);
    }
    
    self.frame = CGRectMake(0, 0, containerSize.width, backgroundFrame.size.height + topSpacing + bottomSpacing);
    
    bool tiledMode = _contentModel.frame.size.height > TGModernFlatteningViewModelTilingLimit;
    [_contentModel setTiledMode:tiledMode];
    self.needsRelativeBoundsUpdates = tiledMode;
    
    if (updateContents)
    {
        [_contentModel setNeedsSubmodelContentsUpdate];
        [_contentModel updateSubmodelContentsIfNeeded];
    }
    
    [super layoutForContainerSize:containerSize];
}

@end
