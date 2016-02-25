#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLmessages_SavedGifs;

@interface TLRPCmessages_getSavedGifs : TLMetaRpc

@property (nonatomic) int32_t n_hash;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCmessages_getSavedGifs$messages_getSavedGifs : TLRPCmessages_getSavedGifs


@end

