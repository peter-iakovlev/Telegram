#import "TGModernConversationInputPanel.h"

@interface TGFeedConversationInputPanel : TGModernConversationInputPanel

@property (nonatomic, assign) NSInteger selectedSection;

@property (nonatomic, copy) void (^sectionChanged)(NSInteger);

@end
