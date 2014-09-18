#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLInputUser;

@interface TLRPCphotos_readWall : TLMetaRpc

@property (nonatomic, retain) TLInputUser *user_id;
@property (nonatomic) int64_t max_id;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCphotos_readWall$photos_readWall : TLRPCphotos_readWall


@end

