#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLChatPhoto;
@class TLGeoPoint;

@interface TLChat : NSObject <TLObject>

@property (nonatomic) int32_t n_id;

@end

@interface TLChat$chatEmpty : TLChat


@end

@interface TLChat$chat : TLChat

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) TLChatPhoto *photo;
@property (nonatomic) int32_t participants_count;
@property (nonatomic) int32_t date;
@property (nonatomic) bool left;
@property (nonatomic) int32_t version;

@end

@interface TLChat$chatForbidden : TLChat

@property (nonatomic, retain) NSString *title;
@property (nonatomic) int32_t date;

@end

@interface TLChat$geoChat : TLChat

@property (nonatomic) int64_t access_hash;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *address;
@property (nonatomic, retain) NSString *venue;
@property (nonatomic, retain) TLGeoPoint *geo;
@property (nonatomic, retain) TLChatPhoto *photo;
@property (nonatomic) int32_t participants_count;
@property (nonatomic) int32_t date;
@property (nonatomic) bool checked_in;
@property (nonatomic) int32_t version;

@end

