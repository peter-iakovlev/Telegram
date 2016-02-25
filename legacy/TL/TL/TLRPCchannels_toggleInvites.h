#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLInputChannel;
@class TLUpdates;

@interface TLRPCchannels_toggleInvites : TLMetaRpc

@property (nonatomic, retain) TLInputChannel *channel;
@property (nonatomic) bool enabled;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCchannels_toggleInvites$channels_toggleInvites : TLRPCchannels_toggleInvites


@end

