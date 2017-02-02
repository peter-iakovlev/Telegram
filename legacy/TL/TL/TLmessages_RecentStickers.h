#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLmessages_RecentStickers : NSObject <TLObject>


@end

@interface TLmessages_RecentStickers$messages_recentStickersNotModified : TLmessages_RecentStickers


@end

@interface TLmessages_RecentStickers$messages_recentStickers : TLmessages_RecentStickers

@property (nonatomic) int32_t n_hash;
@property (nonatomic, retain) NSArray *stickers;

@end

