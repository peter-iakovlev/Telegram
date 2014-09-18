#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLauth_CheckedPhone;

@interface TLRPCauth_checkPhone : TLMetaRpc

@property (nonatomic, retain) NSString *phone_number;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCauth_checkPhone$auth_checkPhone : TLRPCauth_checkPhone


@end

