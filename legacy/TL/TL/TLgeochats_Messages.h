#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLgeochats_Messages : NSObject <TLObject>

@property (nonatomic, retain) NSArray *messages;
@property (nonatomic, retain) NSArray *chats;
@property (nonatomic, retain) NSArray *users;

@end

@interface TLgeochats_Messages$geochats_messages : TLgeochats_Messages


@end

@interface TLgeochats_Messages$geochats_messagesSlice : TLgeochats_Messages

@property (nonatomic) int32_t count;

@end

