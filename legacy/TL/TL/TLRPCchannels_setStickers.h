#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLInputChannel;
@class TLInputStickerSet;

@interface TLRPCchannels_setStickers : TLMetaRpc

@property (nonatomic, retain) TLInputChannel *channel;
@property (nonatomic, retain) TLInputStickerSet *stickerset;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCchannels_setStickers$channels_setStickers : TLRPCchannels_setStickers


@end

