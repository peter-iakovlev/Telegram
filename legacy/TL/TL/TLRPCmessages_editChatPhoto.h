#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLInputChatPhoto;
@class TLUpdates;

@interface TLRPCmessages_editChatPhoto : TLMetaRpc

@property (nonatomic) int32_t chat_id;
@property (nonatomic, retain) TLInputChatPhoto *photo;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCmessages_editChatPhoto$messages_editChatPhoto : TLRPCmessages_editChatPhoto


@end

