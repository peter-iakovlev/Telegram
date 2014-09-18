#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLmessages_StatedMessages : NSObject <TLObject>

@property (nonatomic, retain) NSArray *messages;
@property (nonatomic, retain) NSArray *chats;
@property (nonatomic, retain) NSArray *users;
@property (nonatomic) int32_t pts;
@property (nonatomic) int32_t seq;

@end

@interface TLmessages_StatedMessages$messages_statedMessages : TLmessages_StatedMessages


@end

@interface TLmessages_StatedMessages$messages_statedMessagesLinks : TLmessages_StatedMessages

@property (nonatomic, retain) NSArray *links;

@end

