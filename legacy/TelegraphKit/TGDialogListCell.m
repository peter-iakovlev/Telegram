#import "TGDialogListCell.h"

#import "TGDateUtils.h"
#import "TGStringUtils.h"

#import "TGReusableLabel.h"
#import "TGLabel.h"
#import "TGLetteredAvatarView.h"
#import "TGImageUtils.h"

#import "TGMessage.h"
#import "TGUser.h"

#import "TGDateLabel.h"

#import "TGViewController.h"

#import "TGFont.h"
#import "TGTimerTarget.h"

#import "TGPeerIdAdapter.h"

#import "TGTelegraph.h"

#import "Freedom.h"

#import "TGDialogListCellEditingControls.h"

#import "TGCurrencyFormatter.h"

static UIImage *deliveredCheckmark()
{
    static UIImage *image = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        image = [[UIImage imageNamed:@"ModernConversationListIconDelivered.png"] preloadedImageWithAlpha];
    });
    return image;
}

static UIImage *readCheckmark()
{
    static UIImage *image = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        image = [[UIImage imageNamed:@"ModernConversationListIconRead.png"] preloadedImageWithAlpha];
    });
    return image;
}

static UIColor *normalTextColor = nil;
static UIColor *actionTextColor = nil;
static UIColor *mediaTextColor = nil;

@interface TGDialogListTextView : UIView

@property (nonatomic, strong) NSString *title;
@property (nonatomic) CGRect titleFrame;
@property (nonatomic, strong) UIFont *titleFont;
@property (nonatomic, strong) UIImage *mediaIcon;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic) CGRect textFrame;
@property (nonatomic, strong) UIFont *textFont;
@property (nonatomic , strong) NSString *authorName;
@property (nonatomic) CGRect authorNameFrame;
@property (nonatomic, strong) UIFont *authorNameFont;
@property (nonatomic, strong) UIColor *authorNameColor;

@property (nonatomic) CGRect typingFrame;
@property (nonatomic) bool showTyping;
@property (nonatomic, strong) NSString *typingText;

@property (nonatomic) bool isMultichat;
@property (nonatomic) bool isEncrypted;
@property (nonatomic) bool isMuted;
@property (nonatomic) bool isVerified;

@end

@implementation TGDialogListTextView

- (void)drawRect:(CGRect)rect
{
    static UIColor *nTitleColor = nil;
    static CGColorRef titleColor = nil;
    static UIColor *nEncryptedTitleColor = nil;
    static CGColorRef encryptedTitleColor = nil;
    if (titleColor == nil)
    {
        nTitleColor = [UIColor blackColor];
        titleColor = CGColorRetain([nTitleColor CGColor]);
        
        nEncryptedTitleColor = UIColorRGB(0x00a629);
        encryptedTitleColor = CGColorRetain([nEncryptedTitleColor CGColor]);
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGRect frame = self.frame;
    CGRect titleFrame = CGRectOffset(_titleFrame, -frame.origin.x, -frame.origin.y);
    CGRect textFrame = CGRectOffset(_textFrame, -frame.origin.x, -frame.origin.y);
    CGRect authorNameFrame = CGRectOffset(_authorNameFrame, -frame.origin.x, -frame.origin.y);
    CGRect typingFrame = CGRectOffset(_typingFrame, -frame.origin.x, -frame.origin.y);
    
    if (_isEncrypted)
    {
        UIImage *image = nil;
        
        static UIImage *multichatImage = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            multichatImage = [[UIImage imageNamed:@"ModernConversationListIconLock.png"] preloadedImageWithAlpha];
        });
        image = multichatImage;
        
        [image drawAtPoint:CGPointMake(1.0f, 6.0f) blendMode:kCGBlendModeNormal alpha:1.0f];
    }
    else if (false && _isMultichat)
    {
        UIImage *image = nil;
        
        static UIImage *multichatImage = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            multichatImage = [[UIImage imageNamed:@"DialogListGroupChatIcon.png"] preloadedImageWithAlpha];
        });
        image = multichatImage;
        
        [image drawAtPoint:CGPointMake(1, 6.0) blendMode:kCGBlendModeNormal alpha:1.0f];
    }
    
    CGContextSetFillColorWithColor(context, _isEncrypted ? encryptedTitleColor : titleColor);
    if (CGRectIntersectsRect(rect, titleFrame))
    {
        if (iosMajorVersion() >= 7)
        {
            NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
            style.lineBreakMode = NSLineBreakByTruncatingTail;
            style.alignment = NSTextAlignmentLeft;
            
            NSDictionary *attributes = @{
                NSParagraphStyleAttributeName: style,
                NSFontAttributeName: _titleFont,
                NSForegroundColorAttributeName:_isEncrypted ? nEncryptedTitleColor : nTitleColor
            };
            
            [_title drawWithRect:titleFrame options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
        }
        else
        {
            CGSize titleSize = [_title sizeWithFont:_titleFont];
            [_title drawInRect:CGRectMake(titleFrame.origin.x, titleFrame.origin.y, MIN(titleSize.width, titleFrame.size.width), titleFrame.size.height) withFont:_titleFont lineBreakMode:NSLineBreakByTruncatingTail alignment:NSTextAlignmentLeft];
        }
    }
    
    if (_showTyping)
    {
        CGContextSetFillColorWithColor(context, actionTextColor.CGColor);
        
        if (iosMajorVersion() >= 7)
        {
            static NSDictionary *attributes = nil;
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^
            {
                NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
                style.lineBreakMode = NSLineBreakByClipping;
                style.alignment = NSTextAlignmentLeft;

                attributes = @{
                    NSParagraphStyleAttributeName: style,
                    NSFontAttributeName: _textFont,
                    NSForegroundColorAttributeName: _textColor
                };
            });

            [_typingText drawWithRect:typingFrame options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
        }
        else
        {
            CGSize typingSize = [_typingText sizeWithFont:_textFont];
            [_typingText drawInRect:CGRectMake(typingFrame.origin.x, typingFrame.origin.y, MIN(typingSize.width, typingFrame.size.width), typingFrame.size.height) withFont:_textFont lineBreakMode:NSLineBreakByClipping];
        }
    }
    else
    {
        if (CGRectIntersectsRect(rect, textFrame))
        {
            CGContextSetFillColorWithColor(context, _textColor.CGColor);
            
            if (_mediaIcon != nil)
            {
                [_mediaIcon drawAtPoint:CGPointMake(textFrame.origin.x, textFrame.origin.y + 1.5f) blendMode:kCGBlendModeNormal alpha:1.0f];
                textFrame = CGRectMake(textFrame.origin.x + 19, textFrame.origin.y, textFrame.size.width - 19, textFrame.size.height);
            }
            
            if (iosMajorVersion() >= 7)
            {
                static NSDictionary *attributes = nil;
                static dispatch_once_t onceToken;
                dispatch_once(&onceToken, ^
                {
                    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
                    style.lineSpacing = 1 + TGRetinaPixel;
                    style.lineBreakMode = NSLineBreakByWordWrapping;
                    style.alignment = NSTextAlignmentLeft;
                    
                    attributes = @{
                        NSParagraphStyleAttributeName: style,
                        NSFontAttributeName: _textFont,
                        NSForegroundColorAttributeName: _textColor
                    };
                });
                
                [_text drawWithRect:textFrame options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingTruncatesLastVisibleLine attributes:attributes context:nil];
            }
            else
            {
                [_text drawInRect:textFrame withFont:_textFont lineBreakMode:NSLineBreakByTruncatingTail alignment:NSTextAlignmentLeft];
            }
            
            //CGContextFillRect(context, textFrame);
        }
    
        if (_authorName != nil && _authorName.length != 0)
        {
            CGContextSetFillColorWithColor(context, _authorNameColor == nil ? [UIColor blackColor].CGColor : [_authorNameColor CGColor]);
            if (CGRectIntersectsRect(rect, authorNameFrame))
            {
                if (iosMajorVersion() >= 7)
                {
                    NSDictionary *attributes = nil;
                    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
                    style.lineBreakMode = NSLineBreakByTruncatingTail;
                    style.alignment = NSTextAlignmentLeft;
                    
                    attributes = @{
                        NSParagraphStyleAttributeName: style,
                        NSFontAttributeName: _authorNameFont,
                        NSForegroundColorAttributeName: _authorNameColor == nil ? [UIColor blackColor] : _authorNameColor
                    };
                    
                    [_authorName drawWithRect:authorNameFrame options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
                }
                else
                {
                    CGSize authorNameSize = [_authorName sizeWithFont:_authorNameFont];
                    [_authorName drawInRect:CGRectMake(authorNameFrame.origin.x, authorNameFrame.origin.y, MIN(authorNameSize.width, authorNameFrame.size.width), authorNameFrame.size.height) withFont:_authorNameFont lineBreakMode:NSLineBreakByTruncatingTail alignment:NSTextAlignmentRight];
                }
                
                //CGContextFillRect(context, authorNameFrame);
            }
        }
    }
}

@end

#pragma mark - Cell

@interface TGDialogListCell () <UIGestureRecognizerDelegate>
{
    CALayer *_separatorLayer;
    
    UIImage *_unreadBackgroundImage;
    UIImage *_unreadMutedBackgroundImage;
}

@property (nonatomic, strong) TGDialogListCellEditingControls *wrapView;

@property (nonatomic, strong) TGDialogListTextView *textView;

@property (nonatomic, strong) TGLetteredAvatarView *avatarView;
@property (nonatomic, strong) UIImageView *authorAvatarStrokeView;

@property (nonatomic, strong) TGDateLabel *dateLabel;

@property (nonatomic, strong) UIImageView *unreadCountBackgrond;
@property (nonatomic, strong) UIImageView *pinnedBackgrond;
@property (nonatomic, strong) TGLabel *unreadCountLabel;

@property (nonatomic, strong) UIImageView *deliveryErrorBackgrond;

@property (nonatomic, strong) UIImageView *deliveredCheckmark;
@property (nonatomic, strong) UIImageView *readCheckmark;
@property (nonatomic, strong) UIImageView *pendingIndicator;

@property (nonatomic, strong) NSString *dateString;

@property (nonatomic) int validViews;
@property (nonatomic) CGSize validSize;

@property (nonatomic) bool hideAuthorName;

@property (nonatomic) bool editingIsActive;

@property (nonatomic, strong) UIImage *mediaIcon;

@property (nonatomic, strong) UIColor *messageTextColor;

//@property (nonatomic, strong) UIImageView *arrowView;

@property (nonatomic, strong) UIImageView *muteIcon;
@property (nonatomic, strong) UIImageView *verifiedIcon;

@property (nonatomic, strong) UIView *typingDotsContainer;
@property (nonatomic) bool animatingTyping;
@property (nonatomic, strong) NSTimer *typingDotsTimer;
@property (nonatomic) int typingDotsAnimationStep;

@end

@implementation TGDialogListCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier assetsSource:(id<TGDialogListCellAssetsSource>)assetsSource
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        if (iosMajorVersion() >= 7)
        {
            self.contentView.superview.clipsToBounds = false;
        }
        
        if (iosMajorVersion() <= 6) {
            _separatorLayer = [[CALayer alloc] init];
            _separatorLayer.backgroundColor = TGSeparatorColor().CGColor;
            [self.layer addSublayer:_separatorLayer];
        }
        
        _wrapView = [[TGDialogListCellEditingControls alloc] init];
        _wrapView.clipsToBounds = true;
        [self addSubview:_wrapView];
        
        __weak TGDialogListCell *weakSelf = self;
        _wrapView.requestDelete = ^{
            __strong TGDialogListCell *strongSelf = weakSelf;
            if (strongSelf != nil && strongSelf->_conversationId != 0) {
                if (strongSelf->_deleteConversation) {
                    strongSelf->_deleteConversation(strongSelf->_conversationId);
                }
            }
        };
        _wrapView.toggleMute = ^(bool mute) {
            __strong TGDialogListCell *strongSelf = weakSelf;
            if (strongSelf != nil && strongSelf->_conversationId != 0) {
                if (strongSelf->_toggleMuteConversation) {
                    strongSelf->_toggleMuteConversation(strongSelf->_conversationId, mute);
                }
            }
        };
        _wrapView.togglePinned = ^(bool pin) {
            __strong TGDialogListCell *strongSelf = weakSelf;
            if (strongSelf != nil && strongSelf->_conversationId != 0) {
                if (strongSelf->_togglePinConversation) {
                    strongSelf->_togglePinConversation(strongSelf->_conversationId, pin);
                }
            }
        };
        
        UIView *selectedView = [[UIView alloc] init];
        selectedView.backgroundColor = TGSelectionColor();
        self.selectedBackgroundView = selectedView;
        
        _assetsSource = assetsSource;

        _textView = [[TGDialogListTextView alloc] initWithFrame:CGRectMake(73, 2, self.frame.size.width - 73, 46)];
        _textView.contentMode = UIViewContentModeLeft;
        _textView.titleFont = TGMediumSystemFontOfSize(16);
        _textView.textFont = TGSystemFontOfSize(15);
        _textView.authorNameFont = TGSystemFontOfSize(15);
        _textView.opaque = false;
        _textView.backgroundColor = nil;//[UIColor whiteColor];
        
        [_wrapView addSubview:_textView];
        
        _dateString = [[NSMutableString alloc] initWithCapacity:16];
        
        CGFloat dateFontSize = 14.0f;
        CGFloat amWidth = 24.0f;
        if (TGIsPad())
        {
            dateFontSize = 15.0f;
            amWidth = 25.0f;
        }
        
        _dateLabel = [[TGDateLabel alloc] init];
        _dateLabel.amWidth = amWidth;
        _dateLabel.pmWidth = amWidth;
        _dateLabel.dstOffset = 0.0f;
        _dateLabel.dateFont = TGSystemFontOfSize(dateFontSize);
        _dateLabel.dateTextFont = TGSystemFontOfSize(dateFontSize);
        _dateLabel.dateLabelFont = TGSystemFontOfSize(dateFontSize);
        _dateLabel.textColor = UIColorRGB(0x969699);
        _dateLabel.backgroundColor = [UIColor clearColor];
        _dateLabel.opaque = false;
        
#if !TGTEST
        [_wrapView addSubview:_dateLabel];
#endif
        
        bool fadeTransition = cpuCoreCount() > 1;
        
        _avatarView = [[TGLetteredAvatarView alloc] initWithFrame:CGRectMake(10, 7, 62, 62)];
        [_avatarView setSingleFontSize:28.0f doubleFontSize:21.0f useBoldFont:false];
        _avatarView.fadeTransition = fadeTransition;
        [_wrapView addSubview:_avatarView];
        
        static UIImage *unreadBackground = nil;
        static UIImage *unreadMutedBackground = nil;
        static UIImage *pinnedBackground = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^
        {
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(20.0f, 20.0f), false, 0.0f);
            CGContextRef context = UIGraphicsGetCurrentContext();
            
            CGContextSetFillColorWithColor(context, UIColorRGB(0x0f94f3).CGColor);
            CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, 20.0f, 20.0f));
            
            unreadBackground = [UIGraphicsGetImageFromCurrentImageContext() stretchableImageWithLeftCapWidth:10.0f topCapHeight:0.0f];
            UIGraphicsEndImageContext();
            
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(20.0f, 20.0f), false, 0.0f);
            context = UIGraphicsGetCurrentContext();
            
            CGContextSetFillColorWithColor(context, UIColorRGB(0xb6b6bb).CGColor);
            CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, 20.0f, 20.0f));
            
            unreadMutedBackground = [UIGraphicsGetImageFromCurrentImageContext() stretchableImageWithLeftCapWidth:10.0f topCapHeight:0.0f];
            UIGraphicsEndImageContext();
            
            pinnedBackground = [[UIImage imageNamed:@"DialogListPinnedIcon.png"] preloadedImageWithAlpha];
        });
        
        _unreadBackgroundImage = unreadBackground;
        _unreadMutedBackgroundImage = unreadMutedBackground;
        
        _unreadCountBackgrond = [[UIImageView alloc] initWithImage:unreadBackground];
        _pinnedBackgrond = [[UIImageView alloc] initWithImage:pinnedBackground];
        
        [_wrapView addSubview:_unreadCountBackgrond];
        [_wrapView addSubview:_pinnedBackgrond];
        
        _unreadCountLabel = [[TGLabel alloc] initWithFrame:CGRectMake(0, 0, 50, 20)];
        _unreadCountLabel.textColor = [UIColor whiteColor];
        _unreadCountLabel.font = TGSystemFontOfSize(14);
        
        [_wrapView addSubview:_unreadCountLabel];
        
        _unreadCountLabel.backgroundColor = [UIColor clearColor];
        
        //_arrowView = [[UIImageView alloc] initWithImage:arrowImage()];
        //[self addSubview:_arrowView];
        
        _deliveredCheckmark = [[UIImageView alloc] initWithImage:deliveredCheckmark()];
        
        _readCheckmark = [[UIImageView alloc] initWithImage:readCheckmark()];
        
        [_wrapView addSubview:_readCheckmark];
        [_wrapView addSubview:_deliveredCheckmark];
        
        _validSize = CGSizeZero;
    }
    return self;
}

- (void)dealloc
{
    [_avatarView cancelLoading];
    
    if (_typingDotsTimer != nil)
    {
        [_typingDotsTimer invalidate];
        _typingDotsTimer = nil;
    }
}

- (void)prepareForReuse
{
    [self stopTypingAnimation];
    [_wrapView setExpanded:false animated:false];
    
    [super prepareForReuse];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    bool wasSelected = self.selected;
    
    [super setSelected:selected animated:animated];
    
    if ((selected && !wasSelected))
    {
        [self adjustOrdering];
    }
    
    if ((selected && !wasSelected) || (!selected && wasSelected))
    {
        UIView *selectedView = self.selectedBackgroundView;
        if (selectedView != nil && (self.selected || self.highlighted))
        {
            CGFloat separatorHeight = TGScreenPixel;
            selectedView.frame = CGRectMake(0, -separatorHeight, selectedView.frame.size.width, self.frame.size.height + separatorHeight);
        }
        
        if (TGIsPad() && _separatorLayer != nil)
        {
            bool hidden = (self.selected || self.highlighted);
            if (_separatorLayer.hidden != hidden)
            {
                [CATransaction begin];
                [CATransaction setDisableActions:true];
                _separatorLayer.hidden = hidden;
                [CATransaction commit];
            }
        }
    }
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    bool wasHighlighted = self.highlighted;
    
    [super setHighlighted:highlighted animated:animated];
    
    if ((highlighted && !wasHighlighted))
    {
        [self adjustOrdering];
    }
    
    if ((highlighted && !wasHighlighted) || (!highlighted && wasHighlighted))
    {
        UIView *selectedView = self.selectedBackgroundView;
        if (selectedView != nil && (self.selected || self.highlighted))
        {
            CGFloat separatorHeight = TGScreenPixel;
            selectedView.frame = CGRectMake(0, -separatorHeight, selectedView.frame.size.width, self.frame.size.height + separatorHeight);
        }
        
        if (TGIsPad() && _separatorLayer != nil)
        {
            bool hidden = (self.selected || self.highlighted);
            if (_separatorLayer.hidden != hidden)
            {
                [CATransaction begin];
                [CATransaction setDisableActions:true];
                _separatorLayer.hidden = hidden;
                [CATransaction commit];
            }
        }
    }
}

- (void)adjustOrdering
{
    UIView *selectedView = self.selectedBackgroundView;
    if (selectedView != nil)
    {
        CGFloat separatorHeight = TGScreenPixel;
        selectedView.frame = CGRectMake(0, -separatorHeight, selectedView.frame.size.width, self.frame.size.height + separatorHeight);
    }
    
    if ([self.superview isKindOfClass:[UITableView class]])
    {
        Class UITableViewCellClass = [UITableViewCell class];
        Class UISearchBarClass = [UISearchBar class];
        int maxCellIndex = 0;
        int index = -1;
        int selfIndex = 0;
        for (UIView *view in self.superview.subviews)
        {
            index++;
            if ([view isKindOfClass:UITableViewCellClass] || [view isKindOfClass:UISearchBarClass])
            {
                maxCellIndex = index;
                
                if (view == self)
                    selfIndex = index;
            }
        }
        
        if (selfIndex < maxCellIndex)
        {
            [self.superview insertSubview:self atIndex:maxCellIndex];
        }
    }
}

- (void)setTypingString:(NSString *)typingString
{
    [self setTypingString:typingString animated:false];
}

- (void)setTypingString:(NSString *)typingString animated:(bool)__unused animated
{
    _typingString = typingString;
    
    if (((_textView.typingText == nil) != (typingString == nil)) || (typingString != nil) != _textView.showTyping || ![_textView.typingText isEqualToString:typingString])
    {
        _textView.showTyping = typingString != nil;
        _textView.typingText = typingString;
        
        if (typingString != nil)
            [self startTypingAnimation:false];
        else
            [self stopTypingAnimation];
        
        [_textView setNeedsDisplay];
        _validSize = CGSizeZero;
        [self setNeedsLayout];
    }
}

- (void)collectCachedPhotos:(NSMutableDictionary *)dict
{
    [_avatarView tryFillCache:dict];
}

- (UIView *)typingDotsContainer
{
    if (_typingDotsContainer == nil)
    {
        _typingDotsContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        
        for (int i = 0; i < 3; i++)
        {
            UILabel *typingDot = [[UILabel alloc] init];
            typingDot.tag = 100 + i;
            typingDot.text = @".";
            typingDot.textColor = actionTextColor;
            typingDot.font = _textView.textFont;
            typingDot.backgroundColor = [UIColor clearColor];
            typingDot.frame = CGRectMake(4 * i, 0, 4, 10);
            typingDot.alpha = i == 0 ? 0.0f : 0.0f;
            
            [_typingDotsContainer addSubview:typingDot];
        }
    }
    
    return _typingDotsContainer;
}

- (void)restartAnimations:(bool)force
{
    if (_animatingTyping)
    {
        _animatingTyping = false;
        
        if (_typingDotsTimer != nil)
        {
            [_typingDotsTimer invalidate];
            _typingDotsTimer = nil;
        }
    }
    
    if (_textView.showTyping)
        [self startTypingAnimation:force];
}

- (void)stopAnimations
{
    [self stopTypingAnimation];
}

- (void)startTypingAnimation:(bool)force
{
    if (!_animatingTyping)
    {
        UIView *typingDotsContainer = [self typingDotsContainer];
        
        _animatingTyping = true;
        
        if (typingDotsContainer.superview == nil)
        {
            [_wrapView addSubview:typingDotsContainer];
            _validSize = CGSizeZero;
            [self layoutSubviews];
        }
        
        if (self.window != nil)
        {
            UIApplicationState state = [UIApplication sharedApplication].applicationState;
            if (state == UIApplicationStateActive || state == UIApplicationStateInactive || force)
                [self _loopTypingAnimation];
        }
    }
}

- (void)stopTypingAnimation
{
    if (_animatingTyping)
    {
        _animatingTyping = false;
        
        if (_typingDotsTimer != nil)
        {
            [_typingDotsTimer invalidate];
            _typingDotsTimer = nil;
        }
        
        [_typingDotsContainer removeFromSuperview];
    }
}

- (void)_loopTypingAnimation
{
    if (_typingDotsTimer != nil)
    {
        [_typingDotsTimer invalidate];
        _typingDotsTimer = nil;
    }
    
    _typingDotsAnimationStep = 0;
    [self _typingAnimationStep];
}

- (void)_typingAnimationStep
{
    if (_typingDotsTimer != nil)
    {
        [_typingDotsTimer invalidate];
        _typingDotsTimer = nil;
    }
    
    _typingDotsAnimationStep++;
    
    for (UIView *dotView in _typingDotsContainer.subviews)
    {
        if (dotView.tag >= 100)
        {
            int dotIndex = (int)(dotView.tag - 100);
            if (TGIsRTL())
                dotIndex = 2 - dotIndex;
            
            dotView.alpha = dotIndex < (_typingDotsAnimationStep - 1) ? 1.0f : 0.0f;
        }
    }
    
    if (_typingDotsAnimationStep > 3)
    {
        _typingDotsTimer = [TGTimerTarget scheduledMainThreadTimerWithTarget:self action:@selector(_loopTypingAnimation) interval:0.22 repeat:false];
    }
    else
    {
        _typingDotsTimer = [TGTimerTarget scheduledMainThreadTimerWithTarget:self action:@selector(_typingAnimationStep) interval:_typingDotsAnimationStep == 1 ? 0.22 : 0.12 repeat:false];
    }
}

static NSArray *editingButtonTypes(bool muted, bool pinned, bool mutable) {
    if (mutable) {
        if (pinned) {
            if (muted) {
                return TGDialogListCellEditingControlButtonsUnmuteUnpinDelete();
            } else {
                return TGDialogListCellEditingControlButtonsMuteUnpinDelete();
            }
        } else {
            if (muted) {
                return TGDialogListCellEditingControlButtonsUnmutePinDelete();
            } else {
                return TGDialogListCellEditingControlButtonsMutePinDelete();
            }
        }
    } else {
        if (pinned) {
            return TGDialogListCellEditingControlButtonsUnpinDelete();
        } else {
            return TGDialogListCellEditingControlButtonsPinDelete();
        }
    }
}

- (void)resetView:(bool)keepState
{
    if (self.selectionStyle != UITableViewCellSelectionStyleBlue)
        self.selectionStyle = UITableViewCellSelectionStyleBlue;
    
    [_wrapView setButtonBytes:editingButtonTypes(_isMuted, _pinnedToTop, !_isEncrypted)];
    
    UIColor *backgroundColor = _pinnedToTop ? UIColorRGB(0xf7f7f7) : [UIColor whiteColor];
    //_textView.backgroundColor = _pinnedToTop ? [UIColor clearColor] : ((self.highlighted || self.selected) ? _textView.backgroundColor : [UIColor whiteColor]);
    self.backgroundColor = backgroundColor;
    
    _dateString = _date == 0 ? nil : [TGDateUtils stringForMessageListDate:(int)_date];
    
    _textView.title = _titleText;
    _textView.isVerified = _isVerified;
    
    if (normalTextColor == nil)
    {
        normalTextColor = UIColorRGB(0x8e8e93);
        actionTextColor = UIColorRGB(0x8e8e93);
        mediaTextColor = UIColorRGB(0x8e8e93);
    }
    
    bool attachmentFound = false;
    _hideAuthorName = !_isGroupChat || _rawText || (_isChannel && !_isChannelGroup);
    
    if (_messageAttachments != nil && _messageAttachments.count != 0)
    {
        for (TGMediaAttachment *attachment in _messageAttachments)
        {
            if (attachment.type == TGActionMediaAttachmentType)
            {
                _mediaIcon = nil;
                TGActionMediaAttachment *actionAttachment = (TGActionMediaAttachment *)attachment;
                switch (actionAttachment.actionType)
                {
                    case TGMessageActionChatEditTitle:
                    {
                        if (TGPeerIdIsChannel(_conversationId)) {
                            _messageText = _isChannelGroup ? TGLocalized(@"Notification.RenamedGroup") : TGLocalized(@"Notification.RenamedChannel");
                        } else {
                            TGUser *user = [_users objectForKey:@"author"];
                            _messageText = [[NSString alloc] initWithFormat:TGLocalized(@"Notification.RenamedChat"), user.displayName];
                        }
                        _messageTextColor = actionTextColor;
                        attachmentFound = true;
                        
                        _hideAuthorName = true;
                        
                        break;
                    }
                    case TGMessageActionChatEditPhoto:
                    {
                        if (TGPeerIdIsChannel(_conversationId)) {
                            if (_isChannelGroup) {
                                if ([(TGImageMediaAttachment *)[actionAttachment.actionData objectForKey:@"photo"] imageInfo] == nil) {
                                    _messageText = TGLocalized(@"Group.MessagePhotoRemoved");
                                } else {
                                    _messageText = TGLocalized(@"Group.MessagePhotoUpdated");
                                }
                            } else {
                                if ([(TGImageMediaAttachment *)[actionAttachment.actionData objectForKey:@"photo"] imageInfo] == nil) {
                                    _messageText = TGLocalized(@"Channel.MessagePhotoRemoved");
                                } else {
                                    _messageText = TGLocalized(@"Channel.MessagePhotoUpdated");
                                }
                            }
                        } else {
                            TGUser *user = [_users objectForKey:@"author"];
                            if ([(TGImageMediaAttachment *)[actionAttachment.actionData objectForKey:@"photo"] imageInfo] == nil)
                                _messageText = [[NSString alloc] initWithFormat:TGLocalized(@"Notification.RemovedGroupPhoto"), user.displayName];
                            else
                                _messageText = [[NSString alloc] initWithFormat:TGLocalized(@"Notification.ChangedGroupPhoto"), user.displayName];
                        }
                        _messageTextColor = actionTextColor;
                        attachmentFound = true;
                        
                        _hideAuthorName = true;
                        
                        break;
                    }
                    case TGMessageActionUserChangedPhoto:
                    {
                        TGUser *user = [_users objectForKey:@"author"];
                        if ([(TGImageMediaAttachment *)[actionAttachment.actionData objectForKey:@"photo"] imageInfo] == nil)
                            _messageText = [[NSString alloc] initWithFormat:TGLocalized(@"Notification.RemovedUserPhoto"), user.displayFirstName];
                        else
                            _messageText = [[NSString alloc] initWithFormat:TGLocalized(@"Notification.ChangedUserPhoto"), user.displayFirstName];
                        _messageTextColor = actionTextColor;
                        attachmentFound = true;
                        
                        _hideAuthorName = true;
                        
                        break;
                    }
                    case TGMessageActionChatAddMember:
                    {
                        NSArray *uids = actionAttachment.actionData[@"uids"];
                        if (uids != nil) {
                            TGUser *authorUser = [_users objectForKey:@"author"];
                            NSMutableArray *subjectUsers = [[NSMutableArray alloc] init];
                            for (NSNumber *nUid in uids) {
                                TGUser *user = [_users objectForKey:nUid];
                                if (user != nil) {
                                    [subjectUsers addObject:user];
                                }
                            }
                            
                            if (subjectUsers.count == 1 && authorUser.uid == ((TGUser *)subjectUsers[0]).uid) {
                                _messageText = [[NSString alloc] initWithFormat:TGLocalized(@"Notification.JoinedChat"), authorUser.displayName];
                            } else {
                                NSMutableString *subjectNames = [[NSMutableString alloc] init];
                                for (TGUser *user in subjectUsers) {
                                    if (subjectNames.length != 0) {
                                        [subjectNames appendString:@", "];
                                    }
                                    [subjectNames appendString:user.displayName];
                                }
                                _messageText = [[NSString alloc] initWithFormat:TGLocalized(@"Notification.Invited"), authorUser.displayName, subjectNames];
                            }
                            _messageTextColor = actionTextColor;
                            attachmentFound = true;
                            
                            _hideAuthorName = true;
                        } else {
                            NSNumber *nUid = [actionAttachment.actionData objectForKey:@"uid"];
                            if (nUid != nil)
                            {
                                TGUser *authorUser = [_users objectForKey:@"author"];
                                TGUser *subjectUser = [_users objectForKey:nUid];
                                if (authorUser.uid == subjectUser.uid)
                                    _messageText = [[NSString alloc] initWithFormat:TGLocalized(@"Notification.JoinedChat"), authorUser.displayName];
                                else
                                    _messageText = [[NSString alloc] initWithFormat:TGLocalized(@"Notification.Invited"), authorUser.displayName, subjectUser.displayName];
                                _messageTextColor = actionTextColor;
                                attachmentFound = true;
                                
                                _hideAuthorName = true;
                            }
                        }
                        
                        break;
                    }
                    case TGMessageActionJoinedByLink:
                    {
                        TGUser *authorUser = [_users objectForKey:@"author"];
                        _messageText = [[NSString alloc] initWithFormat:TGLocalized(@"Notification.JoinedGroupByLink"), authorUser.displayName];
                        _messageTextColor = actionTextColor;
                        attachmentFound = true;
                        
                        _hideAuthorName = true;
                        
                        break;
                    }
                    case TGMessageActionChatDeleteMember:
                    {
                        NSNumber *nUid = [actionAttachment.actionData objectForKey:@"uid"];
                        if (nUid != nil)
                        {
                            TGUser *authorUser = [_users objectForKey:@"author"];
                            TGUser *subjectUser = [_users objectForKey:nUid];
                            if (authorUser.uid == subjectUser.uid)
                                _messageText = [[NSString alloc] initWithFormat:TGLocalized(@"Notification.LeftChat"), authorUser.displayName];
                            else
                                _messageText = [[NSString alloc] initWithFormat:TGLocalized(@"Notification.Kicked"), authorUser.displayName, subjectUser.displayName];
                            _messageTextColor = actionTextColor;
                            attachmentFound = true;
                            
                            _hideAuthorName = true;
                        }
                        
                        break;
                    }
                    case TGMessageActionCreateChat:
                    {
                        TGUser *user = [_users objectForKey:@"author"];
                        _messageText = [[NSString alloc] initWithFormat:TGLocalized(@"Notification.CreatedChat"), user.displayName];
                        _messageTextColor = actionTextColor;
                        attachmentFound = true;
                        
                        _hideAuthorName = true;
                        
                        break;
                    }
                    case TGMessageActionChannelCreated:
                    {
                        if (_isChannelGroup) {
                            _messageText = TGLocalized(@"Notification.CreatedGroup");
                        } else {
                            _messageText = TGLocalized(@"Notification.CreatedChannel");
                        }
                        _messageTextColor = actionTextColor;
                        attachmentFound = true;
                        
                        _hideAuthorName = true;
                        
                        break;
                    }
                    case TGMessageActionGroupMigratedTo:
                    {
                        _messageText = TGLocalized(@"Notification.GroupMigratedToChannel");
                        _messageTextColor = actionTextColor;
                        attachmentFound = true;
                        
                        _hideAuthorName = true;
                        
                        break;
                    }
                    case TGMessageActionGroupActivated:
                    {
                        _messageText = TGLocalized(@"Notification.GroupDeactivated");
                        _messageTextColor = actionTextColor;
                        attachmentFound = true;
                        
                        _hideAuthorName = true;
                        
                        break;
                    }
                    case TGMessageActionGroupDeactivated:
                    {
                        _messageText = TGLocalized(@"Notification.GroupActivated");
                        _messageTextColor = actionTextColor;
                        attachmentFound = true;
                        
                        _hideAuthorName = true;
                        
                        break;
                    }
                    case TGMessageActionChannelMigratedFrom:
                    {
                        _messageText = [[NSString alloc] initWithFormat:TGLocalized(@"Notification.ChannelMigratedFrom"), actionAttachment.actionData[@"title"]];
                        _messageTextColor = actionTextColor;
                        attachmentFound = true;
                        
                        _hideAuthorName = true;
                        
                        break;
                    }
                    case TGMessageActionChannelInviter:
                    {
                        TGUser *user = [_users objectForKey:@"author"];
                        if ([actionAttachment.actionData[@"uid"] intValue] == user.uid) {
                            if (_isChannelGroup) {
                                _messageText = TGLocalized(@"Notification.GroupInviterSelf");
                            } else {
                                _messageText = TGLocalized(@"Notification.ChannelInviterSelf");
                            }
                        } else {
                            int32_t inviterUid = [actionAttachment.actionData[@"uid"] intValue];
                            NSString *inviterName = nil;
                            TGUser *user = _users[@(inviterUid)];
                            if (user.uid == inviterUid) {
                                inviterName = user.displayName;
                            }
                            
                            if (_isChannelGroup) {
                                _messageText = [[NSString alloc] initWithFormat:TGLocalized(@"Notification.GroupInviter"), inviterName];
                            } else {
                                _messageText = [[NSString alloc] initWithFormat:TGLocalized(@"Notification.ChannelInviter"), inviterName];
                            }
                        }
                        _messageTextColor = actionTextColor;
                        attachmentFound = true;
                        
                        _hideAuthorName = true;
                        
                        break;
                    }
                    case TGMessageActionCreateBroadcastList:
                    {
                        _messageText = TGLocalized(@"Notification.CreatedBroadcastList");
                        _messageTextColor = actionTextColor;
                        attachmentFound = true;
                        
                        _hideAuthorName = true;
                        
                        break;
                    }
                    case TGMessageActionContactRequest:
                    {
                        _messageText = [[NSString alloc] initWithFormat:@"%@ sent contact request", _authorName];
                        _messageTextColor = actionTextColor;
                        attachmentFound = true;
                        
                        _hideAuthorName = true;
                        
                        break;
                    }
                    case TGMessageActionAcceptContactRequest:
                    {
                        _messageText = [[NSString alloc] initWithFormat:@"%@ accepted contact request", _authorName];
                        _messageTextColor = actionTextColor;
                        attachmentFound = true;
                        
                        _hideAuthorName = true;
                        
                        break;
                    }
                    case TGMessageActionContactRegistered:
                    {
                        _messageText = [[NSString alloc] initWithFormat:TGLocalized(@"Notification.Joined"), _authorName];
                        _messageTextColor = actionTextColor;
                        attachmentFound = true;
                        
                        _hideAuthorName = true;
                        
                        break;
                    }
                    case TGMessageActionEncryptedChatRequest:
                    {
                        _messageText = TGLocalized(@"Notification.EncryptedChatRequested");
                        _messageTextColor = actionTextColor;
                        attachmentFound = true;
                        
                        break;
                    }
                    case TGMessageActionEncryptedChatAccept:
                    {
                        _messageText = TGLocalized(@"Notification.EncryptedChatAccepted");
                        _messageTextColor = actionTextColor;
                        attachmentFound = true;
                        
                        break;
                    }
                    case TGMessageActionEncryptedChatDecline:
                    {
                        _messageText = TGLocalized(@"Notification.EncryptedChatRejected");
                        _messageTextColor = actionTextColor;
                        attachmentFound = true;
                        
                        break;
                    }
                    case TGMessageActionEncryptedChatMessageLifetime:
                    {
                        int messageLifetime = [actionAttachment.actionData[@"messageLifetime"] intValue];
                        
                        _messageTextColor = actionTextColor;
                        attachmentFound = true;
                        
                        if (messageLifetime == 0)
                        {
                            if (_outgoing)
                                _messageText = TGLocalized(@"Notification.MessageLifetimeRemovedOutgoing");
                            else
                            {
                                _messageText = [[NSString alloc] initWithFormat:TGLocalized(@"Notification.MessageLifetimeRemoved"), _encryptionFirstName];
                            }
                        }
                        else
                        {
                            NSString *lifetimeString = [TGStringUtils stringForMessageTimerSeconds:messageLifetime];
                            
                            if (_outgoing)
                                _messageText = [[NSString alloc] initWithFormat:TGLocalized(@"Notification.MessageLifetimeChangedOutgoing"), lifetimeString];
                            else
                                _messageText = [[NSString alloc] initWithFormat:TGLocalized(@"Notification.MessageLifetimeChanged"), _encryptionFirstName, lifetimeString];
                        }
                        
                        break;
                    }
                    case TGMessageActionEncryptedChatScreenshot:
                    case TGMessageActionEncryptedChatMessageScreenshot:
                    {
                        if (_encryptionFirstName.length != 0) {
                            _messageText = [[NSString alloc] initWithFormat:TGLocalized(@"Notification.SecretChatMessageScreenshot"), _encryptionFirstName];
                        } else {
                            _messageText = [[NSString alloc] initWithFormat:TGLocalized(@"Notification.SecretChatScreenshot"), _encryptionFirstName];
                        }
                        
                        break;
                    }
                    case TGMessageActionPinnedMessage:
                    {
                        TGMessage *replyMessage = nil;
                        for (id attachment in _messageAttachments) {
                            if ([attachment isKindOfClass:[TGReplyMessageMediaAttachment class]]) {
                                replyMessage = ((TGReplyMessageMediaAttachment *)attachment).replyMessage;
                                break;
                            }
                        }
                        
                        NSString *formatString = replyMessage != nil ? TGLocalized(@"Message.PinnedTextMessage") : TGLocalized(@"Message.PinnedDeletedMessage");
                        for (id attachment in replyMessage.mediaAttachments) {
                            if ([attachment isKindOfClass:[TGImageMediaAttachment class]]) {
                                formatString = TGLocalized(@"Message.PinnedPhotoMessage");
                            } else if ([attachment isKindOfClass:[TGVideoMediaAttachment class]]) {
                                formatString = TGLocalized(@"Message.PinnedVideoMessage");
                            } else if ([attachment isKindOfClass:[TGDocumentMediaAttachment class]]) {
                                TGDocumentMediaAttachment *document = attachment;
                                if ([document isAnimated]) {
                                    formatString = TGLocalized(@"Message.PinnedAnimationMessage");
                                } else {
                                    bool isSticker = false;
                                    bool isAudio = false;
                                    bool isVoice = false;
                                    
                                    for (id attribute in document.attributes) {
                                        if ([attribute isKindOfClass:[TGDocumentAttributeAudio class]]) {
                                            isAudio = true;
                                            isVoice = ((TGDocumentAttributeAudio *)attribute).isVoice;
                                        } else if ([attribute isKindOfClass:[TGDocumentAttributeSticker class]]) {
                                            isSticker = true;
                                        }
                                    }
                                    
                                    if (isSticker) {
                                        formatString = TGLocalized(@"Message.PinnedStickerMessage");
                                    } else if (isVoice) {
                                        formatString = TGLocalized(@"Message.PinnedAudioMessage");
                                    } else {
                                        formatString = TGLocalized(@"Message.PinnedDocumentMessage");
                                    }
                                }
                            } else if ([attachment isKindOfClass:[TGLocationMediaAttachment class]]) {
                                formatString = TGLocalized(@"Message.PinnedLocationMessage");
                            } else if ([attachment isKindOfClass:[TGContactMediaAttachment class]]) {
                                formatString = TGLocalized(@"Message.PinnedContactMessage");
                            } else if ([attachment isKindOfClass:[TGGameMediaAttachment class]]) {
                                formatString = TGLocalized(@"Message.PinnedGame");
                            }  else if ([attachment isKindOfClass:[TGInvoiceMediaAttachment class]]) {
                                formatString = TGLocalized(@"Message.PinnedInvoice");
                            }
                        }
                        
                        _messageText = [NSString stringWithFormat:formatString, replyMessage.text];
                        _messageTextColor = mediaTextColor;
                        
                        break;
                    }
                    case TGMessageActionGameScore:
                    {
                        TGMessage *replyMessage = nil;
                        for (TGMediaAttachment *attachment in _messageAttachments) {
                            if ([attachment isKindOfClass:[TGReplyMessageMediaAttachment class]]) {
                                replyMessage = ((TGReplyMessageMediaAttachment *)attachment).replyMessage;
                            }
                        }
                        
                        NSString *gameTitle = nil;
                        for (id attachment in replyMessage.mediaAttachments) {
                            if ([attachment isKindOfClass:[TGGameMediaAttachment class]]) {
                                gameTitle = ((TGGameMediaAttachment *)attachment).title;
                                break;
                            }
                        }
                        
                        int scoreCount = (int)[actionAttachment.actionData[@"score"] intValue];
                        
                        NSString *formatStringBase = @"";
                        if (_authorIsSelf) {
                            if (gameTitle != nil) {
                                formatStringBase = [TGStringUtils integerValueFormat:@"Notification.GameScoreSelfExtended_" value:scoreCount];
                            } else {
                                formatStringBase = [TGStringUtils integerValueFormat:@"Notification.GameScoreSelfSimple_" value:scoreCount];
                            }
                        } else {
                            if (gameTitle != nil) {
                                formatStringBase = [TGStringUtils integerValueFormat:@"Notification.GameScoreExtended_" value:scoreCount];
                            } else {
                                formatStringBase = [TGStringUtils integerValueFormat:@"Notification.GameScoreSimple_" value:scoreCount];
                            }
                        }
                        
                        NSString *baseString = TGLocalized(formatStringBase);
                        baseString = [baseString stringByReplacingOccurrencesOfString:@"%@" withString:@"{score}"];
                        
                        NSMutableString *formatString = [[NSMutableString alloc] initWithString:baseString];
                        
                        NSRange scoreRange = [formatString rangeOfString:@"{score}"];
                        if (scoreRange.location != NSNotFound) {
                            [formatString replaceCharactersInRange:scoreRange withString:[NSString stringWithFormat:@"%d", scoreCount]];
                        }
                        
                        NSRange gameTitleRange = [formatString rangeOfString:@"{game}"];
                        if (gameTitleRange.location != NSNotFound) {
                            [formatString replaceCharactersInRange:gameTitleRange withString:gameTitle];
                        }
                        
                        _messageText = formatString;
                        _messageTextColor = mediaTextColor;
                        break;
                    }
                    case TGMessageActionPhoneCall:
                    {
                        bool outgoing = _authorIsSelf;
                        int reason = [actionAttachment.actionData[@"reason"] intValue];
                        bool missed = reason == TGCallDiscardReasonMissed || reason == TGCallDiscardReasonBusy;
                        
                        NSString *type = TGLocalized(missed ? (outgoing ? @"Notification.CallCanceled" : @"Notification.CallMissed") : (outgoing ? @"Notification.CallOutgoing" : @"Notification.CallIncoming"));
                        int callDuration = [actionAttachment.actionData[@"duration"] intValue];
                        NSString *duration = missed || callDuration < 1 ? nil : [TGStringUtils stringForCallDurationSeconds:callDuration];
                        NSString *title = duration != nil ? [NSString stringWithFormat:TGLocalized(@"Notification.CallTimeFormat"), type, duration] : type;
                        _messageText = title;
                        _messageTextColor = actionTextColor;
                        break;
                    }
                    case TGMessageActionPaymentSent: {
                        NSString *string = [[TGCurrencyFormatter shared] formatAmount:[actionAttachment.actionData[@"totalAmount"] longLongValue] currency:actionAttachment.actionData[@"currency"]];
                        _messageText = [[NSString alloc] initWithFormat:TGLocalized(@"Message.PaymentSent"), string];
                        _messageTextColor = actionTextColor;
                        break;
                    }
                    default:
                        break;
                }
            }
            else if (attachment.type == TGImageMediaAttachmentType)
            {
                TGImageMediaAttachment *imageMediaAttachment = (TGImageMediaAttachment *)attachment;
                if (imageMediaAttachment.imageId == 0 && imageMediaAttachment.localImageId == 0) {
                    _messageText = TGLocalized(@"Message.ImageExpired");
                    _messageTextColor = mediaTextColor;
                }
                else if (imageMediaAttachment.caption.length > 0)
                {
                    _messageText = imageMediaAttachment.caption;
                    _messageTextColor = normalTextColor;
                }
                else
                {
                    _messageText = TGLocalized(@"Message.Photo");
                    _messageTextColor = mediaTextColor;
                }
                //_mediaIcon = [UIImage imageNamed:@"MediaPhoto"];
                attachmentFound = true;
                break;
            }
            else if (attachment.type == TGVideoMediaAttachmentType)
            {
                TGVideoMediaAttachment *videoMediaAttachment = (TGVideoMediaAttachment *)attachment;
                if (videoMediaAttachment.videoId == 0 && videoMediaAttachment.localVideoId == 0) {
                    _messageText = TGLocalized(@"Message.VideoExpired");
                    _messageTextColor = mediaTextColor;
                }
                else if (videoMediaAttachment.caption.length > 0)
                {
                    _messageText = videoMediaAttachment.caption;
                    _messageTextColor = normalTextColor;
                }
                else
                {
                    _messageText = videoMediaAttachment.roundMessage ? TGLocalized(@"Message.VideoMessage") : TGLocalized(@"Message.Video");
                    _messageTextColor = mediaTextColor;
                }
                //_mediaIcon = [UIImage imageNamed:@"MediaVideo"];
                attachmentFound = true;
                break;
            }
            else if (attachment.type == TGLocationMediaAttachmentType)
            {
                _messageText = TGLocalized(@"Message.Location");
                _messageTextColor = mediaTextColor;
                //_mediaIcon = [UIImage imageNamed:@"MediaLocation"];
                attachmentFound = true;
                break;
            }
            else if (attachment.type == TGContactMediaAttachmentType)
            {
                _messageText = TGLocalized(@"Message.Contact");
                _messageTextColor = mediaTextColor;
                //_mediaIcon = [UIImage imageNamed:@"MediaContact"];
                attachmentFound = true;
                break;
            }
            else if (attachment.type == TGDocumentMediaAttachmentType)
            {
                TGDocumentMediaAttachment *documentAttachment = (TGDocumentMediaAttachment *)attachment;
                
                bool isAnimated = false;
                CGSize imageSize = CGSizeZero;
                bool isSticker = false;
                bool isVoice = false;
                NSString *musicText = nil;
                NSString *stickerRepresentation = nil;
                for (id attribute in documentAttachment.attributes)
                {
                    if ([attribute isKindOfClass:[TGDocumentAttributeAnimated class]])
                    {
                        isAnimated = true;
                    }
                    else if ([attribute isKindOfClass:[TGDocumentAttributeImageSize class]])
                    {
                        imageSize = ((TGDocumentAttributeImageSize *)attribute).size;
                    }
                    else if ([attribute isKindOfClass:[TGDocumentAttributeVideo class]]) {
                        imageSize = ((TGDocumentAttributeVideo *)attribute).size;
                    }
                    else if ([attribute isKindOfClass:[TGDocumentAttributeSticker class]])
                    {
                        isSticker = true;
                        stickerRepresentation = ((TGDocumentAttributeSticker *)attribute).alt;
                    }
                    else if ([attribute isKindOfClass:[TGDocumentAttributeAudio class]]) {
                        isVoice = ((TGDocumentAttributeAudio *)attribute).isVoice;
                        if (!isVoice) {
                            NSString *artist = ((TGDocumentAttributeAudio *)attribute).performer;
                            NSString *title = ((TGDocumentAttributeAudio *)attribute).title;
                            if (artist.length != 0 && title.length != 0) {
                                musicText = [[artist stringByAppendingString:@" — "] stringByAppendingString:title];
                            } else if (artist.length != 0) {
                                musicText = artist;
                            } else if (title.length != 0) {
                                musicText = title;
                            }
                        }
                    }
                }
                
                if (TGPeerIdIsSecretChat(_conversationId) && [documentAttachment.mimeType isEqualToString:@"video/mp4"] && documentAttachment.size < 1024 * 1024) {
                    isAnimated = true;
                }
                
                if (isSticker)
                {
                    if (stickerRepresentation.length == 0)
                        _messageText = TGLocalized(@"Message.Sticker");
                    else
                        _messageText = [[NSString alloc] initWithFormat:@"%@ %@", stickerRepresentation, TGLocalized(@"Message.Sticker")];
                    _mediaIcon = nil;
                }
                else if (isAnimated) {
                    _messageText = TGLocalized(@"Message.Animation");
                    _messageTextColor = mediaTextColor;
                    attachmentFound = true;
                }
                else if (isVoice) {
                    _messageText = TGLocalized(@"Message.Audio");
                    _messageTextColor = mediaTextColor;
                    attachmentFound = true;
                }
                else if (musicText != nil) {
                    _messageText = musicText;
                    _messageTextColor = mediaTextColor;
                    attachmentFound = true;
                }
                else
                {
                    NSString *fileName = ((TGDocumentMediaAttachment *)attachment).fileName;
                    if (fileName.length != 0)
                        _messageText = fileName;
                    else
                        _messageText = TGLocalized(@"Message.File");
                    
                    _messageTextColor = mediaTextColor;
                    //_mediaIcon = [UIImage imageNamed:@"MediaFile"];
                    attachmentFound = true;
                }
                break;
            }
            else if (attachment.type == TGAudioMediaAttachmentType)
            {
                _messageText = TGLocalized(@"Message.Audio");
                _messageTextColor = mediaTextColor;
                //_mediaIcon = [UIImage imageNamed:@"MediaVoice"];
                attachmentFound = true;
                break;
            }
            else if (attachment.type == TGGameAttachmentType) {
                _messageText = [@"🎮 " stringByAppendingString:((TGGameMediaAttachment *)attachment).title];
                _messageTextColor = mediaTextColor;
                //_mediaIcon = [UIImage imageNamed:@"MediaVoice"];
                attachmentFound = true;
                break;
            } else if (attachment.type == TGInvoiceMediaAttachmentType) {
                _messageText = [@"" stringByAppendingString:((TGInvoiceMediaAttachment *)attachment).title];
                _messageTextColor = mediaTextColor;
                //_mediaIcon = [UIImage imageNamed:@"MediaVoice"];
                attachmentFound = true;
                break;
            }
        }
    }
    
    if (!attachmentFound)
    {
        _messageTextColor = normalTextColor;
        _mediaIcon = nil;
    }
    
    if (_messageText.length == 0)
    {
        _messageTextColor = actionTextColor;
        if (_isEncrypted)
        {
            if (_encryptionStatus == 1)
                _messageText = [[NSString alloc] initWithFormat:TGLocalized(@"DialogList.AwaitingEncryption"), _encryptionFirstName];
            else if (_encryptionStatus == 2)
                _messageText = TGLocalized(@"DialogList.EncryptionProcessing");
            else if (_encryptionStatus == 3)
                _messageText = TGLocalized(@"DialogList.EncryptionRejected");
            else if (_encryptionStatus == 4)
            {
                if (_encryptionOutgoing)
                    _messageText = [[NSString alloc] initWithFormat:TGLocalized(@"DialogList.EncryptedChatStartedOutgoing"), _encryptionFirstName];
                else
                    _messageText = [[NSString alloc] initWithFormat:TGLocalized(@"DialogList.EncryptedChatStartedIncoming"), _encryptionFirstName];
            }
        }
    }
    
    _textView.text = _messageText;
    _textView.textColor = _messageTextColor;
    _textView.mediaIcon = _mediaIcon;
    
    int totalUnreadCount = 0;
    if (TGPeerIdIsChannel(_conversationId)) {
        totalUnreadCount = _unreadCount + _serviceUnreadCount;
    } else {
        totalUnreadCount = _unreadCount + _serviceUnreadCount;
    }

    if (totalUnreadCount) {
        _unreadCountBackgrond.hidden = false;
        _unreadCountLabel.hidden = false;
        _pinnedBackgrond.hidden = true;
        
        if (TGIsLocaleArabic())
        {
            _unreadCountLabel.text = [TGStringUtils stringWithLocalizedNumberCharacters:[[NSString alloc] initWithFormat:@"%d", totalUnreadCount]];
        }
        else
        {
            if (totalUnreadCount < 1000)
                _unreadCountLabel.text = [[NSString alloc] initWithFormat:@"%d", totalUnreadCount];
            else
                _unreadCountLabel.text = [[NSString alloc] initWithFormat:@"%dK", totalUnreadCount / 1000];
        }
    }
    else
    {
        _unreadCountBackgrond.hidden = true;
        _unreadCountLabel.hidden = true;
        
        _pinnedBackgrond.hidden = !_pinnedToTop;
    }
    
    if (_deliveryState == TGMessageDeliveryStateFailed)
    {
        _unreadCountBackgrond.hidden = true;
        _unreadCountLabel.hidden = true;
        _pinnedBackgrond.hidden = true;
        
        if (_deliveryErrorBackgrond == nil)
        {
            static UIImage *unsentImage = nil;
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                unsentImage = [[UIImage imageNamed:@"ModernConversationListBadgeUnsent.png"] preloadedImageWithAlpha];
            });
            _deliveryErrorBackgrond = [[UIImageView alloc] initWithImage:unsentImage];
            [_wrapView addSubview:_deliveryErrorBackgrond];
        }
        else if (_deliveryErrorBackgrond.superview == nil)
            [_wrapView addSubview:_deliveryErrorBackgrond];
    }
    else if (_deliveryErrorBackgrond != nil && _deliveryErrorBackgrond.superview != nil)
    {
        [_deliveryErrorBackgrond removeFromSuperview];
    }
    
    _textView.authorName = _hideAuthorName ? nil : _authorName;
    _textView.authorNameColor = [UIColor blackColor];
    
    if (_draft != nil && ![_draft isEmpty] && totalUnreadCount == 0) {
        _textView.text = _draft.text;
        _textView.textColor = _messageTextColor;
        _textView.authorName = TGLocalized(@"DialogList.Draft");
        _hideAuthorName = false;
        _authorName = _textView.authorName;
        _textView.authorNameColor = UIColorRGB(0xdd4b39);
    }
        
    _avatarView.hidden = false;
    
    static UIImage *placeholder = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        //!placeholder
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(62.0f, 62.0f), false, 0.0f);
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
        CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, 62.0f, 62.0f));
        CGContextSetStrokeColorWithColor(context, UIColorRGB(0xd9d9d9).CGColor);
        CGContextSetLineWidth(context, 1.0f);
        CGContextStrokeEllipseInRect(context, CGRectMake(0.5f, 0.5f, 61.0f, 61.0f));
        
        placeholder = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    });
    
    if (_avatarUrl.length != 0)
    {
        _avatarView.fadeTransitionDuration = keepState ? 0.3 : 0.14;
        
        if (![_avatarView.currentUrl isEqualToString:_avatarUrl])
        {
            if (keepState)
            {
                [_avatarView loadImage:_avatarUrl filter:@"circle:62x62" placeholder:(_avatarView.currentImage != nil ? _avatarView.currentImage : placeholder) forceFade:true];
            }
            else
            {
                [_avatarView loadImage:_avatarUrl filter:@"circle:62x62" placeholder:placeholder forceFade:false];
            }
        }
    }
    else
    {
        _avatarView.fadeTransitionDuration = 0.14;
        
        if (_isEncrypted || _conversationId > 0)
        {
            NSString *firstName = nil;
            NSString *lastName = nil;
            if (_titleLetters.count >= 2)
            {
                firstName = _titleLetters[0];
                lastName = _titleLetters[1];
            }
            else if (_titleLetters.count == 1)
                firstName = _titleLetters[0];
            
            [_avatarView loadUserPlaceholderWithSize:CGSizeMake(62.0f, 62.0f) uid:_isEncrypted ? _encryptedUserId : (int32_t)_conversationId firstName:firstName lastName:lastName placeholder:placeholder];
        }
        else
        {
            [_avatarView loadGroupPlaceholderWithSize:CGSizeMake(62.0f, 62.0f) conversationId:_conversationId title:_isBroadcast ? @"" : _titleText placeholder:placeholder];
        }
    }
    
    _textView.isMultichat = _isGroupChat;
    _textView.isEncrypted = _isEncrypted;
    
    _dateLabel.dateText = _dateString;
    
    _validSize = CGSizeZero;
    
    [_textView setNeedsDisplay];
    
    if (_editingIsActive)
    {
        _editingIsActive = false;
    }
    
    if (_outgoing && (_draft == nil || [_draft isEmpty] || totalUnreadCount != 0)) {
        if (_deliveryState == TGMessageDeliveryStateDelivered && !_unread)
        {
            _deliveredCheckmark.hidden = true;
            _readCheckmark.hidden = false;
        }
        else if (_deliveryState == TGMessageDeliveryStateDelivered && _unread)
        {
            _deliveredCheckmark.hidden = false;
            _readCheckmark.hidden = true;
        }
        else
        {
            _deliveredCheckmark.hidden = true;
            _readCheckmark.hidden = true;
        }
        
        if (_deliveryState == TGMessageDeliveryStatePending)
        {
            if (_pendingIndicator == nil)
            {
                static UIImage *pendingImage = nil;
                static dispatch_once_t onceToken;
                dispatch_once(&onceToken, ^{
                    pendingImage = [[UIImage imageNamed:@"DialogListPending.png"] preloadedImageWithAlpha];
                });
                
                _pendingIndicator = [[UIImageView alloc] initWithImage:pendingImage];
                [_wrapView addSubview:_pendingIndicator];
            }
            
            _pendingIndicator.hidden = false;
        }
        else
        {
            _pendingIndicator.hidden = true;
        }
    }
    else
    {
        _deliveredCheckmark.hidden = true;
        _readCheckmark.hidden = true;
        
        _pendingIndicator.hidden = true;
    }
    
    if (_isMuted)
    {
        if (_muteIcon == nil)
        {
            static UIImage *muteIcon = nil;
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                muteIcon = [[UIImage imageNamed:@"DialogList_Muted.png"] preloadedImageWithAlpha];
            });
            _muteIcon = [[UIImageView alloc] initWithImage:muteIcon];
        }
        
        if (_muteIcon.superview == nil)
            [_wrapView addSubview:_muteIcon];
    }
    else if (_muteIcon != nil)
    {
        [_muteIcon removeFromSuperview];
    }
    
    if (_unreadCountBackgrond != nil && totalUnreadCount > 0)
    {
        UIImage *unreadBackground = _isMuted ? _unreadMutedBackgroundImage : _unreadBackgroundImage;
        if (_unreadCountBackgrond.image != unreadBackground)
            _unreadCountBackgrond.image = unreadBackground;
    }
    
    if (_isVerified) {
        if (_verifiedIcon == nil) {
            static UIImage *verifiedImage = nil;
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                verifiedImage = [[UIImage imageNamed:@"ChannelVerifiedIconSmall.png"] preloadedImageWithAlpha];
            });
            _verifiedIcon = [[UIImageView alloc] initWithImage:verifiedImage];
        }
        if (_verifiedIcon.superview == nil) {
            [_wrapView addSubview:_verifiedIcon];
        }
    } else if (_verifiedIcon != nil && _verifiedIcon.superview != nil) {
        [_verifiedIcon removeFromSuperview];
    }
    
    [self setNeedsLayout];
}

- (void)dismissEditingControls:(bool)__unused animated
{
}

- (void)setIsLastCell:(bool)isLastCell {
    if (_isLastCell != isLastCell) {
        _isLastCell = isLastCell;
        [self setNeedsLayout];
    }
}

- (void)layoutSubviews
{
#undef TG_TIMESTAMP_DEFINE
#undef TG_TIMESTAMP_MEASURE
    
#define TG_TIMESTAMP_DEFINE(x)
#define TG_TIMESTAMP_MEASURE(x)
    
    TG_TIMESTAMP_DEFINE(cellLayout);
    
    TG_TIMESTAMP_MEASURE(cellLayout);
    
    [super layoutSubviews];
    
    CGFloat contentOffset = self.contentView.frame.origin.x;
    
    if ((_disableActions || contentOffset > FLT_EPSILON) && [_wrapView isExpanded]) {
        [_wrapView setExpanded:false animated:false];
    }
    [_wrapView setExpandable:contentOffset <= FLT_EPSILON || _disableActions];
    
    static Class separatorClass = nil;
    static dispatch_once_t onceToken2;
    dispatch_once(&onceToken2, ^{
        separatorClass = NSClassFromString(TGEncodeText(@"`VJUbcmfWjfxDfmmTfqbsbupsWjfx", -1));
    });
    for (UIView *subview in self.subviews) {
        if (subview.class == separatorClass) {
            CGRect frame = subview.frame;
            if (_isLastCell) {
                frame.size.width = self.bounds.size.width;
                frame.origin.x = 0.0f;
            } else {
                if (contentOffset > FLT_EPSILON) {
                    frame.size.width = self.bounds.size.width - 116.0f;
                    frame.origin.x = 116.0f;
                } else {
                    frame.size.width = self.bounds.size.width - 80.0f;
                    frame.origin.x = 80.0f;
                }
            }
            if (!CGRectEqualToRect(subview.frame, frame)) {
                subview.frame = frame;
            }
            break;
        }
    }
    
    TG_TIMESTAMP_MEASURE(cellLayout);
    
    CGFloat separatorHeight = TGScreenPixel;
    
    CGSize rawSize = self.frame.size;
    
    UIView *selectedView = self.selectedBackgroundView;
    if (selectedView != nil) {
        selectedView.frame = CGRectMake(0, -separatorHeight, selectedView.frame.size.width, rawSize.height + separatorHeight);
    }
    
    TG_TIMESTAMP_MEASURE(cellLayout);
    
    self.backgroundView.frame = CGRectMake(0.0f, 0.0f, rawSize.width, rawSize.height);
    
    static CGSize screenSize;
    static CGFloat widescreenWidth;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        screenSize = TGScreenSize();
        widescreenWidth = MAX(screenSize.width, screenSize.height);
    });
    
    if (contentOffset > FLT_EPSILON && _pinnedToTop) {
        if (_pinnedBackgrond.alpha >= FLT_EPSILON) {
            _pinnedBackgrond.alpha = 0.0f;
            _unreadCountBackgrond.alpha = 0.0f;
            _dateLabel.alpha = 0.0f;
            _readCheckmark.alpha = 0.0f;
            _deliveredCheckmark.alpha = 0.0f;
            _unreadCountLabel.alpha = 0.0f;
        }
    } else if (_pinnedBackgrond.alpha <= 1.0f - FLT_EPSILON) {
        _pinnedBackgrond.alpha = 1.0f;
        _unreadCountBackgrond.alpha = 1.0f;
        _dateLabel.alpha = 1.0f;
        _readCheckmark.alpha = 1.0f;
        _deliveredCheckmark.alpha = 1.0f;
        _unreadCountLabel.alpha = 1.0f;
    }
    
    CGSize size = rawSize;
    if (!TGIsPad())
    {
        if (rawSize.width >= widescreenWidth - FLT_EPSILON)
            size.width = screenSize.height - contentOffset;
        else
            size.width = screenSize.width - contentOffset;
    }
    else
        size.width = rawSize.width - contentOffset;
    
    TG_TIMESTAMP_MEASURE(cellLayout);
    
    CGFloat separatorOffset = 80.0f;
    
    if (_separatorLayer != nil) {
        bool disabledActions = [CATransaction disableActions];
        [CATransaction setDisableActions:true];
        _separatorLayer.frame = CGRectMake(separatorOffset, size.height - separatorHeight, rawSize.width - separatorOffset + 256.0f, separatorHeight);
        [CATransaction setDisableActions:disabledActions];
    }
    
    _wrapView.frame = CGRectMake(contentOffset, 0.0f, size.width, size.height);
    
    if (!CGSizeEqualToSize(_validSize, size))
    {
        if (_textView != nil)
        {
            if (!CGSizeEqualToSize(_textView.frame.size, CGRectMake(79.0f, 6, size.width - 79.0f, 62).size))
            {
                _textView.frame = CGRectMake(80.0f, 6, size.width - 80.0f, 62);
                [_textView setNeedsDisplay];
            }
        }
        
        int rightPadding = 0.0f;
        
        CGFloat countTextWidth = [_unreadCountLabel.text sizeWithFont:_unreadCountLabel.font].width;
        
        CGFloat backgroundWidth = MAX(20.0f, countTextWidth + 11.0f);
        CGRect unreadCountBackgroundFrame = CGRectMake(size.width - 11.0f - backgroundWidth, 38.0f, backgroundWidth, 20.0f);
        _unreadCountBackgrond.frame = unreadCountBackgroundFrame;
        _pinnedBackgrond.frame = CGRectMake(size.width - 11.0f - 20.0f, 38.0f, 20.0f, 20.0f);
        CGRect unreadCountLabelFrame = _unreadCountLabel.frame;
        unreadCountLabelFrame.origin = CGPointMake(unreadCountBackgroundFrame.origin.x + TGRetinaFloor(((unreadCountBackgroundFrame.size.width - countTextWidth) / 2.0f)) - (TGIsRetina() ? 0.0f : 0.0f), unreadCountBackgroundFrame.origin.y + 1.0f -TGRetinaPixel);
        _unreadCountLabel.frame = unreadCountLabelFrame;
        
        TG_TIMESTAMP_MEASURE(cellLayout);
        
        if (!_unreadCountBackgrond.hidden || !_pinnedBackgrond.hidden)
            rightPadding += unreadCountBackgroundFrame.size.width + 16;
        
        if (_deliveryErrorBackgrond != nil && _deliveryErrorBackgrond.superview != nil)
        {
            CGRect deliveryErrorFrame = _deliveryErrorBackgrond.frame;
            deliveryErrorFrame = CGRectMake(size.width - 14.0f - TGRetinaPixel - deliveryErrorFrame.size.width, 38.0f + TGRetinaPixel, deliveryErrorFrame.size.width, deliveryErrorFrame.size.height);
            _deliveryErrorBackgrond.frame = deliveryErrorFrame;
            
            rightPadding += 36;
        }
        
        CGSize dateTextSize = [_dateLabel measureTextSize];
        
        CGFloat dateWidth = _date == 0 ? 0 : (int)(dateTextSize.width);
        CGRect dateFrame = CGRectMake(size.width - dateWidth - 11.0f + (contentOffset > FLT_EPSILON ? 4.0f : 0.0f), 10.0f + TGRetinaPixel - (TGIsPad() ? 1.0f : 0.0f), 75, 20);
        _dateLabel.frame = dateFrame;
        CGFloat titleLabelWidth = (int)(dateFrame.origin.x - 4 - 80.0f - 18);
        CGFloat groupChatIconWidth = 0.0f;
        if (_isEncrypted)
        {
            groupChatIconWidth = 15;
            titleLabelWidth -= groupChatIconWidth;
        }
        else if (false && _isGroupChat)
        {
            groupChatIconWidth = 22;
            titleLabelWidth -= groupChatIconWidth;
        }
        
        if (_isMuted)
            titleLabelWidth -= 12;
        
        if (_isVerified) {
            titleLabelWidth -= _verifiedIcon.frame.size.width + 10.0f;
        }
        
        titleLabelWidth = MIN(titleLabelWidth, [_titleText sizeWithFont:_textView.titleFont].width);
        
        TG_TIMESTAMP_MEASURE(cellLayout);
        
        _deliveredCheckmark.frame = CGRectMake(dateFrame.origin.x - 16, 13.0f, 14, 11);
        _readCheckmark.frame = CGRectMake(dateFrame.origin.x - 20, 13.0f, 18, 11);
        
        if (_pendingIndicator != nil)
            _pendingIndicator.frame = CGRectMake(dateFrame.origin.x - 16, 13, 12, 12);
        
        CGRect titleRect = CGRectMake(80.0f + groupChatIconWidth, 8.0f, titleLabelWidth, 20);
        
        CGRect messageRect = CGRectMake(80.0f, 30.0f - TGRetinaPixel, size.width - 80.0f - 7.0f - rightPadding, 40);
        
        CGRect typingRect = messageRect;
        typingRect.size.width -= 12;
        if (TGIsRTL())
            typingRect.origin.x += 12.0f;
        _textView.typingFrame = typingRect;
        
        if (_typingDotsContainer.superview != nil)
        {
            CGSize typingSize = [_textView.typingText sizeWithFont:_textView.textFont constrainedToSize:typingRect.size lineBreakMode:NSLineBreakByTruncatingTail];
            
            CGRect typingDotsFrame = _typingDotsContainer.frame;
            typingDotsFrame.origin.x = TGIsRTL() ? messageRect.origin.x : (typingRect.origin.x + typingSize.width);
            typingDotsFrame.origin.y = typingRect.origin.y + 4;
            _typingDotsContainer.frame = typingDotsFrame;
        }
        
        if (_authorName != nil && !_hideAuthorName)
        {
            _textView.authorNameFrame = CGRectMake(80.0f, 29.0f + TGRetinaPixel, size.width - 80.0f - 4.0f - rightPadding, 20);
            
            messageRect.origin.y += iosMajorVersion() >= 7 ? (10 + TGRetinaPixel) : 17;
            messageRect.size.height -= 12;
        }
        
        TG_TIMESTAMP_MEASURE(cellLayout);
        
        titleRect.size.width = titleLabelWidth;
        
        if (_authorName != nil && !_hideAuthorName && [_messageText sizeWithFont:_textView.textFont constrainedToSize:messageRect.size].height < 20)
            messageRect.origin.y += 9;
        
        if (_isVerified) {
            CGRect verifiedRect = _verifiedIcon.bounds;
            verifiedRect.origin = CGPointMake(titleRect.origin.x + titleRect.size.width + 4.0f, titleRect.origin.y + 4 - TGRetinaPixel);
            _verifiedIcon.frame = verifiedRect;
        }
        
        if (_isMuted)
        {
            CGRect muteRect = _muteIcon.frame;
            muteRect.origin = CGPointMake(titleRect.origin.x + titleRect.size.width + 3, titleRect.origin.y + 6);
            if (_isVerified) {
                muteRect.origin.x += _verifiedIcon.bounds.size.width + 7.0f;
            }
            _muteIcon.frame = muteRect;
        }
        
        _textView.titleFrame = titleRect;
        _textView.textFrame = messageRect;
    
        _validSize = size;
        
        TG_TIMESTAMP_MEASURE(cellLayout);
    }
}

#pragma mark -

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    bool wasEditing = self.isEditing;
    [super setEditing:editing animated:animated];
    if (animated && wasEditing != editing) {
        UIView *snapshotWrappingView = [[UIView alloc] initWithFrame:_wrapView.bounds];
        snapshotWrappingView.backgroundColor = self.backgroundColor;
        UIView *snapshotView = [_textView snapshotViewAfterScreenUpdates:false];
        snapshotView.frame = _textView.frame;
        [snapshotWrappingView addSubview:snapshotView];
        [_wrapView insertSubview:snapshotWrappingView aboveSubview:_textView];
        [UIView animateWithDuration:0.3 animations:^{
            snapshotWrappingView.alpha = 0.0f;
        } completion:^(__unused BOOL finished) {
            [snapshotWrappingView removeFromSuperview];
        }];
    }
}

- (bool)showingDeleteConfirmationButton
{
    return false;
}

- (bool)isEditingControlsExpanded {
    return [_wrapView isExpanded];
}

- (void)setEditingConrolsExpanded:(bool)expanded animated:(bool)animated {
    [_wrapView setExpanded:expanded animated:animated];
}

- (void)resetLocalization
{
    _dateLabel.dateText = @"";
}

- (UIView *)avatarSnapshotView
{
    return [_avatarView snapshotViewAfterScreenUpdates:false];
}

- (CGRect)avatarFrame
{
    CGRect frame = self.bounds;
    frame.size.width = CGRectGetMaxX(_avatarView.frame) + _avatarView.frame.origin.x;
    
    return frame;
}

- (CGRect)textContentFrame
{
    return self.bounds;
}

@end
