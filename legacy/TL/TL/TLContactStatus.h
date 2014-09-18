#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLContactStatus : NSObject <TLObject>

@property (nonatomic) int32_t user_id;
@property (nonatomic) int32_t expires;

@end

@interface TLContactStatus$contactStatus : TLContactStatus


@end

