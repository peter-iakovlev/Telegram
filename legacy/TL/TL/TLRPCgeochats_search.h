#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLInputGeoChat;
@class TLMessagesFilter;
@class TLgeochats_Messages;

@interface TLRPCgeochats_search : TLMetaRpc

@property (nonatomic, retain) TLInputGeoChat *peer;
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

@interface TLRPCgeochats_search$geochats_search : TLRPCgeochats_search


@end

