#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLInputPeer : NSObject <TLObject>


@end

@interface TLInputPeer$inputPeerEmpty : TLInputPeer


@end

@interface TLInputPeer$inputPeerSelf : TLInputPeer


@end

@interface TLInputPeer$inputPeerContact : TLInputPeer

@property (nonatomic) int32_t user_id;

@end

@interface TLInputPeer$inputPeerForeign : TLInputPeer

@property (nonatomic) int32_t user_id;
@property (nonatomic) int64_t access_hash;

@end

@interface TLInputPeer$inputPeerChat : TLInputPeer

@property (nonatomic) int32_t chat_id;

@end

