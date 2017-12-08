#import "TLMetaRpc.h"

@class TLInputPeer;

//messages.sendMultiMedia flags:# silent:flags.5?true background:flags.6?true clear_draft:flags.7?true peer:InputPeer reply_to_msg_id:flags.0?int multi_media:Vector<InputSingleMedia> grouped_id:flags.8?long = Updates

@interface TLRPCmessages_sendMultiMedia : TLMetaRpc

@property (nonatomic) int32_t flags;
@property (nonatomic, strong) TLInputPeer *peer;
@property (nonatomic) int32_t reply_to_msg_id;
@property (nonatomic, strong) NSArray *multi_media;

@end
