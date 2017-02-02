#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLGeoPoint;

@interface TLPhoto : NSObject <TLObject>

@property (nonatomic) int64_t n_id;

@end

@interface TLPhoto$photoEmpty : TLPhoto


@end

@interface TLPhoto$wallPhoto : TLPhoto

@property (nonatomic) int64_t access_hash;
@property (nonatomic) int32_t user_id;
@property (nonatomic) int32_t date;
@property (nonatomic, retain) NSString *caption;
@property (nonatomic, retain) TLGeoPoint *geo;
@property (nonatomic) bool unread;
@property (nonatomic, retain) NSArray *sizes;

@end

@interface TLPhoto$photo : TLPhoto

@property (nonatomic) int32_t flags;
@property (nonatomic) int64_t access_hash;
@property (nonatomic) int32_t date;
@property (nonatomic, retain) NSArray *sizes;

@end

