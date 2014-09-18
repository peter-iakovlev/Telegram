#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLHttpWait : NSObject <TLObject>

@property (nonatomic) int32_t max_delay;
@property (nonatomic) int32_t wait_after;
@property (nonatomic) int32_t max_wait;

@end

@interface TLHttpWait$http_wait : TLHttpWait


@end

