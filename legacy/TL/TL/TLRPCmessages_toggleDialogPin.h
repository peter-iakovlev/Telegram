#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLInputPeer;

@interface TLRPCmessages_toggleDialogPin : TLMetaRpc

@property (nonatomic) int32_t flags;
@property (nonatomic, retain) TLInputPeer *peer;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCmessages_toggleDialogPin$messages_toggleDialogPin : TLRPCmessages_toggleDialogPin


@end

