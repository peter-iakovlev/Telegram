#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLmessages_Dialogs : NSObject <TLObject>

@property (nonatomic, retain) NSArray *dialogs;
@property (nonatomic, retain) NSArray *messages;
@property (nonatomic, retain) NSArray *chats;
@property (nonatomic, retain) NSArray *users;

@end

@interface TLmessages_Dialogs$messages_dialogs : TLmessages_Dialogs


@end

@interface TLmessages_Dialogs$messages_dialogsSlice : TLmessages_Dialogs

@property (nonatomic) int32_t count;

@end

