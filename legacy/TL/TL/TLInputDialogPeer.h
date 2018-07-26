#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLInputPeer;

@interface TLInputDialogPeer : NSObject <TLObject>

@end

@interface TLInputDialogPeer$inputDialogPeerFeed : TLInputDialogPeer

@property (nonatomic) int32_t feed_id;

@end

@interface TLInputDialogPeer$inputDialogPeer : TLInputDialogPeer

@property (nonatomic, strong) TLInputPeer *peer;

@end
