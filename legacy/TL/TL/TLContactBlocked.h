#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLContactBlocked : NSObject <TLObject>

@property (nonatomic) int32_t user_id;
@property (nonatomic) int32_t date;

@end

@interface TLContactBlocked$contactBlocked : TLContactBlocked


@end

