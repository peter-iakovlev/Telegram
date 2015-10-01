#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLInputChannel;
@class TLmessages_ChatFull;

@interface TLRPCchannels_getFullChannel : TLMetaRpc

@property (nonatomic, retain) TLInputChannel *channel;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCchannels_getFullChannel$channels_getFullChannel : TLRPCchannels_getFullChannel


@end

