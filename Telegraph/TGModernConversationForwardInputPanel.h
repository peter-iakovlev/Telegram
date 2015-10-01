#import "TGModernConversationAssociatedInputPanel.h"

@interface TGModernConversationForwardInputPanel : TGModernConversationAssociatedInputPanel

@property (nonatomic, strong) NSArray *messages;

@property (nonatomic, copy) void (^dismiss)();

- (instancetype)initWithMessages:(NSArray *)messages;

@end
