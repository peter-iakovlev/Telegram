#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLRPCaccount_confirmPhone : TLMetaRpc

@property (nonatomic, retain) NSString *phone_code_hash;
@property (nonatomic, retain) NSString *phone_code;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCaccount_confirmPhone$account_confirmPhone : TLRPCaccount_confirmPhone


@end

