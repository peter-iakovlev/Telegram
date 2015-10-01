#import "TGModernConversationAssociatedInputPanel.h"

@class TGWebPageMediaAttachment;

@interface TGModernConversationWebPreviewInputPanel : TGModernConversationAssociatedInputPanel

@property (nonatomic, copy) void (^dismiss)();

- (void)setLink:(NSString *)link webPage:(TGWebPageMediaAttachment *)webPage;

@end
