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

static UIImage *deliveredCheckmark()
{
    static UIImage *image = nil;
    if (image == nil)
    {
        image = [UIImage imageNamed:@"ModernConversationListIconDelivered.png"];
    }
    return image;
}

static UIImage *readCheckmark()
{
    static UIImage *image = nil;
    if (image == nil)
    {
        image = [UIImage imageNamed:@"ModernConversationListIconRead.png"];
    }
    return image;
}

static UIColor *normalTextColor = nil;
static UIColor *actionTextColor = nil;
static UIColor *mediaTextColor = nil;

@interface TGDialogListTextView : UIView
{
}

@property (nonatomic, strong) NSString *title;
@property (nonatomic) CGRect titleFrame;
@property (nonatomic, strong) UIFont *titleFont;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic) CGRect textFrame;
@property (nonatomic, strong) UIFont *textFont;
@property (nonatomic , strong) NSString *authorName;
@property (nonatomic) CGRect authorNameFrame;
@property (nonatomic, strong) UIFont *authorNameFont;

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
    static CGColorRef authorNameColor = nil;
    static UIColor *nAuthorNameColor = nil;
    if (titleColor == nil)
    {
        nTitleColor = [UIColor blackColor];
        titleColor = CGColorRetain([nTitleColor CGColor]);
        
        nEncryptedTitleColor = UIColorRGB(0x00a629);
        encryptedTitleColor = CGColorRetain([nEncryptedTitleColor CGColor]);
        
        nAuthorNameColor = [UIColor blackColor];
        authorNameColor = CGColorRetain([nAuthorNameColor CGColor]);
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
        if (multichatImage == nil)
            multichatImage = [UIImage imageNamed:@"ModernConversationListIconLock.png"];
        image = multichatImage;
        
        [image drawAtPoint:CGPointMake(1.0f, 6.0f) blendMode:kCGBlendModeNormal alpha:1.0f];
    }
    else if (false && _isMultichat)
    {
        UIImage *image = nil;
        
        static UIImage *multichatImage = nil;
        if (multichatImage == nil)
            multichatImage = [UIImage imageNamed:@"DialogListGroupChatIcon.png"];
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
            CGContextSetFillColorWithColor(context, authorNameColor);
            if (CGRectIntersectsRect(rect, authorNameFrame))
            {
                if (iosMajorVersion() >= 7)
                {
                    static NSDictionary *attributes = nil;
                    static dispatch_once_t onceToken;
                    dispatch_once(&onceToken, ^
                    {
                        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
                        style.lineBreakMode = NSLineBreakByTruncatingTail;
                        style.alignment = NSTextAlignmentLeft;
                        
                        attributes = @{
                            NSParagraphStyleAttributeName: style,
                            NSFontAttributeName: _authorNameFont,
                            NSForegroundColorAttributeName: nAuthorNameColor
                        };
                    });
                    
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

@interface TGDialogListCell ()
{
    CALayer *_separatorLayer;
    UIImageView *_avatarIconView;
}

@property (nonatomic, strong) UIView *wrapView;

@property (nonatomic, strong) TGDialogListTextView *textView;

@property (nonatomic, strong) TGLetteredAvatarView *avatarView;
@property (nonatomic, strong) UIImageView *authorAvatarStrokeView;

@property (nonatomic, strong) TGDateLabel *dateLabel;

@property (nonatomic, strong) UIImageView *unreadCountBackgrond;
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
        
        _separatorLayer = [[CALayer alloc] init];
        _separatorLayer.backgroundColor = TGSeparatorColor().CGColor;
        [self.layer addSublayer:_separatorLayer];
        
        _wrapView = [[UIView alloc] init];
        _wrapView.clipsToBounds = true;
        [self addSubview:_wrapView];
        
        UIView *selectedView = [[UIView alloc] init];
        selectedView.backgroundColor = TGSelectionColor();
        self.selectedBackgroundView = selectedView;
        
        _assetsSource = assetsSource;

        _textView = [[TGDialogListTextView alloc] initWithFrame:CGRectMake(73, 2, self.frame.size.width - 73, 46)];
        _textView.contentMode = UIViewContentModeLeft;
        _textView.titleFont = TGMediumSystemFontOfSize(16);
        _textView.textFont = TGSystemFontOfSize(15);
        _textView.authorNameFont = TGSystemFontOfSize(15);
        _textView.opaque = true;
        _textView.backgroundColor = [UIColor whiteColor];
        
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
        
        _avatarView = [[TGLetteredAvatarView alloc] initWithFrame:CGRectMake(10, 7 - TGRetinaPixel, 62 + TGRetinaPixel, 62 + TGRetinaPixel)];
        [_avatarView setSingleFontSize:35.0f doubleFontSize:21.0f useBoldFont:false];
        _avatarView.fadeTransition = fadeTransition;
        [_wrapView addSubview:_avatarView];
        
        _avatarIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"BroadcastLargeAvatarIcon.png"]];
        _avatarIconView.frame = (CGRect){{23.0f, 23.0f}, _avatarIconView.frame.size};
        _avatarIconView.hidden = true;
        [_wrapView addSubview:_avatarIconView];
        
        static UIImage *unreadBackground = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^
        {
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(20.0f, 20.0f), false, 0.0f);
            CGContextRef context = UIGraphicsGetCurrentContext();
            
            CGContextSetFillColorWithColor(context, UIColorRGB(0x0f94f3).CGColor);
            CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, 20.0f, 20.0f));
            
            unreadBackground = [UIGraphicsGetImageFromCurrentImageContext() stretchableImageWithLeftCapWidth:10.0f topCapHeight:0.0f];
            UIGraphicsEndImageContext();
        });
        
        _unreadCountBackgrond = [[UIImageView alloc] initWithImage:unreadBackground];
        
        [_wrapView addSubview:_unreadCountBackgrond];
        
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
            CGFloat separatorHeight = TGIsRetina() ? 0.5f : 1.0f;
            selectedView.frame = CGRectMake(0, -separatorHeight, selectedView.frame.size.width, self.frame.size.height + separatorHeight);
        }
        
        if (TGIsPad())
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
            CGFloat separatorHeight = TGIsRetina() ? 0.5f : 1.0f;
            selectedView.frame = CGRectMake(0, -separatorHeight, selectedView.frame.size.width, self.frame.size.height + separatorHeight);
        }
        
        if (TGIsPad())
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
        CGFloat separatorHeight = TGIsRetina() ? 0.5f : 1.0f;
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

- (void)resetView:(bool)keepState
{
    if (self.selectionStyle != UITableViewCellSelectionStyleBlue)
        self.selectionStyle = UITableViewCellSelectionStyleBlue;
    
    _avatarIconView.hidden = !_isBroadcast;
    
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
    _hideAuthorName = !_isGroupChat || _rawText;
    
    if (_messageAttachments != nil && _messageAttachments.count != 0)
    {
        for (TGMediaAttachment *attachment in _messageAttachments)
        {
            if (attachment.type == TGActionMediaAttachmentType)
            {
                TGActionMediaAttachment *actionAttachment = (TGActionMediaAttachment *)attachment;
                switch (actionAttachment.actionType)
                {
                    case TGMessageActionChatEditTitle:
                    {
                        if (TGPeerIdIsChannel(_conversationId)) {
                            _messageText = TGLocalized(@"Notification.RenamedChannel");
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
                            if ([(TGImageMediaAttachment *)[actionAttachment.actionData objectForKey:@"photo"] imageInfo] == nil) {
                                _messageText = TGLocalized(@"Channel.MessagePhotoRemoved");
                            } else {
                                _messageText = TGLocalized(@"Channel.MessagePhotoUpdated");
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
                        _messageText = TGLocalized(@"Notification.CreatedChannel");
                        _messageTextColor = actionTextColor;
                        attachmentFound = true;
                        
                        _hideAuthorName = true;
                        
                        break;
                    }
                    case TGMessageActionChannelCommentsStatusChanged:
                    {
                        _messageText = [actionAttachment.actionData[@"enabled"] boolValue] ? TGLocalized(@"Channel.NotificationCommentsEnabled") : TGLocalized(@"Channel.NotificationCommentsDisabled");
                        _messageTextColor = actionTextColor;
                        attachmentFound = true;
                        _hideAuthorName = true;
                        break;
                    }
                    case TGMessageActionChannelInviter:
                    {
                        TGUser *user = [_users objectForKey:@"author"];
                        if ([actionAttachment.actionData[@"uid"] intValue] == user.uid) {
                            _messageText = TGLocalized(@"Notification.ChannelInviterSelf");
                        } else {
                            _messageText = [[NSString alloc] initWithFormat:TGLocalized(@"Notification.ChannelInviter"), user.displayName];
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
                        _messageText = [[NSString alloc] initWithFormat:TGLocalized(@"Notification.SecretChatMessageScreenshot"), _encryptionFirstName];
                        
                        break;
                    }
                    default:
                        break;
                }
            }
            else if (attachment.type == TGImageMediaAttachmentType)
            {
                TGImageMediaAttachment *imageMediaAttachment = (TGImageMediaAttachment *)attachment;
                if (imageMediaAttachment.caption.length > 0)
                {
                    _messageText = imageMediaAttachment.caption;
                    _messageTextColor = normalTextColor;
                }
                else
                {
                    _messageText = TGLocalized(@"Message.Photo");
                    _messageTextColor = mediaTextColor;
                }
                attachmentFound = true;
                break;
            }
            else if (attachment.type == TGVideoMediaAttachmentType)
            {
                TGVideoMediaAttachment *videoMediaAttachment = (TGVideoMediaAttachment *)attachment;
                if (videoMediaAttachment.caption.length > 0)
                {
                    _messageText = videoMediaAttachment.caption;
                    _messageTextColor = normalTextColor;
                }
                else
                {
                    _messageText = TGLocalized(@"Message.Video");
                    _messageTextColor = mediaTextColor;
                }
                attachmentFound = true;
                break;
            }
            else if (attachment.type == TGLocationMediaAttachmentType)
            {
                _messageText = TGLocalized(@"Message.Location");
                _messageTextColor = mediaTextColor;
                attachmentFound = true;
                break;
            }
            else if (attachment.type == TGContactMediaAttachmentType)
            {
                _messageText = TGLocalized(@"Message.Contact");
                _messageTextColor = mediaTextColor;
                attachmentFound = true;
                break;
            }
            else if (attachment.type == TGDocumentMediaAttachmentType)
            {
                TGDocumentMediaAttachment *documentAttachment = (TGDocumentMediaAttachment *)attachment;
                
                bool isAnimated = false;
                CGSize imageSize = CGSizeZero;
                bool isSticker = false;
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
                    else if ([attribute isKindOfClass:[TGDocumentAttributeSticker class]])
                    {
                        isSticker = true;
                        stickerRepresentation = ((TGDocumentAttributeSticker *)attribute).alt;
                    }
                }
                
                if (isSticker)
                {
                    if (stickerRepresentation.length == 0)
                        _messageText = TGLocalized(@"Message.Sticker");
                    else
                        _messageText = [[NSString alloc] initWithFormat:@"%@ %@", stickerRepresentation, TGLocalized(@"Message.Sticker")];
                }
                else
                {
                    NSString *fileName = ((TGDocumentMediaAttachment *)attachment).fileName;
                    if (fileName.length != 0)
                        _messageText = fileName;
                    else
                        _messageText = TGLocalized(@"Message.File");
                    
                    _messageTextColor = mediaTextColor;
                    attachmentFound = true;
                }
                break;
            }
            else if (attachment.type == TGAudioMediaAttachmentType)
            {
                _messageText = TGLocalized(@"Message.Audio");
                _messageTextColor = mediaTextColor;
                attachmentFound = true;
                break;
            }
        }
    }
    
    if (!attachmentFound)
    {
        _messageTextColor = normalTextColor;
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
    
    int totalUnreadCount = 0;
    if (TGPeerIdIsChannel(_conversationId)) {
        totalUnreadCount = _unreadCount;
    } else {
        totalUnreadCount = _unreadCount + _serviceUnreadCount;
    }
    
    if (totalUnreadCount)
    {
        _unreadCountBackgrond.hidden = false;
        _unreadCountLabel.hidden = false;
        
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
    }
    
    if (_deliveryState == TGMessageDeliveryStateFailed)
    {
        _unreadCountBackgrond.hidden = true;
        _unreadCountLabel.hidden = true;
        
        if (_deliveryErrorBackgrond == nil)
        {
            _deliveryErrorBackgrond = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ModernConversationListBadgeUnsent.png"]];
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
            //[_avatarView loadImage:[[NSString alloc] initWithFormat:@"dialogListPlaceholder:%lld", _conversationId] filter:nil placeholder:[_assetsSource groupAvatarPlaceholderGeneric] forceFade:false];
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
    
    if (_outgoing)
    {
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
                if (pendingImage == nil)
                {
                    pendingImage = [UIImage imageNamed:@"DialogListPending.png"];
                }
                
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
            _muteIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"DialogList_Muted.png"]];
        }
        
        if (_muteIcon.superview == nil)
            [_wrapView addSubview:_muteIcon];
    }
    else if (_muteIcon != nil)
    {
        [_muteIcon removeFromSuperview];
    }
    
    if (_isVerified) {
        if (_verifiedIcon == nil) {
            _verifiedIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ChannelVerifiedIconSmall.png"]];
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

- (void)layoutSubviews
{
#undef TG_TIMESTAMP_DEFINE
#undef TG_TIMESTAMP_MEASURE
    
#define TG_TIMESTAMP_DEFINE(x)
#define TG_TIMESTAMP_MEASURE(x)
    
    TG_TIMESTAMP_DEFINE(cellLayout);
    
    TG_TIMESTAMP_MEASURE(cellLayout);
    
    [super layoutSubviews];
    
    TG_TIMESTAMP_MEASURE(cellLayout);
    
    CGFloat separatorHeight = TGIsRetina() ? 0.5f : 1.0f;
    
    CGSize rawSize = self.frame.size;
    
    UIView *selectedView = self.selectedBackgroundView;
    if (selectedView != nil)
        selectedView.frame = CGRectMake(0, -separatorHeight, selectedView.frame.size.width, rawSize.height + separatorHeight);
    
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
    
    CGFloat contentOffset = self.contentView.frame.origin.x;
    
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
    
    _separatorLayer.frame = CGRectMake(80.0f, size.height - separatorHeight, rawSize.width - 80.0f, separatorHeight);
    
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
        
        /*CGRect arrowFrame = _arrowView.frame;
        arrowFrame.origin.x = contentOffset > FLT_EPSILON ? (rawSize.width + 4.0f) : (size.width - 9.0f - _arrowView.frame.size.width);
        arrowFrame.origin.y = 12.0f;
        _arrowView.frame = arrowFrame;
        _arrowView.alpha = contentOffset > FLT_EPSILON ? 0.0f : 1.0f;*/
        
        int rightPadding = 0.0f;
        
        CGFloat countTextWidth = [_unreadCountLabel.text sizeWithFont:_unreadCountLabel.font].width;
        
        CGFloat backgroundWidth = MAX(20.0f, countTextWidth + 11.0f);
        CGRect unreadCountBackgroundFrame = CGRectMake(size.width - 11.0f - backgroundWidth, 38.0f, backgroundWidth, 20.0f);
        _unreadCountBackgrond.frame = unreadCountBackgroundFrame;
        CGRect unreadCountLabelFrame = _unreadCountLabel.frame;
        unreadCountLabelFrame.origin = CGPointMake(unreadCountBackgroundFrame.origin.x + TGRetinaFloor(((unreadCountBackgroundFrame.size.width - countTextWidth) / 2.0f)) - (TGIsRetina() ? 0.0f : 0.0f), unreadCountBackgroundFrame.origin.y + 1.0f -TGRetinaPixel);
        _unreadCountLabel.frame = unreadCountLabelFrame;
        
        TG_TIMESTAMP_MEASURE(cellLayout);
        
        if (!_unreadCountBackgrond.hidden)
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
        
        _deliveredCheckmark.frame = CGRectMake(dateFrame.origin.x - 15, 13.0f, 13, 11);
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
    [super setEditing:editing animated:animated];
}

- (bool)showingDeleteConfirmationButton
{
    return false;
}

- (void)resetLocalization
{
    _dateLabel.dateText = @"";
}

@end
