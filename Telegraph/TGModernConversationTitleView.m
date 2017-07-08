#import "TGModernConversationTitleView.h"

#import "TGFont.h"
#import "TGImageUtils.h"
#import "TGStringUtils.h"
#import "TGAnimationBlockDelegate.h"
#import "TGTimerTarget.h"

#import "TGModernConversationTitleIcon.h"
#import "TGModernConversationTitleActivityIndicator.h"

#import "TGViewController.h"
#import "TGAppDelegate.h"

const NSTimeInterval typingIntervalFirst = 0.16;
const NSTimeInterval typingIntervalSecond = 0.14;

@interface TGModernConversationTitleView ()
{
    UILabel *_titleLabel;
    UILabel *_statusLabel;
    
    UILabel *_titleModalProgressLabel;
    UIActivityIndicatorView *_titleModalProgressIndicator;
    NSString *_modalProgressStatus;
    
    bool _animationsAreSuspended;
    
    TGModernConversationTitleActivityIndicator *_activityIndicator;
    
    id _status;
    
    UIInterfaceOrientation _orientation;
    bool _editingMode;
    
    NSArray *_icons;
    NSArray *_iconViews;
    
    UIView *_unreadContainer;
    UIImageView *_unreadBackground;
    UILabel *_unreadLabel;
    int _unreadCount;
    
    NSString *_backButtonTitle;
    
    UIImageView *_toggleIcon;
    UILabel *_toggleLabel;
    
    bool _showUnreadCount;
    bool _disableUnreadCount;
    
    bool _showStatus;
    
    UIImageView *_arrowView;
}

@end

@implementation TGModernConversationTitleView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)]];
        _showUnreadCount = true;
        _showStatus = true;
    }
    return self;
}

- (void)_updateLabelsForCurrentOrientation
{
}

- (UILabel *)titleLabel
{
    if (_titleLabel == nil)
    {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.font = TGMediumSystemFontOfSize(17.0f);
        [self addSubview:_titleLabel];
    }
    
    return _titleLabel;
}

- (UILabel *)statusLabel
{
    if (_statusLabel == nil)
    {
        _statusLabel = [[UILabel alloc] init];
        _statusLabel.backgroundColor = [UIColor clearColor];
        _statusLabel.textColor = UIColorRGB(0x787878);
        _statusLabel.font = TGSystemFontOfSize(13.0f);
        [self addSubview:_statusLabel];
    }
    
    return _statusLabel;
}

- (UILabel *)toggleLabel {
    if (_toggleLabel == nil) {
        _toggleLabel = [[UILabel alloc] init];
        _toggleLabel.backgroundColor = [UIColor clearColor];
        _toggleLabel.textColor = UIColorRGB(0x787878);
        _toggleLabel.font = TGSystemFontOfSize(13.0f);
        [self addSubview:_toggleLabel];
    }
    return _toggleLabel;
}

- (UIImageView *)toggleIcon {
    if (_toggleIcon == nil) {
        _toggleIcon = [[UIImageView alloc] init];
        [self addSubview:_toggleIcon];
    }
    
    return _toggleIcon;
}

- (void)suspendAnimations
{
    _animationsAreSuspended = true;
}

- (void)resumeAnimations
{
    _animationsAreSuspended = false;
}

- (void)setTitle:(NSString *)title
{
    if (!TGStringCompare(title, _title))
    {
        _title = title;
        [self titleLabel].text = title;
        [self setNeedsLayout];
    }
}

- (void)setStatus:(NSString *)status
{
    [self setStatus:status animated:false];
}

- (void)setStatus:(NSString *)status animated:(bool)animated
{
    [self _setStatus:status animated:animated];
}

- (void)setAttributedStatus:(NSAttributedString *)attributedStatus animated:(bool)animated
{
    [self _setStatus:attributedStatus animated:animated];
}

- (void)setShowStatus:(bool)showStatus {
    _showStatus = showStatus;
    _statusLabel.hidden = !showStatus;
    if (!_showStatus) {
        if (_arrowView == nil) {
            _arrowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TooltipArrow.png"]];
            [self addSubview:_arrowView];
        }
    }
}

- (void)_setStatus:(id)status animated:(bool)animated
{
    if (!TGObjectCompare(status, _status))
    {
        _status = status;
        
        if (_typingStatus == nil)
        {
            if ([status isKindOfClass:[NSAttributedString class]])
                [self statusLabel].text = ((NSAttributedString *)status).string;
            else
                [self statusLabel].text = status;
            
            if (animated && self.window != nil && iosMajorVersion() >= 7)
                [self _animateStatus];
            else
                [self setNeedsLayout];
        }
    }
}

- (void)setStatusHasAccentColor:(bool)statusHasAccentColor
{
    if (_statusHasAccentColor != statusHasAccentColor)
    {
        _statusHasAccentColor = statusHasAccentColor;
        
        if (_typingStatus == nil)
            _statusLabel.textColor = _statusHasAccentColor ? UIColorRGB(0x007bff) : UIColorRGB(0x86868d);
    }
}

- (void)setToggleMode:(TGModernConversationControllerTitleToggle)toggleMode {
    if (_toggleMode != toggleMode) {
        _toggleMode = toggleMode;
        
        switch (toggleMode) {
            case TGModernConversationControllerTitleToggleNone: {
                break;
            }
            case TGModernConversationControllerTitleToggleShowDiscussion: {
                self.toggleIcon.image = [UIImage imageNamed:@"ConversationTitleSwitchOff.png"];
                self.toggleLabel.text = TGLocalized(@"Channel.TitleShowDiscussion");
                break;
            }
            case TGModernConversationControllerTitleToggleHideDiscussion: {
                self.toggleIcon.image = [UIImage imageNamed:@"ConversationTitleSwitchOn.png"];
                self.toggleLabel.text = TGLocalized(@"Channel.TitleShowDiscussion");
                break;
            }
        }
        
        [self updateHiddenStatuses];
        
        [self.toggleIcon sizeToFit];
        [self.toggleLabel sizeToFit];
        
        [self setNeedsLayout];
    }
}

- (void)updateHiddenStatuses {
    _titleLabel.hidden = [self normalTitleHidden];
    _statusLabel.hidden = [self normalStatusHidden];
    for (UIView *view in _iconViews) {
        view.hidden = [self normalStatusHidden];
    }
    _activityIndicator.hidden = [self normalStatusHidden];
    
    _toggleIcon.hidden = [self toggleHidden];
    _toggleLabel.hidden = [self toggleHidden];
}

- (void)setTypingStatus:(NSString *)typingStatus
{
    [self setTypingStatus:typingStatus activity:TGModernConversationTitleViewActivityTyping animated:false];
}

- (void)setTypingStatus:(NSString *)typingStatus activity:(TGModernConversationTitleViewActivity)activity animated:(bool)animated
{
    if (!TGStringCompare(typingStatus, _typingStatus))
    {
        bool reallyAnimated = animated && self.window != nil && iosMajorVersion() >= 7;
        
        _typingStatus = typingStatus;
        
        if (typingStatus == nil)
        {
            [self statusLabel].attributedText = [[NSAttributedString alloc] initWithString:_status];
            _statusLabel.textColor = _statusHasAccentColor ? UIColorRGB(0x007bff) : UIColorRGB(0x86868d);
        }
        else
        {
            [self statusLabel].attributedText = [[NSAttributedString alloc] initWithString:typingStatus];
            _statusLabel.textColor = UIColorRGB(0x007bff);
        }
        
        if (typingStatus == nil)
        {
            if (reallyAnimated)
            {
                [UIView animateWithDuration:0.12 animations:^
                {
                    _activityIndicator.alpha = 0.0f;
                } completion:^(BOOL finished)
                {
                    if (finished)
                    {
                        [_activityIndicator setNone];
                        [_activityIndicator removeFromSuperview];
                    }
                }];
            }
            else
            {
                [_activityIndicator setNone];
                [_activityIndicator removeFromSuperview];
            }
        }
        else
        {
            if (_activityIndicator == nil)
            {
                _activityIndicator = [[TGModernConversationTitleActivityIndicator alloc] init];
                _activityIndicator.alpha = 0.0f;
            }
            
            if (_activityIndicator.superview != self)
                [self addSubview:_activityIndicator];
            
            switch (activity)
            {
                case TGModernConversationTitleViewActivityAudioRecording:
                    [_activityIndicator setAudioRecording];
                    break;
                case TGModernConversationTitleViewActivityVideoMessageRecording:
                    [_activityIndicator setVideoRecording];
                    break;
                case TGModernConversationTitleViewActivityUploading:
                    [_activityIndicator setUploading];
                    break;
                case TGModernConversationTitleViewActivityPlaying:
                    [_activityIndicator setPlaying];
                    break;
                default:
                    [_activityIndicator setTyping];
                    break;
            }
            
            if (reallyAnimated)
            {
                [UIView animateWithDuration:0.12 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^
                {
                    _activityIndicator.alpha = 1.0f;
                } completion:nil];
            }
            else
                _activityIndicator.alpha = 1.0f;
        }
        
        if (reallyAnimated)
            [self _animateStatus];
        else
            [self setNeedsLayout];
    }
}

- (void)setIcons:(NSArray *)icons
{
    NSMutableArray *previousIconViews = [[NSMutableArray alloc] initWithArray:_iconViews];
    NSMutableArray *currentIconViews = [[NSMutableArray alloc] init];
    
    for (TGModernConversationTitleIcon *icon in icons)
    {
        UIImageView *iconView = nil;
        if (previousIconViews.count != 0)
        {
            iconView = [previousIconViews lastObject];
            [previousIconViews removeLastObject];
            iconView.image = icon.image;
        }
        else
        {
            iconView = [[UIImageView alloc] initWithImage:icon.image];
            [self addSubview:iconView];
            
            iconView.hidden = [self normalStatusHidden];
        }
        [currentIconViews addObject:iconView];
    }
    
    for (UIView *view in previousIconViews)
    {
        [view removeFromSuperview];
    }
    
    _icons = icons;
    _iconViews = currentIconViews;
    
    [self setNeedsLayout];
}

- (void)setModalProgressStatus:(NSString *)modalProgressStatus
{
    if (!TGStringCompare(_modalProgressStatus, modalProgressStatus))
    {
        _modalProgressStatus = modalProgressStatus;
        
        if (_titleModalProgressLabel == nil)
        {
            _titleModalProgressLabel = [[UILabel alloc] init];
            _titleModalProgressLabel.clipsToBounds = false;
            _titleModalProgressLabel.backgroundColor = [UIColor clearColor];
            _titleModalProgressLabel.textColor = [UIColor blackColor];
            _titleModalProgressLabel.font = TGBoldSystemFontOfSize(16.0f);
            
            _titleModalProgressIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        }
        
        if (modalProgressStatus != nil)
        {
            _titleModalProgressLabel.text = modalProgressStatus;
            [_titleModalProgressLabel sizeToFit];
            
            if (_titleModalProgressLabel.superview == nil)
                [self addSubview:_titleModalProgressLabel];
            
            if (_titleModalProgressIndicator.superview == nil)
            {
                [self addSubview:_titleModalProgressIndicator];
                [_titleModalProgressIndicator startAnimating];
            }
            
            [self setNeedsLayout];
        }
        else
        {
            [_titleModalProgressLabel removeFromSuperview];
            [_titleModalProgressIndicator stopAnimating];
            [_titleModalProgressIndicator removeFromSuperview];
        }
        
        
        [self updateHiddenStatuses];
    }
}

- (bool)normalTitleHidden {
    return _modalProgressStatus != nil;
}

- (bool)normalStatusHidden {
    return _modalProgressStatus != nil || _toggleMode != TGModernConversationControllerTitleToggleNone;
}

- (bool)toggleHidden {
    return _modalProgressStatus != nil || _toggleMode == TGModernConversationControllerTitleToggleNone;
}

static UIView *findNavigationBar(UIView *view)
{
    if (view == nil)
        return nil;
    
    if ([view isKindOfClass:[UINavigationBar class]])
        return view;
    
    return findNavigationBar(view.superview);
}

- (void)setUnreadCount:(int)unreadCount
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad || _disableUnreadCount)
        return;
    
    if (_unreadCount != unreadCount)
    {
        _unreadCount = unreadCount;
        
        if (_unreadCount > 0)
        {
            if (_unreadContainer == nil)
            {
                static UIImage *backgroundImage = nil;
                static dispatch_once_t onceToken;
                dispatch_once(&onceToken, ^
                {
                    UIGraphicsBeginImageContextWithOptions(CGSizeMake(17.0f, 17.0f), false, 0.0f);
                    CGContextRef context = UIGraphicsGetCurrentContext();
                    CGContextSetFillColorWithColor(context, UIColorRGB(0xff3b30).CGColor);
                    CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, 17.0f, 17.0f));
                    backgroundImage = [UIGraphicsGetImageFromCurrentImageContext() stretchableImageWithLeftCapWidth:8 topCapHeight:8];
                    UIGraphicsEndImageContext();
                });
                
                _unreadContainer = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 10.0f, 10.0f)];
                if (iosMajorVersion() >= 9 && TGAppDelegateInstance.rootController.isRTL) {
                    _unreadContainer.frame = CGRectMake(findNavigationBar(self.superview).frame.size.width - 10.0f, 0.0f, 10.0f, 10.0f);
                    _unreadContainer.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
                }
                _unreadContainer.userInteractionEnabled = false;
                _unreadContainer.layer.zPosition = 1000;
                if (self.superview != nil)
                    [findNavigationBar(self.superview) addSubview:_unreadContainer];
                
                _unreadBackground = [[UIImageView alloc] initWithImage:backgroundImage];
                [_unreadContainer addSubview:_unreadBackground];
                
                _unreadLabel = [[UILabel alloc] init];
                _unreadLabel.backgroundColor = [UIColor clearColor];
                _unreadLabel.textColor = [UIColor whiteColor];
                _unreadLabel.font = TGSystemFontOfSize(12.0f);
                if ([TGViewController useExperimentalRTL])
                    _unreadLabel.transform = CGAffineTransformMakeScale(-1.0f, 1.0f);
                [_unreadContainer addSubview:_unreadLabel];
                
                _unreadBackground.alpha = _editingMode ? 0.0f : 1.0f;
                _unreadLabel.alpha = _editingMode ? 0.0f : 1.0f;
            }
            
            _unreadContainer.hidden = false;
            
            _unreadLabel.text = TGIsLocaleArabic() ? [TGStringUtils stringWithLocalizedNumberCharacters:[[NSString alloc] initWithFormat:@"%d", unreadCount]] : [[NSString alloc] initWithFormat:@"%d", unreadCount];
            [_unreadLabel sizeToFit];
            
            CGPoint offset = CGPointMake(14.0f, UIInterfaceOrientationIsPortrait(_orientation) ? 2.0f : 0.0f);
            
            _unreadBackground.frame = CGRectMake(offset.x, offset.y, MAX(_unreadLabel.frame.size.width + 8.0f, 17.0f), 17.0f);
            if (TGAppDelegateInstance.rootController.isRTL) {
                CGRect frame = _unreadBackground.frame;
                frame.origin.x = 10.0f - _unreadBackground.frame.size.width;
                _unreadBackground.frame = frame;
            }
            _unreadLabel.frame = CGRectMake(_unreadBackground.frame.origin.x + TGRetinaFloor((_unreadBackground.frame.size.width - _unreadLabel.frame.size.width) / 2.0f), offset.y + 1.0f + (TGIsLocaleArabic() ? 1.0f : 0.0f), _unreadLabel.frame.size.width, _unreadLabel.frame.size.height);
        }
        else if (_unreadContainer != nil)
        {
            _unreadContainer.hidden = true;
        }
    }
}

- (void)setShowUnreadCount:(bool)showUnreadCount {
    _showUnreadCount = showUnreadCount;
    _unreadContainer.alpha = self.alpha * (showUnreadCount ? 1.0f : 0.0f);
}

- (void)disableUnreadCount {
    _disableUnreadCount = true;
    [_unreadContainer removeFromSuperview];
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    
    if (_unreadContainer != nil)
        [_unreadContainer removeFromSuperview];
}

- (void)didMoveToSuperview
{
    [super didMoveToSuperview];
    
    if (_unreadContainer != nil && self.superview != nil)
    {
        if (iosMajorVersion() >= 9 && TGAppDelegateInstance.rootController.isRTL) {
            _unreadContainer.frame = CGRectMake(findNavigationBar(self.superview).frame.size.width - 20.0f, 0.0f, 10.0f, 10.0f);
        }
        
        [findNavigationBar(self.superview) addSubview:_unreadContainer];
    }
}

- (void)setAlpha:(CGFloat)alpha
{
    [super setAlpha:alpha];
    
    _unreadContainer.alpha = alpha * (_showUnreadCount ? 1.0f : 0.0f);
}

- (void)_animateStatus
{
    CGPoint titlePosition = _titleLabel.frame.origin;
    
    UIView *statusSnapshot = [_statusLabel snapshotViewAfterScreenUpdates:false];
    statusSnapshot.frame = _statusLabel.frame;
    
    [self addSubview:statusSnapshot];
    
    [self layoutSubviews];
    
    CGPoint currentTitlePosition = _titleLabel.frame.origin;
    
    CGRect titleFrame = _titleLabel.frame;
    titleFrame.origin = titlePosition;
    _titleLabel.frame = titleFrame;
    
    _statusLabel.alpha = 0.0f;
    
    [UIView animateWithDuration:0.12 delay:0.0 options:iosMajorVersion() >= 7 ? (7 << 16) : 0 animations:^
    {
        CGRect titleFrame = _titleLabel.frame;
        titleFrame.origin = currentTitlePosition;
        _titleLabel.frame = titleFrame;
        
        statusSnapshot.alpha = 0.0f;
        _statusLabel.alpha = 1.0f;
    } completion:^(__unused BOOL finished)
    {
        [statusSnapshot removeFromSuperview];
    }];
}

- (void)setOrientation:(UIInterfaceOrientation)orientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        orientation = UIInterfaceOrientationPortrait;
    
    if (_orientation != orientation)
    {
        _orientation = orientation;
        [self _updateLabelsForCurrentOrientation];
        [self setNeedsLayout];
        
        if (_unreadContainer != nil)
        {
            CGPoint offset = CGPointMake(14.0f, UIInterfaceOrientationIsPortrait(_orientation) ? 2.0f : 0.0f);
            
            CGRect unreadBackgroundFrame = _unreadBackground.frame;
            unreadBackgroundFrame.origin.y = offset.y;
            if (TGAppDelegateInstance.rootController.isRTL) {
                unreadBackgroundFrame.origin.x = 10.0f - unreadBackgroundFrame.size.width;
            }
            _unreadBackground.frame = unreadBackgroundFrame;
            
            _unreadLabel.frame = CGRectMake(_unreadBackground.frame.origin.x + TGRetinaFloor((_unreadBackground.frame.size.width - _unreadLabel.frame.size.width) / 2.0f), offset.y + 1.0f + (TGIsLocaleArabic() ? 1.0f : 0.0f), _unreadLabel.frame.size.width, _unreadLabel.frame.size.height);
        }
    }
}

- (void)setBackButtonTitle:(NSString *)backButtonTitle
{
    _backButtonTitle = backButtonTitle;
    [self setNeedsLayout];
}

- (void)setEditingMode:(bool)editingMode animated:(bool)animated
{
    if (_editingMode != editingMode)
    {
        CGRect titleFrame = _titleLabel.frame;
        CGRect statusFrame = _statusLabel.frame;
        
        _editingMode = !_editingMode;
        [self layoutSubviews];
        
        if (animated && (!CGRectEqualToRect(titleFrame, _titleLabel.frame) || !CGRectEqualToRect(statusFrame, _statusLabel.frame)))
        {
            _editingMode = !_editingMode;
            [self layoutSubviews];
            
            _editingMode = editingMode;
            [UIView animateWithDuration:editingMode ? 0.2 : 0.3 animations:^
            {
                [self layoutSubviews];
            }];
        }
        
        if (_unreadContainer != nil)
        {
            if (animated && !_unreadContainer.hidden)
            {
                [UIView animateWithDuration:editingMode ? 0.2 : 0.3 animations:^
                {
                    _unreadBackground.alpha = editingMode ? 0.0f : 1.0f;
                    _unreadLabel.alpha = editingMode ? 0.0f : 1.0f;
                }];
            }
            else
            {
                _unreadBackground.alpha = editingMode ? 0.0f : 1.0f;
                _unreadLabel.alpha = editingMode ? 0.0f : 1.0f;
            }
        }
    }
}

- (void)layoutSubviews
{
    CGFloat modalProgressPortraitOffset = 0.0f;
    CGFloat modalProgressLandscapeOffset = 0.0f;
    CGFloat modalProgressIndicatorOffset = 0.0f;
    
    CGFloat titlePortraitOffset = 0.0f;
    CGFloat statusPortraitOffset = 0.0f;
    
    CGFloat titleLandscapeOffset = 0.0f;
    CGFloat statusLandscapeOffset = 0.0f;
    
    if (iosMajorVersion() >= 7)
    {
        modalProgressPortraitOffset = 1.0f;
        modalProgressLandscapeOffset = 0.0f;
        modalProgressIndicatorOffset = -1.0f;
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            titlePortraitOffset = -1.0f - TGRetinaPixel;
            statusPortraitOffset = -TGRetinaPixel;
        }
    }
    else
    {
        modalProgressPortraitOffset = -1.0f;
        modalProgressLandscapeOffset = 1.0f;
        modalProgressIndicatorOffset = 0.0f;
        
        titlePortraitOffset = -4.0f;
        statusPortraitOffset = -2.0f;
        
        titleLandscapeOffset = 1.0f;
        statusLandscapeOffset = 2.0f;
    }
    
    CGRect bounds = self.bounds;
    
    if (_titleLabel != nil && _statusLabel != nil)
    {
        CGFloat portraitScreenWidth = [TGViewController screenSizeForInterfaceOrientation:UIInterfaceOrientationPortrait].width - 12.0f;
        CGFloat landscapeScreenWidth = [TGViewController screenSizeForInterfaceOrientation:UIInterfaceOrientationLandscapeLeft].width;
        
        if (TGIsPad())
        {
            portraitScreenWidth = 367.0f;
            landscapeScreenWidth = 1267.0f;
        }
        
        static const CGFloat avatarButtonSize = 50.0f;
        static CGFloat backButtonSize = 0.0f;
        
        static CGFloat clearAllButtonSize = 0.0f;
        static CGFloat cancelButtonSize = 0.0f;
        
        UIFont *buttonFont = TGSystemFontOfSize(16.0f);
        
        backButtonSize = [_backButtonTitle sizeWithFont:buttonFont].width + 27.0f + 8.0f;
        
        clearAllButtonSize = [TGLocalized(@"Conversation.ClearAll") sizeWithFont:buttonFont].width + 16.0f;
        cancelButtonSize = [TGLocalized(@"Common.Cancel") sizeWithFont:buttonFont].width + 16.0f;
        
        CGFloat buttonsWidth = _editingMode ? (clearAllButtonSize + cancelButtonSize) : (backButtonSize + avatarButtonSize);
        
        CGFloat screenWidth = (UIInterfaceOrientationIsPortrait(_orientation) ? portraitScreenWidth : landscapeScreenWidth);
        CGFloat maxTitleWidth = UIInterfaceOrientationIsPortrait(_orientation) ? (screenWidth - buttonsWidth) : CGFloor((screenWidth - buttonsWidth) / 2.0f);
        CGFloat maxStatusWidth = UIInterfaceOrientationIsPortrait(_orientation) ? (screenWidth - buttonsWidth) : CGFloor((screenWidth - buttonsWidth) / 2.0f);
        
        CGFloat portraitAdjustmentBounds = CGFloor(screenWidth - (_editingMode ? clearAllButtonSize : backButtonSize) * 2.0f);

        if (_typingStatus != nil)
            maxStatusWidth -= 18; // dots
        
        CGFloat titleHorizontalOffset = 0.0f;
        CGFloat iconsWeightedWidth = 0.0f;
        CGFloat iconsTotalWidth = 0.0f;
        
        for (TGModernConversationTitleIcon *icon in _icons)
        {
            if (icon.iconPosition == TGModernConversationTitleIconPositionBeforeTitle)
                titleHorizontalOffset += icon.bounds.size.width;
            iconsWeightedWidth += CGFloor(icon.bounds.size.width * icon.offsetWeight);
            iconsTotalWidth += icon.bounds.size.width;
            maxTitleWidth -= icon.bounds.size.width;
        }
        
        CGSize titleLabelSize = [_titleLabel sizeThatFits:CGSizeMake(maxTitleWidth, 1000.0f)];
        titleLabelSize.width = MIN(titleLabelSize.width, maxTitleWidth);
        CGSize statusLabelSize = [_statusLabel sizeThatFits:CGSizeMake(maxStatusWidth, 1000.0f)];
        statusLabelSize.width = MIN(statusLabelSize.width, maxStatusWidth);
        
        if (UIInterfaceOrientationIsPortrait(_orientation))
        {
            CGFloat titleTotalWidth = titleLabelSize.width + iconsWeightedWidth;
            
            CGFloat titleHorizontalAdjustment = CGFloor(MAX(0, titleTotalWidth - portraitAdjustmentBounds) / 2.0f);
            CGFloat statusHorizontalAdjustment = CGFloor(MAX(0, statusLabelSize.width - portraitAdjustmentBounds) / 2.0f);
            if (titleHorizontalAdjustment < statusHorizontalAdjustment)
                titleHorizontalAdjustment = MIN(titleHorizontalAdjustment + 10.0f, statusHorizontalAdjustment);
            
            if ([TGViewController useExperimentalRTL])
            {
                titleHorizontalAdjustment = -titleHorizontalAdjustment;
                statusHorizontalAdjustment = -statusHorizontalAdjustment;
            }
            
            CGPoint titleOrigin = CGPointMake(titleHorizontalAdjustment + CGFloor((bounds.size.width - titleTotalWidth) / 2.0f), -17.0f + titlePortraitOffset);
            if (!_showStatus) {
                titleOrigin.y += 8.0f;
            }
            
            for (TGModernConversationTitleIcon *icon in _icons)
            {
                if (icon.iconPosition == TGModernConversationTitleIconPositionBeforeTitle)
                {
                    titleOrigin.x -= CGFloor(icon.image.size.width / 2.0f);
                }
                else
                {
                    titleOrigin.x += CGFloor(icon.image.size.width / 2.0f);
                }
            }
            
            _titleLabel.frame = CGRectMake(titleOrigin.x + titleHorizontalOffset, titleOrigin.y, titleLabelSize.width, titleLabelSize.height);
            _statusLabel.frame = CGRectMake(statusHorizontalAdjustment + (_typingStatus == nil ? 0.0f : 10.0f) + CGFloor((bounds.size.width - statusLabelSize.width) / 2.0f), 2.0f + statusPortraitOffset, statusLabelSize.width, statusLabelSize.height);
            
            if (_arrowView != nil) {
                CGSize arrowSize = _arrowView.image.size;
                arrowSize.width *= 0.6f;
                arrowSize.height *= 0.6f;
                _arrowView.frame = CGRectMake(CGRectGetMaxX(_titleLabel.frame) + 3.0f, CGRectGetMinY(_titleLabel.frame) + 8.0f, arrowSize.width, arrowSize.height);
            }
            
            if (_toggleIcon != nil) {
                CGSize toggleIconSize = _toggleIcon.bounds.size;
                CGSize toggleLabelSize = _toggleLabel.bounds.size;
                _toggleLabel.frame = CGRectOffset(_toggleLabel.bounds, CGFloor((bounds.size.width - toggleLabelSize.width + toggleIconSize.width + 2.0f) / 2.0f), 2.0f + statusPortraitOffset);
                _toggleIcon.frame = CGRectOffset(_toggleIcon.bounds, _toggleLabel.frame.origin.x - toggleIconSize.width - 5.0f, 5.0f + statusPortraitOffset);
            }
            
            int index = -1;
            CGPoint currentLeftIconOrigin = titleOrigin;
            CGPoint currentRightIconOrigin = CGPointMake(titleOrigin.x + titleHorizontalOffset + titleLabelSize.width, titleOrigin.y);
            for (TGModernConversationTitleIcon *icon in _icons)
            {
                index++;
                UIImageView *iconView = _iconViews[index];
                
                if (icon.iconPosition == TGModernConversationTitleIconPositionBeforeTitle)
                {
                    CGSize iconSize = iconView.image.size;
                    iconView.frame = CGRectMake(currentLeftIconOrigin.x + icon.imageOffset.x, currentLeftIconOrigin.y + icon.imageOffset.y, iconSize.width, iconSize.height);
                    currentLeftIconOrigin.x += icon.bounds.size.width;
                }
                else
                {
                    CGSize iconSize = iconView.image.size;
                    iconView.frame = CGRectMake(currentRightIconOrigin.x + icon.imageOffset.x, currentRightIconOrigin.y + icon.imageOffset.y, iconSize.width, iconSize.height);
                    currentRightIconOrigin.x += icon.bounds.size.width;
                }
            }
            
            if (_typingStatus != nil)
            {
                _activityIndicator.frame = CGRectMake(_statusLabel.frame.origin.x - 24.0f, _statusLabel.frame.origin.y, 24.0f, 16.0f);
            }
        }
        else
        {
            CGFloat spacing = 6.0f;
            
            if (_typingStatus != nil)
                spacing += 18.0f;
            
            CGFloat totalTitleWidth = titleLabelSize.width + iconsTotalWidth;
            CGFloat commonWidth = totalTitleWidth + spacing + statusLabelSize.width;
            
            CGPoint titleOrigin = CGPointMake(CGFloor((bounds.size.width - commonWidth) / 2.0f), -12.0f + titleLandscapeOffset);
            
            _titleLabel.frame = CGRectMake(titleOrigin.x + titleHorizontalOffset, titleOrigin.y, titleLabelSize.width, titleLabelSize.height);
            _statusLabel.frame = CGRectMake(CGFloor((bounds.size.width - commonWidth) / 2.0f) + totalTitleWidth + spacing, -9.0f + TGRetinaPixel + statusLandscapeOffset, statusLabelSize.width, statusLabelSize.height);
            
            if (_toggleIcon != nil) {
                _toggleIcon.frame = CGRectOffset(_toggleIcon.bounds, CGFloor((bounds.size.width - commonWidth) / 2.0f) + totalTitleWidth + spacing, -9.0f + TGRetinaPixel + statusLandscapeOffset + 3.0f);
                _toggleLabel.frame = CGRectOffset(_toggleLabel.bounds, CGRectGetMaxX(_toggleIcon.frame) + 5.0f, -9.0f + TGRetinaPixel + statusLandscapeOffset);
            }
            
            int index = -1;
            CGPoint currentLeftIconOrigin = titleOrigin;
            CGPoint currentRightIconOrigin = CGPointMake(titleOrigin.x + titleHorizontalOffset + titleLabelSize.width, titleOrigin.y);
            
            for (TGModernConversationTitleIcon *icon in _icons)
            {
                index++;
                UIImageView *iconView = _iconViews[index];
                
                if (icon.iconPosition == TGModernConversationTitleIconPositionBeforeTitle)
                {
                    CGSize iconSize = iconView.image.size;
                    iconView.frame = CGRectMake(currentLeftIconOrigin.x + icon.imageOffset.x, currentLeftIconOrigin.y + icon.imageOffset.y, iconSize.width, iconSize.height);
                    currentLeftIconOrigin.x += icon.bounds.size.width;
                }
                else
                {
                    CGSize iconSize = iconView.image.size;
                    iconView.frame = CGRectMake(currentRightIconOrigin.x + icon.imageOffset.x, currentRightIconOrigin.y + icon.imageOffset.y, iconSize.width, iconSize.height);
                    currentRightIconOrigin.x += icon.bounds.size.width;
                }
            }
            
            if (_typingStatus != nil)
            {
                _activityIndicator.frame = CGRectMake(_statusLabel.frame.origin.x - 24.0f, _statusLabel.frame.origin.y, 24.0f, 16.0f);
            }
        }
    }
    
    if (_titleModalProgressLabel != nil && _modalProgressStatus != nil)
    {
        CGRect titleStatusLabelFrame = _titleModalProgressLabel.frame;
        titleStatusLabelFrame.origin = CGPointMake(CGFloor((bounds.size.width - titleStatusLabelFrame.size.width) / 2.0f) + 16.0f, CGFloor((bounds.size.height - titleStatusLabelFrame.size.height) / 2.0f) + (UIInterfaceOrientationIsPortrait(_orientation) ? modalProgressPortraitOffset : modalProgressLandscapeOffset));
        _titleModalProgressLabel.frame = titleStatusLabelFrame;
        
        CGRect titleIndicatorFrame = _titleModalProgressIndicator.frame;
        titleIndicatorFrame.origin = CGPointMake(titleStatusLabelFrame.origin.x - titleIndicatorFrame.size.width - 4.0f, titleStatusLabelFrame.origin.y + modalProgressIndicatorOffset);
        _titleModalProgressIndicator.frame = titleIndicatorFrame;
    }
}

#pragma mark -

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)__unused event
{
    CGRect frame = CGRectUnion(_titleLabel.frame, _statusLabel.frame);
    CGFloat nominalWidth = (_editingMode ? 160.0f : 176.0f);
    if (frame.size.width < nominalWidth)
    {
        frame.origin.x -= CGFloor((nominalWidth - frame.size.width) / 2.0f);
        frame.size.width = nominalWidth;
    }
    if (CGRectContainsPoint(frame, point))
        return self;
    
    return nil;
}

- (void)tapGesture:(UITapGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateRecognized)
    {
        id<TGModernConversationTitleViewDelegate> delegate = _delegate;
        if ([delegate respondsToSelector:@selector(titleViewTapped:)])
            [delegate titleViewTapped:self];
    }
}

@end
