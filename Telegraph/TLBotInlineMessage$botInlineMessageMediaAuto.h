#import "TLBotInlineMessage.h"

@class TLReplyMarkup;

@interface TLBotInlineMessage$botInlineMessageMediaAuto : TLBotInlineMessage

@property (nonatomic) int32_t flags;
@property (nonatomic, strong) NSString *caption;
@property (nonatomic, strong) TLReplyMarkup *reply_markup;

@end
