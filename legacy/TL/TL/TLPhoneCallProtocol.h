#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLPhoneCallProtocol : NSObject <TLObject>

@property (nonatomic) int32_t flags;
@property (nonatomic) int32_t min_layer;
@property (nonatomic) int32_t max_layer;

@end

@interface TLPhoneCallProtocol$phoneCallProtocol : TLPhoneCallProtocol


@end

