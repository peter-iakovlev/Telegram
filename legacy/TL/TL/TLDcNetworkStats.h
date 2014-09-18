#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLDcNetworkStats : NSObject <TLObject>

@property (nonatomic) int32_t dc_id;
@property (nonatomic, retain) NSString *ip_address;
@property (nonatomic, retain) NSArray *pings;

@end

@interface TLDcNetworkStats$dcPingStats : TLDcNetworkStats


@end

