#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLFutureSalt : NSObject <TLObject>

@property (nonatomic) int32_t valid_since;
@property (nonatomic) int32_t valid_until;
@property (nonatomic) int64_t salt;

@end

@interface TLFutureSalt$futureSalt : TLFutureSalt


@end

