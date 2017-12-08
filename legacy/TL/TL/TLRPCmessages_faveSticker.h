#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLInputDocument;

@interface TLRPCmessages_faveSticker : TLMetaRpc

@property (nonatomic, retain) TLInputDocument *n_id;
@property (nonatomic) bool unfave;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCmessages_faveSticker$messages_faveSticker : TLRPCmessages_faveSticker


@end

