#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLPhoto;

@interface TLMessageAction : NSObject <TLObject>


@end

@interface TLMessageAction$messageActionEmpty : TLMessageAction


@end

@interface TLMessageAction$messageActionChatCreate : TLMessageAction

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSArray *users;

@end

@interface TLMessageAction$messageActionChatEditTitle : TLMessageAction

@property (nonatomic, retain) NSString *title;

@end

@interface TLMessageAction$messageActionChatEditPhoto : TLMessageAction

@property (nonatomic, retain) TLPhoto *photo;

@end

@interface TLMessageAction$messageActionChatDeletePhoto : TLMessageAction


@end

@interface TLMessageAction$messageActionChatAddUser : TLMessageAction

@property (nonatomic) int32_t user_id;

@end

@interface TLMessageAction$messageActionChatDeleteUser : TLMessageAction

@property (nonatomic) int32_t user_id;

@end

@interface TLMessageAction$messageActionSentRequest : TLMessageAction

@property (nonatomic) bool has_phone;

@end

@interface TLMessageAction$messageActionAcceptRequest : TLMessageAction


@end

@interface TLMessageAction$messageActionChatJoinedByLink : TLMessageAction

@property (nonatomic) int32_t inviter_id;

@end

@interface TLMessageAction$messageActionChannelCreate : TLMessageAction

@property (nonatomic, retain) NSString *title;

@end

@interface TLMessageAction$messageActionChannelToggleComments : TLMessageAction

@property (nonatomic) bool enabled;

@end

