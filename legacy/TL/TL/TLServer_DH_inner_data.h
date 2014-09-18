#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLServer_DH_inner_data : NSObject <TLObject>

@property (nonatomic, retain) NSData *nonce;
@property (nonatomic, retain) NSData *server_nonce;
@property (nonatomic) int32_t g;
@property (nonatomic, retain) NSData *dh_prime;
@property (nonatomic, retain) NSData *g_a;
@property (nonatomic) int32_t server_time;

@end

@interface TLServer_DH_inner_data$server_DH_inner_data : TLServer_DH_inner_data


@end

