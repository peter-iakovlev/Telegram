#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLInputDocument;

@interface TLRPCmessages_saveRecentSticker : TLMetaRpc

@property (nonatomic, retain) TLInputDocument *n_id;
@property (nonatomic) bool unsave;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCmessages_saveRecentSticker$messages_saveRecentSticker : TLRPCmessages_saveRecentSticker


@end

