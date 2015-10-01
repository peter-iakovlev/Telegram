#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLInputChannel;
@class TLExportedChatInvite;

@interface TLRPCchannels_exportInvite : TLMetaRpc

@property (nonatomic, retain) TLInputChannel *channel;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCchannels_exportInvite$channels_exportInvite : TLRPCchannels_exportInvite


@end

