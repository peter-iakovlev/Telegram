#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLmessages_AffectedMessages;

@interface TLRPCmessages_deleteMessages : TLMetaRpc

@property (nonatomic) int32_t flags;
@property (nonatomic, retain) NSArray *n_id;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCmessages_deleteMessages$messages_deleteMessages : TLRPCmessages_deleteMessages


@end

