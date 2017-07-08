#import "TGCollectionMenuController.h"

#import "TGChannelManagementSignals.h"

@interface TGChannelAdminLogFilterController : TGCollectionMenuController

@property (nonatomic, copy) void (^completion)(TGChannelEventFilter filter, NSArray *usersFilter, bool allUsersSelected);

- (instancetype)initWithPeerId:(int64_t)peerId accessHash:(int64_t)accessHash isChannel:(bool)isChannel filter:(TGChannelEventFilter)filter usersFilter:(NSArray *)usersFilter;

@end
