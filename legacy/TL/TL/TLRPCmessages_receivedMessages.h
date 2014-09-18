#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class NSArray_int;

@interface TLRPCmessages_receivedMessages : TLMetaRpc

@property (nonatomic) int32_t max_id;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCmessages_receivedMessages$messages_receivedMessages : TLRPCmessages_receivedMessages


@end

