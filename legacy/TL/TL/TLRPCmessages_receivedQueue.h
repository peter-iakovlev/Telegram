#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class NSArray_long;

@interface TLRPCmessages_receivedQueue : TLMetaRpc

@property (nonatomic) int32_t max_qts;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCmessages_receivedQueue$messages_receivedQueue : TLRPCmessages_receivedQueue


@end

