#import <LegacyComponents/TGModernConversationAssociatedInputPanel.h>

@interface TGModernConversationForwardInputPanel : TGModernConversationAssociatedInputPanel

@property (nonatomic, strong) NSArray *messages;
@property (nonatomic, strong) NSSet *completeGroups;

@property (nonatomic, copy) void (^dismiss)();

- (instancetype)initWithMessages:(NSArray *)messages completeGroups:(NSSet *)completeGroups;

@end
