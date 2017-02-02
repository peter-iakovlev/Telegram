#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLRPCauth_cancelCode : TLMetaRpc

@property (nonatomic, retain) NSString *phone_number;
@property (nonatomic, retain) NSString *phone_code_hash;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCauth_cancelCode$auth_cancelCode : TLRPCauth_cancelCode


@end

