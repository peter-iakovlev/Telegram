#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLInputChannel;
@class TLExportedMessageLink;

@interface TLRPCchannels_exportMessageLink : TLMetaRpc

@property (nonatomic, retain) TLInputChannel *channel;
@property (nonatomic) int32_t n_id;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCchannels_exportMessageLink$channels_exportMessageLink : TLRPCchannels_exportMessageLink


@end

