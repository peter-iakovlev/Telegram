#import "TGModernConversationAssociatedInputPanel.h"

@class TGBotContextResults;
@class TGBotContextResult;
@class TGViewController;

@interface TGModernConversationGenericContextResultsAssociatedPanel : TGModernConversationAssociatedInputPanel

@property (nonatomic) int32_t botId;
@property (nonatomic, weak) TGViewController *controller;
@property (nonatomic, copy) void (^resultSelected)(TGBotContextResults *results, TGBotContextResult *result);
@property (nonatomic, copy) void (^activateSwitchPm)(NSString *startParam);
@property (nonatomic, copy) void (^onResultPreview)(void);

- (void)setResults:(TGBotContextResults *)results;

- (CGRect)tableBackgroundFrame;

- (CGPoint)centerPointForResult:(TGBotContextResult *)result;
- (CGRect)rectForResult:(TGBotContextResult *)result;

@end
