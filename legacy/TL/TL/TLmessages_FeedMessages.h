#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLFeedPosition;

@interface TLmessages_FeedMessages : NSObject <TLObject>

@end

@interface TLmessages_FeedMessages$messages_feedMessagesNotModified : TLmessages_FeedMessages

@end

@interface TLmessages_FeedMessages$messages_feedMessagesMeta : TLmessages_FeedMessages

@property (nonatomic) int32_t flags;
@property (nonatomic, strong) TLFeedPosition *max_position;
@property (nonatomic, strong) TLFeedPosition *min_position;
@property (nonatomic, strong) TLFeedPosition *read_max_position;
@property (nonatomic, strong) NSArray *messages;
@property (nonatomic, strong) NSArray *chats;
@property (nonatomic, strong) NSArray *users;

@end
