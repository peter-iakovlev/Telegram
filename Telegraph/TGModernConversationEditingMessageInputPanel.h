#import "TGModernConversationAssociatedInputPanel.h"

@class TGMessage;

@interface TGModernConversationEditingMessageInputPanel : TGModernConversationAssociatedInputPanel

@property (nonatomic, strong) NSString *customTitle;
@property (nonatomic, strong, readonly) TGMessage *message;
@property (nonatomic) UIEdgeInsets lineInsets;
@property (nonatomic) bool largeDismissButton;
@property (nonatomic) bool displayProgress;

@property (nonatomic, copy) void (^dismiss)();
@property (nonatomic, copy) void (^tap)();

- (instancetype)initWithMessage:(TGMessage *)message;

- (void)updateMessage:(TGMessage *)message;

- (void)setTitleFont:(UIFont *)titleFont;

@end
