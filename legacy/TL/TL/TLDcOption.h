#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLDcOption : NSObject <TLObject>

@property (nonatomic) int32_t n_id;
@property (nonatomic, retain) NSString *hostname;
@property (nonatomic, retain) NSString *ip_address;
@property (nonatomic) int32_t port;

@end

@interface TLDcOption$dcOption : TLDcOption


@end

