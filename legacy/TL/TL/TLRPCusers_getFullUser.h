#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLInputUser;
@class TLUserFull;

@interface TLRPCusers_getFullUser : TLMetaRpc

@property (nonatomic, retain) TLInputUser *n_id;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCusers_getFullUser$users_getFullUser : TLRPCusers_getFullUser


@end

