#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLMessage;

@interface TLmessages_Message : NSObject <TLObject>


@end

@interface TLmessages_Message$messages_messageEmpty : TLmessages_Message


@end

@interface TLmessages_Message$messages_message : TLmessages_Message

@property (nonatomic, retain) TLMessage *message;
@property (nonatomic, retain) NSArray *chats;
@property (nonatomic, retain) NSArray *users;

@end

