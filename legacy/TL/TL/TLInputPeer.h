#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLInputPeer : NSObject <TLObject>


@end

@interface TLInputPeer$inputPeerEmpty : TLInputPeer


@end

@interface TLInputPeer$inputPeerSelf : TLInputPeer


@end

@interface TLInputPeer$inputPeerChat : TLInputPeer

@property (nonatomic) int32_t chat_id;

@end

@interface TLInputPeer$inputPeerUser : TLInputPeer

@property (nonatomic) int32_t user_id;
@property (nonatomic) int64_t access_hash;

@end

@interface TLInputPeer$inputPeerChannel : TLInputPeer

@property (nonatomic) int32_t channel_id;
@property (nonatomic) int64_t access_hash;

@end

