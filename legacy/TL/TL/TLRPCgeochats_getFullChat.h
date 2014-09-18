#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLInputGeoChat;
@class TLmessages_ChatFull;

@interface TLRPCgeochats_getFullChat : TLMetaRpc

@property (nonatomic, retain) TLInputGeoChat *peer;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCgeochats_getFullChat$geochats_getFullChat : TLRPCgeochats_getFullChat


@end

