#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLRPCaccount_checkUsername : TLMetaRpc

@property (nonatomic, retain) NSString *username;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCaccount_checkUsername$account_checkUsername : TLRPCaccount_checkUsername


@end

