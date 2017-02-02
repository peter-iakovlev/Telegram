#import "TGModernConversationTitlePanel.h"

@class TGMessage;

@interface TGPinnedMessageTitlePanel : TGModernConversationTitlePanel

@property (nonatomic, readonly) TGMessage *message;
@property (nonatomic, copy) void (^dismiss)();
@property (nonatomic, copy) void (^tapped)();

- (instancetype)initWithMessage:(TGMessage *)message;

- (void)updateMessage:(TGMessage *)message;

@end
