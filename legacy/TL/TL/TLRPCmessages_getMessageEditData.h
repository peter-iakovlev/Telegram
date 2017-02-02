#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLInputPeer;
@class TLmessages_MessageEditData;

@interface TLRPCmessages_getMessageEditData : TLMetaRpc

@property (nonatomic, retain) TLInputPeer *peer;
@property (nonatomic) int32_t n_id;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCmessages_getMessageEditData$messages_getMessageEditData : TLRPCmessages_getMessageEditData


@end

