#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLInputPhoto : NSObject <TLObject>


@end

@interface TLInputPhoto$inputPhotoEmpty : TLInputPhoto


@end

@interface TLInputPhoto$inputPhoto : TLInputPhoto

@property (nonatomic) int64_t n_id;
@property (nonatomic) int64_t access_hash;

@end

