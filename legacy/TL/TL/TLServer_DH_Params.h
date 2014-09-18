#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLServer_DH_Params : NSObject <TLObject>

@property (nonatomic, retain) NSData *nonce;
@property (nonatomic, retain) NSData *server_nonce;

@end

@interface TLServer_DH_Params$server_DH_params_fail : TLServer_DH_Params

@property (nonatomic, retain) NSData *n_new_nonce_hash;

@end

@interface TLServer_DH_Params$server_DH_params_ok : TLServer_DH_Params

@property (nonatomic, retain) NSData *encrypted_answer;

@end

