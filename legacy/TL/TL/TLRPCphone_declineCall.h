#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLInputPhoneCall;

@interface TLRPCphone_declineCall : TLMetaRpc

@property (nonatomic, retain) TLInputPhoneCall *n_id;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCphone_declineCall$phone_declineCall : TLRPCphone_declineCall


@end

