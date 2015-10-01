#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLmessages_Stickers;

@interface TLRPCmessages_getStickers : TLMetaRpc

@property (nonatomic, retain) NSString *emoticon;
@property (nonatomic, retain) NSString *n_hash;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCmessages_getStickers$messages_getStickers : TLRPCmessages_getStickers


@end

