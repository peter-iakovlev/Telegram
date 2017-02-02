#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLInputPhoneCall;

@interface TLRPCphone_receivedCall : TLMetaRpc

@property (nonatomic, retain) TLInputPhoneCall *peer;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCphone_receivedCall$phone_receivedCall : TLRPCphone_receivedCall


@end

