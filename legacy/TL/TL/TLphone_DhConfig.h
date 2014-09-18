#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLphone_DhConfig : NSObject <TLObject>

@property (nonatomic) int32_t g;
@property (nonatomic, retain) NSString *p;
@property (nonatomic) int32_t ring_timeout;
@property (nonatomic) int32_t expires;

@end

@interface TLphone_DhConfig$phone_dhConfig : TLphone_DhConfig


@end

