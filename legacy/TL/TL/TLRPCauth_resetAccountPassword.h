#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLauth_Authorization;

@interface TLRPCauth_resetAccountPassword : TLMetaRpc

@property (nonatomic, retain) NSString *first_name;
@property (nonatomic, retain) NSString *last_name;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCauth_resetAccountPassword$auth_resetAccountPassword : TLRPCauth_resetAccountPassword


@end

