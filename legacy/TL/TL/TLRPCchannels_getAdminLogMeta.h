#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLInputChannel;
@class TLChannelAdminLogEventsFilter;
@class TLchannels_AdminLogResults;

@interface TLRPCchannels_getAdminLogMeta : TLMetaRpc

@property (nonatomic) int32_t flags;
@property (nonatomic, retain) TLInputChannel *channel;
@property (nonatomic, retain) NSString *q;
@property (nonatomic, retain) TLChannelAdminLogEventsFilter *events_filter;
@property (nonatomic, retain) NSArray *admins;
@property (nonatomic) int64_t max_id;
@property (nonatomic) int64_t min_id;
@property (nonatomic) int32_t limit;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCchannels_getAdminLogMeta$channels_getAdminLogMeta : TLRPCchannels_getAdminLogMeta


@end

