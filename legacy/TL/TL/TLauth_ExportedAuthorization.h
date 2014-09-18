#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLauth_ExportedAuthorization : NSObject <TLObject>

@property (nonatomic) int32_t n_id;
@property (nonatomic, retain) NSData *bytes;

@end

@interface TLauth_ExportedAuthorization$auth_exportedAuthorization : TLauth_ExportedAuthorization


@end

