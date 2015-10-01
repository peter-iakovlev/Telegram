#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLStickerSet;

@interface TLmessages_StickerSet : NSObject <TLObject>

@property (nonatomic, retain) TLStickerSet *set;
@property (nonatomic, retain) NSArray *packs;
@property (nonatomic, retain) NSArray *documents;

@end

@interface TLmessages_StickerSet$messages_stickerSet : TLmessages_StickerSet


@end

