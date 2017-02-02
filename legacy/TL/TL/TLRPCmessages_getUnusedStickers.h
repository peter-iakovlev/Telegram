#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class NSArray_StickerSet;

@interface TLRPCmessages_getUnusedStickers : TLMetaRpc

@property (nonatomic) int32_t limit;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCmessages_getUnusedStickers$messages_getUnusedStickers : TLRPCmessages_getUnusedStickers


@end

