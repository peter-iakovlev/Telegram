#import "TLmessages_BotResults.h"

@class TLInlineBotSwitchPM;

@interface TLMessages_BotResults$botResults : TLmessages_BotResults

@property (nonatomic) int32_t flags;
@property (nonatomic, readonly) bool isMedia;
@property (nonatomic) int64_t query_id;
@property (nonatomic, strong) NSString *next_offset;
@property (nonatomic, strong) TLInlineBotSwitchPM *switch_pm;
@property (nonatomic, strong) NSArray *results;
@property (nonatomic) int32_t cache_time;

@end
