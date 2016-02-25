#import "TGModernConversationAssociatedInputPanel.h"

@class TGBotContextResults;
@class TGBotContextResult;
@class TGWebPageMediaAttachment;
@class TGBotContextResultAttachment;

@interface TGModernConversationGenericContextResultsAssociatedPanel : TGModernConversationAssociatedInputPanel

@property (nonatomic, copy) void (^resultSelected)(TGBotContextResults *results, TGBotContextResult *result);
@property (nonatomic, copy) void (^previewWebpage)(NSString *url, bool isEmbed, CGSize embedSize);

- (void)setResults:(TGBotContextResults *)results;

@end
