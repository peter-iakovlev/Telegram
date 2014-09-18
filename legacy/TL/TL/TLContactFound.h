#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLContactFound : NSObject <TLObject>

@property (nonatomic) int32_t user_id;

@end

@interface TLContactFound$contactFound : TLContactFound


@end

