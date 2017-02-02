#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLmessages_Messages : NSObject <TLObject>

@property (nonatomic, retain) NSArray *messages;
@property (nonatomic, retain) NSArray *chats;
@property (nonatomic, retain) NSArray *users;

@end

@interface TLmessages_Messages$messages_messages : TLmessages_Messages


@end

@interface TLmessages_Messages$messages_messagesSlice : TLmessages_Messages

@property (nonatomic) int32_t count;

@end

@interface TLmessages_Messages$messages_channelMessages : TLmessages_Messages

@property (nonatomic) int32_t flags;
@property (nonatomic) int32_t pts;
@property (nonatomic) int32_t count;

@end

