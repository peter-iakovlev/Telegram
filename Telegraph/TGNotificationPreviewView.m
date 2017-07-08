#import "TGNotificationPreviewView.h"
#import "TGNotificationView.h"

#import "TGFont.h"
#import "TGImageUtils.h"

#import "TGMessage.h"
#import "TGUser.h"
#import "TGConversation.h"
#import "TGPeerIdAdapter.h"

const UIEdgeInsets TGNotificationPreviewContentInset = { 0, 62, 0, 10 };

const CGFloat TGNotificationTitleTopPosition = 6.0f;
const CGFloat TGNotificationTitleMiddlePosition = 15.0f;
const CGFloat TGNotificationTextInterlineMargin = 17.0f;
const CGFloat TGNotificationTextHeaderMargin = 4.0f;

@implementation TGNotificationPreviewView

- (instancetype)initWithMessage:(TGMessage *)message conversation:(TGConversation *)conversation peers:(NSDictionary *)peers
{
    self = [super initWithFrame:CGRectZero];
    if (self != nil)
    {
        bool isSecretMessage = (conversation.encryptedData != nil);
        _conversationId = conversation.conversationId;
        _messageId = message.mid;
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = TGMediumSystemFontOfSize(14.0f);
        _titleLabel.numberOfLines = 1;
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.userInteractionEnabled = false;
        [self addSubview:_titleLabel];
        
        if (isSecretMessage)
        {
            _lockIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"NotificationLockIcon"]];
            _lockIcon.frame = CGRectOffset(_lockIcon.frame, -13, 2.5f);
            [_titleLabel addSubview:_lockIcon];
        }
        
        TGUser *user = peers[@"author"];
        if (!isSecretMessage && (conversation.isChat || conversation.isChannelGroup))
             _titleLabel.text = [NSString stringWithFormat:@"%@@%@", user.displayName, conversation.chatTitle];
        else if (conversation.isChannel)
            _titleLabel.text = conversation.chatTitle;
        else
            _titleLabel.text = user.displayName;
        
        _mediaIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 15, 15)];
        _mediaIcon.contentMode = UIViewContentModeCenter;
        _mediaIcon.hidden = true;
        [self addSubview:_mediaIcon];
        
        _textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _textLabel.backgroundColor = [UIColor clearColor];
        _textLabel.font = TGSystemFontOfSize(13);
        _textLabel.textColor = [UIColor whiteColor];
        _textLabel.numberOfLines = 0;
        [self addSubview:_textLabel];
        
        if (!isSecretMessage)
        {
            for (TGMediaAttachment *attachment in message.mediaAttachments)
            {
                if (attachment.type == TGReplyMessageMediaAttachmentType && _replyHeader == nil)
                {
                    _replyHeader = [[TGNotificationReplyHeaderView alloc] initWithAttachment:(TGReplyMessageMediaAttachment *)attachment peers:peers];
                    _replyHeader.alpha = 0.0f;
                    [self addSubview:_replyHeader];
                    
                    _headerHeight = TGNotificationReplyHeaderHeight + 4 + 4;
                }
                else if (attachment.type == TGForwardedMessageMediaAttachmentType)
                {
                    if (peers[@(((TGForwardedMessageMediaAttachment *)attachment).forwardPeerId)] != nil)
                    {
                        _forwardHeader = [[TGNotificationForwardHeaderView alloc] initWithAttachment:(TGForwardedMessageMediaAttachment *)attachment peers:peers];
                        _forwardHeader.alpha = 0.0f;
                        [self addSubview:_forwardHeader];
                        _headerHeight = TGNotificationReplyHeaderHeight + 4 + 4;
                    }
                }
            }
        }
        
        _hasExtraContent = true;
        _isPanable = true;
        _isIdle = true;
    }
    return self;
}

- (void)setIcon:(UIImage *)icon text:(NSString *)text
{
    icon = nil;
    
    _mediaIcon.image = (icon != nil) ? TGTintedImage(icon, [UIColor whiteColor]) : nil;
    _mediaIcon.hidden = (icon == nil);
    
    _textLabel.text = text;
    
    [self setNeedsLayout];
}

- (void)setExpandProgress:(CGFloat)__unused progress
{
    
}

- (void)_updateExpandProgress:(CGFloat)progress hideText:(bool)hideText
{
    CGFloat squareProgress = progress * progress;
    CGFloat cubicProgress = squareProgress * progress;
    
    _textLabel.alpha = !hideText ? 1.0f : MAX(0, 1.0f - squareProgress * 3.5f);
    _mediaIcon.alpha = _textLabel.alpha;
    _replyHeader.alpha = cubicProgress;
    _forwardHeader.alpha = cubicProgress;
}

- (bool)isExpandable
{
    return false;
}

- (bool)isPanableAtPoint:(CGPoint)point
{
    if (!self.isPanable)
        return !CGRectContainsPoint(_textLabel.bounds, [self convertPoint:point toView:_textLabel]);
    
    return true;
}

- (void)imageDataInvalidated:(NSString *)__unused imageUrl
{
    
}

- (void)updateMediaAvailability:(bool)__unused mediaIsAvailable
{
    
}

- (void)updateProgress:(bool)__unused progressVisible progress:(float)__unused progress animated:(bool)__unused animated
{
    
}

- (void)updateInlineMediaContext
{
    
}

- (CGFloat)maxContentHeight
{
    return 0;
}

- (CGFloat)expandedHeightForContainerSize:(CGSize)containerSize
{
    CGFloat textHeight = 0;
    
    if (CGSizeEqualToSize(_currentContainerSize, containerSize))
    {
        textHeight = _textHeight;
    }
    else
    {
        _currentContainerSize = containerSize;
        
        CGFloat width = containerSize.width - TGNotificationPreviewContentInset.left - TGNotificationPreviewContentInset.right;
        CGFloat offset = 0;
        if (!_mediaIcon.hidden)
        {
            offset = 30;
            width -= offset;
        }
        
        CGSize size = CGSizeZero;
        if (iosMajorVersion() >= 7)
        {
            size = [_textLabel.text boundingRectWithSize:CGSizeMake(width, FLT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingTruncatesLastVisibleLine attributes:@{ NSFontAttributeName: _textLabel.font } context:nil].size;
        }
        else
        {
            NSAttributedString *tmp = [[NSAttributedString alloc] initWithString:_textLabel.text attributes:@{ NSFontAttributeName: _textLabel.font }];
            size = [tmp boundingRectWithSize:CGSizeMake(width, FLT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingTruncatesLastVisibleLine context:nil].size;
        }
        
        _textHeight = ceil(size.height);
        textHeight = _textHeight;
        
        if (textHeight > 20)
            _collapsedTextHeight = 31.5f;
        else
            _collapsedTextHeight = textHeight;
    }
    
    CGFloat expandedHeight = _textHeight + _headerHeight;
    CGFloat maxContentHeight = [self maxContentHeight];
    if (maxContentHeight > FLT_EPSILON)
        expandedHeight = MIN(maxContentHeight, expandedHeight);
    
    return MAX(TGNotificationDefaultHeight - 5, expandedHeight + 31);
}

- (void)_layoutText
{
    CGFloat titleX = TGNotificationPreviewContentInset.left;
    if (_lockIcon != nil)
        titleX += 13;
    
    CGFloat textX = TGNotificationPreviewContentInset.left;
    CGFloat progress = _expandProgress;
    
    if (CGSizeEqualToSize(_currentContainerSize, CGSizeZero))
        [self expandedHeightForContainerSize:CGSizeMake(self.frame.size.width, [[[self superview] superview] superview].frame.size.height)];
    
    if (_textHeight > 20.0f)
        _titleStartPos = TGNotificationTitleTopPosition;
    else
        _titleStartPos = TGNotificationTitleMiddlePosition;
    
    _textStartPos = _titleStartPos + TGNotificationTextInterlineMargin;
    
    if (_textHeight < 20.0f && _headerHeight < FLT_EPSILON && !_hasExtraContent)
        _titleEndPos = TGNotificationTitleMiddlePosition;
    else
        _titleEndPos = TGNotificationTitleTopPosition;
    
    _textEndPos = _titleEndPos + TGNotificationTextInterlineMargin + _headerHeight;
    
    if (!_mediaIcon.hidden)
    {
        textX += 19;
        _mediaIcon.frame = CGRectMake(TGNotificationPreviewContentInset.left, 0, _mediaIcon.frame.size.width, _mediaIcon.frame.size.height);
    }
    
    CGFloat titleY = _titleStartPos + (_titleEndPos - _titleStartPos) * progress;
    CGFloat textY = _textStartPos + (_textEndPos - _textStartPos) * progress;
    
    _textLabel.frame = CGRectMake(textX, textY, self.frame.size.width - textX - 10, MIN(_textHeight, 31.5f));
    
    [_titleLabel sizeToFit];
    _titleLabel.frame = CGRectMake(titleX, titleY, self.frame.size.width - TGNotificationPreviewContentInset.left - TGNotificationPreviewContentInset.right, ceil(_titleLabel.frame.size.height));
}

- (void)_layoutHeaders
{
    CGFloat headerX = TGNotificationPreviewContentInset.left;
    CGFloat headerY = TGNotificationTitleTopPosition + TGNotificationTextInterlineMargin + TGNotificationTextHeaderMargin;
    CGFloat headerWidth = self.frame.size.width - headerX - TGNotificationPreviewContentInset.right;
    
    if (_replyHeader != nil)
        _replyHeader.frame = CGRectMake(headerX, headerY, headerWidth, TGNotificationReplyHeaderHeight);
    else if (_forwardHeader != nil)
        _forwardHeader.frame = CGRectMake(headerX, headerY, headerWidth, TGNotificationForwardHeaderHeight);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self _layoutText];
    [self _layoutHeaders];
}

@end
