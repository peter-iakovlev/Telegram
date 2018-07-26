#import "TLBotInlineResult.h"

@class TLBotInlineMessage;
@class TLWebDocument;

@interface TLBotInlineResult$botInlineResult : TLBotInlineResult

@property (nonatomic) int32_t flags;
@property (nonatomic, strong) NSString *n_id;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *n_description;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) TLWebDocument *thumb;
@property (nonatomic, strong) TLWebDocument *content;
@property (nonatomic, strong) TLBotInlineMessage *send_message;

@end
