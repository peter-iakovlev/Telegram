#import "TGModernConversationAssociatedInputPanel.h"

@class TGMessage;

@interface TGModenConcersationReplyAssociatedPanel : TGModernConversationAssociatedInputPanel

@property (nonatomic, strong) NSString *customTitle;
@property (nonatomic, strong, readonly) TGMessage *message;
@property (nonatomic) UIEdgeInsets lineInsets;
@property (nonatomic) bool largeDismissButton;

@property (nonatomic, copy) void (^pressed)();
@property (nonatomic, copy) void (^dismiss)();

- (instancetype)initWithMessage:(TGMessage *)message;

- (void)updateMessage:(TGMessage *)message;

- (void)setTitleFont:(UIFont *)titleFont;

@end
