#import "TLBotInlineMessage.h"

@interface TLBotInlineMessage$botInlineMessageText : TLBotInlineMessage

@property (nonatomic) int32_t flags;
@property (nonatomic, strong) NSString *message;
@property (nonatomic) bool no_webpage;
@property (nonatomic, strong) NSArray *entities;

@end
