#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLmessages_FavedStickers : NSObject <TLObject>


@end

@interface TLmessages_FavedStickers$messages_favedStickersNotModified : TLmessages_FavedStickers


@end

@interface TLmessages_FavedStickers$messages_favedStickers : TLmessages_FavedStickers

@property (nonatomic) int32_t n_hash;
@property (nonatomic, retain) NSArray *packs;
@property (nonatomic, retain) NSArray *stickers;

@end

