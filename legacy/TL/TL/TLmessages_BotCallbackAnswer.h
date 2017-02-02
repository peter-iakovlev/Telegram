#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLmessages_BotCallbackAnswer : NSObject <TLObject>

@property (nonatomic) int32_t flags;
@property (nonatomic, retain) NSString *message;
@property (nonatomic, retain) NSString *url;
@property (nonatomic) int32_t cache_time;

@end

@interface TLmessages_BotCallbackAnswer$messages_botCallbackAnswerMeta : TLmessages_BotCallbackAnswer


@end

