#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLInputPeer;
@class TLmessages_Dialogs;

@interface TLRPCmessages_getDialogs : TLMetaRpc

@property (nonatomic) int32_t flags;
@property (nonatomic) int32_t offset_date;
@property (nonatomic) int32_t offset_id;
@property (nonatomic, retain) TLInputPeer *offset_peer;
@property (nonatomic) int32_t limit;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCmessages_getDialogs$messages_getDialogs : TLRPCmessages_getDialogs


@end

