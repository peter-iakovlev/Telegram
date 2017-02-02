#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLInputChannel;
@class TLUpdates;

@interface TLRPCchannels_updatePinnedMessage : TLMetaRpc

@property (nonatomic) int32_t flags;
@property (nonatomic, retain) TLInputChannel *channel;
@property (nonatomic) int32_t n_id;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCchannels_updatePinnedMessage$channels_updatePinnedMessage : TLRPCchannels_updatePinnedMessage


@end

