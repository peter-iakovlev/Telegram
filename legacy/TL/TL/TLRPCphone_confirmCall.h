#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLInputPhoneCall;
@class TLPhoneCallProtocol;
@class TLphone_PhoneCall;

@interface TLRPCphone_confirmCall : TLMetaRpc

@property (nonatomic, retain) TLInputPhoneCall *peer;
@property (nonatomic, retain) NSData *g_a;
@property (nonatomic) int64_t key_fingerprint;
@property (nonatomic, retain) TLPhoneCallProtocol *protocol;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCphone_confirmCall$phone_confirmCall : TLRPCphone_confirmCall


@end

