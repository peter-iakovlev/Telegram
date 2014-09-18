#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLInputPeer;
@class TLmessages_SentMessage;

@interface TLRPCmessages_sendMessage : TLMetaRpc

@property (nonatomic, retain) TLInputPeer *peer;
@property (nonatomic, retain) NSString *message;
@property (nonatomic) int64_t random_id;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCmessages_sendMessage$messages_sendMessage : TLRPCmessages_sendMessage


@end

