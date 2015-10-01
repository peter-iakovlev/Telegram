#import "TGMessageViewModel.h"

#import "TGAppDelegate.h"
#import "TGImageUtils.h"

#import "TGUser.h"
#import "TGMessage.h"

#import "TGModernViewContext.h"

#import "TGModernRemoteImageViewModel.h"
#import "TGModernButtonViewModel.h"
#import "TGModernCheckButtonViewModel.h"

#import "TGMessageModernConversationItem.h"

#import "TGModernLetteredAvatarViewModel.h"

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
        }
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

- (void)updateMediaAvailability:(bool)__unused mediaIsAvailable viewStorage:(TGModernViewStorage *)__unused viewStorage
{
}

- (void)updateMediaVisibility
{
}

- (void)updateMessageAttributes
{
}

- (void)updateInlineMediaContext
{
}

- (void)updateAnimationsEnabled
{
}

- (void)stopInlineMedia
{
}

- (NSString *)linkAtPoint:(CGPoint)__unused point {
    return nil;
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
}

- (void)unbindView:(TGModernViewStorage *)viewStorage
{
    if (_avatarModel != nil)
    {
        [[_avatarModel boundView] removeGestureRecognizer:_boundAvatarTapRecognizer];
        _boundAvatarTapRecognizer = nil;
    }
    
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
        [_context.companionHandle requestAction:@"userAvatarTapped" options:@{@"uid": @(_uid)}];
    }
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
        _avatarModel.frame = CGRectMake(TGGetMessageViewModelLayoutConstants()->avatarInset + (_editing ? 42.0f : 0.0f), self.frame.size.height - 38, 38, 38);
        _avatarModel.alpha = (_collapseFlags & TGModernConversationItemCollapseBottom) ? 0.0f : 1.0f;
    }
    
    if (_checkButtonModel != nil)
        _checkButtonModel.frame = CGRectMake(11.0f, CGFloor((self.frame.size.height - 30.0f) / 2.0f), 30.0f, 30.0f);
    
    if (_checkAreaModel != nil)
        _checkAreaModel.frame = self.bounds;
}

@end
