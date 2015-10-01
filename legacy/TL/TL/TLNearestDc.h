#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLNearestDc : NSObject <TLObject>

@property (nonatomic, retain) NSString *country;
@property (nonatomic) int32_t this_dc;
@property (nonatomic) int32_t nearest_dc;

@end

@interface TLNearestDc$nearestDc : TLNearestDc


@end

