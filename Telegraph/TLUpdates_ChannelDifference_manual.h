#import "TLupdates_ChannelDifference.h"

@interface TLUpdates_ChannelDifference$empty : TLupdates_ChannelDifference

@property (nonatomic) int32_t flags;
@property (nonatomic) int32_t pts;
@property (nonatomic) int32_t timeout;

@end

@interface TLUpdates_ChannelDifference$channelDifference : TLupdates_ChannelDifference

@property (nonatomic) int32_t flags;
@property (nonatomic) int32_t pts;
@property (nonatomic) int32_t timeout;
@property (nonatomic, strong) NSArray *n_new_messages;
@property (nonatomic, strong) NSArray *other_updates;
@property (nonatomic, strong) NSArray *chats;
@property (nonatomic, strong) NSArray *users;

@end
