#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLSet_client_DH_params_answer;

@interface TLRPCset_client_DH_params : TLMetaRpc

@property (nonatomic, retain) NSData *nonce;
@property (nonatomic, retain) NSData *server_nonce;
@property (nonatomic, retain) NSData *encrypted_data;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCset_client_DH_params$set_client_DH_params : TLRPCset_client_DH_params


@end

