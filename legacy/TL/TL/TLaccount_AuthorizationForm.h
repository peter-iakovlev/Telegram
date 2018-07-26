#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLaccount_AuthorizationForm : NSObject <TLObject>

@property (nonatomic) int32_t flags;
@property (nonatomic, retain) NSArray *required_types;
@property (nonatomic, retain) NSArray *values;
@property (nonatomic, retain) NSArray *errors;
@property (nonatomic, retain) NSArray *users;
@property (nonatomic, retain) NSString *privacy_policy_url;

@end

@interface TLaccount_AuthorizationForm$account_authorizationFormMeta : TLaccount_AuthorizationForm

@end

