#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLaccount_PasswordSettings : NSObject <TLObject>

@property (nonatomic, retain) NSString *email;
@property (nonatomic, retain) NSData *secure_salt;
@property (nonatomic, retain) NSData *secure_secret;
@property (nonatomic) int64_t secure_secret_id;

@end

@interface TLaccount_PasswordSettings$account_passwordSettings : TLaccount_PasswordSettings


@end

