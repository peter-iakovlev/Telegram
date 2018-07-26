#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLSecureCredentialsEncrypted : NSObject <TLObject>

@property (nonatomic, retain) NSData *data;
@property (nonatomic, retain) NSData *n_hash;
@property (nonatomic, retain) NSData *secret;

@end

@interface TLSecureCredentialsEncrypted$secureCredentialsEncrypted : TLSecureCredentialsEncrypted

@end
