#import "TGModernConversationPrivateTitlePanel.h"

@interface TGModernConversationUpgradeStateTitlePanel : TGModernConversationPrivateTitlePanel

@property (nonatomic, copy) void (^rekey)();

- (void)setCurrentLayer:(NSUInteger)currentLayer keyId:(int64_t)keyId rekeySessionId:(int64_t)rekeySessionId canRekey:(bool)canRekey;

@end
