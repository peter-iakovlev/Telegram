#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLSecureFile : NSObject <TLObject>

@end

@interface TLSecureFile$secureFileEmpty : TLSecureFile

@end

@interface TLSecureFile$secureFile : TLSecureFile

@property (nonatomic) int64_t n_id;
@property (nonatomic) int64_t access_hash;
@property (nonatomic) int32_t size;
@property (nonatomic) int32_t dc_id;
@property (nonatomic) int32_t date;
@property (nonatomic, retain) NSData *file_hash;
@property (nonatomic, retain) NSData *secret;

@end
