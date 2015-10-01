#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLInputChannel;
@class TLChannelMessagesFilter;
@class TLupdates_ChannelDifference;

@interface TLRPCupdates_getChannelDifference : TLMetaRpc

@property (nonatomic, retain) TLInputChannel *channel;
@property (nonatomic, retain) TLChannelMessagesFilter *filter;
@property (nonatomic) int32_t pts;
@property (nonatomic) int32_t limit;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCupdates_getChannelDifference$updates_getChannelDifference : TLRPCupdates_getChannelDifference


@end

