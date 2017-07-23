#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLGeoPoint;
@class TLWebPage;
@class TLGame;
@class TLWebDocument;
@class TLPhoto;
@class TLDocument;

@interface TLMessageMedia : NSObject <TLObject>


@end

@interface TLMessageMedia$messageMediaEmpty : TLMessageMedia


@end

@interface TLMessageMedia$messageMediaGeo : TLMessageMedia

@property (nonatomic, retain) TLGeoPoint *geo;

@end

@interface TLMessageMedia$messageMediaContact : TLMessageMedia

@property (nonatomic, retain) NSString *phone_number;
@property (nonatomic, retain) NSString *first_name;
@property (nonatomic, retain) NSString *last_name;
@property (nonatomic) int32_t user_id;

@end

@interface TLMessageMedia$messageMediaUnsupported : TLMessageMedia


@end

@interface TLMessageMedia$messageMediaWebPage : TLMessageMedia

@property (nonatomic, retain) TLWebPage *webpage;

@end

@interface TLMessageMedia$messageMediaVenue : TLMessageMedia

@property (nonatomic, retain) TLGeoPoint *geo;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *address;
@property (nonatomic, retain) NSString *provider;
@property (nonatomic, retain) NSString *venue_id;

@end

@interface TLMessageMedia$messageMediaGame : TLMessageMedia

@property (nonatomic, retain) TLGame *game;

@end

@interface TLMessageMedia$messageMediaInvoiceMeta : TLMessageMedia

@property (nonatomic) int32_t flags;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *n_description;
@property (nonatomic, retain) TLWebDocument *photo;
@property (nonatomic) int32_t receipt_msg_id;
@property (nonatomic, retain) NSString *currency;
@property (nonatomic) int64_t total_amount;
@property (nonatomic, retain) NSString *start_param;

@end

@interface TLMessageMedia$messageMediaPhotoMeta : TLMessageMedia

@property (nonatomic) int32_t flags;
@property (nonatomic, retain) TLPhoto *photo;
@property (nonatomic, retain) NSString *caption;
@property (nonatomic) int32_t ttl_seconds;

@end

@interface TLMessageMedia$messageMediaDocumentMeta : TLMessageMedia

@property (nonatomic) int32_t flags;
@property (nonatomic, retain) TLDocument *document;
@property (nonatomic, retain) NSString *caption;
@property (nonatomic) int32_t ttl_seconds;

@end

