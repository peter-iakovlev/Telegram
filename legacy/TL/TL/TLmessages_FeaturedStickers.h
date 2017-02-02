#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLmessages_FeaturedStickers : NSObject <TLObject>


@end

@interface TLmessages_FeaturedStickers$messages_featuredStickersNotModified : TLmessages_FeaturedStickers


@end

@interface TLmessages_FeaturedStickers$messages_featuredStickers : TLmessages_FeaturedStickers

@property (nonatomic) int32_t n_hash;
@property (nonatomic, retain) NSArray *sets;
@property (nonatomic, retain) NSArray *unread;

@end

