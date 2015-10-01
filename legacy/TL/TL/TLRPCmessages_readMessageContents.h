#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLmessages_AffectedMessages;

@interface TLRPCmessages_readMessageContents : TLMetaRpc

@property (nonatomic, retain) NSArray *n_id;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCmessages_readMessageContents$messages_readMessageContents : TLRPCmessages_readMessageContents


@end

