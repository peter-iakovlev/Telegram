#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLInputCheckPasswordSRP : NSObject <TLObject>

@end

@interface TLInputCheckPasswordSRP$inputCheckPasswordSRP : TLInputCheckPasswordSRP

@property (nonatomic) int64_t srp_id;
@property (nonatomic, retain) NSData *A;
@property (nonatomic, retain) NSData *M1;

@end

@interface TLInputCheckPasswordSRP$inputCheckPasswordEmpty : TLInputCheckPasswordSRP

@end
