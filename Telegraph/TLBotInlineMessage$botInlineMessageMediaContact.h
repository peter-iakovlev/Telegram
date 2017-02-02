#import "TLBotInlineMessage.h"

@class TLReplyMarkup;

@interface TLBotInlineMessage$botInlineMessageMediaContact : TLBotInlineMessage

@property (nonatomic) int32_t flags;
@property (nonatomic, strong) NSString *phone_number;
@property (nonatomic, strong) NSString *first_name;
@property (nonatomic, strong) NSString *last_name;
@property (nonatomic, strong) TLReplyMarkup *reply_markup;

@end
