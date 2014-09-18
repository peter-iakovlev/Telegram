#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLInputGeoChat;

@interface TLRPCgeochats_setTyping : TLMetaRpc

@property (nonatomic, retain) TLInputGeoChat *peer;
@property (nonatomic) bool typing;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCgeochats_setTyping$geochats_setTyping : TLRPCgeochats_setTyping


@end

