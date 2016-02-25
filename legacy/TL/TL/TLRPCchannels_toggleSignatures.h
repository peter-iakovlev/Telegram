#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLInputChannel;
@class TLUpdates;

@interface TLRPCchannels_toggleSignatures : TLMetaRpc

@property (nonatomic, retain) TLInputChannel *channel;
@property (nonatomic) bool enabled;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCchannels_toggleSignatures$channels_toggleSignatures : TLRPCchannels_toggleSignatures


@end

