#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLInputFile;
@class TLInputPhoto;
@class TLInputGeoPoint;
@class TLInputVideo;
@class TLInputAudio;
@class TLInputDocument;

@interface TLInputMedia : NSObject <TLObject>


@end

@interface TLInputMedia$inputMediaEmpty : TLInputMedia


@end

@interface TLInputMedia$inputMediaUploadedPhoto : TLInputMedia

@property (nonatomic, retain) TLInputFile *file;

@end

@interface TLInputMedia$inputMediaPhoto : TLInputMedia

@property (nonatomic, retain) TLInputPhoto *n_id;

@end

@interface TLInputMedia$inputMediaGeoPoint : TLInputMedia

@property (nonatomic, retain) TLInputGeoPoint *geo_point;

@end

@interface TLInputMedia$inputMediaContact : TLInputMedia

@property (nonatomic, retain) NSString *phone_number;
@property (nonatomic, retain) NSString *first_name;
@property (nonatomic, retain) NSString *last_name;

@end

@interface TLInputMedia$inputMediaVideo : TLInputMedia

@property (nonatomic, retain) TLInputVideo *n_id;

@end

@interface TLInputMedia$inputMediaAudio : TLInputMedia

@property (nonatomic, retain) TLInputAudio *n_id;

@end

@interface TLInputMedia$inputMediaUploadedDocument : TLInputMedia

@property (nonatomic, retain) TLInputFile *file;
@property (nonatomic, retain) NSString *file_name;
@property (nonatomic, retain) NSString *mime_type;

@end

@interface TLInputMedia$inputMediaUploadedThumbDocument : TLInputMedia

@property (nonatomic, retain) TLInputFile *file;
@property (nonatomic, retain) TLInputFile *thumb;
@property (nonatomic, retain) NSString *file_name;
@property (nonatomic, retain) NSString *mime_type;

@end

@interface TLInputMedia$inputMediaDocument : TLInputMedia

@property (nonatomic, retain) TLInputDocument *n_id;

@end

@interface TLInputMedia$inputMediaUploadedAudio : TLInputMedia

@property (nonatomic, retain) TLInputFile *file;
@property (nonatomic) int32_t duration;
@property (nonatomic, retain) NSString *mime_type;

@end

@interface TLInputMedia$inputMediaUploadedVideo : TLInputMedia

@property (nonatomic, retain) TLInputFile *file;
@property (nonatomic) int32_t duration;
@property (nonatomic) int32_t w;
@property (nonatomic) int32_t h;
@property (nonatomic, retain) NSString *mime_type;

@end

@interface TLInputMedia$inputMediaUploadedThumbVideo : TLInputMedia

@property (nonatomic, retain) TLInputFile *file;
@property (nonatomic, retain) TLInputFile *thumb;
@property (nonatomic) int32_t duration;
@property (nonatomic) int32_t w;
@property (nonatomic) int32_t h;
@property (nonatomic, retain) NSString *mime_type;

@end

