#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLInputDocument;

@interface TLRPCmessages_saveGif : TLMetaRpc

@property (nonatomic, retain) TLInputDocument *n_id;
@property (nonatomic) bool unsave;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCmessages_saveGif$messages_saveGif : TLRPCmessages_saveGif


@end

