#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLInputUser;
@class TLPhoneCall;

@interface TLRPCphone_requestCall : TLMetaRpc

@property (nonatomic, retain) TLInputUser *user_id;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCphone_requestCall$phone_requestCall : TLRPCphone_requestCall


@end

