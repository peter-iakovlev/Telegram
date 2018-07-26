#import "TLMetaRpc.h"

@class TLInputDialogPeer;

@interface TLRPCmessages_markDialogUnread : TLMetaRpc

@property (nonatomic) int32_t flags;
@property (nonatomic, retain) TLInputDialogPeer *peer;

@end
