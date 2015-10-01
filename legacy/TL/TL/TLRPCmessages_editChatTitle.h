#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLUpdates;

@interface TLRPCmessages_editChatTitle : TLMetaRpc

@property (nonatomic) int32_t chat_id;
@property (nonatomic, retain) NSString *title;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCmessages_editChatTitle$messages_editChatTitle : TLRPCmessages_editChatTitle


@end

