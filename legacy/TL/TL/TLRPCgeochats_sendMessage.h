#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLInputGeoChat;
@class TLgeochats_StatedMessage;

@interface TLRPCgeochats_sendMessage : TLMetaRpc

@property (nonatomic, retain) TLInputGeoChat *peer;
@property (nonatomic, retain) NSString *message;
@property (nonatomic) int64_t random_id;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCgeochats_sendMessage$geochats_sendMessage : TLRPCgeochats_sendMessage


@end

