#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLPeer;

@interface TLDialogPeer : NSObject <TLObject>

@end

@interface TLDialogPeer$dialogPeerFeed : TLDialogPeer

@property (nonatomic) int32_t feed_id;

@end

@interface TLDialogPeer$dialogPeer : TLDialogPeer

@property (nonatomic, strong) TLPeer *peer;

@end
