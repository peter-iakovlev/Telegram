#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLmessages_ArchivedStickers;

@interface TLRPCmessages_getArchivedStickers : TLMetaRpc

@property (nonatomic) int32_t flags;
@property (nonatomic) int64_t offset_id;
@property (nonatomic) int32_t limit;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCmessages_getArchivedStickers$messages_getArchivedStickers : TLRPCmessages_getArchivedStickers


@end

