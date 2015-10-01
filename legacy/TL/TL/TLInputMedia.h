#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLInputGeoPoint;
@class TLInputAudio;
@class TLInputDocument;
@class TLInputFile;
@class TLInputPhoto;
@class TLInputVideo;

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

@interface TLInputMedia$inputMediaAudio : TLInputMedia

@property (nonatomic, retain) TLInputAudio *n_id;

@end

@interface TLInputMedia$inputMediaDocument : TLInputMedia

@property (nonatomic, retain) TLInputDocument *n_id;

@end

@interface TLInputMedia$inputMediaUploadedAudio : TLInputMedia

@property (nonatomic, retain) TLInputFile *file;
@property (nonatomic) int32_t duration;
@property (nonatomic, retain) NSString *mime_type;

@end

@interface TLInputMedia$inputMediaUploadedDocument : TLInputMedia

@property (nonatomic, retain) TLInputFile *file;
@property (nonatomic, retain) NSString *mime_type;
@property (nonatomic, retain) NSArray *attributes;

@end

@interface TLInputMedia$inputMediaUploadedThumbDocument : TLInputMedia

@property (nonatomic, retain) TLInputFile *file;
@property (nonatomic, retain) TLInputFile *thumb;
@property (nonatomic, retain) NSString *mime_type;
@property (nonatomic, retain) NSArray *attributes;

@end

@interface TLInputMedia$inputMediaUploadedPhoto : TLInputMedia

@property (nonatomic, retain) TLInputFile *file;
@property (nonatomic, retain) NSString *caption;

@end

@interface TLInputMedia$inputMediaPhoto : TLInputMedia

@property (nonatomic, retain) TLInputPhoto *n_id;
@property (nonatomic, retain) NSString *caption;

@end

@interface TLInputMedia$inputMediaVideo : TLInputMedia

@property (nonatomic, retain) TLInputVideo *n_id;
@property (nonatomic, retain) NSString *caption;

@end

@interface TLInputMedia$inputMediaVenue : TLInputMedia

@property (nonatomic, retain) TLInputGeoPoint *geo_point;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *address;
@property (nonatomic, retain) NSString *provider;
@property (nonatomic, retain) NSString *venue_id;

@end

@interface TLInputMedia$inputMediaUploadedVideo : TLInputMedia

@property (nonatomic, retain) TLInputFile *file;
@property (nonatomic) int32_t duration;
@property (nonatomic) int32_t w;
@property (nonatomic) int32_t h;
@property (nonatomic, retain) NSString *mime_type;
@property (nonatomic, retain) NSString *caption;

@end

@interface TLInputMedia$inputMediaUploadedThumbVideo : TLInputMedia

@property (nonatomic, retain) TLInputFile *file;
@property (nonatomic, retain) TLInputFile *thumb;
@property (nonatomic) int32_t duration;
@property (nonatomic) int32_t w;
@property (nonatomic) int32_t h;
@property (nonatomic, retain) NSString *mime_type;
@property (nonatomic, retain) NSString *caption;

@end

