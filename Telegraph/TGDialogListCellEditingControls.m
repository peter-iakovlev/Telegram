#import "TGDialogListCellEditingControls.h"

#import <LegacyComponents/LegacyComponents.h>

#import "TGDialogListCellEditingButton.h"

#import "TGPresentation.h"

static UIFont *buttonFont;
static CGFloat leftButtonWidth;
static CGFloat rightButtonWidth;

static NSString *buttonTitleForType(TGDialogListCellEditingControlButton button) {
    switch (button) {
        case TGDialogListCellEditingControlsDelete:
            return TGLocalized(@"Common.Delete");
        case TGDialogListCellEditingControlsPin:
            return TGLocalized(@"DialogList.Pin");
        case TGDialogListCellEditingControlsUnpin:
            return TGLocalized(@"DialogList.Unpin");
        case TGDialogListCellEditingControlsMute:
            return TGLocalized(@"Conversation.Mute");
        case TGDialogListCellEditingControlsUnmute:
            return TGLocalized(@"Conversation.Unmute");
        case TGDialogListCellEditingControlsPromote:
            return TGLocalized(@"GroupInfo.ActionPromote");
        case TGDialogListCellEditingControlsBan:
            return TGLocalized(@"GroupInfo.ActionBan");
        case TGDialogListCellEditingControlsRestrict:
            return TGLocalized(@"GroupInfo.ActionRestrict");
        case TGDialogListCellEditingControlsGroup:
            return TGLocalized(@"DialogList.Group");
        case TGDialogListCellEditingControlsUngroup:
            return TGLocalized(@"DialogList.Ungroup");
        case TGDialogListCellEditingControlsRead:
            return TGLocalized(@"DialogList.Read");
        case TGDialogListCellEditingControlsUnread:
            return TGLocalized(@"DialogList.Unread");
    }
}

static NSString *animationForType(TGDialogListCellEditingControlButton button) {
    switch (button) {
        case TGDialogListCellEditingControlsDelete:
            return @"anim_delete";
        case TGDialogListCellEditingControlsPin:
            return @"anim_pin";
        case TGDialogListCellEditingControlsUnpin:
            return @"anim_unpin";
        case TGDialogListCellEditingControlsMute:
            return @"anim_mute";
        case TGDialogListCellEditingControlsUnmute:
            return @"anim_unmute";
        case TGDialogListCellEditingControlsPromote:
            return nil;
        case TGDialogListCellEditingControlsBan:
            return nil;
        case TGDialogListCellEditingControlsRestrict:
            return nil;
        case TGDialogListCellEditingControlsGroup:
            return @"anim_group";
        case TGDialogListCellEditingControlsUngroup:
            return @"anim_ungroup";
        case TGDialogListCellEditingControlsRead:
            return @"anim_read";
        case TGDialogListCellEditingControlsUnread:
            return @"anim_unread";
    }
}

static UIColor *buttonColorForType(TGDialogListCellEditingControlButton button, TGPresentation *presentation) {
    switch (button) {
        case TGDialogListCellEditingControlsDelete:
            return presentation.pallete.dialogEditDeleteColor;
        case TGDialogListCellEditingControlsPin:
        case TGDialogListCellEditingControlsUnpin:
            return presentation.pallete.dialogEditPinColor;
        case TGDialogListCellEditingControlsMute:
        case TGDialogListCellEditingControlsUnmute:
            return presentation.pallete.dialogEditMuteColor;
        case TGDialogListCellEditingControlsPromote:
            return presentation.pallete.dialogEditPinColor;
        case TGDialogListCellEditingControlsBan:
            return presentation.pallete.dialogEditDeleteColor;
        case TGDialogListCellEditingControlsRestrict:
            return presentation.pallete.dialogEditMuteColor;
        case TGDialogListCellEditingControlsGroup:
        case TGDialogListCellEditingControlsUngroup:
            return presentation.pallete.dialogEditGroupColor;
        case TGDialogListCellEditingControlsRead:
            return presentation.pallete.dialogEditReadColor;
        case TGDialogListCellEditingControlsUnread:
            return presentation.pallete.dialogEditUnreadColor;
    }
}

static UIImage *buttonImageForType(TGDialogListCellEditingControlButton button, TGPresentation *presentation) {
    switch (button) {
        case TGDialogListCellEditingControlsDelete:
            return presentation.images.dialogEditDeleteIcon;
        case TGDialogListCellEditingControlsPin:
            return presentation.images.dialogEditPinIcon;
        case TGDialogListCellEditingControlsUnpin:
            return presentation.images.dialogEditUnpinIcon;
        case TGDialogListCellEditingControlsMute:
            return presentation.images.dialogEditMuteIcon;
        case TGDialogListCellEditingControlsUnmute:
            return presentation.images.dialogEditUnmuteIcon;
        case TGDialogListCellEditingControlsGroup:
            return presentation.images.dialogEditGroupIcon;
        case TGDialogListCellEditingControlsUngroup:
            return presentation.images.dialogEditUngroupIcon;
        default:
            return nil;
    }
}

@interface TGDialogListCellEditingControlsScroller : UIScrollView

@end

static CGPoint validatedPoint(CGPoint value) {
    if (isnan(value.x)) {
        value.x = 0.0f;
    }
    if (isnan(value.y)) {
        value.y = 0.0f;
    }
    return value;
}

static CGRect validatedRect(CGRect value) {
    value.origin = validatedPoint(value.origin);
    return value;
}

@implementation TGDialogListCellEditingControlsScroller

- (void)setContentOffset:(CGPoint)contentOffset {
    [super setContentOffset:validatedPoint(contentOffset)];
}

- (void)setContentOffset:(CGPoint)contentOffset animated:(BOOL)animated {
    [super setContentOffset:validatedPoint(contentOffset) animated:animated];
}

- (void)setBounds:(CGRect)bounds {
    [super setBounds:validatedRect(bounds)];
}

@end

@interface TGDialogListCellEditingControls () <UIScrollViewDelegate> {
    TGDialogListCellEditingControlsScroller *_scroller;
    NSArray *_leftButtonTypes;
    NSArray *_rightButtonTypes;
    NSMutableArray<TGDialogListCellEditingButton *> *_leftButtons;
    NSMutableArray<TGDialogListCellEditingButton *> *_rightButtons;
    bool _labelOnly;
    bool _smallLabels;
    bool _offsetLabels;
    bool _isExpanded;
    
    bool _animatingCollapse;
    bool _ignoringScroll;

    bool _leftReadyToPlay;
    bool _rightReadyToPlay;
    
    bool _scheduledReset;
    
    UIImpactFeedbackGenerator *_feedbackGenerator;
}

@end

@implementation TGDialogListCellEditingControls

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        _scroller = [[TGDialogListCellEditingControlsScroller alloc] init];
        _scroller.exclusiveTouch = true;
        if (iosMajorVersion() >= 11)
            _scroller.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        _scroller.directionalLockEnabled = true;
        _scroller.showsHorizontalScrollIndicator = false;
        _scroller.showsVerticalScrollIndicator = false;
        _scroller.pagingEnabled = true;
        _scroller.delegate = self;
        _scroller.canCancelContentTouches = false;
        _scroller.delaysContentTouches = false;
        _scroller.scrollsToTop = false;
        [_scroller addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollerTapGesture:)]];
        [self addSubview:_scroller];
        
        _leftButtons = [[NSMutableArray alloc] init];
        _rightButtons = [[NSMutableArray alloc] init];
        
        _leftReadyToPlay = true;
        _rightReadyToPlay = true;
        
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            NSArray<NSString *> *leftStrings = @[
                TGLocalized(@"DialogList.Read"),
                TGLocalized(@"DialogList.Unread"),
            ];
            NSArray<NSString *> *rightStrings = @[
                TGLocalized(@"Common.Delete"),
                TGLocalized(@"DialogList.Pin"),
                TGLocalized(@"DialogList.Unpin"),
                TGLocalized(@"Conversation.Mute"),
                TGLocalized(@"Conversation.Unmute"),
            ];
            buttonFont = TGSystemFontOfSize(14.0f);
            CGFloat buttonInset = 10.0f;
            
            CGFloat maxButtonWidth = 0.0f;
            for (NSString *string in leftStrings) {
                CGSize textSize = [string sizeWithFont:buttonFont];
                if (maxButtonWidth < textSize.width) {
                    maxButtonWidth = textSize.width;
                }
            }
            leftButtonWidth = MAX(80.0f, maxButtonWidth + buttonInset);
            
            maxButtonWidth = 0.0f;
            for (NSString *string in rightStrings) {
                CGSize textSize = [string sizeWithFont:buttonFont];
                if (maxButtonWidth < textSize.width) {
                    maxButtonWidth = textSize.width;
                }
            }
            rightButtonWidth = MAX(74.0f, maxButtonWidth + buttonInset);
        });
        
        [self addGestureRecognizer:_scroller.panGestureRecognizer];
        
        if (iosMajorVersion() >= 10)
            _feedbackGenerator = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleMedium];
    }
    return self;
}

- (void)setLeftButtonTypes:(NSArray *)leftButtonTypes rightButtonTypes:(NSArray *)rightButtonTypes {
    if (!TGObjectCompare(_leftButtonTypes, leftButtonTypes) || !TGObjectCompare(_rightButtonTypes, rightButtonTypes)) {
        _leftButtonTypes = leftButtonTypes;
        _rightButtonTypes = rightButtonTypes;
        
        if (!_animatingCollapse)
            [self resetButtons];
        else
            _scheduledReset = true;
    }
}

- (void)setExpanded:(bool)expanded animated:(bool)animated {
    CGPoint offset = CGPointZero;
    if (expanded) {
        offset = CGPointMake(rightButtonWidth * _rightButtonTypes.count, 0.0f);
    }
    if (animated) {
        if ([_scroller isDragging]) {
            [_scroller removeFromSuperview];
            [self insertSubview:_scroller atIndex:0];
        }
        if (!expanded)
            _animatingCollapse = true;
        
        [UIView animateWithDuration:0.3 animations:^{
            [_scroller setContentOffset:offset animated:false];
        } completion:^(__unused BOOL finished) {
            if (!expanded) {
                for (TGDialogListCellEditingButton *button in _leftButtons) {
                    if (button.hidden)
                        continue;
                    
                    [button resetAnimation];
                }
                for (TGDialogListCellEditingButton *button in _rightButtons.reverseObjectEnumerator) {
                    if (button.hidden)
                        continue;
                    
                    [button resetAnimation];
                }
                
                _animatingCollapse = false;
                if (_scheduledReset)
                {
                    _scheduledReset = false;
                    [self resetButtons];
                }
            }
        }];
    } else {
        if (expanded) {
            for (TGDialogListCellEditingButton *button in _rightButtons.reverseObjectEnumerator) {
                if (button.hidden)
                    continue;
                
                [button skipAnimation];
            }
            
            _leftReadyToPlay = false;
            _rightReadyToPlay = false;
        }
        
        if ([_scroller isDecelerating] || [_scroller isDragging]) {
            [_scroller removeFromSuperview];
            [self insertSubview:_scroller atIndex:0];
        }
        [_scroller setContentOffset:offset animated:false];
        if (!expanded) {
            for (TGDialogListCellEditingButton *button in _leftButtons) {
                if (button.hidden)
                    continue;
                
                [button resetAnimation];
            }
            for (TGDialogListCellEditingButton *button in _rightButtons.reverseObjectEnumerator) {
                if (button.hidden)
                    continue;
                
                [button resetAnimation];
            }
        }
    }
    if (_isExpanded != expanded) {
        _isExpanded = expanded;
        if (_expandedUpdated) {
            _expandedUpdated(expanded);
        }
    }
}

- (bool)isExpanded {
    return _scroller.contentOffset.x > FLT_EPSILON || _scroller.contentOffset.x < -FLT_EPSILON;
}

- (bool)isTracking {
    return _scroller.isDragging || _scroller.isTracking;
}

- (void)setExpandable:(bool)expandable {
    if (expandable != _scroller.scrollEnabled) {
        _scroller.scrollEnabled = expandable;
    }
}

- (void)resetButtons {
    void(^processButtons)(NSArray *, NSMutableArray<TGDialogListCellEditingButton *> *, SEL) = ^(NSArray *buttonTypes, NSMutableArray<TGDialogListCellEditingButton *> *buttons, SEL action)
    {
        NSUInteger index = 0;
        for (NSNumber *nButtonType in buttonTypes) {
            TGDialogListCellEditingControlButton buttonType = (TGDialogListCellEditingControlButton)[nButtonType intValue];
            TGDialogListCellEditingButton *button = nil;
            if (index < buttons.count) {
                button = buttons[index];
            } else {
                button = [[TGDialogListCellEditingButton alloc] init];
                [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
                [buttons addObject:button];
                [self addSubview:button];
            }
            button.hidden = false;
            button.labelOnly = _labelOnly;
            button.smallLabel = _smallLabels;
            button.offsetLabel = _offsetLabels;
            NSString *animationName = animationForType(buttonType);
            if (animationName.length > 0)
                [button setTitle:buttonTitleForType(buttonType) animationName:animationName];
            else
                [button setTitle:buttonTitleForType(buttonType) image:buttonImageForType(buttonType, self.presentation)];
            [button setBackgroundColor:buttonColorForType(buttonType, self.presentation) force:true];
            index++;
        }
        while (index < buttons.count) {
            buttons[index].hidden = true;
            index++;
        }
    };

    processButtons(_leftButtonTypes, _leftButtons, @selector(leftButtonPressed:));
    processButtons(_rightButtonTypes, _rightButtons, @selector(rightButtonPressed:));
    
    [self updateFrames];
}

- (void)setFrame:(CGRect)frame {
    bool shouldUpdateFrames = !CGSizeEqualToSize(frame.size, self.bounds.size);
    [super setFrame:frame];
    
    if (shouldUpdateFrames) {
        [self updateFrames];
    }
}

- (void)updateFrames {
    CGFloat leftContentWidth = _leftButtonTypes.count * rightButtonWidth;
    CGFloat rightContentWidth = _rightButtonTypes.count * rightButtonWidth;
    _scroller.frame = CGRectMake(0.0f, 0.0f, rightContentWidth, 1.0f);
    _scroller.contentSize = CGSizeMake(rightContentWidth * 2.0f, 1.0f);
    _scroller.contentInset = UIEdgeInsetsMake(0.0f, leftContentWidth, 0.0f, 0.0f);
    [self updateButtonFrames];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)__unused scrollView willDecelerate:(BOOL)__unused decelerate {
    if (_leftButtonTypes.count > 0) {
        CGFloat offset = _scroller.bounds.origin.x;
        
        CGFloat leftContentWidth = _leftButtonTypes.count * rightButtonWidth;
        CGFloat unconstrainedLeftOffsetFactor = MAX(0.0f, -offset / leftContentWidth);
        
        if (unconstrainedLeftOffsetFactor > 2.0f)
        {
            for (TGDialogListCellEditingButton *button in _leftButtons) {
                if (button.triggered) {
                    self.userInteractionEnabled = false;
                    _ignoringScroll = true;
                    _animatingCollapse = true;
                    _scroller.contentInset = UIEdgeInsetsMake(0.0f, leftContentWidth, 0.0f, 0.0f);
                    
                    for (TGDialogListCellEditingButton *button in _rightButtons.reverseObjectEnumerator) {
                        if (!button.hidden)
                            button.alpha = 0.0f;
                    }
                    
                    [UIView animateWithDuration:0.2 delay:0.0 options:7 << 16 animations:^{
                        _scroller.contentOffset = CGPointZero;
                        self.bounds = CGRectMake(_scroller.bounds.origin.x, 0.0f, self.bounds.size.width, self.bounds.size.height);
                        button.frame = CGRectMake(-rightButtonWidth, 0.0f, rightButtonWidth, self.bounds.size.height);
                    } completion:^(__unused BOOL finished)
                    {
                        _ignoringScroll = false;
                        _animatingCollapse = false;
                        _scroller.contentOffset = CGPointZero;
                        [self updateButtonFrames:true];
                        
                        for (TGDialogListCellEditingButton *button in _rightButtons.reverseObjectEnumerator) {
                            if (!button.hidden)
                                button.alpha = 1.0f;
                        }
                        
                        if (_scheduledReset) {
                            _scheduledReset = false;
                            [self resetButtons];
                        }
                        
                        self.userInteractionEnabled = true;
                    }];
                    
                    TGDialogListCellEditingControlButton action = TGDialogListCellEditingControlsUnmute;
                    for (NSUInteger index = 0; index < _leftButtonTypes.count; index++) {
                        if (index < _leftButtons.count) {
                            if (_leftButtons[index] == button) {
                                action = (TGDialogListCellEditingControlButton)[_leftButtonTypes[index] intValue];
                            }
                        }
                    }
                    
                    if (action == TGDialogListCellEditingControlsRead)
                    {
                        if (_toggleRead) {
                            _toggleRead(true);
                        }
                    }
                    else if (action == TGDialogListCellEditingControlsUnread)
                    {
                        if (_toggleRead) {
                            _toggleRead(false);
                        }
                    }
                }
            }
        }
        else if (unconstrainedLeftOffsetFactor > 1.0f)
        {
            _scroller.contentInset = UIEdgeInsetsMake(0.0f, leftContentWidth, 0.0f, 0.0f);
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)__unused scrollView {
    [self updateButtonFrames];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)__unused scrollView {
    [self updateButtonFrames:true];
}

- (void)updateButtonFrames {
    [self updateButtonFrames:false];
}

- (void)updateButtonFrames:(bool)maybeReset {
    if (_ignoringScroll)
        return;
    
    CGFloat offset = _scroller.bounds.origin.x;
    CGRect bounds = self.bounds;
    
    bool expanded = offset > FLT_EPSILON;
    if (expanded != _isExpanded) {
        _isExpanded = expanded;
        if (_expandedUpdated) {
            _expandedUpdated(expanded);
        }
    }
    
    self.bounds = CGRectMake(offset, 0.0f, bounds.size.width, bounds.size.height);
    
    if (_leftButtonTypes.count > 0) {
        CGFloat leftContentWidth = _leftButtonTypes.count * rightButtonWidth;
        CGFloat leftOffsetFactor = MIN(1.0f, MAX(0.0f, -offset / leftContentWidth));
        CGFloat unconstrainedLeftOffsetFactor = MAX(0.0f, -offset / leftContentWidth);
        CGFloat nextButtonEndOffset = 0.0f;
        
        bool playFeedback = false;
        if (unconstrainedLeftOffsetFactor > 1.8f && unconstrainedLeftOffsetFactor < 2.2f)
            [_feedbackGenerator prepare];
        
        for (TGDialogListCellEditingButton *button in _leftButtons) {
            if (button.hidden) {
                continue;
            }
            button.buttonWidth = rightButtonWidth;
            button.frame = CGRectMake(-rightButtonWidth * (1.0f - leftOffsetFactor) + nextButtonEndOffset * leftOffsetFactor + offset, 0.0f, rightButtonWidth + MAX(-offset - leftContentWidth, 0.0f), bounds.size.height);
            nextButtonEndOffset += rightButtonWidth;
            
            if (leftOffsetFactor >= 0.4f && _leftReadyToPlay)
                [button playAnimation];
            else if (leftOffsetFactor < FLT_EPSILON && maybeReset) {
                [button resetAnimation];
            }
            
            UIEdgeInsets targetContentInset = UIEdgeInsetsMake(0.0f, leftContentWidth, 0.0f, 0.0f);
            if (unconstrainedLeftOffsetFactor > 1.0f)
                targetContentInset = UIEdgeInsetsMake(0.0f, leftContentWidth * 2.0f, 0.0f, 0.0f);
            
            if (!UIEdgeInsetsEqualToEdgeInsets(targetContentInset, _scroller.contentInset))
                _scroller.contentInset = targetContentInset;
            
            if (unconstrainedLeftOffsetFactor > 2.0f)
            {
                if (!button.triggered)
                {
                    [button setTriggered:true animated:_scroller.isDragging];
                    playFeedback = true;
                }
            }
            else
            {
                if (button.triggered)
                {
                    [button setTriggered:false animated:_scroller.isDragging];
                    playFeedback = true;
                }
            }
        }
        
        if (playFeedback && _scroller.isDragging)
            [_feedbackGenerator impactOccurred];
        
        if (leftOffsetFactor >= 0.4f && leftOffsetFactor < 1.0f - FLT_EPSILON)
            _leftReadyToPlay = false;
        else if (leftOffsetFactor < FLT_EPSILON && (maybeReset || _scroller.contentOffset.x < FLT_EPSILON))
            _leftReadyToPlay = true;
    }
    
    if (_rightButtonTypes.count > 0) {
        CGFloat rightContentWidth = _rightButtonTypes.count * rightButtonWidth;
        CGFloat rightOffsetFactor = MIN(1.0f, MAX(0.0f, offset / rightContentWidth));
        CGFloat nextButtonEndOffset = bounds.size.width - rightButtonWidth;
        for (TGDialogListCellEditingButton *button in _rightButtons.reverseObjectEnumerator) {
            if (button.hidden) {
                continue;
            }
            button.buttonWidth = rightButtonWidth;
            button.frame = CGRectMake(bounds.size.width * (1.0f - rightOffsetFactor) + nextButtonEndOffset * rightOffsetFactor + offset, 0.0f, rightButtonWidth, bounds.size.height);
            nextButtonEndOffset -= rightButtonWidth;
            
            if (rightOffsetFactor >= 0.4f && _rightReadyToPlay)
                [button playAnimation];
            else if (rightOffsetFactor < FLT_EPSILON && maybeReset) {
                [button resetAnimation];
            }
        }
        
        if (rightOffsetFactor >= 0.4f && rightOffsetFactor < 1.0f - FLT_EPSILON)
            _rightReadyToPlay = false;
        else if (rightOffsetFactor < FLT_EPSILON && (maybeReset || _scroller.contentOffset.x < FLT_EPSILON))
            _rightReadyToPlay = true;
    }
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (!self.userInteractionEnabled)
        return nil;
    
    UIView *result = [super hitTest:point withEvent:event];
    if ([result isKindOfClass:[UIButton class]]) {
        _scroller.panGestureRecognizer.enabled = false;
        return result;
    }
    _scroller.panGestureRecognizer.enabled = true;
    if (_scroller.bounds.origin.x > FLT_EPSILON || _scroller.bounds.origin.x < -FLT_EPSILON) {
        return _scroller;
    } else {
        return result;
    }
}

- (void)leftButtonPressed:(UIButton *)button {
    [self buttonPressed:button buttonTypes:_leftButtonTypes buttons:_leftButtons];
    [self setExpanded:false animated:true];
}

- (void)rightButtonPressed:(UIButton *)button {
    [self buttonPressed:button buttonTypes:_rightButtonTypes buttons:_rightButtons];
}

- (void)buttonPressed:(UIButton *)button buttonTypes:(NSArray *)buttonTypes buttons:(NSMutableArray<TGDialogListCellEditingButton *> *)buttons {
    TGDialogListCellEditingControlButton action = TGDialogListCellEditingControlsUnmute;
    for (NSUInteger index = 0; index < buttonTypes.count; index++) {
        if (index < buttons.count) {
            if (buttons[index] == button) {
                action = (TGDialogListCellEditingControlButton)[buttonTypes[index] intValue];
            }
        }
    }
    switch (action) {
        case TGDialogListCellEditingControlsDelete:
            if (_requestDelete) {
                _requestDelete();
            }
            break;
        case TGDialogListCellEditingControlsPin:
            if (_togglePinned) {
                _togglePinned(true);
            }
            break;
        case TGDialogListCellEditingControlsUnpin:
            if (_togglePinned) {
                _togglePinned(false);
            }
            break;
        case TGDialogListCellEditingControlsMute:
            if (_toggleMute) {
                _toggleMute(true);
            }
            break;
        case TGDialogListCellEditingControlsUnmute:
            if (_toggleMute) {
                _toggleMute(false);
            }
            break;
        case TGDialogListCellEditingControlsBan:
            if (_requestDelete) {
                _requestDelete();
            }
            break;
        case TGDialogListCellEditingControlsPromote:
            if (_requestPromote) {
                _requestPromote();
            }
            break;
        case TGDialogListCellEditingControlsRestrict:
            if (_requestRestrict) {
                _requestRestrict();
            }
            break;
        case TGDialogListCellEditingControlsGroup:
            if (_toggleGrouped) {
                _toggleGrouped(true);
            }
            break;
        case TGDialogListCellEditingControlsUngroup:
            if (_toggleGrouped) {
                _toggleGrouped(false);
            }
            break;
        case TGDialogListCellEditingControlsRead:
            if (_toggleRead) {
                _toggleRead(true);
            }
            break;
        case TGDialogListCellEditingControlsUnread:
            if (_toggleRead) {
                _toggleRead(false);
            }
            break;
    }
}

- (void)scrollerTapGesture:(UITapGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateEnded && [self isExpanded]) {
        [self setExpanded:false animated:true];
    }
}

- (void)setLabelOnly:(bool)labelOnly {
    _labelOnly = labelOnly;
    [self resetButtons];
}

- (void)setSmallLabels:(bool)smallLabels {
    _smallLabels = smallLabels;
    [self resetButtons];
}

- (void)setOffsetLabels:(bool)offsetLabels {
    _offsetLabels = offsetLabels;
    [self resetButtons];
}

@end
