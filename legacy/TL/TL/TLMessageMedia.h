#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLPhoto;
@class TLVideo;
@class TLGeoPoint;
@class TLDocument;
@class TLAudio;

@interface TLMessageMedia : NSObject <TLObject>


@end

@interface TLMessageMedia$messageMediaEmpty : TLMessageMedia


@end

@interface TLMessageMedia$messageMediaPhoto : TLMessageMedia

@property (nonatomic, retain) TLPhoto *photo;

@end

@interface TLMessageMedia$messageMediaVideo : TLMessageMedia

@property (nonatomic, retain) TLVideo *video;

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

@property (nonatomic, retain) NSData *bytes;

@end

@interface TLMessageMedia$messageMediaDocument : TLMessageMedia

@property (nonatomic, retain) TLDocument *document;

@end

@interface TLMessageMedia$messageMediaAudio : TLMessageMedia

@property (nonatomic, retain) TLAudio *audio;

@end

