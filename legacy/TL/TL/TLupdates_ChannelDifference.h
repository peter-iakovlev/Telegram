#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLupdates_ChannelDifference : NSObject <TLObject>


@end

@interface TLupdates_ChannelDifference$updates_channelDifferenceMeta : TLupdates_ChannelDifference


@end

@interface TLupdates_ChannelDifference$updates_channelDifferenceTooLongMeta : TLupdates_ChannelDifference

@property (nonatomic) int32_t flags;
@property (nonatomic) int32_t pts;
@property (nonatomic) int32_t timeout;
@property (nonatomic) int32_t top_message;
@property (nonatomic) int32_t read_inbox_max_id;
@property (nonatomic) int32_t read_outbox_max_id;
@property (nonatomic) int32_t unread_count;
@property (nonatomic) int32_t unread_mentions_count;
@property (nonatomic, retain) NSArray *messages;
@property (nonatomic, retain) NSArray *chats;
@property (nonatomic, retain) NSArray *users;

@end

