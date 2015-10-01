#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLInputChannel;
@class TLInputUser;
@class TLUpdates;

@interface TLRPCchannels_kickFromChannel : TLMetaRpc

@property (nonatomic, retain) TLInputChannel *channel;
@property (nonatomic, retain) TLInputUser *user_id;
@property (nonatomic) bool kicked;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCchannels_kickFromChannel$channels_kickFromChannel : TLRPCchannels_kickFromChannel


@end

