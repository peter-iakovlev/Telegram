#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLDecryptedMessageMedia : NSObject <TLObject>


@end

@interface TLDecryptedMessageMedia$decryptedMessageMediaEmpty : TLDecryptedMessageMedia


@end

@interface TLDecryptedMessageMedia$decryptedMessageMediaPhoto : TLDecryptedMessageMedia

@property (nonatomic, retain) NSData *thumb;
@property (nonatomic) int32_t thumb_w;
@property (nonatomic) int32_t thumb_h;
@property (nonatomic) int32_t w;
@property (nonatomic) int32_t h;
@property (nonatomic) int32_t size;
@property (nonatomic, retain) NSData *key;
@property (nonatomic, retain) NSData *iv;

@end

@interface TLDecryptedMessageMedia$decryptedMessageMediaVideo : TLDecryptedMessageMedia

@property (nonatomic, retain) NSData *thumb;
@property (nonatomic) int32_t thumb_w;
@property (nonatomic) int32_t thumb_h;
@property (nonatomic) int32_t duration;
@property (nonatomic) int32_t w;
@property (nonatomic) int32_t h;
@property (nonatomic) int32_t size;
@property (nonatomic, retain) NSData *key;
@property (nonatomic, retain) NSData *iv;

@end

@interface TLDecryptedMessageMedia$decryptedMessageMediaGeoPoint : TLDecryptedMessageMedia

@property (nonatomic) double lat;
@property (nonatomic) double n_long;

@end

@interface TLDecryptedMessageMedia$decryptedMessageMediaContact : TLDecryptedMessageMedia

@property (nonatomic, retain) NSString *phone_number;
@property (nonatomic, retain) NSString *first_name;
@property (nonatomic, retain) NSString *last_name;
@property (nonatomic) int32_t user_id;

@end

@interface TLDecryptedMessageMedia$decryptedMessageMediaDocument : TLDecryptedMessageMedia

@property (nonatomic, retain) NSData *thumb;
@property (nonatomic) int32_t thumb_w;
@property (nonatomic) int32_t thumb_h;
@property (nonatomic, retain) NSString *file_name;
@property (nonatomic, retain) NSString *mime_type;
@property (nonatomic) int32_t size;
@property (nonatomic, retain) NSData *key;
@property (nonatomic, retain) NSData *iv;

@end

@interface TLDecryptedMessageMedia$decryptedMessageMediaAudio : TLDecryptedMessageMedia

@property (nonatomic) int32_t duration;
@property (nonatomic) int32_t size;
@property (nonatomic, retain) NSData *key;
@property (nonatomic, retain) NSData *iv;

@end

