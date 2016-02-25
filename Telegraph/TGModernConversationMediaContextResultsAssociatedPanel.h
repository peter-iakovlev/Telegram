#import "TGModernConversationAssociatedInputPanel.h"

@class TGBotContextResults;
@class TGBotContextResult;
@class TGWebPageMediaAttachment;
@class TGBotContextResultAttachment;
@class TGExternalGifSearchResult;
@class TGExternalImageSearchResult;

@interface TGModernConversationMediaContextResultsAssociatedPanel : TGModernConversationAssociatedInputPanel

@property (nonatomic, copy) void (^resultSelected)(TGBotContextResults *results, TGBotContextResult *result);

- (void)setResults:(TGBotContextResults *)results reload:(bool)reload;

@end
