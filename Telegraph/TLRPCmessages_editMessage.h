#import <Foundation/Foundation.h>

#import "TLMetaRpc.h"
#import "TLObject.h"

#import "TLMetaRpc.h"

@class TLInputPeer;

//messages.editMessage flags:# no_webpage:flags.1?true peer:InputPeer id:int message:string entities:flags.3?Vector<MessageEntity> reply_markup:flags.2?ReplyMarkup = Updates

@interface TLRPCmessages_editMessage : TLMetaRpc

@property (nonatomic) int32_t flags;
@property (nonatomic) bool no_webpage;
@property (nonatomic, strong) TLInputPeer *peer;
@property (nonatomic) int32_t n_id;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) NSArray *entities;

@end
