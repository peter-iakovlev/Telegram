#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLInlineBotSwitchPM;

@interface TLmessages_BotResults : NSObject <TLObject>

@property (nonatomic) int32_t flags;
@property (nonatomic) int64_t query_id;
@property (nonatomic, retain) NSString *next_offset;
@property (nonatomic, retain) TLInlineBotSwitchPM *switch_pm;
@property (nonatomic, retain) NSArray *results;
@property (nonatomic) int32_t cache_time;
@property (nonatomic, retain) NSArray *users;

@end

@interface TLmessages_BotResults$messages_botResultsMeta : TLmessages_BotResults


@end

