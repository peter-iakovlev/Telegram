#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLmessages_PeerDialogs;

@interface TLRPCmessages_getPeerDialogs : TLMetaRpc

@property (nonatomic, retain) NSArray *peers;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCmessages_getPeerDialogs$messages_getPeerDialogs : TLRPCmessages_getPeerDialogs


@end

