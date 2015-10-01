#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLInputPeer;
@class TLMessagesFilter;
@class TLmessages_Messages;

@interface TLRPCmessages_search : TLMetaRpc

@property (nonatomic) int32_t flags;
@property (nonatomic, retain) TLInputPeer *peer;
@property (nonatomic, retain) NSString *q;
@property (nonatomic, retain) TLMessagesFilter *filter;
@property (nonatomic) int32_t min_date;
@property (nonatomic) int32_t max_date;
@property (nonatomic) int32_t offset;
@property (nonatomic) int32_t max_id;
@property (nonatomic) int32_t limit;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCmessages_search$messages_search : TLRPCmessages_search


@end

