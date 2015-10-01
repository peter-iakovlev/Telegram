#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLPhotoSize;

@interface TLVideo : NSObject <TLObject>

@property (nonatomic) int64_t n_id;

@end

@interface TLVideo$videoEmpty : TLVideo


@end

@interface TLVideo$video : TLVideo

@property (nonatomic) int64_t access_hash;
@property (nonatomic) int32_t date;
@property (nonatomic) int32_t duration;
@property (nonatomic, retain) NSString *mime_type;
@property (nonatomic) int32_t size;
@property (nonatomic, retain) TLPhotoSize *thumb;
@property (nonatomic) int32_t dc_id;
@property (nonatomic) int32_t w;
@property (nonatomic) int32_t h;

@end

