#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLUpdates;

@interface TLRPCmessages_importChatInvite : TLMetaRpc

@property (nonatomic, retain) NSString *n_hash;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCmessages_importChatInvite$messages_importChatInvite : TLRPCmessages_importChatInvite


@end

