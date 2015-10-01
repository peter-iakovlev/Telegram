#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLInputChannel;
@class TLInputChatPhoto;
@class TLUpdates;

@interface TLRPCchannels_editPhoto : TLMetaRpc

@property (nonatomic, retain) TLInputChannel *channel;
@property (nonatomic, retain) TLInputChatPhoto *photo;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCchannels_editPhoto$channels_editPhoto : TLRPCchannels_editPhoto


@end

