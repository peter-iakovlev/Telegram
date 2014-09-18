#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLInputPhoneCall;
@class TLPhoneConnection;

@interface TLRPCphone_confirmCall : TLMetaRpc

@property (nonatomic, retain) TLInputPhoneCall *n_id;
@property (nonatomic, retain) NSData *a_or_b;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCphone_confirmCall$phone_confirmCall : TLRPCphone_confirmCall


@end

