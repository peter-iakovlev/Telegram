#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLInputPhoneCall;
@class TLPhoneCallProtocol;
@class TLphone_PhoneCall;

@interface TLRPCphone_acceptCall : TLMetaRpc

@property (nonatomic, retain) TLInputPhoneCall *peer;
@property (nonatomic, retain) NSData *g_b;
@property (nonatomic, retain) TLPhoneCallProtocol *protocol;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCphone_acceptCall$phone_acceptCall : TLRPCphone_acceptCall


@end

