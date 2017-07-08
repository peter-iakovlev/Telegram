#import "TGModernConversationInputPanel.h"

@interface TGModernConversationSearchInputPanel : TGModernConversationInputPanel

@property (nonatomic, copy) void (^next)();
@property (nonatomic, copy) void (^previous)();
@property (nonatomic, copy) void (^done)();
@property (nonatomic, copy) void (^calendar)();
@property (nonatomic) bool inProgress;
@property (nonatomic) bool isSearching;

- (void)setOffset:(NSUInteger)offset count:(NSUInteger)count;
- (void)setNone;

@end
