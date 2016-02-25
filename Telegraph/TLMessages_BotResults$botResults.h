#import "TLmessages_BotResults.h"

//messages.botResults flags:# query_id:long media:flags.0?true next_offset:flags.1?string results:Vector<BotContextResult> = messages.BotResults

@interface TLMessages_BotResults$botResults : TLmessages_BotResults

@property (nonatomic) int32_t flags;
@property (nonatomic, readonly) bool isMedia;
@property (nonatomic) int64_t query_id;
@property (nonatomic, strong) NSString *next_offset;
@property (nonatomic, strong) NSArray *results;

@end
