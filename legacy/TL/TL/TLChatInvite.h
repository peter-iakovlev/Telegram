#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLChat;

@interface TLChatInvite : NSObject <TLObject>


@end

@interface TLChatInvite$chatInviteAlready : TLChatInvite

@property (nonatomic, retain) TLChat *chat;

@end

@interface TLChatInvite$chatInvite : TLChatInvite

@property (nonatomic) int32_t flags;
@property (nonatomic, retain) NSString *title;

@end

