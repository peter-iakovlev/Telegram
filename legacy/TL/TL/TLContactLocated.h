#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLGeoPoint;

@interface TLContactLocated : NSObject <TLObject>

@property (nonatomic) int32_t date;
@property (nonatomic) int32_t distance;

@end

@interface TLContactLocated$contactLocated : TLContactLocated

@property (nonatomic) int32_t user_id;
@property (nonatomic, retain) TLGeoPoint *location;

@end

@interface TLContactLocated$contactLocatedPreview : TLContactLocated

@property (nonatomic, retain) NSString *n_hash;
@property (nonatomic) bool hidden;

@end

