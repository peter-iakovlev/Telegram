#import "TLBotInlineMessage.h"

@class TLReplyMarkup;

@interface TLBotInlineMessage$botInlineMessageText : TLBotInlineMessage

@property (nonatomic) int32_t flags;
@property (nonatomic, strong) NSString *message;
@property (nonatomic) bool no_webpage;
@property (nonatomic, strong) NSArray *entities;
@property (nonatomic, strong) TLReplyMarkup *reply_markup;

@end
