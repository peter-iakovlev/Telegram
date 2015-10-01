#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLInputChannel;
@class TLChannelParticipantsFilter;
@class TLchannels_ChannelParticipants;

@interface TLRPCchannels_getParticipants : TLMetaRpc

@property (nonatomic, retain) TLInputChannel *channel;
@property (nonatomic, retain) TLChannelParticipantsFilter *filter;
@property (nonatomic) int32_t offset;
@property (nonatomic) int32_t limit;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCchannels_getParticipants$channels_getParticipants : TLRPCchannels_getParticipants


@end

