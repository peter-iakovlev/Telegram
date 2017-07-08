#import "TGNotificationForwardHeaderView.h"
#import "TGForwardedMessageMediaAttachment.h"

#import "TGFont.h"

#import "TGUser.h"
#import "TGConversation.h"

const CGFloat TGNotificationForwardHeaderHeight = 29.0f;

@interface TGNotificationForwardHeaderView ()
{
    UILabel *_textLabel;
}
@end

@implementation TGNotificationForwardHeaderView

- (instancetype)initWithAttachment:(TGForwardedMessageMediaAttachment *)attachment peers:(NSDictionary *)peers
{
    self = [super initWithFrame:CGRectZero];
    if (self != nil)
    {
        _textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _textLabel.backgroundColor = [UIColor clearColor];
        _textLabel.font = TGSystemFontOfSize(13.0f);
        _textLabel.numberOfLines = 2;
        _textLabel.textColor = [UIColor whiteColor];
        [self addSubview:_textLabel];
        
        NSString *authorName = nil;
        id author = peers[@(attachment.forwardPeerId)];
        if ([author isKindOfClass:[TGUser class]])
            authorName = ((TGUser *)author).displayName;
        else if ([author isKindOfClass:[TGConversation class]])
            authorName = ((TGConversation *)author).chatTitle;
        
        NSString *text = [[NSString alloc] initWithFormat:TGLocalized(@"Message.ForwardedMessage"), authorName];
        _textLabel.text = text;
        
        [_textLabel sizeToFit];
        _textLabel.frame = CGRectMake(0, 0, ceil(_textLabel.frame.size.width), ceil(_textLabel.frame.size.height));
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _textLabel.frame = CGRectMake(0, -2, self.frame.size.width, _textLabel.frame.size.height);
}

@end
