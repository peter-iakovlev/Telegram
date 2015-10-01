#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLchannels_ChannelParticipants : NSObject <TLObject>

@property (nonatomic) int32_t count;
@property (nonatomic, retain) NSArray *participants;
@property (nonatomic, retain) NSArray *users;

@end

@interface TLchannels_ChannelParticipants$channels_channelParticipants : TLchannels_ChannelParticipants


@end

