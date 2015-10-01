#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLUser;

@interface TLRPCaccount_updateProfile : TLMetaRpc

@property (nonatomic, retain) NSString *first_name;
@property (nonatomic, retain) NSString *last_name;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCaccount_updateProfile$account_updateProfile : TLRPCaccount_updateProfile


@end

