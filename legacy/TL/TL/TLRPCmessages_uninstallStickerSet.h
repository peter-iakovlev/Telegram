#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLInputStickerSet;

@interface TLRPCmessages_uninstallStickerSet : TLMetaRpc

@property (nonatomic, retain) TLInputStickerSet *stickerset;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCmessages_uninstallStickerSet$messages_uninstallStickerSet : TLRPCmessages_uninstallStickerSet


@end

