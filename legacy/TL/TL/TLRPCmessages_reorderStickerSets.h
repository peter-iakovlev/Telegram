#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLRPCmessages_reorderStickerSets : TLMetaRpc

@property (nonatomic) int32_t flags;
@property (nonatomic, retain) NSArray *order;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCmessages_reorderStickerSets$messages_reorderStickerSets : TLRPCmessages_reorderStickerSets


@end

