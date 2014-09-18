#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLPeer : NSObject <TLObject>


@end

@interface TLPeer$peerUser : TLPeer

@property (nonatomic) int32_t user_id;

@end

@interface TLPeer$peerChat : TLPeer

@property (nonatomic) int32_t chat_id;

@end

