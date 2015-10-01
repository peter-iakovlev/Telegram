#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLGeoPoint;
@class TLDocument;
@class TLAudio;
@class TLWebPage;
@class TLPhoto;
@class TLVideo;

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

@interface TLMessageMedia$messageMediaDocument : TLMessageMedia

@property (nonatomic, retain) TLDocument *document;

@end

@interface TLMessageMedia$messageMediaAudio : TLMessageMedia

@property (nonatomic, retain) TLAudio *audio;

@end

@interface TLMessageMedia$messageMediaUnsupported : TLMessageMedia


@end

@interface TLMessageMedia$messageMediaWebPage : TLMessageMedia

@property (nonatomic, retain) TLWebPage *webpage;

@end

@interface TLMessageMedia$messageMediaPhoto : TLMessageMedia

@property (nonatomic, retain) TLPhoto *photo;
@property (nonatomic, retain) NSString *caption;

@end

@interface TLMessageMedia$messageMediaVideo : TLMessageMedia

@property (nonatomic, retain) TLVideo *video;
@property (nonatomic, retain) NSString *caption;

@end

@interface TLMessageMedia$messageMediaVenue : TLMessageMedia

@property (nonatomic, retain) TLGeoPoint *geo;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *address;
@property (nonatomic, retain) NSString *provider;
@property (nonatomic, retain) NSString *venue_id;

@end

