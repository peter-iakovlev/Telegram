#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLPeer;

@interface TLMessageFwdHeader : NSObject <TLObject>

@property (nonatomic) int32_t flags;
@property (nonatomic) int32_t from_id;
@property (nonatomic) int32_t date;
@property (nonatomic) int32_t channel_id;
@property (nonatomic) int32_t channel_post;
@property (nonatomic, retain) NSString *post_author;
@property (nonatomic, retain) TLPeer *saved_from_peer;
@property (nonatomic) int32_t saved_from_msg_id;

@end

@interface TLMessageFwdHeader$messageFwdHeaderMeta : TLMessageFwdHeader


@end

