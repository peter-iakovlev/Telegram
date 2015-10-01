#import "TGNeoBubbleMessageViewModel.h"
#import "TGNeoBackgroundViewModel.h"

#import "TGColor.h"

#import "TGBridgeContext.h"
#import "TGBridgeMessage.h"
#import "TGBridgeUser.h"

#import "TGPeerIdAdapter.h"

const UIEdgeInsets TGNeoBubbleMessageViewModelInsets = { 4.5, 11, 9, 11 };
const CGFloat TGNeoBubbleMessageMetaSpacing = 5.0f;
const CGFloat TGNeoBubbleHeaderSpacing = 2.0f;

@interface TGNeoBubbleMessageViewModel ()
{
    TGNeoBackgroundViewModel *_backgroundModel;
}
@end

@implementation TGNeoBubbleMessageViewModel

- (instancetype)initWithMessage:(TGBridgeMessage *)message users:(NSDictionary *)users context:(TGBridgeContext *)context
{
    self = [super initWithMessage:message users:users context:context];
    if (self != nil)
    {
        self.showBubble = true;
        
        if (message.cid < 0 && !TGPeerIdIsChannel(message.cid) && !message.outgoing)
        {
            _authorNameModel = [[TGNeoLabelViewModel alloc] initWithText:[users[@(message.fromUid)] displayName] font:[UIFont systemFontOfSize:14] color:[TGColor colorForUserId:(int32_t)message.fromUid myUserId:context.userId] attributes:nil];
            [self addSubmodel:_authorNameModel];
        }
        
        TGBridgeForwardedMessageMediaAttachment *forwardAttachment = nil;
        TGBridgeReplyMessageMediaAttachment *replyAttachment = nil;
        for (TGBridgeMediaAttachment *attachment in message.media)
        {
            if ([attachment isKindOfClass:[TGBridgeForwardedMessageMediaAttachment class]])
                forwardAttachment = (TGBridgeForwardedMessageMediaAttachment *)attachment;
            else if ([attachment isKindOfClass:[TGBridgeReplyMessageMediaAttachment class]])
                replyAttachment = (TGBridgeReplyMessageMediaAttachment *)attachment;
        }
        
        if (forwardAttachment != nil)
        {
            _forwardHeaderModel = [[TGNeoForwardHeaderViewModel alloc] initWithForwardAttachment:forwardAttachment user:users[@(forwardAttachment.uid)] outgoing:message.outgoing];
            [self addSubmodel:_forwardHeaderModel];
        }
        
        if (replyAttachment != nil)
        {
            _replyHeaderModel = [[TGNeoReplyHeaderViewModel alloc] initWithReplyAttachment:replyAttachment users:users outgoing:message.outgoing];
            [self addSubmodel:_replyHeaderModel];
        }
    }
    return self;
}

- (CGSize)contentContainerSizeWithContainerSize:(CGSize)containerSize
{
    return CGSizeMake(containerSize.width - TGNeoBubbleMessageViewModelInsets.left - TGNeoBubbleMessageViewModelInsets.right, FLT_MAX);
}

- (CGSize)layoutHeaderModelsWithContainerSize:(CGSize)containerSize
{
    CGFloat textTopOffset = self.showBubble ? TGNeoBubbleMessageViewModelInsets.top : 0;
    CGFloat maxContentWidth = 0;
    if (self.authorNameModel != nil)
    {
        CGSize textSize = [self.authorNameModel contentSizeWithContainerSize:containerSize];
        self.authorNameModel.frame = CGRectMake(TGNeoBubbleMessageViewModelInsets.left, textTopOffset, textSize.width, 16.5f);
        textTopOffset += self.authorNameModel.frame.size.height;
            
        if (textSize.width > maxContentWidth)
            maxContentWidth = textSize.width;
    }
    
    if (self.replyHeaderModel != nil)
    {
        textTopOffset += TGNeoBubbleHeaderSpacing;
        
        CGSize headerSize = [self.replyHeaderModel contentSizeWithContainerSize:containerSize];
        self.replyHeaderModel.frame = CGRectMake(TGNeoBubbleMessageViewModelInsets.left, textTopOffset, headerSize.width, headerSize.height);
        if (headerSize.width > maxContentWidth)
            maxContentWidth = headerSize.width;
        
        textTopOffset += self.replyHeaderModel.frame.size.height + TGNeoBubbleHeaderSpacing;
        
        if (_replyHeaderModel.mediaAttachment != nil)
        {
            UIEdgeInsets inset = UIEdgeInsetsMake(self.replyHeaderModel.frame.origin.y + 1.5f, self.replyHeaderModel.frame.origin.x + TGNeoReplyHeaderLineWidth + TGNeoReplyHeaderSpacing, 0, 0);
            NSDictionary *imageDictionary = @{ TGNeoMessageReplyMediaAttachment: _replyHeaderModel.mediaAttachment };
            [self addAdditionalLayout:@{ TGNeoContentInset: [NSValue valueWithUIEdgeInsets:inset], TGNeoMessageReplyImageGroup: imageDictionary } withKey:TGNeoMessageHeaderGroup];
        }
    }
    
    if (self.forwardHeaderModel != nil)
    {
        textTopOffset += TGNeoBubbleHeaderSpacing;
        
        CGSize headerSize = [self.forwardHeaderModel contentSizeWithContainerSize:containerSize];
        self.forwardHeaderModel.frame = CGRectMake(TGNeoBubbleMessageViewModelInsets.left, textTopOffset, headerSize.width, headerSize.height);
        if (headerSize.width > maxContentWidth)
            maxContentWidth = headerSize.width;
        
        textTopOffset += self.forwardHeaderModel.frame.size.height + TGNeoBubbleHeaderSpacing;
    }
    
    return CGSizeMake(maxContentWidth, textTopOffset);
}

- (UIColor *)normalColorForMessage:(TGBridgeMessage *)message
{
    if (message.outgoing)
        return [UIColor whiteColor];
    else
        return [UIColor blackColor];
}

- (UIColor *)subtitleColorForMessage:(TGBridgeMessage *)message
{
    if (message.outgoing)
        return [UIColor hexColor:0xbeddf6];
    else
        return [UIColor hexColor:0x7e7e81];
}

- (UIColor *)accentColorForMessage:(TGBridgeMessage *)message
{
    if (message.outgoing)
        return [UIColor whiteColor];
    else
        return [UIColor hexColor:0x1f97f8];
}

- (CGSize)layoutWithContainerSize:(CGSize)containerSize
{
    self.contentSize = containerSize;
            
    return CGSizeZero;
}

@end
