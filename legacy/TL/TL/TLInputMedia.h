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

@end

@interface TLInputMedia$inputMediaPhoto : TLInputMedia

@property (nonatomic, retain) TLInputPhoto *n_id;
@property (nonatomic, retain) NSString *caption;

@end

@interface TLInputMedia$inputMediaVenue : TLInputMedia

@property (nonatomic, retain) TLInputGeoPoint *geo_point;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *address;
@property (nonatomic, retain) NSString *provider;
@property (nonatomic, retain) NSString *venue_id;

@end

@interface TLInputMedia$inputMediaGifExternal : TLInputMedia

@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) NSString *q;

@end

@interface TLInputMedia$inputMediaDocument : TLInputMedia

@property (nonatomic, retain) TLInputDocument *n_id;
@property (nonatomic, retain) NSString *caption;

@end

@interface TLInputMedia$inputMediaPhotoExternal : TLInputMedia

@property (nonatomic, retain) NSString *url;

@end

@interface TLInputMedia$inputMediaDocumentExternal : TLInputMedia

@property (nonatomic, retain) TLInputFile *url;

@end

@interface TLInputMedia$inputMediaGame : TLInputMedia

@property (nonatomic, retain) TLInputGame *n_id;

@end

@interface TLInputMedia$inputMediaUploadedPhotoMeta : TLInputMedia

@property (nonatomic) int32_t flags;
@property (nonatomic, retain) TLInputFile *file;
@property (nonatomic, retain) NSString *caption;
@property (nonatomic, retain) NSArray *stickers;
@property (nonatomic) int32_t ttl_seconds;

@end

@interface TLInputMedia$inputMediaUploadedDocumentMeta : TLInputMedia

@property (nonatomic) int32_t flags;
@property (nonatomic, retain) TLInputFile *file;
@property (nonatomic, retain) TLInputFile *thumb;
@property (nonatomic, retain) NSString *mime_type;
@property (nonatomic, retain) NSArray *attributes;
@property (nonatomic, retain) NSString *caption;
@property (nonatomic, retain) NSArray *stickers;
@property (nonatomic) int32_t ttl_seconds;

@end

