#import "TGNotificationView.h"
#import "TGNotificationBackgroundView.h"
#import "TGNotificationContentView.h"
#import "TGNotificationReplyPanelView.h"

#import <SSignalKit/SSignalKit.h>

#import "TGUser.h"
#import "TGStringUtils.h"

#import "TGModernConversationMentionsAssociatedPanel.h"
#import "TGModernConversationHashtagsAssociatedPanel.h"
#import "TGStickerAssociatedInputPanel.h"

const CGFloat TGNotificationDefaultHeight = 68.0f;
const CGFloat TGNotificationDefaultPreviewHeight = TGNotificationDefaultHeight - 5.0f;
const CGFloat TGNotificationMaximumHeight = 160.0f;
const CGFloat TGNotificationMaximumWidth = 470.0f;
const CGFloat TGNotificationBottomPadding = 1.0f;
const CGFloat TGNotificationBackgroundInset = -100.0f;
const CGFloat TGNotificationBottomHitTestInset = 20.0f;

@interface TGNotificationView () <TGNotificationReplyPanelDelegate, UIGestureRecognizerDelegate>
{
    TGNotificationBackgroundView *_backgroundView;
    TGNotificationReplyPanelView *_replyView;
    UIView *_handleView;
    
    UIView *_transitionView;
    
    UIPanGestureRecognizer *_panGestureRecognizer;
    UITapGestureRecognizer *_tapGestureRecognizer;
    
    CGFloat _initialOffset;
    bool _initialGestureFinished;
    
    SMetaDisposable *_stickerPacksDisposable;
}
@end

@implementation TGNotificationView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        _backgroundView = [[TGNotificationBackgroundView alloc] initWithFrame:self.bounds];
        _backgroundView.userInteractionEnabled = false;
        [self addSubview:_backgroundView];
        
        _contentView = [[TGNotificationContentView alloc] initWithFrame:self.bounds];
        [self addSubview:_contentView];
    
        _replyView = [[TGNotificationReplyPanelView alloc] initWithFrame:CGRectMake(0, 0, 0, 46)];
        _replyView.alpha = 0.0f;
        _replyView.delegate = self;
        _replyView.userInteractionEnabled = false;
        [self addSubview:_replyView];
        
        _handleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 37, 5)];
        _handleView.layer.cornerRadius = 2.5f;
        _handleView.backgroundColor = (iosMajorVersion() >= 8) ? [UIColor whiteColor] : UIColorRGB(0x9c9c9c);
        _handleView.userInteractionEnabled = false;
        
        if (iosMajorVersion() >= 8)
            [_backgroundView.vibrantEffectView.contentView addSubview:_handleView];
        else
            [_backgroundView addSubview:_handleView];
        
        _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        _panGestureRecognizer.delegate = self;
        _panGestureRecognizer.minimumNumberOfTouches = 1;
        _panGestureRecognizer.maximumNumberOfTouches = 1;
        [self addGestureRecognizer:_panGestureRecognizer];
        
        _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        _tapGestureRecognizer.delegate = self;
        [self addGestureRecognizer:_tapGestureRecognizer];
    }
    return self;
}

#pragma mark -

- (void)handlePan:(UIPanGestureRecognizer *)gesture
{
    CGPoint location = [gesture locationInView:gesture.view.superview];
    CGFloat offset = (_initialOffset - location.y) * -1;
    switch (gesture.state)
    {
        case UIGestureRecognizerStateBegan:
        {
            _initialOffset = location.y;
            _isInteracting = true;
        }
            break;
            
        case UIGestureRecognizerStateChanged:
        {
            bool shouldShrink = [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone && UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation);
            
            CGFloat expandedHeight = [self expandedHeightWithContent:!shouldShrink];
            CGFloat diff = expandedHeight - TGNotificationDefaultHeight;
            
            offset = _initialGestureFinished ? offset + diff : offset;
            
            CGFloat origin = 0;
            CGFloat height = MAX(TGNotificationDefaultHeight, TGNotificationDefaultHeight + offset);
            height = (height >= expandedHeight) ? expandedHeight + [self _swipeOffsetForOffset:height - expandedHeight] : height;
            
            if (self.isExpanded)
            {
                if (height < expandedHeight)
                {
                    if (height > TGNotificationDefaultHeight)
                        origin = height - expandedHeight;
                    else
                        origin = offset - (expandedHeight - TGNotificationDefaultHeight);
                }
                
                height = MAX(expandedHeight, height);
            }
            else
            {
                origin = offset < 0 ? offset : 0;
            }
            
            self.frame = CGRectMake(self.frame.origin.x, origin, self.frame.size.width, height);
            
            CGFloat threshold = expandedHeight - 95.0f;
            CGFloat progress = MAX(0, (offset - threshold) / (diff - threshold));
            
            if (!_handleView.hidden)
                [self setExpandProgress:progress isExpanded:self.isExpanded];
            
            if (offset < expandedHeight - TGNotificationDefaultHeight)
            {
                CGFloat contentHeight = self.isExpanded ? [self expandedPreviewHeight] : MIN([self expandedPreviewHeight], TGNotificationDefaultHeight + offset);
                _contentView.frame = CGRectMake(_contentView.frame.origin.x, 0, _contentView.frame.size.width, contentHeight);
                
                if (_handleView.hidden)
                    return;
                
                if (fabs([self expandedPreviewHeight] - TGNotificationDefaultHeight) > 2.0f)
                {
                    CGFloat progress = (contentHeight - TGNotificationDefaultHeight) / ([self expandedPreviewHeight] - TGNotificationDefaultHeight);
                    progress = self.isExpanded ? 1.0f : MIN(1.0f, MAX(progress, 0.0f));
                    progress = shouldShrink ? 0.0f : progress;
                    [_contentView.previewView setExpandProgress:progress];
                }
                else
                {
                    progress = self.isExpanded ? 1.0f : MIN(1.0f, MAX(progress, 0.0f));
                    progress = shouldShrink ? 0.0f : progress;
                    [_contentView.previewView setExpandProgress:progress];
                }
            }
            else
            {
                if ([self expandedHeight] - TGNotificationDefaultHeight > 2.0f)
                {
                    [self setExpanded:true];
                    _contentView.frame = CGRectMake(_contentView.frame.origin.x, height - expandedHeight, _contentView.frame.size.width, [self expandedPreviewHeight]);
                }
                else
                {
                    if (_handleView.hidden)
                    {
                        CGFloat panelHeight = MAX(_contentView.frame.size.height, TGNotificationDefaultHeight);
                        _contentView.frame = CGRectMake(_contentView.frame.origin.x, MAX(0, self.frame.size.height - panelHeight), _contentView.frame.size.width, _contentView.frame.size.height);
                    }
                    else
                    {
                        _initialGestureFinished = true;
                        [self setExpanded:true];
                        
                        gesture.enabled = false;
                        gesture.enabled = true;
                    }
                }
            }
        }
            break;
            
        case UIGestureRecognizerStateEnded:
        {
            _isInteracting = false;
            
            if (offset < 0)
                [self hideAnimated:true];
            else if (_handleView.hidden)
                [self returnAnimated:true];
            else
                [self expandAnimated:true];
        }
            break;
            
        case UIGestureRecognizerStateCancelled:
        {
            _isInteracting = false;
            
            if (!_initialGestureFinished)
                [self hideAnimated:true];
            else
                [self expandAnimated:true];
        }
            break;
            
        default:
            break;
    }
}

- (CGFloat)_swipeOffsetForOffset:(CGFloat)offset
{
    if (offset > 0.0f)
    {
        CGFloat c = 0.2f;
        CGFloat d = [self expandedHeight];
        return (CGFloat)((1.0f - (1.0f / ((offset * c / d) + 1.0))) * d);
    }
    
    return offset;
}

- (void)handleTap:(UITapGestureRecognizer *)__unused gesture
{
    bool shouldExpand = false;
    if (self.shouldExpandOnTap != nil)
        shouldExpand = self.shouldExpandOnTap();
    
    if (shouldExpand)
    {
        if (self.isExpandable && !self.isExpanded)
            [self expandAnimated:true fromGesture:false];
    }
    else if (self.onTap != nil)
    {
        self.onTap();
        if (self.isPresented)
            [self hideAnimated:true];
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer == _tapGestureRecognizer && self.isRepliable && !_replyView.hidden && _replyView.alpha > FLT_EPSILON && [_replyView pointInside:[gestureRecognizer locationInView:_replyView] withEvent:nil])
    {
        return false;
    }
    else if (gestureRecognizer == _panGestureRecognizer && self.isExpanded)
    {
        return [self.contentView.previewView isPanableAtPoint:[gestureRecognizer locationInView:self.contentView.previewView]];
    }
    
    return true;
}

#pragma mark -

- (void)setExpandProgress:(CGFloat)progress isExpanded:(bool)isExpanded
{
    [self setExpandProgress:progress isExpanded:isExpanded fromGesture:true];
}

- (void)setExpandProgress:(CGFloat)progress isExpanded:(bool)isExpanded fromGesture:(bool)fromGesture
{
    progress = MAX(0, MIN(progress, 1));
    
    CGFloat visualProgress = progress;
    progress = isExpanded ? 1.0f : progress;
    
    _handleView.alpha = MAX(0, 1.0f - progress * 1.2f);
    if (self.isRepliable)
    {
        _replyView.hidden = false;
        _replyView.alpha = progress * progress;
    }
    else
    {
        _replyView.hidden = true;
        _replyView.alpha = 0.0f;
    }
    
    if (self.onExpandProgress != nil)
        self.onExpandProgress(visualProgress);
    
    if (fabs(progress - 1.0f) < FLT_EPSILON && !_isExpanded)
        [self setExpanded:true fromGesture:fromGesture];
}

- (void)setExpanded:(bool)expanded
{
    [self setExpanded:expanded fromGesture:true];
}

- (void)setExpanded:(bool)expanded fromGesture:(bool)fromGesture
{
    if (expanded && !_isExpanded)
    {
        if (self.onExpand != nil)
            self.onExpand();
        
        if (self.isRepliable)
        {
            void (^block)(void) = ^
            {
                [_replyView becomeFirstResponder];
            };
            
            if (fromGesture)
                TGDispatchAfter(0.1, dispatch_get_main_queue(), block);
            else
                block();
        }
    }
    
    _isExpanded = expanded;
    _replyView.userInteractionEnabled = (expanded && self.isRepliable);
}

- (void)expandAnimated:(bool)animated
{
    [self expandAnimated:animated fromGesture:true];
}

- (void)expandAnimated:(bool)animated fromGesture:(bool)fromGesture
{
    _initialGestureFinished = true;
    bool shouldShrink = [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone && UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation);
    CGFloat expandedHeight = [self expandedHeightWithContent:!shouldShrink];
    CGFloat expandedContentHeight = shouldShrink ? TGNotificationDefaultHeight : [self expandedPreviewHeight];
    
    void (^changeBlock)(void) = ^
    {
        self.frame = CGRectMake(self.frame.origin.x, 0, self.frame.size.width, expandedHeight);
        _contentView.frame = CGRectMake(_contentView.frame.origin.x, 0, _contentView.frame.size.width, expandedContentHeight);
        
        [self setExpandProgress:1.0f isExpanded:true fromGesture:fromGesture];
        [_contentView.previewView setExpandProgress:shouldShrink ? 0.0f : 1.0f];
        [_contentView.previewView layoutIfNeeded];
    };
    
    UIViewAnimationOptions options = UIViewAnimationOptionLayoutSubviews | UIViewAnimationOptionBeginFromCurrentState;
    if (animated)
        [UIView animateWithDuration:0.25f delay:0.0 options:options animations:changeBlock completion:nil];
    else
        changeBlock();
}

- (bool)isExpandable
{
    return [self expandedPreviewHeight] > TGNotificationDefaultPreviewHeight || self.isRepliable;
}

- (void)returnAnimated:(bool)animated
{
    void (^changeBlock)(void) = ^
    {
        self.frame = CGRectMake(self.frame.origin.x, 0, self.frame.size.width, TGNotificationDefaultHeight);
        _contentView.frame = CGRectMake(_contentView.frame.origin.x, 0, _contentView.frame.size.width, _contentView.frame.size.height);
    };
    
    if (animated)
        [UIView animateWithDuration:0.25 delay:0.0 options:(7 << 16 | UIViewAnimationOptionLayoutSubviews) animations:changeBlock completion:nil];
    else
        changeBlock();
}

- (CGFloat)expandedPreviewHeight
{
    CGFloat contentWidth = self.frame.size.width;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
        contentWidth = MIN(contentWidth, TGNotificationMaximumWidth);
    
    return [_contentView.previewView expandedHeightForContainerSize:CGSizeMake(contentWidth, self.superview.frame.size.height)];
}

- (CGFloat)expandedHeight
{
    return [self expandedHeightWithContent:true];
}

- (CGFloat)expandedHeightWithContent:(bool)withContent
{
    CGFloat contentWidth = _contentView.frame.size.width;
    CGFloat contentHeight = withContent ? [self expandedPreviewHeight] : TGNotificationDefaultHeight;
    CGFloat replyPanelHeight = self.isRepliable ? [_replyView heightForWidth:contentWidth] : TGNotificationBottomPadding;
    
    return MAX(TGNotificationDefaultHeight, contentHeight + replyPanelHeight);
}

- (CGFloat)shrinkedHeight
{
    CGFloat contentWidth = _contentView.frame.size.width;
    CGFloat replyPanelHeight = _replyView.isFirstResponder ? [_replyView heightForWidth:contentWidth] : 0;
    
    return TGNotificationDefaultHeight + replyPanelHeight;
}

- (void)setShrinked:(bool)shrinked
{
    bool isExpanded = self.isExpanded && !shrinked;
    [self.contentView.previewView setExpandProgress:isExpanded ? 1.0f : 0.0f];
}

- (void)hideAnimated:(bool)animated
{
    if (self.hide != nil)
        self.hide(animated);
}

#pragma mark -

- (void)setRequestMedia:(id (^)(TGMediaAttachment *, int64_t, int32_t))requestMedia
{
    _requestMedia = [requestMedia copy];
    _contentView.requestMedia = requestMedia;
}

- (void)setCancelMedia:(void (^)(id))cancelMedia
{
    _cancelMedia = [cancelMedia copy];
    _contentView.cancelMedia = cancelMedia;
}

- (void)setPlayMedia:(void (^)(TGMediaAttachment *, int64_t, int32_t))playMedia
{
    _playMedia = [playMedia copy];
    _contentView.playMedia = playMedia;
}

- (void)setIsMediaAvailable:(bool (^)(TGMediaAttachment *))isMediaAvailable
{
    _isMediaAvailable = [isMediaAvailable copy];
    _contentView.isMediaAvailable = isMediaAvailable;
}

- (void)setMediaContext:(TGModernViewInlineMediaContext *(^)(int64_t, int32_t))mediaContext
{
    _mediaContext = [mediaContext copy];
    _contentView.mediaContext = mediaContext;
}

#pragma mark - 

- (void)inputPanelWillChangeHeight:(TGNotificationReplyPanelView *)__unused inputPanel height:(CGFloat)__unused height duration:(NSTimeInterval)duration animationCurve:(int)animationCurve
{
    CGFloat contentWidth = _contentView.frame.size.width;
    CGFloat replyPanelHeight = [_replyView heightForWidth:contentWidth];
    
    [UIView animateWithDuration:duration delay:0.0 options:(animationCurve | UIViewAnimationOptionLayoutSubviews) animations:^
    {
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, [self expandedHeight]);
        _replyView.frame = CGRectMake((self.frame.size.width - contentWidth) / 2, self.frame.size.height - replyPanelHeight, contentWidth, replyPanelHeight);
    } completion:nil];
}

- (void)inputPanelRequestedSendText:(TGNotificationReplyPanelView *)__unused inputPanel text:(NSString *)text
{
    if (self.sendTextMessage != nil)
        self.sendTextMessage(text);
    
    [self hideAnimated:true];
}

- (void)inputPanelRequestedSendSticker:(TGNotificationReplyPanelView *)__unused inputTextPanel sticker:(TGDocumentMediaAttachment *)sticker
{
    if (self.sendSticker != nil)
        self.sendSticker(sticker);
    
    [self hideAnimated:true];
}

- (void)inputPanelMentionEntered:(TGNotificationReplyPanelView *)inputTextPanel mention:(NSString *)mention startOfLine:(bool)__unused startOfLine
{
    if (mention == nil)
    {
        if ([[inputTextPanel associatedPanel] isKindOfClass:[TGModernConversationMentionsAssociatedPanel class]])
            [inputTextPanel setAssociatedPanel:nil animated:true];
    }
    else
    {
        TGModernConversationMentionsAssociatedPanel *panel = nil;
        if ([[inputTextPanel associatedPanel] isKindOfClass:[TGModernConversationMentionsAssociatedPanel class]])
            panel = (TGModernConversationMentionsAssociatedPanel *)[inputTextPanel associatedPanel];
        else
        {
            panel = [[TGModernConversationMentionsAssociatedPanel alloc] initWithStyle:TGModernConversationAssociatedInputPanelDarkBlurredStyle];
            
            __weak TGNotificationView *weakSelf = self;
            panel.userSelected = ^(TGUser *user)
            {
                __strong TGNotificationView *strongSelf = weakSelf;
                if (strongSelf != nil)
                {
                    if ([[strongSelf->_replyView associatedPanel] isKindOfClass:[TGModernConversationMentionsAssociatedPanel class]])
                        [strongSelf->_replyView setAssociatedPanel:nil animated:false];
                    
                    [strongSelf->_replyView replaceMention:user.userName];
                }
            };
            [inputTextPanel setAssociatedPanel:panel animated:true];
        }
        
        SSignal *userListSignal = nil;
        if (self.userListSignal != nil)
            userListSignal = self.userListSignal(mention);
        
        [panel setUserListSignal:userListSignal];
    }
}

- (void)inputPanelHashtagEntered:(TGNotificationReplyPanelView *)inputTextPanel hashtag:(NSString *)hashtag
{
    if (hashtag == nil)
    {
        if ([[inputTextPanel associatedPanel] isKindOfClass:[TGModernConversationHashtagsAssociatedPanel class]])
            [inputTextPanel setAssociatedPanel:nil animated:true];
    }
    else
    {
        TGModernConversationHashtagsAssociatedPanel *panel = nil;
        if ([[inputTextPanel associatedPanel] isKindOfClass:[TGModernConversationHashtagsAssociatedPanel class]])
            panel = (TGModernConversationHashtagsAssociatedPanel *)[inputTextPanel associatedPanel];
        else
        {
            panel = [[TGModernConversationHashtagsAssociatedPanel alloc] initWithStyle:TGModernConversationAssociatedInputPanelDarkBlurredStyle];
            
            __weak TGNotificationView *weakSelf = self;
            panel.hashtagSelected = ^(NSString *hashtag)
            {
                __strong TGNotificationView *strongSelf = weakSelf;
                if (strongSelf != nil)
                {
                    if ([[strongSelf->_replyView associatedPanel] isKindOfClass:[TGModernConversationHashtagsAssociatedPanel class]])
                        [strongSelf->_replyView setAssociatedPanel:nil animated:false];
                    
                    [strongSelf->_replyView replaceHashtag:hashtag];
                }
            };
            [inputTextPanel setAssociatedPanel:panel animated:true];
        }
        
        SSignal *hashtagListSignal = nil;
        if (self.hashtagListSignal != nil)
            hashtagListSignal = self.hashtagListSignal(hashtag);
        
        [panel setHashtagListSignal:hashtagListSignal];
    }
}

- (void)inputPanelTextChanged:(TGNotificationReplyPanelView *)inputTextPanel text:(NSString *)text
{
    if (self.stickersSignal == nil)
        return;

    if (![text containsSingleEmoji])
    {
        if ([[inputTextPanel associatedPanel] isKindOfClass:[TGStickerAssociatedInputPanel class]])
            [inputTextPanel setAssociatedPanel:nil animated:true];
        
        [_stickerPacksDisposable setDisposable:nil];
    }
    else
    {
        NSString *emoji = [text getEmojiFromString:true checkString:nil].firstObject;
        SSignal *stickersSignal = self.stickersSignal(emoji);
        
        __weak TGNotificationView *weakSelf = self;
        [_stickerPacksDisposable setDisposable:[stickersSignal startWithNext:^(NSDictionary *matchedDocuments)
        {
            __strong TGNotificationView *strongSelf = weakSelf;
            if (strongSelf == nil)
                return;
            
            if (![text isEqualToString:inputTextPanel.text])
                return;

            NSArray *documents = matchedDocuments[@"documents"];
            if (documents.count == 0)
            {
                if ([[strongSelf->_replyView associatedPanel] isKindOfClass:[TGStickerAssociatedInputPanel class]])
                    [strongSelf->_replyView setAssociatedPanel:nil animated:true];
            }
            else
            {
                [strongSelf->_replyView setAssociatedStickerList:matchedDocuments];
            }
        }]];
    }
}

- (TGViewController *)inputPanelParentViewController:(TGNotificationReplyPanelView *)__unused inputTextPanel
{
    return self.parentController();
}

- (bool)inputPanelShouldBecomeFirstResponder:(TGNotificationReplyPanelView *)__unused inputPanel
{
    return true;
}

#pragma mark - 

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *view = [super hitTest:point withEvent:event];
    if (self.isExpanded && self.isRepliable && view == nil)
        view = [_replyView hitTest:[self convertPoint:point toView:_replyView] withEvent:event];
    
    return view;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)__unused event
{
    return CGRectContainsPoint(UIEdgeInsetsInsetRect(self.bounds, UIEdgeInsetsMake(0, 0, -TGNotificationBottomHitTestInset, 0)), point);
}

#pragma mark -

- (void)updateHandleViewAnimated:(bool)animated
{
    bool handleHidden = !(self.isRepliable || [self expandedPreviewHeight] > TGNotificationDefaultHeight);
    [self setHandleHidden:handleHidden animated:animated];
}

- (void)setHandleHidden:(bool)hidden animated:(bool)animated
{
    if (animated)
    {
        if (hidden)
        {
            if (!_handleView.hidden)
                _handleView.hidden = false;
        }
        else
        {
            if (_handleView.hidden)
                _handleView.alpha = 0.0f;
            _handleView.hidden = false;
        }
        
        [UIView animateWithDuration:0.3f animations:^
        {
            _handleView.alpha = hidden ? 0.0f : 1.0f;
        } completion:^(BOOL finished)
        {
            if (finished)
                _handleView.hidden = hidden;
        }];
    }
    else
    {
        _handleView.hidden = hidden;
    }
}

#pragma mark - 

- (void)prepareInterItemTransitionView
{
    if (_transitionView != nil)
        [_transitionView removeFromSuperview];
    
    _transitionView = [_contentView snapshotViewAfterScreenUpdates:false];
    _transitionView.frame = _contentView.frame;
    [self insertSubview:_transitionView belowSubview:_contentView];
}

- (void)playInterItemTransition
{
    [UIView animateWithDuration:0.25 animations:^
    {
        _transitionView.alpha = 0.0f;
    } completion:^(__unused BOOL finished)
    {
        [_transitionView removeFromSuperview];
        _transitionView = nil;
    }];
    
    _contentView.frame = CGRectOffset(_contentView.frame, 0, -_contentView.frame.size.height);
    [UIView animateWithDuration:0.3 delay:0.05 options:7 << 16 animations:^
    {
        _contentView.frame = CGRectMake(_contentView.frame.origin.x, 0, _contentView.frame.size.width, _contentView.frame.size.height);
    } completion:nil];
}

#pragma mark -

- (bool)hasUnsavedData
{
    return self.isRepliable && [_replyView hasUnsavedData];
}

- (bool)isIdle
{
    return _contentView.previewView.isIdle && (!self.isRepliable || [_replyView isIdle]);
}

- (void)prepareForHide
{
    [_replyView resignFirstResponder];
}

- (void)localizationUpdated
{
    [_replyView localizationUpdated];
}

- (void)reset
{
    _panGestureRecognizer.enabled = false;
    _panGestureRecognizer.enabled = true;
    
    _isRepliable = false;
    _initialGestureFinished = false;
    
    _contentView.frame = CGRectMake(_contentView.frame.origin.x, 0, _contentView.frame.size.width, TGNotificationDefaultHeight);

    [_contentView reset];
    [_replyView reset];
    
    [self setExpandProgress:0.0f isExpanded:false];
    [self setExpanded:false];
}

#pragma mark -

- (void)layoutSubviews
{
    _backgroundView.frame = CGRectMake(TGNotificationBackgroundInset, TGNotificationBackgroundInset, self.frame.size.width - 2 * TGNotificationBackgroundInset, self.frame.size.height - TGNotificationBackgroundInset);
    
    CGFloat contentWidth = self.frame.size.width;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
        contentWidth = MIN(contentWidth, TGNotificationMaximumWidth);
    
    bool update = fabs(_contentView.frame.size.width - contentWidth) > FLT_EPSILON;
    _contentView.frame = CGRectMake((self.frame.size.width - contentWidth) / 2, _contentView.frame.origin.y, contentWidth, _contentView.frame.size.height);
    
    CGFloat replyPanelHeight = MAX(50.0f, [_replyView heightForWidth:contentWidth]);
    _replyView.frame = CGRectMake((self.frame.size.width - contentWidth) / 2, self.frame.size.height - replyPanelHeight, contentWidth, replyPanelHeight);
    _handleView.frame = CGRectMake((_backgroundView.frame.size.width - _handleView.frame.size.width) / 2, _backgroundView.frame.size.height - _handleView.frame.size.height - 4, _handleView.frame.size.width, _handleView.frame.size.height);
    
    if (update && _isExpanded)
    {
        [_replyView layoutIfNeeded];
        [_replyView refreshHeight];
    }
}

- (void)inputPanelRequestedSendGif:(TGNotificationReplyPanelView *)__unused inputTextPanel document:(TGDocumentMediaAttachment *)__unused document {
}

@end
