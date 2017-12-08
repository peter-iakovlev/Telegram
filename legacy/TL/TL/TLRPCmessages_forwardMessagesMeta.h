#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLInputPeer;
@class TLUpdates;

@interface TLRPCmessages_forwardMessages : TLMetaRpc

@property (nonatomic) int32_t flags;
@property (nonatomic, retain) TLInputPeer *from_peer;
@property (nonatomic, retain) NSArray *n_id;
@property (nonatomic, retain) NSArray *random_id;
@property (nonatomic, retain) TLInputPeer *to_peer;
@property (nonatomic) int64_t grouped_id;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end
