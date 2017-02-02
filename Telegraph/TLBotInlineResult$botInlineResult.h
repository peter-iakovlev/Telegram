#import "TLBotInlineResult.h"

@class TLBotInlineMessage;

@interface TLBotInlineResult$botInlineResult : TLBotInlineResult

@property (nonatomic) int32_t flags;
@property (nonatomic, strong) NSString *n_id;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *n_description;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *thumb_url;
@property (nonatomic, strong) NSString *content_url;
@property (nonatomic, strong) NSString *content_type;
@property (nonatomic) int32_t w;
@property (nonatomic) int32_t h;
@property (nonatomic) int32_t duration;
@property (nonatomic, strong) TLBotInlineMessage *send_message;

@end
