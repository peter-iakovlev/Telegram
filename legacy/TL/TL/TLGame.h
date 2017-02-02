#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLPhoto;
@class TLDocument;

@interface TLGame : NSObject <TLObject>

@property (nonatomic) int32_t flags;
@property (nonatomic) int64_t n_id;
@property (nonatomic) int64_t access_hash;
@property (nonatomic, retain) NSString *short_name;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *n_description;
@property (nonatomic, retain) TLPhoto *photo;
@property (nonatomic, retain) TLDocument *document;

@end

@interface TLGame$gameMeta : TLGame


@end

