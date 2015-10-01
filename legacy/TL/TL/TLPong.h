#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLPong : NSObject <TLObject>

@property (nonatomic) int64_t msg_id;
@property (nonatomic) int64_t ping_id;

@end

@interface TLPong$pong : TLPong


@end

