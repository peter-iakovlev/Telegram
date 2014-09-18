#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLInputGeoChat;
@class TLgeochats_StatedMessage;

@interface TLRPCgeochats_checkin : TLMetaRpc

@property (nonatomic, retain) TLInputGeoChat *peer;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCgeochats_checkin$geochats_checkin : TLRPCgeochats_checkin


@end

