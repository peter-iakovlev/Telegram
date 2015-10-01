#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLInputStickerSet;
@class TLmessages_StickerSet;

@interface TLRPCmessages_getStickerSet : TLMetaRpc

@property (nonatomic, retain) TLInputStickerSet *stickerset;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCmessages_getStickerSet$messages_getStickerSet : TLRPCmessages_getStickerSet


@end

