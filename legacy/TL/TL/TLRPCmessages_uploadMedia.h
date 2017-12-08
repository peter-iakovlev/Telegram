#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLInputPeer;
@class TLInputMedia;

@interface TLRPCmessages_uploadMedia : TLMetaRpc

@property (nonatomic, retain) TLInputPeer *peer;
@property (nonatomic, retain) TLInputMedia *media;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCmessages_uploadMedia$messages_uploadMedia : TLRPCmessages_uploadMedia


@end
