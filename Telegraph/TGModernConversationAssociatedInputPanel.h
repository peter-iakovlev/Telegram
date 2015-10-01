#import <UIKit/UIKit.h>

typedef enum
{
    TGModernConversationAssociatedInputPanelDefaultStyle,
    TGModernConversationAssociatedInputPanelDarkStyle
} TGModernConversationAssociatedInputPanelStyle;

@interface TGModernConversationAssociatedInputPanel : UIView

@property (nonatomic, readonly) TGModernConversationAssociatedInputPanelStyle style;
@property (nonatomic, copy) void (^preferredHeightUpdated)();

- (CGFloat)preferredHeight;
- (void)setNeedsPreferredHeightUpdate;

- (void)setSendAreaWidth:(CGFloat)sendAreaWidth attachmentAreaWidth:(CGFloat)attachmentAreaWidth;

- (instancetype)initWithStyle:(TGModernConversationAssociatedInputPanelStyle)style;

@end
