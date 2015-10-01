#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLUser;

@interface TLRPCaccount_changePhone : TLMetaRpc

@property (nonatomic, retain) NSString *phone_number;
@property (nonatomic, retain) NSString *phone_code_hash;
@property (nonatomic, retain) NSString *phone_code;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCaccount_changePhone$account_changePhone : TLRPCaccount_changePhone


@end

