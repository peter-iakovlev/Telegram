#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLInputGeoChat;
@class TLInputMedia;
@class TLgeochats_StatedMessage;

@interface TLRPCgeochats_sendMedia : TLMetaRpc

@property (nonatomic, retain) TLInputGeoChat *peer;
@property (nonatomic, retain) TLInputMedia *media;
@property (nonatomic) int64_t random_id;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCgeochats_sendMedia$geochats_sendMedia : TLRPCgeochats_sendMedia


@end

