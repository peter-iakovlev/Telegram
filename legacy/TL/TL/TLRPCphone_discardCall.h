#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLInputPhoneCall;
@class TLPhoneCallDiscardReason;
@class TLUpdates;

@interface TLRPCphone_discardCall : TLMetaRpc

@property (nonatomic, retain) TLInputPhoneCall *peer;
@property (nonatomic) int32_t duration;
@property (nonatomic, retain) TLPhoneCallDiscardReason *reason;
@property (nonatomic) int64_t connection_id;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCphone_discardCall$phone_discardCall : TLRPCphone_discardCall


@end

