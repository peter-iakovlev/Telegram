#import <UIKit/UIKit.h>

typedef enum
{
    TGModernConversationAssociatedInputPanelDefaultStyle,
    TGModernConversationAssociatedInputPanelDarkStyle,
    TGModernConversationAssociatedInputPanelDarkBlurredStyle
} TGModernConversationAssociatedInputPanelStyle;

@interface TGModernConversationAssociatedInputPanel : UIView

@property (nonatomic, readonly) TGModernConversationAssociatedInputPanelStyle style;
@property (nonatomic, copy) void (^preferredHeightUpdated)();

- (CGFloat)preferredHeight;
- (bool)displayForTextEntryOnly;
- (void)setNeedsPreferredHeightUpdate;

- (void)setSendAreaWidth:(CGFloat)sendAreaWidth attachmentAreaWidth:(CGFloat)attachmentAreaWidth;

- (instancetype)initWithStyle:(TGModernConversationAssociatedInputPanelStyle)style;

- (void)selectPreviousItem;
- (void)selectNextItem;
- (void)commitSelectedItem;

@end
