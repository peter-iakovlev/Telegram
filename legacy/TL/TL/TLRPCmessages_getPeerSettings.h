#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLInputPeer;
@class TLPeerSettings;

@interface TLRPCmessages_getPeerSettings : TLMetaRpc

@property (nonatomic, retain) TLInputPeer *peer;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCmessages_getPeerSettings$messages_getPeerSettings : TLRPCmessages_getPeerSettings


@end

