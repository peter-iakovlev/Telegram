#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@interface TLSecurePasswordKdfAlgo : NSObject <TLObject>

@end

@interface TLSecurePasswordKdfAlgo$securePasswordKdfAlgoUnknown : TLSecurePasswordKdfAlgo

@end

@interface TLSecurePasswordKdfAlgo$securePasswordKdfAlgoPBKDF2HMACSHA512iter100000 : TLSecurePasswordKdfAlgo

@property (nonatomic, retain) NSData *salt;

@end

@interface TLSecurePasswordKdfAlgo$securePasswordKdfAlgoSHA512 : TLSecurePasswordKdfAlgo

@property (nonatomic, retain) NSData *salt;

@end
