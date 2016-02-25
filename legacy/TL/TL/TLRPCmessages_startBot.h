#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLInputUser;
@class TLInputPeer;
@class TLUpdates;

@interface TLRPCmessages_startBot : TLMetaRpc

@property (nonatomic, retain) TLInputUser *bot;
@property (nonatomic, retain) TLInputPeer *peer;
@property (nonatomic) int64_t random_id;
@property (nonatomic, retain) NSString *start_param;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCmessages_startBot$messages_startBot : TLRPCmessages_startBot


@end

