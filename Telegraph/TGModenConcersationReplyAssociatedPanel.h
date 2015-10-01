#import "TGModernConversationAssociatedInputPanel.h"

@class TGMessage;

@interface TGModenConcersationReplyAssociatedPanel : TGModernConversationAssociatedInputPanel

@property (nonatomic, strong, readonly) TGMessage *message;

@property (nonatomic, copy) void (^dismiss)();

- (instancetype)initWithMessage:(TGMessage *)message;

@end
