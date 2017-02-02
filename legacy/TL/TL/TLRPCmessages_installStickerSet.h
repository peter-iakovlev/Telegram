#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLInputStickerSet;
@class TLmessages_StickerSetInstallResult;

@interface TLRPCmessages_installStickerSet : TLMetaRpc

@property (nonatomic, retain) TLInputStickerSet *stickerset;
@property (nonatomic) bool archived;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCmessages_installStickerSet$messages_installStickerSet : TLRPCmessages_installStickerSet


@end

