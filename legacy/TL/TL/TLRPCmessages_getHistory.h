#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLInputPeer;
@class TLmessages_Messages;

@interface TLRPCmessages_getHistory : TLMetaRpc

@property (nonatomic, retain) TLInputPeer *peer;
@property (nonatomic) int32_t offset_id;
@property (nonatomic) int32_t offset_date;
@property (nonatomic) int32_t add_offset;
@property (nonatomic) int32_t limit;
@property (nonatomic) int32_t max_id;
@property (nonatomic) int32_t min_id;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCmessages_getHistory$messages_getHistory : TLRPCmessages_getHistory


@end

