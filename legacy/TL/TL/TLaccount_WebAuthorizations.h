#import "TLObject.h"
#import "TLMetaRpc.h"

@interface TLaccount_WebAuthorizations : NSObject <TLObject>

@property (nonatomic, strong) NSArray *authorizations;
@property (nonatomic, strong) NSArray *users;

@end


@interface TLaccount_WebAuthorizations$account_webAuthorizations : TLaccount_WebAuthorizations


@end
