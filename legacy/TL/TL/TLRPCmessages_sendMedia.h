#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLInputPeer;
@class TLInputMedia;
@class TLmessages_StatedMessage;

@interface TLRPCmessages_sendMedia : TLMetaRpc

@property (nonatomic, retain) TLInputPeer *peer;
@property (nonatomic, retain) TLInputMedia *media;
@property (nonatomic) int64_t random_id;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCmessages_sendMedia$messages_sendMedia : TLRPCmessages_sendMedia


@end

