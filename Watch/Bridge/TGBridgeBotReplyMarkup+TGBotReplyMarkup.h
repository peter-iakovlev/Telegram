#import "TGBridgeBotReplyMarkup.h"

@class TGBotReplyMarkup;
@class TGMessage;

@interface TGBridgeBotReplyMarkup (TGBotReplyMarkup)

+ (TGBridgeBotReplyMarkup *)botReplyMarkupWithTGBotReplyMarkup:(TGBotReplyMarkup *)botReplyMarkup message:(TGMessage *)message;

@end
