#import "TGNeoTextMessageViewModel.h"
#import "TGNeoLabelViewModel.h"

#import "TGBridgeMessage.h"

@interface TGNeoTextMessageViewModel ()
{
    TGNeoLabelViewModel *_textModel;
}
@end

@implementation TGNeoTextMessageViewModel

- (instancetype)initWithMessage:(TGBridgeMessage *)message users:(NSDictionary *)users context:(TGBridgeContext *)context
{
    self = [super initWithMessage:message users:users context:context];
    if (self != nil)
    {
        NSString *text = [message.text stringByReplacingOccurrencesOfString:@"/" withString:@"/\u2060"];
        _textModel = [[TGNeoLabelViewModel alloc] initWithText:text font:[UIFont systemFontOfSize:16] color:[self normalColorForMessage:message] attributes:nil];
        [self addSubmodel:_textModel];
    }
    return self;
}
- (CGSize)layoutWithContainerSize:(CGSize)containerSize
{
    CGSize contentContainerSize = [self contentContainerSizeWithContainerSize:containerSize];
    
    CGSize headerSize = [self layoutHeaderModelsWithContainerSize:contentContainerSize];
    CGFloat maxContentWidth = headerSize.width;
    CGFloat textTopOffset = headerSize.height;
    
    CGSize textSize = [_textModel contentSizeWithContainerSize:contentContainerSize];
    _textModel.frame = CGRectMake(TGNeoBubbleMessageViewModelInsets.left, textTopOffset, textSize.width, textSize.height);
    
    if (textSize.width > maxContentWidth)
        maxContentWidth = textSize.width;
    
    CGSize contentSize = CGSizeZero;
    contentSize.width = maxContentWidth + TGNeoBubbleMessageViewModelInsets.left + TGNeoBubbleMessageViewModelInsets.right;
    contentSize.height = CGRectGetMaxY(_textModel.frame) + TGNeoBubbleMessageViewModelInsets.bottom;
    
    [super layoutWithContainerSize:contentSize];
    
    return contentSize;
}

@end
