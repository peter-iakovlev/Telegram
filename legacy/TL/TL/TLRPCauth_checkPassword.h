#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLauth_Authorization;

@interface TLRPCauth_checkPassword : TLMetaRpc

@property (nonatomic, retain) NSData *password_hash;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCauth_checkPassword$auth_checkPassword : TLRPCauth_checkPassword


@end

