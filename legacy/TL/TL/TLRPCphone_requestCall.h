#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLInputUser;
@class TLPhoneCallProtocol;
@class TLphone_PhoneCall;

@interface TLRPCphone_requestCall : TLMetaRpc

@property (nonatomic, retain) TLInputUser *user_id;
@property (nonatomic) int32_t random_id;
@property (nonatomic, retain) NSData *g_a_hash;
@property (nonatomic, retain) TLPhoneCallProtocol *protocol;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCphone_requestCall$phone_requestCall : TLRPCphone_requestCall


@end

