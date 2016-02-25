#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLmessages_FoundGifs;

@interface TLRPCmessages_searchGifs : TLMetaRpc

@property (nonatomic, retain) NSString *q;
@property (nonatomic) int32_t offset;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCmessages_searchGifs$messages_searchGifs : TLRPCmessages_searchGifs


@end

