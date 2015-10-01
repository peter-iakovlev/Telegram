#import "TGModernConversationAssociatedInputPanel.h"

@implementation TGModernConversationAssociatedInputPanel

- (instancetype)initWithStyle:(TGModernConversationAssociatedInputPanelStyle)style
{
    _style = style;
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
    }
    return self;
}

- (CGFloat)preferredHeight
{
    return 75.0f;
}

- (void)setNeedsPreferredHeightUpdate
{
    if (_preferredHeightUpdated)
        _preferredHeightUpdated();
}

- (void)setSendAreaWidth:(CGFloat)__unused sendAreaWidth attachmentAreaWidth:(CGFloat)__unused attachmentAreaWidth
{
}

@end
