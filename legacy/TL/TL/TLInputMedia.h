#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLInputGeoPoint;
@class TLInputPhoto;
@class TLInputDocument;
@class TLInputFile;
@class TLInputGame;

@interface TLInputMedia : NSObject <TLObject>


@end

@interface TLInputMedia$inputMediaEmpty : TLInputMedia


@end

@interface TLInputMedia$inputMediaGeoPoint : TLInputMedia

@property (nonatomic, retain) TLInputGeoPoint *geo_point;

@end

@interface TLInputMedia$inputMediaContact : TLInputMedia

@property (nonatomic, retain) NSString *phone_number;
@property (nonatomic, retain) NSString *first_name;
@property (nonatomic, retain) NSString *last_name;
@property (nonatomic, retain) NSString *vcard;

@end

@interface TLInputMedia$inputMediaPhotoMeta : TLInputMedia

@property (nonatomic) int32_t flags;
@property (nonatomic, retain) TLInputPhoto *n_id;
@property (nonatomic) int32_t ttl_seconds;

@end

@interface TLInputMedia$inputMediaGifExternal : TLInputMedia

@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) NSString *q;

@end

@interface TLInputMedia$inputMediaDocumentMeta : TLInputMedia

@property (nonatomic) int32_t flags;
@property (nonatomic, retain) TLInputDocument *n_id;
@property (nonatomic) int32_t ttl_seconds;

@end

@interface TLInputMedia$inputMediaPhotoExternalMeta : TLInputMedia

@property (nonatomic) int32_t flags;
@property (nonatomic, retain) NSString *url;
@property (nonatomic) int32_t ttl_seconds;

@end

@interface TLInputMedia$inputMediaDocumentExternalMeta : TLInputMedia

@property (nonatomic) int32_t flags;
@property (nonatomic, retain) NSString *url;
@property (nonatomic) int32_t ttl_seconds;

@end

@interface TLInputMedia$inputMediaGame : TLInputMedia

@property (nonatomic, retain) TLInputGame *n_id;

@end

@interface TLInputMedia$inputMediaUploadedPhotoMeta : TLInputMedia

@property (nonatomic) int32_t flags;
@property (nonatomic, retain) TLInputFile *file;
@property (nonatomic, retain) NSArray *stickers;
@property (nonatomic) int32_t ttl_seconds;

@end

@interface TLInputMedia$inputMediaUploadedDocumentMeta : TLInputMedia

@property (nonatomic) int32_t flags;
@property (nonatomic, retain) TLInputFile *file;
@property (nonatomic, retain) TLInputFile *thumb;
@property (nonatomic, retain) NSString *mime_type;
@property (nonatomic, retain) NSArray *attributes;
@property (nonatomic, retain) NSArray *stickers;
@property (nonatomic) int32_t ttl_seconds;

@end

@interface TLInputMedia$inputMediaGeoLive : TLInputMedia

@property (nonatomic, retain) TLInputGeoPoint *geo_point;
@property (nonatomic) int32_t period;

@end

@interface TLInputMedia$inputMediaVenue : TLInputMedia

@property (nonatomic, retain) TLInputGeoPoint *geo_point;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *address;
@property (nonatomic, retain) NSString *provider;
@property (nonatomic, retain) NSString *venue_id;
@property (nonatomic, retain) NSString *venue_type;

@end

