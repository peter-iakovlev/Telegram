#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLInputDialogPeer;

@interface TLRPCmessages_toggleDialogPin : TLMetaRpc

@property (nonatomic) int32_t flags;
@property (nonatomic, retain) TLInputDialogPeer *peer;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCmessages_toggleDialogPin$messages_toggleDialogPin : TLRPCmessages_toggleDialogPin


@end

