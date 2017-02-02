#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLmessages_Chats;

@interface TLRPCchannels_getAdminedPublicChannels : TLMetaRpc


- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCchannels_getAdminedPublicChannels$channels_getAdminedPublicChannels : TLRPCchannels_getAdminedPublicChannels


@end

