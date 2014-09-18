#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLInputUser;
@class TLphotos_Photos;

@interface TLRPCphotos_getWall : TLMetaRpc

@property (nonatomic, retain) TLInputUser *user_id;
@property (nonatomic) int32_t offset;
@property (nonatomic) int32_t max_id;
@property (nonatomic) int32_t limit;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCphotos_getWall$photos_getWall : TLRPCphotos_getWall


@end

