#import "TGMessageViewModel.h"

#import "TGAppDelegate.h"
#import "TGImageUtils.h"

#import "TGUser.h"
#import "TGConversation.h"
#import "TGMessage.h"

#import "TGModernViewContext.h"

#import "TGModernRemoteImageViewModel.h"
#import "TGModernButtonViewModel.h"
#import "TGModernCheckButtonViewModel.h"

#import "TGMessageModernConversationItem.h"

#import "TGModernLetteredAvatarViewModel.h"

#import "TGModernImageViewModel.h"

#import "TGTelegraphConversationMessageAssetsSource.h"

static CGFloat preferredTextFontSize;

void TGMessageViewModelLayoutSetPreferredTextFontSize(CGFloat fontSize)
{
    preferredTextFontSize = fontSize;
}

static TGMessageViewModelLayoutConstants currentMessageViewModelLayoutConstants;

const TGMessageViewModelLayoutConstants *TGGetMessageViewModelLayoutConstants()
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        TGMessageViewModelLayoutConstants constants;
        
        CGFloat minTextFontSize = 0.0f;
        CGFloat maxTextFontSize = 0.0f;
        CGFloat defaultTextFontSize = 0.0f;
        
        CGSize screenSize = TGScreenSize();
        CGFloat screenSide = MAX(screenSize.width, screenSize.height);
        bool isLargeScreen = screenSide >= 667.0f - FLT_EPSILON;
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        {
            constants.topInset = 2.0f;
            constants.bottomInset = 2.0f;
            constants.topInsetCollapsed = 1.0f;
            constants.bottomInsetCollapsed = 0.0f;
            
            constants.leftInset = 4.0f;
            constants.rightInset = 4.0f;
            
            constants.leftImageInset = 9.0f;
            constants.rightImageInset = 9.0f;
            
            constants.avatarInset = 3.0f;
            
            constants.textBubblePaddingTop = 5.0f;
            constants.textBubblePaddingBottom = 5.0f;
            constants.textBubbleTextOffsetTop = 1.0f;
            
            constants.topPostInset = 2.0f;
            constants.bottomPostInset = 2.0f;
            
            minTextFontSize = 12.0f;
            maxTextFontSize = 24.0f;
            
            if (isLargeScreen)
                defaultTextFontSize = 17.0f;
            else
                defaultTextFontSize = 16.0f;
        }
        else
        {
            constants.topInset = 3.0f;
            constants.bottomInset = 3.0f;
            constants.topInsetCollapsed = 1.0f;
            constants.bottomInsetCollapsed = 1.0f;
            
            constants.leftInset = 17.0f;
            constants.rightInset = 17.0f;
            
            constants.leftImageInset = 23.0f;
            constants.rightImageInset = 23.0f;
            
            constants.avatarInset = 11.0f;
            
            constants.topPostInset = 3.0f;
            constants.bottomPostInset = 3.0f;
            
            constants.textBubblePaddingTop = 5.0f;
            constants.textBubblePaddingBottom = 6.0f;
            constants.textBubbleTextOffsetTop = 1.0f + TGRetinaPixel;
            
            minTextFontSize = 13.0f;
            maxTextFontSize = 25.0f;
            defaultTextFontSize = 17.0f;
        }
        
        if (iosMajorVersion() >= 7 && [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        {
            CGFloat fontSize = [UIFont preferredFontForTextStyle:UIFontTextStyleBody].pointSize - (isLargeScreen ? 0 : 1.0f);
            constants.textFontSize = MAX(minTextFontSize, MIN(maxTextFontSize, fontSize));
        }
        else
        {
            if (preferredTextFontSize == 0)
                constants.textFontSize = defaultTextFontSize;
            else
                constants.textFontSize = MAX(minTextFontSize, MIN(maxTextFontSize, preferredTextFontSize));
        }
        
        currentMessageViewModelLayoutConstants = constants;
    });
    
    return &currentMessageViewModelLayoutConstants;
}

void TGUpdateMessageViewModelLayoutConstants(CGFloat baseFontPointSize)
{
    CGFloat minTextFontSize = 0.0f;
    CGFloat maxTextFontSize = 0.0f;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        minTextFontSize = 12.0f;
        maxTextFontSize = 24.0f;
    }
    else
    {
        minTextFontSize = 13.0f;
        maxTextFontSize = 25.0f;
    }
    
    CGSize screenSize = TGScreenSize();
    CGFloat screenSide = MAX(screenSize.width, screenSize.height);
    bool isLargeScreen = screenSide >= 667.0f - FLT_EPSILON;
    
    CGFloat fontSize = baseFontPointSize - (isLargeScreen ? 0 : 1.0f);
    currentMessageViewModelLayoutConstants.textFontSize = MAX(minTextFontSize, MIN(maxTextFontSize, fontSize));
}

@interface TGMessageViewModel ()
{
    int _uid;
    NSString *_firstName;
    NSString *_lastName;
    
    TGModernLetteredAvatarViewModel *_avatarModel;
    UITapGestureRecognizer *_boundAvatarTapRecognizer;
    
    TGModernButtonViewModel *_checkAreaModel;
    TGModernCheckButtonViewModel *_checkButtonModel;
    
    TGModernImageViewModel *_replyIconModel;
    
    UIImpactFeedbackGenerator *_feedbackGenerator;
}

@end

@implementation TGMessageViewModel

- (instancetype)initWithAuthorPeer:(id)authorPeer context:(TGModernViewContext *)context
{
    self = [super init];
    if (self != nil)
    {
        self.hasNoView = true;
        _context = context;
        _authorPeer = authorPeer;
        
        if (authorPeer != nil && [authorPeer isKindOfClass:[TGUser class]])
        {
            TGUser *author = authorPeer;
            _uid = author.uid;
            _firstName = author.firstName;
            _lastName = author.lastName;
            
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
            
            _avatarModel = [[TGModernLetteredAvatarViewModel alloc] initWithSize:CGSizeMake(38.0f, 38.0f) placeholder:placeholder];
            _avatarModel.skipDrawInContext = true;
            [self addSubmodel:_avatarModel];
        } else if ([authorPeer isKindOfClass:[TGConversation class]] && context != nil && [context isAdminLog]) {
            TGConversation *author = authorPeer;
            _firstName = author.chatTitle;
            
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
            
            _avatarModel = [[TGModernLetteredAvatarViewModel alloc] initWithSize:CGSizeMake(38.0f, 38.0f) placeholder:placeholder];
            _avatarModel.skipDrawInContext = true;
            [self addSubmodel:_avatarModel];
        }
        
        if (iosMajorVersion() >= 10)
            _feedbackGenerator = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleMedium];
    }
    return self;
}

- (void)setAuthorAvatarUrl:(NSString *)authorAvatarUrl groupId:(int64_t)groupId
{
    if (authorAvatarUrl.length == 0)
        [_avatarModel setAvatarTitle:_firstName groupId:groupId];
    else
        [_avatarModel setAvatarUri:authorAvatarUrl];
}

- (void)setAuthorAvatarUrl:(NSString *)authorAvatarUrl
{
    if (authorAvatarUrl.length == 0)
        [_avatarModel setAvatarFirstName:_firstName lastName:_lastName uid:_uid];
    else
        [_avatarModel setAvatarUri:authorAvatarUrl];
}

- (void)setAuthorNameColor:(UIColor *)__unused authorNameColor
{
}

- (void)setAuthorSignature:(NSString *)__unused authorSignature {
}

- (void)updateAssets
{
}

- (void)refreshMetrics
{
}

- (void)updateSearchText:(bool)__unused animated
{
}

- (void)updateMessage:(TGMessage *)__unused message viewStorage:(TGModernViewStorage *)__unused viewStorage sizeUpdated:(bool *)__unused sizeUpdated
{
}

- (void)relativeBoundsUpdated:(CGRect)__unused bounds
{
}

- (void)imageDataInvalidated:(NSString *)__unused imageUrl
{
}

- (CGRect)effectiveContentFrame
{
    return CGRectZero;
}

- (UIView *)referenceViewForImageTransition
{
    return nil;
}

- (void)setTemporaryHighlighted:(bool)__unused temporaryHighlighted viewStorage:(TGModernViewStorage *)__unused viewStorage
{
}

- (void)clearHighlights
{
}

- (void)updateProgress:(bool)__unused progressVisible progress:(float)__unused progress viewStorage:(TGModernViewStorage *)__unused viewStorage animated:(bool)__unused animated
{
}

- (void)updateMediaAvailability:(bool)__unused mediaIsAvailable viewStorage:(TGModernViewStorage *)__unused viewStorage delayDisplay:(bool)__unused delayDisplay
{
}

- (void)updateMediaVisibility
{
}

- (void)updateMessageAttributes
{
}

- (void)updateMessageVisibility
{
}

- (void)updateInlineMediaContext
{
}

- (void)updateAnimationsEnabled
{
}

- (void)stopInlineMedia:(int32_t)__unused excludeMid
{
}

- (void)resumeInlineMedia
{
}

- (NSString *)linkAtPoint:(CGPoint)__unused point {
    return nil;
}

- (bool)isPreviewableAtPoint:(CGPoint)__unused point {
    return false;
}

- (void)updateEditingState:(UIView *)container viewStorage:(TGModernViewStorage *)viewStorage animationDelay:(NSTimeInterval)animationDelay
{
    if (!_needsEditingCheckButton)
        return;
    
    bool editing = _context.editing;
    
    if (editing != _editing)
    {
        _editing = editing;
        
        if (_editing)
        {
            if (_checkAreaModel == nil)
            {
                _checkAreaModel = [[TGModernButtonViewModel alloc] init];
                _checkAreaModel.skipDrawInContext = true;
                _checkAreaModel.frame = self.bounds;
                [self addSubmodel:_checkAreaModel];
                
                if (container != nil)
                {
                    [_checkAreaModel bindViewToContainer:container viewStorage:viewStorage];
                    
                    [(UIButton *)[_checkAreaModel boundView] addTarget:self action:@selector(checkButtonPressed) forControlEvents:UIControlEventTouchUpInside];
                }
            }
        }
        else if (_checkAreaModel != nil)
        {
            if ([_checkAreaModel boundView] != nil)
            {
                [(UIButton *)[_checkAreaModel boundView] removeTarget:self action:@selector(checkButtonPressed) forControlEvents:UIControlEventTouchUpInside];
            }
            
            [self removeSubmodel:_checkAreaModel viewStorage:viewStorage];
            _checkAreaModel = nil;
        }
        
        if (animationDelay > -FLT_EPSILON && container != nil)
        {
            UIView<TGModernView> *checkView = nil;
            
            if (_editing)
            {
                if (_checkButtonModel == nil)
                {
                    _checkButtonModel = [[TGModernCheckButtonViewModel alloc] initWithFrame:CGRectMake(11.0f, CGFloor((self.frame.size.height - 30.0f) / 2.0f), 30.0f, 30.0f)];
                    _checkButtonModel.isChecked = [_context isMessageChecked:_mid];
                    [self addSubmodel:_checkButtonModel];
                    
                    if (container != nil)
                    {
                        [_checkButtonModel bindViewToContainer:container viewStorage:viewStorage];
                        
                        [(UIButton *)[_checkButtonModel boundView] addTarget:self action:@selector(checkButtonPressed) forControlEvents:UIControlEventTouchUpInside];
                    }
                }
                
                [_checkButtonModel boundView].frame = CGRectOffset(_checkButtonModel.frame, -49.0f, 0.0f);
            }
            else if (_checkButtonModel != nil)
            {
                if ([_checkButtonModel boundView] != nil)
                {
                    [(UIButton *)[_checkButtonModel boundView] removeTarget:self action:@selector(checkButtonPressed) forControlEvents:UIControlEventTouchUpInside];
                }
                
                [self removeSubmodel:_checkButtonModel viewStorage:viewStorage];
                checkView = [_checkButtonModel _dequeueView:viewStorage];
                checkView.frame = _checkButtonModel.frame;
                [container addSubview:checkView];
                _checkButtonModel = nil;
            }
            
            [UIView animateWithDuration:MAX(0.025, 0.18 - animationDelay) delay:animationDelay options:iosMajorVersion() >= 7 ? (7 << 16) : 0 animations:^
            {
                if (self.frame.size.width > FLT_EPSILON)
                    [self layoutForContainerSize:CGSizeMake(self.frame.size.width, 0.0f)];
                
                if (_editing)
                    [_checkButtonModel boundView].frame = _checkButtonModel.frame;
                else
                    checkView.frame = CGRectOffset(checkView.frame, -49.0f, 0.0f);
            } completion:^(__unused BOOL finished)
            {
                if (checkView != nil)
                {
                    [checkView removeFromSuperview];
                    [viewStorage enqueueView:checkView];
                }
            }];
        }
        else
        {
            if (self.frame.size.width > FLT_EPSILON)
                [self layoutForContainerSize:CGSizeMake(self.frame.size.width, 0.0f)];
            
            if (_editing)
            {
                if (_checkButtonModel == nil)
                {
                    _checkButtonModel = [[TGModernCheckButtonViewModel alloc] initWithFrame:CGRectMake(11.0f, CGFloor((self.frame.size.height - 30.0f) / 2.0f), 30.0f, 30.0f)];
                    _checkButtonModel.isChecked = [_context isMessageChecked:_mid];
                    [self addSubmodel:_checkButtonModel];
                
                    if (container != nil)
                    {
                        [_checkButtonModel bindViewToContainer:container viewStorage:viewStorage];
                        
                        [(UIButton *)[_checkButtonModel boundView] addTarget:self action:@selector(checkButtonPressed) forControlEvents:UIControlEventTouchUpInside];
                    }
                }
            }
            else if (_checkButtonModel != nil)
            {
                if ([_checkButtonModel boundView] != nil)
                {
                    [(UIButton *)[_checkButtonModel boundView] removeTarget:self action:@selector(checkButtonPressed) forControlEvents:UIControlEventTouchUpInside];
                }
                
                [self removeSubmodel:_checkButtonModel viewStorage:viewStorage];
                _checkButtonModel = nil;
            }
        }
    }
    else if (editing)
        _checkButtonModel.isChecked = [_context isMessageChecked:_mid];
}

- (void)bindSpecialViewsToContainer:(UIView *)container viewStorage:(TGModernViewStorage *)viewStorage atItemPosition:(CGPoint)itemPosition
{   
    if (_avatarModel != nil)
    {
        [_avatarModel bindViewToContainer:container viewStorage:viewStorage];
        [_avatarModel boundView].frame = CGRectOffset([_avatarModel boundView].frame, itemPosition.x, itemPosition.y);
    }
}

- (void)bindViewToContainer:(UIView *)container viewStorage:(TGModernViewStorage *)viewStorage
{
    [super bindViewToContainer:container viewStorage:viewStorage];
    
    if (_avatarModel != nil)
    {
        _boundAvatarTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(avatarTapGesture:)];
        [[_avatarModel boundView] addGestureRecognizer:_boundAvatarTapRecognizer];
    }
    
    if (_checkButtonModel != nil)
        [(UIButton *)[_checkButtonModel boundView] addTarget:self action:@selector(checkButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    if (_checkAreaModel != nil)
        [(UIButton *)[_checkAreaModel boundView] addTarget:self action:@selector(checkButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    //_replyPanGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(replyPanGesture:)];
    //_replyPanGestureRecognizer.delegate = self;
    //[container addGestureRecognizer:_replyPanGestureRecognizer];
}

- (void)moveViewToContainer:(UIView *)container
{
    //if (_replyPanGestureRecognizer != nil)
    //    [_replyPanGestureRecognizer.view removeGestureRecognizer:_replyPanGestureRecognizer];
    
    [super moveViewToContainer:container];
    
    //[container addGestureRecognizer:_replyPanGestureRecognizer];
}

- (void)unbindView:(TGModernViewStorage *)viewStorage
{
    if (_avatarModel != nil)
    {
        [[_avatarModel boundView] removeGestureRecognizer:_boundAvatarTapRecognizer];
        _boundAvatarTapRecognizer = nil;
    }
    
    _replyPanOffset = 0.0f;
    //[_replyPanGestureRecognizer.view removeGestureRecognizer:_replyPanGestureRecognizer];
    //_replyPanGestureRecognizer = nil;
    
    if (_checkButtonModel != nil)
        [(UIButton *)[_checkButtonModel boundView] removeTarget:self action:@selector(checkButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    if (_checkAreaModel != nil)
        [(UIButton *)[_checkAreaModel boundView] removeTarget:self action:@selector(checkButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    [super unbindView:viewStorage];
}

- (void)avatarTapGesture:(UITapGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateRecognized)
    {
        [_context.companionHandle requestAction:@"userAvatarTapped" options:@{@"uid": @(_uid), @"mid": @(_mid)}];
    }
}

- (void)updateReplySwipeInteraction:(UIView *)container viewStorage:(TGModernViewStorage *)viewStorage ended:(bool)ended
{
    CGFloat inset = _avatarModel != nil ? 0.0f : 0.0f;
    if (!ended)
    {
        if (_replyIconModel == nil)
        {
            CGFloat x = _replyPanOffset > 0 ? inset : self.frame.size.width;

            _replyIconModel = [[TGModernImageViewModel alloc] initWithImage:[[TGTelegraphConversationMessageAssetsSource instance] systemSwipeReplyIcon]];
            _replyIconModel.frame = CGRectMake(x, CGFloor((self.frame.size.height - 33.0f) / 2.0f), 33.0f, 33.0f);
            _replyIconModel.skipDrawInContext = true;
            [self addSubmodel:_replyIconModel];
            
            if (container != nil)
                [_replyIconModel bindViewToContainer:container viewStorage:viewStorage];
            
            _replyIconModel.alpha = 0.0f;
            [_replyIconModel boundView].transform = CGAffineTransformMakeScale(0.01f, 0.01f);
        }
    }
    else
    {
        UIView<TGModernView> *iconView = nil;
        
        [self removeSubmodel:_replyIconModel viewStorage:viewStorage];
        iconView = [_replyIconModel _dequeueView:viewStorage];
        
        CGFloat x = _replyPanOffset > 0 ? inset + _replyPanOffset / 2.0f : self.frame.size.width + _replyPanOffset / 2.0f;
        iconView.center = CGPointMake(x, self.frame.size.height / 2.0f);
        [container addSubview:iconView];
        _replyIconModel = nil;
        
        [UIView animateWithDuration:0.2 delay:0.0 options:(iosMajorVersion() >= 7 ? (7 << 16) : 0) | UIViewAnimationOptionBeginFromCurrentState animations:^
        {
            CGFloat x = _replyPanOffset > 0 ? inset : self.frame.size.width;
            _replyPanOffset = 0.0f;
            
            if (self.frame.size.width > FLT_EPSILON)
                [self layoutForContainerSize:CGSizeMake(self.frame.size.width, 0.0f)];
            
            iconView.center = CGPointMake(x, self.frame.size.height / 2.0f);
            iconView.transform = CGAffineTransformMakeScale(0.01f, 0.01f);
            iconView.alpha = 0.0f;
        } completion:^(__unused BOOL finished)
        {
            if (iconView != nil)
            {
                [iconView removeFromSuperview];
                iconView.transform = CGAffineTransformIdentity;
                iconView.alpha = 1.0f;
                [viewStorage enqueueView:iconView];
            }
        }];
    }
}

- (void)replyPanGesture:(UIPanGestureRecognizer *)recognizer
{
    CGFloat inset = _avatarModel != nil ? 0.0f : 0.0f;
    if (recognizer.state == UIGestureRecognizerStateChanged)
    {
        CGFloat translation = [recognizer translationInView:recognizer.view.superview].x * -1.0f;
        _replyPanOffset = MAX(-160.0f, MIN(0.0f, _replyPanOffset + translation));
        [recognizer setTranslation:CGPointZero inView:recognizer.view.superview];
        
        if (fabs(_replyPanOffset) >= 85.0f)
        {
            if (_replyIconModel == nil)
                _context.replySwipeInteraction(_mid, false);
            
            if (_replyIconModel.alpha < FLT_EPSILON)
            {
                [_feedbackGenerator impactOccurred];
                
                void (^animationBlock)(void) = ^
                {
                    [_replyIconModel boundView].transform = CGAffineTransformIdentity;
                    _replyIconModel.alpha = 1.0f;
                };
                
                if (iosMajorVersion() >= 7)
                {
                    [UIView animateWithDuration:0.5 delay:0.0 usingSpringWithDamping:0.4 initialSpringVelocity:0.2 options:kNilOptions animations:animationBlock completion:nil];
                }
                else
                {
                    [UIView animateWithDuration:0.2 animations:animationBlock];
                }
            }
        }
        else
        {
            if (_replyIconModel == nil)
                [_feedbackGenerator prepare];
            
            _replyIconModel.alpha = (float)fabs(_replyPanOffset / 85.0f);
        }
        
        CGFloat x = _replyPanOffset > 0 ? inset + _replyPanOffset / 2.0f : self.frame.size.width + _replyPanOffset / 2.0f;
        [_replyIconModel boundView].center = CGPointMake(x, self.frame.size.height / 2.0f);
        
        [self layoutForContainerSize:CGSizeMake(self.frame.size.width, 0.0f)];
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled)
    {
        if (recognizer.state == UIGestureRecognizerStateEnded && fabs(_replyPanOffset) > 85.0f)
            [_context.companionHandle requestAction:@"replyRequested" options:@{@"mid": @(_mid)}];
        
        _context.replySwipeInteraction(_mid, true);
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer == _replyPanGestureRecognizer)
    {
        UIPanGestureRecognizer *panGestureRecognizer = (UIPanGestureRecognizer *)gestureRecognizer;
        CGPoint velocity = [panGestureRecognizer velocityInView:gestureRecognizer.view];
        if (fabs(velocity.y) > fabs(velocity.x))
            return false;
        
        return _context.canReplyToMessageId(_mid);
    }
    return true;
}

- (void)checkButtonPressed
{
    if (_checkButtonModel != nil)
    {
        _checkButtonModel.isChecked = !_checkButtonModel.isChecked;
        [_context.companionHandle requestAction:@"messageSelectionChanged" options:@{@"mid": @(_mid), @"selected": @(_checkButtonModel.isChecked)}];
    }
}

- (void)layoutForContainerSize:(CGSize)__unused containerSize
{
    if (_avatarModel != nil)
    {
        _avatarModel.frame = CGRectMake(TGGetMessageViewModelLayoutConstants()->avatarInset + (_editing ? 42.0f : 0.0f) + _replyPanOffset, self.frame.size.height - 38 - _avatarOffset, 38, 38);
        _avatarModel.alpha = (_collapseFlags & TGModernConversationItemCollapseBottom) ? 0.0f : 1.0f;
    }
    
    if (_checkButtonModel != nil)
        _checkButtonModel.frame = CGRectMake(11.0f, CGFloor((self.frame.size.height - 30.0f) / 2.0f), 30.0f, 30.0f);
    
    if (_checkAreaModel != nil)
        _checkAreaModel.frame = self.bounds;
}

@end
