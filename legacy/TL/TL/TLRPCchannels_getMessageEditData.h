#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLInputChannel;
@class TLchannels_MessageEditData;

@interface TLRPCchannels_getMessageEditData : TLMetaRpc

@property (nonatomic, retain) TLInputChannel *channel;
@property (nonatomic) int32_t n_id;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCchannels_getMessageEditData$channels_getMessageEditData : TLRPCchannels_getMessageEditData


@end

