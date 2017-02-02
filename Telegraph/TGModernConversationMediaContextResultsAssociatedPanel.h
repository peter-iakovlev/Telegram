#import "TGModernConversationAssociatedInputPanel.h"

@class TGViewController;
@class TGBotContextResults;
@class TGBotContextResult;
@class TGWebPageMediaAttachment;
@class TGBotContextResultAttachment;
@class TGExternalGifSearchResult;
@class TGExternalImageSearchResult;

@interface TGModernConversationMediaContextResultsAssociatedPanel : TGModernConversationAssociatedInputPanel

@property (nonatomic) int32_t botId;

@property (nonatomic, weak) TGViewController *controller;
@property (nonatomic, copy) void (^resultSelected)(TGBotContextResults *results, TGBotContextResult *result);
@property (nonatomic, copy) void (^onResultPreview)(void);
@property (nonatomic, copy) void (^activateSwitchPm)(NSString *startParam);

- (void)setResults:(TGBotContextResults *)results reload:(bool)reload;

@end
