#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLChat;
@class TLChatPhoto;

@interface TLChatInvite : NSObject <TLObject>


@end

@interface TLChatInvite$chatInviteAlready : TLChatInvite

@property (nonatomic, retain) TLChat *chat;

@end

@interface TLChatInvite$chatInviteMeta : TLChatInvite

@property (nonatomic) int32_t flags;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) TLChatPhoto *photo;
@property (nonatomic) int32_t participants_count;
@property (nonatomic, retain) NSArray *participants;

@end

