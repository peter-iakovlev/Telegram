#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLPhoto;
@class TLDocument;

@interface TLFoundGif : NSObject <TLObject>

@property (nonatomic, retain) NSString *url;

@end

@interface TLFoundGif$foundGif : TLFoundGif

@property (nonatomic, retain) NSString *thumb_url;
@property (nonatomic, retain) NSString *content_url;
@property (nonatomic, retain) NSString *content_type;
@property (nonatomic) int32_t w;
@property (nonatomic) int32_t h;

@end

@interface TLFoundGif$foundGifCached : TLFoundGif

@property (nonatomic, retain) TLPhoto *photo;
@property (nonatomic, retain) TLDocument *document;

@end

