#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLInputPeer;
@class TLmessages_StatedMessages;

@interface TLRPCmessages_forwardMessages : TLMetaRpc

@property (nonatomic, retain) TLInputPeer *peer;
@property (nonatomic, retain) NSArray *n_id;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCmessages_forwardMessages$messages_forwardMessages : TLRPCmessages_forwardMessages


@end

