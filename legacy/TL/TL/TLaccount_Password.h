#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLPasswordKdfAlgo;
@class TLSecurePasswordKdfAlgo;


@interface TLaccount_Password : NSObject <TLObject>

@property (nonatomic) int32_t flags;
@property (nonatomic, retain) TLPasswordKdfAlgo *current_algo;
@property (nonatomic, retain) NSData *srp_B;
@property (nonatomic) int64_t srp_id;
@property (nonatomic, retain) NSString *hint;
@property (nonatomic, retain) NSString *email_unconfirmed_pattern;
@property (nonatomic, retain) TLPasswordKdfAlgo *n_new_algo;
@property (nonatomic, retain) TLSecurePasswordKdfAlgo *n_new_secure_algo;
@property (nonatomic, retain) NSData *secure_random;


@end


@interface TLaccount_Password$account_passwordMeta : TLaccount_Password

@end

