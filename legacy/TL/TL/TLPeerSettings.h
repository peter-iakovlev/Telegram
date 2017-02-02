#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLPeerSettings : NSObject <TLObject>

@property (nonatomic) int32_t flags;

@end

@interface TLPeerSettings$peerSettings : TLPeerSettings


@end

