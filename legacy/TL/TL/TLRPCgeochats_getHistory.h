#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLInputGeoChat;
@class TLgeochats_Messages;

@interface TLRPCgeochats_getHistory : TLMetaRpc

@property (nonatomic, retain) TLInputGeoChat *peer;
@property (nonatomic) int32_t offset;
@property (nonatomic) int32_t max_id;
@property (nonatomic) int32_t limit;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCgeochats_getHistory$geochats_getHistory : TLRPCgeochats_getHistory


@end

