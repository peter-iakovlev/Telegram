#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@interface TLFeedBroadcasts : NSObject <TLObject>

@end

@interface TLFeedBroadcasts$feedBroadcasts : TLFeedBroadcasts

@property (nonatomic) int32_t feed_id;
@property (nonatomic, strong) NSArray *channels;

@end

@interface TLFeedBroadcasts$feedBroadcastsUngrouped : TLFeedBroadcasts

@property (nonatomic, strong) NSArray *channels;

@end
