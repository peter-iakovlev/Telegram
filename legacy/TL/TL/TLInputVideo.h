#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLInputVideo : NSObject <TLObject>


@end

@interface TLInputVideo$inputVideoEmpty : TLInputVideo


@end

@interface TLInputVideo$inputVideo : TLInputVideo

@property (nonatomic) int64_t n_id;
@property (nonatomic) int64_t access_hash;

@end

