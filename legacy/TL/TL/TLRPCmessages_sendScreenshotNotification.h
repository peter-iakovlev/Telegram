#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLInputPeer;
@class TLUpdates;

@interface TLRPCmessages_sendScreenshotNotification : TLMetaRpc

@property (nonatomic, retain) TLInputPeer *peer;
@property (nonatomic) int32_t reply_to_msg_id;
@property (nonatomic) int64_t random_id;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCmessages_sendScreenshotNotification$messages_sendScreenshotNotification : TLRPCmessages_sendScreenshotNotification


@end

