#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLSecurePasswordKdfAlgo;

@interface TLSecureSecretSettings : NSObject <TLObject>

@property (nonatomic, retain) TLSecurePasswordKdfAlgo *secure_algo;
@property (nonatomic, retain) NSData *secure_secret;
@property (nonatomic) int64_t secure_secret_id;

@end

@interface TLSecureSecretSettings$secureSecretSettings : TLSecureSecretSettings

@end
