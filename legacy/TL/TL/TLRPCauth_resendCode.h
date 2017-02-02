#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLauth_SentCode;

@interface TLRPCauth_resendCode : TLMetaRpc

@property (nonatomic, retain) NSString *phone_number;
@property (nonatomic, retain) NSString *phone_code_hash;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCauth_resendCode$auth_resendCode : TLRPCauth_resendCode


@end

