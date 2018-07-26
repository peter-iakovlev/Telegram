#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLSecureData;
@class TLSecureValueType;
@class TLSecurePlainData;
@class TLSecureFile;

@interface TLSecureValue : NSObject <TLObject>

@property (nonatomic) int32_t flags;
@property (nonatomic, retain) TLSecureValueType *type;
@property (nonatomic, retain) TLSecureData *data;
@property (nonatomic, retain) TLSecureFile *front_side;
@property (nonatomic, retain) TLSecureFile *reverse_side;
@property (nonatomic, retain) TLSecureFile *selfie;
@property (nonatomic, retain) NSArray *files;
@property (nonatomic, retain) TLSecurePlainData *plain_data;
@property (nonatomic, retain) NSData *n_hash;

@end

@interface TLSecureValue$secureValueMeta : TLSecureValue

@end
