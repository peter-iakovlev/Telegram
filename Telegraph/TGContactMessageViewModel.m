#import "TGContactMessageViewModel.h"

#import "TGMessage.h"
#import "TGUser.h"

#import "TGDateUtils.h"
#import "TGImageUtils.h"
#import "TGPhoneUtils.h"
#import "TGStringUtils.h"

#import "TGModernConversationItem.h"
#import "TGModernView.h"

#import "TGTextMessageBackgroundViewModel.h"
#import "TGModernFlatteningViewModel.h"
#import "TGModernTextViewModel.h"
#import "TGReusableLabel.h"
#import "TGModernLabelViewModel.h"
#import "TGModernDateViewModel.h"
#import "TGModernClockProgressViewModel.h"
#import "TGModernRemoteImageViewModel.h"
#import "TGModernButtonViewModel.h"
#import "TGModernColorViewModel.h"

#import "TGModernLetteredAvatarViewModel.h"

#import "TGDoubleTapGestureRecognizer.h"

#import "TGTelegraphConversationMessageAssetsSource.h"

@interface TGContactMessageViewModel () <UIGestureRecognizerDelegate, TGDoubleTapGestureRecognizerDelegate>
{
    TGTextMessageBackgroundViewModel *_backgroundModel;
    TGModernFlatteningViewModel *_contentModel;
    
    TGModernTextViewModel *_authorNameModel;
    TGModernTextViewModel *_forwardedHeaderModel;
    
    TGModernLabelViewModel *_contactNameModel;
    TGModernLabelViewModel *_contactPhoneModel;
    TGModernLetteredAvatarViewModel *_contactAvatarModel;
    TGModernColorViewModel *_separatorModel;
    TGModernButtonViewModel *_actionButtonModel;
    
    TGModernDateViewModel *_dateModel;
    TGModernClockProgressViewModel *_progressModel;
    TGModernImageViewModel *_checkFirstModel;
    TGModernImageViewModel *_checkSecondModel;
    bool _checkFirstEmbeddedInContent;
    bool _checkSecondEmbeddedInContent;
    TGModernImageViewModel *_unsentButtonModel;
    
    bool _incoming;
    TGMessageDeliveryState _deliveryState;
    bool _read;
    int32_t _date;
    TGUser *_contact;
    
    bool _hasAvatar;
    
    int _forwardedUid;
    
    TGDoubleTapGestureRecognizer *_boundDoubleTapRecognizer;
    UITapGestureRecognizer *_unsentButtonTapRecognizer;
    
    bool _contactAdded;
    
    CGSize _boundOffset;
}

@end

@implementation TGContactMessageViewModel

- (instancetype)initWithMessage:(TGMessage *)message contact:(TGUser *)contact author:(TGUser *)author context:(TGModernViewContext *)context
{
    self = [super initWithAuthor:author context:context];
    if (self != nil)
    {
        static TGTelegraphConversationMessageAssetsSource *assetsSource = nil;
        
        static UIColor *incomingDateColor = nil;
        static UIColor *outgoingDateColor = nil;
        static UIColor *incomingForwardColor = nil;
        static UIColor *outgoingForwardColor = nil;
        static UIColor *incomingSeparatorColor = nil;
        static UIColor *outgoingSeparatorColor = nil;
        static UIImage *actionImageIncoming = nil;
        static UIImage *actionImageOutgoing = nil;
        
        static dispatch_once_t onceToken1;
        dispatch_once(&onceToken1, ^
        {
            assetsSource = [TGTelegraphConversationMessageAssetsSource instance];
            
            incomingDateColor = UIColorRGBA(0x525252, 0.6f);
            outgoingDateColor = UIColorRGBA(0x008c09, 0.8f);
            incomingSeparatorColor = UIColorRGBA(0x000000, 0.1f);
            outgoingSeparatorColor = UIColorRGBA(0x008c09, 0.3f);
            incomingForwardColor = UIColorRGBA(0x007bff, 1.0f);
            outgoingForwardColor = UIColorRGBA(0x00a516, 1.0f);
            actionImageIncoming = [UIImage imageNamed:@"ModernMessageContactAdd_Incoming.png"];
            actionImageOutgoing = [UIImage imageNamed:@"ModernMessageContactAdd_Outgoing.png"];
        });
        
        _needsEditingCheckButton = true;
        
        _mid = message.mid;
        _incoming = !message.outgoing;
        _deliveryState = message.deliveryState;
        _read = !message.unread;
        _date = (int32_t)message.date;
        _contact = contact;
        
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
        
        static UIImage *placeholder = nil;
        static dispatch_once_t onceToken2;
        dispatch_once(&onceToken2, ^
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
        
        _contactAvatarModel = [[TGModernLetteredAvatarViewModel alloc] initWithSize:CGSizeMake(40, 40) placeholder:placeholder];
        if (contact.photoUrlSmall.length != 0)
            [_contactAvatarModel setAvatarUri:contact.photoUrlSmall];
        else
            [_contactAvatarModel setAvatarFirstName:contact.firstName lastName:contact.lastName uid:contact.uid];
        
        _contactAvatarModel.skipDrawInContext = true;
        _contactAvatarModel.viewUserInteractionDisabled = true;
        [self addSubmodel:_contactAvatarModel];
        
        _contactNameModel = [[TGModernLabelViewModel alloc] initWithText:contact.displayName textColor:_incoming ? incomingForwardColor : outgoingForwardColor font:[assetsSource messageForwardPhoneNameFont] maxWidth:155.0f];
        [_contentModel addSubmodel:_contactNameModel];

        _contactPhoneModel = [[TGModernLabelViewModel alloc] initWithText:[TGPhoneUtils formatPhone:contact.phoneNumber forceInternational:contact.uid != 0] textColor:[assetsSource messageTextColor] font:[assetsSource messageForwardPhoneFont] maxWidth:155.0f];
        [_contentModel addSubmodel:_contactPhoneModel];
        
        _separatorModel = [[TGModernColorViewModel alloc] initWithColor:_incoming ? incomingSeparatorColor : outgoingSeparatorColor];
        [self addSubmodel:_separatorModel];
        
        _actionButtonModel = [[TGModernButtonViewModel alloc] init];
        _actionButtonModel.image = _incoming ? actionImageIncoming : actionImageOutgoing;
        _actionButtonModel.modernHighlight = true;
        [self addSubmodel:_actionButtonModel];
        
        int daytimeVariant = 0;
        NSString *dateText = [TGDateUtils stringForShortTime:(int)message.date daytimeVariant:&daytimeVariant];
        _dateModel = [[TGModernDateViewModel alloc] initWithText:dateText textColor:_incoming ? incomingDateColor : outgoingDateColor daytimeVariant:daytimeVariant];
        [_contentModel addSubmodel:_dateModel];
        
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
        static NSRange formatNameRange;
        
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^
        {
            incomingForwardColor = UIColorRGBA(0x007bff, 1.0f);
            outgoingForwardColor = UIColorRGBA(0x00a516, 1.0f);
            
            formatNameRange = [TGLocalizedStatic(@"Message.ForwardedMessage") rangeOfString:@"%@"];
        });
        
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

- (void)setTemporaryHighlighted:(bool)temporaryHighlighted viewStorage:(TGModernViewStorage *)__unused viewStorage
{
    if (temporaryHighlighted)
        [_backgroundModel setHighlightedIfBound];
    else
        [_backgroundModel clearHighlight];
}

- (void)updateMessage:(TGMessage *)message viewStorage:(TGModernViewStorage *)viewStorage
{
    [super updateMessage:message viewStorage:viewStorage];
    
    _mid = message.mid;
    
    if (_deliveryState != message.deliveryState || (!_incoming && _read != !message.unread))
    {
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
                _progressModel.frame = CGRectMake(self.frame.size.width - 32 - unsentOffset - (_contactAdded ? 0 : 44), _contentModel.frame.origin.y + _contentModel.frame.size.height - 17 + TGRetinaPixel, 15, 15);
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

- (void)updateMediaAvailability:(bool)mediaIsAvailable viewStorage:(TGModernViewStorage *)viewStorage
{
    [super updateMediaAvailability:mediaIsAvailable viewStorage:viewStorage];
    
    if (mediaIsAvailable != _contactAdded)
    {
        _contactAdded = mediaIsAvailable;
        
        if (!mediaIsAvailable)
        {
            _actionButtonModel.alpha = 1.0f;
            _separatorModel.alpha = 1.0f;
        }
        else
        {
            _actionButtonModel.alpha = 0.0f;
            _separatorModel.alpha = 0.0f;
        }
        
        if (self.frame.size.width > FLT_EPSILON)
        {
            [self layoutForContainerSize:self.frame.size];
            
            for (TGModernViewModel *model in self.submodels)
                [model _offsetBoundViews:_boundOffset];
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
    
    _boundOffset = CGSizeMake(itemPosition.x, itemPosition.y);
    
    [_backgroundModel bindViewToContainer:container viewStorage:viewStorage];
    [_backgroundModel boundView].frame = CGRectOffset([_backgroundModel boundView].frame, itemPosition.x, itemPosition.y);
    
    [_contactAvatarModel bindViewToContainer:container viewStorage:viewStorage];
    [_contactAvatarModel boundView].frame = CGRectOffset([_contactAvatarModel boundView].frame, itemPosition.x, itemPosition.y);
}

- (void)bindViewToContainer:(UIView *)container viewStorage:(TGModernViewStorage *)viewStorage
{
    _boundOffset = CGSizeZero;
    
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
    
    [(UIButton *)[_actionButtonModel boundView] addTarget:self action:@selector(actionButtonPressed) forControlEvents:UIControlEventTouchUpInside];
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
    
    [(UIButton *)[_actionButtonModel boundView] removeTarget:self action:@selector(actionButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
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
            else if (CGRectContainsPoint(CGRectOffset(CGRectUnion(_contactAvatarModel.frame, CGRectOffset(CGRectUnion(_contactNameModel.frame, _contactPhoneModel.frame), _contentModel.frame.origin.x, _contentModel.frame.origin.y)), -_backgroundModel.frame.origin.x, -_backgroundModel.frame.origin.y), point))
                [_context.companionHandle requestAction:@"showContactMessageMenu" options:@{@"contact": _contact}];
        }
    }
}

- (void)unsentButtonTapGesture:(UITapGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateRecognized)
    {
        [_context.companionHandle requestAction:@"showUnsentMessageMenu" options:@{@"mid": @(_mid)}];
    }
}

- (void)gestureRecognizer:(TGDoubleTapGestureRecognizer *)__unused recognizer didBeginAtPoint:(CGPoint)__unused point
{
}

- (void)gestureRecognizerDidFail:(TGDoubleTapGestureRecognizer *)__unused recognizer
{
}

- (bool)gestureRecognizerShouldHandleLongTap:(TGDoubleTapGestureRecognizer *)__unused recognizer
{
    return true;
}

- (int)gestureRecognizer:(TGDoubleTapGestureRecognizer *)__unused recognizer shouldFailTap:(CGPoint)point
{
    if ((_forwardedHeaderModel && CGRectContainsPoint(_forwardedHeaderModel.frame, point)) || CGRectContainsPoint(CGRectOffset(CGRectUnion(_contactAvatarModel.frame, CGRectOffset(CGRectUnion(_contactNameModel.frame, _contactPhoneModel.frame), _contentModel.frame.origin.x, _contentModel.frame.origin.y)), -_backgroundModel.frame.origin.x, -_backgroundModel.frame.origin.y), point))
        return 3;
    return false;
}

- (void)doubleTapGestureRecognizerSingleTapped:(TGDoubleTapGestureRecognizer *)__unused recognizer
{
}

- (void)actionButtonPressed
{
    [_context.companionHandle requestAction:@"showContactMessageMenu" options:@{@"contact": _contact, @"addMode": @(true)}];
}

- (void)layoutForContainerSize:(CGSize)containerSize
{
    TGMessageViewModelLayoutConstants const *layoutConstants = TGGetMessageViewModelLayoutConstants();
    
    bool isRTL = TGIsRTL();
    
    CGFloat topSpacing = (_collapseFlags & TGModernConversationItemCollapseTop) ? layoutConstants->topInsetCollapsed : layoutConstants->topInset;
    CGFloat bottomSpacing = (_collapseFlags & TGModernConversationItemCollapseBottom) ? layoutConstants->bottomInsetCollapsed : layoutConstants->bottomInset;
    
    CGSize headerSize = CGSizeZero;
    if (_authorNameModel != nil)
    {
        if (_authorNameModel.frame.size.width < FLT_EPSILON)
            [_authorNameModel layoutForContainerSize:CGSizeMake(320.0f - 80.0f, 0.0f)];
        
        CGRect authorModelFrame = _authorNameModel.frame;
        authorModelFrame.origin = CGPointMake(1.0f, 1.0f);
        _authorNameModel.frame = authorModelFrame;
        
        headerSize = CGSizeMake(_authorNameModel.frame.size.width, _authorNameModel.frame.size.height);
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
    
    CGRect contactNameFrame = _contactNameModel.frame;
    contactNameFrame.origin = CGPointMake(44.0f, headerSize.height + 4.0f);
    _contactNameModel.frame = contactNameFrame;
    
    CGRect contactPhoneFrame = _contactPhoneModel.frame;
    contactPhoneFrame.origin = CGPointMake(contactNameFrame.origin.x, CGRectGetMaxY(contactNameFrame) + 1.0f);
    _contactPhoneModel.frame = contactPhoneFrame;
    
    CGSize textSize = CGSizeMake(_contactNameModel.frame.origin.x + MAX(_contactNameModel.frame.size.width, _contactPhoneModel.frame.size.width), contactPhoneFrame.origin.y + contactPhoneFrame.size.height - contactNameFrame.origin.y);
    
    CGFloat backgroundWidth = MAX(60.0f, MAX(headerSize.width, textSize.width) + 25.0f);
    if (!_contactAdded)
        backgroundWidth += 44;
    
    CGRect backgroundFrame = CGRectMake(_incoming ? (avatarOffset + layoutConstants->leftInset) : (containerSize.width - backgroundWidth - layoutConstants->rightInset - unsentOffset), topSpacing, backgroundWidth, MAX((_hasAvatar ? 44.0f : 30.0f), headerSize.height + textSize.height + 30.0f));
    if (_incoming && _editing)
        backgroundFrame.origin.x += 42.0f;
    _backgroundModel.frame = backgroundFrame;
    
    _contentModel.frame = CGRectMake(backgroundFrame.origin.x + (_incoming ? 14 : 8), topSpacing + 2.0f, MAX(32.0f, MAX(headerSize.width, textSize.width) + 2 + (_incoming ? 0.0f : 5.0f)), MAX(headerSize.height + textSize.height + 25.0f, _hasAvatar ? 30.0f : 14.0f));
    
    if (_authorNameModel != nil)
    {
        CGRect authorModelFrame = _authorNameModel.frame;
        authorModelFrame.origin.x = isRTL ? (_contentModel.frame.size.width - authorModelFrame.size.width - 1.0f - (_incoming ? 0.0f : 4.0f)) : 1.0f;
        _authorNameModel.frame = authorModelFrame;
    }
    
    if (_forwardedHeaderModel != nil)
    {
        CGRect forwardedHeaderFrame = _forwardedHeaderModel.frame;
        forwardedHeaderFrame.origin.x = isRTL ? (_contentModel.frame.size.width - forwardedHeaderFrame.size.width - 1.0f - (_incoming ? 0.0f : 4.0f)) : 1.0f;
        _forwardedHeaderModel.frame = forwardedHeaderFrame;
    }
    
    if (isRTL)
    {
        CGRect contactNameFrame = _contactNameModel.frame;
        contactNameFrame.origin.x = _contentModel.frame.size.width - 1.0f - contactNameFrame.size.width - (_incoming ? 0.0f : 4.0f);
        _contactNameModel.frame = contactNameFrame;
        
        CGRect contactPhoneFrame = _contactPhoneModel.frame;
        contactPhoneFrame.origin.x = _contentModel.frame.size.width - 1.0f - contactPhoneFrame.size.width - (_incoming ? 0.0f : 4.0f);
        _contactPhoneModel.frame = contactPhoneFrame;
    }
    
    _contactAvatarModel.frame = CGRectMake(_contentModel.frame.origin.x - 1.0f, headerSize.height + 9.0f, 40.0f, 40.0f);
    
    if (!_contactAdded)
    {
        _separatorModel.frame = CGRectMake(CGRectGetMaxX(_contentModel.frame) + 1.0f + (_incoming ? 5.0f : 0.0f), backgroundFrame.origin.y + backgroundFrame.size.height - 53.0f - 5.0f, TGRetinaPixel, 53.0f);
        _actionButtonModel.frame = CGRectMake(CGRectGetMaxX(_contentModel.frame) + 1.0f + (_incoming ? 5.0f : 0.0f), backgroundFrame.origin.y + backgroundFrame.size.height - 53.0f - 5.0f, 46.0f, 54.0f);
    }
    
    _dateModel.frame = CGRectMake(_contentModel.frame.size.width - (_incoming ? 3 : 20.0f) - _dateModel.frame.size.width, _contentModel.frame.size.height - 18.0f + TGRetinaPixel - (TGIsLocaleArabic() ? 1.0f : 0.0f), _dateModel.frame.size.width, _dateModel.frame.size.height);
    
    if (_progressModel != nil)
        _progressModel.frame = CGRectMake(containerSize.width - 32 - unsentOffset - (_contactAdded ? 0 : 44), _contentModel.frame.origin.y + _contentModel.frame.size.height - 17 + TGRetinaPixel, 15, 15);
    
    CGPoint stateOffset = _contentModel.frame.origin;
    if (_checkFirstModel != nil)
        _checkFirstModel.frame = CGRectMake((_checkFirstEmbeddedInContent ? 0.0f : stateOffset.x) + _contentModel.frame.size.width - 17, (_checkFirstEmbeddedInContent ? 0.0f : stateOffset.y) + _contentModel.frame.size.height - 13, 12, 11);
    
    if (_checkSecondModel != nil)
        _checkSecondModel.frame = CGRectMake((_checkSecondEmbeddedInContent ? 0.0f : stateOffset.x) + _contentModel.frame.size.width - 13, (_checkSecondEmbeddedInContent ? 0.0f : stateOffset.y) + _contentModel.frame.size.height - 13, 12, 11);
    
    if (_unsentButtonModel != nil)
    {
        _unsentButtonModel.frame = CGRectMake(containerSize.width - _unsentButtonModel.frame.size.width - 9, backgroundFrame.size.height + topSpacing + bottomSpacing - _unsentButtonModel.frame.size.height - ((_collapseFlags & TGModernConversationItemCollapseBottom) ? 5 : 6), _unsentButtonModel.frame.size.width, _unsentButtonModel.frame.size.height);
    }
    
    self.frame = CGRectMake(0, 0, containerSize.width, backgroundFrame.size.height + topSpacing + bottomSpacing);
    
    [super layoutForContainerSize:containerSize];
}

- (void)setCollapseFlags:(int)collapseFlags
{
    if (_collapseFlags != collapseFlags)
    {
        _collapseFlags = collapseFlags;
        [_backgroundModel setPartialMode:collapseFlags & TGModernConversationItemCollapseBottom];
    }
}

@end
