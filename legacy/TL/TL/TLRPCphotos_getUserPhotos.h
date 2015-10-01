#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLInputUser;
@class TLphotos_Photos;

@interface TLRPCphotos_getUserPhotos : TLMetaRpc

@property (nonatomic, retain) TLInputUser *user_id;
@property (nonatomic) int32_t offset;
@property (nonatomic) int64_t max_id;
@property (nonatomic) int32_t limit;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCphotos_getUserPhotos$photos_getUserPhotos : TLRPCphotos_getUserPhotos


@end

