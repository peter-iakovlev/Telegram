#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLRPCaccount_setPassword : TLMetaRpc

@property (nonatomic, retain) NSData *current_password_hash;
@property (nonatomic, retain) NSData *n_new_salt;
@property (nonatomic, retain) NSData *n_new_password_hash;
@property (nonatomic, retain) NSString *hint;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCaccount_setPassword$account_setPassword : TLRPCaccount_setPassword


@end

