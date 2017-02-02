#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLmessages_Chats : NSObject <TLObject>

@property (nonatomic, retain) NSArray *chats;

@end

@interface TLmessages_Chats$messages_chats : TLmessages_Chats


@end

@interface TLmessages_Chats$messages_chatsSlice : TLmessages_Chats

@property (nonatomic) int32_t count;

@end

