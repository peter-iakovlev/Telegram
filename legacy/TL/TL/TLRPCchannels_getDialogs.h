#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLmessages_Dialogs;

@interface TLRPCchannels_getDialogs : TLMetaRpc

@property (nonatomic) int32_t offset;
@property (nonatomic) int32_t limit;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCchannels_getDialogs$channels_getDialogs : TLRPCchannels_getDialogs


@end

