#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLInputPeer;
@class TLmessages_Messages;

@interface TLRPCmessages_searchGlobal : TLMetaRpc

@property (nonatomic, retain) NSString *q;
@property (nonatomic) int32_t offset_date;
@property (nonatomic, retain) TLInputPeer *offset_peer;
@property (nonatomic) int32_t offset_id;
@property (nonatomic) int32_t limit;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCmessages_searchGlobal$messages_searchGlobal : TLRPCmessages_searchGlobal


@end

