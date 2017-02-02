#import "TGModernConversationTitlePanel.h"

@interface TGToastTitlePanel : TGModernConversationTitlePanel

@property (nonatomic, copy) void (^dismiss)();

- (instancetype)initWithText:(NSString *)text;

@end
