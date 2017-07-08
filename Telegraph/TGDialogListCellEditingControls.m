#import "TGDialogListCellEditingControls.h"

#import "TGFont.h"
#import "TGImageUtils.h"

#import "TGDialogListCellEditingButton.h"

static UIFont *buttonFont;
static CGFloat buttonWidth;

NSArray *TGDialogListCellEditingControlButtonsPinDelete() {
    static NSArray *buttons;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        buttons = @[@(TGDialogListCellEditingControlsPin), @(TGDialogListCellEditingControlsDelete)];
    });
    return buttons;
}

NSArray *TGDialogListCellEditingControlButtonsUnpinDelete() {
    static NSArray *buttons;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        buttons = @[@(TGDialogListCellEditingControlsUnpin), @(TGDialogListCellEditingControlsDelete)];
    });
    return buttons;
}

NSArray *TGDialogListCellEditingControlButtonsMutePinDelete() {
    static NSArray *buttons;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        buttons = @[@(TGDialogListCellEditingControlsPin), @(TGDialogListCellEditingControlsMute), @(TGDialogListCellEditingControlsDelete)];
    });
    return buttons;
}

NSArray *TGDialogListCellEditingControlButtonsUnmutePinDelete() {
    static NSArray *buttons;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        buttons = @[@(TGDialogListCellEditingControlsPin), @(TGDialogListCellEditingControlsUnmute), @(TGDialogListCellEditingControlsDelete)];
    });
    return buttons;
}

NSArray *TGDialogListCellEditingControlButtonsMuteUnpinDelete() {
    static NSArray *buttons;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        buttons = @[@(TGDialogListCellEditingControlsUnpin), @(TGDialogListCellEditingControlsMute), @(TGDialogListCellEditingControlsDelete)];
    });
    return buttons;
}

NSArray *TGDialogListCellEditingControlButtonsUnmuteUnpinDelete() {
    static NSArray *buttons;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        buttons = @[@(TGDialogListCellEditingControlsUnpin), @(TGDialogListCellEditingControlsUnmute), @(TGDialogListCellEditingControlsDelete)];
    });
    return buttons;
}

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
    }
}

static UIColor *buttonColorForType(TGDialogListCellEditingControlButton button) {
    static UIColor *redColor = nil;
    static UIColor *grayColor = nil;
    static UIColor *lightGrayColor = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        redColor = UIColorRGB(0xff3824);
        grayColor = UIColorRGB(0xaaaab3);
        lightGrayColor = UIColorRGB(0xbcbcc3);
    });
    switch (button) {
        case TGDialogListCellEditingControlsDelete:
            return redColor;
        case TGDialogListCellEditingControlsPin:
        case TGDialogListCellEditingControlsUnpin:
            return lightGrayColor;
        case TGDialogListCellEditingControlsMute:
        case TGDialogListCellEditingControlsUnmute:
            return grayColor;
        case TGDialogListCellEditingControlsPromote:
            return lightGrayColor;
        case TGDialogListCellEditingControlsBan:
            return redColor;
        case TGDialogListCellEditingControlsRestrict:
            return grayColor;
    }
}

static UIImage *buttonImageForType(TGDialogListCellEditingControlButton button) {
    static UIImage *deleteImage = nil;
    static UIImage *muteImage = nil;
    static UIImage *unmuteImage = nil;
    static UIImage *pinImage = nil;
    static UIImage *unpinImage = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        deleteImage = [[UIImage imageNamed:@"DialogListActionDelete.png"] preloadedImageWithAlpha];
        muteImage = [[UIImage imageNamed:@"DialogListActionMute.png"] preloadedImageWithAlpha];
        unmuteImage = [[UIImage imageNamed:@"DialogListActionUnmute.png"] preloadedImageWithAlpha];
        pinImage = [[UIImage imageNamed:@"DialogListActionPin.png"] preloadedImageWithAlpha];
        unpinImage = [[UIImage imageNamed:@"DialogListActionUnpin.png"] preloadedImageWithAlpha];
    });
    switch (button) {
        case TGDialogListCellEditingControlsDelete:
            return deleteImage;
        case TGDialogListCellEditingControlsPin:
            return pinImage;
        case TGDialogListCellEditingControlsUnpin:
            return unpinImage;
        case TGDialogListCellEditingControlsMute:
            return muteImage;
        case TGDialogListCellEditingControlsUnmute:
            return unmuteImage;
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
    NSArray *_buttonTypes;
    NSMutableArray<TGDialogListCellEditingButton *> *_buttons;
    bool _labelOnly;
    bool _smallLabels;
    bool _offsetLabels;
    bool _isExpanded;
}

@end

@implementation TGDialogListCellEditingControls

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        _scroller = [[TGDialogListCellEditingControlsScroller alloc] init];
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
        _buttons = [[NSMutableArray alloc] init];
        
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            NSArray<NSString *> *strings = @[
                TGLocalized(@"Common.Delete"),
                TGLocalized(@"DialogList.Pin"),
                TGLocalized(@"DialogList.Unpin"),
                TGLocalized(@"Conversation.Mute"),
                TGLocalized(@"Conversation.Unmute")
            ];
            buttonFont = TGSystemFontOfSize(14.0f);
            CGFloat buttonInset = 10.0f;
            CGFloat maxButtonWidth = 0.0f;
            for (NSString *string in strings) {
                CGSize textSize = [string sizeWithFont:buttonFont];
                if (maxButtonWidth < textSize.width) {
                    maxButtonWidth = textSize.width;
                }
            }
            buttonWidth = MAX(74.0f, maxButtonWidth + buttonInset);
        });
        
        [self addGestureRecognizer:_scroller.panGestureRecognizer];
    }
    return self;
}

- (void)setButtonBytes:(NSArray *)buttonTypes {
    if (![_buttonTypes isEqual:buttonTypes]) {
        _buttonTypes = buttonTypes;
        [self resetButtons];
    }
}

- (void)setExpanded:(bool)expanded animated:(bool)animated {
    CGPoint offset = CGPointZero;
    if (expanded) {
        offset = CGPointMake(buttonWidth * _buttonTypes.count, 0.0f);
    }
    if (animated) {
        if ([_scroller isDecelerating] || [_scroller isDragging]) {
            [_scroller removeFromSuperview];
            [self insertSubview:_scroller atIndex:0];
        }
        [UIView animateWithDuration:0.3 animations:^{
            _scroller.contentOffset = offset;
        }];
    } else {
        if ([_scroller isDecelerating] || [_scroller isDragging]) {
            [_scroller removeFromSuperview];
            [self insertSubview:_scroller atIndex:0];
        }
        [_scroller setContentOffset:offset animated:false];
    }
    if (_isExpanded != expanded) {
        _isExpanded = expanded;
        if (_expandedUpdated) {
            _expandedUpdated(expanded);
        }
    }
}

- (bool)isExpanded {
    return _scroller.contentOffset.x > FLT_EPSILON;
}

- (void)setExpandable:(bool)expandable {
    if (expandable != _scroller.scrollEnabled) {
        _scroller.scrollEnabled = expandable;
    }
}

- (void)resetButtons {
    NSUInteger index = 0;
    for (NSNumber *nButtonType in _buttonTypes) {
        TGDialogListCellEditingButton *button = nil;
        if (index < _buttons.count) {
            button = _buttons[index];
        } else {
            button = [[TGDialogListCellEditingButton alloc] init];
            [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
            [_buttons addObject:button];
            [self addSubview:button];
        }
        button.hidden = false;
        button.labelOnly = _labelOnly;
        button.smallLabel = _smallLabels;
        button.offsetLabel = _offsetLabels;
        TGDialogListCellEditingControlButton buttonType = (TGDialogListCellEditingControlButton)[nButtonType intValue];
        [button setTitle:buttonTitleForType(buttonType) image:buttonImageForType(buttonType)];
        [button setBackgroundColor:buttonColorForType(buttonType) force:true];
        index++;
    }
    while (index < _buttons.count) {
        _buttons[index].hidden = true;
        index++;
    }
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
    CGFloat contentWidth = _buttonTypes.count * buttonWidth;
    _scroller.frame = CGRectMake(0.0f, 0.0f, contentWidth, 1.0f);
    _scroller.contentSize = CGSizeMake(contentWidth * 2.0f, 1.0f);
    [self updateButtonFrames];
}

- (void)scrollViewDidScroll:(UIScrollView *)__unused scrollView {
    [self updateButtonFrames];
}

- (void)updateButtonFrames {
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
    
    if (_buttonTypes.count == 0) {
        return;
    }
    
    CGFloat contentWidth = _buttonTypes.count * buttonWidth;
    CGFloat offsetFactor = MIN(1.0f, MAX(0.0f, offset / contentWidth));
    CGFloat nextButtonEndOffset = bounds.size.width - buttonWidth;
    for (UIButton *button in _buttons.reverseObjectEnumerator) {
        if (button.hidden) {
            continue;
        }
        button.frame = CGRectMake(bounds.size.width * (1.0f - offsetFactor) + nextButtonEndOffset * offsetFactor + offset, 0.0f, buttonWidth, bounds.size.height);
        nextButtonEndOffset -= buttonWidth;
    }
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *result = [super hitTest:point withEvent:event];
    if ([result isKindOfClass:[UIButton class]]) {
        _scroller.panGestureRecognizer.enabled = false;
        return result;
    }
    _scroller.panGestureRecognizer.enabled = true;
    if (_scroller.bounds.origin.x > FLT_EPSILON) {
        return _scroller;
    } else {
        return result;
    }
}

- (void)buttonPressed:(UIButton *)button {
    TGDialogListCellEditingControlButton action = TGDialogListCellEditingControlsUnmute;
    for (NSUInteger index = 0; index < _buttonTypes.count; index++) {
        if (index < _buttons.count) {
            if (_buttons[index] == button) {
                action = (TGDialogListCellEditingControlButton)[_buttonTypes[index] intValue];
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
